//
//  FavoritesComicView.swift
//  Komiic
//
//  Created by 梁承樸 on 2024/3/19.
//

import SwiftUI

struct FavoritesComicView: View {
    private let orderList:[String: String] = ["COMIC_DATE_UPDATED":"更新", "FAVORITE_ADDED":"加入"]
    private let statusList:[String: String] = ["":"全部", "ONGOING":"連載", "END":"完結"]
    private let readProgressList:[String: String] = ["ALL":"全部", "UNREAD":"未讀", "STARTED":"未讀完", "COMPLETED":"已讀完"]
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
                            ForEach (Array(orderList.keys), id: \.self) {key in
                                Text(orderList[key]!).tag(key)
                            }
                        }
                    } label: {
                        Button(action: {}) {
                            Text("排序方式")
                            Text(orderList[orderBy]!)
                            Image(systemName: "arrow.up.arrow.down")
                        }
                    }.onChange(of: orderBy) { _ in
                        refreshList+=1}
                    Menu {
                        Picker(selection: $status, label: Label("狀態", systemImage: "arrow.up.arrow.down")) {
                            ForEach (Array(statusList.keys), id: \.self) {key in
                                Text(statusList[key]!).tag(key)
                            }
                        }
                    } label: {
                        Button(action: {}) {
                            Text("狀態")
                            Text(statusList[status]!)
                            Image(systemName: "checkmark.square")
                        }
                    }.onChange(of: status) { _ in
                        refreshList+=1}
                    Menu {
                        Picker(selection: $readProgress, label: Label("狀態", systemImage: "arrow.up.arrow.down")) {
                            ForEach (Array(readProgressList.keys), id: \.self) {key in
                                Text(readProgressList[key]!).tag(key)
                            }
                        }
                    } label: {
                        Button(action: {}) {
                            Text("狀態")
                            Text(readProgressList[readProgress]!)
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
