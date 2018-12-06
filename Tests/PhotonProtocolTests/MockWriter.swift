//
//  MockWriter.swift
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

class MockWriter: Writer {
    var offset: Int
    var length: Int {
        return self.buffer.count
    }
    
    private var buffer: [UInt8]
    
    init() {
        self.buffer = []
        self.offset = 0
    }
    
    func writeInt8(value: Int8) {
        self.buffer.append(UInt8(bitPattern: value))
        self.offset += 1
    }
    
    func writeUInt8(value: UInt8) {
        self.buffer.append(value)
        self.offset += 1
    }
    
    func writeInt16(value: Int16) {
        self.writeBytes(value: self.toByteArray(value: Int16(bigEndian: value)))
    }
    
    func writeUInt16(value: UInt16) {
        self.writeBytes(value: self.toByteArray(value: UInt16(bigEndian: value)))
    }
    
    func writeInt32(value: Int32) {
        self.writeBytes(value: self.toByteArray(value: Int32(bigEndian: value)))
    }
    
    func writeUInt32(value: UInt32) {
        self.writeBytes(value: self.toByteArray(value: UInt32(bigEndian: value)))
    }
    
    func writeInt64(value: Int64) {
        self.writeBytes(value: self.toByteArray(value: Int64(bigEndian: value)))
    }
    
    func writeUInt64(value: UInt64) {
        self.writeBytes(value: self.toByteArray(value: UInt64(bigEndian: value)))
    }
    
    func writeBytes(value: [UInt8]) {
        self.buffer.append(contentsOf: value)
        self.offset += value.count
    }
    
    func getBuffer() -> [UInt8] {
        return self.buffer
    }
    
    private func toByteArray<T>(value: T) -> [UInt8] {
        var value = value
        
        return withUnsafePointer(to: &value) {
            Array(UnsafeBufferPointer(start: $0.withMemoryRebound(to: UInt8.self, capacity: 1){$0}, count: MemoryLayout<T>.stride))
        }
    }
}
