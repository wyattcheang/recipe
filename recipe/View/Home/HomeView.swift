//
//  HomeView.swift
//  recipe
//
//  Created by Wyatt Cheang on 10/10/2024.
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

struct HomeView: View {
    @Environment(\.user) var user: UserModel
    
    var body: some View {
        Text("Signed In")
        Button("Sign Out") {
            Task {
                await user.signOut()
            }
        }
        Button {
        } label: {
            Image(systemName: "plus")
                .padding()
                .background(.blue)
                .foregroundStyle(.white)
                .clipShape(.circle)
        }
    }
}

#Preview {
    HomeView()
}
