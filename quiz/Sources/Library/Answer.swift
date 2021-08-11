//
//
//  quiz
//  
//  Created on 07.08.2021
//  Copyright © 2021 Al Jawziyya. All rights reserved.
//  

import Foundation

struct Answer: Identifiable, Equatable, Hashable, Codable {
    let isCorrect: Bool

    var id: String {
        isCorrect.description
    }
}
