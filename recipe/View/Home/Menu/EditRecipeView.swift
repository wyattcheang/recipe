//
//  EditRecipeView.swift
//  recipe
//
//  Created by Wyatt Cheang on 12/10/2024.
//

import SwiftUI

struct EditRecipeView: View {
    @Bindable var recipe: Recipe
    
    @Environment(\.modelContext) var modelContext
    @Environment(\.dismiss) var dismiss
    @State private var alert = AlertControl()
    @State private var tempRecipe = Recipe()
    
    var body: some View {
        RecipeMenuView(recipe: tempRecipe, alert: $alert, placeholder: "Update", action: editRecipe)
        .onAppear {
            tempRecipe = recipe.clone()
        }
    }
    
    private func editRecipe() {
        recipe.update(recipe: tempRecipe)
        alert.title = "Success"
        alert.message = "Recipe updated successfully"
        alert.dismissMessage = "OK"
        alert.isPresented.toggle()
    }
}
