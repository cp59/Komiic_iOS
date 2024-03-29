//
//  ComicListView.swift
//  Komiic
//
//  Created by 梁承樸 on 2024/3/10.
//

import SwiftUI

struct ComicListView: View {
    private let komiicApi = KomiicAPI()
    var title:String
    let requestParameters:String
    var listType: Int = 0
    @State private var lastComic = false
    @State private var comics: [KomiicAPI.ComicData] = []
    @State private var isInit = false
    @State private var isLoading = true
    @State private var currentPage = 0
    @Binding var refreshList:Int
    var body: some View {
        List {
            ForEach(comics, id: \.id) {comic in
                ComicItemView(comic: comic)}
            if (!lastComic) {
                if (listType != 1) {
                    HStack {
                        Spacer()
                        VStack {
                            if isLoading {
                                ProgressView().scaleEffect(1.4).padding(10)
                                Text("載入中...")
                            }
                        }.padding(10)
                        Spacer()
                        
                    }.onAppear {
                        if (!isLoading && comics.count != 0) {
                            currentPage += 1
                            if (listType == 0) {
                                komiicApi.fetchComicList(parameters: requestParameters,page: currentPage,completion: {comicsResp in
                                    if (comicsResp.isEmpty) {
                                        lastComic = true
                                    } else {
                                        comics.append(contentsOf: comicsResp)}
                                    })
                            } else if (listType == 2) {
                                komiicApi.fetchComicHistory(page: currentPage, completion: {history in
                                    if (history.isEmpty) {
                                        lastComic = true
                                    } else {
                                        var queryString = "["
                                        for (index,comic) in history.enumerated() {
                                            queryString += "\"\(comic.comicId)\""
                                            queryString += (index == history.endIndex-1 ? "]" : ",")
                                        }
                                        komiicApi.fetchComicList(parameters: "{\"query\":\"query comicByIds($comicIds: [ID]!) {\\n  comicByIds(comicIds: $comicIds) {\\n    id\\n    title\\n    status\\n    year\\n    imageUrl\\n    authors {\\n      id\\n      name\\n    }\\n    categories {\\n      id\\n      name\\n    }\\n    dateUpdated\\n    monthViews\\n    views\\n    favoriteCount\\n    lastBookUpdate\\n    lastChapterUpdate\\n  }\\n}\",\"variables\":{\"comicIds\":\(queryString)}}",completion: {resp in comics.append(contentsOf: resp)})
                                    }
                                })
                            } else if (listType == 3){
                                komiicApi.fetchFavoritesComic(parameters: requestParameters,page: currentPage,completion: {history in
                                    if (history.isEmpty) {
                                        lastComic = true
                                    } else {
                                        var queryString = "["
                                        for (index,comic) in history.enumerated() {
                                            queryString += "\"\(comic.comicId)\""
                                            queryString += (index == history.endIndex-1 ? "]" : ",")
                                        }
                                        komiicApi.fetchComicList(parameters: "{\"query\":\"query comicByIds($comicIds: [ID]!) {\\n  comicByIds(comicIds: $comicIds) {\\n    id\\n    title\\n    status\\n    year\\n    imageUrl\\n    authors {\\n      id\\n      name\\n    }\\n    categories {\\n      id\\n      name\\n    }\\n    dateUpdated\\n    monthViews\\n    views\\n    favoriteCount\\n    lastBookUpdate\\n    lastChapterUpdate\\n  }\\n}\",\"variables\":{\"comicIds\":\(queryString)}}",completion: {resp in comics.append(contentsOf: resp)})
                                    }
                                    
                                })
                            } else if (listType == 4) {
                                komiicApi.fetchFolderComics(parameters: requestParameters,page: currentPage,completion: {folderComics in
                                    if (folderComics.isEmpty) {
                                        lastComic = true
                                    } else {
                                        komiicApi.fetchComicList(parameters: "{\"query\":\"query comicByIds($comicIds: [ID]!) {\\n  comicByIds(comicIds: $comicIds) {\\n    id\\n    title\\n    status\\n    year\\n    imageUrl\\n    authors {\\n      id\\n      name\\n    }\\n    categories {\\n      id\\n      name\\n    }\\n    dateUpdated\\n    monthViews\\n    views\\n    favoriteCount\\n    lastBookUpdate\\n    lastChapterUpdate\\n  }\\n}\",\"variables\":{\"comicIds\":\(folderComics)}}",completion: {resp in comics.append(contentsOf: resp)})
                                    }
                                })
                            }
                            isLoading = true
                        }
                    }
                    .onDisappear {isLoading = false}
                } else if (!isInit) {
                    HStack {
                        Spacer()
                        if isLoading {
                            VStack {
                                ProgressView().scaleEffect(1.4).padding(10)
                                Text("載入中...")
                            }.padding(10)
                        }
                        Spacer()
                        
                    }
                }
            }
        }
        .padding(EdgeInsets(top: 5, leading: 0, bottom: 0, trailing: 0))
        .onAppear{
            if (!isInit) {
                if (listType == 0 || listType == 1) {
                    komiicApi.fetchComicList(parameters: requestParameters,completion: {comicsResp in comics.append(contentsOf: comicsResp)
                        isInit = true
                        isLoading = false})
                } else if (listType == 2){
                    isInit = true
                    komiicApi.fetchComicHistory(completion: {history in
                        var queryString = "["
                        for (index,comic) in history.enumerated() {
                            queryString += "\"\(comic.comicId)\""
                            queryString += (index == history.endIndex-1 ? "]" : ",")
                        }
                        komiicApi.fetchComicList(parameters: "{\"query\":\"query comicByIds($comicIds: [ID]!) {\\n  comicByIds(comicIds: $comicIds) {\\n    id\\n    title\\n    status\\n    year\\n    imageUrl\\n    authors {\\n      id\\n      name\\n    }\\n    categories {\\n      id\\n      name\\n    }\\n    dateUpdated\\n    monthViews\\n    views\\n    favoriteCount\\n    lastBookUpdate\\n    lastChapterUpdate\\n  }\\n}\",\"variables\":{\"comicIds\":\(queryString)}}",completion: {resp in comics.append(contentsOf: resp)
                            isInit = true
                            isLoading = false})
                        
                    })
                } else if (listType == 3){
                    isInit = true
                    komiicApi.fetchFavoritesComic(parameters: requestParameters,completion: {history in
                        var queryString = "["
                        for (index,comic) in history.enumerated() {
                            queryString += "\"\(comic.comicId)\""
                            queryString += (index == history.endIndex-1 ? "]" : ",")
                        }
                        komiicApi.fetchComicList(parameters: "{\"query\":\"query comicByIds($comicIds: [ID]!) {\\n  comicByIds(comicIds: $comicIds) {\\n    id\\n    title\\n    status\\n    year\\n    imageUrl\\n    authors {\\n      id\\n      name\\n    }\\n    categories {\\n      id\\n      name\\n    }\\n    dateUpdated\\n    monthViews\\n    views\\n    favoriteCount\\n    lastBookUpdate\\n    lastChapterUpdate\\n  }\\n}\",\"variables\":{\"comicIds\":\(queryString)}}",completion: {resp in comics.append(contentsOf: resp)
                            isInit = true
                            isLoading = false})
                        
                    })
                } else if (listType == 4) {
                    komiicApi.fetchFolderComics(parameters: requestParameters,completion: {folderComics in
                        komiicApi.fetchComicList(parameters: "{\"query\":\"query comicByIds($comicIds: [ID]!) {\\n  comicByIds(comicIds: $comicIds) {\\n    id\\n    title\\n    status\\n    year\\n    imageUrl\\n    authors {\\n      id\\n      name\\n    }\\n    categories {\\n      id\\n      name\\n    }\\n    dateUpdated\\n    monthViews\\n    views\\n    favoriteCount\\n    lastBookUpdate\\n    lastChapterUpdate\\n  }\\n}\",\"variables\":{\"comicIds\":\(folderComics)}}",completion: {resp in comics.append(contentsOf: resp)
                            isInit = true
                            isLoading = false})
                        
                    })
                }
            }
        }.onChange(of: refreshList) { _ in
            isInit = false
            isLoading = true
            comics.removeAll()
            currentPage = 0
            if (listType == 0) {
                komiicApi.fetchComicList(parameters: requestParameters,completion: {comicsResp in
                    comics.append(contentsOf: comicsResp)
                    isInit = true
                    isLoading = false})
            } else if (listType == 2){
                isInit = true
                komiicApi.fetchComicHistory(completion: {history in
                    var queryString = "["
                    for (index,comic) in history.enumerated() {
                        queryString += "\"\(comic.comicId)\""
                        queryString += (index == history.endIndex-1 ? "]" : ",")
                    }
                    komiicApi.fetchComicList(parameters: "{\"query\":\"query comicByIds($comicIds: [ID]!) {\\n  comicByIds(comicIds: $comicIds) {\\n    id\\n    title\\n    status\\n    year\\n    imageUrl\\n    authors {\\n      id\\n      name\\n    }\\n    categories {\\n      id\\n      name\\n    }\\n    dateUpdated\\n    monthViews\\n    views\\n    favoriteCount\\n    lastBookUpdate\\n    lastChapterUpdate\\n  }\\n}\",\"variables\":{\"comicIds\":\(queryString)}}",completion: {resp in comics.append(contentsOf: resp)
                        isInit = true
                        isLoading = false})
                    
                })
            } else if (listType == 3){
                isInit = true
                komiicApi.fetchFavoritesComic(parameters: requestParameters,completion: {history in
                    var queryString = "["
                    for (index,comic) in history.enumerated() {
                        queryString += "\"\(comic.comicId)\""
                        queryString += (index == history.endIndex-1 ? "]" : ",")
                    }
                    komiicApi.fetchComicList(parameters: "{\"query\":\"query comicByIds($comicIds: [ID]!) {\\n  comicByIds(comicIds: $comicIds) {\\n    id\\n    title\\n    status\\n    year\\n    imageUrl\\n    authors {\\n      id\\n      name\\n    }\\n    categories {\\n      id\\n      name\\n    }\\n    dateUpdated\\n    monthViews\\n    views\\n    favoriteCount\\n    lastBookUpdate\\n    lastChapterUpdate\\n  }\\n}\",\"variables\":{\"comicIds\":\(queryString)}}",completion: {resp in comics.append(contentsOf: resp)
                        isInit = true
                        isLoading = false})
                    
                })
            } else if (listType == 4) {
                komiicApi.fetchFolderComics(parameters: requestParameters,completion: {folderComics in
                    komiicApi.fetchComicList(parameters: "{\"query\":\"query comicByIds($comicIds: [ID]!) {\\n  comicByIds(comicIds: $comicIds) {\\n    id\\n    title\\n    status\\n    year\\n    imageUrl\\n    authors {\\n      id\\n      name\\n    }\\n    categories {\\n      id\\n      name\\n    }\\n    dateUpdated\\n    monthViews\\n    views\\n    favoriteCount\\n    lastBookUpdate\\n    lastChapterUpdate\\n  }\\n}\",\"variables\":{\"comicIds\":\(folderComics)}}",completion: {resp in comics.append(contentsOf: resp)
                        isInit = true
                        isLoading = false})
                    
                })
            }
        }
            .navigationTitle(title)

    }
}

struct ComicItemView: View {
    var comic: KomiicAPI.ComicData
    @State private var openDetailPage = false
    var body: some View {
        HStack {
            ImageView(withURL: comic.imageUrl)
                .scaleEffect(1.8)
                .padding(EdgeInsets(top: 35, leading: 10, bottom: 35, trailing: 20))
                .cornerRadius(12)
            VStack(alignment: .leading, content: {
                Spacer().frame(height: 20)
                Text(comic.title).font(.title3).bold().truncationMode(.tail).lineLimit(2)
                //Spacer().frame(height: 5)
                Spacer()
                Text(ISO8601DateFormatter().date(from: comic.dateUpdated)!.timeAgoDisplay()+"更新").font(.subheadline).padding(4).background(.gray).cornerRadius(6)
                HStack {
                    HStack (spacing: 3){
                        Image(systemName: "chart.bar.xaxis").font(.subheadline)
                        Text(String(comic.views)).font(.subheadline)
                    }.padding(4).background(.gray).cornerRadius(6)
                    HStack (spacing: 3){
                        Image(systemName: "heart").font(.subheadline)
                        Text(String(comic.favoriteCount)).font(.subheadline)
                    }.padding(4).background(.gray).cornerRadius(6)
                    Spacer()
                }
                HStack {
                    if (comic.status == "ONGOING") {
                        Text("連載中").font(.subheadline).padding(4).background(.blue).cornerRadius(6)
                    } else if (comic.status == "END") {
                        Text("已完結").font(.subheadline).padding(4).background(.gray).cornerRadius(6)
                    }
                    Spacer().frame(width: 5)
                    if (!comic.lastChapterUpdate.isEmpty) {
                        Text("\(comic.lastChapterUpdate)話").font(.subheadline).padding(4).background(.gray).cornerRadius(6)
                    }
                    Spacer().frame(width: 5)
                    if (!comic.lastBookUpdate.isEmpty) {
                        Text("\(comic.lastBookUpdate)卷").font(.subheadline).padding(4).background(.gray).cornerRadius(6)
                    }
                    Spacer()
                }
                Spacer().frame(height: 20)
            })
            NavigationLink(destination: ComicDetailView(comicData: comic), isActive: $openDetailPage )
            {EmptyView()}.frame(width: 0, height: 0)
            Spacer()
            
        }.onTapGesture {
            openDetailPage = true
        }
        
    }
}


