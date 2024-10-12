//
//  LoginIn.swift
//  recipe
//
//  Created by Wyatt Cheang on 10/10/2024.
//

import SwiftUI

enum FocusedField: Hashable {
    case email
    case password
    case confirmPassword
}

enum AuthFlow: String {
    case signIn = "Sign In"
    case signUp = "Sign Up"
    
    var reversed: AuthFlow {
        switch self {
        case .signIn: return .signUp
        case .signUp: return .signIn
        }
    }
}

@Observable
class Credential {
    var email: String = ""
    var password: String = ""
    var confirmPassword: String = ""
    var flow: AuthFlow = .signIn
    var showPassword: Bool = false
    var showConfirmPassowrd: Bool = false
    
    func reset() {
        self.email = ""
        self.password = ""
        self.confirmPassword = ""
    }
    
    var isValid: Bool {
        flow == .signIn
        ? email.isValidEmail() && password.isValidPassword()
        : email.isValidEmail() && password.isValidPassword() && password == confirmPassword
    }
    
    func switchFlow() {
        withAnimation {
            flow = flow.reversed
        }
    }
}

struct AuthView: View {
    @Environment(\.user) var user: UserModel
    @Environment(\.alert) var alert: AlertControl
    @State private var credential = Credential()
    @FocusState private var focus: FocusedField?
    
    func continueWithGoogle() {
        Task {
            guard await user.continueWithGoogle() else {
                alert.title = "Sign In Failed"
                alert.message = "Failed to Sign In with Google"
                alert.dismissMessage = "OK"
                alert.isPresented.toggle()
                return
            }
        }
    }
    
    func authentication() {
        Task {
            switch credential.flow {
            case .signIn:
                await user.signInWithEmail(email: credential.email, password: credential.password) { result in
                    switch result {
                    case .success(_):
                        credential.reset()
                    case .failure(let failure):
                        alert.title = "Sign In Failed"
                        alert.message = failure.localizedDescription
                        alert.dismissMessage = "OK"
                        alert.isPresented.toggle()
                    }
                }
            case .signUp:
                await user.signUpWithEmail(email: credential.email, password: credential.password) { result in
                    switch result {
                    case .success(_):
                        credential.reset()
                    case .failure(let failure):
                        alert.title = "Sign Up Failed"
                        alert.message = failure.localizedDescription
                        alert.dismissMessage = "OK"
                        alert.isPresented.toggle()
                    }
                }
            }
        }
    }
    var body: some View {
        VStack {
            VStack {
                VStack {
                    switch credential.flow {
                    case .signIn:
                        Text("Welcome\nBack!")
                    case .signUp:
                        Text("Join\nUs!")
                    }
                }
                .font(.system(size: 56))
                .fontWeight(.heavy)
                .fontDesign(.serif)
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .frame(minHeight: 350)
            
            Spacer()
            Button { continueWithGoogle()}
            label: {
                Image("google")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 20)
                Text("Continue with Google")
            }
            .padding()
            .frame(maxWidth: .infinity)
            .foregroundColor(.black)
            .background(.white)
            .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .stroke(Color.gray, lineWidth: 1)
            )
            
            Divider()
                .overlay(
                    Text("or")
                        .padding(.horizontal, 6)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                )
                .padding(.vertical, 6)
            
            TextField("Email", text: $credential.email)
                .keyboardType(.emailAddress)
                .textContentType(.emailAddress)
                .textInputAutocapitalization(.never)
                .disableAutocorrection(true)
                .focused($focus, equals: .email)
                .onSubmit(onSubmit)
                .textFieldStyle(RectStyle())
            
            TextField("Password", text: $credential.password)
                .focused($focus, equals: .password)
                .onSubmit(onSubmit)
                .textFieldStyle(RectStyle())
            
            if credential.flow == .signUp {
                TextField("Confirm Password", text: $credential.confirmPassword)
                    .animation(.easeInOut, value: credential.flow)
                    .focused($focus, equals: .confirmPassword)
                    .onSubmit(onSubmit)
                    .textFieldStyle(RectStyle())
            }
            
            Button(credential.flow.rawValue, action: authentication)
                .buttonStyle(AccentButtonStyle())
                .disabled(!credential.isValid)
                .animation(.interactiveSpring, value: credential.flow)
            Spacer()
            HStack {
                Text(credential.flow == .signIn ?
                     "Don't have an account yet?" : "Already have an account?")
                Button(credential.flow.reversed.rawValue) {
                    credential.switchFlow()
                }
            }
            .animation(.interactiveSpring, value: credential.flow)
        }
        .padding(16)
    }
    
    private func onSubmit() {
        if focus == .email {
            focus = .password
        } else if focus == .password {
            if credential.flow == .signIn && credential.isValid {
                authentication()
            } else if credential.flow == .signUp {
                focus = .confirmPassword
            }
        } else if focus == .confirmPassword && credential.isValid {
            authentication()
        }
    }
}

struct PasswordField: View {
    
    var body: some View {
        TextField("Password", text: .constant(""))
    }
}

#Preview {
    AuthView()
}
