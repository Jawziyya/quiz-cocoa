//
//
//  
//  
//  Created on 21.03.2021
//  
//  

import Foundation
import ComposableArchitecture

extension DatabaseClient {

    public static var noop: DatabaseClient {
        .init(
            fetchStats: .init(value: Stats(secondsPlayed: 100)),
            fetchTopics: .none,
            fetchThemes: .none,
            fetchQuestions: .none,
            migrate: .none
        )
    }

}
