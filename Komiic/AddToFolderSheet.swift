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
    private let komiicApi = KomiicAPI()
    var comicId:String
    var body: some View {
        NavigationView {
            VStack {
                if (isLoading) {
                    Spacer()
                    ProgressView().scaleEffect(1.5)
                    Spacer()
                } else {
                    Spacer().frame(height: 10)
                    List {
                        ForEach (accountFolders, id: \.id) { folder in
                            Button(action: {
                                if (comicInFolders.contains(folder.id)) {
                                    komiicApi.removeComicToFolder(comicId: comicId, folderId: folder.id)
                                    comicInFolders.remove(at: comicInFolders.firstIndex(of: folder.id)!)
                                } else {
                                    komiicApi.addComicToFolder(comicId: comicId, folderId: folder.id)
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
            }.onAppear {
                komiicApi.fetchComicFolders(completion: {folders in
                    accountFolders.append(contentsOf: folders)
                    komiicApi.comicInAccountFolders(comicId: comicId, completion: {inFolder in
                        comicInFolders.append(contentsOf: inFolder)
                        isLoading = false
                    })
                })
            }.navigationTitle("加入至書櫃")
        }
    }
}

