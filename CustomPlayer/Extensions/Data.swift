//
//  Data.swift
//  CustomPlayer
//
//  Created by User on 17.09.2021.
//

import Foundation

extension Data {
    func decodeTo<T: Decodable>(type: T.Type,
                                strategy: JSONDecoder.KeyDecodingStrategy = .convertFromSnakeCase) throws -> T {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = strategy
        return try decoder.decode(type, from: self)
    }
}
