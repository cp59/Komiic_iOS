//
//  CategoryView.swift
//  Komiic
//
//  Created by 梁承樸 on 2024/3/11.
//

import SwiftUI

struct CategoryView: View {
    var selectedCategory:KomiicAPI.ComicCategories
    var body: some View {
        ComicListView(title: selectedCategory.name, requestParameters: KomiicAPI.RequestParameters().getComicsByCategory(categoryId: selectedCategory.id))
    }
}

