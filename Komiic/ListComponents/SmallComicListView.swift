//
//  SmallComicListView.swift
//  Komiic
//
//  Created by 梁承樸 on 2024/7/28.
//

import Apollo
import Kingfisher
import KomiicAPI
import SwiftUI

struct SmallComicListView: View {
    @Namespace var namespace
    @EnvironmentObject var appEnv: AppEnvironment
    let listType: ListType
    let title: String
    @State var comics: [KomiicAPI.ComicFrag] = []
    @State private var loadState: LoadState = .loading
    var body: some View {
        NavigationLink {
            ComicListView(listType: listType, comics: comics).navigationTitle(title)
        } label: {
            HStack {
                Spacer().frame(width: 5)
                Text(title).foregroundColor(.primary).font(.title3).bold()
                Image(systemName: "chevron.right").foregroundColor(Color.gray).bold()
                Spacer()
            }
        }
        if loadState == LoadState.loading {
            VStack {
                ProgressView().controlSize(.extraLarge).onFirstAppear {
                    fetchData()
                }
            }.frame(height: 210)
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
            }.frame(height: 210)
        } else {
            ScrollView(.horizontal, showsIndicators: false) {
                LazyHStack {
                    ForEach(Array(comics.enumerated()), id: \.offset) { index, comic in
                        NavigationLink {
                            BookDetailView(namespace: namespace, comic: comic)
                        }label: {
                            KFImage(URL(string: comic.imageUrl))
                                .resizable()
                                .placeholder {
                                    Color.gray.frame(width: 150, height: 200).cornerRadius(6).redacted(reason: .placeholder)
                                }
                                .cancelOnDisappear(true)
                                .fade(duration: 0.5)
                                .id(index)
                                .cornerRadius(6)
                                .scaledToFit()
                                .frame(width: 150, height: 200)
                                .padding(5)
                                .matchedTransitionSource(id: comic.id, in: namespace)
                        }
                    }
                }
            }
        }
    }

    func fetchData() {
        if listType == .recentUpdate {
            APIManager.shared.apolloClient
                .fetch(query: RecentUpdateQuery(pagination: Pagination(limit: 20, offset: 0, orderBy: GraphQLEnum(OrderBy.dateUpdated), asc: true))) { result in
                    switch result {
                    case .success(let response):
                        comics.append(contentsOf: response.data!.recentUpdate!.compactMap { $0?.fragments.comicFrag })
                        loadState = .loaded
                    case .failure(let error):
                        loadState = .failed
                        print(error)
                    }
                }
        } else if listType == .monthHotComic {
            APIManager.shared.apolloClient
                .fetch(query: HotComicsQuery(pagination: Pagination(limit: 20, offset: 0, orderBy: GraphQLEnum(OrderBy.monthViews), asc: true))) { result in
                    switch result {
                    case .success(let response):
                        comics.append(contentsOf: response.data!.hotComics.compactMap { $0?.fragments.comicFrag })
                        loadState = .loaded
                    case .failure(let error):
                        loadState = .failed
                        print(error)
                    }
                }
        } else if listType == .hotComic {
            APIManager.shared.apolloClient
                .fetch(query: HotComicsQuery(pagination: Pagination(limit: 20, offset: 0, orderBy: GraphQLEnum(OrderBy.views), asc: true))) { result in
                    switch result {
                    case .success(let response):
                        comics.append(contentsOf: response.data!.hotComics.compactMap { $0?.fragments.comicFrag })
                        loadState = .loaded
                    case .failure(let error):
                        loadState = .failed
                        print(error)
                    }
                }
        }
    }
}

#Preview {
    ComicListView(listType: .recentUpdate)
}
