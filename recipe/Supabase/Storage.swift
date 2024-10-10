//
//  storage.swift
//  recipe
//
//  Created by Wyatt Cheang on 10/10/2024.
//

import Foundation

class Recipe: Identifiable, Decodable {
    var id: UUID
    var title: String
    var description: String
    var servings: Int
    var category: RecipeType
    
    init(id: UUID, title: String, description: String, servings: Int, category: RecipeType) {
        self.id = id
        self.title = title
        self.description = description
        self.servings = servings
        self.category = category
    }
}

class RecipeType: Identifiable, Decodable {
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
}

class RecipeIngredient: Identifiable, Decodable {
    var id: UUID
    var name: String
    var quantity: String
    var unit: Float
    
    init(id: UUID, name: String, quantity: String, unit: Float) {
        self.id = id
        self.name = name
        self.quantity = quantity
        self.unit = unit
    }
}

class RecipeStep: Identifiable, Decodable {
    var id: UUID
    var number: String
    var description: String
    
    init(id: UUID, number: String, description: String) {
        self.id = id
        self.number = number
        self.description = description
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
}
