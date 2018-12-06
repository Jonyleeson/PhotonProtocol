//
//  PhotonCommandHeader.swift
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

struct PhotonCommandHeader {
    enum CommandType: UInt8 {
        case none                 = 0
        case acknowledge          = 1
        case connect              = 2
        case verifyConnect        = 3
        case disconnect           = 4
        case ping                 = 5
        case sendReliable         = 6
        case sendUnreliable       = 7
        case sendReliableFragment = 8
        case serverTime           = 12
    }
    
    static var length: Int {
        return 12
    }
    
    let type: CommandType
    let channelId: UInt8
    let flags: UInt8
    let reserved: UInt8
    let length: Int32
    let reliableSequenceNumber: Int32
    let isInSequence: Bool
    let isReliable: Bool
    
    init(type: CommandType, channelId: UInt8, length: Int32, reliableSequenceNumber: Int32, isInSequence: Bool, isReliable: Bool) {
        self.type = type
        self.channelId = channelId
        self.isInSequence = isInSequence
        self.isReliable = isReliable
        
        var flags: UInt8 = 0
        
        if isInSequence {
            flags |= 2
        }
        
        if isReliable {
            flags |= 1
        }
        
        self.flags = flags
        self.reserved = 4 // i think this is what the server sends
        self.length = length
        self.reliableSequenceNumber = reliableSequenceNumber
    }
}

extension PhotonCommandHeader: CustomReadable {
    init(reader: Reader, length: Int = 0, crypto: PhotonCryptoProvider? = nil) {
        let rawType = reader.readUInt8()
        if let type = CommandType(rawValue: rawType) {
            self.type = type
        }
        else {
            self.type = .none
        }
        
        self.channelId = reader.readUInt8()
        self.flags = reader.readUInt8()
        self.reserved = reader.readUInt8()
        self.length = reader.readInt32()
        self.reliableSequenceNumber = reader.readInt32()
        
        self.isInSequence = flags & 2 > 0
        self.isReliable = flags & 1 > 0
    }
}

extension PhotonCommandHeader: CustomWritable {
    func write(to writer: Writer) {
        writer.writeUInt8(value: self.type.rawValue)
        writer.writeUInt8(value: self.channelId)
        writer.writeUInt8(value: self.flags)
        writer.writeUInt8(value: self.reserved)
        writer.writeInt32(value: self.length)
        writer.writeInt32(value: self.reliableSequenceNumber)
    }
}
