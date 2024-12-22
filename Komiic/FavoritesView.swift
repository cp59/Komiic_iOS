//
//  FavoritesView.swift
//  Komiic
//
//  Created by 梁承樸 on 2024/12/22.
//

import KomiicAPI
import SwiftUI

struct FavoritesView: View {
    let namespace: Namespace.ID
    @State private var loadState: LoadState = .loading
    @State private var categoryList: [KomiicAPI.AllCategoryQuery.Data.AllCategory] = []
    private let sortList: [OrderBy: String] = [.comicDateUpdated: "更新", .favoriteAdded: "加入"]
    private let statusList: [String: String] = ["": "全部", "ONGOING": "連載", "END": "完結"]
    private let readProgressList: [ReadProgressType: String] = [.all: "全部", .unread: "未讀", .started: "未讀完", .completed: "已讀完"]
    @State private var sort: OrderBy = .comicDateUpdated
    @State private var status: String = ""
    @State private var readProgress: ReadProgressType = .all
    @State private var showFilterSheet: Bool = false
    var body: some View {
        ComicListView(listType: .favoriteComics, orderBy: $sort, status: $status, readProgressType: $readProgress).toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button(action: {
                    showFilterSheet = true
                }) {
                    Image(systemName: "line.3.horizontal.decrease.circle")
                }
            }
        }.navigationTransition(.zoom(sourceID: "favorites", in: namespace)).sheet(isPresented: $showFilterSheet) {
            ScrollView {
                VStack(alignment: .leading) {
                    Text("排序方式").font(.footnote).foregroundStyle(.secondary)
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 5), count: 3), spacing: 5) {
                        ForEach(Array(sortList.keys), id: \.self) { key in
                            if sort == key {
                                Button(action: {}) {
                                    Text(sortList[key]!).frame(maxWidth: .infinity).foregroundStyle(.onAccent)
                                }.buttonStyle(.borderedProminent)
                            } else {
                                Button(action: {
                                    sort = key
                                }) {
                                    Text(sortList[key]!).frame(maxWidth: .infinity)
                                }.buttonStyle(.bordered)
                            }
                        }
                    }
                    Spacer().frame(height: 10)
                    Text("狀態").font(.footnote).foregroundStyle(.secondary)
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 5), count: 3), spacing: 5) {
                        ForEach(Array(statusList.keys), id: \.self) { key in
                            if status == key {
                                Button(action: {}) {
                                    Text(statusList[key]!).frame(maxWidth: .infinity).foregroundStyle(.onAccent)
                                }.buttonStyle(.borderedProminent)
                            } else {
                                Button(action: {
                                    status = key
                                }) {
                                    Text(statusList[key]!).frame(maxWidth: .infinity)
                                }.buttonStyle(.bordered)
                            }
                        }
                    }
                    Spacer().frame(height: 10)
                    Text("閱讀進度").font(.footnote).foregroundStyle(.secondary)
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 5), count: 3), spacing: 5) {
                        ForEach(Array(readProgressList.keys), id: \.self) { key in
                            if readProgress == key {
                                Button(action: {}) {
                                    Text(readProgressList[key]!).frame(maxWidth: .infinity).foregroundStyle(.onAccent)
                                }.buttonStyle(.borderedProminent)
                            } else {
                                Button(action: {
                                    readProgress = key
                                }) {
                                    Text(readProgressList[key]!).frame(maxWidth: .infinity)
                                }.buttonStyle(.bordered)
                            }
                        }
                    }
                }.padding().presentationDetents([.medium, .large])
            }
        }
    }
}
