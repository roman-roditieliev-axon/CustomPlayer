//
//  URLRequestError.swift
//  RXMVVMC
//
//  Created by Vitalii Shkliar on 06.11.2019.
//  Copyright © 2019 Vitalii Shkliar. All rights reserved.
//

import Foundation

enum URLRequestError: Error {
    case badRequest
    case internalServerError
    case outdated
    case unknown
}
