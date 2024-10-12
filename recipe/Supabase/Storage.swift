//
//  Storage.swift
//  recipe
//
//  Created by Wyatt Cheang on 12/10/2024.
//

import Foundation
import UIKit

struct Storage {
    static let shared = Storage()
    
    func deleteImage(bucket: String, path: String, completion: @escaping (Result<Void, Error>) -> Void) {
        Task {
            do {
                let _ = try await supabase.storage
                    .from(bucket)
                    .remove(paths: [path])
                completion(.success(()))
            }
            catch {
                print(error)
            }
        }
    }
    
    func fetchImage(bucket: String, path: String, completion: @escaping (Result<Data, Error>) -> Void) {
        Task {
            do {
                let data = try await supabase.storage
                    .from(bucket)
                    .download(path: path)
                if UIImage(data: data) != nil {
                    completion(.success(data))
                } else {
                    completion(.failure(NSError(domain: "", code: -1,
                                                userInfo: [NSLocalizedDescriptionKey: "Failed to convert data to UIImage"])))
                }
            }
            catch {
                print(error)
                completion(.failure(error))
            }
        }
    }
    
    func uploadImage(bucket: String, path: String, data: Data, completion: @escaping (Result<Void, Error>) -> Void) {
        Task {
            do {
                try await supabase.storage
                    .from(bucket)
                    .upload(path, data: data)
            } catch {
                print(error)
                completion(.failure(error))
            }
        }
    }
}
