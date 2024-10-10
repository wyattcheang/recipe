//
//  User.swift
//  recipe
//
//  Created by Wyatt Cheang on 10/10/2024.
//

import Foundation
import Auth

enum AuthState {
    case unauthenticated
    case authenticating
    case authenticated
}

@Observable
class UserModel {
    var data: User?
    var authState: AuthState
    var errorMessage: String

    init() {
        self.data = nil
        self.authState = .unauthenticated
        self.errorMessage = ""
    }
    
    func getCurrentSession() async {
        do {
            let session = try await supabase.auth.session
            self.data = session.user
        } catch {
            return
        }
    }
}


extension UserModel {
    
    func signInWithEmail(email: String, password: String, completion: @escaping (Result<Bool, Error>) -> Void) async {
        self.authState = .authenticating
        do {
            let session = try await supabase.auth.signIn(email: email, password: password)
            self.data = session.user
            self.authState = .authenticated
            completion(.success(true))
        }
        catch  {
            completion(.failure(error))
            self.authState = .unauthenticated
        }
    }
    
    func signUpWithEmail(email: String, password: String, completion: @escaping (Result<Bool, Error>) -> Void) async {
        self.authState = .authenticating
        do {
            let session = try await supabase.auth.signUp(email: email, password: password)
            self.data = session.user
            self.authState = .authenticated
            completion(.success(true))
        }
        catch  {
            completion(.failure(error))
            self.authState = .unauthenticated
        }
    }
    
    func signOut() async {
        self.authState = .authenticating
        do {
            try await supabase.auth.signOut()
            self.data = nil
            authState = .unauthenticated
        } catch {
            return
        }
    }

    
    func continueWithGoogle() async -> Bool {
        self.authState = .authenticating
        let google = await SignInGoogle()
        do {
            let result = try await google.startSignInWithGoogleFlow()
            let session = try await supabase.auth.signInWithIdToken(credentials: OpenIDConnectCredentials(provider: .google, idToken: result.idToken, accessToken: result.accessToken))
            self.data = session.user
            self.authState = .authenticated
            return true
        }
        catch {
            self.authState = .unauthenticated
            return false
        }
    }
}
