//
//  ComicHistoryView.swift
//  Komiic
//
//  Created by 梁承樸 on 2024/3/19.
//

import SwiftUI

struct ComicHistoryView: View {
    @State private var refreshList = 0
    var body: some View {
        NavigationView {
            ComicListView(title: "最近閱讀", requestParameters: "", listType: 2, refreshList: $refreshList).refreshable {
                refreshList += 1
            }
        }.navigationViewStyle(StackNavigationViewStyle())
    }
}

#Preview {
    ComicHistoryView()
}
