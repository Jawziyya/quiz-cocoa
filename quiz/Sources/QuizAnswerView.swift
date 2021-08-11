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

enum QuizAnswerViewModel: Equatable, Hashable {
    case text(String)
    case image(ImageType)
    case textAndImage(text: String, image: ImageType, positioning: TextAndImagePositioning)
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

        case .image(let imageType):
            getImage(imageType)

        case .textAndImage:
            getTextAndImageView(type: type)

        }
    }

    @ViewBuilder
    func getTextAndImageView(type: QuizAnswerViewModel) -> some View {
        switch type {

        case .text, .image:
            EmptyView()

        case .textAndImage(let text, let imageType, let positioning):
            switch positioning {
            case .vStack:
                VStack {
                    Text(text)
                    Spacer()
                    getImage(imageType)
                }

            case .zStack:
                ZStack(alignment: Alignment.top) {
                    getImage(imageType)
                    Text(text)
                        .padding(4)
                        .background(Colors.secondaryBackground.cornerRadius(4))
                }
            }

        }
    }

    @ViewBuilder
    func getImage(_ type: ImageType) -> some View {
        switch type {

        case .bundled(let name):
            Image(name)
                .resizable()
                .aspectRatio(contentMode: .fill)

        case .system(let name):
            Image(systemName: name)
                .resizable()
                .aspectRatio(contentMode: .fit)

        case .remote(let url):
            AsyncImage(
                url: url,
                scale: 1,
                content: { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                },
                placeholder: {
                    Image(systemName: "photo")
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .padding()
                        .foregroundColor(Color.secondary)
                }
            )
            .equatable()
            .frame(width: Constant.quizImageCardSize * 0.8, height: Constant.quizImageCardSize * 0.8)

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
//            QuizAnswerView(store: getStore(vm: .text("Test")))
//            QuizAnswerView(store: getStore(vm: .image(.bundled("table"))))
//            QuizAnswerView(store: getStore(vm: .textAndImage(text: "Test", image: .bundled("table"))))
//            QuizAnswerView(store: getStore(vm: .image(ImageType.remote(istanbulMosqueImageURL))))
            QuizAnswerView(store: getStore(vm: .textAndImage(
                text: "Istanbul",
                image: .remote(URL(string: "https://images.unsplash.com/photo-1527838832700-5059252407fa?ixlib=rb-1.2.1&ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&auto=format&fit=crop&w=943&q=80")!), positioning: .zStack))
            )
        }
        .previewLayout(.fixed(width: 200, height: 200))
    }
}
