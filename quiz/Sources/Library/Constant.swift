//
//
//  quiz
//  
//  Created on 07.03.2021
//  
//  

import UIKit

enum Constant {

    static var cornerRadius: CGFloat = 10

    static var quizImageCardSize: CGFloat = 0
    static var bottomInset: CGFloat = 0

    /// This is a bottom inset to apply to controls at the bottom of the screen
    /// for old devices as iPhone 8, for newest devices this will be equal to zero.
    static var bottomInsetForOldDevices: CGFloat {
        bottomInset == 0 ? 16 : 0
    }

    static let correctAnswerPoints = 50

    static let questionMaxTime: Double = 10

}
