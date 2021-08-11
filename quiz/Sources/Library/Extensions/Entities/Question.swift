//
//
//  quiz
//  
//  Created on 07.08.2021
//  Copyright © 2021 Al Jawziyya. All rights reserved.
//  

import Entities

extension Question {

    func getCorrectOptions() -> [Option] {
        options.filter(\.isCorrect)
    }

    func getCorrectAnswer() -> String {
        if hasMoreThanOneCorrectAnswer {
            return getCorrectOptions().reduce("", { $0 + ", \($1.text)" })
        } else {
            return getCorrectOptions()[0].text
        }
    }

}
