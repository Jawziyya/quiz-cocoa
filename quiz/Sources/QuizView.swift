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
import DatabaseClient

let questionMaxTime: Double = 30

struct QuizState: Equatable, Hashable {
    var theme: Theme
    var question: QuizQuestionState?
    var progress: QuizProgressViewState? = .init(progress: 0, score: 0)

    var time: Double = 0
    var timeProgress: Double = 0

    var questionsComplete = 0 {
        didSet {
            let progress = CGFloat(questionsComplete) / CGFloat(theme.questions.count) * 1
            let score = self.progress?.score ?? 0
            self.progress = .init(progress: progress, score: score)
        }
    }

    var presentCancellationAlert = false
}

enum QuizAction: Equatable {
    case start
    case finish
    case `continue`
    case timerTick
    case quizQuestion(QuizQuestionAction)
    case quizProgress(QuizProgressViewAction)
}

struct QuizEnvironment {
    let mainQueue = DispatchQueue.main.eraseToAnyScheduler()
    let quizQuestionEnvironment = QuizQuestionEnvironment()
    let databaseClient: DatabaseClient
}

let quizReducer = Reducer.combine(
    Reducer<QuizState, QuizAction, QuizEnvironment> { state, action, env in

        struct TimerId: Hashable {}

        switch action {

        case .timerTick:

            defer {
                state.question?.timeProgress = 1 - ((questionMaxTime - state.time) / questionMaxTime)
            }

            state.time += 1
            if state.time >= questionMaxTime {
                state.time = 0
                state.questionsComplete += 1
                return .merge(
                    .cancel(id: TimerId()),
                    .init(value: .quizQuestion(.continueFlow))
                )
            }
            return .none

        case .start:
            return .merge(
                .cancel(id: TimerId()),
                Effect.timer(
                    id: TimerId(),
                    every: 1,
                    tolerance: .zero,
                    on: env.mainQueue
                )
                .map { _ in .timerTick }
            )

        case .continue:
            state.presentCancellationAlert = false
            return .init(value: .start)

        case .quizProgress(.cancel):
            state.presentCancellationAlert = true
            return Effect.cancel(id: TimerId())

        case .quizQuestion(.commitAnswer(let answer)):
            state.questionsComplete += 1
            if answer.isCorrect, var progress = state.progress {
                progress.score += Constant.correctAnswerPoints
                state.progress = progress
            }
            state.time = 0
            return .cancel(id: TimerId())

        case .quizQuestion(.continueFlow):
            let questions = state.theme.questions
            if
                let prev = state.question?.question,
                let index = questions.firstIndex(of: prev),
                let question = questions[safe: index + 1]
            {
                state.question = .init(question: question)
                return .init(value: .start)
            } else {
                return .init(value: .finish)
            }

        default:
            return .none

        }
    },
    quizQuestionReducer
      .optional()
      .pullback(
        state: \.question,
        action: /QuizAction.quizQuestion,
        environment: { $0.quizQuestionEnvironment }
      ),
    quizProgressViewReducer
        .optional()
        .pullback(
            state: \.progress,
            action: /QuizAction.quizProgress,
            environment: { _ in () }
        )
)
.debugActions("⁉️ QuizView", actionFormat: .labelsOnly)

struct QuizView: View {

    struct State: Equatable {
        var question: QuizQuestionState?
        init(from state: QuizState) {
            question = state.question
        }
    }

    typealias Store = ComposableArchitecture.Store<QuizState, QuizAction>

    let store: Store

    @ObservedObject var viewStore: ViewStore<State, Never>

    init(store: Store) {
        self.store = store
        viewStore = ViewStore(store.actionless.scope(state: State.init))
    }

    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        WithViewStore(store) { viewStore in
            VStack {
                IfLetStore(
                    self.store.scope(
                        state: \.progress,
                        action: QuizAction.quizProgress
                    ),
                    then: QuizProgressView.init(store:)
                )

                IfLetStore(
                    self.store.scope(
                        state: { $0.question },
                        action: QuizAction.quizQuestion),
                    then: QuizQuestionView.init(store:)
                )
            }
            .navigationBarTitle(Text(viewStore.theme.title), displayMode: .inline)
            .alert(isPresented: .constant(viewStore.presentCancellationAlert)) {
                Alert(title: Text("Are you sure?"), primaryButton: Alert.Button.default(Text("common.yes", comment: "YES"), action: {
                    viewStore.send(.finish)
                }), secondaryButton: .cancel(Text("common.no", comment: "NO"), action: {
                    viewStore.send(.continue)
                }))
            }
            .onAppear {
                viewStore.send(.start)
            }
        }
    }

}

struct QuizView_Previews: PreviewProvider {
    static var previews: some View {
        return QuizView(
            store: Store(
                initialState: QuizState(
                    theme: Theme.placeholder,
                    question: QuizQuestionState(question: .placeholder1, answer: nil),
                    progress: .init(progress: 30, score: 200)
                ),
                reducer: quizReducer,
                environment: QuizEnvironment(databaseClient: DatabaseClient.noop)
            )
        )
    }
}
