//
//  ComicListView.swift
//  Komiic
//
//  Created by 梁承樸 on 2024/3/10.
//

import SwiftUI

struct SmallComicListView: View {
    @EnvironmentObject var app:app
    @State var comics: [KomiicAPI.ComicData] = []
    @State var isLoading = true
    var folder:KomiicAPI.ComicFolder = KomiicAPI.ComicFolder(id: "", key: "", name: "", views: 0, comicCount: 0)
    var listType:Int = 0
    let title:String
    let requestParameters:String
    var body: some View {
        Spacer().frame(height: 10)
        HStack {
            Text(title).font(.title2).bold()
            Spacer()
            if (listType == 0) {
                NavigationLink(destination: ComicListView(title: title, requestParameters: requestParameters), label: {
                    Text("查看全部")
                })
            } else if (listType == 3){
                NavigationLink(destination: FavoritesComicView(), label: {
                    Text("查看全部")
                })
            } else if (listType == 4) {
                NavigationLink(destination: FolderComicView(folder: folder), label: {
                    Text("查看全部")
                })
            }
        }.onFirstAppear {
            if (listType == 0) {
                app.komiicApi.fetchComicList(parameters: requestParameters,completion: {comicsResp in
                    comics.append(contentsOf: comicsResp)
                    isLoading = false})
            } else if (listType == 3) {
                app.komiicApi.fetchFavoritesComic(completion: {history in
                    var queryString = "["
                    for (index,comic) in history.enumerated() {
                        queryString += "\"\(comic.comicId)\""
                        queryString += (index == history.endIndex-1 ? "]" : ",")
                    }
                    app.komiicApi.fetchComicList(parameters: "{\"query\":\"query comicByIds($comicIds: [ID]!) {\\n  comicByIds(comicIds: $comicIds) {\\n    id\\n    title\\n    status\\n    year\\n    imageUrl\\n    authors {\\n      id\\n      name\\n    }\\n    categories {\\n      id\\n      name\\n    }\\n    dateUpdated\\n    monthViews\\n    views\\n    favoriteCount\\n    lastBookUpdate\\n    lastChapterUpdate\\n  }\\n}\",\"variables\":{\"comicIds\":\(queryString)}}",completion: {resp in 
                        comics.append(contentsOf: resp)
                        isLoading = false})
                })
            } else if (listType == 4) {
                app.komiicApi.fetchFolderComics(parameters: requestParameters,completion: {folderComics in
                    app.komiicApi.fetchComicList(parameters: "{\"query\":\"query comicByIds($comicIds: [ID]!) {\\n  comicByIds(comicIds: $comicIds) {\\n    id\\n    title\\n    status\\n    year\\n    imageUrl\\n    authors {\\n      id\\n      name\\n    }\\n    categories {\\n      id\\n      name\\n    }\\n    dateUpdated\\n    monthViews\\n    views\\n    favoriteCount\\n    lastBookUpdate\\n    lastChapterUpdate\\n  }\\n}\",\"variables\":{\"comicIds\":\(folderComics)}}",completion: {resp in
                        comics.append(contentsOf: resp)
                        isLoading = false})
                    
                })
            }
        }
        if (isLoading) {
            ProgressView().frame(height: 183)
        } else {
            ScrollView (.horizontal, showsIndicators: false){
                LazyHStack {
                    ForEach(comics, id: \.id) {comic in
                        SmallComicItemView(comic: comic)}
                }
            }.frame(height: 183)
        }
    }
}

struct SmallComicItemView: View {
    var comic: KomiicAPI.ComicData
    @State private var openDetailPage = false
    var body: some View {
        if #available(iOS 16.0, *) {
            VStack {
                ImageView(withURL: comic.imageUrl)
                NavigationLink(destination: ComicDetailView(comicData: comic), isActive: $openDetailPage )
                {EmptyView()}.frame(width: 0, height: 0)
            }.onTapGesture {
                openDetailPage = true
            }.contextMenu {} preview: {
                ComicDetailView(comicData: comic)
            }
        } else {
            VStack {
                ImageView(withURL: comic.imageUrl)
                NavigationLink(destination: ComicDetailView(comicData: comic), isActive: $openDetailPage )
                {EmptyView()}.frame(width: 0, height: 0)
            }.onTapGesture {
                openDetailPage = true
            }
        }
        
    }
}


