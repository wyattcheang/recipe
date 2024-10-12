//
//  storage.swift
//  recipe
//
//  Created by Wyatt Cheang on 10/10/2024.
//

import Foundation
import UIKit

protocol ImageLoadable: AnyObject {
    var image: Data? { get set }
    var imagePath: String { get }
}

extension ImageLoadable {
    func fetchImageAsync() async {
        await withCheckedContinuation { continuation in
            Storage.shared.fetchImage(bucket: "image", path: imagePath) { result in
                switch result {
                case .success(let data):
                    self.image = data
                case .failure(let error):
                    print("Failed to fetch image: \(error)")
                }
                continuation.resume()
            }
        }
    }
}

@Observable
class Recipe: Identifiable, Codable, Hashable, ImageLoadable {
    var id: UUID
    var title: String
    var description: String
    var serving: Int
    var type: RecipeType?
    var steps: [RecipeStep]
    var ingredients: [RecipeIngredient]
    var imagePath: String
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
    
    init(id: UUID, title: String, description: String, serving: Int, type: RecipeType, steps: [RecipeStep], ingredients: [RecipeIngredient], imagePath: String) {
        self.id = id
        self.title = title
        self.description = description
        self.serving = serving
        self.type = type
        self.steps = steps
        self.ingredients = ingredients
        self.imagePath = imagePath
    }
    
    init() {
        self.id = UUID()
        self.title = ""
        self.description = ""
        self.serving = 1
        self.type = nil
        self.steps = []
        self.ingredients = []
        self.imagePath = ""
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
        case description
        case serving
        case type
        case typeId = "type_id"
        case steps = "step"
        case ingredients = "ingredient"
        case imagePath = "image_path"
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(UUID.self, forKey: .id)
        self.title = try container.decode(String.self, forKey: .title)
        self.description = try container.decode(String.self, forKey: .description)
        self.serving = try container.decode(Int.self, forKey: .serving)
        self.type = try container.decodeIfPresent(RecipeType.self, forKey: .type)
        self.steps = try container.decode([RecipeStep].self, forKey: .steps)
        self.ingredients = try container.decode([RecipeIngredient].self, forKey: .ingredients)
        self.imagePath = try container.decode(String.self, forKey: .imagePath)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(title, forKey: .title)
        try container.encode(description, forKey: .description)
        try container.encode(serving, forKey: .serving)
        try container.encode(typeId, forKey: .typeId)
        try container.encode(imagePath, forKey: .imagePath)
    }

    func assignRecipeId() {
        ingredients.forEach { $0.recipeId = self.id }
        steps.forEach { $0.recipeId = self.id }
    }
}

@Observable
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

@Observable
class RecipeIngredient: Identifiable, Codable, Hashable {
    var id: UUID
    var name: String
    var quantity: Double
    var unit: String
    
    var recipeId: UUID?
    
    var text: String {
        return ("\(self.name) \(self.quantity) \(self.unit)")
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

@Observable
class RecipeStep: Identifiable, Codable, Hashable {
    var id: UUID
    var order: Int
    var description: String
    
    var recipeId: UUID?

    var isValid: Bool {
        return order > 0 && !description.isEmpty
    }
    
    init(id: UUID, order: Int, description: String) {
        self.id = id
        self.order = order
        self.description = description
    }
    
    init(order: Int) {
        self.id = UUID()
        self.order = order
        self.description = ""
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
        case description
        case recipeId = "recipe_id"
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(UUID.self, forKey: .id)
        self.order = try container.decode(Int.self, forKey: .order)
        self.description = try container.decode(String.self, forKey: .description)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(order, forKey: .order)
        try container.encode(description, forKey: .description)
        try container.encode(recipeId, forKey: .recipeId)
    }
}

class Database {
    static let shared = Database()
    
    func fetchRecipeType(completion: @escaping (Result<[RecipeType], Error>) -> Void) {
        Task {
            do {
                let types: [RecipeType] = try await supabase
                    .from("type")
                    .select()
                    .execute()
                    .value
                completion(.success(types))
            } catch {
                completion(.failure(error))
            }
        }
        
    }
    
    func addRecipe(_ recipe: Recipe, completion: @escaping (Result<Void, Error>) -> Void) {
        Task {
            do {
                recipe.assignRecipeId()
                try await supabase
                    .from("recipe")
                    .insert(recipe)
                    .execute()
                try await addRecipeIngredients(recipe.ingredients)
                try await addRecipeSteps(recipe.steps)
                if recipe.image != nil {
                    Storage.shared.uploadImage(bucket: "image",
                                               path: recipe.imagePath,
                                               data: recipe.image!) { result in
                        switch result {
                        case .success():
                            completion(.success(()))
                        case .failure(let error):
                            completion(.failure(error))
                        }
                    }
                }
                completion(.success(()))
            } catch {
                completion(.failure(error))
            }
        }
    }
    
    func addRecipeIngredients(_ ingredients: [RecipeIngredient]) async throws {
        try await supabase
            .from("ingredient")
            .insert(ingredients)
            .execute()
    }
    
    func addRecipeSteps(_ steps: [RecipeStep]) async throws {
        try await supabase
            .from("step")
            .insert(steps)
            .execute()
    }
    
    func fetchRecipes(_ type: RecipeType, completion: @escaping (Result<[Recipe], Error>) -> Void) {
        Task {
            do {
                let recipes: [Recipe] = try await supabase
                    .rpc("get_recipes")
                    .eq("type_id", value: type.id)
                    .select("""
                    id,
                    type_id,
                    serving,
                    description,
                    title,
                    image_path,
                    step:step(id, order, description),
                    ingredient:ingredient(id, name, quantity, unit)
                    """)
                    .execute()
                    .value

                completion(.success(recipes))
            } catch {
                completion(.failure(error))
            }
        }
    }
}
