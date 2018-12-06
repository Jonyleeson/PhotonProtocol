//
//  PhotonCryptoProvider.swift
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

import Foundation

protocol PhotonCryptoProvider {
    var isInitialized: Bool { get }
    var publicKey: [UInt8] { get }
    
    func deriveSharedKey(peerPublicKey: [UInt8])
    
    func encrypt(_ data: [UInt8]) -> [UInt8]
    func encrypt(_ data: [UInt8], offset: Int, count: Int) -> [UInt8]
    func decrypt(_ data: [UInt8]) -> [UInt8]
    func decrypt(_ data: [UInt8], offset: Int, count: Int) -> [UInt8]
}
