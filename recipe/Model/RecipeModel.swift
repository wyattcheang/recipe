//
//  RecipeModel.swift
//  recipe
//
//  Created by Wyatt Cheang on 16/10/2024.
//

import Foundation
import SwiftData
import UIKit

@Model
class Recipe: Identifiable, Codable, Hashable {
    var id: UUID
    var title: String
    var note: String
    var serving: Int
    var type: RecipeType?
    @Relationship(deleteRule: .cascade) var steps: [RecipeStep]
    @Relationship(deleteRule: .cascade) var ingredients: [RecipeIngredient]
    var image: Data?
    
    var isValid: Bool {
        guard !title.isEmpty,
              serving > 0,
              type != nil,
              !steps.isEmpty,
              !ingredients.isEmpty else {
            return false
        }
        return steps.allSatisfy { $0.isValid } && ingredients.allSatisfy { $0.isValid }
    }
    
    private var typeId: Int {
        return type?.id ?? 0
    }
    
    init(title: String, note: String, serving: Int, type: RecipeType, steps: [RecipeStep], ingredients: [RecipeIngredient], image: Data) {
        self.id = UUID()
        self.title = title
        self.note = note
        self.serving = serving
        self.type = type
        self.steps = steps
        self.ingredients = ingredients
        self.image = image
    }
    
    init() {
        self.id = UUID()
        self.title = ""
        self.note = ""
        self.serving = 1
        self.type = nil
        self.steps = []
        self.ingredients = []
    }
    
    init(type: RecipeType) {
        self.id = UUID()
        self.title = ""
        self.note = ""
        self.serving = 1
        self.type = nil
        self.steps = []
        self.ingredients = []
        self.type = type
    }
    
    // Hashable
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    // Equatable
    static func == (lhs: Recipe, rhs: Recipe) -> Bool {
        lhs.id == rhs.id
    }
    
    // Codable
    private enum CodingKeys: String, CodingKey {
        case id
        case title
        case note
        case serving
        case type
        case typeId = "type_id"
        case steps = "step"
        case ingredients = "ingredient"
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(UUID.self, forKey: .id)
        self.title = try container.decode(String.self, forKey: .title)
        self.note = try container.decode(String.self, forKey: .note)
        self.serving = try container.decode(Int.self, forKey: .serving)
        self.type = try container.decodeIfPresent(RecipeType.self, forKey: .type)
        self.steps = try container.decode([RecipeStep].self, forKey: .steps)
        self.ingredients = try container.decode([RecipeIngredient].self, forKey: .ingredients)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(title, forKey: .title)
        try container.encode(note, forKey: .note)
        try container.encode(serving, forKey: .serving)
        try container.encode(typeId, forKey: .typeId)
    }
    
    func clone() -> Recipe {
        return Recipe(
            title: title,
            note: note,
            serving: serving,
            type: type!,
            steps: steps,
            ingredients: ingredients,
            image: image!
        )
    }
    
    func update(recipe: Recipe) {
        self.title = recipe.title
        self.note = recipe.note
        self.serving = recipe.serving
        self.type = recipe.type
        self.steps = recipe.steps
        self.ingredients = recipe.ingredients
        if let image = recipe.image {
            self.image = image
        }
    }
    
    func assignRecipeId() {
        ingredients.forEach { $0.recipeId = self.id }
        steps.forEach { $0.recipeId = self.id }
    }
    
}

@Model
class RecipeType: Identifiable, Decodable, Hashable {
    var id: Int
    var name: String
    
    init(id: Int, name: String) {
        self.id = id
        self.name = name
    }
    
    private enum CodingKeys: String, CodingKey {
        case id
        case name
    }
    
    // Conform Hashable
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    // Implement Equatable (required for Hashable)
    static func == (lhs: RecipeType, rhs: RecipeType) -> Bool {
        return lhs.id == rhs.id
    }
    
    // Conform Decodable
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(Int.self, forKey: .id)
        self.name = try container.decode(String.self, forKey: .name)
    }
}

@Model
class RecipeIngredient: Identifiable, Codable, Hashable {
    var id: UUID
    var name: String
    var quantity: Double
    var unit: String
    
    var recipeId: UUID?
    
    var text: String {
        return ("\(self.name) \(self.quantity.toString) \(self.unit)")
    }
    
    var isValid: Bool {
        return !name.isEmpty && quantity > 0 && !unit.isEmpty
    }
    
    init(id: UUID, name: String, quantity: Double, unit: String) {
        self.id = id
        self.name = name
        self.quantity = quantity
        self.unit = unit
    }
    
    init() {
        self.id = UUID()
        self.name = ""
        self.quantity = 1
        self.unit = "gram"
    }
    
    // Conform Hashable
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    // Implement Equatable (required for Hashable)
    static func == (lhs: RecipeIngredient, rhs: RecipeIngredient) -> Bool {
        return lhs.id == rhs.id
    }
    
    // Conform Codable
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case quantity
        case unit
        case recipeId = "recipe_id"
    }
    
    // Decoding initializer
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(UUID.self, forKey: .id)
        self.name = try container.decode(String.self, forKey: .name)
        self.quantity = try container.decode(Double.self, forKey: .quantity)
        self.unit = try container.decode(String.self, forKey: .unit)
        //        self.recipeId = try container.decode(UUID.self, forKey: .recipeId)
    }
    
    // Encoding method
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(name, forKey: .name)
        try container.encode(quantity, forKey: .quantity)
        try container.encode(unit, forKey: .unit)
        try container.encode(recipeId, forKey: .recipeId)
    }
}

@Model
class RecipeStep: Identifiable, Codable, Hashable {
    var id: UUID
    var order: Int
    var note: String
    
    var recipeId: UUID?
    
    var isValid: Bool {
        return order > 0 && !note.isEmpty
    }
    
    init(id: UUID, order: Int, note: String) {
        self.id = id
        self.order = order
        self.note = note
    }
    
    init(order: Int) {
        self.id = UUID()
        self.order = order
        self.note = ""
    }
    
    // Conform Hashable
    static func == (lhs: RecipeStep, rhs: RecipeStep) -> Bool {
        ObjectIdentifier(lhs) == ObjectIdentifier(rhs)
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(ObjectIdentifier(self))
    }
    
    // Conform Codable
    private enum CodingKeys: String, CodingKey {
        case id
        case order
        case note
        case recipeId = "recipe_id"
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(UUID.self, forKey: .id)
        self.order = try container.decode(Int.self, forKey: .order)
        self.note = try container.decode(String.self, forKey: .note)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(order, forKey: .order)
        try container.encode(note, forKey: .note)
        try container.encode(recipeId, forKey: .recipeId)
    }
}
