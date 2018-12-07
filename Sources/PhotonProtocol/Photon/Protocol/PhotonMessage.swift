//
//  PhotonMessage.swift
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

public struct PhotonMessage {
    public enum Message {
        case initialize(peerInformation: PhotonPeerInformation)
        case initializeResponse
        case operationRequest(operationRequest: PhotonOperationRequest)
        case operationResponse(operationResponse: PhotonOperationResponse)
        case event(event: PhotonEvent)
        case internalOperationRequest(operationRequest: PhotonOperationRequest)
        case internalOperationResponse(operationResponse: PhotonOperationResponse)
        case message
        case rawMessage
    }
    
    public let header: PhotonMessageHeader
    public let message: Message
    
    public init(header: PhotonMessageHeader, message: Message) {
        self.header = header
        self.message = message
    }
}

extension PhotonMessage: CustomReadable {
    public init(reader: Reader, length: Int, crypto: PhotonCryptoProvider? = nil) {
        self.header = PhotonMessageHeader(reader: reader)
        
        var length = length
        
        if self.header.isEncrypted, let crypto = crypto {
            let encrypted = reader.slice(at: reader.offset, length: length - PhotonCommandHeader.length - PhotonMessageHeader.length)
            let decrypted = crypto.decrypt(encrypted)
            
            reader.set(bytes: decrypted, at: reader.offset)
            
            let diff = encrypted.count - decrypted.count
            length -= diff
        }
        
        switch self.header.type {
        case .initialize:
            let peerInformation = PhotonPeerInformation(reader: reader)
            
            self.message = .initialize(peerInformation: peerInformation)
        case .initializeResponse:
            reader.advance(by: 1) // unused byte
            
            self.message = .initializeResponse
        case .operationRequest:
            let operationRequest = PhotonOperationRequest(reader: reader)
            
            self.message = .operationRequest(operationRequest: operationRequest)
        case .operationResponse:
            let operationResponse = PhotonOperationResponse(reader: reader)
            
            self.message = .operationResponse(operationResponse: operationResponse)
        case .event:
            let event = PhotonEvent(reader: reader)
            
            self.message = .event(event: event)
        case .internalOperationRequest:
            let operationRequest = PhotonOperationRequest(reader: reader)
            
            self.message = .internalOperationRequest(operationRequest: operationRequest)
        case .internalOperationResponse:
            let operationResponse = PhotonOperationResponse(reader: reader)
            
            self.message = .internalOperationResponse(operationResponse: operationResponse)
        case .message:
            self.message = .message
        case .rawMessage:
            self.message = .rawMessage
        }
    }
}

extension PhotonMessage: CustomWritable {
    public func write(to writer: Writer) {
        self.header.write(to: writer)
        
        switch self.message {
        case .initializeResponse:
            writer.writeUInt8(value: UInt8(0))
        case .internalOperationResponse(let operationResponse):
            writer.writeUInt8(value: operationResponse.opcode)
            writer.writeInt16(value: operationResponse.responseCode)
            writer.writeParameter(parameter: operationResponse.debugMessage)
            writer.writeParameterTable(params: operationResponse.params)
        case .operationResponse(let operationResponse):
            writer.writeUInt8(value: operationResponse.opcode)
            writer.writeInt16(value: operationResponse.responseCode)
            writer.writeParameter(parameter: operationResponse.debugMessage)
            writer.writeParameterTable(params: operationResponse.params)
        case .event(let event):
            writer.writeUInt8(value: event.eventCode)
            writer.writeParameterTable(params: event.params)
        default:
            print("write unhandled \(self.message)")
        }
    }
}
