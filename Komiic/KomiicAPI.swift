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
    func getChapterByComicId (comicId: String, completion:(@escaping ([Chapters]) -> Void)) {
        let formatParameters = "{\"query\":\"query chapterByComicId($comicId: ID!) {\\n  chaptersByComicId(comicId: $comicId) {\\n    id\\n    serial\\n    type\\n    size\\n  }\\n}\",\"variables\":{\"comicId\":\"\(comicId)\"}}"
        let postData = formatParameters.data(using: .utf8)
        var urlRequest = URLRequest(url: URL(string: "\(apiUrl)/api/query")!)
        urlRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")
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
            let endIndex = respText.index(respText.endIndex, offsetBy: -2)
            do {
                let chapters = try JSONDecoder().decode([Chapters].self, from: Data(String(respText[startIndex..<endIndex]).utf8))
                return completion(chapters)
            } catch {
                print(error)
                return completion([])
            }
        }
        task.resume()
    }
    func getImagesByChapterId (chapterId: String, completion:(@escaping ([ComicImages]) -> Void)) {
        let formatParameters = "{\"query\":\"query imagesByChapterId($chapterId: ID!) {\\n  imagesByChapterId(chapterId: $chapterId) {\\n    id\\n    kid\\n    height\\n    width\\n  }\\n}\",\"variables\":{\"chapterId\":\"\(chapterId)\"}}"
        let postData = formatParameters.data(using: .utf8)
        var urlRequest = URLRequest(url: URL(string: "\(apiUrl)/api/query")!)
        urlRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")
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
            let endIndex = respText.index(respText.endIndex, offsetBy: -2)
            do {
                let chapters = try JSONDecoder().decode([ComicImages].self, from: Data(String(respText[startIndex..<endIndex]).utf8))
                return completion(chapters)
            } catch {
                print(error)
                return completion([])
            }
        }
        task.resume()
    }
    func fetchList(parameters: String, page: Int = 0,completion:(@escaping ([ComicData]) -> Void)) {
        let formatParameters = parameters.replacingOccurrences(of: "[page]", with: String(page*20))
        let postData = formatParameters.data(using: .utf8)
        var urlRequest = URLRequest(url: URL(string: "\(apiUrl)/api/query")!)
        urlRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")
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
                let comics = try JSONDecoder().decode([ComicData].self, from: Data(String(respText[startIndex..<endIndex]).utf8))
                return completion(comics)
            } catch {
                print(error)
                return completion([])
            }
        }
        task.resume()
    }
    func fetchComicHistory(completion:(@escaping ([ComicHistory]) -> Void)) {
        let formatParameters = "{\"query\":\"query readComicHistory($pagination: Pagination!) {\\n  readComicHistory(pagination: $pagination) {\\n    id\\n    comicId\\n    chapters {\\n      id\\n      chapterId\\n      page\\n    }\\n    startDate\\n    lastDate\\n    chapterType\\n  }\\n}\",\"variables\":{\"pagination\":{\"limit\":20,\"offset\":0,\"orderBy\":\"DATE_UPDATED\",\"asc\":true}}}"
        let postData = formatParameters.data(using: .utf8)
        var urlRequest = URLRequest(url: URL(string: "\(apiUrl)/api/query")!)
        urlRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")
        urlRequest.httpMethod = "POST"
        urlRequest.addValue("Bearer \(keychain.get("token")!)", forHTTPHeaderField: "authorization")
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
            let endIndex = respText.index(respText.endIndex, offsetBy: -2)
            do {
                let comics = try JSONDecoder().decode([ComicHistory].self, from: Data(String(respText[startIndex..<endIndex]).utf8))
                return completion(comics)
            } catch {
                print(error)
                return completion([])
            }
        }
        task.resume()
    }
    func fetchCategoryList(completion:(@escaping ([ComicCategories]) -> Void)) {
        let formatParameters = "{\"query\":\"query allCategory {\\n  allCategory {\\n    id\\n    name\\n  }\\n}\",\"variables\":{}}"
        let postData = formatParameters.data(using: .utf8)
        var urlRequest = URLRequest(url: URL(string: "\(apiUrl)/api/query")!)
        urlRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")
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
            let endIndex = respText.index(respText.endIndex, offsetBy: -2)
            do {
                let categories = try JSONDecoder().decode([ComicCategories].self, from: Data(String(respText[startIndex..<endIndex]).utf8))
                return completion(categories)
            } catch {
                print(error)
                return completion([])
            }
        }
        task.resume()
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
        let parameters = "{\"query\":\"query accountQuery {\\n  account {\\n    id\\n    email\\n    nickname\\n    dateCreated\\n    totalDonateAmount\\n    monthDonateAmount\\n    nextChapterMode\\n  }\\n}\",\"variables\":{}}"
        let postData = parameters.data(using: .utf8)
        var request = URLRequest(url: URL(string: "https://komiic.com/api/query")!)
        request.addValue("Bearer \(keychain.get("token")!)", forHTTPHeaderField: "authorization")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "POST"
        request.httpBody = postData
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data else {
                print(String(describing: error))
                return completion(AccountInfo(id: "", email: "", nickname: "", dateCreated: "", nextChapterMode: "", totalDonateAmount: 0, monthDonateAmount: 0))
            }
            let resp = String(data: data, encoding: .utf8)!
            let startIndex = resp.index(resp.startIndex, offsetBy: 19)
            let endIndex = resp.index(resp.endIndex, offsetBy: -2)
            do {
                let accountInfo = try JSONDecoder().decode(AccountInfo.self, from: Data(String(resp[startIndex..<endIndex]).utf8))
                return completion(accountInfo)
            } catch {
                return completion(AccountInfo(id: "tokenExpired", email: "", nickname: "", dateCreated: "", nextChapterMode: "", totalDonateAmount: 0, monthDonateAmount: 0))
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
    struct ComicImages: Decodable {
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
}
