//
//  PlayerViewController.swift
//  CustomPlayer
//
//  Created by User on 17.09.2021.
//

import AVFoundation
import FittedSheets
import UIKit

final class PlayerViewController: UIViewController {
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var timeLeftLabel: UILabel!
    @IBOutlet weak var timePlayedLabel: UILabel!
    @IBOutlet weak var playbackSlider: PlaybackSlider!
    @IBOutlet weak var playPauseButtonView: UIButton!
    @IBOutlet weak var seekTimeBackwardsView: UIButton!
    @IBOutlet weak var seekTimeForwardView: UIButton!
    @IBOutlet weak var speedButtonView: UIButton!
    @IBOutlet weak var downloadButtonView: UIButton!
    @IBOutlet weak var shareButtonView: UIButton!
    @IBOutlet weak var favoritesButtonView: UIButton!
    @IBOutlet weak var timerButtonView: UIButton!
    @IBOutlet weak var likeButtonView: UIButton!
    @IBOutlet weak var dislikeButtonView: UIButton!
    @IBOutlet weak var likeCountLabel: UILabel!
    @IBOutlet weak var dislikeCountLabel: UILabel!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    var viewModel: PlayerViewModeling!
    private var audioService = AudioPlayer.shared

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        guard audioService.wasPlaying else { return }
        setupCompletions()
        activityIndicator.stopAnimating()
        imageView.setImage(url: audioService.podcast?.imageURL)
        viewModel.multicast.invokeDelegates { delegate in
            delegate.updateLikeButtonStatus(status: viewModel.likeStatus, likes: viewModel.likesCount, dislikes: viewModel.dislikeCount)
        }
        setPlayButtonState()
        setControlButtonsEnabledState(isEnabled: true)
        descriptionLabel.text = audioService.podcast?.podcastDescription
        audioService.updatePlaybackInfo()
        setPlayButtonState()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        activityIndicator.startAnimating()
        setupSliders()
        setupPlayControlButtons()
        setupCompletions()
        setupOptionsControlButtons()
        setControlButtonsEnabledState(isEnabled: false)
        audioService.multicast.addDelegate(self)
        viewModel.multicast.addDelegate(self)
        setupImageView()
    }

    private func setupImageView() {
        imageView.layer.masksToBounds = true
        imageView.layer.cornerRadius = 7
    }

    private func setupCompletions() {
        audioService.onError = { [weak self] error in
//            self?.showAlert(text: error)
        }

        audioService.isLoading = { [weak self] in
            self?.activityIndicator.startAnimating()
        }

        audioService.didLoad = { [weak self] in
            self?.activityIndicator.stopAnimating()
            self?.setControlButtonsEnabledState(isEnabled: true)
        }
    }

    private func setControlButtonsEnabledState(isEnabled: Bool) {
        [playPauseButtonView, playbackSlider, seekTimeForwardView, seekTimeBackwardsView, speedButtonView, downloadButtonView, shareButtonView, favoritesButtonView, timerButtonView, likeButtonView, dislikeButtonView].forEach {
            $0?.isEnabled = isEnabled
        }
    }

    /// Set up control target functions for sliders
    private func setupSliders() {
        playbackSlider.addTarget(self, action: #selector(changePlaybackTime), for: .valueChanged)
        playbackSlider.setThumbImage(UIImage(named: "sliderThumb"), for: .normal)
        playbackSlider.bounds.size.width = 8
        playbackSlider.bounds.size.height = 8
    }

    /// Set up target methods
    private func setupPlayControlButtons() {
        seekTimeBackwardsView.addTarget(self, action: #selector(seekTimeBackward), for: .touchUpInside)
        seekTimeForwardView.addTarget(self, action: #selector(seekTimeForward), for: .touchUpInside)
    }

    private func setupOptionsControlButtons() {
        speedButtonView.addTarget(self, action: #selector(changePlaybackSpeedButtonAction), for: .touchUpInside)
        downloadButtonView.addTarget(self, action: #selector(downloadPodcastButtonAction), for: .touchUpInside)
        shareButtonView.addTarget(self, action: #selector(sharePodcastButtonAction), for: .touchUpInside)
        favoritesButtonView.addTarget(self, action: #selector(addPodcastToFavoritesButtonAction), for: .touchUpInside)
        timerButtonView.addTarget(self, action: #selector(openTimePickerFormButtonAction), for: .touchUpInside)
        likeButtonView.addTarget(self, action: #selector(likeButtonPressed), for: .touchUpInside)
        dislikeButtonView.addTarget(self, action: #selector(dislikeButtonPressed), for: .touchUpInside)
    }

    @objc private func seekTimeForward() {
        audioService.seekTime(direction: .forward)
    }

    @objc private func seekTimeBackward() {
        audioService.seekTime(direction: .backwards)
    }

    @IBAction func playPauseButtonAction(_ sender: UIButton) {
        audioService.didTapPlayButton()
    }
}

extension PlayerViewController {
    @objc private func changePlaybackTime(_ sender: PlaybackSlider, forEvent event: UIEvent) {
        guard let touchEvent = event.allTouches?.first else { return }
        switch touchEvent.phase {
        case .began:
            audioService.pause()
        case .moved, .stationary:
            let value = self.playbackSlider.value
            audioService.setCurrentPlaybackTime(value: value)
        case .ended:
            audioService.decideToPlay()
        default:
            break
        }
    }

    @objc private func changePlaybackSpeedButtonAction() {
        audioService.increasePlaybackSpeed()
    }

    @objc private func downloadPodcastButtonAction() { }

    @objc private func sharePodcastButtonAction() { }

    @objc private func addPodcastToFavoritesButtonAction() {
        viewModel.didTapAddToFavorites()
    }

    @objc private func openTimePickerFormButtonAction() {
        let controller = TimerViewController()
        let sheetController = SheetViewController(controller: controller,
                                                  sizes: [.fixed(controller.preferredContentSize.height)])
        self.present(sheetController, animated: true, completion: nil)
    }

    @objc private func likeButtonPressed() {
        viewModel.didTapLikeButton()
    }

    @objc private func dislikeButtonPressed() {
        viewModel.didTapDislikeButton()
    }
}

extension PlayerViewController: PlayerViewModelMultiDelegate {
    func onError(error: String) {
//        showAlert(text: error)
    }

    func updateLikeButtonStatus(status: LikeStatus, likes: Int, dislikes: Int) {
        switch status {
        case .disliked:
            dislikeButtonView.setImage(PlayerImageConstants.dislikeActive, for: .normal)
            likeButtonView.setImage(PlayerImageConstants.likeInactive, for: .normal)
            likeCountLabel.textColor = .black
            dislikeCountLabel.textColor = .systemBlue

        case .liked:
            likeButtonView.setImage(PlayerImageConstants.likeActive, for: .normal)
            dislikeButtonView.setImage(PlayerImageConstants.dislikeInactive, for: .normal)
            likeCountLabel.textColor = .systemBlue
            dislikeCountLabel.textColor = .black

        case .undefined:
            likeButtonView.setImage(PlayerImageConstants.likeInactive, for: .normal)
            dislikeButtonView.setImage(PlayerImageConstants.dislikeInactive, for: .normal)
            likeCountLabel.textColor = .black
            dislikeCountLabel.textColor = .black
        }

        likeCountLabel.text = "\(likes)"
        dislikeCountLabel.text = "\(dislikes)"
    }
}

extension PlayerViewController: AudioPlayerDelegate {
    func resetView() {
        imageView.image = UIImage(named: "Development")
        timeLeftLabel.text = "--:--"
        timePlayedLabel.text = "--:--"
        descriptionLabel.text = ""
        setControlButtonsEnabledState(isEnabled: false)
    }

    func didGetData() {
        activityIndicator.stopAnimating()

        if audioService.player != nil {
        imageView.setImage(url: audioService.podcast?.imageURL)
        descriptionLabel.text = audioService.podcast?.podcastDescription
        setControlButtonsEnabledState(isEnabled: true)
        }
    }

    func playbackInfoChanged(duration: Float, currentTime: Float, playbackSpeed: Double) {
        playbackSlider.maximumValue = duration
        playbackSlider.value = currentTime
        speedButtonView.setTitle("\(playbackSpeed)x", for: .normal)

        let time = viewModel.format(duration: TimeInterval(duration), currentTime: TimeInterval(currentTime))

        timePlayedLabel.text = time.timePlayed
        timeLeftLabel.text = time.timeLeft
    }

    func setPlayButtonState() {
        audioService.isPlaying ? playPauseButtonView.setBackgroundImage(PlayerImageConstants.pauseButton, for: .normal) : playPauseButtonView.setBackgroundImage(PlayerImageConstants.playButton, for: .normal)
    }
}
