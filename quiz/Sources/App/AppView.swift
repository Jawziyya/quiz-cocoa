//
//
//  quiz
//  
//  Created on 22.03.2021
//  Copyright © 2021 Al Jawziyya. All rights reserved.
//  

import SwiftUI
import ComposableArchitecture
import Entities
import DatabaseClient
import Combine

struct AppState: Equatable {
    var appDelegate = AppDelegateState()
    let topics: [Topic]
    var selectedTheme: Theme?
    var selectedQuizState: QuizState?
}

enum AppAction: Equatable {
    case appDelegate(AppDelegateAction)
    case showTheme(Theme?)
    case quiz(QuizAction)
    case finish
}

struct AppEnvironment {
    let mainQueue: AnySchedulerOf<DispatchQueue>
    let databaseClient: DatabaseClient
}

let appReducer = Reducer.combine(
    appDelegateReducer
        .pullback(
            state: \.appDelegate,
            action: /AppAction.appDelegate,
            environment: { env in
                .init(databaseClient: env.databaseClient)
            }
        ),
    quizReducer
        .optional()
        .pullback(
            state: \.selectedQuizState,
            action: /AppAction.quiz,
            environment: { env in
                QuizEnvironment(databaseClient: env.databaseClient)
            }
        ),
    Reducer<AppState, AppAction, AppEnvironment> { state, action, env in

        switch action {

        case .appDelegate(.didFinishLaunching):
            return .merge(
                env.databaseClient.migrate
                    .ignoreOutput()
                    .ignoreFailure()
                    .eraseToEffect()
                    .fireAndForget()
            )

        case .showTheme(let theme):
            if let theme = theme {
                state.selectedTheme = theme
                state.selectedQuizState = .init(theme: theme, quizQuestion: QuizQuestionState(question: .placeholder1))
            }
            return .none

        // This will be called by QuizView on `Continue` button tap.
        // The navigation view will be popped and resources will be disposed after some delay in .finish case ↓
        case .quiz(.finish):
            let quizState = state.selectedQuizState
            if quizState?.progress == 100 && quizState?.score == quizState?.questionsComplete {
                GameKitHelper.shared.reportProgress()
            }

            state.selectedTheme = nil
            return Effect(value: .finish)
                .delay(for: 0.3, scheduler: env.mainQueue.eraseToAnyScheduler())
                .eraseToEffect()

        // Dispose the resources.
        case .finish:
            state.selectedQuizState = nil
            return .none

        default:
            return .none

        }
    }
)
.debugActions("AppView", actionFormat: .labelsOnly)

struct AppView: View {

    typealias QuizTopicsStore = Store<AppState, AppAction>

    let store: QuizTopicsStore
    @ObservedObject var viewStore: ViewStore<ViewState, AppAction>

    struct ViewState: Equatable {
        var selectedTheme: Theme?
    }

    init(store: QuizTopicsStore) {
        self.store = store
        viewStore = ViewStore(store.scope(state: { ViewState(selectedTheme: $0.selectedTheme) }))
    }

    var body: some View {
        WithViewStore(self.store.scope(state: \.topics)) { viewStore in
            NavigationView {
                List {
                    ForEach(viewStore.state) { topic in
                        Section(header: Text(topic.title)) {
                            ForEach(topic.themes) { theme in
                                Button(action: {
                                    viewStore.send(.showTheme(theme))
                                }) {
                                    Text(theme.title)
                                        .padding(.vertical, 8)
                                }
                                .accentColor(Color(.label))
                            }
                        }
                    }
                }
                .fullScreenCover(
                    item: self.viewStore.binding(
                        get: \.selectedTheme,
                        send: AppAction.showTheme
                    )
                ) { theme in
                    IfLetStore(
                        self.store.scope(
                            state: \.selectedQuizState, action: AppAction.quiz),
                        then: QuizView.init(store:)
                    )
                }
                .listStyle(InsetGroupedListStyle())
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        ZStack {
                            if GameKitHelper.shared.enabled {
                                Button(action: {
                                    GameKitHelper.shared.authenticateLocalPlayer()
                                }, label: {
                                    Image(systemName: "list.star")
                                })
                            } else {
                                Color.clear
                            }
                        }
                    }
                }
                .navigationTitle(Text("topics.title", comment: "Topic screen title."))
            }
        }
        .background(
            GeometryReader { proxy in
                Color.clear.onAppear {
                    let insets = proxy.safeAreaInsets
                    Constant.bottomInset = insets.bottom
                }
            }
        )
    }


}

struct AppView_Previews: PreviewProvider {
    static var previews: some View {
        AppView(
            store: Store(
                initialState: AppState(topics: [Topic.placeholder, .placeholder, .placeholder]),
                reducer: appReducer,
                environment: AppEnvironment(
                    mainQueue: DispatchQueue.main.eraseToAnyScheduler(),
                    databaseClient: .noop
                )
            )
        )
        .preferredColorScheme(.dark)
    }
}
