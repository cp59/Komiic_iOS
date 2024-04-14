//
//  ComicContextMenuPreview.swift
//  Komiic
//
//  Created by 梁承樸 on 2024/4/14.
//

import SwiftUI
import Kingfisher

struct ComicContextMenuPreview: View {
    var comicData:KomiicAPI.ComicData
    @State private var authorsText = ""
    @State private var categoriesText = ""
    var body: some View {
        VStack {
            KFImage(URL(string: comicData.imageUrl))
                .diskCacheExpiration(.expired)
                .placeholder { _ in
                    VStack {
                        Spacer()
                        ProgressView()
                        Spacer()
                    }.frame(width: 233, height: 350).background(Color(UIColor.darkGray)).cornerRadius(10).padding(10)
                }
                .resizable()
                .cornerRadius(14)
                .scaledToFit()
                .frame(width: 233, height: 350)
            Text(comicData.title).font(.title2).bold()
            Spacer().frame(height: 10)
            Text(authorsText).font(.headline).onFirstAppear {
                for (index,author) in comicData.authors.enumerated() {
                    if (index != 0) {
                        authorsText += " 與 "
                    }
                    authorsText += author.name
                }
            }
            Spacer().frame(height: 20)
            Divider()
            Spacer().frame(height: 20)
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(alignment: .center, spacing: 10) {
                    Spacer().frame(width: 10)
                    VStack {
                        Text("狀態").font(.caption)
                        if (comicData.status == "ONGOING") {
                            Text("連載中").font(.system(size: 16)).padding(4).background(.blue).cornerRadius(6)
                        } else if (comicData.status == "END") {
                            Text("已完結").font(.system(size: 16)).padding(4).background(.gray).cornerRadius(6)
                        }
                        
                    }
                    Divider()
                    VStack {
                        Text("年份").font(.caption)
                        Text(String(comicData.year)).font(.system(size: 20)).bold().padding(1)
                    }
                    Divider()
                    VStack {
                        Text("點閱").font(.caption)
                        Text(String(comicData.views)).font(.system(size: 20)).bold().padding(1)
                    }
                    Divider()
                    VStack {
                        Text("類型").font(.caption)
                        Text(categoriesText).font(.system(size: 20)).bold().padding(1).onAppear {
                            if  (categoriesText == "") {
                                for (index,category) in comicData.categories.enumerated() {
                                    if (index != 0) {
                                        categoriesText += " & "
                                    }
                                    categoriesText += category.name
                                }
                            }
                        }
                    }
                    Divider()
                    VStack {
                        Text("更新").font(.caption)
                        Text(ISO8601DateFormatter().date(from: comicData.dateUpdated)!.timeAgoDisplay()).font(.system(size: 20)).bold().padding(1)
                    }
                    Spacer().frame(width: 10)
                }
            }.frame(height: 60)
            Spacer().frame(height: 20)
        }.frame(idealWidth: 400)
    }
}
