import SwiftUI
import ComposableArchitecture

enum AppAction: Equatable {
    case articlesAction(ArticlesAction)
    case favoriteArticlesAction(ArticlesAction)
    case articleDetail(ArticleDetailAction)
}

struct AppState: Equatable {
    
    @Heap var articlesState: ArticlesState!
    //    var articleDetailState = ArticleDetailState()
    
    init(id: String = UUID().uuidString) {
        _articlesState = .init(.init())
    }
}

struct AppEnvironment {
    var qiitaAPIClient: QiitaAPIClient
}

let appReducer: Reducer<AppState, AppAction, AppEnvironment> =
Reducer<AppState, AppAction, AppEnvironment>
    .recurse { (self) in
        .combine(
            .init { state, action, environment in
                switch action {
                case .articlesAction, .favoriteArticlesAction, .articleDetail:
                    return .none
                }
            },
            articlesReducer
                .optional()
                .pullback(
                    state: \.articlesState,
                    action: /AppAction.articlesAction,
                    environment: {
                        ArticlesEnvironment(
                            qiitaAPIClient: $0.qiitaAPIClient
                        )
                    }
                )
        )
    }
