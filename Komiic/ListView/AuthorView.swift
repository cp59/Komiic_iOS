//
//  AuthorView.swift
//  Komiic
//
//  Created by 梁承樸 on 2024/3/10.
//

import SwiftUI

struct AuthorView: View {
    var selectedAuthor: KomiicAPI.ComicAuthor
    var body: some View {
        ComicListView(title: selectedAuthor.name, requestParameters: KomiicAPI.RequestParameters().getComicsByAuthorId(authorId: selectedAuthor.id), listType: 1)
    }
}


