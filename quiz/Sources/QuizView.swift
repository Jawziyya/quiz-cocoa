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

struct QuizState: Equatable, Hashable {
    var theme: Theme
    var question: QuizQuestionState?
    var progress: QuizProgressViewState? = .init(progress: 0, score: 0)

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

        switch action {

        case .start:
            return .none

        case .continue:
            state.presentCancellationAlert = false
            return .init(value: .start)

        case .quizProgress(.cancel):
            state.presentCancellationAlert = true
            return .none

        case .quizQuestion(.commitAnswer(let answer)):
            state.questionsComplete += 1
            if answer.isCorrect, var progress = state.progress {
                progress.score += Constant.correctAnswerPoints
                state.progress = progress
            }
            return .none

        case .quizQuestion(.continueFlow):
            let questions = state.theme.questions
            if
                let prev = state.question?.question,
                let index = questions.firstIndex(of: prev),
                let question = questions[safe: index + 1]
            {
                state.question = .init(question: question)
                return .none
            } else {
                return .init(value: .finish)
            }

        case .quizQuestion(.timeout):
            return .init(value: .quizQuestion(.continueFlow))

        case .finish:
            state.question = nil
            return .none

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

/**
 Represents one Quiz with number of child questions.

 Has progress view as top and QuizQuestionView as it's bottom.
 */
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
            VStack(spacing: 0) {
                Color.clear.frame(height: 16)

                IfLetStore(
                    self.store.scope(
                        state: \.progress,
                        action: QuizAction.quizProgress
                    ),
                    then: QuizProgressView.init(store:)
                )
                .layoutPriority(2)

                IfLetStore(
                    self.store.scope(
                        state: { $0.question },
                        action: QuizAction.quizQuestion),
                    then: QuizQuestionView.init(store:)
                )
            }
            .accentColor(Colors.blue)
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
        Constant.quizImageCardSize = UIScreen.main.bounds.width/2.5
        func getQuizView() -> some View {
            QuizView(
                store: Store(
                    initialState: QuizState(
                        theme: Theme.placeholder,
                        question: QuizQuestionState(question: .placeholderWithLongTitleAndImages, answer: nil),
                        progress: .init(progress: 30, score: 200)
                    ),
                    reducer: quizReducer,
                    environment: QuizEnvironment(databaseClient: DatabaseClient.noop)
                )
            )
        }

        return Group {
            getQuizView()
                .previewLayout(.fixed(width: 300, height: 667))

            getQuizView()
                .previewDevice("iPhone 12 Pro")
        }
    }
}
