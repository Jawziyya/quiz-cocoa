//
//
//  
//  
//  Created on 21.03.2021
//  
//  

import Foundation
import ComposableArchitecture
import Entities
import GRDB

private let fileManager = FileManager.default

extension DatabaseClient {

    public static func live(cacheDatabaseURL: URL, staticDatabaseURL: URL) -> Self {
        var _db: DatabasePool!
        var _staticDb: DatabasePool!
        func db() throws -> DatabasePool {
          if _db == nil {
            _db = try DatabasePool(path: cacheDatabaseURL.path)
          }
          return _db
        }

        func staticDatabase() throws -> DatabasePool {
          if _staticDb == nil {
              var config = Configuration()
              config.readonly = true
              _staticDb = try DatabasePool(path: staticDatabaseURL.path, configuration: config)
          }
          return _staticDb
        }

        return Self(
            fetchStats: .catching {
                try db().read { db in
                    try Stats.fetchOne(db)
                }
            },

            fetchTopics: .catching {
                try staticDatabase().read { db in
                    let topicsRequest = Topic
                        .including(
                            all: Topic.themes
                                .including(
                                    all: Theme.questions
                                        .including(all: Question.answers)
                                )
                        )
                    return try Topic.fetchAll(db, topicsRequest)
                }
            },

            fetchThemes: .catching{
                try staticDatabase().read { db in
                    let themesRequest = Theme
                        .including(
                            all: Theme.questions
                                .including(all: Question.answers)
                        )
                    return try Theme.fetchAll(db, themesRequest)
                }
            },

            fetchQuestions: .catching {
                try staticDatabase().read { db in
                    let questionsRequest = Question.including(all: Question.answers)
                    let questionsData = try Question.fetchAll(db, questionsRequest)
                    return questionsData
                }
            },

            migrate: .catching {
                var migrator = DatabaseMigrator()

                #if DEBUG
                // Speed up development by nuking the database when migrations change
                migrator.eraseDatabaseOnSchemaChange = true
                #endif

                migrator.registerMigration("createRounds") { db in
                    try db.create(table: Entities.Round.databaseTableName) { t in
                        t.autoIncrementedPrimaryKey("id")
                        t.column("theme", .integer).notNull()
                        t.column("timePlayed", .integer)
                        t.column("answers", .blob)
                    }
                }

                try migrator.migrate(try db())
            }
        )
    }

}
