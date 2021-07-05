//
//
//  quizTests
//  
//  Created on 09.03.2021
//  
//  

import XCTest
import Entities
import ComposableArchitecture
@testable import quiz

class QuizAnswerTests: XCTestCase {

    func testAnswerSelection() {
        let option = Option.placeholder

        let store = TestStore(
            initialState: QuizAnswerState(option: option, viewModel: .text("option")),
            reducer: quizAnswerReducer,
            environment: ()
        )

        store.assert(
            .send(.select, { state in
                state.isSelected = true
            })
        )
    }
    
}
