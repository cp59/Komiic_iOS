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
    var offlineResource = false
    private let userDefaults = UserDefaults()
    @State private var chapterPath:URL?
    @State private var chaptersList:[KomiicAPI.Chapters] = []
    @State private var specChapterId:String = ""
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
    @State private var reachedImageLimit = false
    @State private var currentPage = ""
    @State private var lastReadPage = -1
    @State private var haveLastReadRecord = false
    @State private var pageSelection = ""
    @State private var currentChapterHaveOfflineResource = false
    @State private var imgRequestModifier = AnyModifier {r in return r}
    @State private var useFullScreen = false
    private let safeAreaTopHeight = UIApplication.shared.keyWindow!.safeAreaInsets.top
    init (comicId: String,isPresented: Binding<Bool>, offlineResource:Bool = false) {
        self.comicId = comicId
        _isPresented = isPresented
        self.offlineResource = offlineResource
        useSecondReadMode = userDefaults.bool(forKey: "useSecondReadMode")
        useFullScreen = userDefaults.bool(forKey: "useFullScreen")
    }
    private let token = KeychainSwift().get("token") ?? ""
    var body: some View {
        GeometryReader {proxy in
            HStack{}.onChange(of: proxy.size.width){_ in viewWidth=proxy.size.width}.onAppear{viewWidth=proxy.size.width}}.frame(height: 0)
        ZStack (alignment: .top){
            if (!useSecondReadMode) {
                ScrollViewReader {scrollView in
                    ScrollView {
                        LazyVStack {
                            Spacer().frame(height: safeAreaTopHeight)
                            ForEach(Array(picList.enumerated()), id:\.element.id) { page,img in
                                if (!currentChapterHaveOfflineResource) {
                                    KFImage(URL(string:"https://komiic.com/api/image/\(img.kid)"))
                                        .requestModifier(imgRequestModifier)
                                        .placeholder { _ in
                                            VStack {
                                                Spacer()
                                                ProgressView().tint(.white)
                                                Spacer()
                                            }.frame(width:viewWidth).aspectRatio(CGSize(width: img.width, height: img.height), contentMode: .fill)
                                                .background(Color(UIColor.darkGray)).cornerRadius(10).padding(10)
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
                                        .padding(EdgeInsets(top: -2, leading: 0, bottom: -2, trailing: 0))
                                        .id("\(page)_\(img.kid)")
                                        .scaledToFill()
                                } else {
                                    KFImage(source: .provider(LocalFileImageDataProvider(fileURL: chapterPath!.appendingPathComponent("images").appendingPathComponent("\(img.kid).jpeg"))))
                                        .requestModifier(imgRequestModifier)
                                        .placeholder { _ in
                                            VStack {
                                                Spacer()
                                                ProgressView().tint(.white)
                                                Spacer()
                                            }.frame(width:viewWidth).aspectRatio(CGSize(width: img.width, height: img.height), contentMode: .fill)
                                                .background(Color(UIColor.darkGray)).cornerRadius(10).padding(10)
                                        }
                                        .onSuccess { _ in
                                            currentPage = "\(page)_\(img.kid)"
                                            pageSelection = currentPage
                                        }
                                        .diskCacheExpiration(.expired)
                                        .fade(duration: 0.25)
                                        .cancelOnDisappear(true)
                                        .resizable()
                                        .padding(EdgeInsets(top: -2, leading: 0, bottom: -2, trailing: 0))
                                        .id("\(page)_\(img.kid)")
                                        .scaledToFill()
                                }
                            }.onAppear {
                                if (userDefaults.bool(forKey: "notFinishedReading")) {
                                    scrollView.scrollTo(userDefaults.string(forKey: "lastReadPage"))
                                    userDefaults.set(false, forKey: "notFinishedReading")
                                }
                                scrollView.scrollTo(pageSelection)
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
                            if (!currentPage.isEmpty && !offlineResource) {
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
                }
            } else {
                TabView (selection: $pageSelection){
                    ForEach(Array(picList.enumerated()), id:\.element.id) { page,img in
                        if (!currentChapterHaveOfflineResource) {
                            KFImage(URL(string:"https://komiic.com/api/image/\(img.kid)"))
                                .requestModifier(imgRequestModifier)
                                .placeholder { _ in
                                    VStack {
                                        Spacer()
                                        ProgressView().tint(.white)
                                        Spacer()
                                    }.frame(width:viewWidth).aspectRatio(CGSize(width: img.width, height: img.height), contentMode: .fill)
                                        .background(Color(UIColor.darkGray)).cornerRadius(10).padding(10)
                                }
                                .onFailure{error in
                                    app.komiicApi.reachedImageLimit(completion: {status in reachedImageLimit = status})
                                }
                                .onSuccess { _ in
                                    currentPage = "\(page)_\(img.kid)"
                                    if (app.isLogin) {
                                        app.komiicApi.addReadComicHistory(comicId: comicId, chapterId: specChapterId, page: page)
                                    }
                                }
                                .diskCacheExpiration(.expired)
                                .fade(duration: 0.25)
                                .cancelOnDisappear(true)
                                .resizable()
                                .padding(EdgeInsets(top: -2, leading: 0, bottom: -2, trailing: 0))
                                .tag("\(page)_\(img.kid)")
                                .scaledToFit()
                        } else {
                            KFImage(source: .provider(LocalFileImageDataProvider(fileURL: chapterPath!.appendingPathComponent("images").appendingPathComponent("\(img.kid).jpeg"))))
                                .requestModifier(imgRequestModifier)
                                .placeholder { _ in
                                    VStack {
                                        Spacer()
                                        ProgressView().tint(.white)
                                        Spacer()
                                    }.frame(width:viewWidth).aspectRatio(CGSize(width: img.width, height: img.height), contentMode: .fill)
                                        .background(Color(UIColor.darkGray)).cornerRadius(10).padding(10)
                                }
                                .onSuccess { _ in
                                    currentPage = "\(page)_\(img.kid)"
                                }
                                .diskCacheExpiration(.expired)
                                .fade(duration: 0.25)
                                .cancelOnDisappear(true)
                                .resizable()
                                .padding(EdgeInsets(top: -2, leading: 0, bottom: -2, trailing: 0))
                                .tag("\(page)_\(img.kid)")
                                .scaledToFit()
                        }
                        }.onAppear {
                            if (userDefaults.bool(forKey: "notFinishedReading")) {
                                pageSelection = (userDefaults.string(forKey: "lastReadPage"))!
                                userDefaults.set(false, forKey: "notFinishedReading")
                            }
                        }.onChange(of: haveLastReadRecord) { _ in
                            if (lastReadPage != -1) {
                                pageSelection = ("\(lastReadPage)_\(picList[lastReadPage].kid)")
                                lastReadPage = -1
                            }
                        }
                    if (!currentPage.isEmpty && !offlineResource) {
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
                }.tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
            }
            if (showingButton || !useFullScreen) {
                HStack {
                    Spacer()
                }.background(.black).frame(height: safeAreaTopHeight+30)
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
        }.snackbar(isShowing: $haveLastReadRecord, title: "將從上次閱讀的地方開始",text: "因為你登入的帳號有此漫畫的閱讀紀錄" ,style: .custom(.blue)).onReceive(NotificationCenter.default.publisher(for: UIApplication.willTerminateNotification), perform: { output in
            let userDefaults = UserDefaults()
            userDefaults.setValue(true, forKey: "notFinishedReading")
            userDefaults.setValue(comicId, forKey: "lastReadComicId")
            userDefaults.setValue(specChapterId, forKey: "lastReadChapterId")
            userDefaults.setValue(currentPage, forKey: "lastReadPage")
        }).overlay(alignment:.topTrailing) {
            ExitButtonView().frame(width: 20,height: 20).opacity(showingButton ? 1 : 0).padding(EdgeInsets(top: safeAreaTopHeight+5, leading: 15, bottom: 15, trailing: 15)).onTapGesture {
                ImageCache.default.clearMemoryCache()
                isPresented = false
            }
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
                }.opacity(showingButton ? 1 : 0).padding(10).sheet(isPresented: $showingChapterPicker, content: { [chaptersList] in
                    let comicPath = app.docURL.appendingPathComponent(comicId)
                    NavigationView {
                        List {
                            if (offlineResource) {
                                Text("目前為離線模式，只允許閱讀已下載的章節，若要返回線上模式，請從書櫃或書庫閱讀此漫畫。").font(.caption)
                            }
                            Section {
                                ForEach(Array(chaptersList.enumerated()),id: \.element.id) { index,chapter in
                                    let currentChapterBadge = (specChapterId == chapter.id ? "目前章節" : "\(chapter.size)p")
                                    let downloadedBadge = (FileManager.default.fileExists(atPath: comicPath.appendingPathComponent(chapter.id).path) ? "(已下載)" : "")
                                    if (chapter.type == "book") {
                                        Button(chapter.serial+"卷") {
                                            specChapterId = chapter.id
                                            currentChapterIndex = index
                                            chapterIsBook = true
                                            showingChapterPicker = false
                                        }.badge("\(currentChapterBadge) \(downloadedBadge)")
                                        .onAppear{haveBook = true}.disabled(offlineResource && !FileManager.default.fileExists(atPath: comicPath.appendingPathComponent(chapter.id).path))
                                    }
                                }
                            } header: {
                                if (haveBook) {
                                    Text("卷")
                                }
                            }
                            Section {
                                ForEach(Array(chaptersList.enumerated()),id: \.element.id) { index,chapter in
                                    let currentChapterBadge = (specChapterId == chapter.id ? "目前章節" : "\(chapter.size)p")
                                    let downloadedBadge = (FileManager.default.fileExists(atPath: comicPath.appendingPathComponent(chapter.id).path) ? "(已下載)" : "")
                                    if (chapter.type == "chapter") {
                                        Button(chapter.serial+"話") {
                                            specChapterId = chapter.id
                                            currentChapterIndex = index
                                            chapterIsBook = false
                                            showingChapterPicker = false
                                        }.badge("\(currentChapterBadge) \(downloadedBadge)").onAppear{haveChapter = true}.disabled(offlineResource && !FileManager.default.fileExists(atPath: comicPath.appendingPathComponent(chapter.id).path))
                                    }
                                }
                            } header: {
                                if (haveChapter) {
                                    Text("話")
                                }
                            }
                        }.navigationTitle("選擇章節").navigationBarItems(trailing:
                            Button (action: {
                                if (specChapterId == "") {
                                    isPresented = false
                                }
                                showingChapterPicker = false
                            }) {
                                ExitButtonView()
                            }.padding(5)
                        ).padding(EdgeInsets(top: 10, leading: 0, bottom: 0, trailing: 0))
                    }
                    
                }).sheet(isPresented: $showingReaderSettings, content: {
                    NavigationView {
                        List {
                            Toggle(isOn: $useSecondReadMode, label: {
                                Text("使用翻頁模式")
                            }).onChange(of: useSecondReadMode) { _ in userDefaults.setValue(useSecondReadMode, forKey: "useSecondReadMode")}
                            Toggle(isOn: $useFullScreen, label: {
                                Text("使用全螢幕顯示")
                            }).onChange(of: useFullScreen) { _ in userDefaults.setValue(useFullScreen, forKey: "useFullScreen")}
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
            imgRequestModifier = AnyModifier {request in
                var r = request
                r.addValue("https://komiic.com/comic/\(comicId)/chapter/\(specChapterId)/images/all", forHTTPHeaderField: "referer")
                if (app.isLogin) {
                    r.addValue("Bearer \(app.token)", forHTTPHeaderField: "authorization")
                }
                return r
            }
            app.komiicApi.getChapterByComicId(comicId: comicId, completion: { chapters in
                if (!offlineResource) {
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
                                    specChapterId = firstChapter.id
                                } else {
                                    self.lastReadPage = lastReadPage
                                    specChapterId = String(biggestId)
                                }
                            } else {
                                let firstChapter = chapters.first!
                                specChapterId.append(firstChapter.id)
                            }
                        })
                    } else {
                        specChapterId = userDefaults.string(forKey: "lastReadChapterId")!
                    }
                }
                chaptersList.append(contentsOf: chapters)
                if (offlineResource) {
                    showingChapterPicker = true
                }
            })
        }
        .onChange(of: specChapterId) { _ in
            picList.removeAll()
            currentPage = ""
            pageSelection = ""
            chapterPath = app.docURL.appendingPathComponent(comicId).appendingPathComponent(specChapterId)
            if (FileManager.default.fileExists(atPath: chapterPath!.path)) {
                currentChapterHaveOfflineResource = true
                do {
                    picList = try JSONDecoder().decode([KomiicAPI.ComicImages].self, from: Data(contentsOf: chapterPath!.appendingPathComponent("imgList.json")))
                } catch {
                    print(error)
                }
            } else {
                currentChapterHaveOfflineResource = false
                app.komiicApi.getImagesByChapterId(chapterId: specChapterId, completion: {imagesList in
                    picList = imagesList
                    if (lastReadPage != -1) {
                        haveLastReadRecord = true
                    }
                })
            }
        }.alert(isPresented: $reachedImageLimit) {
            Alert(
                title: Text("已達到當前圖片讀取量限制"),
                message: Text("若未登入帳號，可登入帳號來將限制提高至800張"),
                dismissButton: .default(
                    Text("好"),
                    action: {isPresented = false}
                )
            )
        }.statusBarHidden(!showingButton && useFullScreen)
    }
}


