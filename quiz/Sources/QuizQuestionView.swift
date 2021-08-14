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

func getAnswer(to question: Question, options: [QuizAnswerState]) -> Answer {
    if question.hasCorrectAnswer && question.hasMoreThanOneCorrectAnswer == false, let selectedOption = options.first(where: \.isSelected) {
        return Answer(isCorrect: selectedOption.option.isCorrect)
    } else if question.hasMoreThanOneCorrectAnswer {
        let selection = Set(options.filter(\.isSelected).map(\.option))
        return Answer(isCorrect: selection.subtracting(Set(question.options)).isEmpty)
    } else {
        return .init(isCorrect: false)
    }
}

private func getRandomIndices() -> [Int] {
    Array(0..<4).shuffled()
}

private var randomIndices: [Int] = getRandomIndices()

struct QuizQuestionState: Equatable, Hashable {
    let question: Question

    init(question: Question, answer: Answer? = nil) {
        self.question = question
        self.answer = answer
        options = question.options.map(\.quizAnswerState)
    }

    var options: [QuizAnswerState]

    var title: String { question.title }

    func compileAnswer() -> Answer {
        getAnswer(to: question, options: options)
    }

    func getCorrectAnswerDescription() -> String {
        question.getCorrectAnswer()
    }

    var canCommit = false
    var showComplainMenu = false
    var answer: Answer?

    var timeProgress: Double = 0

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
    case timeout
}

struct QuizQuestionEnvironment {
}

let quizQuestionReducer = Reducer<QuizQuestionState,  QuizQuestionAction, QuizQuestionEnvironment>.combine(
    Reducer { state, action, environment in

        switch action {

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

        case .timeout:
            return .none

        default:
            return .none

        }
    }
)

/**
 This view represents one question and it's options.

 It also includes a button at the bottom of the container (either `Commit answer` or `Continue`).


 ------------
   QUESTION
    TITLE?

 ⎡          ⎤
   [1]  [2]
   [3]  [4]
 ⎣          ⎦

   CONTINUE
 ------------

 */
struct QuizQuestionView: View {

    let store: Store<QuizQuestionState, QuizQuestionAction>

    private let buttonHeight: CGFloat = 60

    var body: some View {
        WithViewStore(store) { viewStore in
            ZStack(alignment: .bottom) {

                // Answer indicator overlay view at the bottom.
                if viewStore.hasAnswer {
                    AnswerIndicatorView(
                        answerIsCorrect: viewStore.answerIsCorrect,
                        correctAnswer: viewStore.state.getCorrectAnswerDescription(),
                        complain: {
                            viewStore.send(.complain)
                        }
                    )
                    .padding(.bottom, buttonHeight + Constant.bottomInsetForOldDevices)
                    .background(
                        (viewStore.answerIsCorrect ? correctAnswerBackgroundColor : wrongAnswerBackgroundColor)
                            .edgesIgnoringSafeArea(.all)
                    )
                    .transition(.asymmetric(insertion: .move(edge: .bottom), removal: .opacity))
                    .animation(.interactiveSpring())
                    .zIndex(0)
                }

                VStack(alignment: .center, spacing: 0) {
                    // Question title.
                    Group {
                        getTitleView(title: viewStore.title)
                            .layoutPriority(1)

                        // Answer options
                        getAnswersView(options: randomIndices.map { viewStore.state.options[$0] })
                            .layoutPriority(0.5)
                    }
                    .disabled(viewStore.hasAnswer)
                    .padding(.horizontal)

                    Color.clear.frame(minHeight: 20, idealHeight: 74, maxHeight: .infinity)
                        .layoutPriority(0.4)

                    Button(action: {
                        if viewStore.hasAnswer {
                            viewStore.send(.continueFlow)
                            return
                        }

                        if viewStore.canCommit {
                            viewStore.send(.commitAnswer(viewStore.state.compileAnswer()))
                        }
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
                    .if(Constant.bottomInset == 0) { v in
                        v.padding(.bottom, 20)
                    }
                    .overlay(
                        ZStack {
                            if viewStore.hasAnswer {
                                Color.clear
                            } else {
                                QuizQuestionProgressView(questionId: viewStore.question.id) {
                                    viewStore.send(.timeout)
                                }
                                .equatable()
                                .allowsHitTesting(false)
                            }
                        }
                    )
                    .padding(.horizontal)
                    .frame(height: buttonHeight, alignment: .bottom)
                    .zIndex(0.1)
                    .animation(.none)
                    .layoutPriority(1)
                }
            }
            .overlay(
                Group {
                    if viewStore.hasAnswer && viewStore.answerIsCorrect {
                        LottieView(name: "confetti\(Int.random(in: 1...4))", loopMode: .playOnce)
                            .edgesIgnoringSafeArea(.all)
                            .allowsHitTesting(false)
                            .zIndex(1)
                    }
                }
            )
        }
    }

    private func getTitleView(title: String) -> some View {
        HStack(alignment: .top) {
            Text(title)
                .font(Font.system(.largeTitle, design: .rounded).weight(.medium))
                .minimumScaleFactor(0.25)
                .frame(minHeight: 100, idealHeight: 140, maxHeight: 200)
                .padding(.vertical, 30)
            Spacer()
        }
    }

    @ViewBuilder
    func getAnswersView(options: [QuizAnswerState]) -> some View {
        switch options[0].viewModel {

        case .text:
            VStack(alignment: .center, spacing: 16) {
                Spacer()
                ForEach((randomIndices), id: \.self) { idx in
                    QuizAnswerView(
                        store: self.store.scope(
                            state: { $0.options[idx] },
                            action: { QuizQuestionAction.selectOption(index: idx, action: $0) }
                        )
                    )

                }
                Spacer()
            }
            .frame(height: Constant.quizImageCardSize * 2)

        case .textAndImage:
            VStack(alignment: .center) {
                LazyVGrid(
                    columns: [
                        GridItem(.fixed(Constant.quizImageCardSize), spacing: 30, alignment: nil),
                        GridItem(.fixed(Constant.quizImageCardSize), spacing: 30, alignment: nil)
                    ],
                    alignment: HorizontalAlignment.center,
                    spacing: 16) {

                    ForEach(Array(randomIndices), id: \.self) { idx in
                        QuizAnswerView(
                            store: self.store.scope(
                                state: { $0.options[idx] },
                                action: { QuizQuestionAction.selectOption(index: idx, action: $0) }
                            )
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
        Constant.quizImageCardSize = UIScreen.main.bounds.width/2.5
        func getStore(question: Question) -> Store<QuizQuestionState, QuizQuestionAction> {
            Store(
                initialState: QuizQuestionState(question: question, answer: nil),
                reducer: quizQuestionReducer,
                environment: QuizQuestionEnvironment()
            )
        }
        func getQuestionView(question: Question = Question.placeholder1) -> QuizQuestionView {
            QuizQuestionView(store: getStore(question: question))
        }

        return Group {
            getQuestionView(question: Question.placeholderWithLongTitleAndImages)
                .previewLayout(.fixed(width: 375, height: 667))
                .previewDisplayName("Small device")

            getQuestionView()

            getQuestionView()
                .previewDevice("iPhone 12 Pro")

            getQuestionView()
                .previewDevice("iPhone 8")
        }
    }
}
