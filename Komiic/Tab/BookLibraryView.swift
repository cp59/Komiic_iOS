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
    @State private var comicFolder: [MyFolderQuery.Data.Folder] = []
    var body: some View {
        NavigationStack {
            if !appEnv.isLogin {
                LoginView()
            } else if loadState == .loading {
                ProgressView().controlSize(.extraLarge).onFirstAppear {
                    APIManager.shared.apolloClient.fetch(query: MyFolderQuery()) { result in
                        switch result {
                        case .success(let response):
                            comicFolder.append(contentsOf: response.data!.folders.compactMap { $0! })
                            loadState = .loaded
                        case .failure(let error):
                            loadState = .failed
                            print(error)
                        }
                    }
                }
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
                }
            } else {
                ScrollView {
                    VStack {
                        LazyVGrid(columns: [GridItem(.adaptive(minimum: 175, maximum: 175), spacing: 10)], alignment: .center, spacing: 25) {
                            NavigationLink {
                                // OfflineComicView()
                            } label: {
                                VStack {
                                    Image(systemName: "arrow.down.square.fill").font(.system(size: 80)).foregroundColor(.primary).frame(width: 175, height: 230).background(.thickMaterial).cornerRadius(10)
                                    Text("離線下載").font(.callout).foregroundColor(.primary)
                                }
                            }
                            // ComicFolderItem(folder: KomiicAPI.Folder)
                            ForEach(comicFolder, id: \.id) { folder in
                                ComicFolderItem(folder: folder)
                            }
                        }
                    }.padding()
                }.navigationTitle("書櫃")
            }
        }
    }
}

struct ComicFolderItem: View {
    @EnvironmentObject var appEnv: AppEnvironment
    let folder: KomiicAPI.MyFolderQuery.Data.Folder
    @Namespace var namespace
    @State var comics: [KomiicAPI.ComicFrag] = []
    var body: some View {
        NavigationLink {
            FolderView(namespace: namespace, folder: folder,comics: comics)
        } label: {
            VStack {
                LazyVGrid(columns: [GridItem(.fixed(75)), GridItem(.fixed(75))], alignment: .center) {
                    ForEach(comics.prefix(4), id: \.id) { comic in
                        KFImage(URL(string: comic.imageUrl))
                            .diskCacheExpiration(.expired)
                            .resizable()
                            .placeholder {
                                Color.gray.frame(width: 75, height: 100).cornerRadius(10).redacted(reason: .placeholder)
                            }
                            .cancelOnDisappear(true)
                            .cornerRadius(6)
                            .scaledToFit()
                            .frame(width: 75, height: 100)
                    }
                }.frame(height: 210).padding(10).background(.thickMaterial).cornerRadius(10).onFirstAppear {
                    APIManager.shared.apolloClient.fetch(query: FolderComicIdsQuery(folderId: folder.id, pagination: Pagination(limit: 4, offset: 0, orderBy: GraphQLEnum(OrderBy.dateUpdated), asc: true))) { result in
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
                }.matchedTransitionSource(id: "folder_\(folder.id)", in: namespace)
                Text(folder.name).font(.callout).foregroundColor(.primary)
            }
        }
    }
}

#Preview {
    BookLibraryView()
}
