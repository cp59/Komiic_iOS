//
//  ComicDetailView.swift
//  Komiic
//
//  Created by 梁承樸 on 2024/3/10.
//

import SwiftUI
import Kingfisher

struct ComicDetailView: View {
    @EnvironmentObject var app:AppEnvironment
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
    @State private var showAddToFolderSheet = false
    @State private var showDownloadView = false
    @State private var showMessagesView = false
    var body: some View {
        NavigationLink(destination:
                        AuthorView(selectedAuthor: selectedAuthor)
                       , isActive: $openAuthorPage ){EmptyView()}
        NavigationLink(destination:
                        CategoryView(selectedCategory: selectedCategory)
                       , isActive: $openCategoryPage ){EmptyView()}
        ScrollView {
            LazyVStack {
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
                    .padding(EdgeInsets(top: -90, leading: 0, bottom: -10, trailing: 0))
                Text(comicData.title).font(.title2).bold()
                Spacer().frame(height: 10)
                Button {
                    if (comicData.authors.count == 1) {
                        selectedAuthor = comicData.authors.first!
                        openAuthorPage = true
                    } else {
                        isShowingAuthorPickDialog.toggle()
                    }
                }label: {Text(authorsText).font(.headline).onFirstAppear {
                    for (index,author) in comicData.authors.enumerated() {
                        if (index != 0) {
                            authorsText += " 與 "
                        }
                        authorsText += author.name
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
                Spacer().frame(height: 20)
                HStack {
                    Button(action: {
                        startReading = true
                    }) {
                        Label("開始閱讀", systemImage: "book.pages").font(.title3).frame(maxWidth: .infinity)
                    }.buttonStyle(.borderedProminent).controlSize(.large).fullScreenCover(isPresented: $startReading, content: {
                        ReaderView(comicId: comicData.id, isPresented: $startReading).ignoresSafeArea()
                    })
                    Menu {
                        if #available(iOS 16.0, *) {
                            ShareLink(item: URL(string: "https://komiic.com/comic/\(comicData.id)")!)
                        } else {
                            Button {
                                let AV = UIActivityViewController(activityItems: ["https://komiic.com/comic/\(comicData.id)"], applicationActivities: nil)
                                let activeScene = UIApplication.shared.connectedScenes.first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene
                                let rootViewController = (activeScene?.windows ?? []).first(where: { $0.isKeyWindow })?.rootViewController
                                // for iPad. if condition is optional.
                                if UIDevice.current.userInterfaceIdiom == .pad{
                                    AV.popoverPresentationController?.sourceView = rootViewController?.view
                                    AV.popoverPresentationController?.sourceRect = .zero
                                }
                                rootViewController?.present(AV, animated: true, completion: nil)
                            } label: {
                                Label("分享", systemImage: "square.and.arrow.up")
                            }
                        }
                        Divider()
                        Button {
                            showAddToFolderSheet = true
                        } label: {
                            Label("加入書櫃", systemImage: "plus.rectangle.on.folder")
                        }
                        Button {
                            showDownloadView = true
                        } label: {
                            Label("下載離線漫畫", systemImage: "arrow.down.circle")
                        }
                        Button {
                            showMessagesView = true
                        } label: {
                            Label("顯示留言 (Beta)", systemImage: "message")
                        }
                    } label: {
                        Image(systemName: "ellipsis.circle.fill").font(.title3).frame(maxHeight: .infinity).padding(EdgeInsets(top: 0, leading: 10, bottom: 0, trailing: 10))
                    }.buttonStyle(.bordered).sheet(isPresented: $showAddToFolderSheet, content: {
                        AddToFolderSheet(isPresented: $showAddToFolderSheet, comicId: comicData.id)
                    }).sheet(isPresented: $showMessagesView, content: {
                        ComicMessagesView(isPresented: $showMessagesView, comicId: comicData.id)
                    }).sheet(isPresented: $showDownloadView, content: {
                        ComicDownloadView(comic: comicData)
                    })
                }
                Spacer().frame(height: 20)
                Divider()
                Spacer().frame(height: 20)
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(alignment: .center, spacing: 10) {
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
                ForEach(comicData.authors, id: \.id) { author in
                    Spacer().frame(height: 10)
                    SmallComicListView(listType: 1, title: "所有 \(author.name) 的漫畫", requestParameters: KomiicAPI.RequestParameters().getComicsByAuthorId(authorId: author.id))
                }
                Spacer().frame(height: 20)
                Divider()
                Spacer().frame(height: 10)
                SmallComicListView(listType: 6, title: "其他人還看了", requestParameters: comicData.id)
                Spacer()
            }.padding(20)
        }
    }
}


