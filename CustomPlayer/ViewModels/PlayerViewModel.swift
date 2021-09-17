//
//  PlayerViewModel.swift
//  CustomPlayer
//
//  Created by User on 17.09.2021.
//

import UIKit

protocol PlayerViewModelMultiDelegate: AnyObject {
    func updateLikeButtonStatus(status: LikeStatus, likes: Int, dislikes: Int)
    func onError(error: String)
}

protocol PlayerViewModeling {
    var likeStatus: LikeStatus { get }
    var likesCount: Int { get }
    var dislikeCount: Int { get }
    var multicast: MulticastDelegate<PlayerViewModelMultiDelegate> { get }

    func updateUI()
    func didTapLikeButton()
    func didTapDislikeButton()
    func didTapAddToFavorites()
    func format(duration: TimeInterval, currentTime: TimeInterval) -> (timePlayed: String, timeLeft: String)
}

class PlayerViewModel: PlayerViewModeling {
    var likesCount: Int { podcast?.likeCount ?? 0 }
    var dislikeCount: Int { podcast?.dislikeCount ?? 0 }
    var likeStatus: LikeStatus { podcast?.reactionType ?? .undefined }
    let multicast = MulticastDelegate<PlayerViewModelMultiDelegate>()

    private var podcastRepo: PodcastRepositoryProtocol
    private var audioPlayer = AudioPlayer.shared
    private lazy var podcast = audioPlayer.podcast
//    private var accountRepo = UserAccountRepository.shared

    init(podcastRepo: PodcastRepositoryProtocol) {
        self.podcastRepo = podcastRepo
        audioPlayer.delegate = self
    }

    func didTapLikeButton() {
        if likeStatus == .liked {
            removeReaction(reaction: likeStatus)
            podcast?.reactionType = .undefined
            podcast?.likeCount -= 1
        } else if likeStatus == .disliked {
            podcast?.reactionType = .liked
            podcast?.likeCount += 1
            podcast?.dislikeCount -= 1
            removeAndSetNewReaction(oldReaction: likeStatus, newReaction: .liked)
        } else if likeStatus == .undefined {
            podcast?.reactionType = .liked
            podcast?.likeCount += 1
            setReaction(reaction: likeStatus)
        }
    }

    func didTapDislikeButton() {
        if likeStatus == .disliked {
            podcast?.reactionType = .undefined
            podcast?.dislikeCount -= 1
            removeReaction(reaction: likeStatus)
        } else if likeStatus == .undefined {
            podcast?.reactionType = .disliked
            podcast?.dislikeCount += 1
            setReaction(reaction: likeStatus)
        } else if likeStatus == .liked {
            podcast?.reactionType = .disliked
            podcast?.dislikeCount += 1
            podcast?.likeCount -= 1
            removeAndSetNewReaction(oldReaction: likeStatus, newReaction: .disliked)
        }
    }

    func updateUI() {
        multicast.invokeDelegates { delegate in
            delegate.updateLikeButtonStatus(status: likeStatus, likes: likesCount, dislikes: dislikeCount)
        }
    }

    private func onError(error: String) {
        multicast.invokeDelegates({ delegate in
            delegate.onError(error: error)
        })
    }

    private func setReaction(reaction: LikeStatus) {
        guard let podcast = podcast?.podcastID else { return }
//        self.podcastRepo.setReaction(with: ReactionType.init(id: podcast, reaction: reaction.rawValue)) { [weak self] result in
//            switch result {
//            case .success(_):
//                self?.updateUI()
//            case .failure(let error):
//                self?.onError(error: error.localizedDescription)
//            }
//        }
    }

    private func removeReaction(reaction: LikeStatus) {
        guard let podcast = podcast?.podcastID else { return }
//        self.podcastRepo.removeReaction(with: ReactionType.init(id: podcast, reaction: reaction.rawValue)) { [weak self] result in
//            switch result {
//            case .success(_):
//                self?.updateUI()
//            case .failure(let error):
//                self?.onError(error: error.localizedDescription)
//            }
//        }
    }

    private func removeAndSetNewReaction(oldReaction: LikeStatus, newReaction: LikeStatus) {
        guard let podcast = podcast?.podcastID else { return }
//        podcastRepo.removeReaction(with: ReactionType.init(id: podcast, reaction: oldReaction.rawValue)) { [weak self] result in
//            switch result {
//            case .success(_):
//                self?.setReaction(reaction: newReaction)
//            case .failure(let error):
//                self?.onError(error: error.localizedDescription)
//            }
//        }
    }

    func didTapAddToFavorites() { }

    func format(duration: TimeInterval, currentTime: TimeInterval) -> (timePlayed: String, timeLeft: String) {
        let time = TimeFormatter.format(duration: duration, currentTime: currentTime)

        return (time.timePlayed, time.timeLeft)
    }
}

extension PlayerViewModel: AudioPlayerViewModelDelegate {
    func updateUIInfo() {
        updateUI()
    }
}
