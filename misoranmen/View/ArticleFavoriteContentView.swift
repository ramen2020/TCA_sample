////
////  ArticleFavoriteContentView.swift
////  misoranmen
////
////  Created by 宮本光直 on 2021/06/29.
////
//
//import Foundation
//import ComposableArchitecture
//import SwiftUI
//import Kingfisher
//
//struct ArticleFavoriteContentView: View {
//    let store: Store<ArticleState, ArticleAction>
//    var body: some View {
//        VStack {
//            WithViewStore(self.store) { viewStore in
//                List {
//                    if viewStore.state.favoriteArticles.isEmpty {
//                        Text("お気に入りは現在ありません。")
//                    } else {
//                        ForEach(viewStore.state.favoriteArticles) { article in
//                            NavigationLink(destination: WebView(urlString: article.url)) {
//                                HStack {
//                                    KFImage(URL(string: article.user.profile_image_url)!)
//                                        .frame(width: 40, height: 40)
//                                        .clipShape(Circle())
//                                    VStack() {
//                                        Text("\(article.title)")
//                                            .font(.system(size: 15))
//                                        Text("\(article.user.name)")
//                                            .foregroundColor(.red)
//                                            .font(.system(size: 12))
//                                    }
//                                    Spacer()
//                                    Button (action: {
//                                        viewStore.send(.toggleFavoriteArticle(article: article))
//                                    }) {
//                                        ZStack {
//                                            Image(systemName: viewStore.state.favoriteArticlesIds.contains(article.id) ? "heart.fill" : "heart")
//                                                .foregroundColor(.red)
//                                        }.padding()
//                                    }.buttonStyle(BorderlessButtonStyle())
//                                }
//                            }
//                        }
//                    }
//                }
//                
//            }
//        }
//    }
//}
////
////struct ArticleFavoriteContentView_Previews: PreviewProvider {
////    static var previews: some View {
////        ArticleFavoriteContentView()
////    }
////}
