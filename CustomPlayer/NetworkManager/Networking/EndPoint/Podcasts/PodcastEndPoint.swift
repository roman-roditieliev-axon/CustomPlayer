//
//  Podcasts.swift
//  AxonPodcasts
//
//  Created by Evhen Petrovskyi on 28.06.2021.
//

import Foundation

enum PodcastEndPoint: EndPointType {
    /// This method will return array of podcasts
    case getPodcasts(model: PodcastsRequest, id: String, token: String)
    /// This method will return podcast audio
    case getPodcastAudio(url: URL)
    /// THis method will return podcast categories
    case getCategories(token: String)
    /// This method will post reaction type for podcast
    case setReaction(model: ReactionType, token: String)
    /// This method will remove selected reaction for podcast
    case removeReaction(model: ReactionType, token: String)
    /// This method will return single podcast
    case getSinglePodcast(id: String, token: String)
}

extension PodcastEndPoint {
    
    var environmentBaseURL: String {
        switch self {
        case .getPodcasts, .getCategories, .setReaction, .removeReaction, .getSinglePodcast:
            let url = EndPointConstants.baseURL
            return url
        case .getPodcastAudio(let url):
            return String(describing: url)
        }
    }
    
    var baseURL: URL {
        guard let url = URL(string: environmentBaseURL) else {
            fatalError("failed to configure base URL")
        }
        return url
    }
    
    var path: String {
        switch self {
        case .getPodcasts:
            return "/podcasts"
        case .getPodcastAudio:
            return ""
        case .getCategories:
            return "/categories"
        case .setReaction(let model, _), .removeReaction(let model, _):
            return "/podcasts/\(model.id)/reaction"
        case .getSinglePodcast(let id, _):
            return "podcasts/\(id)"
        }
    }
    
    var httpMethod: HTTPMethod {
        switch self {
        case .getPodcasts, .getPodcastAudio, .getCategories, .getSinglePodcast:
            return .get
        case .setReaction:
            return .post
        case .removeReaction:
            return .delete
        }
    }
    
    var task: HTTPTask {
        switch self {
        case .getPodcasts(let model, let id, let token):
            let parameters = ["category": id,
                              "skip": model.skip,
                              "limit": model.limit, ] as [String: Any]
            let headers = ["Authorization": "Bearer \(token)"]
            return .requestParametersAndHeaders(bodyParameters: nil, urlParameters: parameters, additionHeaders: headers)
            
        case .getPodcastAudio:
            return .request
            
        case .getCategories(let token):
            let headers = ["Authorization": "Bearer \(token)"]
            return .requestParametersAndHeaders(bodyParameters: nil, urlParameters: nil, additionHeaders: headers)
            
        case .setReaction(let model, let token):
            let headers = ["Authorization": "Bearer \(token)"]
            let urlParams = ["type": model.reaction]
            return .requestParametersAndHeaders(bodyParameters: nil, urlParameters: urlParams, additionHeaders: headers)
            
        case .removeReaction(let model, let token):
            let headers = ["Authorization": "Bearer \(token)"]
            let urlParams = ["type": model.reaction]
            return .requestParametersAndHeaders(bodyParameters: nil, urlParameters: urlParams, additionHeaders: headers)
            
        case .getSinglePodcast(_, let token):
            let headers = ["Authorization": "Bearer \(token)"]
            return .requestParametersAndHeaders(bodyParameters: nil, urlParameters: nil, additionHeaders: headers)
        }
    }
    
    var headers: HTTPHeaders? { nil }
}
