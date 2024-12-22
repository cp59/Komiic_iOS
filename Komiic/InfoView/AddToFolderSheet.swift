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
    @State private var performingFolders: [String] = []
    @State private var isLoading = true
    @State private var comicInFavoriteList = false
    @State private var loadState: LoadState = .loading
    @State private var showFailedToast = false
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
                                    comicInFolders.append(contentsOf: response.data!.comicInAccountFolders.compactMap { $0! })
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
            } else if loadState == .failed {
                Text("無法載入").font(.title).bold()
                Button(action: {
                    loadState = .loading
                }) {
                    Image(systemName: "arrow.triangle.2.circlepath.circle.fill")
                        .imageScale(.large)
                    Text("重試")
                }
                .buttonStyle(.borderedProminent)
                .buttonBorderShape(.capsule)
            } else {
                List {
                    Button(action: {
                        performingFolders.append("fav")
                        if comicInFavoriteList {
                            APIManager.shared.apolloClient.perform(mutation: RemoveFavoriteMutation(comicId: comicId)) { result in
                                switch result {
                                case .success(_):
                                    comicInFavoriteList = false
                                case .failure(_):
                                    showFailedToast = true
                                }
                                performingFolders.remove(at: performingFolders.firstIndex(of: "fav")!)
                            }
                        } else {
                            APIManager.shared.apolloClient.perform(mutation: AddFavoriteMutation(comicId: comicId)) { result in
                                switch result {
                                case .success(_):
                                    comicInFavoriteList = true
                                case .failure(_):
                                    showFailedToast = true
                                }
                                performingFolders.remove(at: performingFolders.firstIndex(of: "fav")!)
                            }
                        }
                    }, label: {
                        HStack {
                            Text("喜愛書籍").tint(.primary)
                            Spacer()
                            if performingFolders.contains("fav") {
                                ProgressView()
                            } else if comicInFavoriteList {
                                Image(systemName: "checkmark")
                            }
                        }
                    })
                    ForEach(accountFolders, id: \.id) { folder in
                        Button(action: {
                            performingFolders.append(folder.id)
                            if comicInFolders.contains(folder.id) {
                                APIManager.shared.apolloClient.perform(mutation: RemoveComicToFolderMutation(comicId: comicId, folderId: folder.id)) { result in
                                    switch result {
                                    case .success(_):
                                        comicInFolders.remove(at: comicInFolders.firstIndex(of: folder.id)!)
                                    case .failure(_):
                                        showFailedToast = true
                                    }
                                    performingFolders.remove(at: performingFolders.firstIndex(of: folder.id)!)
                                }
                            } else {
                                APIManager.shared.apolloClient.perform(mutation: AddComicToFolderMutation(comicId: comicId, folderId: folder.id)) { result in
                                    switch result {
                                    case .success(_):
                                        comicInFolders.append(folder.id)
                                    case .failure(_):
                                        showFailedToast = true
                                    }
                                    performingFolders.remove(at: performingFolders.firstIndex(of: folder.id)!)
                                }
                            }
                        }, label: {
                            HStack {
                                Text(folder.name).tint(.primary)
                                Spacer()
                                if performingFolders.contains(folder.id) {
                                    ProgressView()
                                } else if comicInFolders.contains(folder.id) {
                                    Image(systemName: "checkmark")
                                }
                            }
                        })
                    }
                }.alert(isPresented: $showFailedToast) {
                    Alert(title: Text("無法處理請求"), message: Text("檢查網路連線後，請稍後再試一次"))
                }
            }
        }.presentationDetents([.medium, .large]).onAppear {
            APIManager.shared.apolloClient.clearCache()
        }.interactiveDismissDisabled(!performingFolders.isEmpty)
    }
}
