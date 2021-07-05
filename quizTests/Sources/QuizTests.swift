//
//
//  quizTests
//
//  Created on 14.03.2021
//  Copyright © 2021 Al Jawziyya. All rights reserved.
//

import XCTest
import ComposableArchitecture
import Entities
@testable import quiz

class QuizTests: XCTestCase {

    let question1 = Question.placeholder1
    let question2 = Question.placeholder2
    let theme = Theme.placeholder

    func createTestStore() -> TestStore<QuizState, QuizState, QuizAction, QuizAction, QuizEnvironment> {
        TestStore(
            initialState:
                QuizState(
                    theme: theme,
                    question: QuizQuestionState(question: question1, answer: .none),
                    progress: QuizProgressViewState(progress: 0, score: 0),
                    time: 0,
                    timeProgress: 0,
                    questionsComplete: 0,
                    presentCancellationAlert: false
                )
            ,
            reducer: quizReducer,
            environment: QuizEnvironment(databaseClient: .noop)
        )
    }

    func testQuizHasCorrectScore() {
        let store = createTestStore()
        store.assert(
            .send(.quizQuestion(.continueFlow), { state in
                state.question = .init(question: self.question2)
            }),
            .receive(.finish)
        )
    }

    func testQuizHasCorrectProgress() {
        let store = createTestStore()
        let answer = Answer(isCorrect: true)
        store.assert(
            .send(.quizQuestion(.commitAnswer(answer)), { state in
                state.question = .init(question: self.question1, answer: answer)
                state.progress = .init(
                    progress: CGFloat(state.questionsComplete) / CGFloat(state.theme.questions.count) * 100,
                    score: 50
                )
                state.questionsComplete = 1
            })
        )
    }

    func testQuizHasCorrectNextQuestionAndProgress() {
        let store = createTestStore()
        let incorrectAnswer = Answer(isCorrect: false)

        store.assert(
            .send(.quizQuestion(.commitAnswer(incorrectAnswer))) { state in
                state.question = .init(question: self.question1, answer: incorrectAnswer)
                state.progress = .init(progress: 50, score: 0)
                state.questionsComplete = 1
            },

            .send(.quizQuestion(.continueFlow)) { state in
                state.question = .init(question: self.question2, answer: .init(isCorrect: false))
            },

            .send(.quizQuestion(.commitAnswer(incorrectAnswer))) { state in
                state.progress = .init(progress: 100, score: 0)
                state.questionsComplete = 2
                state.question = .init(question: self.question2, answer: incorrectAnswer)
            }
        )
    }

}
