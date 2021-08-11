//
//
//  
//  
//  Created on 21.03.2021
//  
//  

import Foundation
import ComposableArchitecture
import GRDB
import Entities

extension Entities.Topic: FetchableRecord, TableRecord {
    public static var databaseTableName: String { "topics" }
    static let themes = hasMany(Entities.Theme.self, using: ForeignKey(["topic_id"], to: ["id"]))
}

extension Entities.Theme: FetchableRecord, TableRecord {
    public static var databaseTableName: String { "themes" }
    static let questions = hasMany(Entities.Question.self, using: ForeignKey(["theme_id"], to: ["id"]))
}

extension Entities.Question: FetchableRecord, TableRecord {
    public static var databaseTableName: String { "questions" }
    static let options = hasMany(Entities.Option.self, using: ForeignKey(["question_id"], to: ["id"]))
}

extension Entities.Option: FetchableRecord, TableRecord, EncodableRecord {
    public static var databaseTableName: String { "answers" }
    static let question = hasOne(Entities.Question.self, using: ForeignKey(["question_id"], to: ["id"]))
}

extension Entities.Round: PersistableRecord, FetchableRecord, EncodableRecord {
    public static var databaseTableName: String { "rounds" }
}

public struct QuestionData: Decodable, FetchableRecord {
    public let question: Question
    public let answers: [Option]
}

public struct DatabaseClient {

    public var fetchStats: Effect<Stats?, Error>
    public var fetchTopics: Effect<[Topic], Error>
    public var fetchThemes: Effect<[Theme], Error>
    public var fetchQuestions: Effect<[Question], Error>
    public var migrate: Effect<Void, Error>

    public struct Stats: Codable, FetchableRecord, PersistableRecord {
        let secondsPlayed: Int
    }

}
