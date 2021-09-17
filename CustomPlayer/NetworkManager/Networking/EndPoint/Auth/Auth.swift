//
//  Auth.swift
//  RXMVVMC
//
//  Created by Vitalii Shkliar on 06.11.2019.
//  Copyright © 2019 Vitalii Shkliar. All rights reserved.
//

import Foundation

enum Auth: EndPointType {
    case signout(token: String)
    /// This method will get chapters
    case getPositionsAndChapters
    /// This method will get saved User Settings
    case getUserSettings(token: String)
    /// This method will refresh token
    case refreshToken
    /// This method will return User Profile that was last saved on server
    case getUserProfile(token: String)
}

extension Auth {
    
    var environmentBaseURL: String {
        //You can do env check and tweak url here
        let url = EndPointConstants.baseURL
        return url
    }
    
    var baseURL: URL {
        guard let url = URL(string: environmentBaseURL) else {
            fatalError("failed to configure base URL")
        }
        return url
    }
    
    var path: String {
        switch self {
        case .signout:
            return "/tokens/me"
        case .getPositionsAndChapters:
            return "/dictionaries"
        case .getUserSettings:
            return "/users/me/settings"
        case .refreshToken:
            return "/tokens/refresh"
        case .getUserProfile:
            return "/users/me"
        }
    }
    
    var httpMethod: HTTPMethod {
        switch self {
        case .refreshToken:
            return .post
        case .signout:
            return .delete
        case .getPositionsAndChapters, .getUserSettings, .getUserProfile:
            return .get
        }
    }
    
    var task: HTTPTask {
        switch self {
        case .signout(let token):
            let header = ["Authorization": "Bearer \(token)"]
            return .requestParametersAndHeaders(bodyParameters: nil, urlParameters: nil, additionHeaders: header)
        case .getPositionsAndChapters:
            return .requestParameters(bodyParameters: nil, urlParameters: nil)
        case .getUserSettings(let token):
            let headers = ["Authorization": "Bearer \(token)"]
            return .requestParametersAndHeaders(bodyParameters: nil, urlParameters: nil, additionHeaders: headers)
            
        case .refreshToken:
            let params = ["clientSecret": EndPointConstants.clientSecret]
            return .requestParameters(bodyParameters: params, urlParameters: nil)
            
        case .getUserProfile(let token):
            let headers = ["Authorization": "Bearer \(token)"]
            return .requestParametersAndHeaders(bodyParameters: nil, urlParameters: nil, additionHeaders: headers)
        }
    }
    
    var headers: HTTPHeaders? { nil }
}
