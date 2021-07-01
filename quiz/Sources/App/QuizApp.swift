//
//
//  quiz
//  
//  Created on 22.03.2021
//  Copyright © 2021 Al Jawziyya. All rights reserved.
//  

import SwiftUI

@main
struct QuizApp: App {
  @UIApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate
  @Environment(\.scenePhase) private var scenePhase

  var body: some Scene {
    WindowGroup {
        AppView(store: self.appDelegate.store)
            .environmentObject(GameKitHelper.shared)
            .onAppear {
                GameKitHelper.shared.authenticateLocalPlayer()
            }
    }
  }
}
