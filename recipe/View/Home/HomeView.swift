//
//  HomeView.swift
//  recipe
//
//  Created by Wyatt Cheang on 10/10/2024.
//

import SwiftUI

struct HomeView: View {
    @State var selectedRecipeType: RecipeType?
    @State var recipeTypes: [RecipeType] = []
    @Environment(\.user) var user: UserModel
    
    var body: some View {
        VStack {
            HStack {
                Text("Recipes")
                .font(.title)
                .fontWeight(.heavy)
                .fontDesign(.serif)
                .frame(maxWidth: .infinity, alignment: .leading)
                Spacer()
                Button {
                    Task {
                        await user.signOut()
                    }
                } label: {
                    Image(systemName: "rectangle.portrait.and.arrow.right")
                }
            }
            .padding(16)
            ScrollView(.vertical) {
                if !recipeTypes.isEmpty {
                    TabButtonBar(types: recipeTypes, selectedType: $selectedRecipeType)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
            .overlay(alignment: .bottomTrailing) {
                Button {
                } label: {
                    Image(systemName: "plus")
                        .bold()
                        .padding()
                        .background(.accent)
                        .foregroundStyle(.white)
                        .clipShape(.circle)
                }
                .padding()
            }
        }
        .onAppear {
            Database.shared.fetchRecipeType(completion: { result in
                switch result {
                case .success(let types):
                    DispatchQueue.main.async {
                        recipeTypes = types
                        selectedRecipeType = recipeTypes.first
                    }
                case .failure(let failure):
                    print(failure)
                }
            })
        }
    }
}

struct TabButtonBar: View {
    let types: [RecipeType]
    @Binding var selectedType: RecipeType?
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(types) { type in
                    TabButton(type: type, isSelected: Binding(
                        get: { selectedType?.id == type.id },
                        set: { if $0 { selectedType = type } }
                    ))
                }
            }
            .padding(.horizontal)
        }
    }
}

struct TabButton: View {
    let type: RecipeType
    @Binding var isSelected: Bool
    
    var body: some View {
        Button(action: {
            withAnimation {
                isSelected = true
            }
        }) {
            Text(type.name)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(isSelected ? Color.accentColor : Color(UIColor.systemGray6))
                .foregroundColor(isSelected ? .white : .primary)
                .clipShape(Capsule())
        }
    }
}

#Preview {
    HomeView()
}
