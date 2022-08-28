import SwiftUI
import ComposableArchitecture

indirect enum ArticleDetailAction: Equatable {
    case setNavigation(ArticleDetailState.Route)
    case dismiss
    case onAppear
    case featchArticle
    case featchArticles
    case featchArticlesResponse(Result<[Article], QiitaAPIClient.ArticleApiError>)

    case articlesAction(ArticlesAction)
    case articleDetailAction(ArticleDetailAction)
}

struct ArticleDetailState: Equatable {
    enum Route: Equatable, Hashable {
        case articles
        case articleDetail
    }

    var articleDetail: Article?
    var articles: [Article]?
    var route: Route?

    @Heap var articlesState: ArticlesState!
    @Heap var articleDetailState: ArticleDetailState!

    init() {
        _articleDetailState = .init(nil)
        _articlesState = .init(nil)
    }
}

struct ArticleDetailEnvironment {
    var qiitaAPIClient: QiitaAPIClient
}

let articleDetailReducer: Reducer<ArticleDetailState, ArticleDetailAction, ArticleDetailEnvironment>
= Reducer<ArticleDetailState, ArticleDetailAction, ArticleDetailEnvironment>.recurse { (self) in
        .combine(
            .init { state, action, environment in
                switch action {
                case .setNavigation(let route):
                    switch route {
                    case .articleDetail:
                        state.articleDetailState = .init()
                    case .articles:
                        state.articlesState = .init()
                    }
                    
                    state.route = route
                    return .none
                case .dismiss:
                    state.route = nil
                    return .none
                case .onAppear:
                    //        var effects = [Effect<ArticleDetailAction, Never>]()
                    //        effects.append(.init(value: .featchArticle))
                    //        effects.append(.init(value: .featchArticles))
                    //        return .merge(effects)
                    return .none
                    // 記事詳細取得
                case .featchArticle:
                    return .none
                    // 記事一覧取得
                case .featchArticles:
                    return environment.qiitaAPIClient
                        .getArticle()
                        .receive(on: DispatchQueue.main)
                        .catchToEffect()
                        .map(ArticleDetailAction.featchArticlesResponse)
                    // 記事取得失敗
                case let .featchArticlesResponse(.failure(error)):
                    print("えらー２： \(error.localizedDescription)")
                    return .none

                    // 記事取得成功
                case let .featchArticlesResponse(.success(articles)):
                    state.articles = articles
                    return .none
                case let .articleDetailAction(.articleDetailAction(action)):
                    guard state.articleDetailState?.articleDetailState != nil else { break }
                    return self.run(&state.articleDetailState!.articleDetailState!, action, environment)
                        .map{.articleDetailAction(.articleDetailAction($0))}

                case .articlesAction(.articleDetailAction(let recursiveAction)):
                    guard state.articlesState != nil else { return .none }
                    return self.run(&state.articlesState!.articleDetailState, recursiveAction, environment)
                        .map({ ArticleDetailAction.articlesAction(.articleDetailAction($0)) })
                default: break
                }

                return .none
            },
            articleDetailReducer
                .optional()
                .pullback(
                    state: \.articleDetailState,
                    action: /ArticleDetailAction.articleDetailAction,
                    environment: {
                        ArticleDetailEnvironment(
                            qiitaAPIClient: $0.qiitaAPIClient
                        )
                    }
                ),
            articlesReducer
                .optional()
                .pullback(
                    state: \.articlesState,
                    action: /ArticleDetailAction.articlesAction,
                    environment: {
                        ArticlesEnvironment(
                            qiitaAPIClient: $0.qiitaAPIClient
                        )
                    }
                )
        )
}
