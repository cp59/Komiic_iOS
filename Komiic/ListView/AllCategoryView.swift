//
//  AllCategoryView.swift
//  Komiic
//
//  Created by 梁承樸 on 2024/3/16.
//

import SwiftUI

struct AllCategoryView: View {
    private let komiicApi = KomiicAPI()
    @State private var refreshList = 0
    @State private var isLoading = true
    @State private var showingCategoryPicker = false
    @State private var sort: String = "DATE_UPDATED"
    @State private var categoryId = "0"
    @State private var status:String = ""
    @State private var categoryList:[KomiicAPI.ComicCategories] = []
    var body: some View {
        VStack {
            if (isLoading) {
                ProgressView().scaleEffect(2)
            } else {
                ComicListView(title: "所有漫畫", requestParameters: KomiicAPI.RequestParameters().getComicsByCategory(categoryId: categoryId, orderBy: sort, status: status), refreshList: $refreshList).toolbar {
                    ToolbarItem(placement: .primaryAction) {
                        Menu {
                            Menu {
                                Picker(selection: $sort, label: Label("排序方式", systemImage: "arrow.up.arrow.down")) {
                                    Text("更新").tag("DATE_UPDATED")
                                    Text("觀看數").tag("VIEWS")
                                    Text("喜愛數").tag("FAVORITE_COUNT")
                                }
                            } label: {
                                Button(action: {}) {
                                    Text("排序方式")
                                    if (sort == "DATE_UPDATED") {
                                        Text("更新")
                                    } else if (sort == "VIEWS") {
                                        Text("觀看數")
                                    } else if (sort == "FAVORITE_COUNT") {
                                        Text("喜愛數")
                                    }
                                    Image(systemName: "arrow.up.arrow.down")
                                }
                            }.onChange(of: sort) { _ in
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
                                Picker(selection: $categoryId, label: Label("分類", systemImage: "list.bullet")) {
                                    ForEach(categoryList, id: \.id) { category in
                                        Text(category.name).tag(category.id)
                                    }
                                }
                            } label: {
                                Button(action: {}) {
                                    Text("分類")
                                    Text(categoryList.filter{(x) -> Bool in x.id == categoryId}.first!.name)
                                    Image(systemName: "square.grid.2x2")
                                }
                            }
                            .onChange(of: categoryId) { _ in
                                refreshList+=1}
                        }
                        label: {
                            Label("Sort", systemImage: "line.3.horizontal.decrease.circle")
                        }
                    }
                }
            }
        }.navigationTitle("所有漫畫").onAppear {
            komiicApi.fetchCategoryList(completion: {resp in categoryList = resp
                categoryList.insert(KomiicAPI.ComicCategories(id: "0", name: "全部類型"), at: 0)
            isLoading = false})
        }
    }
}

#Preview {
    AllCategoryView()
}
