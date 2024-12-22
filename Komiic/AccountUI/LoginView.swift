//
//  LoginView.swift
//  Komiic
//
//  Created by 梁承樸 on 2024/7/28.
//

import KeychainSwift
import SwiftUI

struct LoginView: View {
    @State private var showingLoginSheet = false
    @State private var showLoginFailedAlert = false
    @State private var username = ""
    @State private var password = ""
    @State private var logging = false
    @EnvironmentObject var appEnv: AppEnvironment
    var body: some View {
        VStack {
            Text("尚未登入").font(.title).bold()
            Spacer().frame(height: 5)
            Text("登入即可使用書櫃功能、書簽功能、跨平台閱讀記錄、留言功能、更多漫畫等功能").multilineTextAlignment(.center).font(.callout)
            Spacer().frame(height: 20)
            Button(action: {
                showingLoginSheet.toggle()
            }, label: {
                Text("登入").frame(maxWidth: .infinity, maxHeight: 35)
            }).buttonStyle(.borderedProminent)
                .sheet(isPresented: $showingLoginSheet, content: {
                    NavigationStack {
                        VStack {
                            Text("登入 Komiic ID")
                                .font(.largeTitle)
                                .bold()
                            TextField(text: $username, prompt: Text("電子郵件地址")) { Text("電子郵件地址") }
                                .keyboardType(.emailAddress)
                                .textContentType(.emailAddress)
                                .textInputAutocapitalization(.never)
                                .frame(height: 50)
                                .padding(.horizontal, 10)
                                .background(Color(.secondarySystemBackground))
                                .cornerRadius(8)
                            SecureField(text: $password, prompt: Text("密碼")) { Text("密碼") }
                                .frame(height: 50)
                                .padding(.horizontal, 10)
                                .background(Color(.secondarySystemBackground))
                                .cornerRadius(8)
                            Spacer().frame(height: 20)
                            Button(action: {
                                if !logging {
                                    logging.toggle()
                                    APIManager.shared.login(email: username, password: password, completion: { result in
                                        if result.expire.isEmpty {
                                            logging.toggle()
                                            showLoginFailedAlert.toggle()
                                        } else {
                                            let keychain = KeychainSwift()
                                            keychain.synchronizable = true
                                            keychain.set(result.token, forKey: "token")
                                            let expireDate = ISO8601DateFormatter().date(from:result.expire)!
                                            keychain.set(username, forKey: "email")
                                            keychain.set(password, forKey: "password")
                                            keychain.set(String(Int(expireDate.timeIntervalSince1970)), forKey: "expire")
                                            showingLoginSheet.toggle()
                                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                                appEnv.token = result.token
                                                appEnv.isLogin.toggle()
                                            }
                                        }
                                    })
                                }
                            }, label: {
                                HStack {
                                    if logging {
                                        ProgressView().tint(.white)
                                    } else {
                                        Text("登入")
                                    }
                                }.frame(maxWidth: .infinity, maxHeight: 35)
                            }).alert(isPresented: $showLoginFailedAlert, content: {
                                Alert(title: Text("登入失敗"), message: Text("可能因為輸入資訊不正確，或是網際網路連線不佳"), dismissButton: .default(Text("好")))
                            })
                            .buttonStyle(.borderedProminent)
                            Spacer().frame(height: 20)
                            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], content: {
                                Link("忘記密碼？", destination: URL(string: "https://komiic.com/sendResetPassword")!)
                                Link("註冊帳戶", destination: URL(string: "https://komiic.com/register")!)
                            })
                            Spacer().frame(height: 60)
                        }.padding().toolbar {
                            ToolbarItem(placement: .cancellationAction, content: {
                                Button("取消", role: .cancel) {
                                    showingLoginSheet = false
                                }
                            })
                        }
                    }
                })
        }.padding()
    }
}

#Preview {
    LoginView()
}
