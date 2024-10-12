//
//  RecipeDetailView.swift
//  recipe
//
//  Created by Wyatt Cheang on 12/10/2024.
//

import SwiftUI

struct RecipeDetailView: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.alert) var alert: AlertControl
    
    @Binding var recipe: Recipe
    @State private var servingMultiplier: Double = 1.0
    @State var isSheetPresented: Bool = false
    @State var isDeleteConfirmed: Bool = false
    
    var body: some View {
        ScrollView {
            VStack(alignment: .center, spacing: 24) {
                Text(recipe.title)
                    .font(.title)
                    .fontDesign(.serif)
                    .fontWeight(.bold)
                VStack {
                    if let data = recipe.image,
                       let image = UIImage(data: data) {
                        Image(uiImage: image)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .clipped()
                    }
                }
                .background(.accent)
                
                if !recipe.description.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        Text(recipe.description)
                    }
                }
                
                VStack(alignment: .center, spacing: 16) {
                    Text("Ingredients")
                        .font(.title2)
                        .fontWeight(.bold)
                    Incrementor(number: Int(servingMultiplier),
                                increment: { adjustServing(1) },
                                decrement: {adjustServing(-1) })
                    IngredientsList(servingMultiplier: servingMultiplier,
                                    ingredients: recipe.ingredients)
                }
                .padding()
                .padding(.vertical, 8)
                .background(Color(UIColor.secondarySystemBackground))
                .clipShape(.rect(cornerRadius: 16))
                
                VStack(alignment: .leading, spacing: 16) {
                    Text("Steps")
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    StepsList(steps: recipe.steps)
                }
                .padding(.horizontal)
            }
        }
        .frame(maxWidth: .infinity)
        .navigationTitle(recipe.type?.name ?? "")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            Menu {
                Button(action: {
                    isSheetPresented.toggle() // Action for editing
                }) {
                    Label("Edit", systemImage: "slider.horizontal.3")
                }
                Button(action: {
                    isDeleteConfirmed.toggle()
                }) {
                    Label("Delete", systemImage: "trash")
                        .foregroundColor(.red) // Optional: Change color to red for delete action
                }
            } label: {
                Label("Actions", systemImage: "ellipsis.circle")
            }
        }
        .sheet(isPresented: $isSheetPresented) {
            EditRecipeView(recipe: $recipe)
        }
        .confirmationDialog("Are you sure you want to delete this recipe?", isPresented: $isDeleteConfirmed, titleVisibility: .visible) {
            Button("Delete", role: .destructive) {
                deleteRecipe()
            }
            Button("Cancel", role: .cancel) {}
        }
    }
    
    private func adjustServing(_ change: Int) {
        let newMultiplier = servingMultiplier + (Double(change) * 0.5)
        servingMultiplier = max(0.5, newMultiplier)
    }
    
    private func deleteRecipe() {
        Task {
            do {
                let deleteSuccess = await Database.shared.deleteRecipe(recipe: recipe)
                if deleteSuccess {
                    dismiss()
                    alert.title = "Success"
                    alert.message = "Recipe deleted successfully."
                    alert.dismissMessage = "OK"
                }
                alert.isPresented.toggle()
            }
        }
    }
}

struct Incrementor: View {
    var number: Int
    var increment: () -> Void
    var decrement: () -> Void
    var min: Int = 1
    
    var body: some View {
        HStack {
            Button(action: decrement) {
                Image(systemName: "minus")
            }
            .buttonStyle(CircleStyle(.small))
            .disabled(number <= min)
            
            Text("\(number)")
                .font(.title3)
                .fontWeight(.semibold)
                .frame(minWidth: 40)
            
            Button(action: increment) {
                Image(systemName: "plus")
            }
            .buttonStyle(CircleStyle(.small))
        }
        .padding(8)
        .background(Color(UIColor.systemBackground))
        .cornerRadius(20)
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(Color.gray.opacity(0.3), lineWidth: 1)
        )
    }
}

struct IngredientsList: View {
    var servingMultiplier: Double
    var ingredients: [RecipeIngredient]
    
    var body: some View {
        VStack {
            ForEach(ingredients) { ingredient in
                HStack {
                    Text(ingredient.name)
                    Spacer()
                    Text("\((ingredient.quantity * servingMultiplier).toString) \(ingredient.unit)")
                }
                Divider()
            }
        }
    }
}

struct StepsList: View {
    let steps: [RecipeStep]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            ForEach(steps) { step in
                HStack(alignment: .top, spacing: 15) {
                    TextBullet("\(step.order)")
                    Text(step.description)
                        .fixedSize(horizontal: false, vertical: true)
                    
                    Spacer()
                }
            }
        }
    }
}

struct TextBullet: View {
    var text: String
    var color: Color
    
    init(_ text: String, color: Color = .accent) {
        self.text = text
        self.color = color
    }
    var body: some View {
        HStack {
            Text("\(text)")
                .font(.headline)
                .foregroundColor(.white)
        }
        .frame(width: 32, height: 32)
        .background(color)
        .clipShape(Circle())
    }
}

#Preview {
    TextBullet("1")
    TextBullet("10")
    TextBullet("100")
}

#Preview {
    NavigationView {
        RecipeDetailView(recipe: .constant(Recipe(
            id: UUID(),
            title: "Cabbage Salad",
            description: "A simple and refreshing cabbage salad.",
            serving: 2,
            type: RecipeType(id: 1, name: "Salad"),
            steps: [
                RecipeStep(id: UUID(), order: 1, description: "Place one cabbage leaf to the side and finely shred the remaining cabbage."),
                RecipeStep(id: UUID(), order: 2, description: "Put the cabbage in a bowl, add salt and mash the cabbage well with clean hands for a few minutes until juice begins to appear."),
                RecipeStep(id: UUID(), order: 3, description: "Grate the ginger and add it to the cabbage, mixing and mashing well."),
                RecipeStep(id: UUID(), order: 4, description: "Place the mashed cabbage along with the juice in a fermentation container (for example a large jar), cover the cabbage completely with the set aside cabbage leaf, and press tightly.")
            ],
            ingredients: [
                RecipeIngredient(id: UUID(), name: "Cabbage", quantity: 1, unit: "head"),
                RecipeIngredient(id: UUID(), name: "Salt", quantity: 1, unit: "tbsp"),
                RecipeIngredient(id: UUID(), name: "Ginger", quantity: 1, unit: "inch")
            ],
            imagePath: ""
        )))
    }
}
