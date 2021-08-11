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

struct QuizTopicsState: Equatable {
    let topics: [Topic]
    var selectedTheme: Theme?
    var selectedQuizState: QuizState?
}

enum QuizTopicsAction: Equatable {
    case home
    case showTheme(Theme?)
    case quiz(QuizAction)
    case finish
}

struct QuizTopicsEnvironment {
    let mainQueue: AnySchedulerOf<DispatchQueue>
    let databaseClient: DatabaseClient
}

let quizTopicsReducer = Reducer.combine(
    quizReducer
        .optional()
        .pullback(
            state: \.selectedQuizState,
            action: /QuizTopicsAction.quiz,
            environment: { env in
                QuizEnvironment(databaseClient: env.databaseClient)
            }
        ),
    Reducer<QuizTopicsState, QuizTopicsAction, QuizTopicsEnvironment> { state, action, env in

        switch action {

        case .home:
            return .none

        case .showTheme(let theme):
            if let theme = theme, let question = theme.questions.first {
                state.selectedTheme = theme
                state.selectedQuizState = .init(theme: theme, question: QuizQuestionState(question: question))
            }
            return .none

        // This will be called by QuizView on `Continue` button tap.
        // The navigation view will be popped and resources will be disposed after some delay in .finish case ↓
        case .quiz(.finish):
            let quizState = state.selectedQuizState
            if quizState?.progress?.progress == 100 && quizState?.progress?.score == quizState?.questionsComplete {
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
.debugActions("QuizTopicsView", actionFormat: .labelsOnly)

/**
 Displays list of quiz themes grouped by their topics.

 Topic 1
  - Theme 1
  - Theme 2

 Topic 2
  - Theme 1
  - Theme 2
  - Theme 3
 */
struct QuizTopicsView: View {

    typealias QuizTopicsStore = Store<QuizTopicsState, QuizTopicsAction>

    let store: QuizTopicsStore
    @ObservedObject var viewStore: ViewStore<QuizTopicsViewState, QuizTopicsAction>

    struct QuizTopicsViewState: Equatable {
        var selectedTheme: Theme?
    }

    init(store: QuizTopicsStore) {
        self.store = store
        viewStore = ViewStore(store.scope(state: { QuizTopicsViewState(selectedTheme: $0.selectedTheme) }))
    }

    var body: some View {
        WithViewStore(self.store.scope(state: \.topics)) { viewStore in
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
                    send: QuizTopicsAction.showTheme
                )
            ) { theme in
                IfLetStore(
                    self.store.scope(
                        state: \.selectedQuizState,
                        action: QuizTopicsAction.quiz
                    ),
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
        .background(
            GeometryReader { proxy in
                Color.clear.onAppear {
                    let insets = proxy.safeAreaInsets
                    Constant.quizImageCardSize = (proxy.size.width / 2.5).rounded(.up)
                    Constant.bottomInset = UIApplication.shared.windows.first?.safeAreaInsets.bottom ?? insets.bottom
                }
            }
        )
    }


}

struct AppView_Previews: PreviewProvider {
    static var previews: some View {
        QuizTopicsView(
            store: Store(
                initialState: QuizTopicsState(topics: [Topic.placeholder, .placeholder, .placeholder]),
                reducer: quizTopicsReducer,
                environment: QuizTopicsEnvironment(
                    mainQueue: DispatchQueue.main.eraseToAnyScheduler(),
                    databaseClient: .noop)
            )
        )
        .preferredColorScheme(.dark)
    }
}
