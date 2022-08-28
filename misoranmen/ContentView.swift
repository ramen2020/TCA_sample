//
//  ContentView.swift
//  misoranmen
//
//  Created by 宮本光直 on 2021/06/28.
//
import ComposableArchitecture
import SwiftUI

struct ContentView: View {
    
    let store: Store<AppState, AppAction>
    
    var body: some View {
        NavigationView {
            WithViewStore(store) { viewStore in
                TabView {
                    ArticlesView(
                        store: store.scope(
                            state: \.articlesState,
                            action: AppAction.articlesAction
                        )
                    )
                    .tabItem {
                        Label("article", systemImage: "gamecontroller")
                    }
                    
//                    ArticleFavoriteContentView(
//                        store: store.scope(
//                            state: \.fa,
//                            action: AppAction.articlesAction
//                        )
//                    )
//                    .tabItem {
//                        Label("favorite", systemImage: "star")
//                    }
                }
                .navigationBarTitle("Article List", displayMode: .inline)
                .navigationBarItems(
                    trailing: HStack {
                        Button(action: {
                            //
                        }, label: {
                            Image(systemName: "person.fill")
                                .resizable()
                                .frame(width: 22, height: 22)
                                .padding()
                        })
                    })
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
}

//struct ContentView_Previews: PreviewProvider {
//    static var previews: some View {
//        ContentView()
//    }
//}
