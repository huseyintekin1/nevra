// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "Nevra",
    defaultLocalization: "en",
    platforms: [.macOS(.v14)],
    products: [
        .library(name: "NevraCore", targets: ["NevraCore"]),
        .executable(name: "Nevra", targets: ["NevraApp"]),
        .executable(name: "nevra-cli", targets: ["NevraCLI"])
    ],
    dependencies: [
        .package(url: "https://github.com/sparkle-project/Sparkle", exact: "2.10.0")
    ],
    targets: [
        .target(name: "NevraCore", resources: [.copy("Resources")]),
        // The frozen XPC wire protocol stays at its sealed source path. It is compiled
        // into the renamed module without changing its Objective-C identity.
        .target(name: "NevraUpdates", dependencies: [.product(name: "Sparkle", package: "Sparkle")], path: "Sources", exclude: ["NevraApp", "NevraCore", "NevraCLI", "UpdateCredentialBroker"], sources: ["NevraUpdates", "TangerineUpdates/UpdateCredentialBrokerProtocol.swift"]),
        .executableTarget(name: "NevraApp", dependencies: ["NevraCore", "NevraUpdates"], exclude: ["Clipboard/Resources"], linkerSettings: [.unsafeFlags(["-Xlinker", "-rpath", "-Xlinker", "@executable_path/../Frameworks"])]),
        .executableTarget(name: "NevraCLI", dependencies: ["NevraCore"]),
        .testTarget(name: "NevraCoreTests", dependencies: ["NevraCore"], resources: [.copy("Fixtures")]),
        .testTarget(name: "NevraUpdatesTests", dependencies: ["NevraUpdates"])
    ],
    swiftLanguageModes: [.v5]
)
