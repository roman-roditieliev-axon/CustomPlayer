//
//  AudioPlayer.swift
//  CustomPlayer
//
//  Created by User on 15.09.2021.
//

import AVFoundation
import UIKit

enum SeekDirection {
    case forward
    case backwards
}

protocol MiniPlayerPresenterDelegate: AnyObject {
    func presentMiniPlayer()
}

protocol AudioPlayerViewModelDelegate: AnyObject {
    func updateUIInfo()
}

protocol AudioPlayerDelegate: AnyObject {
    func playbackInfoChanged(duration: Float, currentTime: Float, playbackSpeed: Double)
    func setPlayButtonState()
    func didGetData()
    func resetView()
}

 class AudioPlayer {
    var onError: (String) -> Void = { _ in }
    var isLoading = { }
    var didLoad = { }
    var player: AVPlayer!
    var playerItem: CachingPlayerItem!
    var podcast: Podcast?
    var wasPlaying: Bool = false
    let multicast = MulticastDelegate<AudioPlayerDelegate>()
    weak var delegate: AudioPlayerViewModelDelegate?
    weak var miniPlayerDelegate: MiniPlayerPresenterDelegate?
    private let seekDuration: Double = 15
    private var displayLink: CADisplayLink?
    private var commandCenter: PlayerCommandCenterType?
    private let storageRepository = FileRepository.shared

    var duration: Float = 0.0

    var currentTime: Float = 0.0 {
        didSet {
            self.multicast.invokeDelegates({ delegate in
                delegate.playbackInfoChanged(duration: duration, currentTime: currentTime, playbackSpeed: Double(playBackSpeed))
            })
            commandCenter?.setupNowPlaying()
        }
    }

    var isPlaying: Bool = false {
        didSet {
            multicast.invokeDelegates({ delegate in delegate.setPlayButtonState() })
            commandCenter?.setupNowPlaying()
        }
    }

    var playBackSpeed: Float = 1 {
        didSet {
            self.multicast.invokeDelegates({ delegate in
                delegate.playbackInfoChanged(duration: duration, currentTime: currentTime, playbackSpeed: Double(playBackSpeed))
            })
        }
    }

    private var isOnline: Bool = true {
        didSet { stallPlayerHandling() }
    }

    func playPodcast(with model: Podcast, currentTime: Float? = nil, completion: (() -> Void)? = nil) {
        playerState()
        self.podcast = model
        guard let podcast = podcast?.podcastID else { return }
        storageRepository.retrieveFile(name: podcast) { result in
            switch result {
            case .success(let data):
                self.playFromLocalUrl(url: data.localURL)
                if let currentTime = currentTime {
                    self.setCurrentPlaybackTime(value: currentTime)
                    self.stopPlaying()
                    self.commandCenter?.setupNowPlaying()
                }
            case .failure:
                self.playFromRemoteAndCache(podcast: model)
            }
        }
    }

    private func playFromLocalUrl(url: URL?) {
        guard let url = url else { return }
        let asset = AVURLAsset(url: url)
        let playerItem = AVPlayerItem(asset: asset)
        self.player = AVPlayer(playerItem: playerItem)
        let duration = asset.duration
        let inSeconds = CMTimeGetSeconds(duration)
        self.duration = Float(inSeconds)
        NotificationCenter.default.addObserver(self, selector: #selector(didFinishPlaying(_ :)), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: playerItem)
        miniPlayerDelegate?.presentMiniPlayer()
        didLoad()
        delegate?.updateUIInfo()
        commandCenter = PlayerCommandCenter.init(player: player, playerItem: playerItem)
        multicast.invokeDelegates({ delegate in delegate.didGetData() })
        startPlaying()
    }

    private func playFromRemoteAndCache(podcast: Podcast) {
        self.playerItem = CachingPlayerItem(url: (podcast.audioURL)!, customFileExtension: "mp3")
        self.podcast?.audioURL = podcast.audioURL
        self.playerItem.delegate = self
        self.player = AVPlayer(playerItem: self.playerItem)
        self.player.automaticallyWaitsToMinimizeStalling = false
        NotificationCenter.default.addObserver(self, selector: #selector(self.didFinishPlaying(_ :)), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: self.playerItem)
        self.miniPlayerDelegate?.presentMiniPlayer()
        self.duration = Float(self.podcast?.duration ?? 0)
        self.didLoad()
        self.delegate?.updateUIInfo()
        self.commandCenter = PlayerCommandCenter.init(player: self.player, playerItem: self.playerItem)
        self.multicast.invokeDelegates({ delegate in delegate.didGetData() })
        self.updatePlaybackInfo()
        self.startPlaying()
    }

    /// Update playback info using timer
    private func setupTimer() {
        let displayLink = CADisplayLink(target: self, selector: #selector(updatePlaybackInfo))
        displayLink.add(to: .current, forMode: .common)
        self.displayLink = displayLink
    }

    /// Start play
    func startPlaying() {
        if round(currentTime) == round(duration) {
            currentTime = 0
            let targetTime = CMTime(value: CMTimeValue(currentTime), timescale: CMTimeScale(1.0))
            player.seek(to: targetTime)
        }
        setupTimer()
        player?.playImmediately(atRate: playBackSpeed)
        wasPlaying = true
        isPlaying = true
    }

    /// Stop playing
    func stopPlaying() {
        isPlaying = false
        setTimerPausedState(isPaused: true)
        player?.pause()
    }

    /// Pause player
    func pause() {
        player?.pause()
        commandCenter?.setupNowPlaying()
    }

    /// If Player was playing or not
    func decideToPlay() {
        if wasPlaying && isPlaying {
            startPlaying()
        }
    }

    /// PLay or pause button taped
    func didTapPlayButton() {
        isPlaying ? stopPlaying() : startPlaying()
    }

    /// Check if player already exist in memory
    private func playerState() {
        guard player != nil else { return }
        wasPlaying = false
        isPlaying = false
        player?.replaceCurrentItem(with: nil)
        displayLink?.invalidate()
        multicast.invokeDelegates({ delegate in delegate.resetView() })
        return
    }

    /// Get info from viewController on needed playback time
    func setCurrentPlaybackTime(value: Float) {
        let targetTime = CMTime(value: CMTimeValue(value), timescale: CMTimeScale(1.0))
        self.player?.seek(to: targetTime)
        updatePlaybackInfo()
    }

    /// Rise displayLink to update UI on changes
    func setTimerPausedState(isPaused: Bool) {
        displayLink?.isPaused = isPaused
    }

    func seekTime(direction: SeekDirection) {
        guard player != nil else { return }
        guard let duration = player?.currentItem?.duration,
              let currentTime = player?.currentTime() else { return }
        let newTime = CMTimeGetSeconds(currentTime) + seekDuration * (direction == .forward ? 1 : -1)
        guard newTime < CMTimeGetSeconds(duration) else { return }
        let selectedTime: CMTime = CMTimeMake(value: Int64(newTime * 1000 as Float64), timescale: 1000)
        player?.seek(to: selectedTime)
        decideToPlay()
    }

    func increasePlaybackSpeed() {
        guard player != nil, duration != 0 else { return }

        if playBackSpeed + 0.5 <= 2 {
            playBackSpeed += 0.5
        } else {
            playBackSpeed = 1
        }

        decideToPlay()
    }

    // MARK: - Stall player handling due to internet connection lost
    private func stallPlayerHandling() {
        guard let url = podcast?.audioURL,
              let currentTime = player?.currentTime() else { return }
        let currentTimeToProceedWith = CMTimeGetSeconds(currentTime)
        let resumeTime: CMTime = CMTimeMake(value: Int64(currentTimeToProceedWith * 1000 as Float64), timescale: 1000)
        if isOnline {
            let playerItem = AVPlayerItem.init(url: url)
            player?.replaceCurrentItem(with: playerItem)
            player?.seek(to: resumeTime)

            if player?.status == .readyToPlay {
                startPlaying()
                didLoad()
            }
        } else {
            stopPlaying()
            isLoading()
        }
    }
}

extension AudioPlayer {
    /// Update playback info for labels and playbackSlider position
    @objc func updatePlaybackInfo() {
        guard player != nil else { return }
        guard let currentTime = player?.currentTime().seconds else { return }

        if player?.currentItem?.status == .readyToPlay {
            self.currentTime = Float(currentTime)
        }
        commandCenter?.setupNowPlaying()
    }

    @objc func playerDidStall(_ notification: Notification) {
        guard notification.object as? CachingPlayerItem != nil else { return }
        print("Did stall")
        stallPlayerHandling()
    }

    @objc func didFailedToPlayToEndTime(_ notification: Notification) {
        guard let notification = notification.object as? AVPlayerItem else { return }

        if notification.isPlaybackBufferEmpty {
            stallPlayerHandling()
        }
    }
}

extension AudioPlayer {
    @objc func didFinishPlaying(_ myNotification: NSNotification) {
        duration = currentTime
        isPlaying = false
        setTimerPausedState(isPaused: true)
    }
}

// MARK: - CachingPlayerItemDelegate
extension AudioPlayer: CachingPlayerItemDelegate {
    func playerItem(_ playerItem: CachingPlayerItem, didFinishDownloadingData data: Data) {
        // Audio is downloaded. Saving it to the cache asynchronously.
        guard let podcast = podcast?.podcastID else { return }
        storageRepository.saveFile(data: data, name: podcast) { result in
            switch result {
            case .success:
                print("Saved locally with path \(podcast).mp3")
            case .failure:
                print("Fail to save with path \(podcast).mp3")
            }
        }
    }
}
