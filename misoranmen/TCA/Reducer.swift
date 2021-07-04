//
//  ArticleReducer.swift
//  misoranmen
//
//  Created by 宮本光直 on 2021/06/29.
//

import Foundation
import ComposableArchitecture

let articleReducer = Reducer<ArticleState, ArticleAction, ArticleEnvironment> { state, action, environment in
    switch action {
    // 記事一覧取得
    case .featchArticles:
        return environment.qiitaAPIClient
            .getArticle()
            .receive(on: DispatchQueue.main)
            .catchToEffect()
            .map(ArticleAction.featchArticlesResponse)
        
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
            .map(ArticleAction.featchArticlesResponse)
        
    // 記事取得失敗
    case let .featchArticlesResponse(.failure(error)):
        print("えらー２： \(error.localizedDescription)")
        return .none
        
    // 記事取得成功
    case let .featchArticlesResponse(.success(articles)):
        state.articles = articles
        return .none
        
    // 記事お気に入り
    case let .toggleFavoriteArticle(article: article):
        // お気に入り削除
        if state.favoriteArticlesIds.contains(article.id) {
            let index = state.favoriteArticlesIds.firstIndex(of: article.id)
            state.favoriteArticlesIds.remove(at: index!)
            state.favoriteArticles.remove(at: index!)
            print("お気に入り削除： \(article)")
        } else {
            // お気に入り
            var articleId = article.id
            state.favoriteArticles.append(article)
            state.favoriteArticlesIds.append(article.id)
            print("お気に入り： \(article)")
        }
        return .none
    }
}
