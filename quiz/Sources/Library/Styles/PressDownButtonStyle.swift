//
//
//  quiz
//  
//  Created on 07.03.2021
//  
//  

import SwiftUI

struct PressDownButtonStyle: ButtonStyle {

    var insets: UIEdgeInsets = .init(top: 4, left: 4, bottom: 4, right: 4)
    var backgroundColor = Color(.systemBackground)
    var bottomLayerColor: Color?

    func makeBody(configuration: Self.Configuration) -> some View {
        configuration.label
            .foregroundColor(Color.accentColor)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(backgroundColor)
            .cornerRadius(Constant.cornerRadius)
            .padding(.leading, insets.left)
            .padding(.trailing, insets.right)
            .padding(.top, insets.top)
            .padding(.bottom, configuration.isPressed ? insets.top : insets.bottom * 2)
            .background(bottomLayerColor ?? backgroundColor.darker(by: 15))
            .cornerRadius(Constant.cornerRadius)
            .offset(y: configuration.isPressed ? insets.bottom / 2 : 0)
    }
}

struct PressDownButtonStyle_Previews: PreviewProvider {

    static var previews: some View {
        Button(action: {}, label: {
            VStack {
                Text("text")
                Spacer()
                Image(systemName: "flag")
            }
            .padding()
        })
        .buttonStyle(PressDownButtonStyle(backgroundColor: Color.red, bottomLayerColor: nil))
        .previewLayout(.fixed(width: 200, height: 200))
        .padding()
        .accentColor(Color(#colorLiteral(red: 0.4666666687, green: 0.7647058964, blue: 0.2666666806, alpha: 1)))
    }

}
