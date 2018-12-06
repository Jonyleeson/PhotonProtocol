//
//  Writer.swift
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

protocol Writer {
    var offset: Int { get }
    var length: Int { get }
    
    func writeInt8(value: Int8)
    func writeUInt8(value: UInt8)
    func writeInt16(value: Int16)
    func writeUInt16(value: UInt16)
    func writeInt32(value: Int32)
    func writeUInt32(value: UInt32)
    func writeInt64(value: Int64)
    func writeUInt64(value: UInt64)
    func writeBytes(value: [UInt8])
    
    func getBuffer() -> [UInt8]
}

extension Writer {
    func writeString(value: String) {
        let buffer: [UInt8] = Array(value.utf8)
        
        self.writeInt16(value: Int16(buffer.count))
        self.writeBytes(value: buffer)
    }
}

extension Writer {
    func writeParameterTable(params: [ UInt8: Any? ]) {
        self.writeInt16(value: Int16(params.count))
        
        for (key, value) in params {
            self.writeUInt8(value: key)
            self.writeParameter(parameter: value)
        }
    }
    
    func parameterType(from parameter: Any?) -> ParameterType {
        guard let parameter = parameter else { return .null }
        
        let type = Swift.type(of: parameter)
        var elementType: ParameterType = .unknown
        
        if type == Int32.self {
            elementType = ParameterType.integer
        }
        else if type == Int16.self {
            elementType = ParameterType.short
        }
        else if type == Int64.self {
            elementType = ParameterType.long
        }
        else if type == String.self {
            elementType = ParameterType.string
        }
        else if type == Double.self {
            elementType = ParameterType.double
        }
        else if type == Float.self {
            elementType = ParameterType.float
        }
        
        return elementType
    }
    
    func writeParameter(parameter: Any?) {
        if parameter == nil {
            self.writeParameter(parameter: nil, type: .null)
        }
        else if let parameter = parameter as? String {
            self.writeParameter(parameter: parameter, type: .string)
        }
        else if let parameter = parameter as? Bool {
            self.writeParameter(parameter: parameter, type: .boolean)
        }
        else if let parameter = parameter as? UInt8 {
            self.writeParameter(parameter: parameter, type: .byte)
        }
        else if let parameter = parameter as? Int16 {
            self.writeParameter(parameter: parameter, type: .short)
        }
        else if let parameter = parameter as? Int32 {
            self.writeParameter(parameter: parameter, type: .integer)
        }
        else if let parameter = parameter as? Int64 {
            self.writeParameter(parameter: parameter, type: .long)
        }
        else if let parameter = parameter as? Double {
            self.writeParameter(parameter: parameter, type: .double)
        }
        else if let parameter = parameter as? Float {
            self.writeParameter(parameter: parameter, type: .float)
        }
        else if let parameter = parameter as? [UInt8] {
            self.writeParameter(parameter: parameter, type: .byteArray)
        }
        else if let parameter = parameter as? [Any] {
            self.writeParameter(parameter: parameter, type: .array)
        }
        else if let parameter = parameter as? [ String: Any? ] {
            self.writeParameter(parameter: parameter, type: .dictionary)
        }
        else {
            print("writing unhandled parameter \(Swift.type(of: parameter))")
        }
    }
    
    func writeParameter(parameter: Any?, type: ParameterType, writeType: Bool = true) {
        if writeType {
            self.writeUInt8(value: type.rawValue)
        }
        
        switch type {
        case .null:
            break // don't write, just the type
        case .boolean:
            self.writeUInt8(value: (parameter as! Bool) ? UInt8(1) : UInt8(0))
        case .string:
            self.writeString(value: parameter as! String)
        case .byte:
            self.writeUInt8(value: parameter as! UInt8)
        case .short:
            self.writeInt16(value: parameter as! Int16)
        case .integer:
            self.writeInt32(value: parameter as! Int32)
        case .long:
            self.writeInt64(value: parameter as! Int64)
        case .double:
            self.writeUInt64(value: (parameter as! Double).bitPattern)
        case .float:
            self.writeUInt32(value: (parameter as! Float).bitPattern)
        case .byteArray:
            self.writeInt32(value: Int32((parameter as! [UInt8]).count))
            self.writeBytes(value: parameter as! [UInt8])
        case .array:
            let parameter = parameter as! [Any]
            
            self.writeInt16(value: Int16(parameter.count))
            
            if let first = parameter.first {
                let arraytype = Swift.type(of: first)
                var elementType: ParameterType = .null
                
                if arraytype == Int32.self {
                    elementType = ParameterType.integer
                }
                else if arraytype == Int16.self {
                    elementType = ParameterType.short
                    
                }
                else if arraytype == Int64.self {
                    elementType = ParameterType.long
                }
                else if arraytype == String.self {
                    elementType = ParameterType.string
                }
                else if arraytype == Double.self {
                    elementType = ParameterType.double
                }
                else if arraytype == Float.self {
                    elementType = ParameterType.float
                }
                
                self.writeUInt8(value: elementType.rawValue)
                
                for i in 0 ..< parameter.count {
                    self.writeParameter(parameter: parameter[i], type: elementType, writeType: false)
                }
            }
            else {
                self.writeUInt8(value: ParameterType.null.rawValue)
            }
        case .dictionary:
            let parameter = parameter as! [String: Any?]
            
            if parameter.count > 0 {
                let key = parameter.keys.first!
                let value = parameter[key]!
                
                let keyType = self.parameterType(from: key)
                let valueType = self.parameterType(from: value)
                
                self.writeUInt8(value: keyType.rawValue)
                self.writeUInt8(value: valueType.rawValue)
                
                self.writeInt16(value: Int16(parameter.count))
                
                for (key, value) in parameter {
                    self.writeParameter(parameter: key, type: keyType, writeType: false)
                    self.writeParameter(parameter: value, type: keyType, writeType: false)
                }
            }
            else {
                self.writeUInt8(value: ParameterType.null.rawValue)
                self.writeUInt8(value: ParameterType.null.rawValue)
            }
            
            
        default:
            print("write param \(type) unhandled")
        }
    }
}
