//
//  PhotonProtocolTests.swift
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

import XCTest
@testable import PhotonProtocol

final class PhotonProtocolTests: XCTestCase {
    func testExample() {
        let buffer: [UInt8] = [ 0xFF, 0xFF, 0, 1, 0, 0, 0, 0x19, 0x66, 0x15, 0xA6, 0xCE, 2, 0xFF, 1, 4, 0, 0, 0, 0x2C, 0, 0, 0, 1, 0, 0, 4, 0xB0, 0, 0, 0x80, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0x13, 0x88, 0, 0, 0, 2, 0, 0, 0, 2 ]
        
        let reader = MockReader(buffer: buffer)
        let header = PhotonHeader(reader: reader)

        XCTAssertEqual(header.peerId, -1, "Testing header.peerId")
        XCTAssertEqual(header.flags, 0, "Testing header.flags")
        XCTAssertEqual(header.commandCount, 1, "Testing header.commandCount")
        XCTAssertEqual(header.timestamp, 25, "Testing header.timestamp")
        XCTAssertEqual(header.challenge, 1712694990, "Testing header.challenge")
        XCTAssertEqual(header.isCrcEnabled, false, "Testing header.isCrcEnabled")
        XCTAssertEqual(header.isCrcValid, true, "Testing header.isCrcValid")
        XCTAssertEqual(header.isEncrypted, false, "Testing header.isEncrypted")
        XCTAssertEqual(header.crc, nil, "Testing header.crc")
        
        let command = PhotonCommand(reader: reader)
        
        XCTAssertEqual(command.header?.type, PhotonCommandHeader.CommandType.connect, "Testing command.header.type")
        XCTAssertEqual(command.header?.channelId, 0xFF, "Testing command.header.channelId")
        XCTAssertEqual(command.header?.flags, 1, "Testing command.header.flags")
        XCTAssertEqual(command.header?.reserved, 4, "Testing command.header.reserved")
        XCTAssertEqual(command.header?.length, 44, "Testing command.header.length")
        XCTAssertEqual(command.header?.reliableSequenceNumber, 1, "Testing command.header.reliableSequenceNumber")
        XCTAssertEqual(command.header?.isInSequence, false, "Testing command.header.isInSequence")
        XCTAssertEqual(command.header?.isReliable, true, "Testing command.header.isReliable")
    }

    static var allTests = [
        ("testExample", testExample),
    ]
}
