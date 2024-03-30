//
//  ComicFolderView.swift
//  Komiic
//
//  Created by 梁承樸 on 2024/3/19.
//

import SwiftUI

struct ComicFolderView: View {
    @EnvironmentObject var app: app
    @State private var comicFolders:[KomiicAPI.ComicFolder] = []
    @State private var isLoading = true
    var body: some View {
        NavigationView {
            VStack {
                if (isLoading) {
                    ProgressView()
                } else if (!app.isLogin) {
                    LoginView()
                } else {
                    ScrollView {
                        VStack {
                            Divider()
                            SmallComicListView(listType: 3, title: "喜愛書籍", requestParameters: "")
                            ForEach (comicFolders, id: \.id) { folder in
                                Divider()
                                SmallComicListView(folder: folder, listType: 4, title: folder.name, requestParameters: KomiicAPI.RequestParameters().getFolderComicIds(folderId: folder.id))
                            }
                        }.padding(10)
                        Spacer()
                    }.refreshable {
                        isLoading = true
                        comicFolders.removeAll()
                        app.komiicApi.fetchComicFolders(completion: {folders in
                            comicFolders.append(contentsOf: folders)
                            isLoading = false
                        })

                    }
                }
            }.navigationTitle("書櫃")
        }.navigationViewStyle(StackNavigationViewStyle()).onFirstAppear {
            app.komiicApi.fetchComicFolders(completion: {folders in
                comicFolders.append(contentsOf: folders)
                isLoading = false
            })
        }
    }
}

#Preview {
    ComicFolderView()
}
