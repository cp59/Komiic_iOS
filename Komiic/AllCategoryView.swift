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
    @State private var categoryId: [String] = []
    @State private var status: String
    @State private var showFilterSheet: Bool = false
    init(categoryId: [String] = [], status: String = "") {
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
                        loadState = .loaded
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
            ComicListView(listType: .allComics, orderBy: $sort, status: $status, categoryId: $categoryId).toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button(action: {
                        showFilterSheet = true
                    }) {
                        Image(systemName: "line.3.horizontal.decrease.circle")
                    }
                }
            }.sheet(isPresented: $showFilterSheet) {
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
                        Text("分類 （可多選）").font(.footnote).foregroundStyle(.secondary)
                        LazyVGrid(columns: [GridItem(.adaptive(minimum: 60))], spacing: 5) {
                            if categoryId.isEmpty {
                                Button(action: {}) {
                                    Text("全部").foregroundStyle(.onAccent)
                                }.buttonStyle(.borderedProminent)
                            } else {
                                Button(action: {
                                    categoryId.removeAll()
                                }) {
                                    Text("全部")
                                }.buttonStyle(.bordered)
                            }
                            ForEach(categoryList, id: \.id) { category in
                                if categoryId.contains(category.id) {
                                    Button(action: {
                                        categoryId.remove(at: categoryId.firstIndex(of: category.id)!)
                                    }) {
                                        Text(category.name).foregroundStyle(.onAccent)
                                    }.buttonStyle(.borderedProminent)
                                } else {
                                    Button(action: {
                                        categoryId.append(category.id)
                                    }) {
                                        Text(category.name)
                                    }.buttonStyle(.bordered)
                                }
                            }
                        }
                    }.padding().presentationDetents([.medium, .large])
                }
            }
        }
    }
}
