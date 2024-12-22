//
//  HomeView.swift
//  Komiic
//
//  Created by 梁承樸 on 2024/7/28.
//

import KeychainSwift
import KomiicAPI
import SwiftUI

struct HomeView: View {
    @EnvironmentObject var appEnv: AppEnvironment
    @State private var loadState: LoadState = .checkingAccount
    @State private var openAccountSheet = false
    var body: some View {
        NavigationStack {
            if loadState == .checkingAccount {
                ProgressView().controlSize(.extraLarge).onFirstAppear {
                    let keychain = KeychainSwift()
                    keychain.synchronizable = true
                    appEnv.token = keychain.get("token") ?? ""
                    if !appEnv.token.isEmpty {
                        let nowTime = Int(Date().timeIntervalSince1970)
                        let expireTime = Int(keychain.get("expire")!)!
                        if nowTime >= expireTime {
                            APIManager.shared.login(email: keychain.get("email")!, password: keychain.get("password")!, completion: { result in
                                if result.expire.isEmpty {
                                    keychain.delete("token")
                                    keychain.delete("expire")
                                    keychain.delete("email")
                                    keychain.delete("password")
                                    appEnv.isLogin = false
                                    loadState = .loading
                                } else {
                                    keychain.set(result.token, forKey: "token")
                                    let expireDate = ISO8601DateFormatter().date(from: result.expire)!
                                    keychain.set(String(Int(expireDate.timeIntervalSince1970)), forKey: "expire")
                                    appEnv.isLogin = true
                                    appEnv.token = result.token
                                    loadState = .loading
                                }
                            })
                        } else {
                            appEnv.isLogin = true
                            loadState = .loading
                        }
                    } else {
                        appEnv.isLogin = false
                        loadState = .loading
                    }
                }
            } else if !appEnv.isLogin {
                LoginView().padding()
            } else {
                VStack {
                    Text("asd")
                }.navigationTitle("首頁").navigationBarItems(trailing:
                    Button(action: {
                        openAccountSheet.toggle()
                    }) {
                        Image(systemName: "person.crop.circle").font(.system(size: 25))
                    }
                )
            }
        }.sheet(isPresented: $openAccountSheet, content: {
            UserView(isPresented: $openAccountSheet)
        })
    }
}

#Preview {
    HomeView()
}
