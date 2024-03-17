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
    @State private var logging = false
    @State private var showingLoginSheet = false
    @State private var showLoginFailedAlert = false
    @State private var username = ""
    @State private var password = ""
    @State private var accountInfo =  KomiicAPI.AccountInfo(id: "", email: "", nickname: "", dateCreated: "", nextChapterMode: "", totalDonateAmount: 0, monthDonateAmount: 0)
    @State private var imageLimitInfo =  KomiicAPI.ImageLimit(limit: 0, usage: 0, resetInSeconds: "0")
    @State private var showLogoutAlert = false
    private let keychain = KeychainSwift()
    @State private var isLogin = false
    var body: some View {
        VStack {
            if (isLogin) {
                VStack {
                    if (imageLimitInfo.limit == 0) {
                        ProgressView().scaleEffect(2)
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
                                        isLogin = false
                                        keychain.delete("token")
                                    }
                                )
                            )
                        }
                        Spacer()
                    }
                }.onAppear {
                    komiicApi.getAccountInfo(completion: {resp in
                        if (resp.id == "tokenExpired") {
                            isLogin = false
                            keychain.delete("token")
                        } else {
                            accountInfo = resp
                            komiicApi.getImageLimit(completion: {resp in imageLimitInfo = resp})
                        }
                    })
                }
            } else {
                Text("尚未登入").font(.title).bold()
                Spacer().frame(height: 5)
                Text("登入即可使用下書櫃功能、書簽功能、跨平台閱讀記錄、留言功能、更多漫畫").multilineTextAlignment(.center)
                Spacer().frame(height: 10)
                Button(action: {
                    showingLoginSheet = true
                }, label: {
                    Text("登入").frame(maxWidth: .infinity,maxHeight: 35)
            }).buttonStyle(.borderedProminent).sheet(isPresented: $showingLoginSheet, content:
            {
                VStack {
                    NavigationView {
                        VStack {
                            Form {
                                TextField(text: $username, prompt: Text("電子郵件地址")) {
                                    Text("電子郵件地址")
                                }.textInputAutocapitalization(.never)
                                SecureField(text: $password, prompt: Text("密碼")) {
                                    Text("密碼")
                                }
                            }
                            Button(action: {
                                if (!logging) {
                                    logging = true
                                    komiicApi.login(email: username, password: password, completion: {token in
                                        logging = false
                                        if (token.isEmpty) {
                                            showLoginFailedAlert = true
                                        } else {
                                            keychain.set(token, forKey: "token")
                                            isLogin = true
                                            showingLoginSheet = false
                                        }
                                    })
                                }
                            }, label: {
                                HStack {
                                    if (logging) {
                                        ProgressView().tint(.white).scaleEffect(1.3)
                                    } else {
                                        Text("登入")
                                    }
                                }.frame(maxWidth: .infinity,maxHeight: 35)
                            }).alert(isPresented: $showLoginFailedAlert, content: {
                                Alert(title: Text("登入失敗"), message: Text("可能因為輸入資訊不正確，或是網際網路連線不佳"), dismissButton: .default(Text("好")))
                            })
                            .buttonStyle(.borderedProminent).padding()
                        }.navigationTitle("登入Komiic")
                    }
                }
            })
            }
        }.onAppear {
            let token = keychain.get("token") ?? ""
            isLogin = !token.isEmpty
        }
    }
}

