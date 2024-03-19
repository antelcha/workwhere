//
//  SignInView.swift
//  WorkWhereLast
//
//  Created by Mustafa Girgin on 20.03.2024.
//

import Foundation
import SwiftUI

@MainActor
class SignInViewModel: ObservableObject {
    let authManager = AuthManager.shared
}

struct SignInView: View {
    
    @ObservedObject var viewModel = SignInViewModel()
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        VStack {
            Image("app")
                .resizable()
                .scaledToFit()
                .frame(width: 100)

                .clipShape(RoundedRectangle(cornerRadius: 25, style: .continuous))
                .padding()

            Button(action: {
                Task {
                    try? await viewModel.authManager.signInGoogle(GIDClientID: "653951891127-kdkj7h3a87fb6q0i5hqf1q05ej4d0muh.apps.googleusercontent.com")
                    
                    dismiss()
                }
            }, label: {
                SignInWithGoogleButtonView(type: .continue, style: .whiteOutline).allowsHitTesting(false)
            })
            .frame(height: 55)

            Button(action: {
                Task {
                    try? await viewModel.authManager.signInApple()
                    dismiss()
                }
            }, label: {
                SignInWithAppleButtonView(type: .continue, style: .black)
                    .allowsHitTesting(false)
            })
            .frame(height: 55)
        }
        .preferredColorScheme(.light)
        .padding()
    }
}

//
//  SignInWithAppleButtonView.swift
//
//
//  Created by Nick Sarno on 10/25/23.
//

import AuthenticationServices
import GoogleSignInSwift
import SwiftUI

public struct SignInWithAppleButtonView: View {
    public let type: ASAuthorizationAppleIDButton.ButtonType
    public let style: ASAuthorizationAppleIDButton.Style
    public let cornerRadius: CGFloat

    public init(
        type: ASAuthorizationAppleIDButton.ButtonType = .signIn,
        style: ASAuthorizationAppleIDButton.Style = .black,
        cornerRadius: CGFloat = 10
    ) {
        self.type = type
        self.style = style
        self.cornerRadius = cornerRadius
    }

    public var body: some View {
        ZStack {
            Color.black.opacity(0.001)

            SignInWithAppleButtonViewRepresentable(type: type, style: style, cornerRadius: cornerRadius)
                .disabled(true)
        }
    }
}

private struct SignInWithAppleButtonViewRepresentable: UIViewRepresentable {
    let type: ASAuthorizationAppleIDButton.ButtonType
    let style: ASAuthorizationAppleIDButton.Style
    let cornerRadius: CGFloat

    func makeUIView(context: Context) -> some UIView {
        let button = ASAuthorizationAppleIDButton(type: type, style: style)
        button.cornerRadius = cornerRadius
        return button
    }

    func updateUIView(_ uiView: UIViewType, context: Context) {
    }

    func makeCoordinator() {
    }
}

//
//  SignInWithGoogleButtonView.swift
//
//
//  Created by Nicholas Sarno on 11/6/23.
//

import AuthenticationServices
import Foundation
import SwiftUI

fileprivate extension ASAuthorizationAppleIDButton.Style {
    var backgroundColor: Color {
        switch self {
        case .white:
            return .white
        case .whiteOutline:
            return .white
        default:
            return .black
        }
    }

    var foregroundColor: Color {
        switch self {
        case .white:
            return .black
        case .whiteOutline:
            return .black
        default:
            return .white
        }
    }

    var borderColor: Color {
        switch self {
        case .white:
            return .white
        case .whiteOutline:
            return .black
        default:
            return .black
        }
    }
}

fileprivate extension ASAuthorizationAppleIDButton.ButtonType {
    var buttonText: String {
        switch self {
        case .signIn:
            return "Sign in with"
        case .continue:
            return "Continue with"
        case .signUp:
            return "Sign up with"
        default:
            return "Sign in with"
        }
    }
}

public struct SignInWithGoogleButtonView: View {
    private var backgroundColor: Color
    private var foregroundColor: Color
    private var borderColor: Color
    private var buttonText: String
    private var cornerRadius: CGFloat

    public init(
        type: ASAuthorizationAppleIDButton.ButtonType = .signIn,
        style: ASAuthorizationAppleIDButton.Style = .black,
        cornerRadius: CGFloat = 10
    ) {
        self.cornerRadius = cornerRadius
        backgroundColor = style.backgroundColor
        foregroundColor = style.foregroundColor
        borderColor = style.borderColor
        buttonText = type.buttonText
    }

    public init(
        type: ASAuthorizationAppleIDButton.ButtonType = .signIn,
        backgroundColor: Color = .black,
        borderColor: Color = .black,
        foregroundColor: Color = .white,
        cornerRadius: CGFloat = 10
    ) {
        self.cornerRadius = cornerRadius
        self.backgroundColor = backgroundColor
        self.borderColor = borderColor
        self.foregroundColor = foregroundColor
        buttonText = type.buttonText
    }

    public var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: cornerRadius)
                .fill(borderColor)

            RoundedRectangle(cornerRadius: cornerRadius)
                .fill(backgroundColor)
                .padding(0.8)

            HStack(spacing: 6) {
                Text("\(buttonText) Google")
                    .font(.system(size: 20))
                    .fontWeight(.medium)
            }
            .foregroundColor(foregroundColor)
        }
        .padding(.vertical, 1)
        .disabled(true)
    }
}

