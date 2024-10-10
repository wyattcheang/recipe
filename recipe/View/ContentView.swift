//
//  ContentView.swift
//  recipe
//
//  Created by Wyatt Cheang on 09/10/2024.
//

import SwiftUI

@Observable
class AlertControl {
    var title: String
    var message: String
    var dismissMessage: String
    var isPresented: Bool
    
    init(title: String = "", message: String = "", dismiss: String = "OK", isPresented: Bool = false) {
        self.title = title
        self.message = message
        self.dismissMessage = dismiss
        self.isPresented = isPresented
    }
}

struct ContentView: View {
    @State private var user = UserModel()
    @State private var alert = AlertControl()
    
    var body: some View {
        Group {
            switch user.authState {
            case .unauthenticated:
                AuthView()
                    .environment(\.user, user)
                    .environment(\.alert, alert)
            case .authenticating:
                ProgressView()
            case .authenticated:
                HomeView()
                    .environment(\.user, user)
            }
        }
        .task {
            await user.getCurrentSession()
            await listenToAuthStateChanges()
        }
        .alert(isPresented: $alert.isPresented) {
            Alert(
                title: Text(alert.title),
                message: Text(alert.message),
                dismissButton: .default(Text(alert.dismissMessage))
            )
        }
    }
    
    private func listenToAuthStateChanges() async {
        for await state in supabase.auth.authStateChanges {
            if [.initialSession, .signedIn, .signedOut].contains(state.event) {
                DispatchQueue.main.async {
                    if state.session != nil {
                        user.authState = .authenticated
                    } else {
                        user.authState = .unauthenticated
                    }
                }
            }
        }
    }
}

private struct UserModelKey: EnvironmentKey {
    static var defaultValue: UserModel = UserModel()
}

private struct AlertControlKey: EnvironmentKey {
    static var defaultValue: AlertControl = AlertControl()
}

extension EnvironmentValues {
    var user: UserModel {
        get { self[UserModelKey.self] }
        set { self[UserModelKey.self] = newValue }
    }
    
    var alert: AlertControl {
        get { self[AlertControlKey.self] }
        set { self[AlertControlKey.self] = newValue }
    }
}

#Preview {
    ContentView()
}
