//
//  ComicDetailView.swift
//  Komiic
//
//  Created by 梁承樸 on 2024/3/10.
//

import SwiftUI
import Kingfisher

struct ComicDetailView: View {
    private let komiicApi = KomiicAPI()
    var comicData: KomiicAPI.ComicData;
    @State var categoriesText: String = ""
    @State var authorsText: String = ""
    @State var isShowingAuthorPickDialog = false
    @State var isShowingCategoryPickDialog = false
    @State private var openAuthorPage = false
    @State private var openCategoryPage = false
    @State private var selectedAuthor: KomiicAPI.ComicAuthor = KomiicAPI.ComicAuthor(id: "0", name: "")
    @State private var selectedCategory: KomiicAPI.ComicCategories = KomiicAPI.ComicCategories(id: "0", name: "")
    @State private var startReading = false
    var body: some View {
        NavigationLink(destination:
                        AuthorView(selectedAuthor: selectedAuthor)
                       , isActive: $openAuthorPage ){EmptyView()}
        NavigationLink(destination:
                        CategoryView(selectedCategory: selectedCategory)
, isActive: $openCategoryPage )
        {EmptyView()}
        ScrollView {
            KFImage(URL(string: comicData.imageUrl))
                .memoryCacheExpiration(.expired)
                .diskCacheExpiration(.expired)
                .resizable()
                .scaledToFit()
                .frame(height: 350)
                .cornerRadius(14)
                .padding(EdgeInsets(top: -50, leading: 0, bottom: 0, trailing: 0))
            Text(comicData.title).font(.title).bold().multilineTextAlignment(.center).padding(5)
            Spacer().frame(height: 10)
            Button {
                if (comicData.authors.count == 1) {
                    selectedAuthor = comicData.authors.first!
                    openAuthorPage = true
                } else {
                    isShowingAuthorPickDialog.toggle()
                }
            }label: {Text(authorsText).font(.title3).onAppear {
                if (authorsText == "") {
                    for (index,author) in comicData.authors.enumerated() {
                        if (index != 0) {
                            authorsText += " 與 "
                        }
                        authorsText += author.name
                    }
                }
            }
            }.confirmationDialog("選擇作者",
                                 isPresented: $isShowingAuthorPickDialog,
                                 titleVisibility: .visible) {
                ForEach(Array(comicData.authors.enumerated()),id: \.element.id) { index,author in
                    Button(author.name) {
                        selectedAuthor = author
                        openAuthorPage = true
                    }
                }
                Button("取消", role: .cancel) {}
                } message: {
                    Text("點選任一作者名稱來查看他的其他作品")
                }
            HStack {
                Button(action: {
                    startReading = true
                }) {
                    Label("開始閱讀", systemImage: "book.pages").font(.title3).frame(maxWidth: .infinity)
                }.buttonStyle(.borderedProminent).controlSize(.large).fullScreenCover(isPresented: $startReading, content: {
                    ReaderView(comicId: comicData.id, isPresented: $startReading)
                })
            }.padding(10)
            Divider()
            Spacer().frame(height: 20)
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(alignment: .center, spacing: 10) {
                    Spacer()
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
                        }.onTapGesture {
                            if (comicData.categories.count == 1) {
                                selectedCategory = comicData.categories.first!
                                openCategoryPage = true
                            } else {
                                isShowingCategoryPickDialog.toggle()
                            }
                        }.confirmationDialog("選擇類型",
                                             isPresented: $isShowingCategoryPickDialog,
                                             titleVisibility: .visible) {
                            ForEach(Array(comicData.categories.enumerated()),id: \.element.id) { index,category in
                                Button(category.name) {
                                    selectedCategory = category
                                    openCategoryPage = true
                                }
                            }
                            Button("取消", role: .cancel) {}
                            } message: {
                                Text("點選任一類型來查看其他包含此類型的作品")
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
            Divider()
            Spacer()
        }
    }
}


