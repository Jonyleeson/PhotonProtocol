//
//  PhotonCommand.swift
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

public struct PhotonCommand {
    public enum Command {
        case none
        case acknowledge(receivedReliableSequenceNumber: Int32, receivedSentTime: Int32)
        case connect(mtu: Int16, channelCount: UInt8)
        case verifyConnect(peerId: Int16)
        case disconnect
        case ping
        case sendReliable(message: PhotonMessage)
        case sendUnreliable(unreliableSequenceNumber: UInt32, message: PhotonMessage)
        case sendReliableFragment(fragment: PhotonFragment, data: [UInt8])
        case serverTime
    }
    
    public let header: PhotonCommandHeader?
    public let command: Command
    
    public init(command: Command) {
        self.header = nil
        self.command = command
    }
}

extension PhotonCommand: CustomReadable {
    public init(reader: Reader, length: Int = 0, crypto: PhotonCryptoProvider? = nil) {
        let startOffset = reader.offset
        
        self.header = PhotonCommandHeader(reader: reader)
        
        // todo: check length, if unexpected length throw exception or something
        
        switch self.header!.type {
        case .none:
            self.command = .none
        case .connect:
            reader.advance(by: 2)
            let mtu = reader.readInt16()
            reader.advance(by: 4) // so it's not that these are useless I guess,
                                  // but they're static in the client. looks like the same
                                  // data as verifyConnect
            let channelCount = reader.readUInt8()
            reader.advance(by: 23)
            
            self.command = .connect(mtu: mtu, channelCount: channelCount)
        case .acknowledge:
            let receivedReliableSequenceNumber = reader.readInt32()
            let receivedSentTime = reader.readInt32()
            
            self.command = .acknowledge(receivedReliableSequenceNumber: receivedReliableSequenceNumber, receivedSentTime: receivedSentTime)
        case .verifyConnect:
            let peerId = reader.readInt16()
            
            reader.advance(by: 30) // looks like same data as connect
            
            self.command = .verifyConnect(peerId: peerId)
        case .disconnect:
            self.command = .disconnect
        case .ping:
            self.command = .ping
        case .sendReliable:
            let message = PhotonMessage(reader: reader, length: Int(self.header!.length), crypto: crypto)
            
            self.command = .sendReliable(message: message)
        case .sendUnreliable:
            let unreliableSequenceNumber = reader.readUInt32()
            let message = PhotonMessage(reader: reader, length: Int(self.header!.length), crypto: crypto)
            
            self.command = .sendUnreliable(unreliableSequenceNumber: unreliableSequenceNumber, message: message)
        case .sendReliableFragment:
            let fragment = PhotonFragment(reader: reader, length: Int(self.header!.length), crypto: crypto)
            let data = reader.slice(length: Int(self.header!.length) - (reader.offset - startOffset))
            
            self.command = .sendReliableFragment(fragment: fragment, data: data)
        case .serverTime:
            self.command = .serverTime
        }
    }
}

extension PhotonCommand: CustomWritable {
    public func write(to writer: Writer) {
        switch self.command {
        case .acknowledge(let receivedReliableSequenceNumber, let receivedSentTime):
            writer.writeInt32(value: receivedReliableSequenceNumber)
            writer.writeInt32(value: receivedSentTime)
        case .verifyConnect(let peerId):
            writer.writeInt16(value: peerId)
            writer.writeBytes(value: [UInt8](repeating: 0, count: 30))
        case .sendReliable(let message):
            message.write(to: writer)
        default:
            print("writing not implemented \(self)")
        }
    }
}
