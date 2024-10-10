//
//  TabView.swift
//  recipe
//
//  Created by Wyatt Cheang on 11/10/2024.
//

import SwiftUI

struct MenuBarView: View {
    var body: some View {
        TabView {
            HomeView()
                .tabItem() {
                    Image(systemName:"house")
                        .padding()
                    Text("Home")
                }
            ProfileView()
                .tabItem() {
                    Image(systemName:"person.fill")
                        .padding()
                    Text("Profile")
                }
        }
    }
}

#Preview {
    MenuBarView()
}
