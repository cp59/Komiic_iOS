//
//  ReaderView.swift
//  Komiic
//
//  Created by 梁承樸 on 2024/3/12.
//

import SwiftUI
import Kingfisher
import KeychainSwift
import SwiftUISnackbar

struct ReaderView: View {
    @EnvironmentObject var app:app
    var comicId:String
    private let userDefaults = UserDefaults()
    @State private var chaptersList:[KomiicAPI.Chapters] = []
    @State private var specChapterId:String = ""
    @State private var isLoading = true
    @Binding var isPresented:Bool
    @State var picList:[KomiicAPI.ComicImages] = []
    @State private var showingButton = false
    @State private var showingChapterPicker = false
    @State private var showingReaderSettings = false
    @State private var viewWidth = CGFloat(0)
    @State private var haveBook = false
    @State private var haveChapter = false
    @State private var useSecondReadMode = false
    @State private var currentChapterIndex = 0
    @State private var chapterIsBook = false
    @State private var imageViewReady = false
    @State private var reachedImageLimit = false
    @State private var currentPage = ""
    @State private var lastReadPage = -1
    @State private var haveLastReadRecord = false
    @State private var tabViewSelection = ""
    @State private var pageSelection = ""
    @State var modifier = AnyModifier { request in
        return request
    }
    private let token = KeychainSwift().get("token") ?? ""
    var body: some View {
        GeometryReader {proxy in
            HStack{}.onChange(of: proxy.size.width){_ in viewWidth=proxy.size.width}.onAppear{viewWidth=proxy.size.width}}.frame(height: 0)
        VStack {
            if (!useSecondReadMode) {
                ScrollViewReader {scrollView in
                    ScrollView {
                        LazyVStack {
                            ForEach(Array(picList.enumerated()), id:\.element.id) { page,img in
                                KFImage(URL(string:"https://komiic.com/api/image/\(img.kid)"))
                                    .requestModifier(modifier)
                                    .placeholder { _ in
                                        VStack {
                                            Spacer()
                                            ProgressView()
                                            Spacer()
                                        }.frame(width:viewWidth).aspectRatio(CGSize(width: img.width, height: img.height), contentMode: .fill)
                                            .background(Color(UIColor.darkGray)).cornerRadius(10).padding(10).onAppear {imageViewReady = true}
                                    }
                                    .onFailure{error in
                                        app.komiicApi.reachedImageLimit(completion: {status in reachedImageLimit = status})
                                    }
                                    .onSuccess { _ in
                                        currentPage = "\(page)_\(img.kid)"
                                        pageSelection = currentPage
                                        if (app.isLogin) {
                                            app.komiicApi.addReadComicHistory(comicId: comicId, chapterId: specChapterId, page: page)
                                        }
                                    }
                                    .diskCacheExpiration(.expired)
                                    .fade(duration: 0.25)
                                    .cancelOnDisappear(true)
                                    .resizable()
                                    .padding(EdgeInsets(top: -2, leading: 5, bottom: -2, trailing: 5))
                                    .id("\(page)_\(img.kid)")
                                    .scaledToFill()
                            }.onAppear {
                                if (userDefaults.bool(forKey: "notFinishedReading")) {
                                    scrollView.scrollTo(userDefaults.string(forKey: "lastReadPage"))
                                    userDefaults.set(false, forKey: "notFinishedReading")
                                }
                            }.onChange(of: haveLastReadRecord) { _ in
                                if (lastReadPage != -1) {
                                    scrollView.scrollTo("\(lastReadPage)_\(picList[lastReadPage].kid)")
                                    lastReadPage = -1
                                }
                            }.onChange(of: pageSelection) { _ in
                                if (currentPage != pageSelection) {
                                    scrollView.scrollTo(pageSelection)
                                }
                            }
                            if (imageViewReady) {
                                if (chaptersList.filter({$0.type.hasPrefix(chapterIsBook ? "b" : "c")}).last?.id == specChapterId) {
                                    Text("此為最後章節")
                                } else {
                                    Button(action: {
                                        while true {
                                            currentChapterIndex += 1
                                            let nextChapter = chaptersList[currentChapterIndex]
                                            let nextIsBook = nextChapter.type == "book"
                                            if (nextIsBook == chapterIsBook) {
                                                specChapterId = chaptersList[currentChapterIndex].id
                                                break
                                            }
                                        }
                                    }, label: {
                                        Text("下一章節").frame(maxWidth: .infinity,minHeight: 30)
                                    }).buttonStyle(.borderedProminent).padding(5)
                                }
                            }
                            Spacer()
                        }
                    }
                }.onTapGesture {
                    if (showingButton) {
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
                }
            } else {
                TabView (selection: $tabViewSelection){
                    ForEach(Array(picList.enumerated()), id:\.element.id) { page,img in
                            KFImage(URL(string:"https://komiic.com/api/image/\(img.kid)"))
                                .requestModifier(modifier)
                                .placeholder { progress in
                                    VStack {
                                        Spacer()
                                        ProgressView()
                                        Spacer()
                                    }.frame(width:viewWidth).aspectRatio(CGSize(width: img.width, height: img.height), contentMode: .fill)
                                        .background(Color(UIColor.darkGray)).cornerRadius(10).padding(10).onAppear {imageViewReady = true}
                                }
                                .diskCacheExpiration(.expired)
                                .fade(duration: 0.25)
                                .cancelOnDisappear(true)
                                .onSuccess { _ in
                                    currentPage = "\(page)_\(img.kid)"
                                    pageSelection = currentPage
                                    if (app.isLogin) {
                                        app.komiicApi.addReadComicHistory(comicId: comicId, chapterId: specChapterId, page: page)
                                    }
                                }
                                .resizable()
                                .tag("\(page)_\(img.kid)")
                                .scaledToFit()
                        }.onAppear {
                            if (userDefaults.bool(forKey: "notFinishedReading")) {
                                tabViewSelection = (userDefaults.string(forKey: "lastReadPage"))!
                                userDefaults.set(false, forKey: "notFinishedReading")
                            }
                        }.onChange(of: haveLastReadRecord) { _ in
                            if (lastReadPage != -1) {
                                tabViewSelection = ("\(lastReadPage)_\(picList[lastReadPage].kid)")
                                lastReadPage = -1
                            }
                        }
                        .onChange(of: pageSelection, perform: { value in
                            if (pageSelection != currentPage) {
                                tabViewSelection = pageSelection
                            }
                        })
                    if (imageViewReady) {
                        if (chaptersList.filter({$0.type.hasPrefix(chapterIsBook ? "b" : "c")}).last?.id == specChapterId) {
                            Text("此為最後章節")
                        } else {
                            Button(action: {
                                while true {
                                    currentChapterIndex += 1
                                    let nextChapter = chaptersList[currentChapterIndex]
                                    let nextIsBook = nextChapter.type == "book"
                                    if (nextIsBook == chapterIsBook) {
                                        specChapterId = chaptersList[currentChapterIndex].id
                                        break
                                    }
                                }
                            }, label: {
                                Text("下一章節").frame(maxWidth: .infinity,minHeight: 30)
                            }).buttonStyle(.borderedProminent).padding(5)
                        }
                    }
                }.tabViewStyle(PageTabViewStyle(indexDisplayMode: .never)).onTapGesture {
                    if (showingButton) {
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
                }
            }
        }.snackbar(isShowing: $haveLastReadRecord, title: "將從上次閱讀的地方開始",text: "因為你登入的帳號有此漫畫的閱讀紀錄" ,style: .custom(.blue)).onReceive(NotificationCenter.default.publisher(for: UIApplication.willTerminateNotification), perform: { output in
            let userDefaults = UserDefaults()
            userDefaults.setValue(true, forKey: "notFinishedReading")
            userDefaults.setValue(comicId, forKey: "lastReadComicId")
            userDefaults.setValue(specChapterId, forKey: "lastReadChapterId")
            userDefaults.setValue(currentPage, forKey: "lastReadPage")
        }).overlay(alignment:.topTrailing) {
                Button (action: {
                    ImageCache.default.clearMemoryCache()
                    isPresented = false
                }) {
                    ExitButtonView().frame(width: 24,height: 24)
                }.opacity(showingButton ? 1 : 0).padding(15)
        }.overlay(alignment:.bottomTrailing) {
                Menu {
                    Button {
                        showingReaderSettings = true
                    }label: {
                        Label("閱讀器設定", systemImage: "gear")
                    }
                    Menu{
                        Picker(selection: $pageSelection, label: Label("頁數", systemImage: "list.bullet")) {
                            ForEach (Array(picList.enumerated().reversed()), id: \.element.id) {index,page in
                                Text(String(index+1)).tag("\(index)_\(page.kid)")
                            }
                        }
                    }label: {
                        Label("頁數", systemImage: "book.pages")
                    }
                    Button{
                        showingChapterPicker = true
                    }label: {
                        Label("選擇章節", systemImage: "list.bullet")
                    }
                } label: {
                    Image(systemName: "filemenu.and.selection")
                        .resizable()
                        .frame(width: 28, height: 28)
                        .foregroundColor(.white)
                        .padding(5)
                        .background(.gray)
                        .cornerRadius(8)
                }.opacity(showingButton ? 1 : 0).padding(10).sheet(isPresented: $showingChapterPicker, content: {
                    NavigationView {
                        List() {
                            Section {
                                ForEach(Array(chaptersList.enumerated()),id: \.element.id) { index,chapter in
                                    if (chapter.type == "book") {
                                        Button(chapter.serial+"卷") {
                                            specChapterId = chapter.id
                                            currentChapterIndex = index
                                            chapterIsBook = true
                                            showingChapterPicker = false
                                        }.badge(specChapterId == chapter.id ? "目前章節" : "\(chapter.size)p")
                                        .onAppear{haveBook = true}
                                    }
                                }
                            } header: {
                                if (haveBook) {
                                    Text("卷")
                                }
                            }
                            Section {
                                ForEach(Array(chaptersList.enumerated()),id: \.element.id) { index,chapter in
                                    if (chapter.type == "chapter") {
                                        Button(chapter.serial+"話") {
                                            specChapterId = chapter.id
                                            currentChapterIndex = index
                                            chapterIsBook = false
                                            showingChapterPicker = false
                                        }.badge(specChapterId == chapter.id ? "目前章節" : "\(chapter.size)p").onAppear{haveChapter = true}
                                    }
                                }
                            } header: {
                                if (haveChapter) {
                                    Text("話")
                                }
                            }
                        }.navigationTitle("選擇章節").navigationBarItems(trailing:
                            Button (action: {
                                showingChapterPicker = false
                            }) {
                                ExitButtonView()
                            }.padding(5)
                        ).padding(EdgeInsets(top: 10, leading: 0, bottom: 0, trailing: 0))
                    }
                    
                }).sheet(isPresented: $showingReaderSettings, content: {
                    NavigationView {
                        List() {
                            Toggle(isOn: $useSecondReadMode, label: {
                                Text("使用翻頁模式")
                            }).onChange(of: useSecondReadMode) { _ in userDefaults.setValue(useSecondReadMode, forKey: "useSecondReadMode")}
                        }.navigationTitle("閱讀器設定").navigationBarItems(trailing:
                            Button (action: {
                                showingReaderSettings = false
                            }) {
                                ExitButtonView()
                            }.padding(5)
                        ).padding(EdgeInsets(top: 10, leading: 0, bottom: 0, trailing: 0))
                    }
                })
        }
        .onAppear {
            useSecondReadMode = userDefaults.bool(forKey: "useSecondReadMode")
            app.komiicApi.getChapterByComicId(comicId: comicId, completion: { chapters in
                if (!userDefaults.bool(forKey: "notFinishedReading")) {
                    app.komiicApi.fetchComicHistory(completion: {history in
                        let comicHistory = history.filter {(x) -> Bool in
                            x.comicId == comicId
                        }.first
                        if ((comicHistory) != nil) {
                            let sameTypeChapter = chaptersList.filter {(x) -> Bool in
                                x.type == comicHistory!.chapterType}
                            var sameTypeChapterId:[String] = []
                            for chapter in sameTypeChapter {
                                sameTypeChapterId.append(chapter.id)
                            }
                            var biggestId = 0
                            var lastReadPage = 0
                            for (index,chapter) in comicHistory!.chapters.enumerated() {
                                if (sameTypeChapterId.contains(chapter.chapterId)) {
                                    if (Int(chapter.chapterId)! > biggestId) {
                                        biggestId = Int(chapter.chapterId)!
                                        lastReadPage = chapter.page
                                        currentChapterIndex = index
                                    }
                                }
                            }
                            if (biggestId == 0) {
                                let firstChapter = chapters.first!
                                specChapterId.append(firstChapter.id)
                            } else {
                                self.lastReadPage = lastReadPage
                                specChapterId.append(String(biggestId))
                            }
                        } else {
                            let firstChapter = chapters.first!
                            specChapterId.append(firstChapter.id)
                        }
                    })
                } else {
                    specChapterId = userDefaults.string(forKey: "lastReadChapterId")!
                }
                chaptersList.append(contentsOf: chapters)
                
            })
        }
        .onChange(of: specChapterId) { _ in
            picList.removeAll()
            imageViewReady = false
            app.komiicApi.getImagesByChapterId(chapterId: specChapterId, completion: {imagesList in
                modifier = AnyModifier { request in
                    var r = request
                    r.addValue("https://komiic.com/comic/\(comicId)/chapter/\(specChapterId)/images/all", forHTTPHeaderField: "referer")
                    if (!token.isEmpty) {
                        r.addValue("Bearer \(token)", forHTTPHeaderField: "authorization")
                    }
                    return r
                }
                picList.append(contentsOf: imagesList)
                if (lastReadPage != -1) {
                    haveLastReadRecord = true
                }
            })
        }.alert(isPresented: $reachedImageLimit) {
            Alert(
                title: Text("已達到當前圖片讀取量限制"),
                message: Text("若未登入帳號，可登入帳號來將限制提高至800張"),
                dismissButton: .default(
                    Text("好"),
                    action: {isPresented = false}
                )
            )
        }
    }
}


