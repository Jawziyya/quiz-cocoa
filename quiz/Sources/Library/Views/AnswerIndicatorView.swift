//
//
//  quiz
//  
//  Created on 30.06.2021
//  Copyright © 2021 Al Jawziyya. All rights reserved.
//  

import SwiftUI

let correctAnswerBackgroundColor = Colors.green.lighter(by: 30)
let wrongAnswerBackgroundColor = Colors.red.lighter(by: 30)

struct AnswerIndicatorView: View {

    let answerIsCorrect: Bool
    let correctAnswer: String
    let complain: (() -> Void)

    private let bodyFont = Font.body.smallCaps()
    private let boldBodyFont = Font.body.weight(.heavy).smallCaps()

    private var correctTitle: String {
        let variants = ["great", "awesome", "excellent", "perfect"]
        return NSLocalizedString("quiz.correct.\(variants.randomElement()!)", comment: "")
    }

    var body: some View {
        HStack {
            if answerIsCorrect {
                Text(correctTitle + "!")
                    .font(boldBodyFont)
            } else {
                Text("quiz.incorrect-title", comment: "Incorrect title")
                    .font(bodyFont)
                +
                Text(": " + correctAnswer)
                    .font(boldBodyFont)
            }

            Spacer(minLength: 16)
            Button(action: {
                self.complain()
            }, label: {
                Image(systemName: "flag")
                    .font(Font.body.weight(.black))
            })
        }
        .foregroundColor(answerIsCorrect ? Colors.green : Colors.red)
        .padding()
        .background(
            ZStack {
                if answerIsCorrect {
                    correctAnswerBackgroundColor
                } else {
                    wrongAnswerBackgroundColor
                }
            }
            .edgesIgnoringSafeArea(.bottom)
        )
    }
}

struct AnswerIndicatorView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            AnswerIndicatorView(answerIsCorrect: false, correctAnswer: "Correct answer is this: It is really hard to align views sometimes.") { }

            AnswerIndicatorView(answerIsCorrect: true, correctAnswer: "Correct answer is this...") { }
        }
        .previewLayout(.fixed(width: 350, height: 150))
    }
}
