// swift-tools-version:4.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

//
//  Package.swift
//
// PhotonProtocol: A swift implementation of the Photon network protocol
// Copyright (C) 2018
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program, located in the LICENSE file.  If not, see
// <https://www.gnu.org/licenses/>.
//

import PackageDescription

let package = Package(
    name: "PhotonProtocol",
    products: [
        // Products define the executables and libraries produced by a package, and make them visible to other packages.
        .library(
            name: "PhotonProtocol",
            targets: ["PhotonProtocol"]),
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        // .package(url: /* package url */, from: "1.0.0"),
        .package(url: "https://github.com/attaswift/BigInt.git", from: "3.1.0"),
        .package(url: "https://github.com/krzyzanowskim/CryptoSwift.git", .upToNextMinor(from: "0.9.0"))
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages which this package depends on.
        .target(
            name: "PhotonProtocol",
            dependencies: [ "BigInt", "CryptoSwift" ]),
        .testTarget(
            name: "PhotonProtocolTests",
            dependencies: ["PhotonProtocol"]),
    ]
)
