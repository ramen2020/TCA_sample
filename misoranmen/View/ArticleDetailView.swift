//
//  ComposableArtictectureClient.swift
//  misoranmen
//
//  Created by 宮本光直 on 2021/06/28.
//

import Foundation
import ComposableArchitecture
import SwiftUI
import SwiftUINavigation
import Kingfisher

struct ArticleDetailView: View {
    let store: Store<ArticleDetailState, ArticleDetailAction>
    @ObservedObject var viewStore: ViewStore<ArticleDetailState, ArticleDetailAction>
    
    public init(
        store: Store<ArticleDetailState, ArticleDetailAction>
    ) {
        self.store = store
        viewStore = ViewStore(store)
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            card
                .padding()
            
            List {
                if let articles = viewStore.state.articles {
                    ForEach(articles) { article in
                        HStack(spacing: 16) {
                            KFImage(URL(string: article.user.profile_image_url)!)
                                .frame(width: 40, height: 40)
                                .clipShape(Circle())
                            VStack(alignment: .leading) {
                                Text("\(article.title)")
                                    .font(.system(size: 15))
                                Text("\(article.user.name)")
                                    .foregroundColor(.red)
                                    .font(.system(size: 12))
                            }
                        }
                        .padding()
                        .onTapGesture {
                            viewStore.send(.setNavigation(.articleDetail(article.id)))
                        }
                    }
                } else {
                    Indicator()
                        .frame(width: 44, height: 44)
                        .frame(maxWidth: .infinity, alignment: .center)
                }
            }
        }
        .background(navigationLinks)
        .background(articlesNavigationLink)
        .onTapGesture {
            UIApplication.shared.closeKeyboard()
        }
        .onAppear {
            viewStore.send(.onAppear)
        }
        .toolbar {
            ToolbarItemGroup(placement: .navigationBarTrailing) {
                Button {
                    viewStore.send(.setNavigation(.articles))
                } label: {
                    Text("全ての投稿を見る")
                }
            }
        }
    }
    
    var card: some View {
        Button {
            if let articleId = viewStore.articleId {
                viewStore.send(.setNavigation(.articleDetail(articleId)))
            }
        } label: {
            if let articleDetail = viewStore.articleDetail {
                VStack(alignment: .center, spacing: 16) {
                    KFImage(URL(string: articleDetail.user.profile_image_url)!)
                        .resizable()
                        .scaledToFit()
                    VStack(alignment: .leading, spacing: 8) {
                        Text(articleDetail.user.name)
                            .font(.headline)
                            .foregroundColor(.gray)
                        Text(articleDetail.title)
                            .font(.largeTitle)
                        
                            .foregroundColor(.black)
                        
                    }
                    .multilineTextAlignment(.leading)
                }
            }
        }
    }
}

extension ArticleDetailView {
    var navigationLinks: some View {
        NavigationLink(
            unwrapping: viewStore.binding(get: \.route, send: .dismiss),
            case: /ArticleDetailState.Route.articleDetail
        ) { articleId in
            ArticleDetailView(
                store: store.scope(
                    state: \.articleDetailState,
                    action: ArticleDetailAction.articleDetailAction
                )
            )
        } onNavigate: { _ in
        } label: {
        }
    }
    
    var articlesNavigationLink: some View {
        NavigationLink(
            unwrapping: viewStore.binding(get: \.route, send: .dismiss),
            case: /ArticleDetailState.Route.articles
        ) { _ in
            ArticlesView(
                store: store.scope(
                    state: \.articlesState,
                    action: ArticleDetailAction.articlesAction
                )
            )
        } onNavigate: { _ in
        } label: {
        }
    }
}
