//
//  AddRecipeView.swift
//  recipe
//
//  Created by Wyatt Cheang on 11/10/2024.
//

import SwiftUI
import PhotosUI

struct AddRecipeView: View {
    @Environment(\.modelContext) var modelContext
    @Environment(\.dismiss) var dismiss
    
    var type: RecipeType
    @State private var alert = AlertControl()
    @State private var recipe = Recipe()
    
    var body: some View {
        RecipeMenuView(recipe: recipe, alert: $alert, placeholder: "Add", action: addRecipe)
            .onAppear {
                recipe.type = type
            }
    }
    
    private func addRecipe() {
        let recipe = recipe
        modelContext.insert(recipe)
        
        alert.title = "Success"
        alert.message = "Recipe added successfully"
        alert.dismissMessage = "OK"
        alert.isPresented.toggle()
    }
}
