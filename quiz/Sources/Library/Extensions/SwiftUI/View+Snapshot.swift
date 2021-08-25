//
//
//  quiz
//  
//  Created on 18.08.2021
//  Copyright © 2021 Al Jawziyya. All rights reserved.
//  

import UIKit
import SwiftUI

extension View {

    /// Create snapshot of the view.
    func snapshot() -> UIImage {
        let controller = UIHostingController(rootView: self)
        let view = controller.view

        let targetSize = controller.view.intrinsicContentSize
        view?.bounds = CGRect(origin: .zero, size: targetSize)
        view?.backgroundColor = .clear

        let renderer = UIGraphicsImageRenderer(size: targetSize)

        return renderer.image { _ in
            view?.drawHierarchy(in: controller.view.bounds, afterScreenUpdates: true)
        }
    }

}
