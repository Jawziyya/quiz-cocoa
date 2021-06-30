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

    public static func live(url: URL) -> Self {
        var _db: DatabasePool!
        func db() throws -> DatabasePool {
          if _db == nil {
            _db = try DatabasePool(path: url.path)
          }
          return _db
        }

        return Self(

            fetchStats: .catching {
                try db().read { db in
                    try Stats.fetchOne(db)
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
