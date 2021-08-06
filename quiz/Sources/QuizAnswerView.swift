//
//
//  quiz
//  
//  Created on 07.03.2021
//  
//  

import SwiftUI
import ComposableArchitecture
import Entities

enum ImageType {
    case bundled, system
}

enum QuizAnswerViewModel: Equatable, Hashable {
    case text(String)
    case image(_ name: String, type: ImageType = .bundled)
    case textAndImage(text: String, imageName: String, imageType: ImageType = .bundled)
}

struct ImageAndTextView: View {
    var body: some View {
        Text("test")
    }
}

struct QuizAnswerState: Equatable, Hashable {
    let option: Option
    let viewModel: QuizAnswerViewModel
    var showCheckmark = true
    var isSelected = false
}

enum QuizAnswerAction: Equatable {
    case select
}

typealias QuizAnswerEnvironment = Void

let quizAnswerReducer = Reducer<QuizAnswerState, QuizAnswerAction, QuizAnswerEnvironment> { state, action, env in
    switch action {
    case .select:
        state.isSelected.toggle()
    }
    return .none
}

/**
 Represents one answer option along others.

 [1] [2]  <-- One of these items in grid.
 [3] [4]
 */
struct QuizAnswerView: View {

    let store: ViewStore<QuizAnswerState, QuizAnswerAction>

    var body: some View {
        Button(action: {
            store.send(.select)
        }, label: {
            VStack {
                getView(for: store.viewModel)
                    .padding()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .foregroundColor(store.isSelected ? Color.accentColor : Color(.label))
                    .background(store.isSelected ? Color.accentColor.opacity(0.2) : Color.clear)
            }
        })
        .buttonStyle(
            PressDownButtonStyle(
                insets: UIEdgeInsets(top: 2, left: 2, bottom: 2, right: 2),
                backgroundColor: Color(.systemBackground),
                bottomLayerColor: Color.accentColor
            )
        )
    }

    @ViewBuilder
    private func getView(for type: QuizAnswerViewModel) -> some View {
        switch type {
        case .text(let text):
            Text(text)
        case .image(let imageName, let type):
            getImage(name: imageName, type: type)
        case .textAndImage(let text, let imageName, let imageType):
            VStack {
                Text(text)
                Spacer()
                getImage(name: imageName, type: imageType)
            }
        }
    }

    @ViewBuilder
    func getImage(name: String, type: ImageType) -> some View {
        switch type {
        case .bundled:
            Image(name)
                .resizable()
                .aspectRatio(contentMode: .fit)
        case .system:
            Image(systemName: name).resizable().aspectRatio(contentMode: .fit)
        }
    }

}

struct QuizAnswerView_Previews: PreviewProvider {
    static var previews: some View {
        func getStore(vm: QuizAnswerViewModel) -> ViewStore<QuizAnswerState, QuizAnswerAction> {
            return .init(Store(
                initialState: QuizAnswerState(option: .placeholder, viewModel: vm),
                reducer: quizAnswerReducer,
                environment: ())
            )
        }

        return Group {
            QuizAnswerView(store: getStore(vm: .text("Test")))
            QuizAnswerView(store: getStore(vm: .image("table")))
            QuizAnswerView(store: getStore(vm: .textAndImage(text: "Test", imageName: "table")))
        }
        .previewLayout(.fixed(width: 200, height: 200))
    }
}
