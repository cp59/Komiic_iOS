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
    let folder: KomiicAPI.MyFolderQuery.Data.Folder
    var comics: [KomiicAPI.ComicFrag] = []
    @State private var showRenameAlert = false
    @State private var folderName: String = ""
    @State private var showDeleteAlert = false
    @State private var deleteCheckText: String = ""
    @State private var showCancelDeleteAlert = false
    @State private var showSuccessDeleteAlert = false
    var body: some View {
        ComicListView(listType: .folderComic, args: folder.id, comics: comics).navigationTitle(folder.name).navigationTransition(.zoom(sourceID: "folder_\(folder.id)", in: namespace)).navigationTitle(folderName).toolbar {
            ToolbarItemGroup(placement: .navigationBarTrailing) {
                Menu {
                    ShareLink(item: URL(string: "https://komiic.com/folder/\(folder.key)")!) {
                        Label("分享書櫃", systemImage: "square.and.arrow.up")
                    }
                    Divider()
                    Button(action: {
                        folderName = folder.name
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
                APIManager.shared.apolloClient.perform(mutation: UpdateFolderNameMutation(folderId: folder.id, name: folderName))
            })
            Button("取消", role: .cancel, action: {})
        }, message: { Text("變更將於重開App後生效") }).alert("永久刪除書櫃？", isPresented: $showDeleteAlert, actions: {
            TextField("輸入「YES」來確認刪除", text: $deleteCheckText)
            Button("刪除", role: .destructive, action: {
                if deleteCheckText == "YES" {
                    APIManager.shared.apolloClient.perform(mutation: RemoveFolderMutation(folderId: folder.id))
                    showSuccessDeleteAlert.toggle()
                } else {
                    showCancelDeleteAlert.toggle()
                }
            })
            Button("取消", role: .cancel, action: {})
        }, message: { Text("刪除後將無法恢復，若要刪除請在下方輸入「YES」來執行") }).toast(isPresenting: $showCancelDeleteAlert, duration: 2, tapToDismiss: true, alert: {
            AlertToast(type: .regular, title: "已取消刪除")
        }, onTap: {}, completion: {}).toast(isPresenting: $showSuccessDeleteAlert, duration: 2, tapToDismiss: true, alert: {
            AlertToast(type: .complete(.green), title: "已刪除", subTitle: "")
        }, onTap: {}, completion: {dismiss()})
    }
}
