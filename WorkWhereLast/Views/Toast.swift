//
//  Toast.swift
//  WorkWhereLast
//
//  Created by Mustafa Girgin on 20.03.2024.
//

import Foundation

struct Toast: Equatable {
  var style: ToastStyle
    var title: String
  var message: String
  var duration: Double = 3
  var width: Double = .infinity
}



enum ToastStyle {
  case error
  case warning
  case success
  case info
}

extension ToastStyle {
  var themeColor: Color {
    switch self {
    case .error: return Color.red
    case .warning: return Color.orange
    case .info: return Color.blue
    case .success: return Color.green
    }
  }
  
  var iconFileName: String {
    switch self {
    case .info: return "info.circle.fill"
    case .warning: return "exclamationmark.triangle.fill"
    case .success: return "checkmark.circle.fill"
    case .error: return "xmark.circle.fill"
    }
  }
}

//
//  ToastView.swift
//  ToastDemo
//
//  Created by Ondrej Kvasnovsky on 1/30/23.
//

import SwiftUI
//
//  FancyToastView.swift
//  ToastDemo
//
//  Created by Ondrej Kvasnovsky on 1/30/23.
//

import SwiftUI

struct ToastView: View {
  
  var type: ToastStyle
  var title: String
  var message: String
  var onCancelTapped: (() -> Void)
  
  var body: some View {
    VStack(alignment: .leading) {
      HStack(alignment: .top) {
        Image(systemName: type.iconFileName)
          .foregroundColor(type.themeColor)
        
        VStack(alignment: .leading) {
          Text(title)
            .font(.system(size: 14, weight: .semibold))
          
          Text(message)
            .font(.system(size: 12))
            .foregroundColor(Color.black.opacity(0.6))
        }
        
        Spacer(minLength: 10)
        
        Button {
          onCancelTapped()
        } label: {
          Image(systemName: "xmark")
            .foregroundColor(Color.black)
        }
      }
      .padding()
    }
    
    .overlay(
      Rectangle()
        .fill(type.themeColor)
        .frame(width: 6)
        .clipped()
      , alignment: .leading
    )
    .frame(minWidth: 0, maxWidth: .infinity)
    .cornerRadius(20)
    .background(RoundedRectangle(cornerRadius: 20, style: .continuous).foregroundStyle(.ultraThinMaterial))
    
    .padding(.horizontal, 16)
  }
}

//  ToastModifier.swift
//  ToastDemo
//
//  Created by Ondrej Kvasnovsky on 1/30/23.
//

import Foundation
import SwiftUI

struct ToastModifier: ViewModifier {
  
  @Binding var toast: Toast?
  @State private var workItem: DispatchWorkItem?
  
  func body(content: Content) -> some View {
    content
      
      .overlay(alignment: .bottom) {
          
              
              
              
              
              mainToastView()
              
              
              
          .animation(.spring(), value: toast)
      }
      .onChange(of: toast) { value in
        showToast()
      }
  }
  
  @ViewBuilder func mainToastView() -> some View {
    if let toast = toast {
      VStack {
        ToastView(
            type: toast.style,
            title: toast.title,
            message: toast.message
        ) {
          dismissToast()
        }
        Spacer()
      }
      .transition(.move(edge: .top))
      .transition(AnyTransition.opacity.animation(.linear))
      .transition(AnyTransition.scale.animation(.linear))
      .transition(AnyTransition.opacity.animation(.easeInOut(duration: 0.1)))
    }
  }
  
  private func showToast() {
    guard let toast = toast else { return }
    
    UIImpactFeedbackGenerator(style: .light)
      .impactOccurred()
    
    if toast.duration > 0 {
      workItem?.cancel()
      
      let task = DispatchWorkItem {
        dismissToast()
      }
      
      workItem = task
      DispatchQueue.main.asyncAfter(deadline: .now() + toast.duration, execute: task)
    }
  }
  
  private func dismissToast() {
    withAnimation {
      toast = nil
    }
    
    workItem?.cancel()
    workItem = nil
  }
}

import SwiftUI

extension View {

  func toastView(toast: Binding<Toast?>) -> some View {
    self.modifier(ToastModifier(toast: toast))
  }
}
