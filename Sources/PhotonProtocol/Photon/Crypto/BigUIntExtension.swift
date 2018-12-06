//
//  BigUIntExtension.swift
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
import BigInt

extension BigUInt {
    public func makeBytes() -> [UInt8] {
        var bytes: [UInt8] = []
        for w in self.words {
            var wordBytes: [UInt8] = []
            var word = w
            
            for _ in 0 ..< 8 {
                wordBytes.insert(UInt8(word & 0xFF), at: 0)
                word = word >> 8
            }
            
            for i in (0 ..< wordBytes.count).reversed() {
                bytes.insert(wordBytes[i], at: 0)
            }
        }
        return bytes
    }
}
