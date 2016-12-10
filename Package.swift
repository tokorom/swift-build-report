import PackageDescription

let package = Package(
    name: "swift-build-report",
    dependencies: [
        .Package(url: "https://github.com/kylef/Commander.git", majorVersion: 0),
    ]
)
