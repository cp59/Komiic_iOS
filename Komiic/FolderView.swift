//
//  FolderView.swift
//  Komiic
//
//  Created by 梁承樸 on 2024/9/8.
//

import AlertToast
import KomiicAPI
import SwiftUI

struct FolderView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var appEnv: AppEnvironment
    let namespace: Namespace.ID
    let folder: KomiicAPI.FolderFrag
    private let sortList: [OrderBy: String] = [.dateUpdated: "更新", .dateCreated: "加入"]
    private let statusList: [String: String] = ["": "全部", "ONGOING": "連載", "END": "完結"]
    @State private var sort: OrderBy = .dateUpdated
    @State private var status: String = ""
    @State private var showRenameAlert = false
    @State private var folderName: String = ""
    @State private var displayFolderName: String = ""
    @State private var showDeleteAlert = false
    @State private var deleteCheckText: String = ""
    @State private var showSuccessDeleteAlert = false
    @State private var showFilterSheet: Bool = false
    var body: some View {
        ComicListView(listType: .folderComic , args: folder.id, orderBy: $sort, status: $status).navigationTitle(displayFolderName).navigationBarTitleDisplayMode(.large).navigationTransition(.zoom(sourceID: "folder_\(folder.id)", in: namespace)).navigationTitle(folderName).toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button(action: {
                    showFilterSheet = true
                }) {
                    Image(systemName: "line.3.horizontal.decrease.circle")
                }
            }
            ToolbarItemGroup(placement: .navigationBarTrailing) {
                Menu {
                    ShareLink(item: URL(string: "https://komiic.com/folder/\(folder.key)")!) {
                        Label("分享書櫃", systemImage: "square.and.arrow.up")
                    }
                    Divider()
                    Button(action: {
                        folderName = displayFolderName
                        showRenameAlert.toggle()
                    }) {
                        Label("重新命名書櫃", systemImage: "pencil")
                    }
                    Button(role: .destructive, action: {
                        deleteCheckText = ""
                        showDeleteAlert.toggle()
                    }) {
                        Label("刪除書櫃", systemImage: "trash")
                    }
                } label: {
                    Label("Add", systemImage: "ellipsis.circle")
                }
            }
        }.alert("重新命名書櫃", isPresented: $showRenameAlert, actions: {
            TextField("書櫃名稱", text: $folderName)
            Button("完成", action: {
                APIManager.shared.apolloClient.perform(mutation: UpdateFolderNameMutation(folderId: folder.id, name: folderName)) { result in
                    switch result {
                    case .success:
                        displayFolderName = folderName
                    case .failure:
                        print("failed")
                    }
                }
            })
            Button("取消", role: .cancel, action: { folderName = folder.name })
        }).alert("永久刪除書櫃？", isPresented: $showDeleteAlert, actions: {
            TextField("輸入「YES」來確認刪除", text: $deleteCheckText)
            Button("刪除", role: .destructive, action: {
                APIManager.shared.apolloClient.perform(mutation: RemoveFolderMutation(folderId: folder.id))
                showSuccessDeleteAlert.toggle()
            }).disabled(deleteCheckText != "YES")
            Button("取消", role: .cancel, action: {})
        }, message: { Text("刪除後將無法恢復，若要刪除請在下方輸入「YES」來執行") }).toast(isPresenting: $showSuccessDeleteAlert, duration: 2, tapToDismiss: true, alert: {
            AlertToast(type: .complete(.green), title: "已刪除", subTitle: "")
        }, onTap: {}, completion: { dismiss() }).onFirstAppear {
            displayFolderName = folder.name
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
                }.padding().presentationDetents([.medium, .large])
            }
        }
    }
}
