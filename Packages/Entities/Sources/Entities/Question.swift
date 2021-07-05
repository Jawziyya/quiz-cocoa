//
//
//  
//  
//  Created on 06.03.2021
//  
//  

import Foundation

public struct Question: Equatable, Hashable, Identifiable, Decodable {

    public enum CodingKeys: String, CodingKey {
        case id, title, description, reference, difficulty, answers
        case _theme_id = "theme_id"
    }

    let _theme_id: Int

    public let id: Int
    public let title: String

    public let description: String?
    public let reference: String?
    public let difficulty: DifficultyLevel

    public let answers: [Option]

    public var hasCorrectAnswer: Bool {
        answers.filter(\.isCorrect).isEmpty == false
    }

    public var hasMoreThanOneCorrectAnswer: Bool {
        answers.filter(\.isCorrect).count > 1
    }

    public static var placeholder1: Question {
        Question(_theme_id: 1, id: 1, title: "", description: "", reference: "", difficulty: .easy, answers: [Option.init(id: 1, questionId: 1, text: "", isCorrect: true, image: nil)])
    }

    public static var placeholder2: Question {
        placeholder1
    }

}
