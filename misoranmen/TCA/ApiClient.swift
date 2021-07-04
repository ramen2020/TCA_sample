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
            
            return URLSession.shared.dataTaskPublisher(for: components.url!)
                .map { data, _ in data }
                .decode(type: [Article].self, decoder: JSONDecoder())
                .mapError { _ in ArticleApiError() }
                .eraseToEffect()
        },
        // 記事検索取得
        getArticleBySearch:{ searchWord -> Effect<[Article], ArticleApiError> in
            print("検索API実行：　\(searchWord)")
            var components = URLComponents(string: APIConst.BASE_URL)!
            components.queryItems = [
                URLQueryItem(name: "per_page", value: "5"),
                URLQueryItem(name: "query", value: searchWord)
            ]
            
            return URLSession.shared.dataTaskPublisher(for: components.url!)
                .map { data, _ in data }
                .decode(type: [Article].self, decoder: JSONDecoder())
                .mapError { _ in ArticleApiError() }
                .eraseToEffect()
        })
}
