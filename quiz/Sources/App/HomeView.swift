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
}

enum HomeViewAction: Equatable {
    case appDelegate(AppDelegateAction)

    case showTopics
    case closeTopics
    case displayTopics([Topic])
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
    Reducer<HomeViewState, HomeViewAction, HomeViewEnv> { state, action, env in

        switch action {

        case .showTopics:
            return env.databaseClient
                .fetchTopics
                .replaceError(with: [])
                .map { topics in
                    return HomeViewAction.displayTopics(topics)
                }
                .eraseToEffect()

        case .closeTopics:
            state.topicsState = nil
            return .none

        case .displayTopics(let topics):
            state.topicsState = .init(topics: topics, selectedTheme: .none, selectedQuizState: .none)
            return .none

        case .quizTopics(let action):
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
    .debugActions("🏡 Home", actionFormat: ActionFormat.labelsOnly)
)
.presents(
    quizTopicsReducer,
    state: \.topicsState,
    action: /HomeViewAction.quizTopics,
    environment: { env in
        .init(mainQueue: env.mainQueue, databaseClient: env.databaseClient)
    }
)

/**
 Root view of the application.

 - Has app logo
 - Shows main actions as Start Quiz, About app etc.
 */
struct HomeView: View {

    typealias Store = ComposableArchitecture.Store<HomeViewState, HomeViewAction>

    let store: Store

    struct HomeViewViewState: Equatable {
        init(state: HomeViewState) { }
    }

    var body: some View {
        WithViewStore(store.scope(state: HomeViewViewState.init(state:))) { viewStore in
            ScrollView {
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
                        viewStore.send(.showTopics)
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
        .navigate(
            using: store.scope(
                state: \.topicsState,
                action: HomeViewAction.quizTopics
            ),
            destination: QuizTopicsView.init(store:),
            onDismiss: {
                ViewStore(store).send(.closeTopics)
            }
        )
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
