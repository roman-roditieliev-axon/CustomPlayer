//
//  PlayerCommandCenter.swift
//  CustomPlayer
//
//  Created by User on 15.09.2021.
//

import MediaPlayer
import Kingfisher

protocol PlayerCommandCenterType {
    func setupNowPlaying()
    func setupNowPlyingArt()
}

class PlayerCommandCenter: PlayerCommandCenterType {
    private var player: AVPlayer
    private var playerItem: AVPlayerItem
    private var audioPlayer = AudioPlayer.shared
    private var nowPlayingInfo = [String: Any]()
    private let commandCenter = MPRemoteCommandCenter.shared()
    private let playingInfoCenter = MPNowPlayingInfoCenter.default()

    init(player: AVPlayer, playerItem: AVPlayerItem) {
        self.player = player
        self.playerItem = playerItem
        setupCommandCenterSkipForwardCommand()
        setupCommandCenterSkipBackwardsCommand()
        setupCommandCenterPlayCommand()
        setupCommandCenterPauseCommand()
        setupCommandCenterPlaybackValueChangeCommand()
        setupNowPlaying()
        setupNowPlyingArt()
    }

    // MARK: - Remote controls set up
    func setupCommandCenterSkipForwardCommand() {
        commandCenter.skipForwardCommand.isEnabled = true
        commandCenter.skipForwardCommand.preferredIntervals = [15]
        commandCenter.skipForwardCommand.addTarget { [weak self] _ in
            self?.audioPlayer.seekTime(direction: .forward)
            return .success
        }
    }

    func setupCommandCenterSkipBackwardsCommand() {
        commandCenter.skipBackwardCommand.isEnabled = true
        commandCenter.skipBackwardCommand.preferredIntervals = [15]
        commandCenter.skipBackwardCommand.addTarget { [weak self] _ in
            self?.audioPlayer.seekTime(direction: .backwards)
            return .success
        }
    }

    func setupCommandCenterPlayCommand() {
        commandCenter.playCommand.isEnabled = true
        commandCenter.playCommand.addTarget { [weak self] _ in
            guard let self = self else { return .commandFailed }
            self.audioPlayer.startPlaying()
            self.nowPlayingInfo[MPNowPlayingInfoPropertyElapsedPlaybackTime] = CMTimeGetSeconds((self.player.currentTime()))
            self.nowPlayingInfo[MPNowPlayingInfoPropertyPlaybackRate] = self.audioPlayer.playBackSpeed
            self.playingInfoCenter.nowPlayingInfo = self.nowPlayingInfo
            return .success
        }
    }

    func setupCommandCenterPauseCommand() {
        commandCenter.pauseCommand.isEnabled = true
        commandCenter.pauseCommand.addTarget { [weak self] _ in
            guard let self = self else { return .commandFailed }
            self.audioPlayer.stopPlaying()
            self.nowPlayingInfo[MPNowPlayingInfoPropertyElapsedPlaybackTime] = CMTimeGetSeconds((self.player.currentTime()))
            self.nowPlayingInfo[MPNowPlayingInfoPropertyPlaybackRate] = 0
            self.playingInfoCenter.nowPlayingInfo = self.nowPlayingInfo
            return .success
        }
    }

    func setupCommandCenterPlaybackValueChangeCommand() {
        commandCenter.changePlaybackPositionCommand.addTarget { [weak self] event in
            guard let self = self,
                  let seconds = (event as? MPChangePlaybackPositionCommandEvent)?.positionTime else { return .commandFailed }
            let time = CMTime(value: CMTimeValue(seconds), timescale: CMTimeScale(1.0))
            self.player.seek(to: time)
            return .success
        }
    }

    /// Set up now playing control info
    func setupNowPlaying() {
        guard let currentTime = player.currentItem?.currentTime(),
              let duration = player.currentItem?.duration else { return }
        // Define Now Playing Info
        nowPlayingInfo[MPMediaItemPropertyTitle] = audioPlayer.podcast?.title
        nowPlayingInfo[MPNowPlayingInfoPropertyElapsedPlaybackTime] = CMTimeGetSeconds(currentTime)
        nowPlayingInfo[MPMediaItemPropertyPlaybackDuration] = CMTimeGetSeconds(duration)
        nowPlayingInfo[MPNowPlayingInfoPropertyPlaybackRate] = 1
        nowPlayingInfo[MPMediaItemPropertyTitle] = audioPlayer.podcast?.title
        nowPlayingInfo[MPMediaItemPropertyAlbumTitle] = audioPlayer.podcast?.podcastDescription
        playingInfoCenter.nowPlayingInfo = nowPlayingInfo
    }

    /// Set up now playing art image for album/podcast
    func setupNowPlyingArt() {
        guard let imageURL = audioPlayer.podcast?.imageURL else { return }
        //Get cached image
        KingfisherManager.shared.retrieveImage(with: imageURL) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let result):
                self.nowPlayingInfo[MPMediaItemPropertyArtwork] =
                    MPMediaItemArtwork(boundsSize: result.image.size) { _ in
                        return result.image
                    }
                self.playingInfoCenter.nowPlayingInfo = self.nowPlayingInfo
            case .failure(_):
                guard let image = PlayerImageConstants.defaultImage else { return }
                self.nowPlayingInfo[MPMediaItemPropertyArtwork] =
                    MPMediaItemArtwork(boundsSize: image.size) { _ in
                        return image
                    }
                self.playingInfoCenter.nowPlayingInfo = self.nowPlayingInfo
            }
        }
    }
}
