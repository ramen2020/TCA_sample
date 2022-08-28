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
                    print("せんい", route)
                    switch route {
                    case .articleDetail(let articleId):
                        state.articleDetailState = .init(articleId: articleId)
                        print("::: articleId: ", articleId)
                        print("::: state.articleDetailState: ", state.articleDetailState)
                    default: break
                    }
                    state.route = route
                    return .none
                case .dismiss:
                    state.route = nil
                    return .none
                    // 記事一覧取得
                case .featchArticles:
                    return environment.qiitaAPIClient
                        .getArticle()
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
                    print("えらー： \(error.localizedDescription)")
                    return .none
                    // 記事取得成功
                case let .featchArticlesResponse(.success(articles)):
                    state.articles = articles
                    return .none
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
