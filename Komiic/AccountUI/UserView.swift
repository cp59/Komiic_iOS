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
                    Spacer().frame(height: 20)
                    Image(systemName: "person.crop.circle").font(.system(size: 100))
                    Spacer().frame(height: 5)
                    Text(account!.nickname).font(.title).bold()
                    Text(account!.email).font(.headline).foregroundStyle(.secondary)
                    List {
                        Section {
                            VStack (alignment: .leading){
                                HStack (alignment: .bottom){
                                    Text("單日圖片讀取用量").bold()
                                    Spacer()
                                    if Int(imageLimit!.resetInSeconds)! / 60 / 60 > 0 {
                                        Text("\(Int(imageLimit!.resetInSeconds)! / 60 / 60)小時後重置").font(.callout).foregroundColor(.gray)
                                    } else {
                                        Text("\(Int(imageLimit!.resetInSeconds)! / 60)分鐘後重置").font(.callout).foregroundColor(.gray)
                                    }
                                }
                                ImageLimitProgressBarView(value: Double(imageLimit!.usage), total: Double(imageLimit!.limit)).frame(height: 8)
                                Text("\(imageLimit!.limit) (額度) - \(imageLimit!.usage) (已讀取) = \(imageLimit!.limit - imageLimit!.usage) (剩餘)").font(.subheadline).foregroundStyle(.secondary)
                            }.padding(2)
                            Link("贊助 Komiic.com 即可升級讀取額度", destination: URL(string: "https://komiic.com/donate")!)
                        }
                        Section {
                        }
                        Section {
                            Button(role: .destructive, action: {
                                showLogoutAlert = true
                            }, label: {
                                Text("登出").frame(maxWidth: .infinity,alignment: .center)
                            })
                        } footer: {
                            Text("App designed by 梁承樸").frame(maxWidth: .infinity).padding(5)
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
                } else if loadState == .failed {
                    Text("無法載入").font(.title).bold()
                    Button(action: {
                        loadState = .loading
                    }) {
                        Image(systemName: "arrow.triangle.2.circlepath.circle.fill")
                            .imageScale(.large)
                        Text("重試")
                    }
                    .buttonStyle(.borderedProminent)
                    .buttonBorderShape(.capsule)
                }
            }.navigationTitle("Komiic ID").navigationBarItems(trailing:
                Button(action: {
                    isPresented.toggle()
                }) {
                    Text("完成")
                }
            ).navigationBarTitleDisplayMode(.inline)
        }
    }
}

struct ImageLimitProgressBarView: View {
    
    let value: CGFloat
    let total: CGFloat
    
    var body: some View {
        GeometryReader(content: { geometry in
            ZStack(alignment: .leading, content: {
                Rectangle()
                    .foregroundColor(Color.gray.opacity(0.2))
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .clipShape(Capsule())
                
                Rectangle()
                    .foregroundColor(.accent)
                    .frame(maxHeight: .infinity)
                    .frame(width: calculateBarWidth(contentWidth: geometry.size.width))
                    .clipShape(Capsule())
            })
            .clipped()
        })
    }
    
    private func calculateBarWidth(contentWidth: CGFloat) -> CGFloat {
        return (value / total) * contentWidth
    }
}
