//
//
//  quiz
//  
//  Created on 01.07.2021
//  Copyright © 2021 Al Jawziyya. All rights reserved.
//  

import SwiftUI
import ComposableArchitecture

struct HomeViewState: Equatable {
}

enum HomeViewAction: Equatable {
    case topics
    case aboutApp
}

typealias HomeViewEnv = Void

let homeViewReducer = Reducer<HomeViewState, HomeViewAction, HomeViewEnv> { state, action, env in

    switch action {
    case .topics:
        break
    case .aboutApp:
        break
    }

    return .none
}
.debugActions("🏡 HomeView: ")

struct HomeView: View {

    typealias Store = ComposableArchitecture.Store<HomeViewState, HomeViewAction>

    let store: Store

    var body: some View {
        WithViewStore(store) { viewStore in
            VStack {
                Spacer(minLength: 10)
                Text("Quiz")
                    .foregroundColor(Color(.label))
                    .font(Font.system(size: 80, weight: .heavy, design: .monospaced).smallCaps())

                Spacer()

                Image("bird")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .padding()

                Spacer()

                VStack {
                    Button(action: {
                        viewStore.send(.topics)
                    }, label: {
                        Text("Начать")
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.accentColor.opacity(0.1))
                            .cornerRadius(8)
                            .foregroundColor(Colors.blue)
                            .font(Font.body.smallCaps().weight(.heavy))
                    })

                    Button(action: {
                        viewStore.send(.aboutApp)
                    }, label: {
                        Text("О приложении")
                            .padding()
                            .frame(maxWidth: .infinity)
                            .cornerRadius(8)
                            .foregroundColor(Colors.blue)
                            .font(Font.body.smallCaps().weight(.bold))
                    })
                }
                .padding()
            }
            .background(Color(.systemBackground).edgesIgnoringSafeArea(.all))
        }
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        let store = HomeView.Store(
            initialState: HomeViewState(),
            reducer: homeViewReducer,
            environment: ()
        )

        return Group {
            HomeView(store: store)
                .environment(\.colorScheme, .dark)
            HomeView(store: store)
                .environment(\.colorScheme, .light)
        }
    }
}
