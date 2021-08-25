//
//
//  quiz
//  
//  Created on 04.07.2021
//  Copyright © 2021 Al Jawziyya. All rights reserved.
//  

import SwiftUI
import ComposableArchitecture

struct QuizProgressViewState: Equatable, Hashable {
    var progress: CGFloat
    var score: Int
}

enum QuizProgressViewAction: Equatable {
    case cancel
}

typealias QuizProgressViewEnv = Void

let quizProgressViewReducer = Reducer<QuizProgressViewState, QuizProgressViewAction, QuizProgressViewEnv> { state, action, _ in
    return .none
}

/**
 Represents quiz progress with progress bar and points number.

 Has a close button which triggers cancel action on tap.
 */
struct QuizProgressView: View {

    typealias QuizProgressViewStore = Store<QuizProgressViewState, QuizProgressViewAction>

    let store: QuizProgressViewStore

    var body: some View {
        WithViewStore(store) { viewStore in
            HStack(spacing: 16) {
                Button(action: {
                    viewStore.send(.cancel)
                }) {
                    Image(systemName: "xmark")
                        .resizable()
                        .frame(width: 18, height: 18)
                        .contentShape(Rectangle().inset(by: -20))
                }

                LinearProgress(
                    progress: viewStore.progress,
                    foregroundColor: Color.accentColor,
                    backgroundColor: Color.gray.opacity(0.15),
                    cornerRadius: Constant.cornerRadius,
                    fillAxis: .horizontal
                )
                .frame(height: 14)
                .animation(Animation.spring().speed(1.1))

                Text(viewStore.score.description)
                    .foregroundColor(Colors.green)
                    .font(Font.system(.caption, design: .monospaced))
                    .frame(minWidth: 20)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Colors.green, lineWidth: 1)
                    )
            }
            .padding(.horizontal)
        }
    }
}

struct QuizProgressView_Previews: PreviewProvider {
    static var previews: some View {
        func getStore(progress: CGFloat, score: Int) -> QuizProgressView.QuizProgressViewStore {
            .init(
                initialState: QuizProgressViewState(progress: progress, score: score),
                reducer: quizProgressViewReducer,
                environment: ()
            )
        }

        return Group {
            QuizProgressView(store: getStore(progress: 0.5, score: 1))
                .environment(\.colorScheme, .dark)

            QuizProgressView(store: getStore(progress: 0.25, score: 1000))

            QuizProgressView(store: getStore(progress: 1, score: 125))
        }
        .previewLayout(.fixed(width: 375, height: 50))
        .accentColor(Colors.blue)
    }
}
