// Package.swift
// swift-tools-version:5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "packagings",
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "packagings",
            targets: ["packagings"]),
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        .package(url: "https://github.com/pvieito/PythonKit.git", from: "0.0.0"),
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "packagings",
            dependencies: ["PythonKit"]),
        .testTarget(
            name: "packagingsTests",
            dependencies: ["packagings"]),
    ]
)
