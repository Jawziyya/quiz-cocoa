//
//
//  quiz
//  
//  Created on 06.03.2021
//  
//  

import UIKit
import ComposableArchitecture
import Entities
import DatabaseClient
import GameKit

// Messages sent using the Notification Center to trigger
// Game Center's Popup screen
public enum PopupControllerMessage: String {
    case PresentAuthentication = "PresentAuthenticationViewController"
    case GameCenter = "GameCenterViewController"
}

extension PopupControllerMessage {
  public func postNotification() {
     NotificationCenter.default.post(
        name: Notification.Name(rawValue: self.rawValue),
        object: self)
  }

  public func addHandlerForNotification(_ observer: Any, handler: Selector) {
     NotificationCenter.default .
          addObserver(observer, selector: handler, name:
            NSNotification.Name(rawValue: self.rawValue), object: nil)
  }

}

open class GameKitHelper: NSObject, ObservableObject,  GKGameCenterControllerDelegate {
    public var authenticationViewController: UIViewController?
    public var lastError: Error?

    public static let shared = GameKitHelper()

    private override init() {
        super.init()
    }

    @Published public var enabled :Bool = false

    public var  gameCenterEnabled: Bool {
        return GKLocalPlayer.local.isAuthenticated }

    public func authenticateLocalPlayer () {
        let localPlayer = GKLocalPlayer.local
        localPlayer.authenticateHandler = { viewController, error in

            self.lastError = error as NSError?
            self.enabled = GKLocalPlayer.local.isAuthenticated
            if viewController != nil {
                self.authenticationViewController = viewController
                PopupControllerMessage
                    .PresentAuthentication
                    .postNotification()
            }
        }
    }

    public func reportProgress() {
        let id = "io.jawziyya.quiz.achievement_basic_1"
        GKAchievement.loadAchievements { list, error in
            guard let targetAchievement = list?.first(where: { $0.identifier == id }) else {
                return
            }
            targetAchievement.percentComplete = 100
            GKAchievement.report([targetAchievement], withCompletionHandler: nil)
        }
    }

    public var gameCenterViewController: GKGameCenterViewController? {
        guard gameCenterEnabled else {
            print("Local player is not authenticated")
            return nil }
        let gameCenterViewController = GKGameCenterViewController(state: .achievements)
        gameCenterViewController.gameCenterDelegate = self
        return gameCenterViewController
    }

    open func gameCenterViewControllerDidFinish(_ gameCenterViewController: GKGameCenterViewController) {
        gameCenterViewController.dismiss(animated: true, completion: nil)
    }

}

struct AppDelegateState: Equatable { }

public enum AppDelegateAction: Equatable {
  case didFinishLaunching
  case didRegisterForRemoteNotifications(Result<Data, NSError>)
}

struct AppDelegateEnvironment {
    var databaseClient: DatabaseClient
}

extension HomeViewEnv {

    static func live() throws -> Self {
        let fileManager = FileManager.default
        let folderURL = try fileManager
            .url(for: .applicationSupportDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
            .appendingPathComponent("database", isDirectory: true)
        try fileManager.createDirectory(at: folderURL, withIntermediateDirectories: true)
        let dbURL = folderURL.appendingPathComponent("db.sqlite")
        let databaseClient = DatabaseClient.live(url: dbURL)

        return HomeViewEnv(
            mainQueue: DispatchQueue.main.eraseToAnyScheduler(),
            databaseClient: databaseClient
        )
    }

}

let appDelegateReducer = Reducer<
    AppDelegateState, AppDelegateAction, AppDelegateEnvironment
  > { state, action, environment in
    return .none
}

class AppDelegate: UIResponder, UIApplicationDelegate {

    let store = Store(
        initialState: HomeViewState(),
        reducer: homeViewReducer,
        environment: try! HomeViewEnv.live()
    )
    
    lazy var viewStore = ViewStore(
        self.store.scope(
            state: \.appDelegateState,
            action: HomeViewAction.appDelegate
        )
    )

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        viewStore.send(.didFinishLaunching)

        PopupControllerMessage.PresentAuthentication
            .addHandlerForNotification(
                self,
                handler: #selector(AppDelegate
                    .showAuthenticationViewController)
            )

        PopupControllerMessage.GameCenter
            .addHandlerForNotification(
                self,
                handler: #selector(AppDelegate
                    .showGameCenterViewController)
            )

//        GKAccessPoint.shared.location = .topTrailing
//        GKAccessPoint.shared.showHighlights = false
//        GKAccessPoint.shared.isActive = true

        return true
    }

    // pop's up the leaderboard and achievement screen
    @objc func showGameCenterViewController() {
        if let gameCenterViewController =
            GameKitHelper.shared.gameCenterViewController {
            UIApplication.shared.windows.first?.rootViewController?.present(
                gameCenterViewController,
                animated: true,
                completion: nil)
        }

    }
    // pop's up the authentication screen
    @objc func showAuthenticationViewController() {
        if let authenticationViewController =
            GameKitHelper.shared.authenticationViewController {
            UIApplication.shared.windows.first?.rootViewController?.present(
                authenticationViewController, animated: true)
            {
                GameKitHelper.shared.enabled  =
                GameKitHelper.shared.gameCenterEnabled
            }
        }
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
    }

}
