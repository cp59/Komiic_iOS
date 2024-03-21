//
//  ComicFolderView.swift
//  Komiic
//
//  Created by 梁承樸 on 2024/3/19.
//

import SwiftUI

struct ComicFolderView: View {
    @State private var comicFolders:[KomiicAPI.ComicFolder] = []
    @State private var isLoading = true
    @State private var isInit = false
    var body: some View {
        NavigationView {
            VStack {
                if (isLoading) {
                    ProgressView().scaleEffect(2)
                } else {
                    ScrollView {
                        Spacer().frame(height: 20)
                        SmallComicListView(listType: 3, title: "喜愛書籍", requestParameters: "")
                        ForEach (comicFolders, id: \.id) { folder in
                            SmallComicListView(folder: folder, listType: 4, title: folder.name, requestParameters: KomiicAPI.RequestParameters().getFolderComicIds(folderId: folder.id))
                        }
                        Spacer()
                    }
                }
            }.navigationTitle("書櫃").refreshable {
                isLoading = true
                comicFolders.removeAll()
                KomiicAPI().fetchComicFolders(completion: {folders in
                    comicFolders.append(contentsOf: folders)
                    isLoading = false
                    isInit = true
                })

            }
        }.navigationViewStyle(StackNavigationViewStyle()).onAppear {
            if (!isInit) {
                KomiicAPI().fetchComicFolders(completion: {folders in
                    comicFolders.append(contentsOf: folders)
                    isLoading = false
                    isInit = true
                })
            }
        }
    }
}

#Preview {
    ComicFolderView()
}
