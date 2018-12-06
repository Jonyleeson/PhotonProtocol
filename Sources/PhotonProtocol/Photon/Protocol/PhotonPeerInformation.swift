//
//  PhotonPeerInformation.swift
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

struct PhotonPeerInformation {
    let versionBytes: [UInt8]
    let clientSdkIdShifted: UInt8
    let clientVersion: [UInt8]
    let isIpv6: Bool
    let appId: String
}

extension PhotonPeerInformation: CustomReadable {
    init(reader: Reader, length: Int = 0, crypto: PhotonCryptoProvider? = nil) {
        let version = reader.readUInt16()
        self.versionBytes = [ UInt8(version >> 8), UInt8(version & 0xFF) ]
        self.clientSdkIdShifted = reader.readUInt8()
        
        let clientVersion = reader.readUInt32()
        
        self.isIpv6 = (clientVersion & (0x80 << 24)) > 0
        self.clientVersion = [ UInt8(((clientVersion >> 24) & 0x70) >> 4), UInt8((clientVersion >> 24) & 0x0F), UInt8((clientVersion >> 16) & 0xFF) , UInt8((clientVersion >> 8) & 0xFF) ]
        
        let appIdBytes = reader.slice(length: 32)
        
        self.appId = appIdBytes.withUnsafeBytes({
            String(cString: $0.baseAddress!.assumingMemoryBound(to: UInt8.self))
        })
    }
}
