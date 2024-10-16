////
////  storage.swift
////  recipe
////
////  Created by Wyatt Cheang on 10/10/2024.
////
//
//import SwiftData
//import Foundation
//import UIKit
//
//protocol ImageLoadable: AnyObject {
//    var image: Data? { get set }
//    var imagePath: String { get }
//}
//
//extension ImageLoadable {
//    func fetchImageAsync() async throws {
//        if imagePath.isEmpty { return }
//        try await withCheckedThrowingContinuation { continuation in
//            Storage.shared.fetchImage(bucket: "image", path: imagePath) { result in
//                switch result {
//                case .success(let data):
//                    self.image = data
//                    continuation.resume(returning: ())
//                case .failure(let error):
//                    print("Failed to fetch image: \(error)")
//                    continuation.resume(throwing: error) // Resume with an error if fetching fails
//                }
//            }
//        }
//    }
//}
//

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

//
//    func editRecipe(_ recipe: Recipe, completion: @escaping (Result<Void, Error>) -> Void) {
//        Task {
//            do {
//                let deleteSuccess = await deleteRecipe(recipe: recipe)
//
//                if deleteSuccess {
//                    // After deletion, add the recipe back
//                    addRecipe(recipe) { result in
//                        switch result {
//                        case .success:
//                            completion(.success(()))
//                        case .failure(let failure):
//                            completion(.failure(failure))
//                        }
//                    }
//                }
//            }
//        }
//    }
//
//    func deleteRecipe(recipe: Recipe) async -> Bool {
//        do {
//            // Generate the image path
//            recipe.generateImagePath()
//            
//            // Delete recipe from the database
//            try await supabase
//                .from("recipe")
//                .delete()
//                .eq("id", value: recipe.id)
//                .execute()
//            
//            // Delete the image asynchronously
//            let imageDeleteSuccess = await withCheckedContinuation { continuation in
//                Storage.shared.deleteImage(bucket: "image", path: recipe.imagePath) { result in
//                    switch result {
//                    case .success:
//                        continuation.resume(returning: true)
//                    case .failure:
//                        continuation.resume(returning: false)
//                    }
//                }
//            }
//            
//            return imageDeleteSuccess
//        } catch {
//            return false
//        }
//    }
//    
//    func addRecipe(_ recipe: Recipe, completion: @escaping (Result<Void, Error>) -> Void) {
//        Task {
//            do {
//                recipe.generateImagePath()
//                recipe.assignRecipeId()
//                try await supabase
//                    .from("recipe")
//                    .insert(recipe)
//                    .execute()
//                try await addRecipeIngredients(recipe.ingredients)
//                try await addRecipeSteps(recipe.steps)
//                if recipe.image != nil {
//                    Storage.shared.uploadImage(bucket: "image",
//                                               path: recipe.imagePath,
//                                               data: recipe.image!) { result in
//                        switch result {
//                        case .success():
//                            completion(.success(()))
//                        case .failure(let error):
//                            completion(.failure(error))
//                        }
//                    }
//                }
//                completion(.success(()))
//            } catch {
//                completion(.failure(error))
//            }
//        }
//    }
//    
//    func addRecipeIngredients(_ ingredients: [RecipeIngredient]) async throws {
//        try await supabase
//            .from("ingredient")
//            .insert(ingredients)
//            .execute()
//    }
//    
//    func addRecipeSteps(_ steps: [RecipeStep]) async throws {
//        try await supabase
//            .from("step")
//            .insert(steps)
//            .execute()
//    }
//    
//    func fetchRecipes(_ type: RecipeType, completion: @escaping (Result<[Recipe], Error>) -> Void) {
//        Task {
//            do {
//                let recipes: [Recipe] = try await supabase
//                    .rpc("get_recipes")
//                    .eq("type_id", value: type.id)
//                    .select("""
//                    id,
//                    type_id,
//                    type:type(id, name),
//                    serving,
//                    note,
//                    title,
//                    image_path,
//                    step:step(id, order, note),
//                    ingredient:ingredient(id, name, quantity, unit)
//                    """)
//                    .execute()
//                    .value
//                completion(.success(recipes))
//            } catch {
//                completion(.failure(error))
//            }
//        }
//    }
//}
