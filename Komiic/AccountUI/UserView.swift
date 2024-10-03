//
//  UserView.swift
//  Komiic
//
//  Created by 梁承樸 on 2024/7/30.
//

import KeychainSwift
import KomiicAPI
import SwiftUI

struct UserView: View {
    @EnvironmentObject var appEnv:AppEnvironment
    @Binding var isPresented: Bool
    @State private var loadState: LoadState = .loading
    @State private var account: KomiicAPI.AccountQuery.Data.Account?
    @State private var imageLimit: KomiicAPI.GetImageLimitQuery.Data.GetImageLimit?
    @State private var showLogoutAlert = false
    var body: some View {
        NavigationStack {
            VStack {
                if loadState == .loading {
                    ProgressView().controlSize(.large).onAppear {
                        APIManager.shared.apolloClient.fetch(query: AccountQuery()) { result in
                            switch result {
                            case .success(let response):
                                account = response.data!.account
                                APIManager.shared.apolloClient.fetch(query: GetImageLimitQuery()) { ILResult in
                                    switch ILResult {
                                    case .success(let response):
                                        imageLimit = response.data!.getImageLimit
                                        loadState = .loaded
                                    case .failure(let error):
                                        print(error)
                                        loadState = .failed
                                    }
                                }
                            case .failure(let error):
                                print(error)
                                loadState = .failed
                            }
                        }
                    }
                } else if loadState == .loaded {
                    Spacer().frame(height: 40)
                    Image(systemName: "person.crop.circle").font(.system(size: 120))
                    Spacer().frame(height: 10)
                    Text(account!.nickname).font(.title).bold()
                    Text(account!.email).font(.title3)
                    Spacer().frame(height: 20)
                    HStack {
                        ImageLimitCard(value: "\(imageLimit!.limit - imageLimit!.usage)張", caption: "剩餘")
                        ImageLimitCard(value: "\(imageLimit!.usage)張", caption: "已讀取")
                        ImageLimitCard(value: "\(imageLimit!.limit)張", caption: "單日讀取上限")
                        
                    }
                    Spacer().frame(height: 5)
                    if Int(imageLimit!.resetInSeconds)! / 60 / 60 > 0 {
                        Text("\(Int(imageLimit!.resetInSeconds)! / 60 / 60)小時後重置").font(.footnote).foregroundColor(.gray)
                    } else {
                        Text("\(Int(imageLimit!.resetInSeconds)! / 60)分鐘後重置").font(.footnote).foregroundColor(.gray)
                    }
                    Spacer().frame(height: 40)
                    List {
                        Section {
                            Link("贊助Komiic.com", destination: URL(string: "https://donate.komiic.com/")!)
                        }
                        Section {
                            Button(role: .destructive, action: {
                                showLogoutAlert = true
                            }, label: {
                                Text("登出").frame(maxWidth: .infinity,alignment: .center)
                            })
                        } footer: {
                            Text("App designed by 梁承樸")
                        }
                    }.alert(isPresented: $showLogoutAlert) {
                        Alert(
                            title: Text("確定要登出嗎？"),
                            message: Text(""),
                            primaryButton: .default(
                                Text("取消"),
                                action: {}
                            ),
                            secondaryButton: .destructive(
                                Text("登出"),
                                action: {
                                    let keychain = KeychainSwift()
                                    keychain.synchronizable = true
                                    keychain.delete("expire")
                                    keychain.delete("token")
                                    isPresented.toggle()
                                    appEnv.isLogin = false
                                }
                            )
                        )
                    }
                    Spacer()
                }
            }.navigationTitle("帳號").navigationBarItems(trailing:
                Button(action: {
                    isPresented.toggle()
                }) {
                    Text("完成")
                }
            ).navigationBarTitleDisplayMode(.inline)
        }
    }
}

struct ImageLimitCard: View {
    var value: String
    var caption: String
    var body: some View {
        VStack {
            Text(caption).font(.subheadline)
            Text(value).font(.title2)
        }.padding().background(Color(.systemGray6)).cornerRadius(8)
    }
}
