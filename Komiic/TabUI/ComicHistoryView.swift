//
//  ComicHistoryView.swift
//  Komiic
//
//  Created by 梁承樸 on 2024/3/19.
//

import SwiftUI

struct ComicHistoryView: View {
    @EnvironmentObject var app:AppEnvironment
    @State private var refreshList = 0
    var body: some View {
        NavigationView {
            if (app.isLogin) {
                ComicListView(title: "最近閱讀", requestParameters: "", listType: 2, refreshList: $refreshList).refreshable {
                    refreshList += 1
                }
            } else {
                LoginView()
            }
        }.navigationViewStyle(StackNavigationViewStyle())
    }
}

#Preview {
    ComicHistoryView()
}
