//
//
//  
//  
//  Created on 21.03.2021
//  
//  

import Foundation

public struct Round: Codable {
    public var id: Int
    public var theme: Int
    public var timePlayed: Int
    public var answers: [Int]
}
