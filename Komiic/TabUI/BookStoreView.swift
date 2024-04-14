//
//  BookStoreView.swift
//  Komiic
//
//  Created by 梁承樸 on 2024/3/11.
//

import SwiftUI
import KeychainSwift
struct BookStoreView: View {
    @State var searchText = ""
    @State var refreshSearch = 0
    @State var isSearching = false
    @State var viewWidth = CGFloat(0)
    var body: some View {
        NavigationView {
            VStack {
                GeometryReader {proxy in
                    HStack{}.onChange(of: proxy.size.width){_ in viewWidth=(proxy.size.width-32.0)/2}.onAppear {viewWidth=(proxy.size.width-32.0)/2}}.frame(height: 0)
                if (isSearching) {
                    ComicListView(title: "", requestParameters: KomiicAPI.RequestParameters().searchComic(keyword: searchText), listType: 1, refreshList: $refreshSearch)
                } else if (!isSearching){
                    ScrollView {
                        VStack {
                            SmallComicListView(title: "最近更新", requestParameters: KomiicAPI.RequestParameters().getRecentUpdate())
                            Divider()
                            SmallComicListView(title: "本月最夯", requestParameters: KomiicAPI.RequestParameters().getMonthHotComics())
                            Divider()
                            SmallComicListView(title: "歷年熱門", requestParameters: KomiicAPI.RequestParameters().getHotComics())
                            Divider()
                            HStack {
                                NavigationLink(destination: AllCategoryView()) {
                                    HStack {
                                        Text("所有漫畫").foregroundStyle(.blue)
                                        Spacer()
                                        Image(systemName: "books.vertical").font(.system(size: 40))
                                    }.frame(height: 70).padding(2)
                                }.frame(width: viewWidth).buttonStyle(.bordered)
                            }
                            Spacer()
                        }.padding(EdgeInsets(top: 0, leading: 20, bottom: 20, trailing: 10))
                    }
                    
                }
            }
            .navigationTitle("書店")
            .searchable(text: $searchText, prompt: "搜尋漫畫").onSubmit (of: .search){
                refreshSearch += 1
            }.onChange(of: searchText) {value in
                    isSearching = !value.isEmpty}
            
        }.navigationViewStyle(StackNavigationViewStyle())
    }
}

#Preview {
    BookStoreView()
}
