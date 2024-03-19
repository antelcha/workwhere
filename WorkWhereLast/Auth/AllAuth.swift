//
//  AllAuth.swift
//  WorkWhereLast
//
//  Created by Mustafa Girgin on 19.03.2024.
//

import Foundation


import Foundation

public struct AuthInfo {
    public let profile: UserAuthInfo?
    
    public var userId: String? {
        profile?.uid
    }
    
    public var isSignedIn: Bool {
        profile != nil
    }
}

public enum Configuration {
    case mock, firebase
    
    var provider: AuthProvider {
        switch self {
        case .firebase:
            return FirebaseAuthProvider()
        case .mock:
            return MockAuthProvider()
        }
    }
}

import FirebaseFirestore




@MainActor
public final class AuthManager: ObservableObject {
    

    private let provider: AuthProvider
    @Published var isSignedIn: Bool = false
    @Published var isNewUser : Bool = false
    @Published public private(set) var currentUser: AuthInfo
    let db = Firestore.firestore()

    private var task: Task<Void, Never>? = nil
    
    static let shared = AuthManager(configuration: .firebase)
    
    private init(configuration: Configuration) {
        self.provider = configuration.provider
        self.currentUser = AuthInfo(profile: provider.getAuthenticatedUser())
        self.streamSignInChangesIfNeeded()
        isSignedIn = currentUser.isSignedIn
    }
    
    public func getUserId() throws -> String {
        guard let id = currentUser.userId else {
            // If there is no userId, user should not be signed in.
            // Sign out anyway, in case there's an edge case?
            defer {
                try? signOut()
            }
            
            throw AuthManagerError.noUserId
        }
        
        return id
    }
    
    enum AuthManagerError: Error {
        case noUserId
    }
    
    private func streamSignInChangesIfNeeded() {
        // Only stream changes if a user is signed in
        // This is mainly for if their auth gets removed via Firebase Console or another application, we can automatically sign user out
        // However, we don't want to stream user signing in, since the signIn() methods should confirm sign in success
        guard currentUser.isSignedIn else { return }
        
        self.task = Task {
            for await user in provider.authenticationDidChangeStream() {
                currentUser = AuthInfo(profile: user)
            }
        }
    }
    
    public func signInGoogle(GIDClientID: String) async throws -> (user: UserAuthInfo, isNewUser: Bool) {
        let value = try await provider.authenticateUser_Google(GIDClientID: GIDClientID)
        
        currentUser = AuthInfo(profile: value.user)
        
        defer {
            streamSignInChangesIfNeeded()
        }
        DispatchQueue.main.async {
            self.isNewUser = value.isNewUser
        }
        
                   
//        if value.isNewUser == true {
//
//
//            let user = UserModel(id: value.user.uid, email: value.user.email ?? "",  name: value.user.displayName ?? "", posts: [])
//
//                       let data: [String: Any] = [
//                           "id": user.id,
//                           "email": user.email,
//                           
//                           "name": user.name,
//                           "posts": user.posts,
//                       ]
//
//                       db.collection("user").addDocument(data: data) { error in
//                           if let error = error {
//                               print("Error adding document: \(error)")
//                           } else {
//                               print("Document added successfully")
//                           }
//                       }
//                   }
////
        
        DispatchQueue.main.async {
            self.isSignedIn = true
        }
        return value
    }
    
    public func signInApple() async throws -> (user: UserAuthInfo, isNewUser: Bool) {
        let value = try await provider.authenticateUser_Apple()
        currentUser = AuthInfo(profile: value.user)

        DispatchQueue.main.async {
            self.isNewUser = value.isNewUser
        }
        
        
        
        defer {
            streamSignInChangesIfNeeded()
        }
        
        
        
        
                   
//        if value.isNewUser == true {
//
//
//            let user = UserModel(id: value.user.uid, email: value.user.email ?? "", name: value.user.displayName ?? UUID().uuidString, posts: [])
//
//                       let data: [String: Any] = [
//                           "id": user.id,
//                           "email": user.email,
//                           
//                           "name": user.name,
//                           "posts": user.posts,
//                       ]
//
//            
//                       db.collection("user").addDocument(data: data) { error in
//                           if let error = error {
//                               print("Error adding document: \(error)")
//                           } else {
//                               print("Document added successfully")
//                           }
//                       }
//                   }
        
        DispatchQueue.main.async {
            self.isSignedIn = true
        }
        return value
    }
    
    public func signOut() throws {
        try provider.signOut()
        isSignedIn = false
        clearLocalData()
    }
    
    public func deleteAuthentication() async throws {
        try await provider.deleteAccount()
        clearLocalData()
    }
    
    private func clearLocalData() {
        task?.cancel()
        task = nil
        UserDefaults.auth.reset()
        currentUser = AuthInfo(profile: nil)
    }
}




//
//  AuthProvider.swift
//
//
//  Created by Nick Sarno on 10/25/23.
//

import Foundation
import FirebaseAuth

public protocol AuthProvider {
    func getAuthenticatedUser() -> UserAuthInfo?
    func authenticationDidChangeStream() -> AsyncStream<UserAuthInfo?>
    func authenticateUser_Google(GIDClientID: String) async throws -> (user: UserAuthInfo, isNewUser: Bool)
    func authenticateUser_Apple() async throws -> (user: UserAuthInfo, isNewUser: Bool)
    func signOut() throws
    func deleteAccount() async throws
}

public struct UserAuthInfo: Codable {
    public let uid: String
    public let email: String?
    public let isAnonymous: Bool
    public let authProviders: [AuthProviderOption]
    public let displayName: String?
    public var firstName: String? = nil
    public var lastName: String? = nil
    public let phoneNumber: String?
    public let photoURL: URL?
    public let creationDate: Date?
    public let lastSignInDate: Date?
    
    init(
        uid: String,
        email: String? = nil,
        isAnonymous: Bool = false,
        authProviders: [AuthProviderOption] = [],
        displayName: String? = nil,
        firstName: String? = nil,
        lastName: String? = nil,
        phoneNumber: String? = nil,
        photoURL: URL? = nil,
        creationDate: Date? = nil,
        lastSignInDate: Date? = nil
    ) {
        self.uid = uid
        self.email = email
        self.isAnonymous = isAnonymous
        self.authProviders = authProviders
        self.displayName = displayName
        self.firstName = firstName
        self.lastName = lastName
        self.phoneNumber = phoneNumber
        self.photoURL = photoURL
        self.creationDate = creationDate
        self.lastSignInDate = lastSignInDate
    }
    
    init(user: User) {
        self.uid = user.uid
        self.email = user.email
        self.isAnonymous = user.isAnonymous
        self.authProviders = user.providerData.compactMap({ AuthProviderOption(rawValue: $0.providerID) })
        self.displayName = user.displayName
        self.firstName = UserDefaults.auth.firstName
        self.lastName = UserDefaults.auth.lastName
        self.phoneNumber = user.phoneNumber
        self.photoURL = user.photoURL
        self.creationDate = user.metadata.creationDate
        self.lastSignInDate = user.metadata.lastSignInDate
    }
    
    enum CodingKeys: String, CodingKey {
        case uid = "user_id"
        case email = "email"
        case isAnonymous = "is_anonymous"
        case authProviders = "auth_providers"
        case displayName = "display_name"
        case firstName = "first_name"
        case lastName = "last_name"
        case phoneNumber = "phone_number"
        case photoURL = "photo_url"
        case creationDate = "creation_date"
        case lastSignInDate = "last_sign_in_date"
    }
}

public enum AuthProviderOption: String, Codable {
    case google = "google.com"
    case apple = "apple.com"
    case email = "password"
    case mock = "mock"
}


//
//  FirebaseAuthProvider.swift
//
//
//  Created by Nick Sarno on 10/25/23.
//

import Foundation
import FirebaseAuth

struct FirebaseAuthProvider: AuthProvider {
    
    func getAuthenticatedUser() -> UserAuthInfo? {
        if let currentUser = Auth.auth().currentUser {
            return UserAuthInfo(user: currentUser)
        } else {
            return nil
        }
    }
    
    @MainActor
    func authenticationDidChangeStream() -> AsyncStream<UserAuthInfo?> {
        AsyncStream { continuation in
            Auth.auth().addStateDidChangeListener { _, currentUser in
                if let currentUser {
                    let user = UserAuthInfo(user: currentUser)
                    continuation.yield(user)
                } else {
                    continuation.yield(nil)
                }
            }
        }
    }
    
    @MainActor
    func authenticateUser_Apple() async throws -> (user: UserAuthInfo, isNewUser: Bool) {
        let helper = SignInWithAppleHelper()
        
        // Sign in to Apple account
        for try await appleResponse in helper.startSignInWithAppleFlow() {
            
            // Convert Apple Auth to Firebase credential
            let credential = OAuthProvider.credential(
                withProviderID: AuthProviderOption.apple.rawValue,
                idToken: appleResponse.token,
                rawNonce: appleResponse.nonce
            )
            
            // Sign in to Firebase
            let authDataResult = try await signIn(credential: credential)

            var firebaserUser = authDataResult.user
            
            // Determines if this is the first time this user is being authenticated
            let isNewUser = authDataResult.additionalUserInfo?.isNewUser ?? true
            
            if isNewUser {
                // Update Firebase user profile with info from Apple account
                if let updatedUser = try await updateUserProfile(
                    displayName: appleResponse.displayName,
                    firstName: appleResponse.firstName,
                    lastName: appleResponse.lastName,
                    photoUrl: nil
                ) {
                    firebaserUser = updatedUser
                }
            }
            
            // Convert to generic type
            let user = UserAuthInfo(user: firebaserUser)
            
            return (user, isNewUser)
        }
        
        // Should never occur - only would occur if startSignInWithAppleFlow() completed without yielding a result (success or error)
        throw AuthError.noResponse
    }
    
    @MainActor
    func authenticateUser_Google(GIDClientID: String) async throws -> (user: UserAuthInfo, isNewUser: Bool) {
        let helper = SignInWithGoogleHelper(GIDClientID: GIDClientID)
        
        // Sign in to Google account
        let googleResponse = try await helper.signIn()
        
        // Convert Google Auth to Firebase credential
        let credential = GoogleAuthProvider.credential(withIDToken: googleResponse.idToken, accessToken: googleResponse.accessToken)
        
        // Sign in to Firebase
        let authDataResult = try await signIn(credential: credential)
        
        var firebaserUser = authDataResult.user
        
        // Determines if this is the first time this user is being authenticated
        let isNewUser = authDataResult.additionalUserInfo?.isNewUser ?? true

        if isNewUser {
            // Update Firebase user profile with info from Google account
            if let updatedUser = try await updateUserProfile(
                displayName: googleResponse.displayName,
                firstName: googleResponse.firstName,
                lastName: googleResponse.lastName,
                photoUrl: googleResponse.profileImageUrl
            ) {
                firebaserUser = updatedUser
            }
        }
        
        // Convert to generic type
        let user = UserAuthInfo(user: firebaserUser)
        
        return (user, isNewUser)
    }
    
    func signOut() throws {
        try Auth.auth().signOut()
    }
    
    func deleteAccount() async throws {
        guard let user = Auth.auth().currentUser else {
            throw AuthError.userNotFound
        }
        
        try await user.delete()
    }
    
    // MARK: PRIVATE
    
    
    private func signIn(credential: AuthCredential) async throws -> AuthDataResult {
        try await Auth.auth().signIn(with: credential)
    }
    
    private func updateUserProfile(displayName: String?, firstName: String?, lastName: String?, photoUrl: URL?) async throws -> User? {
        let request = Auth.auth().currentUser?.createProfileChangeRequest()
        
        var didMakeChanges: Bool = false
        if let displayName {
            request?.displayName = displayName
            didMakeChanges = true
        }
        
        if let firstName {
            UserDefaults.auth.firstName = firstName
        }
        
        if let lastName {
            UserDefaults.auth.lastName = lastName
        }
        
        if let photoUrl {
            request?.photoURL = photoUrl
            didMakeChanges = true
        }
        
        if didMakeChanges {
            try await request?.commitChanges()
        }
        
        return Auth.auth().currentUser
    }
    
    
    private enum AuthError: LocalizedError {
        case noResponse
        case userNotFound
        
        var errorDescription: String? {
            switch self {
            case .noResponse:
                return "Bad response."
            case .userNotFound:
                return "Current user not found."
            }
        }
    }

}

extension UserDefaults {
    
    static let auth = UserDefaults(suiteName: "auth_defaults")!
    
    func reset() {
        firstName = nil
        lastName = nil
    }
    
    var firstName: String? {
        get {
            self.value(forKey: "first_name") as? String
        }
        set {
            self.setValue(newValue, forKey: "first_name")
        }
    }
    
    var lastName: String? {
        get {
            self.value(forKey: "last_name") as? String
        }
        set {
            self.setValue(newValue, forKey: "last_name")
        }
    }
}


//
//  SignInWithApple.swift
//
//
//  Created by Nick Sarno on 10/25/23.
//

import Foundation
import CryptoKit
import AuthenticationServices
import UIKit

struct SignInWithAppleResult {
    let token: String
    let nonce: String
    let email: String?
    let firstName: String?
    let lastName: String?
    let nickName: String?

    var fullName: String? {
        if let firstName, let lastName {
            return firstName + " " + lastName
        } else if let firstName {
            return firstName
        } else if let lastName {
            return lastName
        }
        return nil
    }
    
    var displayName: String? {
        fullName ?? nickName
    }

    init?(authorization: ASAuthorization, nonce: String) {
        guard
            let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential,
            let appleIDToken = appleIDCredential.identityToken,
            let token = String(data: appleIDToken, encoding: .utf8)
        else {
            return nil
        }

        self.token = token
        self.nonce = nonce
        self.email = appleIDCredential.email
        self.firstName = appleIDCredential.fullName?.givenName
        self.lastName = appleIDCredential.fullName?.familyName
        self.nickName = appleIDCredential.fullName?.nickname
    }
}

final class SignInWithAppleHelper: NSObject {
        
    private var completionHandler: ((Result<SignInWithAppleResult, Error>) -> Void)? = nil
    private var currentNonce: String? = nil
    
    /// Start Sign In With Apple and present OS modal.
    ///
    /// - Parameter viewController: ViewController to present OS modal on. If nil, function will attempt to find the top-most ViewController. Throws an error if no ViewController is found.
    @MainActor
    func startSignInWithAppleFlow(viewController: UIViewController? = nil) -> AsyncThrowingStream<SignInWithAppleResult, Error> {
        AsyncThrowingStream { continuation in
            startSignInWithAppleFlow { result in
                switch result {
                case .success(let signInWithAppleResult):
                    continuation.yield(signInWithAppleResult)
                    continuation.finish()
                    return
                case .failure(let error):
                    continuation.finish(throwing: error)
                    return
                }
            }
        }
    }
    
    @MainActor
    private func startSignInWithAppleFlow(viewController: UIViewController? = nil, completion: @escaping (Result<SignInWithAppleResult, Error>) -> Void) {
        guard let topVC = viewController ?? UIApplication.topViewController() else {
            completion(.failure(SignInWithAppleError.noViewController))
            return
        }

        let nonce = randomNonceString()
        currentNonce = nonce
        completionHandler = completion
        showOSPrompt(nonce: nonce, on: topVC)
    }
    
}

// MARK: PRIVATE
private extension SignInWithAppleHelper {
        
    // Adapted from https://auth0.com/docs/api-auth/tutorials/nonce#generate-a-cryptographically-random-nonce
    private func randomNonceString(length: Int = 32) -> String {
        precondition(length > 0)
        let charset: [Character] =
        Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
        var result = ""
        var remainingLength = length
        
        while remainingLength > 0 {
            let randoms: [UInt8] = (0 ..< 16).map { _ in
                var random: UInt8 = 0
                let errorCode = SecRandomCopyBytes(kSecRandomDefault, 1, &random)
                if errorCode != errSecSuccess {
                    fatalError(
                        "Unable to generate nonce. SecRandomCopyBytes failed with OSStatus \(errorCode)"
                    )
                }
                return random
            }
            
            randoms.forEach { random in
                if remainingLength == 0 {
                    return
                }
                
                if random < charset.count {
                    result.append(charset[Int(random)])
                    remainingLength -= 1
                }
            }
        }
        
        return result
    }
    
    private func sha256(_ input: String) -> String {
        let inputData = Data(input.utf8)
        let hashedData = SHA256.hash(data: inputData)
        let hashString = hashedData.compactMap {
            String(format: "%02x", $0)
        }.joined()
        
        return hashString
    }
    
    private func showOSPrompt(nonce: String, on viewController: UIViewController) {
        let appleIDProvider = ASAuthorizationAppleIDProvider()
        let request = appleIDProvider.createRequest()
        request.requestedScopes = [.fullName, .email]
        request.nonce = sha256(nonce)
        
        let authorizationController = ASAuthorizationController(authorizationRequests: [request])
        authorizationController.delegate = self
        authorizationController.presentationContextProvider = viewController

        authorizationController.performRequests()
    }
    
    private enum SignInWithAppleError: LocalizedError {
        case noViewController
        case invalidCredential
        case badResponse
        case unableToFindNonce
        
        var errorDescription: String? {
            switch self {
            case .noViewController:
                return "Could not find top view controller."
            case .invalidCredential:
                return "Invalid sign in credential."
            case .badResponse:
                return "Apple Sign In had a bad response."
            case .unableToFindNonce:
                return "Apple Sign In token expired."
            }
        }
    }
    
}

extension SignInWithAppleHelper: ASAuthorizationControllerDelegate {
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        do {
            guard let currentNonce else {
                throw SignInWithAppleError.unableToFindNonce
            }
            
            guard let result = SignInWithAppleResult(authorization: authorization, nonce: currentNonce) else {
                throw SignInWithAppleError.badResponse
            }
            
            completionHandler?(.success(result))
        } catch {
            completionHandler?(.failure(error))
            return
        }
    }
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        completionHandler?(.failure(error))
        return
    }
}

extension UIViewController: ASAuthorizationControllerPresentationContextProviding {
    public func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return self.view.window!
    }
}


//
//  File.swift
//
//
//  Created by Nick Sarno on 10/25/23.
//

import Foundation
import UIKit

extension UIApplication {
    
    static private func rootViewController() -> UIViewController? {
        var rootVC: UIViewController?
        if #available(iOS 15.0, *) {
            rootVC = UIApplication
                .shared
                .connectedScenes
                .compactMap { ($0 as? UIWindowScene)?.keyWindow }
                .last?
                .rootViewController
        } else {
            rootVC = UIApplication
                .shared
                .connectedScenes
                .flatMap { ($0 as? UIWindowScene)?.windows ?? [] }
                .last { $0.isKeyWindow }?
                .rootViewController
        }
        
        return rootVC ?? UIApplication.shared.keyWindow?.rootViewController
    }
    
    @MainActor static func topViewController(controller: UIViewController? = nil) -> UIViewController? {
        let controller = controller ?? rootViewController()
        
        if let navigationController = controller as? UINavigationController {
            return topViewController(controller: navigationController.visibleViewController)
        }
        if let tabController = controller as? UITabBarController {
            if let selected = tabController.selectedViewController {
                return topViewController(controller: selected)
            }
        }
        if let presented = controller?.presentedViewController {
            return topViewController(controller: presented)
        }
        return controller
    }
    
}

//
//  File.swift
//
//
//  Created by Nick Sarno on 10/25/23.
//

import Foundation
import SwiftUI
import UIKit
import GoogleSignIn
import GoogleSignInSwift

struct GoogleSignInResult {
    let idToken: String
    let accessToken: String
    let email: String?
    let firstName: String?
    let lastName: String?
    let fullName: String?
    let profileImageUrl: URL?
    
    var displayName: String? {
        fullName ?? firstName ?? lastName
    }
    
    init?(result: GIDSignInResult) {
        guard let idToken = result.user.idToken?.tokenString else {
            return nil
        }

        self.idToken = idToken
        self.accessToken = result.user.accessToken.tokenString
        self.email = result.user.profile?.email
        self.firstName = result.user.profile?.givenName
        self.lastName = result.user.profile?.familyName
        self.fullName = result.user.profile?.name
        
        let dimension = round(400 * UIScreen.main.scale)
        
        if result.user.profile?.hasImage == true {
            self.profileImageUrl = result.user.profile?.imageURL(withDimension: UInt(dimension))
        } else {
            self.profileImageUrl = nil
        }
    }
}

final class SignInWithGoogleHelper {
    
    init(GIDClientID: String) {
        let config = GIDConfiguration(clientID: GIDClientID)
        GIDSignIn.sharedInstance.configuration = config
    }
        
    @MainActor
    func signIn(viewController: UIViewController? = nil) async throws -> GoogleSignInResult {
        guard let topViewController = viewController ?? UIApplication.topViewController() else {
            throw GoogleSignInError.noViewController
        }
                
        let gidSignInResult = try await GIDSignIn.sharedInstance.signIn(withPresenting: topViewController)
        
        guard let result = GoogleSignInResult(result: gidSignInResult) else {
            throw GoogleSignInError.badResponse
        }
        
        return result
    }
    
    private enum GoogleSignInError: LocalizedError {
        case noViewController
        case badResponse
        
        var errorDescription: String? {
            switch self {
            case .noViewController:
                return "Could not find top view controller."
            case .badResponse:
                return "Google Sign In had a bad response."
            }
        }
    }
}



//
//  MockAuthProvider.swift
//
//
//  Created by Nick Sarno on 10/25/23.
//

import Foundation
import Combine

final class MockAuthProvider: AuthProvider {
    
    static private var mockUser: UserAuthInfo {
        UserAuthInfo(
            uid: "mock123",
            email: "mock123@mock.com",
            isAnonymous: false,
            authProviders: [.mock],
            displayName: "Mock User",
            phoneNumber: "1-234-5678"
        )
    }
    
    @Published private(set) var authenticatedUser: UserAuthInfo? {
        didSet {
            UserDefaults.userIsSignedIn = authenticatedUser != nil
            continuation?.yield(authenticatedUser)
        }
    }
    
    init() {
        self.authenticatedUser = UserDefaults.userIsSignedIn ? MockAuthProvider.mockUser : nil
    }
    
    private var continuation: AsyncStream<UserAuthInfo?>.Continuation? = nil
    
    
    func getAuthenticatedUser() -> UserAuthInfo? {
        authenticatedUser
    }
    
    func authenticationDidChangeStream() -> AsyncStream<UserAuthInfo?> {
        AsyncStream { continuation in
            self.continuation = continuation
        }
    }
    
    func authenticateUser_Google(GIDClientID: String) async throws -> (user: UserAuthInfo, isNewUser: Bool) {
        try? await Task.sleep(nanoseconds: 1_000_000_000)
        return signInMockUser()
    }
        
    func authenticateUser_Apple() async throws -> (user: UserAuthInfo, isNewUser: Bool) {
        try? await Task.sleep(nanoseconds: 1_000_000_000)
        return signInMockUser()
    }
    
    private func signInMockUser() -> (user: UserAuthInfo, isNewUser: Bool) {
        let count = UserDefaults.userSignedInAuthCount
        let newCount = count + 1
        
        // Increment auth count
        UserDefaults.userSignedInAuthCount = newCount
        
        
        // Persist mock sign in
        let mockUser = MockAuthProvider.mockUser
        authenticatedUser = mockUser
        
        let isNewUser = newCount == 1
        return (mockUser, isNewUser)
    }
    
    func signOut() throws {
        signOutMockUser()
    }
    
    func deleteAccount() async throws {
        signOutMockUser()
    }
    
    private func signOutMockUser() {
        // Reset auth count
        UserDefaults.userSignedInAuthCount = 0
        
        // Persist mock sign out
        authenticatedUser = nil
    }
    
}

private extension UserDefaults {
    
    private static let MockAuthDefaults = UserDefaults(suiteName: "SwiftfulFirebaseAuth_MockDefaults") ?? .standard
    
    private static let userIsSignedIn_key = "mock_user_signed_in"
    static var userIsSignedIn: Bool {
        get {
            return MockAuthDefaults.bool(forKey: userIsSignedIn_key)
        }
        set {
            return MockAuthDefaults.set(newValue, forKey: userIsSignedIn_key)
        }
    }
    
    private static let userSignedInAuthCount_key = "mock_user_signed_in_auth_count"
    static var userSignedInAuthCount: Int {
        get {
            return MockAuthDefaults.integer(forKey: userSignedInAuthCount_key)
        }
        set {
            return MockAuthDefaults.set(newValue, forKey: userSignedInAuthCount_key)
        }
    }
}
