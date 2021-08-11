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
        case id, title, description, reference, difficulty, options = "answers"
        case _theme_id = "theme_id"
    }

    let _theme_id: Int

    public let id: Int
    public let title: String

    public let description: String?
    public let reference: String?
    public let difficulty: DifficultyLevel

    public let options: [Option]

    public var hasCorrectAnswer: Bool {
        options.filter(\.isCorrect).isEmpty == false
    }

    public var hasMoreThanOneCorrectAnswer: Bool {
        options.filter(\.isCorrect).count > 1
    }

    public static var placeholder1: Question {
        Question(
            _theme_id: 1,
            id: 1,
            title: "В каком городе находится мечеть Пророка?",
            description: "",
            reference: "Question reference",
            difficulty: .easy,
            options: [
                Option(id: 1, questionId: 1, text: "Мекка", isCorrect: false, image: "https://images.unsplash.com/photo-1580418827493-f2b22c0a76cb?ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&ixlib=rb-1.2.1&auto=format&fit=crop&w=934&q=80"),
                Option(id: 2, questionId: 1, text: "Медина", isCorrect: true, image: "https://images.unsplash.com/photo-1540866225557-9e4c58100c67?ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&ixlib=rb-1.2.1&auto=format&fit=crop&w=940&q=80"),
                Option(id: 3, questionId: 1, text: "Иерусалим", isCorrect: false, image: "https://images.unsplash.com/photo-1552423314-cf29ab68ad73?ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&ixlib=rb-1.2.1&auto=format&fit=crop&w=1950&q=80"),
                Option(id: 4, questionId: 1, text: "Дамаск", isCorrect: false, image: "https://images.unsplash.com/photo-1580310219243-dbad8c44e576?ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&ixlib=rb-1.2.1&auto=format&fit=crop&w=1950&q=80"),
            ]
        )
    }

    public static var placeholder2: Question {
        Question(
            _theme_id: 1,
            id: 1,
            title: "В каком городе находится мечеть Пророка?",
            description: "",
            reference: "Question reference",
            difficulty: .easy,
            options: [
                Option(id: 1, questionId: 1, text: "Мекка", isCorrect: false, image: nil),
                Option(id: 2, questionId: 1, text: "Медина", isCorrect: true, image: nil),
                Option(id: 3, questionId: 1, text: "Иерусалим", isCorrect: false, image: nil),
                Option(id: 4, questionId: 1, text: "Дамаск", isCorrect: false, image: nil),
            ]
        )
    }

    public static var placeholderWithImages: Question {
        Question(
            _theme_id: 1,
            id: 1,
            title: "What do you like more?",
            description: "",
            reference: "Some reference",
            difficulty: .easy,
            options: [
                Option(id: 1, questionId: 1, text: "Table", isCorrect: false, image: "table"),
                Option(id: 2, questionId: 1, text: "Bird", isCorrect: true, image: "bird"),
                Option(id: 3, questionId: 1, text: "Cat", isCorrect: false, image: "cat"),
                Option(id: 4, questionId: 1, text: "Space", isCorrect: false, image: "space"),
            ]
        )
    }

    public static var placeholderWithLongTitleAndImages: Question {
        Question(
            _theme_id: 1,
            id: 1,
            title: "В каком направлении при молитве поворачивались мусульмане в первые года Ислама?",
            description: "",
            reference: "Question reference",
            difficulty: .easy,
            options: [
                Option(id: 1, questionId: 1, text: "Мекка", isCorrect: false, image: "https://images.unsplash.com/photo-1580418827493-f2b22c0a76cb?ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&ixlib=rb-1.2.1&auto=format&fit=crop&w=934&q=80"),
                Option(id: 2, questionId: 1, text: "Медина", isCorrect: false, image: "https://images.unsplash.com/photo-1540866225557-9e4c58100c67?ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&ixlib=rb-1.2.1&auto=format&fit=crop&w=940&q=80"),
                Option(id: 3, questionId: 1, text: "Иерусалим", isCorrect: true, image: "https://images.unsplash.com/photo-1552423314-cf29ab68ad73?ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&ixlib=rb-1.2.1&auto=format&fit=crop&w=1950&q=80"),
                Option(id: 4, questionId: 1, text: "Дамаск", isCorrect: false, image: "https://images.unsplash.com/photo-1580310219243-dbad8c44e576?ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&ixlib=rb-1.2.1&auto=format&fit=crop&w=1950&q=80"),
            ]
        )
    }

    public static var placeholderWithLongTitle: Question {
        Question(
            _theme_id: 1,
            id: 1,
            title: "В каком направлении при молитве поворачивались мусульмане в первые года Ислама?",
            description: "",
            reference: "Some reference",
            difficulty: .easy,
            options: [
                Option(id: 1, questionId: 1, text: "Мекка", isCorrect: false, image: nil),
                Option(id: 2, questionId: 1, text: "Иерусалим", isCorrect: true, image: nil),
                Option(id: 3, questionId: 1, text: "Медина", isCorrect: false, image: nil),
                Option(id: 4, questionId: 1, text: "Дамаск", isCorrect: false, image: nil),
            ]
        )
    }

}
