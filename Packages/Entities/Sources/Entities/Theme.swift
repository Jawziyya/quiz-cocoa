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
    public let titleImage: String

    public init (id: Int, title: String, questions: [Question], titleImage: String) {
        self.id = id
        self.title = title
        self.questions = questions
        self.titleImage = titleImage
    }

    public static var placeholder: Theme {
        .init(id: 0, title: "Theme: " + UUID().uuidString, questions: [Question.placeholder1, .placeholder2], titleImage: "")
    }

    public static var quran: Theme {
        .init(id: 1, title: "Quran", questions: [], titleImage: "")
    }

    public static var sira: Theme {
        .init(id: 2, title: "Sira", questions: [], titleImage: "")
    }
    public static var salyat: Theme {
        .init(id: 3, title: "Salyat", questions: [], titleImage: "")
    }
    public static var hadj: Theme {
        .init(id: 4, title: "Hadj", questions: [], titleImage: "")
    }
    public static var zakat: Theme {
        .init(id: 5, title: "Zakat", questions: [], titleImage: "")
    }
    public static var ramadan: Theme {
        .init(id: 6, title: "Ramadan", questions: [], titleImage: "")
    }
}

