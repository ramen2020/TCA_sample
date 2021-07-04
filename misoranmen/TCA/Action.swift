//
//  ArticleAction.swift
//  misoranmen
//
//  Created by 宮本光直 on 2021/06/29.
//

import SwiftUI
import ComposableArchitecture

enum ArticleAction: Equatable {
    case featchArticles
    case typingSearchWord(searchWord: String)
    case featchArticlesBySearchWord(searchWord: String)
    case featchArticlesResponse(Result<[Article], QiitaAPIClient.ArticleApiError>)
    case toggleFavoriteArticle(article: Article)
}
