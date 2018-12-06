//
//  MockReader.swift
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
@testable import PhotonProtocol

class MockReader: Reader {
    var offset: Int
    var length: Int {
        return self.buffer.count
    }
    
    private var buffer: [UInt8]
    
    init(buffer: [UInt8]) {
        self.buffer = buffer
        self.offset = 0
    }
    
    func advance(by count: Int) {
        self.offset += count
    }
    
    func readInt8() -> Int8 {
        let value = Int8(bitPattern: self.buffer[self.offset])
        
        self.offset += 1
        
        return value
    }
    
    func readUInt8() -> UInt8 {
        let value = self.buffer[self.offset]
        
        self.offset += 1
        
        return value
    }
    
    func readInt16() -> Int16 {
        return Int16(bigEndian: self.fromByteArray(buffer: self.slice(length: 2)))
    }
    
    func readUInt16() -> UInt16 {
        return UInt16(bigEndian: self.fromByteArray(buffer: self.slice(length: 2)))
    }
    
    func readInt32() -> Int32 {
        return Int32(bigEndian: self.fromByteArray(buffer: self.slice(length: 4)))
    }
    
    func readUInt32() -> UInt32 {
        return UInt32(bigEndian: self.fromByteArray(buffer: self.slice(length: 4)))
    }
    
    func readInt64() -> Int64 {
        return Int64(bigEndian: self.fromByteArray(buffer: self.slice(length: 8)))
    }
    
    func readUInt64() -> UInt64 {
        return UInt64(bigEndian: self.fromByteArray(buffer: self.slice(length: 8)))
    }
    
    func slice(length: Int) -> [UInt8] {
        let buffer = self.slice(at: self.offset, length: length)
        
        self.offset += length
        
        return buffer
    }
    
    func slice(at offset: Int, length: Int) -> [UInt8] {
        return Array(buffer[offset ..< (offset + length)])
    }
    
    func set(bytes: [UInt8], at offset: Int) {
        self.buffer.replaceSubrange(offset ..< offset + bytes.count, with: bytes)
    }
    
    private func fromByteArray<T>(buffer: [UInt8]) -> T {
        return buffer.withUnsafeBufferPointer {
            ($0.baseAddress!.withMemoryRebound(to: T.self, capacity: 1) { $0 })
        }.pointee
    }
}
