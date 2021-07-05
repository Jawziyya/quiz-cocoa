//
//
//  quizTests
//
//  Created on 06.03.2021
//
//

import XCTest
import ComposableArchitecture
@testable import quiz
import Entities
import DatabaseClient

class QuizQuestionTests: XCTestCase {

    let scheduler = DispatchQueue.test

    let question = Question.placeholder1

    func createTestStore(question: Question) -> TestStore<QuizQuestionState, QuizQuestionState, QuizQuestionAction, QuizQuestionAction, QuizQuestionEnvironment> {
        TestStore(
            initialState: QuizQuestionState(question: question),
            reducer: quizQuestionReducer,
            environment: QuizQuestionEnvironment()
        )
    }

    func testQuizQuestionSelection() {
        let store = createTestStore(question: question)
        store.assert(.send(.selectOption(index: 0, action: .select), { state in
            state.canCommit = true
            state.options[0].isSelected = true
        }))
    }

    func testQuizContinueFlow() {
        let theme = Theme(id: 0, title: UUID().uuidString, questions: [Question.placeholder1])

        let quizViewStore = TestStore(
            initialState: QuizState(theme: theme, question: .init(question: question)),
            reducer: quizReducer,
            environment: QuizEnvironment(databaseClient: DatabaseClient.noop)
        )
        quizViewStore.scope(state: \.question)
            .assert(
                .send(.quizQuestion(.continueFlow)),
                .receive(.finish)
            )
    }

    func testQuizQuestionHasCorrectAnswerProperty() {
        let store = createTestStore(question: question)
        let validAnswer = Answer(isCorrect: true)
        store.assert(.send(.commitAnswer(validAnswer), { state in
            state.answer = validAnswer
        }))

        let invalidAnswer = Answer(isCorrect: false)
        store.assert(.send(.commitAnswer(invalidAnswer), { state in
            state.answer = invalidAnswer
        }))
    }

    func testQuizQuestionComplainMenuIsTrue() {
        let store = createTestStore(question: question)
        store.assert(.send(.complain, { state in
            state.showComplainMenu = true
        }))
    }

}
