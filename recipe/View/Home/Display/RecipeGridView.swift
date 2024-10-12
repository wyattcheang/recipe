//
//  RecipeGridView.swift
//  recipe
//
//  Created by Wyatt Cheang on 12/10/2024.
//

import SwiftUI


struct RecipeGridView: View {
    @Binding var recipes: [Recipe]
    var fetchData: () -> Void
    
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
                                RecipeCardView(recipe: $recipes[index], reload: fetchData)
                            }
                        }
                    }
                }
                .padding(.horizontal, spacing / 2)
            }
            .refreshable {
                Task {
                    fetchData()
                }
            }
        }
    }
}

#Preview {
    RecipeGridView(recipes: .constant([]), fetchData: {})
}
