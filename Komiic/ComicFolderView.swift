//
//  ComicFolderView.swift
//  Komiic
//
//  Created by 梁承樸 on 2024/3/19.
//

import SwiftUI

struct ComicFolderView: View {
    var body: some View {
        NavigationView {
            VStack {
                ScrollView {
                    Spacer().frame(height: 20)
                    SmallComicListView(listType: 3, title: "喜愛書籍", requestParameters: "")
                    Spacer()
                }
            }   .navigationTitle("書櫃")
        }.navigationViewStyle(StackNavigationViewStyle())
    }
}

#Preview {
    ComicFolderView()
}
