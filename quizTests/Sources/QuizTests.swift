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
            initialState: QuizState(theme: theme, quizQuestion: QuizQuestionState(question: question1), score: 0, progress: 0, questionsComplete: 0, isPresented: true, presentCancellationAlert: false),
            reducer: quizReducer,
            environment: QuizEnvironment()
        )
    }

    func testQuizHasCorrectScore() {
        let store = createTestStore()
        store.assert(.send(.quizQuestion(.continueFlow), { state in
            state.quizQuestion = .init(question: self.question2)
        }))
    }

    func testQuizHasCorrectProgress() {
        let store = createTestStore()
        let answer = Answer(isCorrect: true)
        store.assert(.send(.quizQuestion(.commitAnswer(answer)), { state in
            state.quizQuestion = .init(question: self.question1, answer: answer)
            state.score = 1
            state.questionsComplete = 1
            state.progress = CGFloat(state.questionsComplete) / CGFloat(state.theme.questions.count) * 100
        }))
    }

    func testQuizHasCorrectNextQuestionAndProgress() {
        let store = createTestStore()
        let incorrectAnswer = Answer(isCorrect: false)

        store.assert(

            .send(.quizQuestion(.commitAnswer(incorrectAnswer))) { state in
                state.quizQuestion = .init(question: self.question1, answer: incorrectAnswer)
                state.progress = 50
                state.questionsComplete = 1
                state.score = 0
            },

            .send(.quizQuestion(.continueFlow)) { state in
                state.quizQuestion = .init(question: self.question2, answer: nil)
            },

            .send(.quizQuestion(.commitAnswer(incorrectAnswer))) { state in
                state.progress = 100
                state.questionsComplete = 2
                state.quizQuestion = .init(question: self.question2, answer: incorrectAnswer)
            }

        )
    }

}
