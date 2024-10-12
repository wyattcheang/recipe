//
//  HomeView.swift
//  recipe
//
//  Created by Wyatt Cheang on 10/10/2024.
//

import SwiftUI

struct HomeView: View {
    @Environment(\.user) var user: UserModel

    @State private var recipes: [Recipe] = []
    @State private var recipeTypes: [RecipeType] = []
    @State private var selectedRecipeType: RecipeType?
    
    @State var isSheetPresented: Bool = false
    @State var isRecipeModified: Bool = false
    
    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 8) {
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
                .padding(.horizontal)
                if !recipeTypes.isEmpty {
                    TabButtonBar(types: recipeTypes, selectedType: $selectedRecipeType)
                }
                RecipeGridView(recipes: $recipes, fetchData: fetchAllRecipes)
                    .overlay(alignment: .bottomTrailing) {
                        Button("Add Recipe", systemImage: "plus") {
                            isSheetPresented.toggle()
                        }
                        .buttonStyle(CircleStyle())
                        .padding()
                    }
            }
            .onAppear {
                fetchRecipeType()
            }
            .onChange(of: selectedRecipeType) { oldValue, newValue in
                if newValue != nil {
                    fetchAllRecipes()
                }
            }
            .sheet(isPresented: $isSheetPresented, onDismiss: fetchAllRecipes) {
                AddRecipeView()
            }
        }
    }
    
    func fetchRecipeType() {
        Database.shared.fetchRecipeType(completion: { result in
            switch result {
            case .success(let types):
                DispatchQueue.main.async {
                    recipeTypes = types
                    if selectedRecipeType == nil {
                        selectedRecipeType = recipeTypes.first
                    }
                }
            case .failure(let failure):
                print(failure)
            }
        })
    }
    
    func fetchAllRecipes() {
        print("fetching")
        if let type = selectedRecipeType {
            Database.shared.fetchRecipes(type) { result in
                switch result {
                case .success(let data):
                    recipes = data
                    print("fetched")
                case .failure(let failure):
                    print(failure)
                }
            }
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
                        get: { selectedType == type },
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
        Button(type.name) {
            withAnimation {
                isSelected = true
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .background(isSelected ? Color.accentColor : Color(UIColor.secondarySystemBackground))
        .foregroundColor(isSelected ? .white : .primary)
        .clipShape(.capsule)
    }
}

#Preview {
    HomeView()
}
