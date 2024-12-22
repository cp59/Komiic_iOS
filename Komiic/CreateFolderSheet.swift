//
//  CreateFolderSheet.swift
//  Komiic
//
//  Created by 梁承樸 on 2024/12/22.
//

import KomiicAPI
import SwiftUI

struct CreateFolderSheet: View {
    enum FocusedField {
        case folderName
    }

    @Environment(\.dismiss) private var dismiss
    @FocusState private var focusedField: FocusedField?
    @State private var requesting = false
    @State private var failed = false
    @State private var folderName = ""
    var body: some View {
        NavigationStack {
            Form {
                TextField("書櫃名稱", text: $folderName).focused($focusedField, equals: .folderName)
                    .onAppear {
                        focusedField = .folderName
                    }
            }.navigationTitle("建立書櫃")
                .navigationBarItems(leading: Button("取消") { dismiss() }, trailing:
                    Button(action: {
                        if !requesting {
                            requesting = true
                            APIManager.shared.apolloClient.perform(mutation: CreateFolderMutation(name: folderName)) { result in
                                switch result {
                                case .success:
                                    dismiss()
                                case .failure:
                                    requesting = false
                                    failed = true
                                }
                            }
                        }
                    }
                    ) {
                        if requesting {
                            ProgressView()
                        } else {
                            Text("完成")
                        }
                }.disabled(folderName.isEmpty)).alert(isPresented: $failed) {
                        Alert(title: Text("無法處理請求"), message: Text("檢查網路連線後，請稍後再試一次"))
                }.padding(.vertical, 10)
        }
    }
}
