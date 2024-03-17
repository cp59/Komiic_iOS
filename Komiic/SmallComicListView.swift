//
//  ComicListView.swift
//  Komiic
//
//  Created by 梁承樸 on 2024/3/10.
//

import SwiftUI

struct SmallComicListView: View {
    private let komiicApi = KomiicAPI()
    @State var comics: [KomiicAPI.ComicData] = []
    @State var isInit = false
    @State var refreshList = 0
    let title:String
    let requestParameters:String
    var body: some View {
        HStack {
            Text(title).font(.title2).bold()
            Spacer()
            NavigationLink(destination: ComicListView(title: title, requestParameters: requestParameters, refreshList: $refreshList), label: {
                Text("查看全部")
            })
        }.padding(EdgeInsets(top: -15, leading: 20, bottom: -15, trailing: 20))
        ScrollView (.horizontal, showsIndicators: false){
            LazyHStack {
                Spacer().frame(width: 20)
                ForEach(comics, id: \.id) {comic in
                    SmallComicItemView(comic: comic)}
            }
        }.frame(height: 240)
        .onAppear{
            if (!isInit) {
                komiicApi.fetchList(parameters: requestParameters,completion: {comicsResp in
                    comics.append(contentsOf: comicsResp)
                    isInit = true})
            }
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
                    .scaleEffect(1.8)
                    .padding(EdgeInsets(top: 35, leading: 10, bottom: 35, trailing: 20))
                    .cornerRadius(12)
                Text(comic.title).truncationMode(.tail).lineLimit(1).frame(width: 130)
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
                    .scaleEffect(1.8)
                    .padding(EdgeInsets(top: 35, leading: 10, bottom: 35, trailing: 20))
                    .cornerRadius(12)
                Text(comic.title).truncationMode(.tail).lineLimit(1).frame(width: 130)
                NavigationLink(destination: ComicDetailView(comicData: comic), isActive: $openDetailPage )
                {EmptyView()}.frame(width: 0, height: 0)
            }.onTapGesture {
                openDetailPage = true
            }
        }
        
    }
}


