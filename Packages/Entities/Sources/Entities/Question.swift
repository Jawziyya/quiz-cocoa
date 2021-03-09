//
//
//  
//  
//  Created on 06.03.2021
//  
//  

import Foundation

public struct Question: Equatable, Hashable, Identifiable, Codable {

    public typealias Option = String

    public init(id: Int, title: String, options: [Option], answers: [Option]) {
        self.id = id
        self.title = title
        self.options = options
        self.answers = answers
    }

    public let id: Int
    public let title: String
    public let options: [Option]
    public let answers: [Option]

    public var hasCorrectAnswer: Bool {
        answers.isEmpty == false
    }

    public var hasMoreThanOneCorrectAnswer: Bool {
        answers.count > 1
    }
    
}
