//
//  ArticlesStore.swift
//  misoranmen
//
//  Created by nao on 2022/08/28.
//

import SwiftUI
import ComposableArchitecture

enum ArticlesAction: Equatable {
    case setNavigation(ArticlesState.Route)
    case dismiss
    case featchArticles
    case typingSearchWord(searchWord: String)
    case featchArticlesBySearchWord(searchWord: String)
    case featchArticlesResponse(Result<[Article], QiitaAPIClient.ArticleApiError>)
    case loadNext(Int)

    case articleDetailAction(ArticleDetailAction)
}

struct ArticlesState: Equatable {
    enum Route: Equatable, Hashable {
        case articles
        case articleDetail(String)
    }
    var route: Route?
    var articles: [Article] = []
    var searchWord = ""
    var currentPage = 0
    var perPage = 10
    var loadingId: Int {
        perPage * currentPage - 5
    }
    
    @Heap var articleDetailState: ArticleDetailState!
    
    init() {
        _articleDetailState = .init(.init())
    }
}

struct ArticlesEnvironment {
    var qiitaAPIClient: QiitaAPIClient
}

let articlesReducer: Reducer<ArticlesState, ArticlesAction, ArticlesEnvironment> = Reducer<ArticlesState, ArticlesAction, ArticlesEnvironment>.recurse { (self) in
        .combine(
            .init { state, action, environment in
                switch action {
                case .setNavigation(let route):
                    switch route {
                    case .articleDetail(let articleId):
                        state.articleDetailState = .init(articleId: articleId)
                    default: break
                    }
                    state.route = route
                    return .none
                case .dismiss:
                    state.route = nil
                    return .none
                    // 記事一覧取得
                case .featchArticles:
                    state.currentPage = state.currentPage + 1
                    return environment.qiitaAPIClient
                        .getArticle(state.currentPage, state.perPage)
                        .receive(on: DispatchQueue.main)
                        .catchToEffect()
                        .map(ArticlesAction.featchArticlesResponse)
                    // 検索入力中
                case let .typingSearchWord(searchWord: searchWord):
                    state.searchWord = searchWord
                    return .none
                    // 記事検索
                case let .featchArticlesBySearchWord(searchWord: searchWord):
                    return environment.qiitaAPIClient
                        .getArticleBySearch(searchWord)
                        .receive(on: DispatchQueue.main)
                        .catchToEffect()
                        .map(ArticlesAction.featchArticlesResponse)
                    // 記事取得失敗
                case let .featchArticlesResponse(.failure(error)):
                    return .none
                    // 記事取得成功
                case let .featchArticlesResponse(.success(articles)):
                    state.articles += articles
                    return .none
                case .loadNext(let index):
                    guard state.loadingId == index else {return .none}
                    return .init(value: .featchArticles)
                case .articleDetailAction(_):
                    return .none
                }
            },
            articleDetailReducer
                .optional()
                .pullback(
                    state: \.articleDetailState,
                    action: /ArticlesAction.articleDetailAction,
                    environment: {
                        ArticleDetailEnvironment(
                            qiitaAPIClient: $0.qiitaAPIClient
                        )
                    }
                )
        )
}
