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

    /// Show the classic Apple share sheet on iPhone and iPad.
    func showShareSheet(with activityItems: [Any]) {
        guard let source = UIApplication.shared.windows.last?.rootViewController else {
            return
        }

        let activityVC = UIActivityViewController(
            activityItems: activityItems,
            applicationActivities: nil)

        if let popoverController = activityVC.popoverPresentationController {
            popoverController.sourceView = source.view
            popoverController.sourceRect = CGRect(
                x: source.view.bounds.midX,
                y: source.view.bounds.midY,
                width: .zero,
                height: .zero
            )
            popoverController.permittedArrowDirections = []
        }
        source.present(activityVC, animated: true)
    }

}
