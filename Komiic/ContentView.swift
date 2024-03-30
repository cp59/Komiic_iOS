//
//  ContentView.swift
//  Komiic
//
//  Created by 梁承樸 on 2024/3/10.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var app:app
    private let userDefaults = UserDefaults()
    @State private var showNotFinishedReadingAlert = false
    @State private var startReading = false
    var body: some View {
        TabView {
            ComicFolderView().tabItem {
                Image(systemName: "books.vertical.fill")
                Text("書櫃")
            }
            ComicHistoryView().tabItem {
                Image(systemName: "clock.fill")
                Text("最近閱讀")
            }
            BookStoreView()
            .tabItem {
                Image(systemName: "bag.fill")
                Text("書店")
            }
            UserView().tabItem {
                Image(systemName: "person.crop.circle")
                Text("我的帳號")
            }
        }.onFirstAppear {
            if (userDefaults.bool(forKey: "notFinishedReading")) {
                showNotFinishedReadingAlert = true
            }
            if (app.isLogin) {
                app.komiicApi.getAccountInfo(completion: {accountInfo in
                    if (accountInfo.id == "tokenExpired") {
                        app.isLogin = false
                    }
                })
            }
        }.alert(isPresented: $showNotFinishedReadingAlert) {
            Alert(
                title: Text("發現未閱讀完成的紀錄"),
                message: Text("繼續上次未閱讀完成的漫畫嗎?"),
                primaryButton: .default(
                    Text("閱讀"),
                    action: {
                        startReading = true
                    }
                ),
                secondaryButton: .destructive(
                    Text("取消"),
                    action: {
                        userDefaults.setValue(false, forKey: "notFinishedReading")
                    }
                )
            )
        }.fullScreenCover(isPresented: $startReading, content: {
            ReaderView(comicId: userDefaults.string(forKey: "lastReadComicId")! , isPresented: $startReading)})
    }
}

#Preview {
    ContentView()
}
