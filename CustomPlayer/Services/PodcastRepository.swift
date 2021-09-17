//
//  PodcastRepository.swift
//  CustomPlayer
//
//  Created by User on 15.09.2021.
//

import Foundation

protocol PodcastRepositoryProtocol {
//    func getPodcasts(with model: PodcastsRequest, by id: String, completion: @escaping (Result<PaginatedResponse<Podcast>, Error>) -> Void)
    func getPodcastAudio(with url: URL, completion: @escaping (Result<(localUrl: URL?, response: URLResponse?), Error>) -> Void)
//    func getCategories(completion: @escaping (Result<CategoriesResponse, Error>) -> Void)
//    func setReaction(with model: ReactionType, completion: @escaping (Result<StatusCode, Error>) -> Void)
//    func removeReaction(with model: ReactionType, completion: @escaping (Result<StatusCode, Error>) -> Void)
    func getSinglePodcast(by id: String, completion: @escaping (Result<Podcast, Error>) -> Void)
//    func saveLastPodcast(podcast: LastPlayedPodcast, completion: (Result<LastPlayedPodcast, Error>) -> Void)
//    func getLastPodcast(completion: @escaping (Result<LastPlayedPodcast, Error>) -> Void)
    var lastPodcastExists: Bool { get }
}

class PodcastRepository: PodcastRepositoryProtocol {
    private let service = APIRouter<PodcastEndPoint>()
    private let responseHandler = AuthRemoteAPIResponseHandler()
    static let shared = PodcastRepository()

    var accessToken: String? { "UserAccountRepository.shared.accessToken" }
    var lastPodcastExists: Bool { false }

//    func getPodcasts(with model: PodcastsRequest, by id: String, completion: @escaping (Result<PaginatedResponse<Podcast>, Error>) -> Void) {
//        guard let accessToken = accessToken else {
//            completion(.failure(AccountRepositoryError.noAccessToken))
//            return
//        }
//        service.requestWithPagination(.getPodcasts(model: model, id: id, token: accessToken), model: Podcast.self, responseHandler: responseHandler) { result in
//            DispatchQueue.main.async {
//                switch result {
//                case .success(let result):
//                    completion(.success(result))
//                case .failure(let error):
//                    completion(.failure(error))
//                }
//            }
//        }
//    }

    func getPodcastAudio(with url: URL, completion: @escaping (Result<(localUrl: URL?, response: URLResponse?), Error>) -> Void) {
        service.requestDownload(.getPodcastAudio(url: url), responseHandler: responseHandler) { (result) in
            DispatchQueue.main.async {
                switch result {
                case .success(let result):
                    completion(.success(result))
                case .failure(let error):
                    completion(.failure(error))
                }
            }
        }
    }

//    func getCategories(completion: @escaping (Result<CategoriesResponse, Error>) -> Void) {
//        guard let accessToken = accessToken else {
//            completion(.failure(AccountRepositoryError.noAccessToken))
//            return
//        }
//        service.request(.getCategories(token: accessToken), model: CategoriesResponse.self, responseHandler: responseHandler) { result in
//            DispatchQueue.main.async {
//                switch result {
//                case .success(let result):
//                    completion(.success(result))
//                case .failure(let error):
//                    completion(.failure(error))
//                }
//            }
//        }
//    }
//
//    func setReaction(with model: ReactionType, completion: @escaping (Result<StatusCode, Error>) -> Void) {
//        guard let accessToken = accessToken else {
//            completion(.failure(AccountRepositoryError.noAccessToken))
//            return
//        }
//        service.request(.setReaction(model: model, token: accessToken), responseHandler: responseHandler) { result in
//            DispatchQueue.main.async {
//                switch result {
//                case .success(let statusCode):
//                    completion(.success(statusCode))
//                case .failure(let error):
//                    completion(.failure(error))
//                }
//            }
//        }
//    }
//
//    func removeReaction(with model: ReactionType, completion: @escaping (Result<StatusCode, Error>) -> Void) {
//        guard let accessToken = accessToken else {
//            completion(.failure(AccountRepositoryError.noAccessToken))
//            return
//        }
//        service.request(.removeReaction(model: model, token: accessToken), responseHandler: responseHandler) { result in
//            DispatchQueue.main.async {
//                switch result {
//                case .success(let statusCode):
//                    completion(.success(statusCode))
//                case .failure(let error):
//                    completion(.failure(error))
//                }
//            }
//        }
//    }

    func getSinglePodcast(by id: String, completion: @escaping (Result<Podcast, Error>) -> Void) {
        guard let accessToken = accessToken else {
            completion(.failure(AccountRepositoryError.noAccessToken))
            return
        }
        service.request(.getSinglePodcast(id: id, token: accessToken), model: Podcast.self, responseHandler: responseHandler) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let model):
                    completion(.success(model))
                case .failure(let error):
                    completion(.failure(error))
                }
            }

        }
    }

//    func saveLastPodcast(podcast: LastPlayedPodcast, completion: (Result<LastPlayedPodcast, Error>) -> Void) {
//        UserDefaultsDataStore.shared.saveLastPlayedPodcast(podcast: podcast) {
//            completion(.success(podcast))
//        }
//    }
//
//    func getLastPodcast(completion: @escaping (Result<LastPlayedPodcast, Error>) -> Void) {
//        UserDefaultsDataStore.shared.retrieveLastPodcast(completion: { data in
//            switch data {
//            case .success(let podcast):
//                completion(.success(podcast))
//            case .failure(let error):
//                completion(.failure(error))
//            }
//        })
//    }
}
