//
//  ComicListView.swift
//  Komiic
//
//  Created by 梁承樸 on 2024/3/10.
//

import SwiftUI
import Kingfisher

struct ComicListView: View {
    @EnvironmentObject var app: app
    var title:String
    let requestParameters:String
    var listType: Int = 0
    @State private var lastComic = false
    @State private var comics: [KomiicAPI.ComicData] = []
    @State private var isLoading = false
    @State private var currentPage = -1
    @State private var startOfflineReading = false
    @Binding var refreshList:Int
    @State private var selectedComic: KomiicAPI.ComicData?
    @Namespace var animation
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
        } else if (listType == 5) {
            do {
                let directoryContents = try FileManager.default.contentsOfDirectory(at: app.docURL, includingPropertiesForKeys: nil)
                let comicFolders = directoryContents.filter{$0.lastPathComponent != ".Trash"}
                var tempComicList:[KomiicAPI.ComicData] = []
                for folder in comicFolders {
                    do {
                        try tempComicList.append(KomiicAPI.ComicData(id: folder.lastPathComponent, title: String(contentsOf: folder.appendingPathComponent("comicTitle.txt"), encoding: .utf8), status: "", year: 0, imageUrl: folder.appendingPathComponent("cover.jpg").path, authors: [], categories: [], dateUpdated: "", monthViews: 0, views: 0, favoriteCount: 0, lastBookUpdate: "", lastChapterUpdate: ""))
                    } catch {
                        
                    }
                }
                comics = tempComicList
                isLoading = false
                lastComic = true
            } catch {
                print(error)
            }
        }
    }
    var body: some View {
        ZStack {
            ScrollView {
                if (selectedComic != nil && listType != 5) {
                    Spacer().frame(height: 100)
                }
                LazyVGrid (columns: [GridItem(.adaptive(minimum: 160))]) {
                    ForEach(comics, id: \.id) {comic in
                        ComicItemView(comic: comic, loadLocalImage: listType == 5, animation: animation).onAppear {
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
                        }.onTapGesture {
                            selectedComic = comic
                            if (listType == 5) {
                                startOfflineReading = true
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
            }.fullScreenCover(isPresented: $startOfflineReading, content: {
                ReaderView(comicId: selectedComic!.id, isPresented: $startOfflineReading, offlineResource: true)
            })
            .padding(EdgeInsets(top: 5, leading: 0, bottom: 0, trailing: 0))
            .onChange(of: refreshList) { _ in
                isLoading = true
                lastComic = false
                comics.removeAll()
                currentPage = 0
                fetchData()
            }
            if (selectedComic != nil && listType != 5) {
                ComicDetailView(comicData: selectedComic!, animation: animation).overlay(alignment: .topTrailing) {
                    ExitButtonView().onTapGesture {
                        selectedComic = nil
                    }.frame(width: 20,height: 20).padding(30)
                }.frame(height: UIScreen.main.bounds.height).background {
                    Color(.black).opacity(0.6).frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height).onTapGesture {
                        selectedComic = nil
                    }
                }
            }
        }.animation(.interpolatingSpring(duration: 0.35,bounce: 0.25 ), value: selectedComic != nil).navigationBarHidden(selectedComic != nil && listType != 5).navigationTitle(title)
            
    }
}

struct ComicItemView: View {
    var comic: KomiicAPI.ComicData
    var loadLocalImage = false
    @State private var openDetailPage = false
    let animation: Namespace.ID
    var body: some View {
        VStack {
            ZStack {
                Color(.secondarySystemBackground).frame(width: 160, height: 213).matchedGeometryEffect(id: "comicBackground_\(comic.id)", in: animation).cornerRadius(10)
                if (!loadLocalImage) {
                    KFImage(URL(string: comic.imageUrl))
                        .diskCacheExpiration(.expired)
                        .placeholder { _ in
                            VStack {
                                Spacer()
                                ProgressView()
                                Spacer()
                            }.frame(width: 160, height: 213).background(Color(UIColor.darkGray)).cornerRadius(10).padding(10)
                        }
                        .resizable()
                        .cancelOnDisappear(true)
                        .cornerRadius(14)
                        .matchedGeometryEffect(id: "comicImage_\(comic.id)", in: animation)
                        .scaledToFit()
                        .frame(width: 160, height: 213)
                } else {
                    KFImage(source: .provider(LocalFileImageDataProvider(fileURL: URL(fileURLWithPath: comic.imageUrl))))
                        .diskCacheExpiration(.expired)
                        .placeholder { _ in
                            VStack {
                                Spacer()
                                ProgressView()
                                Spacer()
                            }.frame(width: 160, height: 213).background(Color(UIColor.darkGray)).cornerRadius(10).padding(10)
                        }
                        .resizable()
                        .cancelOnDisappear(true)
                        .cornerRadius(14)
                        .matchedGeometryEffect(id: "comicImage_\(comic.id)", in: animation)
                        .scaledToFit()
                        .frame(width: 160, height: 213)
                }
            }
            Text(comic.title).font(.headline).truncationMode(.tail).lineLimit(1).frame(width: 160,alignment: .leading)
            if (!loadLocalImage) {
                Text("\(comic.views)次點閱").font(.footnote).frame(width: 160,alignment: .leading)
            }
            Spacer()
        }
    }
}


