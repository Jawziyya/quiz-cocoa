//
//
//  quiz
//  
//  Created on 07.08.2021
//  Copyright © 2021 Al Jawziyya. All rights reserved.
//  

import Foundation
import Entities

extension Option {

    var quizAnswerState: QuizAnswerState {
        let text = text.isEmpty ? nil : text
        let vm: QuizAnswerViewModel

        if let image = image {
            let imageType: ImageType
            if image.contains("http"), let url = URL(string: image) {
                imageType = .remote(url)
            } else {
                imageType = .bundled(image)
            }

            if let text = text {
                vm = .textAndImage(text: text, image: imageType, positioning: .zStack)
            } else {
                vm = .image(imageType)
            }
        } else {
            vm = .text(text ?? "")
        }

        return QuizAnswerState(option: self, viewModel: vm, isSelected: false)
    }

}
