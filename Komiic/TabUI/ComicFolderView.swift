//
//  ComicFolderView.swift
//  Komiic
//
//  Created by 梁承樸 on 2024/3/19.
//

import SwiftUI

struct ComicFolderView: View {
    @EnvironmentObject var app:AppEnvironment
    @State private var comicFolders:[KomiicAPI.ComicFolder] = []
    @State private var isLoading = true
    var body: some View {
        NavigationView {
            VStack {
                if (!app.isLogin) {
                    LoginView()
                } else if (isLoading) {
                    ProgressView().onFirstAppear {
                        app.komiicApi.fetchComicFolders(completion: {folders in
                            comicFolders.append(contentsOf: folders)
                            isLoading = false
                        })
                    }
                } else {
                    ScrollView {
                        VStack {
                            Divider()
                            SmallComicListView(listType: 3, title: "喜愛書籍", requestParameters: "")
                            ForEach (comicFolders, id: \.id) { folder in
                                Divider()
                                SmallComicListView(folder: folder, listType: 4, title: folder.name, requestParameters: KomiicAPI.RequestParameters().getFolderComicIds(folderId: folder.id))
                            }
                        }.padding(EdgeInsets(top: 5, leading: 20, bottom: 20, trailing: 10))
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
        }.navigationViewStyle(StackNavigationViewStyle())
    }
}

#Preview {
    ComicFolderView()
}
