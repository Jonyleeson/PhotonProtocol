//
//  PhotonOperationResponse.swift
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

class PhotonOperationResponse: CustomReadable {
    let opcode: UInt8
    let responseCode: Int16
    let debugMessage: String?
    let params: [ UInt8: Any? ]
    
    init(opcode: UInt8, responseCode: Int16, debugMessage: String?, params: [ UInt8: Any? ]) {
        self.opcode = opcode
        self.responseCode = responseCode
        self.debugMessage = debugMessage
        self.params = params
    }
    
    required init(reader: Reader, length: Int = 0, crypto: PhotonCryptoProvider? = nil) {
        self.opcode = reader.readUInt8()
        self.responseCode = reader.readInt16()
        self.debugMessage = reader.readParameter() as? String
        self.params = reader.readParameterTable()
    }
}
