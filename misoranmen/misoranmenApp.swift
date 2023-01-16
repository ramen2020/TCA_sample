//
//  misoranmenApp.swift
//  misoranmen
//
//  Created by 宮本光直 on 2021/07/04.
//

import SwiftUI
import ComposableArchitecture

@main
struct misoranmenApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView(store: Store(
                initialState: AppState(),
                reducer: appReducer,
                 environment: AppEnvironment(
                    qiitaAPIClient: QiitaAPIClient.live
                )
            ))
        }
    }
}
