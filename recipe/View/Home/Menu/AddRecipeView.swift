//
//  AddRecipeView.swift
//  recipe
//
//  Created by Wyatt Cheang on 11/10/2024.
//

import SwiftUI
import PhotosUI

struct AddRecipeView: View {
    @Environment(\.dismiss) var dismiss
    @State private var alert = AlertControl()
    @State var recipe = Recipe()
    
    var body: some View {
        RecipeMenuView(recipe: $recipe, alert: $alert, placeholder: "Add", action: addRecipe)
    }
    
    private func addRecipe() {
        if let file = recipe.image,
           let _ = UIImage(data: file) {
            self.recipe.imagePath = "\(recipe.id.uuidString)"
        }
        Task {
            Database.shared.addRecipe(recipe) { result in
                switch result {
                case .success(_):
                    alert.title = "Success"
                    alert.message = "Recipe added successfully"
                    alert.dismissMessage = "OK"
                    alert.isPresented.toggle()
                case .failure(let failure):
                    alert.title = "Failed"
                    alert.message = failure.localizedDescription
                    alert.dismissMessage = "OK"
                    alert.isPresented.toggle()
                }
            }
        }
    }
}
