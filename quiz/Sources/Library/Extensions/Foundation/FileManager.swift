//
//
//  quiz
//  
//  Created on 15.08.2021
//  Copyright © 2021 Al Jawziyya. All rights reserved.
//  

import Foundation

public extension FileManager {

    func listFiles(in directoryPath: String, type: String) -> [URL] {
        // Enumerators are recursive
        let enumerator = FileManager.default.enumerator(atPath: directoryPath)
        var urls: [URL] = []

        while let filePath = enumerator?.nextObject() as? String {
            let url = URL(fileURLWithPath: filePath)
            if url.pathExtension == type {
                urls.append(url)
            }
        }
        return urls
    }

}
