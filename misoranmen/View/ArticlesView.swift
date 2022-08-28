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
                    Section {
                        ForEach(Array(viewStore.state.articles.enumerated()), id:\.offset) { index, article in
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
                            .onAppear{
                                viewStore.send(.loadNext(index))
                            }
                            .padding()
                            .onTapGesture {
                                viewStore.send(.setNavigation(.articleDetail(article.id)))
                            }
                        }
                   } header: {
                       Text("新着投稿")
                   }
                }
            }
            .onAppear{
                viewStore.send(.featchArticles)
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
        ) { articleDetailId in
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

