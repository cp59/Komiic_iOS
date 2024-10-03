//
//  AllCategoryView.swift
//  Komiic
//
//  Created by 梁承樸 on 2024/9/8.
//

import KomiicAPI
import SwiftUI

struct AllCategoryView: View {
    @State private var loadState: LoadState = .loading
    @State private var categoryList: [KomiicAPI.AllCategoryQuery.Data.AllCategory] = []
    private let sortList: [OrderBy: String] = [.dateUpdated: "更新", .views: "觀看數", .favoriteCount: "喜愛數"]
    private let statusList: [String: String] = ["": "全部", "ONGOING": "連載", "END": "完結"]
    @State private var sort: OrderBy = .dateUpdated
    @State private var categoryId: String
    @State private var status: String
    init (categoryId: String = "0", status: String = "") {
        self.categoryId = categoryId
        self.status = status
    }
    var body: some View {
        if loadState == .loading {
            ProgressView().controlSize(.extraLarge).onFirstAppear {
                APIManager.shared.apolloClient.fetch(query: AllCategoryQuery()) { result in
                    switch result {
                    case .success(let response):
                        categoryList.append(contentsOf: response.data!.allCategory.compactMap { $0! })
                        do {
                            categoryList.insert(try KomiicAPI.AllCategoryQuery.Data.AllCategory(data: ["id": "0", "name": "全部", "__typename": "Category"]),at: 0)
                            loadState = .loaded
                        } catch {
                            print(error)
                            loadState = .failed
                        }
                    case .failure(let error):
                        loadState = .failed
                        print(error)
                    }
                }
            }
        } else if loadState == .failed {
            VStack {
                Text("無法載入").font(.title).bold()
                Button(action: {
                    loadState = .loading
                }) {
                    Image(systemName: "arrow.triangle.2.circlepath.circle.fill")
                        .imageScale(.large)
                    Text("重試")
                }
                .buttonStyle(.borderedProminent)
                .buttonBorderShape(.capsule)
            }.frame(height: 210)
        } else {
            ComicListView(listType: .allComics,orderBy: $sort,status: $status, categoryId: $categoryId).toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Menu {
                        Menu {
                            Picker(selection: $sort, label: Label("排序方式", systemImage: "arrow.up.arrow.down")) {
                                ForEach(Array(sortList.keys), id: \.self) { key in
                                    Text(sortList[key]!).tag(key)
                                }
                            }
                        } label: {
                            Button(action: {}) {
                                Text("排序方式")
                                Text(sortList[sort]!)
                                Image(systemName: "arrow.up.arrow.down")
                            }
                        }
                        Menu {
                            Picker(selection: $status, label: Label("狀態", systemImage: "arrow.up.arrow.down")) {
                                ForEach(Array(statusList.keys), id: \.self) { key in
                                    Text(statusList[key]!).tag(key)
                                }
                            }
                        } label: {
                            Button(action: {}) {
                                Text("狀態")
                                Text(statusList[status]!)
                                Image(systemName: "checkmark.square")
                            }
                        }
                        Menu {
                            Picker(selection: $categoryId, label: Label("分類", systemImage: "list.bullet")) {
                                ForEach(categoryList, id: \.id) { category in
                                    Text(category.name).tag(category.id)
                                }
                            }
                        } label: {
                            Button(action: {}) {
                                Text("分類")
                                Text(categoryList.filter { x -> Bool in x.id == categoryId }.first!.name)
                                Image(systemName: "square.grid.2x2")
                            }
                        }
                    }
                    label: {
                        Label("Sort", systemImage: "line.3.horizontal.decrease.circle")
                    }
                }
            }
        }
    }
}
