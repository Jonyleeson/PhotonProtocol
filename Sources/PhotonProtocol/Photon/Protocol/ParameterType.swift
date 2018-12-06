//
//  ParameterType.swift
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

enum ParameterType: UInt8 {
    case unknown = 0
    case null = 42 // 0x2A
    case dictionary = 68 // 0x44
    case stringArray = 97 // 0x61
    case byte = 98 // 0x62
    case custom = 99 // 0x63
    case double = 100 // 0x64
    case eventData = 101 // 0x65
    case float = 102 // 0x66
    case hashtable = 104 // 0x68
    case integer = 105 // 0x69
    case short = 107 // 0x6B
    case long = 108 // 0x6C
    case integerArray = 110 // 0x6E
    case boolean = 111 // 0x6F
    case operationResponse = 112 // 0x70
    case operationRequest = 113 // 0x71
    case string = 115 // 0x73
    case byteArray = 120 // 0x78
    case array = 121 // 0x79
    case objectArray = 122 // 0x7A
}
