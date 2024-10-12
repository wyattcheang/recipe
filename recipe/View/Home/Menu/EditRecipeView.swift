//
//  EditRecipeView.swift
//  recipe
//
//  Created by Wyatt Cheang on 12/10/2024.
//

import SwiftUI

struct EditRecipeView: View {
    @Environment(\.dismiss) var dismiss
    
    @State private var alert = AlertControl()
    @Binding var recipe: Recipe
    var body: some View {
        RecipeMenuView(recipe: $recipe, alert: $alert, placeholder: "Update", action: editRecipe)
    }
    
    private func editRecipe() {
        Task {
            Database.shared.editRecipe(recipe) { result in
                switch result {
                case .success(_):
                    alert.title = "Success"
                    alert.message = "Recipe updated successfully"
                    alert.dismissMessage = "OK"
                    alert.isPresented.toggle()
                    print("called1")
                case .failure(let failure):
                    alert.title = "Failed"
                    alert.message = failure.localizedDescription
                    alert.dismissMessage = "OK"
                    alert.isPresented.toggle()
                    print("called2")
                }
            }
        }
    }
}
