//
//  UserView.swift
//  Komiic
//
//  Created by 梁承樸 on 2024/3/15.
//

import SwiftUI
import KeychainSwift

struct UserView: View {
    private let komiicApi = KomiicAPI()
    @State private var accountInfo =  KomiicAPI.AccountInfo(id: "", email: "", nickname: "", dateCreated: "", nextChapterMode: "", totalDonateAmount: 0, monthDonateAmount: 0)
    @State private var imageLimitInfo =  KomiicAPI.ImageLimit(limit: 0, usage: 0, resetInSeconds: "0")
    @State private var showLogoutAlert = false
    private let keychain = KeychainSwift()
    @EnvironmentObject var app:app
    var body: some View {
        VStack {
            if (app.isLogin) {
                VStack {
                    if (imageLimitInfo.limit == 0) {
                        ProgressView()
                    } else {
                        List {
                            Section {
                                HStack {
                                    Image(systemName: "person.crop.circle").font(.system(size: 40))
                                    VStack (alignment: .leading){
                                        Text(accountInfo.nickname).font(.title2)
                                        Text(accountInfo.email).font(.subheadline)
                                    }
                                    Spacer()
                                }
                                Text("圖片已讀取").badge("\(imageLimitInfo.usage)張")
                                Text("剩餘圖片讀取量").badge("\(imageLimitInfo.limit - imageLimitInfo.usage)張")
                                Text("圖片讀取量限制").badge("\(imageLimitInfo.limit)張")
                                Text("重置時間").badge("\(lround(Double(imageLimitInfo.resetInSeconds)!/3600))小時後")
                            } footer: {
                                Text("成為贊助帳號來解鎖最高1萬張的圖片讀取量限制")
                            }
                            Section {
                                Text("帳號創建日期").badge(ISO8601DateFormatter().date(from: accountInfo.dateCreated)!.timeAgoDisplay())
                                Text("已贊助").badge("$\(accountInfo.totalDonateAmount)")
                                Text("本月已贊助").badge("$\(accountInfo.monthDonateAmount)")
                            }
                            Section {
                                Link("贊助Komiic.com", destination: URL(string: "https://donate.komiic.com/")!)
                                Button(action: {
                                    showLogoutAlert = true
                                }, label: {
                                    Text("登出").foregroundStyle(.red)
                                })
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
                                        app.isLogin = false
                                        keychain.delete("token")
                                    }
                                )
                            )
                        }
                        Spacer()
                    }
                }.onAppear {
                    komiicApi.getAccountInfo(completion: {resp in
                        accountInfo = resp
                        komiicApi.getImageLimit(completion: {resp in imageLimitInfo = resp})
                    })
                }
            } else {
                LoginView()
            }
        }
    }
}

