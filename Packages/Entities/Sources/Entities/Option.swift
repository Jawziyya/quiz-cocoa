//
//
//  
//  
//  Created on 05.07.2021
//  
//  

import Foundation

public struct Option: Equatable, Hashable, Identifiable, Codable {
    enum CodingKeys: String, CodingKey {
        case id, text, image
        case questionId = "question_id"
        case isCorrect = "is_correct"
    }

    public let id: Int
    public let questionId: Int
    public let text: String
    public let isCorrect: Bool
    public let image: String?

    public static var placeholder: Option {
        Option(id: 1, questionId: 1, text: "Text", isCorrect: true, image: nil)
    }
}
