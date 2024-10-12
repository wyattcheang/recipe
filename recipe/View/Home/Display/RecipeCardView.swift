//
//  RecipeCardView.swift
//  recipe
//
//  Created by Wyatt Cheang on 12/10/2024.
//

import Foundation
import SwiftUI

struct RecipeCardView: View {
    @Binding var recipe: Recipe
    var reload: () -> Void
    
    var body: some View {
        NavigationLink(destination: RecipeDetailView(recipe: $recipe)) {
            VStack(alignment: .leading, spacing: 8) {
                ZStack {
                    if let data = recipe.image,
                       let image = UIImage(data: data) {
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFill()
                    } else {
                        Rectangle()
                            .fill(Color.gray.opacity(0.3))
                            .frame(height: 180)
                            .overlay {
                                ProgressView()
                            }
                    }
                }
                Text(recipe.title)
                    .lineLimit(1)
                    .padding(.horizontal, 16)
                    .padding(.bottom, 8)
            }
            .frame(maxWidth: .infinity)
            .clipShape(.rect(cornerRadius: 2, style: .continuous))
            .background(Color(UIColor.secondarySystemBackground))
            .cornerRadius(10)
        }
        .buttonStyle(PlainButtonStyle())
        .onAppear {
            Task {
                reload()
                try await recipe.fetchImageAsync()
            }
        }
        .onChange(of: recipe.image) { oldValue, newValue in
            Task {
                reload()
                try await recipe.fetchImageAsync()
            }
        }
    }
}
//
//#Preview {
//    RecipeCardView(recipe: .constant(.init(id: UUID(), title: "Grilled Chicken", description: "hi", serving: 1, type: RecipeType(id: 1, name: "Dinner"), steps: [], ingredients: [], imagePath: "")))
//}
