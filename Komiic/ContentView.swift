//
//  ContentView.swift
//  Komiic
//
//  Created by 梁承樸 on 2024/7/28.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var appEnv: AppEnvironment
    var body: some View {
        ZStack {
            TabView {
                HomeView().tabItem {
                    Image(systemName: "house")
                    Text("首頁")
                }
                BookLibraryView().tabItem {
                    Image(systemName: "books.vertical")
                    Text("書櫃")
                }
                BookStoreView()
                    .tabItem {
                        Image(systemName: "bag.fill")
                        Text("書店")
                    }
            }
        }
    }
}

#Preview {
    ContentView()
}
