//
//  FolderComicView.swift
//  Komiic
//
//  Created by 梁承樸 on 2024/3/20.
//

import SwiftUI

struct FolderComicView: View {
    let folder: KomiicAPI.ComicFolder
    @State private var refreshList = 0
    var body: some View {
        ComicListView(title: folder.name, requestParameters: KomiicAPI.RequestParameters().getFolderComicIds(folderId: folder.id), listType: 4, refreshList: $refreshList)
    }
}
