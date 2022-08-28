//
//  ComposableArtictectureClient.swift
//  misoranmen
//
//  Created by 宮本光直 on 2021/06/28.
//

import Foundation
import ComposableArchitecture
import SwiftUI
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
            Spacer()
        }
        .background(navigationLinks)
        .background(articlesNavigationLink)
        .onAppear{
            viewStore.send(.onAppear)
        }
        .onTapGesture {
            UIApplication.shared.closeKeyboard()
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
            viewStore.send(.setNavigation(.articleDetail))
        } label: {
            ZStack(alignment: .top) {
                Image("frozen")
                    .resizable()
                    .scaledToFit()
                HStack {
                    VStack(alignment: .leading, spacing: 0) {
                        Text("title")
                            .font(.headline)
                            .foregroundColor(.white)
                            .shadow(radius: 4.0)
                        Text("APP OF THE DAY")
                            .font(.largeTitle)
                            .foregroundColor(.white)
                            .shadow(radius: 4.0)
                    }
                    .padding()
                    Spacer()
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
        ) { _ in
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
