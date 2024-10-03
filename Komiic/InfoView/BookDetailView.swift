//
//  BookDetailView.swift
//  Komiic
//
//  Created by 梁承樸 on 2024/8/11.
//

import DominantColors
import Kingfisher
import KomiicAPI
import SwiftUI

struct BookDetailView: View {
    @EnvironmentObject var appEnv: AppEnvironment
    @Namespace var readNamespace
    let namespace: Namespace.ID
    @State private var startReading = false
    @State private var showAddToFolderSheet = false
    let comic: ComicFrag
    var body: some View {
        VStack {
            KFImage(URL(string: comic.imageUrl))
                .resizable()
                .placeholder {
                    Color.gray.frame(width: 240, height: 320).cornerRadius(6).redacted(reason: .placeholder)
                }
                .cancelOnDisappear(true)
                .fade(duration: 0.25)
                .navigationTransition(.zoom(sourceID: comic.id, in: namespace))
                .matchedTransitionSource(id: "cover", in: readNamespace)
                .frame(width: 240, height: 320)
                .cornerRadius(8)
                .padding()
                .shadow(radius: 5)
                .scaledToFit()
            Spacer().frame(height: 20)
            Text(comic.title).font(.title2).bold().contextMenu {
                Button(action: {
                    UIPasteboard.general.string = comic.title
                }) {
                    Label("複製名稱", systemImage: "doc.on.doc")
                }
                Link(destination: URL(string: "https://www.google.com/search?q=" + comic.title)!, label: { Label("Google查詢", systemImage: "magnifyingglass") })
            }.multilineTextAlignment(.center)
            Spacer().frame(height: 10)
            if comic.authors.count == 1 {
                NavigationLink {
                    ComicListView(listType: .authorComics, args: "\(comic.authors.first!!.id)").navigationTitle(comic.authors.first!!.name).navigationBarTitleDisplayMode(.large)
                } label: {
                    HStack {
                        Text(comic.authors.map(\.self!.name).joined(separator: " 和 ")).foregroundColor(.secondary).font(.subheadline)
                        Image(systemName: "chevron.right").foregroundColor(Color.gray).bold().font(.subheadline)
                    }
                }
            } else {
                Menu {
                    ForEach(comic.authors.compactMap { $0! }, id: \.id) { author in
                        NavigationLink {
                            ComicListView(listType: .authorComics, args: "\(author.id)").navigationTitle(author.name).navigationBarTitleDisplayMode(.large)
                        } label: {
                            HStack {
                                Text(author.name)
                            }
                        }
                    }
                } label: {
                    HStack {
                        Text(comic.authors.map(\.self!.name).joined(separator: " 和 ")).foregroundColor(.secondary).font(.subheadline)
                        Image(systemName: "chevron.right").foregroundColor(Color.gray).bold().font(.subheadline)
                    }
                }
            }
            Spacer().frame(height: 20)
            Button(action: {
                startReading = true
            }) {
                Text("開始閱讀").font(.title3).frame(maxWidth: .infinity)
            }.buttonStyle(.borderedProminent).controlSize(.large)
            Spacer().frame(height: 20)
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(alignment: .center, spacing: 10) {
                    VStack {
                        Text("狀態").font(.caption)
                        Text(comic.status == "ONGOING" ? "連載中" : "已完結").foregroundStyle(.white).font(.system(size: 16)).padding(4).background(.blue).cornerRadius(6)
                    }.padding(.horizontal, 5)
                    Divider()
                    VStack {
                        Text("年份").font(.caption)
                        Text(String(comic.year)).font(.system(size: 20)).bold().padding(1)
                    }.padding(.horizontal, 5)
                    Divider()
                    VStack {
                        Text("點閱").font(.caption)
                        Text(String(comic.views!)).font(.system(size: 20)).bold().padding(1)
                    }.padding(.horizontal, 5)
                    Divider()
                    if comic.categories.count < 2 {
                        NavigationLink {
                            AllCategoryView(categoryId: comic.categories.first!!.id).navigationTitle(comic.categories.first!!.name).navigationBarTitleDisplayMode(.large)
                        } label: {
                            VStack {
                                Text("類型").font(.caption).foregroundColor(.primary)
                                Text(comic.categories.map(\.self!.name).joined(separator: " 和 ")).font(.system(size: 20)).bold().padding(1).foregroundColor(.primary)
                            }.padding(.horizontal, 5)
                        }
                    } else {
                        Menu {
                            ForEach(comic.categories.compactMap{$0!}, id: \.id) { category in
                                NavigationLink {
                                    AllCategoryView(categoryId: category.id).navigationTitle(category.name).navigationBarTitleDisplayMode(.large)
                                } label: {
                                    Text(category.name)
                                }
                            }
                        } label: {
                            VStack {
                                Text("類型").font(.caption).foregroundColor(.primary)
                                Text(comic.categories.map(\.self!.name).joined(separator: " 和 ")).font(.system(size: 20)).bold().padding(1).foregroundColor(.primary)
                            }.padding(.horizontal, 5)
                        }
                    }
                    Divider()
                    VStack {
                        Text("更新").font(.caption)
                        Text(ISO8601DateFormatter().date(from: comic.dateUpdated!)!.timeAgoDisplay()).font(.system(size: 20)).bold().padding(1)
                    }.padding(.horizontal, 5)
                    Spacer().frame(width: 10)
                }
            }.frame(height: 60)
            Spacer()
        }.padding().fullScreenCover(isPresented: $startReading) {
            ReaderView(comicId: comic.id).navigationTransition(.zoom(sourceID: "cover", in: readNamespace))
        }.toolbar {
            ToolbarItemGroup(placement: .navigationBarTrailing) {
                Menu {
                    ShareLink(item: URL(string: "https://komiic.com/comic/\(comic.id)")!) {
                        Label("分享書籍", systemImage: "square.and.arrow.up")
                    }
                    if appEnv.isLogin {
                        Divider()
                        Button {
                            showAddToFolderSheet = true
                        } label: {
                            Label("加入書櫃", systemImage: "plus.rectangle.on.folder")
                        }
                    }
                } label: {
                    Label("Add", systemImage: "ellipsis.circle")
                }
            }
        }.sheet(isPresented: $showAddToFolderSheet, content: {
            AddToFolderSheet(comicId: comic.id)
        })
    }
}
