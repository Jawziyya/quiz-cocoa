//
//
//  quiz
//  
//  Created on 15.08.2021
//  Copyright © 2021 Al Jawziyya. All rights reserved.
//  

import SwiftUI
import ComposableArchitecture
import Lottie
import ConfettiSwiftUI

struct QuizResultsState: Equatable, Hashable {

    enum Score: String, Equatable, Hashable {
        case bad, nice, excellent
    }

    let points: Int
    let correctAnswers: Int
    let totalQuestions: Int

    var score: Score {
        let correctAnswersPercentage = (Float(correctAnswers) / Float(totalQuestions))
        switch correctAnswersPercentage {
        case 0..<0.25: return .bad
        case 0.25..<0.8: return .nice
        default: return .excellent
        }
    }

    var scoreTitle: String {
        switch score {
        case .bad: return "Почти неплохо!"
        case .nice: return "Хорошо, но можно лучше!"
        case .excellent: return "Отлично!"
        }
    }
}

enum QuizResultsAction: Equatable {
    case `continue`
    case share
}

struct QuizResultsEnvironment { }

let quizResultsReducer = Reducer<QuizResultsState, QuizResultsAction, QuizResultsEnvironment> { state, action, env in
    return .none
}

struct QuizResultsView: View {

    typealias ResultsStore = Store<QuizResultsState, QuizResultsAction>

    let store: ResultsStore

    @State private var confettiCounter = 0

    var textColor: SwiftUI.Color {
        Color("text")
    }

    var backgroundColor: SwiftUI.Color {
        Color("results/background")
    }

    func getMessageColor(score: QuizResultsState.Score) -> SwiftUI.Color {
        Color("results/message")
    }

    func getConfettiView(for score: QuizResultsState.Score) -> some View {
        let confettiNumber: Int
        switch score {
        case .bad: confettiNumber = 1
        case .nice: confettiNumber = 5
        case .excellent: confettiNumber = 5
        }

        let interval: Double
        switch score {
        case .bad: interval = 0.3
        case .nice: interval = 0.35
        case .excellent: interval = 0.15
        }

        return ConfettiCannon(
            counter: $confettiCounter,
            num: confettiNumber,
            confettiSize: 8,
            rainHeight: 800,
            fadesOut: true,
            openingAngle: Angle(degrees: 0),
            closingAngle: Angle(degrees: 360),
            radius: 200,
            repetitions: 5000,
            repetitionInterval: interval
        )
        .onAppear {
            confettiCounter += 1
        }
        .frame(height: 50)
        .frame(maxWidth: .infinity)
        .offset(y: -300)
    }

    var rocketImage: some View {
        Image("results/rocket")
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(height: 250)
            .frame(maxWidth: .infinity)
    }

    var body: some View {
        WithViewStore(store) { viewStore in
            VStack {

                rocketImage
                    .padding()
                    .background(getConfettiView(for: viewStore.score))

                Spacer()

                Text(viewStore.scoreTitle)
                    .font(Font.system(size: 60, weight: .bold, design: .rounded).lowercaseSmallCaps())
                    .lineLimit(1)
                    .minimumScaleFactor(0.3)
                    .foregroundColor(getMessageColor(score: viewStore.score))
                    .shadow(color: getMessageColor(score: viewStore.score).opacity(0.5), radius: 4, x: 0, y: 0)
                    .padding()

                Spacer()

                Text("\(viewStore.correctAnswers)/\(viewStore.totalQuestions)")
                    .frame(maxWidth: .infinity)
                    .font(Font.title2.bold())
                    .foregroundColor(Color.accentColor)
                    .padding(.horizontal)
                    .padding(.vertical, 10)
                    .background(
                        RoundedRectangle(cornerRadius: 18)
                            .stroke(Color.accentColor, style: StrokeStyle(lineWidth: 2))
                            .foregroundColor(Color.clear)
                            .padding(.horizontal, 50)
                    )
                    .overlay(
                        Image("results/star")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 90, height: 160)
                            .offset(x: 10, y: 25)
                        ,
                        alignment: .leading
                    )
                    .accentColor(getMessageColor(score: viewStore.score))

                Spacer()

                Button(action: {
                    // TODO: Create a view dedicated to this action.
                    let image = rocketImage.background(Color(.systemBackground)).frame(width: 300).snapshot()
                    let text = "Я завершил тест, ответит на \(viewStore.correctAnswers)/\(viewStore.totalQuestions) вопросов..."
                    self.showShareSheet(with: [image, text])
                }, label: {
                    Text("Поделиться результатами")
                        .font(Font.system(.callout, design: .rounded).weight(.medium))
                        .foregroundColor(textColor)
                        .underline()
                })

                Color.clear.frame(height: 30)

                Button(action: {
                    viewStore.send(.continue)
                }, label: {
                    HStack {
                        Spacer()
                        Text("ПРОДОЛЖИТЬ")
                            .font(Font.callout.bold().smallCaps())
                            .foregroundColor(Color.white)
                            .padding()
                        Spacer()
                    }
                })
                .buttonStyle(PressDownButtonStyle(insets: UIEdgeInsets(top: 0, left: 0, bottom: 2, right: 0), backgroundColor: Colors.blue))
                .if(Constant.bottomInset == 0) { v in
                    v.padding(.bottom, 20)
                }
                .padding(.horizontal)
                .frame(height: 60, alignment: .bottom)
                .zIndex(0.1)
                .animation(.none)
                .layoutPriority(1)
            }
            .navigationBarHidden(true)
        }
        .background(
            backgroundColor.edgesIgnoringSafeArea(.all)
        )
    }

}

struct QuizResultsView_Preview: PreviewProvider {

    static var previews: some View {
        let store = Store<QuizResultsState, QuizResultsAction>(
            initialState: QuizResultsState(points: 100, correctAnswers: 20, totalQuestions: 20),
            reducer: quizResultsReducer,
            environment: QuizResultsEnvironment()
        )

        return Group {
            QuizResultsView(store: store)
                .environment(\.colorScheme, .light)
            QuizResultsView(store: store)
                .environment(\.colorScheme, .dark)
        }
    }

}
