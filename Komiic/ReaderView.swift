//
//  ReaderView.swift
//  Komiic
//
//  Created by 梁承樸 on 2024/9/22.
//

import AlertToast
import Kingfisher
import KomiicAPI
import SwiftUI

struct ReaderView: View {
    @EnvironmentObject var appEnv: AppEnvironment
    @Environment(\.dismiss) private var dismiss
    @State var loadState: ReaderLoadState = .initializing
    @State var chapterList: [KomiicAPI.ChapterByComicIdQuery.Data.ChaptersByComicId] = []
    @State var bookList: [KomiicAPI.ChapterByComicIdQuery.Data.ChaptersByComicId] = []
    @State var imagesList: [KomiicAPI.ImagesByChapterIdQuery.Data.ImagesByChapterId] = []
    @State var currentChapterId: String = ""
    @State private var viewWidth = CGFloat(0)
    @State private var imgRequestModifier = AnyModifier { r in r }
    @State private var showingButton = true
    @State private var currentPage = 0
    @State private var showLastReadToast = false
    @State private var showingChapterPicker = false
    let comicId: String
    var body: some View {
        VStack {
            if loadState == .initializing {
                ProgressView().controlSize(.large).onFirstAppear {
                    APIManager.shared.apolloClient.clearCache()
                    APIManager.shared.apolloClient.fetch(query: ChapterByComicIdQuery(comicId: comicId)) { result in
                        switch result {
                        case .success(let response):
                            let chapters = response.data!.chaptersByComicId.compactMap { $0! }
                            for chapter in chapters {
                                if chapter.type == "book" {
                                    bookList.append(chapter)
                                } else {
                                    chapterList.append(chapter)
                                }
                            }
                            if appEnv.isLogin {
                                APIManager.shared.apolloClient.fetch(query: ComicsLastReadQuery(comicIds: [comicId])) { result in
                                    switch result {
                                    case .success(let lastReadResp):
                                        let lastRead = lastReadResp.data!.lastReadByComicIds.first!
                                        if lastRead!.book != nil {
                                            currentPage = lastRead!.book!.page
                                            currentChapterId = lastRead!.book!.chapterId
                                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                                withAnimation {
                                                    showLastReadToast = true
                                                }
                                            }
                                        } else if lastRead!.chapter != nil {
                                            currentPage = lastRead!.chapter!.page
                                            currentChapterId = lastRead!.chapter!.chapterId
                                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                                withAnimation {
                                                    showLastReadToast = true
                                                }
                                            }
                                        } else {
                                            if chapterList.isEmpty {
                                                currentChapterId = bookList.first!.id
                                            } else {
                                                currentChapterId = chapterList.first!.id
                                            }
                                        }
                                        loadState = .fetchingImages
                                    case .failure(let error):
                                        loadState = .failed
                                        print(error)
                                    }
                                }
                            } else {
                                if chapterList.isEmpty {
                                    currentChapterId = bookList.first!.id
                                } else {
                                    currentChapterId = chapterList.first!.id
                                }
                                loadState = .fetchingImages
                            }
                        case .failure(let error):
                            loadState = .failed
                            print(error)
                        }
                    }
                }
            } else if loadState == .fetchingImages {
                ProgressView().controlSize(.large).onFirstAppear {
                    ImageCache.default.clearMemoryCache()
                    APIManager.shared.apolloClient.fetch(query: ImagesByChapterIdQuery(chapterId: currentChapterId)) { result in
                        switch result {
                        case .success(let response):
                            imagesList = response.data!.imagesByChapterId.compactMap { $0! }
                            imgRequestModifier = AnyModifier { request in
                                var r = request
                                r.addValue("https://komiic.com/comic/\(comicId)/chapter/\(currentChapterId)/images/all", forHTTPHeaderField: "referer")
                                if appEnv.isLogin {
                                    r.addValue("Bearer \(appEnv.token)", forHTTPHeaderField: "authorization")
                                }
                                return r
                            }
                            loadState = .reveal
                        case .failure(let error):
                            loadState = .failed
                            print(error)
                        }
                    }
                }
            } else if loadState == .reveal {
                GeometryReader { proxy in
                    HStack {}.onChange(of: proxy.size.width) { viewWidth = proxy.size.width }.onAppear { viewWidth = proxy.size.width }
                }.frame(height: 0)
                TabView(selection: $currentPage) {
                    ForEach(Array(imagesList.enumerated()), id: \.element.id) { page, img in
                        KFImage(URL(string: "https://komiic.com/api/image/\(img.kid)"))
                            .diskCacheExpiration(.expired)
                            .requestModifier(imgRequestModifier)
                            .placeholder { _ in
                                VStack {
                                    ProgressView()
                                }
                            }
                            .onFailure { _ in
                            }
                            .onSuccess { _ in
                                if appEnv.isLogin {
                                    APIManager.shared.apolloClient.perform(mutation: AddReadComicHistoryMutation(comicId: comicId, chapterId: currentChapterId, page: currentPage))
                                }
                            }
                            .diskCacheExpiration(.expired)
                            .fade(duration: 0.25)
                            .cancelOnDisappear(true)
                            .resizable()
                            .tag(page)
                            .aspectRatio(CGSize(width: img.width, height: img.height), contentMode: .fit)
                    }
                }.tabViewStyle(PageTabViewStyle()).scrollIndicators(.hidden).onTapGesture {
                    if showingButton {
                        withAnimation {
                            showingButton = false
                        }
                    } else {
                        withAnimation {
                            showingButton = true
                        }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) {
                            withAnimation {
                                showingButton = false
                            }
                        }
                    }
                }.overlay(alignment: .topTrailing) {
                    ExitButtonView().frame(width: 36, height: 36).opacity(showingButton ? 1 : 0).padding(EdgeInsets(top: 5, leading: 15, bottom: 15, trailing: 15)).onTapGesture {
                        ImageCache.default.clearMemoryCache()
                        dismiss()
                    }
                }.overlay(alignment: .bottomTrailing) {
                    Menu {
                        Menu {
                            Picker(selection: $currentPage, label: Label("頁數", systemImage: "list.bullet")) {
                                ForEach(Array(imagesList.enumerated().reversed()), id: \.element.id) { index, _ in
                                    Text(String(index + 1)).tag(index)
                                }
                            }
                        } label: {
                            Label("頁數", systemImage: "book.pages")
                        }
                        Button {
                            showingChapterPicker = true
                        } label: {
                            Label("章節", systemImage: "list.bullet")
                        }
                    } label: {
                        Image(systemName: "filemenu.and.selection")
                            .resizable()
                            .frame(width: 28, height: 28)
                            .foregroundColor(.white)
                            .padding(5)
                            .background(.gray)
                            .cornerRadius(8).padding(.horizontal, 20)
                    }.opacity(showingButton ? 1 : 0).sheet(isPresented: $showingChapterPicker, content: {
                        NavigationView {
                            VStack {
                                List {
                                    Section {
                                        ForEach(bookList, id: \.id) { book in
                                            let currentChapterBadge = (currentChapterId == book.id ? "目前章節" : "\(book.size)p")
                                            Button("\(book.serial)卷") {
                                                currentChapterId = book.id
                                                currentPage = 0
                                                loadState = .fetchingImages
                                                showingChapterPicker = false
                                            }.badge(currentChapterBadge)
                                        }
                                    } header: {
                                        if !bookList.isEmpty {
                                            Text("卷")
                                        }
                                    }
                                    Section {
                                        ForEach(chapterList, id: \.id) { chapter in
                                            let currentChapterBadge = (currentChapterId == chapter.id ? "目前章節" : "\(chapter.size)p")
                                            Button("\(chapter.serial)話") {
                                                currentChapterId = chapter.id
                                                currentPage = 0
                                                loadState = .fetchingImages
                                                showingChapterPicker = false
                                            }.badge(currentChapterBadge)
                                        }
                                    } header: {
                                        if !chapterList.isEmpty {
                                            Text("話")
                                        }
                                    }
                                }
                            }.navigationTitle("章節").navigationBarItems(trailing:
                                Button(action: {
                                    showingChapterPicker = false
                                }) {
                                    ExitButtonView().frame(width: 32, height: 32)
                                }.padding(EdgeInsets(top: 15, leading: 0, bottom: 0, trailing: 10))
                            )
                        }
                    })
                }
            }
        }.toast(isPresenting: $showLastReadToast) {
            AlertToast(displayMode: .hud, type: .regular, title: "已自動跳轉到上次閱讀的頁面")
        }
    }
}
