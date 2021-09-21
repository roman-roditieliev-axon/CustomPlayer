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
    func setupNowPlayingArt()
}

class PlayerCommandCenter: PlayerCommandCenterType {
    private var player: AVPlayer
    private var playerItem: AVPlayerItem
    private var audioPlayer = AudioPlayer.shared
    private var nowPlayingInfo = [String: Any]()
    private let commandCenter = MPRemoteCommandCenter.shared()
    private let playingInfoCenter = MPNowPlayingInfoCenter.default()
    private let intervalForForwardBackwardCommands: NSNumber = 15
    private let defaultPlaybackRate = 1

    init(player: AVPlayer, playerItem: AVPlayerItem) {
        self.player = player
        self.playerItem = playerItem
        setupForwardBackwardCommands()
        setupPlayPauseCommands()
        setupCommandCenterPlaybackValueChangeCommand()
        setupNowPlaying()
        setupNowPlayingArt()
    }

    // MARK: - Remote controls set up
    // Updated: optimised commands setup
    func setupForwardBackwardCommands() {
        let arrayForwardBackwardCommand = [commandCenter.skipForwardCommand, commandCenter.skipBackwardCommand]
        arrayForwardBackwardCommand.forEach { (command) in
            command.isEnabled = true
            command.preferredIntervals = [intervalForForwardBackwardCommands]
            command.addTarget { [weak self] _ in
                self?.audioPlayer.seekTime(direction: command == self?.commandCenter.skipForwardCommand ? .forward : .backwards)
                return .success
            }
        }
    }

    func setupPlayPauseCommands() {
        let arrayPlayPauseCommand = [commandCenter.playCommand, commandCenter.pauseCommand]
        arrayPlayPauseCommand.forEach { (command) in
            command.isEnabled = true
            command.addTarget { [weak self] _ in
                guard let self = self else { return .commandFailed }
                if command == self.commandCenter.playCommand {
                    self.audioPlayer.startPlaying()
                } else {
                    self.audioPlayer.stopPlaying()
                }
                self.nowPlayingInfo[MPNowPlayingInfoPropertyElapsedPlaybackTime] = CMTimeGetSeconds((self.player.currentTime()))
                self.nowPlayingInfo[MPNowPlayingInfoPropertyPlaybackRate] = command == self.commandCenter.playCommand ? self.audioPlayer.playBackSpeed : 0
                self.playingInfoCenter.nowPlayingInfo = self.nowPlayingInfo
                return .success
            }
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
        nowPlayingInfo[MPMediaItemPropertyTitle] = audioPlayer.podcast?.title
        nowPlayingInfo[MPNowPlayingInfoPropertyElapsedPlaybackTime] = CMTimeGetSeconds(currentTime)
        nowPlayingInfo[MPMediaItemPropertyPlaybackDuration] = CMTimeGetSeconds(duration)
        nowPlayingInfo[MPNowPlayingInfoPropertyPlaybackRate] = defaultPlaybackRate
        nowPlayingInfo[MPMediaItemPropertyTitle] = audioPlayer.podcast?.title
        nowPlayingInfo[MPMediaItemPropertyAlbumTitle] = audioPlayer.podcast?.podcastDescription
        playingInfoCenter.nowPlayingInfo = nowPlayingInfo
    }

    /// Set up now playing art image for album/podcast
    func setupNowPlayingArt() {
        guard let imageURL = audioPlayer.podcast?.imageURL else { return }
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
