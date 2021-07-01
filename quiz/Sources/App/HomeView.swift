//
//
//  quiz
//  
//  Created on 01.07.2021
//  Copyright © 2021 Al Jawziyya. All rights reserved.
//  

import SwiftUI
import ComposableArchitecture
import DatabaseClient
import Entities

struct TopicsId: Hashable, Identifiable {
    var id: String = UUID().uuidString
}

struct HomeViewState: Equatable {
    var appDelegateState = AppDelegateState()
    var topicsState: QuizTopicsState?
    var topics: TopicsId?
}

enum HomeViewAction: Equatable {
    case appDelegate(AppDelegateAction)

    case showTopics(TopicsId?)
    case quizTopics(QuizTopicsAction)

    case aboutApp
}

struct HomeViewEnv {
    let mainQueue: AnySchedulerOf<DispatchQueue>
    let databaseClient: DatabaseClient
}

let homeViewReducer = Reducer.combine(
    appDelegateReducer
        .pullback(
            state: \.appDelegateState,
            action: /HomeViewAction.appDelegate,
            environment: { env in
                .init(databaseClient: env.databaseClient)
            }
        ),
    quizTopicsReducer
        .optional()
        .pullback(
            state: \.topicsState,
            action: /HomeViewAction.quizTopics,
            environment: { env in
                .init(mainQueue: env.mainQueue, databaseClient: env.databaseClient)
            }),
    Reducer<HomeViewState, HomeViewAction, HomeViewEnv> { state, action, env in

        switch action {

        case .showTopics(let id):
            state.topics = id
            state.topicsState = .init(topics: [Topic.placeholder], selectedTheme: .none, selectedQuizState: .none)
            return .none

        case .appDelegate(.didFinishLaunching):
            return .merge(
                env.databaseClient.migrate
                    .ignoreOutput()
                    .ignoreFailure()
                    .eraseToEffect()
                    .fireAndForget()
            )

        default:
            return .none

        }
    }
    .debugActions("🏡 HomeView")
)

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
                        viewStore.send(.showTopics(TopicsId()))
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
            .fullScreenCover(
                item: viewStore.binding(
                    get: \.topics,
                    send: HomeViewAction.showTopics
                )
            ) { theme in
                IfLetStore(
                    self.store.scope(
                        state: \.topicsState, action: HomeViewAction.quizTopics),
                    then: QuizTopicsView.init(store:)
                )
            }
        }
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        let store = HomeView.Store(
            initialState: HomeViewState(),
            reducer: homeViewReducer,
            environment: .init(
                mainQueue: DispatchQueue.main.eraseToAnyScheduler(),
                databaseClient: DatabaseClient.noop
            )
        )

        return Group {
            HomeView(store: store)
                .environment(\.colorScheme, .dark)
            HomeView(store: store)
                .environment(\.colorScheme, .light)
        }
    }
}
