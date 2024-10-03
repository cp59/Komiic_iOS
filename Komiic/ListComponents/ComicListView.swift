//
//  ComicListView.swift
//  Komiic
//
//  Created by 梁承樸 on 2024/7/28.
//

import Apollo
import Kingfisher
import KomiicAPI
import SwiftUI

struct ComicListView: View {
    @EnvironmentObject var appEnv:AppEnvironment
    @Namespace var namespace
    let listType: ListType
    var args: String = ""
    @State var comics: [KomiicAPI.ComicFrag] = []
    @State private var loadState: LoadState = .loading
    @State private var page = -1
    @State private var scrollID: Int?
    @Binding var orderBy: OrderBy
    @Binding var status: String
    @Binding var categoryId: String
    init(listType: ListType, args: String = "", comics: [KomiicAPI.ComicFrag] = [], page: Int = -1, orderBy: Binding<OrderBy> = .constant(.dateUpdated), status: Binding<String> = .constant(""), categoryId: Binding<String> = .constant("0")) {
        self.listType = listType
        self.args = args
        self.comics = comics
        self.page = page
        self._orderBy = orderBy
        self._status = status
        self._categoryId = categoryId
    }
    var body: some View {
        if loadState == LoadState.loading {
            VStack {
                ProgressView().controlSize(.extraLarge).onFirstAppear {
                    if !comics.isEmpty {
                        page = 0
                        loadState = .loaded
                    } else {
                        fetchData()
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
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 150, maximum: 150), spacing: 25)], alignment: .center, spacing: 25) {
                    ForEach(Array(comics.enumerated()), id: \.offset) { index, comic in
                        NavigationLink {
                            BookDetailView(namespace: namespace, comic: comic)
                        } label: {
                            VStack {
                                KFImage(URL(string: comic.imageUrl))
                                    .resizable()
                                    .placeholder {
                                        Color.gray.frame(width: 150, height: 200).cornerRadius(6).redacted(reason: .placeholder)
                                    }
                                    .cancelOnDisappear(true)
                                    .fade(duration: 0.25)
                                    .id(index)
                                    .matchedTransitionSource(id: comic.id, in: namespace)
                                    .cornerRadius(8)
                                    .scaledToFit()
                                    .frame(width: 150, height: 200)
                                Text(comic.title).font(.subheadline).truncationMode(.tail).bold().lineLimit(1).frame(width: 150, alignment: .leading).foregroundColor(.primary)
                                Text("\(comic.views!)次點閱").font(.caption).frame(width: 150, alignment: .leading).foregroundColor(.primary)
                            }
                        }
                    }
                }.padding().scrollTargetLayout()
                if loadState != .end && comics.count >= 20 {
                    ProgressView().padding().onChange(of: scrollID) {
                        if loadState != .loadingMore && scrollID ?? 0 >= comics.count - 10 {
                            loadState = .loadingMore
                            fetchData()
                        }
                    }
                }
            }.scrollPosition(id: $scrollID).onChange(of: orderBy, {
                comics.removeAll()
                page = -1
                loadState = .loading
            }).onChange(of: status, {
                comics.removeAll()
                page = -1
                loadState = .loading
            }).onChange(of: categoryId, {
                comics.removeAll()
                page = -1
                loadState = .loading
            })
        }
    }

    func fetchData() {
        if listType == .recentUpdate {
            APIManager.shared.apolloClient
                .fetch(query: RecentUpdateQuery(pagination: Pagination(limit: 20, offset: (page + 1) * 20, orderBy: GraphQLEnum(OrderBy.dateUpdated), asc: true))) { result in
                    switch result {
                    case .success(let response):
                        comics.append(contentsOf: response.data!.recentUpdate!.compactMap { $0?.fragments.comicFrag })
                        loadSuccessHandler()
                    case .failure(let error):
                        loadFailureHandler()
                        print(error)
                    }
                }
        } else if listType == .monthHotComic {
            APIManager.shared.apolloClient
                .fetch(query: HotComicsQuery(pagination: Pagination(limit: 20, offset: (page + 1) * 20, orderBy: GraphQLEnum(OrderBy.monthViews), asc: true))) { result in
                    switch result {
                    case .success(let response):
                        comics.append(contentsOf: response.data!.hotComics.compactMap { $0?.fragments.comicFrag })
                        loadSuccessHandler()
                    case .failure(let error):
                        loadFailureHandler()
                        print(error)
                    }
                }
        } else if listType == .hotComic {
            APIManager.shared.apolloClient
                .fetch(query: HotComicsQuery(pagination: Pagination(limit: 20, offset: (page + 1) * 20, orderBy: GraphQLEnum(OrderBy.views), asc: true))) { result in
                    switch result {
                    case .success(let response):
                        comics.append(contentsOf: response.data!.hotComics.compactMap { $0?.fragments.comicFrag })
                        loadSuccessHandler()
                    case .failure(let error):
                        loadFailureHandler()
                        print(error)
                    }
                }
        } else if listType == .folderComic {
            APIManager.shared.apolloClient.fetch(query: FolderComicIdsQuery(folderId: args, pagination: Pagination(limit: 20, offset: (page + 1) * 20, orderBy: GraphQLEnum(OrderBy.dateUpdated), asc: true))) { result in
                switch result {
                case .success(let response):
                    if response.data!.folderComicIds.comicIds.isEmpty {
                        loadSuccessHandler()
                    } else {
                        APIManager.shared.apolloClient.fetch(query: ComicByIdsQuery(comicIds: (response.data?.folderComicIds.comicIds)!)) { comicResult in
                            switch comicResult {
                            case .success(let response):
                                comics.append(contentsOf: response.data!.comicByIds.compactMap { $0?.fragments.comicFrag })
                                loadSuccessHandler()
                            case .failure(let error):
                                loadFailureHandler()
                                print(error)
                            }
                        }
                    }
                case .failure(let error):
                    loadFailureHandler()
                    print(error)
                }
            }
        } else if listType == .allComics {
            APIManager.shared.apolloClient.fetch(query: ComicByCategoryQuery(categoryId: categoryId, pagination: Pagination(limit: 20, offset: (page + 1) * 20, orderBy: GraphQLEnum(orderBy), asc: false, status: GraphQLNullable(stringLiteral: status)))) { result in
                switch result {
                case .success(let response):
                    comics.append(contentsOf: response.data!.comicByCategory.compactMap { $0?.fragments.comicFrag })
                    loadSuccessHandler()
                case .failure(let error):
                    loadFailureHandler()
                    print(error)
                }
            }
        } else if listType == .authorComics {
            APIManager.shared.apolloClient.fetch(query: ComicsByAuthorQuery(authorId: args)) { result in
                switch result {
                    case .success(let response):
                    comics.append(contentsOf: response.data!.getComicsByAuthor.compactMap{$0?.fragments.comicFrag})
                    loadState = .end
                case .failure(let error):
                    loadFailureHandler()
                    print(error)
                }
            }
        }
    }

    func loadSuccessHandler() {
        page += 1
        if comics.count < 20 * (page + 1) {
            loadState = .end
        } else {
            loadState = .loaded
        }
    }

    func loadFailureHandler() {
        if loadState == .loadingMore {
            loadState = .loaded
        } else {
            loadState = .failed
        }
    }
}

#Preview {
    ComicListView(listType: .recentUpdate)
}
