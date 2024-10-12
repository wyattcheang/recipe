//
//  AddRecipeView.swift
//  recipe
//
//  Created by Wyatt Cheang on 11/10/2024.
//

import SwiftUI
import PhotosUI

struct AddRecipeView: View {
    @State private var alert = AlertControl()
    @Environment(\.dismiss) var dismiss
    
    let types: [RecipeType]
    @State private var recipe = Recipe()
    @State private var ingredient = RecipeIngredient()
    @State private var step = RecipeStep(order: 1)
    @State private var draggedStep: RecipeStep?

    var body: some View {
        ScrollView(.vertical) {
            VStack(spacing: 24) {
                VStack(alignment: .leading) {
                    headingText("Photo")
                    AddImageView(selectedImageData: $recipe.image)
                }
                .padding(.horizontal)
                
                VStack(alignment: .leading) {
                    headingText("Food Name")
                    TextField("Title", text: $recipe.title)
                        .textFieldStyle(RectStyle())
                }
                .padding(.horizontal)
                
                VStack(alignment: .leading) {
                    headingText("Category")
                        .padding(.horizontal)
                    TabButtonBar(types: types, selectedType: $recipe.type)
                }
                
                VStack(alignment: .leading) {
                    headingText("Ingredients")
                    ForEach(Array(recipe.ingredients.enumerated()), id: \.element.id) { index, ingredient in
                        ItemLabel(text: ingredient.text,
                                  delete: { deleteIngredient(at: index) },
                                  tapped: { modifyIngredient(at: index) })
                    }
                    AddIngredientView(ingredient: $ingredient, addIngredient: addIngredient)
                }
                .padding(.horizontal)
                
                VStack(alignment: .leading) {
                    headingText("Steps")
                    ForEach(Array(recipe.steps.enumerated()), id: \.element.id) { index, step in
                        ItemLabel(text: "\(step.order). \(step.description)",
                                  delete: { deleteStep(at: index) },
                                  tapped: { modifyStep(at: index) })
                        .onDrag {
                            self.draggedStep = step
                            return NSItemProvider(object: String(step.id.uuidString) as NSString)
                        }
                        .onDrop(of: [UTType.text], delegate: StepDropDelegate(item: step, items: $recipe.steps, draggedItem: $draggedStep))
                    }
                    AddStepView(step: $step, addStep: addStep)
                }
                .padding(.horizontal)
                
                VStack(alignment: .leading) {
                    headingText("Notes")
                    HStack {
                        TextField("Tips for the recipe...", text: $recipe.description, axis: .vertical)
                            .padding()
                    }
                    .frame(minHeight: 100, alignment: .topLeading)
                    .background(Color(UIColor.secondarySystemBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                }
                .frame(minHeight: 120)
                .padding(.horizontal)
                
                VStack(alignment: .leading) {
                    headingText("Serving")
                    RectFrame {
                        HStack {
                            Slider(value: Binding(get: { Double(recipe.serving) },
                                                  set: { recipe.serving = Int($0) }),
                                   in: 1...50,
                                   step: 1)
                            .accentColor(.accent)
                            Text("\(recipe.serving)")
                                .frame(width: 40)
                        }
                        .padding()
                    }
                }
                .padding(.horizontal)
                VStack {
                    Button("Add recipe", action: addRecipe)
                        .buttonStyle(AccentButtonStyle())
                        .disabled(!recipe.isValid)
                }
                .padding(.horizontal)
            }
            .frame(maxHeight: .infinity)
        }
        .padding(.vertical, 24)
        .alert(isPresented: $alert.isPresented) {
            Alert(
                title: Text(alert.title),
                message: Text(alert.message),
                dismissButton: .default(Text(alert.dismissMessage)) {
                    dismiss()
                }
            )
        }
        .onChange(of: recipe.steps) {
            updateStepOrders()
        }
    }
    
    private func headingText(_ text: String) -> some View {
        Text(text)
            .font(.headline)
    }
    
    private func listItemText(_ text: String) -> some View {
        Text(text)
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(Color(UIColor.secondarySystemBackground))
            .clipShape(.rect(cornerRadius: 16, style: .continuous))
            .padding(.horizontal)
    }
    
    private func addIngredient() {
        recipe.ingredients.append(ingredient)
        ingredient = RecipeIngredient()
    }
    
    private func deleteIngredient(at index: Int) {
        recipe.ingredients.remove(at: index)
    }
    
    private func modifyIngredient(at index: Int) {
        ingredient = recipe.ingredients[index]
        recipe.ingredients.remove(at: index)
    }
    
    private func addStep() {
        recipe.steps.append(step)
        let nextStep = recipe.steps.count + 1
        step = RecipeStep(order: nextStep)
    }
    
    private func deleteStep(at index: Int) {
        recipe.steps.remove(at: index)
        updateStepOrders()
    }
    
    private func modifyStep(at index: Int) {
        step = recipe.steps[index]
        recipe.steps.remove(at: index)
    }
    
    private func moveStep(from source: IndexSet, to destination: Int) {
        recipe.steps.move(fromOffsets: source, toOffset: destination)
        updateStepOrders()
    }
    
    private func updateStepOrders() {
        for (index, step) in recipe.steps.enumerated() {
            step.order = index + 1
        }
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


struct StepDropDelegate: DropDelegate {
    let item: RecipeStep
    @Binding var items: [RecipeStep]
    @Binding var draggedItem: RecipeStep?

    func performDrop(info: DropInfo) -> Bool {
        return true
    }

    func dropEntered(info: DropInfo) {
        guard let draggedItem = draggedItem else { return }
        
        if draggedItem != item {
            let from = items.firstIndex(of: draggedItem)!
            let to = items.firstIndex(of: item)!
            if items[to] != draggedItem {
                items.move(fromOffsets: IndexSet(integer: from),
                           toOffset: to > from ? to + 1 : to)
            }
        }
    }

    func dropUpdated(info: DropInfo) -> DropProposal? {
        return DropProposal(operation: .move)
    }
}

struct ItemLabel: View {
    var text: String
    var delete: () -> Void
    var tapped: () -> Void
    
    var body: some View {
        HStack {
            Text(text)
                .font(.headline)
            Button("delete", systemImage: "minus", action: delete)
                .buttonStyle(CircleStyle(.small, color: Color(UIColor.systemGray4)))
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .background(Color(UIColor.secondarySystemBackground))
        .clipShape(.rect(cornerRadius: 16, style: .continuous))
        .onTapGesture(perform: tapped)
    }
}

struct AddImageView: View {
    @State private var selectedItem: PhotosPickerItem?
    @Binding var selectedImageData: Data?
    
    var body: some View {
        PhotosPicker(selection: $selectedItem, matching: .images) {
            if let selectedImageData,
               let uiImage = UIImage(data: selectedImageData) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFill()
                    .frame(height: 200)
                    .clipShape(.rect(cornerRadius: 16, style: .continuous))
            } else {
                RectFrame {
                    VStack(spacing: 16) {
                        Image(systemName: "photo.badge.plus")
                            .font(.largeTitle)
                            .foregroundStyle(.primary)
                        Text("Upload a photo of your recipe")
                    }
                    .frame(maxWidth: .infinity, minHeight: 200)
                }
            }
        }
        .onChange(of: selectedItem) { oldValue, newValue in
            Task {
                if let data = try? await newValue?.loadTransferable(type: Data.self) {
                    selectedImageData = data
                }
            }
        }
    }
}

struct AddIngredientView: View {
    @Binding var ingredient: RecipeIngredient
    var addIngredient: () -> Void
    let units = ["gram", "ml", "teaspoon", "tablespoon", "cup", "oz", "lb", "pinch", "cloves", "pieces", "cans", "slices"]
    
    var body: some View {
        VStack {
            VStack(alignment: .leading) {
                VStack {
                    HStack {
                        TextField("Title", text: $ingredient.name)
                        Button("Add Recipe Step", systemImage: "plus", action: addIngredient)
                            .buttonStyle(CircleStyle(.small))
                            .disabled(!ingredient.isValid)
                    }
                    HStack {
                        TextField("Quantity", value: $ingredient.quantity, formatter: NumberFormatter())
                            .keyboardType(.decimalPad)
                        Picker("", selection: $ingredient.unit) {
                            ForEach(units, id: \.self) { unit in
                                Text(unit).tag(unit)
                            }
                        }
                    }
                }
                .padding()
                .background(Color(UIColor.secondarySystemBackground))
                .frame(width: .infinity)
                .clipShape(.rect(cornerRadius: 16))
            }
        }
        .background(Color(UIColor.systemBackground))
    }
}

struct AddStepView: View {
    @Binding var step: RecipeStep
    var addStep: () -> Void
    
    var body: some View {
        VStack {
            HStack {
                TextField("Step", text: $step.description, axis: .vertical)
                Button("Add Recipe Step", systemImage: "plus", action: addStep)
                    .buttonStyle(CircleStyle(.small))
                    .disabled(!step.isValid)
            }
        }
        .padding()
        .background(Color(UIColor.secondarySystemBackground))
        .frame(width: .infinity)
        .clipShape(.rect(cornerRadius: 16))
    }
}

#Preview {
    AddRecipeView(types: [RecipeType(id: 1, name: "Salad"), RecipeType(id: 2, name: "Breakfast")])
}
