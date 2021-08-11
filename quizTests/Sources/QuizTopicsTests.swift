//
//
//  quiz
//
//  Created on 10.03.2021
//  Copyright © 2021 Al Jawziyya. All rights reserved.
//

import XCTest
import ComposableArchitecture
@testable import quiz
import Entities
import DatabaseClient

class QuizTopicsTests: XCTestCase {

    let testScheduler = DispatchQueue.testScheduler.eraseToAnyScheduler()

    func testTopicsListSelection() {
        let topics: [Topic] = [.placeholder, .placeholder, .placeholder]
        let store = TestStore(
            initialState: QuizTopicsState(topics: topics, selectedTheme: nil, selectedQuizState: nil),
            reducer: quizTopicsReducer,
            environment: QuizTopicsEnvironment(mainQueue: testScheduler, databaseClient: DatabaseClient.noop)
        )

        let question = Question.placeholder1
        let theme = Theme(id: 1, title: "Theme", questions: [question])
        store.assert(.send(.showTheme(theme), { state in
            state.selectedTheme = theme
            state.selectedQuizState = .init(
                theme: theme,
                question: QuizQuestionState(question: question, answer: .none),
                progress: QuizProgressViewState(progress: 0, score: 0),
                questionsComplete: 0,
                presentCancellationAlert: false
            )
        }))
    }

}
