//
//
//  quiz
//  
//  Created on 07.08.2021
//  Copyright © 2021 Al Jawziyya. All rights reserved.
//  

import SwiftUI

/**
 Timer based progress view.
 */
struct QuizQuestionProgressView: View, Equatable {

    static func == (lhs: QuizQuestionProgressView, rhs: QuizQuestionProgressView) -> Bool {
        lhs.questionId == rhs.questionId
    }

    let questionId: Int

    @State var time: Double = 0
    var timeElapsedCompletion: (() -> Void)?

    private var progress: CGFloat {
        CGFloat(time / Constant.questionMaxTime)
    }

    let timer = Timer.publish(every: 0.025, on: .main, in: .common).autoconnect()

    var body: some View {
        LinearProgress(progress: progress, foregroundColor: Color.white.opacity(0.2), cornerRadius: Constant.cornerRadius)
            .onReceive(timer) { _ in
                if time >= Constant.questionMaxTime {
                    time = 0
                    timer.upstream.connect().cancel()
                    timeElapsedCompletion?()
                    return
                }
                time += 0.025
            }
    }

}
struct QuizQuestionProgressView_Previews: PreviewProvider {
    static var previews: some View {
        QuizQuestionProgressView(questionId: 1)
    }
}
