// swift-tools-version:5.3
import PackageDescription

let package = Package(
    name: "RoadmapProjects",
    platforms: [
        .macOS(.v10_15)
    ],
    products: [
        .executable(
            name: "MovieReservation",
            targets: ["MovieReservation"]
        )
    ],
    dependencies: [],
    targets: [
        .target(
            name: "MovieReservation",
            dependencies: [],
            path: "MovieReservation/Sources",
            exclude: [],
            sources: ["Models", "Controllers", "Utils", "main.swift"]
        )
    ]
)
