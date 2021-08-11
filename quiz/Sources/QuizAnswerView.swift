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

    private let insets = UIEdgeInsets(top: 2, left: 2, bottom: 2, right: 2)

    let store: Store<QuizAnswerState, QuizAnswerAction>

    var body: some View {
        WithViewStore(store) { viewStore in
            Button(action: {
                viewStore.send(.select)
            }, label: {
                getView(for: viewStore.viewModel)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .foregroundColor(viewStore.isSelected ? Color.accentColor : Color(.label))
                    .background(viewStore.isSelected ? Color.accentColor.opacity(0.2) : Color.clear)
            })
            .buttonStyle(
                PressDownButtonStyle(
                    insets: insets,
                    backgroundColor: Color(.systemBackground),
                    bottomLayerColor: Color.gray,
                    bottomLayerSelectedColor: Color.accentColor,
                    isSelected: viewStore.isSelected
                )
            )
            .animation(.none)
            .font(Font.system(.callout, design: .rounded))
        }
    }

    @ViewBuilder
    private func getView(for type: QuizAnswerViewModel) -> some View {
        switch type {

        case .text(let text):
            Text(text)

        case .image(let imageType):
            getImage(imageType, axis: .zStack)

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
                        .padding(8)
                        .layoutPriority(1)
                    Spacer()
                    getImage(imageType, axis: positioning)
                }

            case .zStack:
                ZStack(alignment: Alignment.top) {
                    getImage(imageType, axis: positioning)
                    Text(text)
                        .padding(EdgeInsets(top: 4, leading: 8, bottom: 4, trailing: 8))
                        .background(
                            Color.white
                                .cornerRadius(Constant.cornerRadius)
                                .overlay(
                                    RoundedRectangle(cornerRadius: Constant.cornerRadius)
                                        .stroke(Color.accentColor, lineWidth: 1)
                                )
                        )
                        .foregroundColor(Color.black)
                        .padding(8)
                }
            }

        }
    }

    @ViewBuilder
    func getImage(_ type: ImageType, axis: TextAndImagePositioning) -> some View {
        switch type {

        case .bundled(let name):
            Image(name)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .clipped()
                .frame(width: .infinity, height: .infinity)

        case .system(let name):
            Image(systemName: name)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .clipped()
                .frame(width: .infinity, height: .infinity)

        case .remote(let url):
            AsyncImage(
                url: url,
                scale: 1,
                content: { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: axis == .vStack ? .fit : .fill)
                        .clipped()
                        .frame(width: Constant.quizImageCardSize, height: Constant.quizImageCardSize)
                },
                placeholder: {
                    Image(systemName: "photo")
                        .resizable()
                        .aspectRatio(contentMode: ContentMode.fill)
                        .padding()
                        .foregroundColor(Color.secondary)
                }
            )
            .equatable()
            .frame(
                width: Constant.quizImageCardSize - insets.left - insets.right,
                height: Constant.quizImageCardSize - insets.top - insets.bottom
            )

        }
    }

}

struct QuizAnswerView_Previews: PreviewProvider {
    static var previews: some View {
        func getStore(vm: QuizAnswerViewModel, isSelected: Bool = false) -> Store<QuizAnswerState, QuizAnswerAction> {
            return Store(
                initialState: QuizAnswerState(option: .placeholder, viewModel: vm, isSelected: isSelected),
                reducer: quizAnswerReducer,
                environment: ()
            )
        }

        Constant.quizImageCardSize = 200

        let mosqueImageURL = URL(string: "https://images.unsplash.com/photo-1466442929976-97f336a657be?ixid=MnwxMjA3fDB8MHxzZWFyY2h8MTB8fGlzdGFuYnVsfGVufDB8fDB8fA%3D%3D&ixlib=rb-1.2.1&auto=format&fit=crop&w=900&q=60")!

        return Group {

            QuizAnswerView(store: getStore(vm: .text("Test"), isSelected: true))
                .previewDisplayName("Just text")

            QuizAnswerView(store: getStore(vm: .textAndImage(text: "Test", image: .bundled("table"), positioning: .zStack)))
                .previewDisplayName("Bundled image")

            QuizAnswerView(store: getStore(vm: .image(ImageType.remote(mosqueImageURL))))
                .previewDisplayName("Just image")

            QuizAnswerView(store: getStore(vm: .textAndImage(
                text: "Istanbul",
                image: .remote(mosqueImageURL), positioning: .vStack))
            )
            .previewDisplayName("Remote image and title vstack")

            QuizAnswerView(store: getStore(vm: .textAndImage(
                text: "Istanbul",
                image: .remote(mosqueImageURL), positioning: .zStack))
            )
            .previewDisplayName("Remote image and title overlay")

        }
        .previewLayout(.fixed(width: 200, height: 200))
    }
}
