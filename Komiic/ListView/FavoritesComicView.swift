//
//  FavoritesComicView.swift
//  Komiic
//
//  Created by 梁承樸 on 2024/3/19.
//

import SwiftUI

struct FavoritesComicView: View {
    @State private var orderBy = "COMIC_DATE_UPDATED"
    @State private var status = ""
    @State private var readProgress = "ALL"
    @State private var refreshList = 0
    var body: some View {
        ComicListView(title: "喜愛書籍", requestParameters: KomiicAPI.RequestParameters().getFavoritesComic(orderBy: orderBy, status: status, readProgress: readProgress), listType: 3, refreshList: $refreshList).toolbar {
            ToolbarItem(placement: .primaryAction) {
                Menu {
                    Menu {
                        Picker(selection: $orderBy, label: Label("排序方式", systemImage: "arrow.up.arrow.down")) {
                            Text("更新").tag("COMIC_DATE_UPDATED")
                            Text("加入").tag("FAVORITE_ADDED")
                        }
                    } label: {
                        Button(action: {}) {
                            Text("排序方式")
                            if (orderBy == "COMIC_DATE_UPDATED") {
                                Text("更新")
                            } else if (orderBy == "FAVORITE_ADDED") {
                                Text("加入")
                            }
                            Image(systemName: "arrow.up.arrow.down")
                        }
                    }.onChange(of: orderBy) { _ in
                        refreshList+=1}
                    Menu {
                        Picker(selection: $status, label: Label("狀態", systemImage: "arrow.up.arrow.down")) {
                            Text("全部").tag("")
                            Text("連載").tag("ONGOING")
                            Text("完結").tag("END")
                        }
                    } label: {
                        Button(action: {}) {
                            Text("狀態")
                            if (status == "") {
                                Text("全部")
                            } else if (status == "ONGOING") {
                                Text("連載")
                            } else if (status == "END") {
                                Text("完結")
                            }
                            Image(systemName: "checkmark.square")
                        }
                    }.onChange(of: status) { _ in
                        refreshList+=1}
                    Menu {
                        Picker(selection: $readProgress, label: Label("狀態", systemImage: "arrow.up.arrow.down")) {
                            Text("全部").tag("ALL")
                            Text("未讀").tag("UNREAD")
                            Text("未讀完").tag("STARTED")
                            Text("已讀完").tag("COMPLETED")
                        }
                    } label: {
                        Button(action: {}) {
                            Text("狀態")
                            if (readProgress == "ALL") {
                                Text("全部")
                            } else if (readProgress == "UNREAD") {
                                Text("未讀")
                            } else if (readProgress == "STARTED") {
                                Text("未讀完")
                            } else if (readProgress == "COMPLETED") {
                                Text("已讀完")
                            }
                            Image(systemName: "checkmark.square")
                        }
                    }.onChange(of: readProgress) { _ in
                        refreshList+=1}
                }
                label: {
                    Label("Sort", systemImage: "line.3.horizontal.decrease.circle")
                }
            }
        }
    }
}

#Preview {
    FavoritesComicView()
}
