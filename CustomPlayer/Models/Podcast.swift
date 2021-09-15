//
//  Podcast.swift
//  CustomPlayer
//
//  Created by User on 15.09.2021.
//

import UIKit

// MARK: Decoded response reactionType for internal use via Enum
enum LikeStatus: String, Codable {
    case liked = "LIKE"
    case disliked = "DISLIKE"
    case undefined

    init(from decoder: Decoder) throws {
        let reactionType = try decoder.singleValueContainer().decode(String.self)
        switch reactionType {
        case "DISLIKE": self = .disliked
        case "LIKE": self = .liked
        default: self = .undefined
        }
    }
}

// MARK: - Podcast
class Podcast: Codable {
    let title, podcastDescription: String
    let duration: TimeInterval
    var likeCount, dislikeCount: Int
    let imageURL: URL?
    var audioURL: URL?
    let podcastID, categoryID: String
    let createdAt, status: String
    let publishedAt: String?
    var reactionType: LikeStatus

    enum CodingKeys: String, CodingKey {
        case title
        case podcastDescription = "description"
        case duration
        case imageURL = "imageUrl"
        case audioURL = "audioUrl"
        case podcastID = "podcastId"
        case categoryID = "categoryId"
        case createdAt, publishedAt, likeCount, dislikeCount
        case reactionType
        case status
    }

    required init(from decoder: Decoder) throws {
        let value = try decoder.container(keyedBy: CodingKeys.self)

        title = try value.decodeIfPresent(String.self, forKey: .title) ?? "No title"
        podcastDescription = try value.decodeIfPresent(String.self, forKey: .podcastDescription) ?? "No description"
        duration = try value.decodeIfPresent(TimeInterval.self, forKey: .duration) ?? 0
        audioURL = try value.decodeIfPresent(URL.self, forKey: .audioURL)
        podcastID = try value.decodeIfPresent(String.self, forKey: .podcastID) ?? ""
        categoryID = try value.decodeIfPresent(String.self, forKey: .categoryID) ?? ""
        createdAt = try value.decodeIfPresent(String.self, forKey: .createdAt) ?? ""
        publishedAt = try value.decode(String.self, forKey: .publishedAt)
        likeCount = try value.decodeIfPresent(Int.self, forKey: .likeCount) ?? 0
        dislikeCount = try value.decodeIfPresent(Int.self, forKey: .dislikeCount) ?? 0
        status = try value.decodeIfPresent(String.self, forKey: .status) ?? ""
        reactionType = try value.decodeIfPresent(LikeStatus.self, forKey: .reactionType) ?? .undefined
        imageURL = try value.decode(URL.self, forKey: .imageURL)
    }
}

typealias PodcastsResponse = [Podcast]
