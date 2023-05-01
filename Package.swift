// swift-tools-version: 5.5

// WARNING:
// This file is automatically generated.
// Do not edit it by hand because the contents will be replaced.

import PackageDescription
import AppleProductTypes

let package = Package(
    name: "ObjectsIn4DAritonAlexandru",
    platforms: [
        .iOS("15.2")
    ],
    products: [
        .iOSApplication(
            name: "ObjectsIn4DAritonAlexandru",
            targets: ["AppModule"],
            bundleIdentifier: "com.andu.ObjectsIn4DAritonAlexandru",
            teamIdentifier: "9HB7KJC764",
            displayVersion: "1.0",
            bundleVersion: "1",
            iconAssetName: "AppIcon",
            accentColorAssetName: "AccentColor",
            supportedDeviceFamilies: [
                .pad,
                .phone
            ],
            supportedInterfaceOrientations: [
                .portrait,
                .landscapeRight,
                .landscapeLeft,
                .portraitUpsideDown(.when(deviceFamilies: [.pad]))
            ]
        )
    ],
    targets: [
        .executableTarget(
            name: "AppModule",
            path: "."
        )
    ]
)
