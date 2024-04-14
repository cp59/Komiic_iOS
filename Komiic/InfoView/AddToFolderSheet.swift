//
//  AddToFolderSheet.swift
//  Komiic
//
//  Created by 梁承樸 on 2024/3/21.
//

import SwiftUI

struct AddToFolderSheet: View {
    @State private var accountFolders:[KomiicAPI.ComicFolder] = []
    @State private var comicInFolders:[String] = []
    @State private var isLoading = true
    @State private var comicInFavoriteList = false
    @Binding var isPresented:Bool
    @EnvironmentObject var app:AppEnvironment
    var comicId:String
    var body: some View {
        NavigationView {
            VStack {
                if (isLoading) {
                    Spacer()
                    ProgressView()
                    Spacer()
                } else {
                    Spacer().frame(height: 10)
                    List {
                        Button(action: {
                            if (comicInFavoriteList) {
                                app.komiicApi.removeFavorite(comicId: comicId)
                                comicInFavoriteList = false
                            } else {
                                app.komiicApi.addFavorite(comicId: comicId)
                                comicInFavoriteList = true
                            }
                        }, label: {
                            HStack {
                                Text("喜愛書籍").tint(.primary)
                                Spacer()
                                if (comicInFavoriteList) {
                                    Image(systemName: "checkmark")
                                }
                            }
                        })
                        ForEach (accountFolders, id: \.id) { folder in
                            Button(action: {
                                if (comicInFolders.contains(folder.id)) {
                                    app.komiicApi.removeComicToFolder(comicId: comicId, folderId: folder.id)
                                    comicInFolders.remove(at: comicInFolders.firstIndex(of: folder.id)!)
                                } else {
                                    app.komiicApi.addComicToFolder(comicId: comicId, folderId: folder.id)
                                    comicInFolders.append(folder.id)
                                }
                            }, label: {
                                HStack {
                                    Text(folder.name).tint(.primary)
                                    Spacer()
                                    if (comicInFolders.contains(folder.id)) {
                                        Image(systemName: "checkmark")
                                    }
                                }
                            })
                        }
                    }
                }
            }.onFirstAppear {
                app.komiicApi.fetchComicFolders(completion: {folders in
                    accountFolders.append(contentsOf: folders)
                    app.komiicApi.comicInAccountFolders(comicId: comicId, completion: {inFolder in
                        comicInFolders.append(contentsOf: inFolder)
                        app.komiicApi.getAccountInfo(completion: { accountInfo in
                            comicInFavoriteList = accountInfo.favoriteComicIds.contains(comicId)
                            isLoading = false
                        })
                    })
                })
            }.navigationTitle("加入至書櫃")
                .navigationBarItems(trailing:
                    Button (action: {
                        isPresented = false
                    }) {
                        ExitButtonView()
                    }.padding(5)
                )
        }
    }
}

