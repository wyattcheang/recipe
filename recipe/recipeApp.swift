//
//  recipeApp.swift
//  recipe
//
//  Created by Wyatt Cheang on 09/10/2024.
//

import SwiftUI
import GoogleSignIn

@main
struct recipeApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .onOpenURL { url in
                    GIDSignIn.sharedInstance.handle(url)
                }
        }
    }
}
