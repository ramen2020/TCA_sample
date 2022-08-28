//
//  ArticleAPIClient.swift
//  misoranmen
//
//  Created by 宮本光直 on 2021/06/28.
//

import Combine
import ComposableArchitecture
import Foundation

struct QiitaAPIClient {
    var getArticle: () -> Effect<[Article], ArticleApiError>
    var getArticleBySearch: (String) -> Effect<[Article], ArticleApiError>
    var getArticleById: (String) -> Effect<Article, ArticleApiError>
    
    struct ArticleApiError: Error, Equatable {}
}

extension QiitaAPIClient {
    static let live = QiitaAPIClient(
        // 記事一覧取得
        getArticle: { () -> Effect<[Article], ArticleApiError> in
            var components = URLComponents(string: APIConst.BASE_URL)!
            components.queryItems = [
                URLQueryItem(name: "per_page", value: "5"),
            ]
            
            var request = URLRequest(url: components.url!)
            request.allHTTPHeaderFields = ["Authorization": "Bearer \(APIConst.ACCESS_TOKEN)"]
            
            return URLSession.shared.dataTaskPublisher(for: request)
                .map { data, _ in data }
                .decode(type: [Article].self, decoder: JSONDecoder())
                .mapError { _ in ArticleApiError() }
                .eraseToEffect()
        },
        // 記事検索取得
        getArticleBySearch:{ searchWord -> Effect<[Article], ArticleApiError> in
            var components = URLComponents(string: APIConst.BASE_URL)!
            components.queryItems = [
                URLQueryItem(name: "per_page", value: "5"),
                URLQueryItem(name: "query", value: searchWord)
            ]
            
            var request = URLRequest(url: components.url!)
            request.allHTTPHeaderFields = ["Authorization": "Bearer \(APIConst.ACCESS_TOKEN)"]
            
            return URLSession.shared.dataTaskPublisher(for: components.url!)
                .map { data, _ in data }
                .decode(type: [Article].self, decoder: JSONDecoder())
                .mapError { _ in ArticleApiError() }
                .eraseToEffect()
        },
        getArticleById:{ articleId -> Effect<Article, ArticleApiError> in
            let url = URL(string: APIConst.BASE_URL + "/\(articleId)")!
            var request = URLRequest(url: url)
            var components = URLComponents(string: APIConst.BASE_URL + "/\(articleId)")!
            
            request.allHTTPHeaderFields = ["Authorization": "Bearer \(APIConst.ACCESS_TOKEN)"]
            
            return URLSession.shared.dataTaskPublisher(for: request)
                .map { data, _ in data }
                .decode(type: Article.self, decoder: JSONDecoder())
                .mapError { _ in ArticleApiError() }
                .eraseToEffect()
        }
    )
}
