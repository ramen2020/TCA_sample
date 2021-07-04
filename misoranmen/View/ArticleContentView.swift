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

struct ArticleContentView: View {
    let store: Store<ArticleState, ArticleAction>
    var body: some View {
        VStack {
            WithViewStore(self.store) { viewStore in
                HStack{
                    TextField("検索してください。",
                              text: viewStore.binding(
                                get: \.searchWord, send: ArticleAction.typingSearchWord),
                              onCommit: {
                                viewStore.send(.featchArticlesBySearchWord(searchWord: viewStore.state.searchWord))
                              }
                    )
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    
                    Button (action: {
                        viewStore.send(.featchArticlesBySearchWord(searchWord: viewStore.state.searchWord))
                    }) {
                        ZStack{
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
                            NavigationLink(destination: WebView(urlString: article.url)) {
                                HStack {
                                    KFImage(URL(string: article.user.profile_image_url)!)
                                        .frame(width: 40, height: 40)
                                        .clipShape(Circle())
                                    VStack() {
                                        Text("\(article.title)")
                                            .font(.system(size: 15))
                                        Text("\(article.user.name)")
                                            .foregroundColor(.red)
                                            .font(.system(size: 12))
                                    }
                                    Spacer()
                                    Button (action: {
                                        viewStore.send(.toggleFavoriteArticle(article: article))
                                    }) {
                                        ZStack {
                                            Image(systemName: viewStore.state.favoriteArticles.contains(article) ? "heart.fill" : "heart")
                                                .foregroundColor(.red)
                                        }
                                    }
                                    .buttonStyle(BorderlessButtonStyle())
                                    .padding()
                                }
                            }
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
        }
        .onTapGesture {
            UIApplication.shared.closeKeyboard()
        }
    }
}

extension UIApplication {
    // 背景タップでキーボード閉じる処理
    func closeKeyboard() {
        sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

