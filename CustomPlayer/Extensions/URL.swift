//
//  URL.swift
//  CustomPlayer
//
//  Created by User on 22.09.2021.
//

import Foundation

extension URL {
    func withScheme(_ scheme: String) -> URL? {
        var components = URLComponents(url: self, resolvingAgainstBaseURL: false)
        components?.scheme = scheme
        return components?.url
    }
}
