//
//  komiicApi.swift
//  Komiic
//
//  Created by 梁承樸 on 2024/3/10.
//

import Foundation
import KeychainSwift

struct KomiicAPI {
    private let keychain = KeychainSwift()
    let apiUrl = "https://komiic.com"
    func fetchList<T: Decodable>(of type: T.Type, parameters: String, page: Int = 0, completion: @escaping ([T]) -> Void) {
        let token = keychain.get("token") ?? ""
        let formatParameters = parameters.replacingOccurrences(of: "[page]", with: String(page*20))
        let postData = formatParameters.data(using: .utf8)
        var urlRequest = URLRequest(url: URL(string: "\(apiUrl)/api/query")!)
        urlRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")
        if (!token.isEmpty) {
            urlRequest.addValue("Bearer \(keychain.get("token")!)", forHTTPHeaderField: "authorization")
        }
        urlRequest.httpMethod = "POST"
        urlRequest.httpBody = postData
        let task = URLSession.shared.dataTask(with: urlRequest) {data, response, error in
            guard let data = data else {
                return completion([])
            }
            let respText = String(data: data, encoding: .utf8)!
            if (respText.index(of: "[{") == nil) {
                return completion([])
            }
            let startIndex = respText.index(of: "[{")!
            let endIndex:String.Index
            if (parameters.starts(with: "{\"query\":\"query searchComicAndAuthorQuery")) {
                endIndex = respText.index(respText.endIndex, offsetBy: -3)
            } else {
                endIndex = respText.index(respText.endIndex, offsetBy: -2)
            }
            do {
                let comics = try JSONDecoder().decode([T].self, from: Data(String(respText[startIndex..<endIndex]).utf8))
                return completion(comics)
            } catch {
                print(error)
                print(respText)
                return completion([])
            }
        }
        task.resume()
    }   
    func fetchRecommendComicById (comicId: String, completion:(@escaping (String) -> Void)) {
        let formatParameters = "{\"query\":\"query recommendComicById($comicId: ID!) {\\n  recommendComicById(comicId: $comicId)\\n}\",\"variables\":{\"comicId\":\"\(comicId)\"}}"
        let postData = formatParameters.data(using: .utf8)
        var request = URLRequest(url: URL(string: "https://komiic.com/api/query")!)
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "POST"
        request.httpBody = postData
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data else {
                print(String(describing: error))
                return completion("")
            }
            let resp = String(data: data, encoding: .utf8)!
            if (resp.contains("[]")) {
                return completion("")
            }
            let startIndex = resp.index(of: "[\"")
            let endIndex = resp.index(resp.endIndex, offsetBy: -2)
            return completion(String(resp[startIndex!..<endIndex]))
        }
        task.resume()
    }
    func getMessagesByComicId (comicId: String,page: Int = 0 , completion:(@escaping ([ComicMessage]) -> Void)) {
        let formatParameters = "{\"query\":\"query getMessagesByComicId($comicId: ID!, $pagination: Pagination!) {\\n  getMessagesByComicId(comicId: $comicId, pagination: $pagination) {\\n    id\\n    account {\\n      nickname\\n    }\\n    message\\n    replyTo {\\n      id\\n      message\\n      account {\\n        nickname\\n      }\\n    }\\n    upCount\\n    downCount\\n    dateUpdated\\n    dateCreated\\n  }\\n}\",\"variables\":{\"comicId\":\"\(comicId)\",\"pagination\":{\"limit\":100,\"offset\":\(page*100),\"orderBy\":\"DATE_UPDATED\",\"asc\":true}}}"
        fetchList(of: ComicMessage.self, parameters: formatParameters, completion: { resp in
            return completion(resp)})
    }
    func getChapterByComicId (comicId: String, completion:(@escaping ([Chapters]) -> Void)) {
        let formatParameters = "{\"query\":\"query chapterByComicId($comicId: ID!) {\\n  chaptersByComicId(comicId: $comicId) {\\n    id\\n    serial\\n    type\\n    size\\n  }\\n}\",\"variables\":{\"comicId\":\"\(comicId)\"}}"
        fetchList(of: Chapters.self, parameters: formatParameters, completion: { resp in
            return completion(resp)})
    }
    func getImagesByChapterId (chapterId: String, completion:(@escaping ([ComicImages]) -> Void)) {
        let formatParameters = "{\"query\":\"query imagesByChapterId($chapterId: ID!) {\\n  imagesByChapterId(chapterId: $chapterId) {\\n    id\\n    kid\\n    height\\n    width\\n  }\\n}\",\"variables\":{\"chapterId\":\"\(chapterId)\"}}"
        fetchList(of: ComicImages.self, parameters: formatParameters, completion: { resp in
            return completion(resp)})
    }
    func fetchComicList(parameters: String, page: Int = 0,completion:(@escaping ([ComicData]) -> Void)) {
        fetchList(of: ComicData.self, parameters: parameters,page: page , completion: { resp in
            return completion(resp)})
    }
    func fetchComicHistory(page:Int = 0,completion:(@escaping ([ComicHistory]) -> Void)) {
        let formatParameters = "{\"query\":\"query readComicHistory($pagination: Pagination!) {\\n  readComicHistory(pagination: $pagination) {\\n    id\\n    comicId\\n    chapters {\\n      id\\n      chapterId\\n      page\\n    }\\n    startDate\\n    lastDate\\n    chapterType\\n  }\\n}\",\"variables\":{\"pagination\":{\"limit\":20,\"offset\":\(page*20),\"orderBy\":\"DATE_UPDATED\",\"asc\":true}}}"
        fetchList(of: ComicHistory.self, parameters: formatParameters,page: page , completion: { resp in
            return completion(resp)})
    }
    func fetchFavoritesComic(parameters: String = RequestParameters().getFavoritesComic(),page:Int = 0,completion:(@escaping ([FavoritesComic]) -> Void)) {
        let formatParameters = parameters.replacingOccurrences(of: "[page]", with: String(page*20))
        fetchList(of: FavoritesComic.self, parameters: formatParameters,page: page , completion: { resp in
            return completion(resp)})
    }
    func fetchCategoryList(completion:(@escaping ([ComicCategories]) -> Void)) {
        let formatParameters = "{\"query\":\"query allCategory {\\n  allCategory {\\n    id\\n    name\\n  }\\n}\",\"variables\":{}}"
        fetchList(of: ComicCategories.self, parameters: formatParameters, completion: { resp in
            return completion(resp)})
    }
    func fetchComicFolders(completion:(@escaping ([ComicFolder]) -> Void)) {
        let formatParameters = "{\"query\":\"query myFolder {\\n  folders {\\n    id\\n    key\\n    name\\n    views\\n    comicCount\\n  }\\n}\",\"variables\":{}}"
        fetchList(of: ComicFolder.self, parameters: formatParameters, completion: { resp in
            return completion(resp)})
    }
    func login(email: String,password: String, completion:(@escaping (String) -> Void)) {
        let parameters = "{\"email\":\"\(email)\",\"password\":\"\(password)\"}"
        let postData = parameters.data(using: .utf8)
        var request = URLRequest(url: URL(string: "https://komiic.com/auth/login")!,timeoutInterval: Double.infinity)
        request.addValue("text/plain", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "POST"
        request.httpBody = postData
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let httpResponse = response as? HTTPURLResponse {
                if (httpResponse.statusCode == 400) {
                    return completion("")
                }
                let token = String(data: data!, encoding: .utf8)!
                return completion(String(token[token.index(token.startIndex, offsetBy: 10)..<token.index(token.endIndex, offsetBy: -2)]))
            }
        }
        task.resume()

    }
    func reachedImageLimit(completion:(@escaping (Bool) -> Void)) {
        let token = keychain.get("token") ?? ""
        let parameters = "{\"query\":\"query reachedImageLimit {\\n  reachedImageLimit\\n}\",\"variables\":{}}"
        let postData = parameters.data(using: .utf8)
        var request = URLRequest(url: URL(string: "https://komiic.com/auth/login")!,timeoutInterval: Double.infinity)
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        if (!token.isEmpty) {
            request.addValue("Bearer \(keychain.get("token")!)", forHTTPHeaderField: "authorization")
        }
        request.httpMethod = "POST"
        request.httpBody = postData
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data else {
                return completion(false)
            }
            return completion(String(data: data, encoding: .utf8)!.contains("true"))
        }
        task.resume()

    }
    func getAccountInfo(completion:(@escaping (AccountInfo) -> Void)) {
        let parameters = "{\"query\":\"query accountQuery {\\n  account {\\n    id\\n    email\\n    nickname\\n    dateCreated\\n    totalDonateAmount\\n    monthDonateAmount\\n    nextChapterMode\\n    \\n favoriteComicIds\\n}\\n}\",\"variables\":{}}"
        let postData = parameters.data(using: .utf8)
        var request = URLRequest(url: URL(string: "https://komiic.com/api/query")!)
        request.addValue("Bearer \(keychain.get("token")!)", forHTTPHeaderField: "authorization")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "POST"
        request.httpBody = postData
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data else {
                print(String(describing: error))
                return completion(AccountInfo(id: "", email: "", nickname: "", dateCreated: "", nextChapterMode: "", totalDonateAmount: 0, monthDonateAmount: 0, favoriteComicIds: []))
            }
            let resp = String(data: data, encoding: .utf8)!
            let startIndex = resp.index(resp.startIndex, offsetBy: 19)
            let endIndex = resp.index(resp.endIndex, offsetBy: -2)
            do {
                let accountInfo = try JSONDecoder().decode(AccountInfo.self, from: Data(String(resp[startIndex..<endIndex]).utf8))
                return completion(accountInfo)
            } catch {
                print(error)
                return completion(AccountInfo(id: "tokenExpired", email: "", nickname: "", dateCreated: "", nextChapterMode: "", totalDonateAmount: 0, monthDonateAmount: 0, favoriteComicIds: []))
            }
        }
        task.resume()
    }
    func getImageLimit(completion:(@escaping (ImageLimit) -> Void)) {
        let parameters = "{\"query\":\"query getImageLimit {\\n  getImageLimit {\\n    limit\\n    usage\\n    resetInSeconds\\n  }\\n}\",\"variables\":{}}"
        let postData = parameters.data(using: .utf8)
        var request = URLRequest(url: URL(string: "https://komiic.com/api/query")!)
        request.addValue("Bearer \(keychain.get("token")!)", forHTTPHeaderField: "authorization")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "POST"
        request.httpBody = postData
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data else {
                print(String(describing: error))
                return completion(ImageLimit(limit: 0, usage: 0, resetInSeconds: "0"))
            }
            let resp = String(data: data, encoding: .utf8)!
            let startIndex = resp.index(resp.startIndex, offsetBy: 25)
            let endIndex = resp.index(resp.endIndex, offsetBy: -2)
            do {
                let imageLimit = try JSONDecoder().decode(ImageLimit.self, from: Data(String(resp[startIndex..<endIndex]).utf8))
                return completion(imageLimit)
            } catch {
                print(error)
                return completion(ImageLimit(limit: 0, usage: 0, resetInSeconds: "0"))
            }
        }
        task.resume()
    }
    func fetchFolderComics(parameters: String, page:Int = 0, completion:(@escaping (String) -> Void)) {
        let formatParameters = parameters.replacingOccurrences(of: "[page]", with: String(page*20))
        let postData = formatParameters.data(using: .utf8)
        var request = URLRequest(url: URL(string: "https://komiic.com/api/query")!)
        request.addValue("Bearer \(keychain.get("token")!)", forHTTPHeaderField: "authorization")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "POST"
        request.httpBody = postData
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data else {
                print(String(describing: error))
                return completion("")
            }
            let resp = String(data: data, encoding: .utf8)!
            if (resp.contains("[]")) {
                return completion("")
            }
            let startIndex = resp.index(of: "[\"")
            let endIndex = resp.index(resp.endIndex, offsetBy: -3)
            return completion(String(resp[startIndex!..<endIndex]))
        }
        task.resume()
    }
    func comicInAccountFolders(comicId: String, completion:(@escaping ([String]) -> Void)) {
        let formatParameters = "{\"query\":\"query comicInAccountFolders($comicId: ID!) {\\n  comicInAccountFolders(comicId: $comicId)\\n}\",\"variables\":{\"comicId\":\"\(comicId)\"}}"
        let postData = formatParameters.data(using: .utf8)
        var request = URLRequest(url: URL(string: "https://komiic.com/api/query")!)
        request.addValue("Bearer \(keychain.get("token")!)", forHTTPHeaderField: "authorization")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "POST"
        request.httpBody = postData
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data else {
                print(String(describing: error))
                return completion([])
            }
            let resp = String(data: data, encoding: .utf8)!
            if (resp.contains("[]")) {
                return completion([])
            }
            let startIndex = resp.index(of: "[\"")!
            let endIndex = resp.index(resp.endIndex, offsetBy: -2)
            do {
                let comicInAccountFolders = try JSONDecoder().decode([String].self, from: Data(String(resp[startIndex..<endIndex]).utf8))
                return completion(comicInAccountFolders)
            } catch {
                print(error)
                return completion([])
            }
        }
        task.resume()
    }
    func addReadComicHistory(comicId: String, chapterId: String, page: Int) {
        let parameters = "{\"query\":\"mutation addReadComicHistory($comicId: ID!, $chapterId: ID!, $page: Int!) {\\n  addReadComicHistory(comicId: $comicId, chapterId: $chapterId, page: $page) {\\n    id\\n  }\\n}\",\"variables\":{\"comicId\":\"\(comicId)\",\"chapterId\":\"\(chapterId)\",\"page\":\(page)}}"
        let postData = parameters.data(using: .utf8)
        var request = URLRequest(url: URL(string: "https://komiic.com/api/query")!,timeoutInterval: Double.infinity)
        request.addValue("Bearer \(keychain.get("token")!)", forHTTPHeaderField: "authorization")
        request.addValue("application/json", forHTTPHeaderField: "content-type")
        request.httpMethod = "POST"
        request.httpBody = postData
        let task = URLSession.shared.dataTask(with: request) { data, response, error in }
        task.resume()
    }
    func removeComicToFolder(comicId: String, folderId: String) {
        let parameters = "{\"query\":\"mutation removeComicToFolder($comicId: ID!, $folderId: ID!) {\\n  removeComicToFolder(comicId: $comicId, folderId: $folderId)\\n}\",\"variables\":{\"comicId\":\"\(comicId)\",\"folderId\":\"\(folderId)\"}}"
        let postData = parameters.data(using: .utf8)
        var request = URLRequest(url: URL(string: "https://komiic.com/api/query")!,timeoutInterval: Double.infinity)
        request.addValue("Bearer \(keychain.get("token")!)", forHTTPHeaderField: "authorization")
        request.addValue("application/json", forHTTPHeaderField: "content-type")
        request.httpMethod = "POST"
        request.httpBody = postData
        let task = URLSession.shared.dataTask(with: request) { data, response, error in }
        task.resume()
    }
    func addComicToFolder(comicId: String, folderId: String) {
        let parameters = "{\"query\":\"mutation addComicToFolder($comicId: ID!, $folderId: ID!) {\\n  addComicToFolder(comicId: $comicId, folderId: $folderId)\\n}\",\"variables\":{\"comicId\":\"\(comicId)\",\"folderId\":\"\(folderId)\"}}"
        let postData = parameters.data(using: .utf8)
        var request = URLRequest(url: URL(string: "https://komiic.com/api/query")!,timeoutInterval: Double.infinity)
        request.addValue("Bearer \(keychain.get("token")!)", forHTTPHeaderField: "authorization")
        request.addValue("application/json", forHTTPHeaderField: "content-type")
        request.httpMethod = "POST"
        request.httpBody = postData
        let task = URLSession.shared.dataTask(with: request) { data, response, error in }
        task.resume()
    }
    func addFavorite(comicId: String) {
        let parameters = "{\"query\":\"mutation addFavorite($comicId: ID!) {\\n  addFavorite(comicId: $comicId) {\\n    id\\n    comicId\\n    dateAdded\\n    lastAccess\\n    bookReadProgress\\n    chapterReadProgress\\n    __typename\\n  }\\n}\",\"variables\":{\"comicId\":\"\(comicId)\"}}"
        let postData = parameters.data(using: .utf8)
        var request = URLRequest(url: URL(string: "https://komiic.com/api/query")!,timeoutInterval: Double.infinity)
        request.addValue("Bearer \(keychain.get("token")!)", forHTTPHeaderField: "authorization")
        request.addValue("application/json", forHTTPHeaderField: "content-type")
        request.httpMethod = "POST"
        request.httpBody = postData
        let task = URLSession.shared.dataTask(with: request) { data, response, error in }
        task.resume()
    }
    func removeFavorite(comicId: String) {
        let parameters = "{\"query\":\"mutation removeFavorite($comicId: ID!) {\\n  removeFavorite(comicId: $comicId)\\n}\",\"variables\":{\"comicId\":\"\(comicId)\"}}"
        let postData = parameters.data(using: .utf8)
        var request = URLRequest(url: URL(string: "https://komiic.com/api/query")!,timeoutInterval: Double.infinity)
        request.addValue("Bearer \(keychain.get("token")!)", forHTTPHeaderField: "authorization")
        request.addValue("application/json", forHTTPHeaderField: "content-type")
        request.httpMethod = "POST"
        request.httpBody = postData
        let task = URLSession.shared.dataTask(with: request) { data, response, error in }
        task.resume()
    }
    struct RequestParameters {
        func getRecentUpdate () -> String{
            return "{\"query\":\"query recentUpdate($pagination: Pagination!) {\\n  recentUpdate(pagination: $pagination) {\\n    id\\n    title\\n    status\\n    year\\n    imageUrl\\n    authors {\\n      id\\n      name\\n      \\n    }\\n    categories {\\n      id\\n      name\\n      \\n    }\\n    dateUpdated\\n    monthViews\\n    views\\n    favoriteCount\\n    lastBookUpdate\\n    lastChapterUpdate\\n    \\n  }\\n}\",\"variables\":{\"pagination\":{\"limit\":20,\"offset\":[page],\"orderBy\":\"DATE_UPDATED\",\"status\":\"\",\"asc\":true}}}"
        }
        func getHotComics () -> String {
            return "{\"query\":\"query hotComics($pagination: Pagination!) {\\n  hotComics(pagination: $pagination) {\\n    id\\n    title\\n    status\\n    year\\n    imageUrl\\n    authors {\\n      id\\n      name\\n    }\\n    categories {\\n      id\\n      name\\n    }\\n    dateUpdated\\n    monthViews\\n    views\\n    favoriteCount\\n    lastBookUpdate\\n    lastChapterUpdate\\n  }\\n}\",\"variables\":{\"pagination\":{\"limit\":20,\"offset\":[page],\"orderBy\":\"VIEWS\",\"status\":\"\",\"asc\":true}}}"
        }
        func getMonthHotComics () -> String {
            return "{\"query\":\"query hotComics($pagination: Pagination!) {\\n  hotComics(pagination: $pagination) {\\n    id\\n    title\\n    status\\n    year\\n    imageUrl\\n    authors {\\n      id\\n      name\\n    }\\n    categories {\\n      id\\n      name\\n    }\\n    dateUpdated\\n    monthViews\\n    views\\n    favoriteCount\\n    lastBookUpdate\\n    lastChapterUpdate\\n  }\\n}\",\"variables\":{\"pagination\":{\"limit\":20,\"offset\":[page],\"orderBy\":\"MONTH_VIEWS\",\"status\":\"\",\"asc\":true}}}"
        }
        func getComicsByAuthorId (authorId: String) -> String {
            return "{\"query\":\"query comicsByAuthor($authorId: ID!) {\\n  getComicsByAuthor(authorId: $authorId) {\\n    id\\n    title\\n    status\\n    year\\n    imageUrl\\n    authors {\\n      id\\n      name\\n    }\\n    categories {\\n      id\\n      name\\n    }\\n    dateUpdated\\n    monthViews\\n    views\\n    favoriteCount\\n    lastBookUpdate\\n    lastChapterUpdate\\n  }\\n}\",\"variables\":{\"authorId\":\"\(authorId)\"}}"
        }
        func searchComic (keyword: String) -> String {
            return "{\"query\":\"query searchComicAndAuthorQuery($keyword: String!) {\\n  searchComicsAndAuthors(keyword: $keyword) {\\n    comics {\\n      id\\n      title\\n      status\\n      year\\n      imageUrl\\n      authors {\\n        id\\n        name\\n      }\\n      categories {\\n        id\\n        name\\n      }\\n      dateUpdated\\n      monthViews\\n      views\\n      favoriteCount\\n      lastBookUpdate\\n      lastChapterUpdate\\n    }\\n  }\\n}\",\"variables\":{\"keyword\":\"\(keyword)\"}}"
        }
        func getComicsByCategory (categoryId: String, orderBy: String = "DATE_UPDATED", status: String = "") -> String {
            return "{\"query\":\"query comicByCategory($categoryId: ID!, $pagination: Pagination!) {\\n  comicByCategory(categoryId: $categoryId, pagination: $pagination) {\\n    id\\n    title\\n    status\\n    year\\n    imageUrl\\n    authors {\\n      id\\n      name\\n    }\\n    categories {\\n      id\\n      name\\n    }\\n    dateUpdated\\n    monthViews\\n    views\\n    favoriteCount\\n    lastBookUpdate\\n    lastChapterUpdate\\n  }\\n}\",\"variables\":{\"categoryId\":\"\(categoryId)\",\"pagination\":{\"limit\":20,\"offset\":[page],\"orderBy\":\"\(orderBy)\",\"asc\":false,\"status\":\"\(status)\"}}}"
        }
        func getFavoritesComic (orderBy: String = "COMIC_DATE_UPDATED", status: String = "", readProgress: String = "ALL") -> String {
            return "{\"query\":\"query favoritesQuery($pagination: Pagination!) {\\n  getLatestUpdatedDateInFavorite\\n  favoritesV2(pagination: $pagination) {\\n    id\\n    comicId\\n  }\\n}\",\"variables\":{\"pagination\":{\"limit\":20,\"offset\":[page],\"orderBy\":\"\(orderBy)\",\"status\":\"\(status)\",\"asc\":true,\"readProgress\":\"\(readProgress)\"}}}"
        }
        func getFolderComicIds (folderId: String, orderBy: String = "DATE_UPDATED", status: String = "") -> String {
            return "{\"query\":\"query folderComicIds($folderId: ID!, $pagination: Pagination!) {\\n  folderComicIds(folderId: $folderId, pagination: $pagination) {\\n    comicIds\\n  }\\n}\",\"variables\":{\"folderId\":\"\(folderId)\",\"pagination\":{\"limit\":20,\"offset\":[page],\"orderBy\":\"\(orderBy)\",\"status\":\"\(status)\",\"asc\":true}}}"
        }
    }

    struct ComicData: Decodable {
        let id: String
        let title: String
        let status: String
        let year: Int
        let imageUrl: String
        let authors: [ComicAuthor]
        let categories: [ComicCategories]
        let dateUpdated: String
        let monthViews: Int
        let views: Int
        let favoriteCount: Int
        let lastBookUpdate: String
        let lastChapterUpdate: String
    }
    
    struct ComicAuthor: Codable {
        let id: String
        let name: String
    }

    struct ComicCategories: Codable {
        let id: String
        let name: String
        
    }
    struct Chapters: Codable {
        let id: String
        let serial: String
        let type: String
        let size: Int
    }
    struct ComicImages: Codable {
        let id: String
        let kid: String
        let height: Int
        let width: Int
    }
    struct AccountInfo: Decodable {
        let id: String
        let email: String
        let nickname: String
        let dateCreated:String
        let nextChapterMode: String
        let totalDonateAmount: Int
        let monthDonateAmount: Int
        let favoriteComicIds: [String]
    }
    struct ImageLimit: Decodable {
        let limit: Int
        let usage: Int
        let resetInSeconds: String
    }
    struct ComicHistory: Decodable {
        let id: String
        let comicId: String
        let chapters: [ChapterHistory]
        let chapterType: String
    }
    struct ChapterHistory: Codable {
        let id: String
        let chapterId: String
        let page: Int
    }
    struct FavoritesComic: Decodable {
        let id: String
        let comicId: String
    }
    struct ComicFolder: Decodable {
        let id: String
        let key: String
        let name: String
        let views: Int
        let comicCount: Int
    }
    struct ComicMessageAccount: Decodable {
        let nickname: String
    }
    struct ComicMessageReplyTo: Decodable {
        let id: String
        let account: ComicMessageAccount
        let message: String
    }
    struct ComicMessage: Decodable {
        let id: String
        let account: ComicMessageAccount
        let message: String
        let replyTo: ComicMessageReplyTo?
        let upCount: Int
        let downCount: Int
        let dateUpdated: String
        let dateCreated: String
    }
}
