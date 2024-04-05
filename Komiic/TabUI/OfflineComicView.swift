//
//  OfflineComicView.swift
//  Komiic
//
//  Created by 梁承樸 on 2024/4/4.
//

import SwiftUI

struct OfflineComicView: View {
    @EnvironmentObject var app:app
    @State private var showingManageSheet = false
    @State private var comicList:[OfflineComicData] = []
    var body: some View {
        NavigationView {
            ComicListView(title: "離線下載", requestParameters: "", listType: 5).toolbar {
                Button("管理") {
                    showingManageSheet = true
                }
            }.onFirstAppear {
                do {
                    var tempComicList:[OfflineComicData] = []
                    let directoryContents = try FileManager.default.contentsOfDirectory(at: app.docURL, includingPropertiesForKeys: nil)
                    let comicFolders = directoryContents.filter{$0.lastPathComponent != ".Trash"}
                    for folder in comicFolders {
                        var offlineChapterList:[OfflineComicChapter] = []
                        let chapterList = try JSONDecoder().decode([KomiicAPI.Chapters].self, from: Data(contentsOf: folder.appendingPathComponent("chapters.json")))
                        for chapter in chapterList {
                            if (FileManager.default.fileExists(atPath: folder.appendingPathComponent(chapter.id).path)) {
                                offlineChapterList.append(OfflineComicChapter(id:  chapter.id, name: chapter.serial + (chapter.type == "book" ? "卷" : "話")))
                            }
                        }
                        tempComicList.append(OfflineComicData(id: folder.lastPathComponent, name: try String(contentsOf: folder.appendingPathComponent("comicTitle.txt"), encoding: .utf8), chapters: offlineChapterList))
                    }
                    comicList.append(contentsOf: tempComicList)
                } catch {
                    print(error)
                }
            }.sheet(isPresented: $showingManageSheet, content: { [comicList] in
                NavigationView {
                    List {
                        ForEach(comicList, id: \.id) {comic in
                            Section {
                                ForEach(comic.chapters, id: \.id) { chapter in
                                    Text(chapter.name)
                                }
                            } header: {
                                Text(comic.name)
                            }
                        }.onDelete(perform: { indexSet in
                            let deleteComic = comicList[indexSet.first!]
                            self.comicList.remove(at: indexSet.first!)
                            do {
                                try FileManager.default.removeItem(at: app.docURL.appendingPathComponent(deleteComic.id))
                            } catch {
                                print(error)
                            }
                        })
                    }.navigationTitle("管理下載內容").navigationBarItems(trailing:
                        Button (action: {
                            showingManageSheet = false
                        }) {
                            ExitButtonView()
                        }.padding(5)
                    ).padding(EdgeInsets(top: 10, leading: 0, bottom: 0, trailing: 0)).id(UUID())
                }
                
            })
        }
    }
}
struct OfflineComicChapter:Codable {
    let id:String
    let name:String
}
struct OfflineComicData:Identifiable {
    let id:String
    let name:String
    let chapters:[OfflineComicChapter]
}
#Preview {
    OfflineComicView()
}
