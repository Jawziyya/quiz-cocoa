//
//
//  quiz
//  
//  Created on 07.03.2021
//  
//  

import SwiftUI
import Entities
import ComposableArchitecture

typealias Option = Question.Option

private func getRandomIndices() -> [Int] {
    Array(0..<4).shuffled()
}

private var randomIndices: [Int] = getRandomIndices()

struct Answer: Identifiable, Equatable, Hashable {
    let isCorrect: Bool

    var id: String {
        isCorrect.description
    }
}

struct QuizQuestionState: Equatable, Hashable {
    let question: Question

    init(question: Question, answer: Answer? = nil) {
        self.question = question
        self.options = zip(question.options, ["table", "bird", "space", "cat"])
            .map { option, imageName in
                QuizAnswerState(option: option, viewModel: .textAndImage(text: option, imageName: imageName, imageType: .bundled), isSelected: false)
            }
        self.answer = answer
    }

    var options: [QuizAnswerState]

    var title: String { question.title }

    func getAnswer() -> Answer {
        let selection = Set(options.filter(\.isSelected).map(\.option))
        return Answer(isCorrect: selection.subtracting(Set(question.answers)).isEmpty)
    }

    func getCorrectAnswer() -> String {
        question.answers.joined(separator: ", ")
    }

    var canCommit = false
    var showComplainMenu = false
    var answer: Answer?

    var hasAnswer: Bool {
        answer != nil
    }

    var commitButtonTitle: String {
        hasAnswer ? NSLocalizedString("quiz.continue", comment: "") : NSLocalizedString("quiz.check", comment: "")
    }

    var answerIsCorrect: Bool {
        answer?.isCorrect == true
    }
}

enum QuizQuestionAction: Equatable {
    case optionSelection(_ option: QuizAnswerState)
    case selectOption(index: Int, action: QuizAnswerAction)
    case commitAnswer(Answer)
    case complain
    case continueFlow
}

struct QuizQuestionEnvironment {
}

let quizQuestionReducer = Reducer<QuizQuestionState,  QuizQuestionAction, QuizQuestionEnvironment>.combine(
    Reducer { state, action, environment in

        switch action {

        case .optionSelection(let option):
            return .none

        case .selectOption(let index, let action):
            if state.question.hasMoreThanOneCorrectAnswer {
                state.options[index].isSelected.toggle()
            } else {
                for i in 0..<state.options.count {
                    let isSelected: Bool
                    let isSelectedOld = state.options[i].isSelected
                    if i == index, isSelectedOld {
                        isSelected = false
                    } else {
                        isSelected = i == index
                    }
                    state.options[i].isSelected = isSelected
                }
            }
            state.canCommit = state.options.contains(where: { $0.isSelected })
            state.answer = nil
            return .none

        case .commitAnswer(let answer):
            assert(Thread.isMainThread)
            if answer.isCorrect {
                UIImpactFeedbackGenerator(style: .soft).impactOccurred()
                SoundEffect.playSuccess()
            } else {
                SoundEffect.playError()
            }

            state.answer = answer

            return .none

        case .complain:
            state.showComplainMenu = true
            return .none

        case .continueFlow:
            randomIndices = getRandomIndices()
            return .none

        }
    }
)

struct QuizQuestionView: View {

    let store: Store<QuizQuestionState, QuizQuestionAction>

    private let buttonHeight: CGFloat = 60

    var body: some View {
        WithViewStore(store) { viewStore in
            ZStack(alignment: .bottom) {
                if viewStore.hasAnswer {
                    AnswerIndicatorView(
                        answerIsCorrect: viewStore.answerIsCorrect,
                        correctAnswer: viewStore.state.getCorrectAnswer(),
                        complain: {
                            viewStore.send(.complain)
                        }
                    )
                    .padding(.bottom, buttonHeight)
                    .background(
                        (viewStore.answerIsCorrect ? correctAnswerBackgroundColor : wrongAnswerBackgroundColor)
                            .edgesIgnoringSafeArea(.all)
                    )
                    .transition(.asymmetric(insertion: .move(edge: .bottom), removal: .opacity))
                    .animation(.interactiveSpring())
                    .zIndex(0)
                }

                VStack {
                    VStack(alignment: .center, spacing: 40) {
                        HStack(alignment: .top) {
                            Text(viewStore.title)
                                .font(Font.system(.largeTitle, design: .rounded).weight(.medium))
                                .frame(height: 140)
                                .minimumScaleFactor(0.3)
                            Spacer()
                        }

                        getAnswersView(options: randomIndices.map { viewStore.state.options[$0] })
                    }
                    .disabled(viewStore.hasAnswer)
                    .padding()

                    Color.clear.frame(height: 60)

                    Button(action: {
                        if viewStore.hasAnswer {
                            viewStore.send(.continueFlow)
                            return
                        }

                        guard viewStore.canCommit else {
                            return
                        }
                        viewStore.send(.commitAnswer(viewStore.state.getAnswer()))
                    }, label: {
                        HStack {
                            Spacer()
                            Text(viewStore.commitButtonTitle)
                                .font(Font.callout.bold().smallCaps())
                                .foregroundColor(Color.white)
                                .padding()
                            Spacer()
                        }
                    })
                    .opacity(viewStore.canCommit ? 1 : 0.5)
                    .disabled(!viewStore.canCommit)
                    .buttonStyle(PressDownButtonStyle(insets: UIEdgeInsets(top: 0, left: 0, bottom: 2, right: 0), backgroundColor: viewStore.hasAnswer ? viewStore.answerIsCorrect ? Colors.green : Colors.red : Colors.blue))
                    .padding(.horizontal)
                    .frame(height: buttonHeight, alignment: .bottom)
                    .zIndex(0.1)
                    .animation(.none)
                }
            }
            .overlay(
                Group {
                    if viewStore.hasAnswer && viewStore.answerIsCorrect {
                        LottieView(name: "confetti\(Int.random(in: 1...4))", loopMode: .playOnce)
                            .edgesIgnoringSafeArea(.all)
                            .disabled(true)
                            .zIndex(1)
                    }
                }
            )
        }
    }

    @ViewBuilder
    func getAnswersView(options: [QuizAnswerState]) -> some View {
        switch options[0].viewModel {

        case .text:
            VStack(alignment: .center, spacing: 16) {
                ForEach((randomIndices), id: \.self) { idx in
                    WithViewStore(
                        self.store.scope(
                            state: { $0.options[idx] },
                            action: { QuizQuestionAction.selectOption(index: idx, action: $0) }
                        ), content: QuizAnswerView.init(store:)
                    )
                }
            }

        case .textAndImage:
            VStack(alignment: .center) {
                HStack {

                    ForEach(Array(randomIndices.prefix(2)), id: \.self) { idx in
                        WithViewStore(
                            self.store.scope(
                                state: { $0.options[idx] },
                                action: { QuizQuestionAction.selectOption(index: idx, action: $0) }
                            ), content: QuizAnswerView.init(store:)
                        )
                    }
                }

                HStack {
                    ForEach(randomIndices.suffix(from: 2), id: \.self) { idx in
                        WithViewStore(
                            self.store.scope(
                                state: { $0.options[idx] },
                                action: { QuizQuestionAction.selectOption(index: idx, action: $0) }
                            ), content: QuizAnswerView.init(store:)
                        )
                    }
                }
            }

        default:
            Text("TE")
        }
    }

}

struct QuizQuestionView_Previews: PreviewProvider {
    static var previews: some View {
        QuizQuestionView(
            store: Store(
                initialState: QuizQuestionState(question: .placeholder1, answer: Answer(isCorrect: false)),
                reducer: quizQuestionReducer,
                environment: QuizQuestionEnvironment()
            )
        )
        .accentColor(Color(.systemIndigo))
    }
}
