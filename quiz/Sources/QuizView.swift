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

struct QuizState: Equatable, Hashable {
    var theme: Theme
    var quizQuestion: QuizQuestionState?

    var score = 0
    var progress: CGFloat = 0
    var questionsComplete = 0 {
        didSet {
            progress = CGFloat(questionsComplete) / CGFloat(theme.questions.count) * 100
        }
    }

    var isPresented = true
    var presentCancellationAlert = false
}

enum QuizAction: Equatable {
    case start
    case quizQuestion(QuizQuestionAction)
    case finish
    case dismiss
    case cancel
}

struct QuizEnvironment {
    let quizQuestionEnvironment = QuizQuestionEnvironment()
}

let quizReducer = Reducer.combine(
    Reducer<QuizState, QuizAction, QuizEnvironment> { state, action, env in
        switch action {

        case .start:
            return .none

        case .cancel:
            state.presentCancellationAlert = true
            return .none

        case .dismiss:
//            state.isPresented = false
            return .none

        case .quizQuestion(.commitAnswer(let answer)):
            state.questionsComplete += 1
            if answer.isCorrect {
                state.score += 1
            }
            return .none

        case .quizQuestion(.continueFlow):
            let questions = state.theme.questions
            if
                let prev = state.quizQuestion?.question,
                let index = questions.firstIndex(of: prev),
                let question = questions[safe: index + 1]
            {
                state.quizQuestion = .init(question: question)
                return .none
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
        state: \.quizQuestion,
        action: /QuizAction.quizQuestion,
        environment: { $0.quizQuestionEnvironment }
      )
)
.debugActions("QuizView", actionFormat: .labelsOnly)

struct QuizView: View {

    struct State: Equatable {
        var question: QuizQuestionState?
        init(from state: QuizState) {
            question = state.quizQuestion
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
                HStack(spacing: 16) {
                    Button(action: {
                        viewStore.send(.cancel)
                    }) {
                        Image(systemName: "xmark")
                            .resizable()
                            .frame(width: 18, height: 18)
                            .contentShape(Rectangle().inset(by: -10))
                    }
                    
                    LinearProgress(progress: viewStore.progress, foregroundColor: Color.accentColor, backgroundColor: Color.gray.opacity(0.15), cornerRadius: Constant.cornerRadius, fillAxis: .horizontal)
                        .frame(height: 15)
                        .animation(Animation.spring().speed(1.1))

                    HStack {
                        Text("quiz.score", comment: "Quiz score label.")
                            .font(Font.system(.title2, design: .monospaced))
                            .foregroundColor(Color.accentColor)
                            +
                            Text(": " + viewStore.score.description)
                            .font(Font.system(.title2, design: .monospaced))
                            .foregroundColor(Color.accentColor.darker(by: 10))
                    }
                }
                .padding(.horizontal)
                
                IfLetStore(
                    self.store.scope(
                        state: { $0.quizQuestion },
                        action: QuizAction.quizQuestion),
                    then: QuizQuestionView.init(store:)
                )
            }
            .navigationBarTitle(Text(viewStore.theme.title), displayMode: .inline)
            .onChange(of: viewStore.isPresented) { isPresented in
                if !isPresented {
                    self.presentationMode.wrappedValue.dismiss()
                }
            }
            .alert(isPresented: .constant(viewStore.presentCancellationAlert)) {
                Alert(title: Text("Are you sure?"), primaryButton: Alert.Button.default(Text("common.yes", comment: "Yes"), action: {
                    viewStore.send(.finish)
                }), secondaryButton: .cancel())
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
                    quizQuestion: QuizQuestionState(question: .placeholder1, answer: Answer(isCorrect: true)),
                    progress: 50
                ),
                reducer: quizReducer,
                environment: QuizEnvironment()
            )
        )
    }
}
