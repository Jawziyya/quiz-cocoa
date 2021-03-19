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

class QuizTopicsTests: XCTestCase {

    let testScheduler = DispatchQueue.testScheduler.eraseToAnyScheduler()

    func testTopicsListSelection() {
        let topics: [Topic] = [.placeholder, .placeholder, .placeholder]
        let store = TestStore(
            initialState: QuizTopicsState(topics: topics, selectedTheme: nil, selectedQuizState: nil),
            reducer: quizTopicsReducer,
            environment: QuizTopicsEnvironment(mainQueue: testScheduler)
        )

        let selectedTopic = topics[0]
        let selectedTheme = selectedTopic.themes.first!
        store.assert(.send(.showTheme(selectedTheme), { state in
            state.selectedTheme = selectedTheme
            state.selectedQuizState = .init(theme: selectedTheme, quizQuestion: QuizQuestionState(question: Question.placeholder1), score: 0, progress: 0, questionsComplete: 0, isPresented: true, presentCancellationAlert: false)
        }))
    }

}
