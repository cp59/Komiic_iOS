//
//  DownloadView.swift
//  Komiic
//
//  Created by 梁承樸 on 2024/4/4.
//

import SwiftUI
import CustomAlert

struct ComicDownloadView: View {
    @EnvironmentObject var app:app
    @State private var chaptersList: [KomiicAPI.Chapters] = []
    @State private var haveBook = false
    @State private var haveChapter = false
    @State private var startDownload = false
    @State private var selectedChapter:KomiicAPI.Chapters?
    @State private var showAlreadyDownloadedAlert = false
    @State private var downloadSuccess = false
    @State private var downloadFailed = false
    @State private var downloadProgress = 0
    var comic: KomiicAPI.ComicData
    var body: some View {
        VStack (spacing : 0){
            if (chaptersList.isEmpty) {
                Spacer()
                ProgressView()
                Spacer()
            } else {
                List {
                    Section {
                        ForEach(Array(chaptersList.enumerated()),id: \.element.id) { index,chapter in
                            if (chapter.type == "book") {
                                Button(chapter.serial+"卷") {
                                    selectedChapter = chapter
                                    startDownload = true
                                }.badge("\(chapter.size)p")
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
                                    selectedChapter = chapter
                                    startDownload = true
                                }.badge("\(chapter.size)p").onAppear{haveChapter = true}
                            }
                        }
                    } header: {
                        if (haveChapter) {
                            Text("話")
                        }
                    }
                }.customAlert(isPresented: $startDownload, content: {
                    HStack (spacing: 10){
                        ProgressView().tint(.primary)
                        Text("下載中...\(downloadProgress)%").font(.caption)
                    }
                }, actions: {})
                .onChange(of: startDownload) { _ in
                    downloadProgress = 0
                    if (startDownload) {
                        let selectedChapterId = selectedChapter!.id
                        let comicDataPath = app.docURL.appendingPathComponent(comic.id)
                        if !FileManager.default.fileExists(atPath: comicDataPath.path) {
                            do {
                                try FileManager.default.createDirectory(atPath: comicDataPath.path, withIntermediateDirectories: true, attributes: nil)
                            } catch {
                                print(error.localizedDescription)
                                startDownload = false
                                downloadFailed = true
                            }
                        }
                        downloadComicDataIfNeeded(comicPath: comicDataPath, completion: { result in
                            let chapterDataPath = comicDataPath.appendingPathComponent(selectedChapter!.id)
                            if !FileManager.default.fileExists(atPath: chapterDataPath.path) {
                                do {
                                    try FileManager.default.createDirectory(atPath: chapterDataPath.path, withIntermediateDirectories: true, attributes: nil)
                                    let imagePath = chapterDataPath.appendingPathComponent("images")
                                    try FileManager.default.createDirectory(atPath: imagePath.path, withIntermediateDirectories: true, attributes: nil)
                                    app.komiicApi.getImagesByChapterId(chapterId: selectedChapter!.id, completion: {resp in
                                        let imagesCount = Float(resp.count)
                                        do {
                                            let jsonEncoder = JSONEncoder()
                                            let imageListJsonData = try jsonEncoder.encode(resp)
                                            try imageListJsonData.write(to: chapterDataPath.appendingPathComponent("imgList.json"))
                                            Task {
                                                do {
                                                    for (index,image) in resp.enumerated() {
                                                        var urlRequest = URLRequest(url: URL(string: "https://komiic.com/api/image/\(image.kid)")!)
                                                        urlRequest.addValue("https://komiic.com/comic/\(comic.id)/chapter/\(selectedChapterId)/images/all", forHTTPHeaderField: "referer")
                                                        if (app.isLogin) {
                                                            urlRequest.addValue("Bearer \(app.token)", forHTTPHeaderField: "authorization")
                                                        }
                                                        let (location, _) = try await URLSession.shared.download(for: urlRequest)
                                                        try FileManager.default.moveItem(atPath: location.path, toPath: imagePath.appendingPathComponent("\(image.kid).jpeg").path)
                                                        downloadProgress = Int((Float(index+1)/imagesCount)*100)
                                                    }
                                                    startDownload = false
                                                    downloadSuccess = true
                                                } catch {
                                                    print(error)
                                                    startDownload = false
                                                    downloadFailed = true
                                                }
                                            }
                                        } catch {
                                            startDownload = false
                                            downloadFailed = true
                                        }})
                                } catch {
                                    print(error.localizedDescription)
                                    startDownload = false
                                    downloadFailed = true
                                }
                            } else {
                                startDownload = false
                                showAlreadyDownloadedAlert = true
                            }
                        })
                    }
                }
                Text("").frame(width: 0,height: 0).alert(isPresented: $showAlreadyDownloadedAlert) {
                    Alert(title: Text("已經下載過此章節"),
                          message: Text("若要重新下載，請先前往離線漫畫管理頁面刪除該章節，然後再下載一次。"))
                }
                Text("").frame(width: 0,height: 0).alert(isPresented: $downloadSuccess) {
                    Alert(title: Text("成功下載此章節"),
                          message: Text("要閱讀離線內容，請前往離線漫畫管理頁面。"))
                }
                Text("").frame(width: 0,height: 0).alert(isPresented: $downloadFailed) {
                    Alert(title: Text("下載失敗"),
                          message: Text("請確認網際網路連線，以及目前可存取的漫畫圖片數量是否足以下載此章節。"))
                }
            }
        }.navigationTitle("下載離線漫畫").onFirstAppear {
            app.komiicApi.getChapterByComicId(comicId: comic.id, completion: {resp in chaptersList = resp})
        }
    }
    func downloadComicDataIfNeeded(comicPath:URL, completion:(@escaping (Bool) -> Void)) {
        do {
            try comic.title.write(to: comicPath.appendingPathComponent("comicTitle.txt"), atomically: false, encoding: .utf8)
        } catch {
            
        }
        if FileManager.default.fileExists(atPath: comicPath.appendingPathComponent("cover.jpg").path) {
            return completion(true)
        }
        URLSession.shared.dataTask(with: URL(string: comic.imageUrl)!) { data, response, error in
            guard let data = data else { return completion(false) }
            do {
                try data.write(to: comicPath.appendingPathComponent("cover.jpg"))
                let jsonEncoder = JSONEncoder()
                let imageListJsonData = try jsonEncoder.encode(chaptersList)
                try imageListJsonData.write(to: comicPath.appendingPathComponent("chapters.json"))
                try comic.title.write(to: comicPath.appendingPathComponent("comicTitle.txt"), atomically: false, encoding: .utf8)
                return completion(true)
            } catch {
                print(error)
                return completion(false)
            }
            
        }.resume()
    }
}

