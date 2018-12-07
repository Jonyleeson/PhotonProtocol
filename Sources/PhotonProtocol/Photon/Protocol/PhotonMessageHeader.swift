//
//  PhotonMessageHeader.swift
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

public struct PhotonMessageHeader {
    public enum MessageType: UInt8 {
        case initialize                   = 0 // send client version(s) & info
        case initializeResponse           = 1
        case operationRequest             = 2
        case operationResponse            = 3
        case event                        = 4
        case internalOperationRequest     = 6 // used for key exchange (send client pubkey)
        case internalOperationResponse    = 7 // recv server pubkey
        case message                      = 8 // haven't seen this yet or code to send it
        case rawMessage                   = 9 // see above
    }
    
    public let signature: UInt8 // always equal to 243 afaik
    public let type: MessageType
    public let isEncrypted: Bool
    
    static var length: Int {
        return 2
    }
    
    public init(type: MessageType, isEncrypted: Bool = false) {
        self.signature = 243
        self.type = type
        self.isEncrypted = isEncrypted
    }
}

extension PhotonMessageHeader: CustomReadable {
    public init(reader: Reader, length: Int = 0, crypto: PhotonCryptoProvider? = nil) {
        self.signature = reader.readUInt8()
        
        let type = reader.readUInt8()
        
        self.type = MessageType(rawValue: type & UInt8(Int8.max))!
        self.isEncrypted = (type & 0x80) > 0
    }
}

extension PhotonMessageHeader: CustomWritable {
    public func write(to writer: Writer) {
        writer.writeUInt8(value: self.signature)
        
        if self.isEncrypted {
            writer.writeUInt8(value: self.type.rawValue | 0x80)
        }
        else {
            writer.writeUInt8(value: self.type.rawValue)
        }
    }
}
