//
//
//  quiz
//  
//  Created on 07.08.2021
//  Copyright © 2021 Al Jawziyya. All rights reserved.
//  

import Foundation

enum ImageType: Hashable, Equatable {
    case bundled(String)
    case system(String)
    case remote(URL)
}
