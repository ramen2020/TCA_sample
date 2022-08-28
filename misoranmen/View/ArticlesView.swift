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

struct ArticlesView: View {
    let store: Store<ArticlesState, ArticlesAction>
    @ObservedObject var viewStore: ViewStore<ArticlesState, ArticlesAction>

    public init(
        store: Store<ArticlesState, ArticlesAction>
    ) {
        self.store = store
        viewStore = ViewStore(store)
    }


    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                TextField(
                    "検索してください。",
                    text: viewStore.binding(
                            get: \.searchWord, send: ArticlesAction.typingSearchWord),
                    onCommit: {
                        viewStore.send(.featchArticlesBySearchWord(searchWord: viewStore.state.searchWord))
                    }
                )
                .textFieldStyle(RoundedBorderTextFieldStyle())

                Button (action: {
                    viewStore.send(.featchArticlesBySearchWord(searchWord: viewStore.state.searchWord))
                }) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 5)
                            .fill(Color.primary)
                            .frame(width:30, height: 30)
                        Image(systemName: "magnifyingglass")
                            .resizable()
                            .foregroundColor(.white)
                            .frame(width: 20, height: 20)
                    }
                }
            }
            .padding()
            List {
                if viewStore.state.articles.isEmpty {
                    Indicator().frame(width: 44, height: 44)
                } else {
                    ForEach(viewStore.state.articles) { article in
                        HStack {
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
                    }
                    .onTapGesture {
                        viewStore.send(.setNavigation(.articleDetail))
                    }
                }
            }
            .onAppear{
                // タブ切り替える度に、実行されてしまうのを制御
                if viewStore.articles.isEmpty {
                    viewStore.send(.featchArticles)
                }
            }
        }
        .background(navigationLinks)
        .onTapGesture {
            UIApplication.shared.closeKeyboard()
        }
    }
}

extension ArticlesView {
    var navigationLinks: some View {
        NavigationLink(
            unwrapping: viewStore.binding(get: \.route, send: .dismiss),
            case: /ArticlesState.Route.articleDetail
        ) { _ in
            ArticleDetailView(
                store: store.scope(
                    state: \.articleDetailState,
                    action: ArticlesAction.articleDetailAction
                )
            )
        } onNavigate: { _ in
        } label: {
        }
    }
}

extension UIApplication {
    // 背景タップでキーボード閉じる処理
    func closeKeyboard() {
        sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

