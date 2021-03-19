//
//
//  
//  
//  Created on 11.03.2021
//  
//  

import Foundation

public struct Topic: Hashable, Decodable, Identifiable {

    public let id: Int
    public let title: String
    public let themes: [Theme]

    public init(id: Int, title: String, themes: [Theme]) {
        self.id = id
        self.title = title
        self.themes = themes
    }

    public static var placeholder: Topic {
        .init(id: 0, title: "Topic: " + UUID().uuidString, themes: [
            .placeholder,
            .placeholder,
            .placeholder
        ])
    }

}
