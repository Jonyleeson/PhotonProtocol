//
//  PhotonHeader.swift
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

public struct PhotonHeader {
    static var length: Int {
        return 12
    }
    
    public let peerId: Int16
    public let flags: UInt8
    public let commandCount: UInt8
    public let timestamp: UInt32
    public let challenge: Int32
    public let isCrcEnabled: Bool
    public let isCrcValid: Bool
    public let isEncrypted: Bool
    public let crc: UInt32?
    
    public init(peerId: Int16, commandCount: UInt8, timestamp: UInt32, challenge: Int32, isEncrypted: Bool, crc: UInt32? = nil) {
        self.peerId = peerId
        
        if isEncrypted {
            self.flags = UInt8(1)
            self.isCrcEnabled = false
            self.isEncrypted = true
            self.crc = nil
        }
        else if let crc = crc {
            self.flags = UInt8(0xCC)
            self.isEncrypted = false
            self.isCrcEnabled = true
            self.crc = crc
        }
        else {
            self.flags = UInt8(0)
            self.isEncrypted = false
            self.isCrcEnabled = false
            self.crc = nil
        }
        
        self.commandCount = commandCount
        self.timestamp = timestamp
        self.challenge = challenge
        self.isCrcValid = true
    }
}

extension PhotonHeader: CustomStringConvertible {
    public var description: String {
        return "PeerId: \(self.peerId), IsCrcEnabled: \(self.isCrcEnabled), IsEncrypted: \(self.isEncrypted), CommandCount: \(self.commandCount), Timestamp: \(self.timestamp), Challenge: \(self.challenge)"
    }
}

extension PhotonHeader: CustomReadable {
    public init(reader: Reader, length: Int = 0, crypto: PhotonCryptoProvider? = nil) {
        let startOffset = reader.offset
        
        self.peerId = reader.readInt16()
        self.flags = reader.readUInt8()
        self.commandCount = reader.readUInt8()
        self.timestamp = reader.readUInt32()
        self.challenge = reader.readInt32()
        
        self.isCrcEnabled = flags == 0xCC
        self.isEncrypted = flags == 1
        
        if isEncrypted {
            self.crc = nil
            self.isCrcValid = true
        }
        else if isCrcEnabled {
            self.crc = reader.readUInt32()
            
            reader.set(bytes: [ 0, 0, 0, 0 ], at: reader.offset - 4)
            
            let buffer = reader.slice(at: startOffset, length: length)
            let calculatedCrc = PhotonHeader.calculateCrc(buffer: buffer)
            
            self.isCrcValid = self.crc == calculatedCrc
        }
        else {
            self.crc = nil
            self.isCrcValid = true
        }
    }
    
    private static func calculateCrc(buffer: [UInt8]) -> UInt32 {
        var crc = UInt32.max
        let constant = UInt32(3988292384)
        
        for i in 0 ..< buffer.count {
            let c = buffer[i]
            crc ^= UInt32(c)
            
            for _ in 0 ..< 8 {
                if crc & 1 > 0 {
                    crc = crc >> 1 ^ constant;
                }
                else {
                    crc >>= 1
                }
            }
        }
        
        return crc
    }
}

extension PhotonHeader: CustomWritable {
    public func write(to writer: Writer) {
        writer.writeInt16(value: self.peerId)
        writer.writeUInt8(value: self.flags)
        writer.writeUInt8(value: self.commandCount)
        writer.writeUInt32(value: self.timestamp)
        writer.writeInt32(value: self.challenge)
        
        if self.isCrcEnabled, let crc = self.crc {
            writer.writeUInt32(value: crc)
        }
    }
}
