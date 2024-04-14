//
//  ComicMessagesView.swift
//  Komiic
//
//  Created by 梁承樸 on 2024/4/14.
//

import SwiftUI

struct ComicMessagesView: View {
    @EnvironmentObject var app:AppEnvironment
    @Binding var isPresented:Bool
    var comicId:String
    @State private var messages:[KomiicAPI.ComicMessage] = []
    @State private var isLoading = true
    var body: some View {
        NavigationView {
            VStack {
                if (isLoading) {
                    Spacer()
                    ProgressView()
                    Spacer()
                } else {
                    ScrollView {
                        VStack (spacing: 10){
                            ForEach(messages, id: \.id) { message in
                                if (message.replyTo == nil) {
                                    VStack (alignment: .leading){
                                        HStack {
                                            Text(message.account.nickname).bold()
                                            Spacer()
                                            Text(ISO8601DateFormatter().date(from: message.dateCreated)!.timeAgoDisplay()).font(.caption).foregroundColor(.gray)
                                        }
                                        Text(message.message).font(.callout)
                                        HStack {
                                            Spacer()
                                            Button {
                                                
                                            } label: {
                                                Label("回覆", systemImage: "arrowshape.turn.up.left").font(.footnote)
                                            }.buttonStyle(.bordered)
                                            Button {
                                                
                                            } label: {
                                                Label("\(message.upCount)", systemImage: "hand.thumbsup").font(.footnote)
                                            }.buttonStyle(.bordered)
                                            Button {
                                                
                                            } label: {
                                                Label("\(message.downCount)", systemImage: "hand.thumbsdown").font(.footnote)
                                            }.buttonStyle(.bordered)
                                        }
                                    }.padding(15).background(Color(.secondarySystemGroupedBackground))
                                        .cornerRadius(7)
                                }
                            }
                        }.padding(10)
                    }.frame(maxWidth: .infinity)
                }
            }.background(Color(.systemGroupedBackground)).navigationTitle("留言").onFirstAppear {
                app.komiicApi.getMessagesByComicId(comicId: comicId, completion: {resp in
                    messages = resp
                    isLoading = false
                })
            }.navigationBarItems(trailing:
                Button (action: {
                    isPresented = false
                }) {
                    ExitButtonView()
                }.padding(5)
            )
        }
    }
}
