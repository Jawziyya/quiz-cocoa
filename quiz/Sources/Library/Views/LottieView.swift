//
//
//  quiz
//  
//  Created on 09.03.2021
//  
//  

import SwiftUI
import Lottie

struct LottieView: UIViewRepresentable {

    let animationView = AnimationView()
    let name: String
    var loopMode: LottieLoopMode = .playOnce
    var contentMode: UIView.ContentMode = .scaleAspectFit
    var speed: CGFloat = 1

    func makeUIView(context: UIViewRepresentableContext<LottieView>) -> UIView {
        let animation = Animation.named(name)
        animationView.animation = animation
        animationView.contentMode = contentMode
        animationView.loopMode = loopMode
        animationView.animationSpeed = speed
        animationView.play()
        animationView.translatesAutoresizingMaskIntoConstraints = false
        animationView.isUserInteractionEnabled = false

        let view = UIView()
        view.addSubview(animationView)
        [animationView.heightAnchor.constraint(equalTo: view.heightAnchor),
         animationView.widthAnchor.constraint(equalTo: view.widthAnchor)].forEach {
            $0.isActive = true
        }
        return view
    }

    func updateUIView(_ uiView: UIView, context: UIViewRepresentableContext<LottieView>) { }

}
