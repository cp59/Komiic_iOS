//
//  ComicListView.swift
//  Komiic
//
//  Created by 梁承樸 on 2024/3/10.
//

import SwiftUI

struct ComicListView: View {
    @EnvironmentObject var app: app
    var title:String
    let requestParameters:String
    var listType: Int = 0
    @State private var lastComic = false
    @State private var comics: [KomiicAPI.ComicData] = []
    @State private var isLoading = false
    @State private var currentPage = -1
    @Binding var refreshList:Int
    init(title: String, requestParameters: String, listType: Int = 0, refreshList: Binding<Int> = .constant(0)) {
        self.title = title
        self.requestParameters = requestParameters
        self.listType = listType
        self._refreshList = refreshList
    }
    func fetchData () {
        if (listType == 0 || listType == 1) {
            app.komiicApi.fetchComicList(parameters: requestParameters,page: currentPage,completion: {comicsResp in
                if (comicsResp.isEmpty) {
                    lastComic = true
                } else {
                    comics.append(contentsOf: comicsResp)
                }
                isLoading = false
                if (listType == 1) {
                    lastComic = true
                }
                })
        } else if (listType == 2) {
            app.komiicApi.fetchComicHistory(page: currentPage, completion: {history in
                if (history.isEmpty) {
                    lastComic = true
                } else {
                    var queryString = "["
                    for (index,comic) in history.enumerated() {
                        queryString += "\"\(comic.comicId)\""
                        queryString += (index == history.endIndex-1 ? "]" : ",")
                    }
                    app.komiicApi.fetchComicList(parameters: "{\"query\":\"query comicByIds($comicIds: [ID]!) {\\n  comicByIds(comicIds: $comicIds) {\\n    id\\n    title\\n    status\\n    year\\n    imageUrl\\n    authors {\\n      id\\n      name\\n    }\\n    categories {\\n      id\\n      name\\n    }\\n    dateUpdated\\n    monthViews\\n    views\\n    favoriteCount\\n    lastBookUpdate\\n    lastChapterUpdate\\n  }\\n}\",\"variables\":{\"comicIds\":\(queryString)}}",completion: {resp in
                            comics.append(contentsOf: resp)
                            isLoading = false
                    })
                }
            })
        } else if (listType == 3){
            app.komiicApi.fetchFavoritesComic(parameters: requestParameters,page: currentPage,completion: {history in
                if (history.isEmpty) {
                    lastComic = true
                } else {
                    var queryString = "["
                    for (index,comic) in history.enumerated() {
                        queryString += "\"\(comic.comicId)\""
                        queryString += (index == history.endIndex-1 ? "]" : ",")
                    }
                    app.komiicApi.fetchComicList(parameters: "{\"query\":\"query comicByIds($comicIds: [ID]!) {\\n  comicByIds(comicIds: $comicIds) {\\n    id\\n    title\\n    status\\n    year\\n    imageUrl\\n    authors {\\n      id\\n      name\\n    }\\n    categories {\\n      id\\n      name\\n    }\\n    dateUpdated\\n    monthViews\\n    views\\n    favoriteCount\\n    lastBookUpdate\\n    lastChapterUpdate\\n  }\\n}\",\"variables\":{\"comicIds\":\(queryString)}}",completion: {resp in
                        comics.append(contentsOf: resp)
                        isLoading = false
                    })
                }
                
            })
        } else if (listType == 4) {
            app.komiicApi.fetchFolderComics(parameters: requestParameters,page: currentPage,completion: {folderComics in
                if (folderComics.isEmpty) {
                    lastComic = true
                } else {
                    app.komiicApi.fetchComicList(parameters: "{\"query\":\"query comicByIds($comicIds: [ID]!) {\\n  comicByIds(comicIds: $comicIds) {\\n    id\\n    title\\n    status\\n    year\\n    imageUrl\\n    authors {\\n      id\\n      name\\n    }\\n    categories {\\n      id\\n      name\\n    }\\n    dateUpdated\\n    monthViews\\n    views\\n    favoriteCount\\n    lastBookUpdate\\n    lastChapterUpdate\\n  }\\n}\",\"variables\":{\"comicIds\":\(folderComics)}}",completion: {resp in
                        comics.append(contentsOf: resp)
                        isLoading = false
                    })
                }
            })
        }
    }
    var body: some View {
        ScrollView {
            LazyVGrid (columns: [GridItem(.adaptive(minimum: 160))]) {
                ForEach(comics, id: \.id) {comic in
                    ComicItemView(comic: comic).onAppear {
                        if ((comic.id == comics.last!.id) && !lastComic) {
                            if (listType == 1) {
                                if (!lastComic && !isLoading) {
                                    isLoading = true
                                    fetchData()
                                }
                            } else {
                                if (!isLoading) {
                                    isLoading = true
                                    currentPage += 1
                                    fetchData()
                                }
                            }
                        }
                    }
                }
            }.padding(10)
            if (!lastComic) {
                HStack {
                    Spacer()
                    VStack {
                        ProgressView()
                        Spacer().frame(height: 5)
                        Text("載入中...").font(.caption).foregroundStyle(.gray)
                    }.padding(20)
                    Spacer()
                }.onAppear {
                    if (listType == 1) {
                        if (!lastComic && !isLoading) {
                            isLoading = true
                            fetchData()
                        }
                    } else {
                        if (!isLoading) {
                            isLoading = true
                            currentPage += 1
                            fetchData()
                        }
                    }
                }
            }
        }
        .padding(EdgeInsets(top: 5, leading: 0, bottom: 0, trailing: 0))
        .onChange(of: refreshList) { _ in
            isLoading = true
            lastComic = false
            comics.removeAll()
            currentPage = 0
            fetchData()
        }.navigationTitle(title)

    }
}

struct ComicItemView: View {
    var comic: KomiicAPI.ComicData
    @State private var openDetailPage = false
    var body: some View {
        VStack {
            ImageView(withURL: comic.imageUrl,width:160,height:213)
            Text(comic.title).font(.headline).truncationMode(.tail).lineLimit(1).frame(width: 160,alignment: .leading)
            Text("\(comic.views)次點閱").font(.footnote).frame(width: 160,alignment: .leading)
            NavigationLink(destination: ComicDetailView(comicData: comic), isActive: $openDetailPage )
            {EmptyView()}.frame(width: 0, height: 0)
            Spacer()
            
        }.onTapGesture {
            openDetailPage = true
        }
        
    }
}


