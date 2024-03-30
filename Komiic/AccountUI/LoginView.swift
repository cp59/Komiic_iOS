//
//  LoginView.swift
//  Komiic
//
//  Created by 梁承樸 on 2024/3/31.
//

import SwiftUI
import KeychainSwift

struct LoginView: View {
    @State private var showingLoginSheet = false
    @State private var showLoginFailedAlert = false
    @State private var username = ""
    @State private var password = ""
    @State private var logging = false
    @EnvironmentObject var app:app
    private let keychain = KeychainSwift()
    var body: some View {
        VStack {
            Text("尚未登入").font(.title).bold()
            Spacer().frame(height: 8)
            Text("登入即可使用書櫃功能、書簽功能、跨平台閱讀記錄、留言功能、更多漫畫等功能").multilineTextAlignment(.center)
            Spacer().frame(height: 15)
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
                                    app.komiicApi.login(email: username, password: password, completion: {token in
                                        logging = false
                                        if (token.isEmpty) {
                                            showLoginFailedAlert = true
                                        } else {
                                            keychain.set(token, forKey: "token")
                                            app.isLogin = true
                                            app.token = token
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
        }.padding()
    }
}

#Preview {
    LoginView()
}
