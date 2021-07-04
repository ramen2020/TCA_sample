//
//  ArticleState.swift
//  misoranmen
//
//  Created by 宮本光直 on 2021/06/29.
//

import SwiftUI
import ComposableArchitecture

struct ArticleState: Equatable {
    var articles: [Article] = []
    var searchWord = ""
    var favoriteArticles: [Article] = []
    var favoriteArticlesIds: [String] = []
}
