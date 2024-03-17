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
    private let isLogin = !(KeychainSwift().get("token") ?? "").isEmpty
    var body: some View {
        NavigationView {
            VStack {
                GeometryReader {proxy in
                    HStack{}.onAppear{viewWidth=(proxy.size.width-32.0)/2}}.frame(height: 0)
                if (isSearching) {
                    ComicListView(title: "", requestParameters: KomiicAPI.RequestParameters().searchComic(keyword: searchText), listType: 1, refreshList: $refreshSearch)
                } else if (!isSearching){
                    ScrollView {
                        Spacer().frame(height: 20)
                        SmallComicListView(title: "最近更新", requestParameters: KomiicAPI.RequestParameters().getRecentUpdate())
                        SmallComicListView(title: "本月最夯", requestParameters: KomiicAPI.RequestParameters().getMonthHotComics())
                        SmallComicListView(title: "歷年熱門", requestParameters: KomiicAPI.RequestParameters().getHotComics())
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
                    }
                    
                }
            }   .navigationTitle("書店")
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
