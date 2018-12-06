//
//  PhotonDiffieHellmanCryptoProvider.swift
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
import CryptoSwift

class PhotonDiffieHellmanCryptoProvider: PhotonCryptoProvider {
    private var prime: BigUInt
    private var primeRoot: BigUInt
    
    private var secret: BigUInt
    private var pubKey: BigUInt
    
    private var sharedKey: BigUInt?
    private var aes: AES?
    
    var isInitialized: Bool {
        return self.sharedKey != nil
    }
    
    var publicKey: [UInt8] {
        return self.pubKey.makeBytes()
    }
    
    init() {
        // oakley768 (http://www.sandelman.ottawa.on.ca/ipsec/1996/06/msg00059.html)
        self.prime =  BigUInt("155251809230070893513091813125848" +
                              "175563133404943451431320235119490" +
                              "296623994910210725866945387659164" +
                              "244291000768028886422915080371891" +
                              "804634263272761303128298374438082" +
                              "089019628850917069131659317536746" +
                              "9551763119843371637221007210577919")!
        
        self.primeRoot = BigUInt(22)
        
        var secret = BigUInt.randomInteger(withExactWidth: 160)
        
        while (secret >= prime - 1 || secret == 0) {
            secret = BigUInt.randomInteger(withExactWidth: 160)
        }
        
        self.secret = secret
        self.pubKey = primeRoot.power(secret, modulus: prime)
    }
    
    func deriveSharedKey(peerPublicKey: [UInt8]) {
        let peerPubKey = peerPublicKey.withUnsafeBytes {
            BigUInt($0)
        }
        
        let sharedKey = peerPubKey.power(self.secret, modulus: self.prime)
        self.sharedKey = sharedKey
        
        let sharedKeyBytes = sharedKey.makeBytes()
        let digest = sharedKeyBytes.sha256()
        
        self.aes = try? AES(key: digest, blockMode: .CBC(iv: [UInt8](repeating: 0, count: 16)), padding: .pkcs7)
    }
    
    func encrypt(_ data: [UInt8]) -> [UInt8] {
        guard let aes = self.aes else { return [] } // todo: throw an exception
        
        return try! aes.encrypt(data)
    }
    
    func encrypt(_ data: [UInt8], offset: Int, count: Int) -> [UInt8] {
        guard let aes = self.aes else { return [] } // todo: throw an exception
        
        let slice = data[offset ..< offset + count]
        
        return try! aes.encrypt(slice)
    }
    
    func decrypt(_ data: [UInt8]) -> [UInt8] {
        guard let aes = self.aes else { return [] } // todo: throw an exception
        
        return try! aes.decrypt(data)
    }
    
    func decrypt(_ data: [UInt8], offset: Int, count: Int) -> [UInt8] {
        guard let aes = self.aes else { return [] } // todo: throw an exception
        
        let slice = data[offset ..< offset + count]
        
        return try! aes.decrypt(slice)
    }
}
