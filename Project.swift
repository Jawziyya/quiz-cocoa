import Foundation
import ProjectDescription

// MARK: - Constants
let kCompilationConditions = "SWIFT_ACTIVE_COMPILATION_CONDITIONS"
let kDevelopmentTeam = "DEVELOPMENT_TEAM"
let kDeadCodeStripping = "DEAD_CODE_STRIPPING"

let companyName = "Al Jawziyya"
let teamId = "486STKKP6Y"
let projectName = "quiz"
let baseDomain = "io.jawziyya"

let baseSettingsDictionary = SettingsDictionary()
    .bitcodeEnabled(true)
    .merging([kDevelopmentTeam: SettingValue(stringLiteral: teamId)])

    // A workaround due https://bugs.swift.org/browse/SR-11564
    // Should be removed when the bug is resolved.
    .merging([kDeadCodeStripping: SettingValue(booleanLiteral: false)])

let settings = Settings(
    base: baseSettingsDictionary
)

let deploymentTarget = DeploymentTarget.iOS(targetVersion: "14.0", devices: .iphone)
let testsDeploymentTarget = DeploymentTarget.iOS(targetVersion: "14.0", devices: .ipad)

// MARK: - Extensions
extension SettingsDictionary {
    var addingObjcLinkerFlag: Self {
        return self.merging(["OTHER_LDFLAGS": "$(inherited) -ObjC"])
    }

    func addingDevelopmentAssets(path: String) -> Self {
        return self.merging(
            ["DEVELOPMENT_ASSET_PATHS": .init(arrayLiteral: path)]
        )
    }
}

enum QuizTarget: String, CaseIterable {
    case quizApp = "quiz"
    case quizAppTests = "quizTests"

    var target: Target {
        switch self {

        case .quizApp:
            return Target(
                name: rawValue,
                platform: .iOS,
                product: .app,
                bundleId: baseDomain + ".quiz",
                deploymentTarget: deploymentTarget,
                infoPlist: .file(path: "\(rawValue)/Info.plist"),
                sources: "quiz/Sources/**",
                resources: "quiz/Resources/**",
                dependencies: [
                    .package(product: QuizPackage.entities.name),
                    .package(product: QuizPackage.databaseClient.name),
                    .package(product: "Lottie"),
                    .sdk(name: "SwiftUI.framework", status: SDKStatus.optional),
                ],
                settings: Settings(
                    base: baseSettingsDictionary
                        .addingDevelopmentAssets(path: "quiz/Resources/PreviewAssets.xcassets")
                )
            )

        case .quizAppTests:
            return Target(
                name: rawValue,
                platform: Platform.iOS,
                product: Product.unitTests,
                productName: rawValue,
                bundleId: baseDomain + ".quiz.tests",
                deploymentTarget: deploymentTarget,
                infoPlist: "quizTests/Info.plist",
                sources: [
                    "quizTests/Sources/**"
                ],
                resources: [
                    "quizTests/Resources/**"
                ],
                dependencies: [
                    .target(name: QuizTarget.quizApp.rawValue),
                ],
                settings: Settings(
                    base: baseSettingsDictionary
                        .manualCodeSigning()
                        .codeSignIdentity("")
                ),
                launchArguments: []
            )

        }
    }
}

enum QuizPackage: String {
    case entities = "Entities"
    case databaseClient = "DatabaseClient"

    var name: String { rawValue }

    var path: Path {
        return "Packages/\(name)"
    }
}

let packages: [Package] = [
    .remote(url: "https://github.com/pointfreeco/swift-composable-architecture", requirement: .upToNextMajor(from: "0.16.0")),
    .remote(url: "https://github.com/airbnb/lottie-ios", requirement: .upToNextMajor(from: "3.2.1")),
    .local(path: QuizPackage.entities.path),
    .local(path: QuizPackage.databaseClient.path)
]

let project = Project(
    name: projectName,
    organizationName: companyName,
    packages: packages,
    settings: settings,
    targets: QuizTarget.allCases.map(\.target),
    schemes: [
        Scheme(
            name: QuizTarget.quizApp.rawValue,
            shared: true,
            buildAction: BuildAction(targets: ["quiz"]),
            testAction: TestAction.testPlans("quiz/Resources/quiz.xctestplan"),
            runAction: RunAction(executable: "quiz")
        )
    ],
    additionalFiles: []
)
