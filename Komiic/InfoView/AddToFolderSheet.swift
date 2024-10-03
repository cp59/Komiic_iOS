//
//  AddToFolderSheet.swift
//  Komiic
//
//  Created by 梁承樸 on 2024/3/21.
//

import KomiicAPI
import SwiftUI

struct AddToFolderSheet: View {
    @State private var accountFolders: [MyFolderQuery.Data.Folder] = []
    @State private var comicInFolders: [String] = []
    @State private var isLoading = true
    @State private var comicInFavoriteList = false
    @State private var loadState: LoadState = .loading
    @EnvironmentObject var appEnv: AppEnvironment
    var comicId: String
    var body: some View {
        VStack {
            if loadState == .loading {
                ProgressView().controlSize(.extraLarge).onAppear {
                    APIManager.shared.apolloClient.fetch(query: MyFolderQuery()) { result in
                        switch result {
                        case .success(let response):
                            accountFolders.append(contentsOf: response.data!.folders.compactMap { $0! })
                            APIManager.shared.apolloClient.fetch(query: ComicInAccountFoldersQuery(comicId: comicId)) { inResult in
                                switch inResult {
                                case .success(let response):
                                    comicInFolders.append(contentsOf: response.data!.comicInAccountFolders.compactMap({$0!}))
                                    APIManager.shared.apolloClient.fetch(query: AccountQuery()) { aqResult in 
                                        switch aqResult {
                                        case .success(let response):
                                            comicInFavoriteList = response.data!.account.favoriteComicIds.contains(comicId)
                                            loadState = .loaded
                                        case .failure(let error):
                                            loadState = .failed
                                            print(error)
                                        }
                                    }
                                case .failure(let error):
                                    loadState = .failed
                                    print(error)
                                }
                            }
                        case .failure(let error):
                            loadState = .failed
                            print(error)
                        }
                    }
                }
            } else {
                List {
                    Button(action: {
                        if comicInFavoriteList {
                            APIManager.shared.apolloClient.perform(mutation: RemoveFavoriteMutation(comicId: comicId))
                            comicInFavoriteList = false
                        } else {
                            APIManager.shared.apolloClient.perform(mutation: AddFavoriteMutation(comicId: comicId))
                            comicInFavoriteList = true
                        }
                    }, label: {
                        HStack {
                            Text("喜愛書籍").tint(.primary)
                            Spacer()
                            if comicInFavoriteList {
                                Image(systemName: "checkmark")
                            }
                        }
                    })
                    ForEach(accountFolders, id: \.id) { folder in
                        Button(action: {
                            if comicInFolders.contains(folder.id) {
                                APIManager.shared.apolloClient.perform(mutation: RemoveComicToFolderMutation(comicId: comicId, folderId: folder.id))
                                comicInFolders.remove(at: comicInFolders.firstIndex(of: folder.id)!)
                            } else {
                                APIManager.shared.apolloClient.perform(mutation: AddComicToFolderMutation(comicId: comicId, folderId: folder.id))
                                comicInFolders.append(folder.id)
                            }
                        }, label: {
                            HStack {
                                Text(folder.name).tint(.primary)
                                Spacer()
                                if comicInFolders.contains(folder.id) {
                                    Image(systemName: "checkmark")
                                }
                            }
                        })
                    }
                }
            }
        }.presentationDetents([.medium, .large]).onAppear {
            APIManager.shared.apolloClient.clearCache()
        }
    }
}
