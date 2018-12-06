//
//  Reader.swift
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

protocol Reader {
    var offset: Int { get }
    var length: Int { get }
    
    func advance(by count: Int)
    
    func readInt8() -> Int8
    func readUInt8() -> UInt8
    func readInt16() -> Int16
    func readUInt16() -> UInt16
    func readInt32() -> Int32
    func readUInt32() -> UInt32
    func readInt64() -> Int64
    func readUInt64() -> UInt64
    func slice(length: Int) -> [UInt8]
    func slice(at offset: Int, length: Int) -> [UInt8]
    func set(bytes: [UInt8], at offset: Int)
}

extension Reader {
    func readString() -> String {
        let length = self.readInt16()
        let bytes = self.slice(length: Int(length))
        
        return String(bytes: bytes, encoding: .utf8) ?? ""
    }
}

extension Reader {
    func readParameterTable() -> [ UInt8: Any? ] {
        var params: [ UInt8: Any? ] = [:]
        
        let count = self.readInt16()
        
        for _ in 0 ..< Int(count) {
            let index = self.readUInt8()
            params[index] = self.readParameter()
        }
        
        return params
    }
    
    func readParameter() -> Any? {
        let rawType = self.readUInt8()
        
        if let type = ParameterType(rawValue: rawType) {
            let param = self.readParameter(type: type)
            
            if param == nil {
                print("warning parsing \(type), returned nil")
            }
            
            return param
        }
        else {
            print("UNABLE TO PARSE PARAMETER TYPE \(rawType)")
            return nil
        }
    }
    
    /*
     
     paramTable:
     short paramCount
     [ paramKey: UInt8, param: (paramType: UInt8, paramValue: [Byte]?) ]
     
     if paramType = dict
     paramType = dictheader: keytype: uint8, valueType: uint8 IF valuetype == dict, valuetype = dictheader
     paramcount: int16
     [ paramkey: paramValue(keyType), paramValue: paramValue(valueType) ]
     
     if paramType = event
     eventCode = uint8
     params: paramTable
     
     if paramType = hastable
     count: int16
     [ key: param, value: param ]
     
     if paramType = operationResponse
     opcode: uint8
     returnCode: int16
     debugmessage: param
     params: paramtable
     
     if paramType = operationRequest
     opcode: uint8
     params: paramtable
     
     if paramType = string (pascal-esque string)
     length: int16
     string: [uint8] utf8 encoded
     
     if paramType = byteArray
     length: int32
     data: [uint8]
     
     if paramType = intArray
     length: short
     data: [int32]
     
     if paramType = stringArray
     length: short
     data: [string]
     
     if paramType = objectArray
     length: short
     data: [param]
     
     if paramType = array
     length: short
     paramType: uint8
     data: [paramType]
     
     if paramType = custom
     customType: uint8
     length: short
     data: [uint8]
     
     all other types are standard
     */
    
    func readParameter(type: ParameterType) -> Any? {
        switch type {
        case .unknown:
            fallthrough
        case .null:
            return nil
        case .dictionary:
            return nil // todo
            //return readDictionary(data: data, offset: &offset)
        case .stringArray:
            return nil // todo
            //return readStringArray(data: data, offset: &offset)
        case .byte:
            return self.readUInt8()
        case .custom: // TODO: impl
            return nil
        case .double:
            return Double(bitPattern: self.readUInt64())
        case .eventData: // TODO: impl
            return nil
        case .float:
            return Float(bitPattern: self.readUInt32())
        case .hashtable:
            return nil // todo
            //return readHashtable(data: data, offset: &offset)
        case .integer:
            return self.readInt32()
        case .short:
            return self.readInt16()
        case .long:
            return self.readInt64()
        case .integerArray:
            return nil // todo
            //return readIntArray(data: data, offset: &offset)
        case .boolean:
            let byte = self.readUInt8()
            return !(byte == 0)
        case .operationResponse: // TODO: impl
            return nil
        case .operationRequest: // TODO: impl
            return nil
        case .string:
            return self.readString()
        case .byteArray:
            let length = self.readInt32()
            return self.slice(length: Int(length))
        case .array:
            let length = self.readInt16()
            let rawType = self.readUInt8()
            
            if let type = ParameterType(rawValue: rawType) {
                var result: [Any?] = []
                
                for _ in 0 ..< length {
                    result.append(self.readParameter(type: type))
                }
                
                return result
            }
            else {
                print("error parsing array unknown type \(rawType)")
            }
            
            return nil
        case .objectArray:
            return nil
            //return readObjectArray(data: data, offset: &offset)
        }
    }
}


