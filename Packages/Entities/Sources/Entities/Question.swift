//
//
//  
//  
//  Created on 06.03.2021
//  
//  

import Foundation

public struct Question: Equatable, Hashable, Identifiable, Decodable {

    public static let testData: [Question] = {
        let url = Bundle.main.url(forResource: "questions_ru", withExtension: "json")!
        let data = try! Data(contentsOf: url)
        let decoder = JSONDecoder()
        return try! decoder.decode([Question].self, from: data)
    }()

    public enum CodingKeys: String, CodingKey {
        case id, title, description, reference, difficulty
        case _options = "options", _answers = "answers", _theme_id = "theme_id"
    }

    public typealias Option = String

    let _options: String
    let _answers: String
    let _theme_id: Int

    public let id: Int
    public let title: String

    public let description: String?
    public let reference: String?
    public let difficulty: DifficultyLevel

    public var options: [Option] {
        _options.components(separatedBy: ";")
    }

    public var answers: [Option] {
        let indices = _answers.components(separatedBy: ";")
        if indices.isEmpty {
            if let index = Int(_answers) {
                return [options[index]]
            } else {
                return []
            }
        } else {
            return indices.map { Int($0) ?? 0 }.map { options[$0] }
        }
    }

    public var hasCorrectAnswer: Bool {
        answers.isEmpty == false
    }

    public var hasMoreThanOneCorrectAnswer: Bool {
        answers.count > 1
    }

    public static var placeholder1: Question {
        testData[0]
    }

    public static var placeholder2: Question {
        testData[1]
    }

}
