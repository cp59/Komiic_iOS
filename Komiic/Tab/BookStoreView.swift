//
//  BookStoreView.swift
//  Komiic
//
//  Created by 梁承樸 on 2024/3/11.
//

import SwiftUI

struct BookStoreView: View {
    @EnvironmentObject var appEnv:AppEnvironment
    @Namespace var namespace
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack {
                    SmallComicListView(listType: .recentUpdate,title: "最近更新")
                    Spacer().frame(height: 10)
                    SmallComicListView(listType: .monthHotComic,title: "本月熱門")
                    Spacer().frame(height: 10)
                    SmallComicListView(listType: .hotComic,title: "本站熱門")
                    Divider()
                    NavigationLink(destination: AllCategoryView().navigationTransition(.zoom(sourceID: "allCategory", in: namespace)).navigationTitle("所有漫畫")) {
                        HStack {
                            Text("所有漫畫").bold().font(.title2)
                            Spacer()
                            Image(systemName: "books.vertical").font(.system(size: 40))
                        }.frame(height: 70).padding(2)
                    }.frame(width: 300).buttonStyle(.bordered).matchedTransitionSource(id: "allCategory", in: namespace)
                    Spacer()
                }.padding()
            }.navigationTitle("書店").navigationViewStyle(StackNavigationViewStyle())
        }
    }
}

#Preview {
    BookStoreView()
}
