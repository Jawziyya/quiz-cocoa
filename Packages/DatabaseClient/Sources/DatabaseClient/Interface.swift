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

extension Entities.Round: PersistableRecord, FetchableRecord {
    public static var databaseTableName: String { "rounds" }
}

public struct DatabaseClient {

    public var fetchStats: Effect<Stats?, Error>
    public var migrate: Effect<Void, Error>

    public struct Stats: Codable, FetchableRecord, PersistableRecord {
        let secondsPlayed: Int
    }

}
