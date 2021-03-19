//
//
//  quiz
//  
//  Created on 07.03.2021
//  
//  

import SwiftUI
import ComposableArchitecture
import Entities

struct QuizTopicsState: Equatable {
    let topics: [Topic]
    var selectedTheme: Theme?
    var selectedQuizState: QuizState?
}

enum QuizTopicsAction: Equatable {
    case showTheme(Theme?)
    case quiz(QuizAction)
    case finish
}

struct QuizTopicsEnvironment {
    var mainQueue: AnySchedulerOf<DispatchQueue>
}

let quizTopicsReducer = Reducer.combine(
    quizReducer
        .optional()
        .pullback(
            state: \.selectedQuizState,
            action: /QuizTopicsAction.quiz,
            environment: { asd in
                QuizEnvironment()
            }
        ),
    Reducer<QuizTopicsState, QuizTopicsAction, QuizTopicsEnvironment> { state, action, env in

        switch action {

        case .showTheme(let theme):
            if let theme = theme {
                state.selectedTheme = theme
                state.selectedQuizState = .init(theme: theme, quizQuestion: QuizQuestionState(question: .placeholder1))
            }
            return .none

        // This will be called by QuizView on `Continue` button tap.
        // The navigation view will be popped and resources will be disposed after some delay in .finish case ↓
        case .quiz(.finish):
//            state.selectedTheme = nil
//            state.selectedQuizState?.isPresented = false
            return Effect(value: .finish)
                .delay(for: 0.3, scheduler: env.mainQueue.eraseToAnyScheduler())
                .eraseToEffect()

        // Dispose the resources.
        case .finish:
            state.selectedQuizState = nil
            state.selectedTheme = nil
            return .none

        default:
            return .none

        }
    }
)
.debugActions("QuizTopicsView", actionFormat: .labelsOnly)

struct QuizTopicsView: View {

    typealias QuizTopicsStore = Store<QuizTopicsState, QuizTopicsAction>

    let store: QuizTopicsStore
    @ObservedObject var viewStore: ViewStore<ViewState, QuizTopicsAction>

    struct ViewState: Equatable {
        var selectedTheme: Theme?
    }

    init(store: QuizTopicsStore) {
        self.store = store
        viewStore = ViewStore(store.scope(state: { ViewState.init(selectedTheme: $0.selectedTheme) }))
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
                        send: QuizTopicsAction.showTheme
                    )
                ) { theme in
                    IfLetStore(
                        self.store.scope(
                            state: \.selectedQuizState, action: QuizTopicsAction.quiz),
                        then: QuizView.init(store:)
                    )
                }
                .listStyle(InsetGroupedListStyle())
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

struct QuizTopicsView_Previews: PreviewProvider {
    static var previews: some View {
        QuizTopicsView(
            store: Store(
                initialState: QuizTopicsState(topics: [Topic.placeholder, .placeholder, .placeholder]),
                reducer: quizTopicsReducer,
                environment: QuizTopicsEnvironment(mainQueue: DispatchQueue.main.eraseToAnyScheduler()))
        )
        .preferredColorScheme(.dark)
    }
}
