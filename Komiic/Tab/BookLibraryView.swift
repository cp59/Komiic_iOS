//
//  BookLibraryView.swift
//  Komiic
//
//  Created by 梁承樸 on 2024/7/30.
//

import Kingfisher
import KomiicAPI
import SwiftUI

struct BookLibraryView: View {
    @EnvironmentObject var appEnv: AppEnvironment
    @State private var loadState: LoadState = .loading
    @State private var showCreateFolderSheet: Bool = false
    @State private var folderName: String = ""
    @State private var comicFolder: [KomiicAPI.FolderFrag] = []
    @State private var firstLoaded = false
    var body: some View {
        NavigationStack {
            if !appEnv.isLogin {
                LoginView()
            } else if loadState == .loading {
                ProgressView().controlSize(.extraLarge).onFirstAppear {
                    APIManager.shared.apolloClient.fetch(query: MyFolderQuery()) { result in
                        switch result {
                        case .success(let response):
                            comicFolder.append(contentsOf: response.data!.folders.compactMap { $0!.fragments.folderFrag })
                            loadState = .loaded
                        case .failure(let error):
                            loadState = .failed
                            print(error)
                        }
                    }
                }.navigationTitle("書櫃")
            } else if loadState == .failed {
                VStack {
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
                }.navigationTitle("書櫃")
            } else {
                ScrollView {
                    VStack {
                        LazyVGrid(columns: [GridItem(.adaptive(minimum: 175, maximum: 175), spacing: 5)], alignment: .center, spacing: 15) {
                            NavigationLink {
                                // OfflineComicView()
                            } label: {
                                VStack {
                                    Image(systemName: "arrow.down.square.fill").font(.system(size: 80)).foregroundColor(.primary).frame(width: 175, height: 230).background(.thickMaterial).cornerRadius(10)
                                    Text("離線下載").font(.callout).foregroundColor(.primary)
                                }
                            }
                            ComicFolderItem()
                            ForEach(comicFolder, id: \.id) { folder in
                                ComicFolderItem(folder: folder)
                            }
                        }
                    }.padding()
                }.navigationTitle("書櫃").navigationBarItems(trailing:
                    Button(action: { showCreateFolderSheet = true }) { Image(systemName: "plus") }
                ).onAppear {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        if firstLoaded {
                            APIManager.shared.apolloClient.clearCache()
                            APIManager.shared.apolloClient.fetch(query: MyFolderQuery()) { result in
                                switch result {
                                case .success(let response):
                                    comicFolder = response.data!.folders.compactMap { $0!.fragments.folderFrag }
                                case .failure(let error):
                                    print(error)
                                }
                            }
                        }
                    }
                }.onFirstAppear {
                    firstLoaded = true
                }.refreshable {
                    do {
                        APIManager.shared.apolloClient.clearCache()
                        let result = try await APIManager.shared.apolloClient.fetch(query: MyFolderQuery())
                        comicFolder = result.data!.folders.compactMap { $0!.fragments.folderFrag }
                    } catch {
                        print(error)
                    }
                }
                .sheet(isPresented: $showCreateFolderSheet, onDismiss: {
                    APIManager.shared.apolloClient.clearCache()
                    APIManager.shared.apolloClient.fetch(query: MyFolderQuery()) { result in
                        switch result {
                        case .success(let response):
                            comicFolder = response.data!.folders.compactMap { $0!.fragments.folderFrag }
                        case .failure(let error):
                            print(error)
                        }
                    }
                }) {
                    CreateFolderSheet()
                }
            }
        }
    }
}

struct ComicFolderItem: View {
    @EnvironmentObject var appEnv: AppEnvironment
    var folder: KomiicAPI.FolderFrag? = nil
    @Namespace var namespace
    @State var comics: [KomiicAPI.ComicFrag] = []
    var body: some View {
        NavigationLink {
            if folder != nil {
                FolderView(namespace: namespace, folder: folder!)
            } else {
                FavoritesView(namespace: namespace)
            }
        } label: {
            VStack {
                LazyVGrid(columns: [GridItem(.fixed(75)), GridItem(.fixed(75))], alignment: .center) {
                    ForEach(comics.prefix(4), id: \.id) { comic in
                        KFImage(URL(string: comic.imageUrl))
                            .diskCacheExpiration(.expired)
                            .resizable()
                            .placeholder {
                                Spacer().frame(width: 75, height: 100).cornerRadius(6).redacted(reason: .placeholder)
                            }
                            .cancelOnDisappear(true)
                            .cornerRadius(6)
                            .scaledToFit()
                            .frame(width: 75, height: 100)
                    }
                    if comics.isEmpty {
                        ForEach(0 ..< 4) { _ in
                            Spacer().frame(width: 75, height: 100).cornerRadius(6)
                        }
                    } else if comics.count < 4 {
                        ForEach(0 ..< (4 - comics.count)) { _ in
                            Spacer().frame(width: 75, height: 100).cornerRadius(6)
                        }
                    }
                }.frame(height: 210).padding(10).background(.thickMaterial).cornerRadius(10).onFirstAppear {
                    if folder != nil {
                        APIManager.shared.apolloClient.fetch(query: FolderComicIdsQuery(folderId: folder!.id, pagination: Pagination(limit: 4, offset: 0, orderBy: GraphQLEnum(OrderBy.dateUpdated), asc: true))) { result in
                            switch result {
                            case .success(let response):
                                APIManager.shared.apolloClient.fetch(query: ComicByIdsQuery(comicIds: (response.data?.folderComicIds.comicIds)!)) { comicResult in
                                    switch comicResult {
                                    case .success(let response):
                                        comics.append(contentsOf: response.data!.comicByIds.compactMap { $0?.fragments.comicFrag })
                                    case .failure(let error):
                                        print(error)
                                    }
                                }
                            case .failure(let error):
                                print(error)
                            }
                        }
                    } else {
                        APIManager.shared.apolloClient.fetch(query: FavoritesQuery(pagination: Pagination(limit: 4, offset: 0, orderBy: GraphQLEnum(OrderBy.dateUpdated), asc: true))) { result in
                            switch result {
                            case .success(let response):
                                APIManager.shared.apolloClient.fetch(query: ComicByIdsQuery(comicIds: response.data!.favoritesV2.compactMap{$0!.comicId})) { comicResult in
                                    switch comicResult {
                                    case .success(let response):
                                        comics.append(contentsOf: response.data!.comicByIds.compactMap { $0?.fragments.comicFrag })
                                    case .failure(let error):
                                        print(error)
                                    }
                                }
                            case .failure(let error):
                                print(error)
                            }
                        }
                    }
                }.matchedTransitionSource(id: folder == nil ? "favorites" : "folder_\(folder!.id)", in: namespace)
                if folder == nil {
                    Text("喜愛書籍").font(.callout).foregroundColor(.primary)
                } else {
                    Text(folder!.name).font(.callout).foregroundColor(.primary)
                }
            }
        }
    }
}

#Preview {
    BookLibraryView()
}
