//
//
//  quiz
//  
//  Created on 11.03.2021
//  Copyright © 2021 Al Jawziyya. All rights reserved.
//  

import Foundation

extension Collection {

    subscript(safe index: Index) -> Element? {
        self.indices.contains(index) ? self[index] : nil
    }

}
