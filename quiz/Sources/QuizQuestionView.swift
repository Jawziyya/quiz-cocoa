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

private func getRandomIndices() -> [Int] {
    Array(0..<4).shuffled()
}

private var randomIndices: [Int] = getRandomIndices()

struct Answer: Identifiable, Equatable, Hashable, Codable {
    let isCorrect: Bool

    var id: String {
        isCorrect.description
    }
}

struct QuizQuestionState: Equatable, Hashable {
    let question: Question

    init(question: Question, answer: Answer? = nil) {
        self.question = question
        self.options = zip(question.answers, ["table", "bird", "space", "cat"])
            .map { answer, imageName -> QuizAnswerState in
                let text = answer.text.isEmpty ? nil : answer.text
                let vm: QuizAnswerViewModel

                if let image = answer.image {
                    let imageType: ImageType
                    if let url = URL(string: image) {
                        imageType = .remote(url)
                    } else {
                        imageType = .bundled(image)
                    }

                    if let text = text {
                        vm = .textAndImage(text: text, image: imageType, positioning: .zStack)
                    } else {
                        vm = .image(imageType)
                    }
                } else {
                    vm = .text(text ?? "")
                }

                return QuizAnswerState(option: answer, viewModel: vm, isSelected: false)
            }
        self.answer = answer
    }

    var options: [QuizAnswerState]

    var title: String { question.title }

    func getAnswer() -> Answer {
        if question.hasCorrectAnswer && question.hasMoreThanOneCorrectAnswer == false, let selectedOption = options.first(where: \.isSelected) {
            return Answer(isCorrect: selectedOption.option.isCorrect)
        } else if question.hasMoreThanOneCorrectAnswer {
            let selection = Set(options.filter(\.isSelected).map(\.option))
            return Answer(isCorrect: selection.subtracting(Set(question.answers)).isEmpty)
        } else {
            return .init(isCorrect: false)
        }
    }

    func getCorrectAnswer() -> [Option] {
        question.answers.filter(\.isCorrect)
    }

    func getCorrectAnswerDescription() -> String {
        if question.hasMoreThanOneCorrectAnswer {
            return getCorrectAnswer().reduce("", { $0 + ", \($1.text)" })
        } else {
            return getCorrectAnswer()[0].text
        }
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

        case .timeout:
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
                        .layoutPriority(1)

                        Spacer()

                        // Answer options
                        getAnswersView(options: randomIndices.map { viewStore.state.options[$0] })
                            .layoutPriority(0.5)
                    }
                    .disabled(viewStore.hasAnswer)
                    .padding()

                    Spacer()
                    Color.clear.frame(height: 60)

                    Button(action: {
                        if viewStore.hasAnswer {
                            viewStore.send(.continueFlow)
                            return
                        }

                        if viewStore.canCommit {
                            viewStore.send(.commitAnswer(viewStore.state.getAnswer()))
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

                LazyVGrid(
                    columns: [
                        .init(.fixed(Constant.quizImageCardSize), spacing: 10, alignment: .center),
                        .init(.fixed(Constant.quizImageCardSize), spacing: 10, alignment: .center),
                    ],
                    alignment: HorizontalAlignment.center,
                    spacing: 20) {

                    ForEach(Array(randomIndices), id: \.self) { idx in
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
                initialState: QuizQuestionState(question: .placeholder1, answer: nil),
                reducer: quizQuestionReducer,
                environment: QuizQuestionEnvironment()
            )
        )
        .accentColor(Color(.systemIndigo))
    }
}
