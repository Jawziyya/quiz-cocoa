//
//
//  
//  
//  Created on 11.03.2021
//  
//  

import Foundation

public struct Theme: Hashable, Decodable, Identifiable {
    public let id: Int
    public let title: String
    public let questions: [Question]

    public init (id: Int, title: String, questions: [Question]) {
        self.id = id
        self.title = title
        self.questions = questions
    }

    public static var placeholder: Theme {
        .init(id: 0, title: "Theme: " + UUID().uuidString, questions: Question.testData)
    }

    public static var quran: Theme {
        .init(id: 1, title: "Quran", questions: Question.testData)
    }

    public static var sira: Theme {
        .init(id: 1, title: "Sira", questions: Question.testData)
    }
}
