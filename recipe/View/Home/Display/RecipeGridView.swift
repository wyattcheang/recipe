//
//  RecipeGridView.swift
//  recipe
//
//  Created by Wyatt Cheang on 12/10/2024.
//

import SwiftUI
import SwiftData

struct RecipeGridView: View {
    @Environment(\.modelContext) var modelContext
    @Query var recipes: [Recipe]
    
    init(type: RecipeType) {
        let id = type.id
        _recipes = Query(filter: #Predicate<Recipe> {
            if let type_id = $0.type?.id {
                return type_id == id
            } else {
                return false
            }
        })
    }
    
    let spacing: CGFloat = 6
    let minColumnWidth: CGFloat = 150
    
    var body: some View {
        GeometryReader { geometry in
            let columns = max(Int(geometry.size.width / (minColumnWidth + spacing)), 2)
            ScrollView {
                HStack(alignment: .top, spacing: spacing) {
                    ForEach(0..<columns, id: \.self) { columnIndex in
                        LazyVStack(spacing: spacing) {
                            ForEach(recipes.indices.filter { $0 % columns == columnIndex }, id: \.self) { index in
                                RecipeCardView(recipe: recipes[index])
                            }
                        }
                    }
                }
                .padding(.horizontal, spacing / 2)
            }
        }
    }
}

//#Preview {
//    RecipeGridView(type: RecipeType(id: 1, name: "Breakfast"))
//}
