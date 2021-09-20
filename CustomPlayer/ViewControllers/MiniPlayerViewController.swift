//
//  MiniPlayerViewController.swift
//  CustomPlayer
//
//  Created by User on 20.09.2021.
//

import EFAutoScrollLabel
import UIKit

final class MiniPlayerViewController: UIViewController {
    var viewModel: PlayerViewModeling!
    weak var delegate: MiniPlayerViewControllerDelegate?
    static let playerHeight: CGFloat = 58
    private let audioPlayer = AudioPlayer.shared

    private lazy var imageView: UIImageView = {
        let view = UIImageView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.image = UIImage(named: "Development")
        view.layer.masksToBounds = true
        view.layer.cornerRadius = 8
        return view
    }()

    private lazy var descriptionLabel: EFAutoScrollLabel = {
        let view = EFAutoScrollLabel()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.frame.size.height = 22
        view.textAlignment = .left
        view.text = "You're description will be here"
        view.labelSpacing = 40
        view.pauseInterval = 3
        view.scrollSpeed = 30
        view.textAlignment = .left
        view.fadeLength = 8
        view.scrollDirection = .left
        return view
    }()

    private lazy var playButton: UIButton = {
       let view = UIButton()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.setImage(PlayerImageConstants.miniPlayButton, for: .normal)
        view.addTarget(self, action: #selector(didTapPlayPauseButton), for: .touchUpInside)
        return view
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        setUpView()
        setControlButtonsEnabledState(isEnabled: false)
        audioPlayer.multicast.addDelegate(self)
        setupGestureRecognizer()
        playerUpdateIfNeeded()
    }

    /// If player still in memory method will update UI
    private func playerUpdateIfNeeded() {
        guard audioPlayer.player != nil else { return }
        audioPlayer.multicast.invokeDelegates({ delegate in
            delegate.didGetData()
        })
    }

    private func setupGestureRecognizer() {
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(didTapToShowPlayer(_:)))
        tapGestureRecognizer.numberOfTapsRequired = 1
        tapGestureRecognizer.delegate = self
        view.addGestureRecognizer(tapGestureRecognizer)
    }

    private func setUpView() {
        view.addSubview(imageView)
        view.addSubview(descriptionLabel)
        view.addSubview(playButton)

        NSLayoutConstraint.activate([
            imageView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 8),
            imageView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            imageView.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.8),
            imageView.widthAnchor.constraint(equalTo: imageView.heightAnchor),

            descriptionLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            descriptionLabel.leadingAnchor.constraint(equalTo: imageView.trailingAnchor, constant: 16),
            descriptionLabel.trailingAnchor.constraint(equalTo: playButton.leadingAnchor),

            playButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 0),
            playButton.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            playButton.heightAnchor.constraint(equalTo: view.heightAnchor),
            playButton.widthAnchor.constraint(equalTo: playButton.heightAnchor),
        ])
    }

    /// Enable control buttons
    private func setControlButtonsEnabledState(isEnabled: Bool) {
        playButton.isEnabled = isEnabled
    }

}

// MARK: - Extension for selector methods
extension MiniPlayerViewController {
    @objc private func didTapPlayPauseButton() {
        audioPlayer.isPlaying ? audioPlayer.stopPlaying() : audioPlayer.startPlaying()
    }
}

// MARK: - Multicast delegate methods implementation
extension MiniPlayerViewController: AudioPlayerDelegate {
    func playbackInfoChanged(duration: Float, currentTime: Float, playbackSpeed: Double) { }

    func setPlayButtonState() {
        audioPlayer.isPlaying ? playButton.setImage(PlayerImageConstants.miniPauseButton, for: .normal) : playButton.setImage(PlayerImageConstants.miniPlayButton, for: .normal)
    }

    func didGetData() {
        imageView.setImage(url: audioPlayer.podcast?.imageURL)
        descriptionLabel.text = audioPlayer.podcast?.podcastDescription

        setControlButtonsEnabledState(isEnabled: true)
    }

    func resetView() {
        imageView.image = UIImage(named: "Development")
        descriptionLabel.text = ""
        setControlButtonsEnabledState(isEnabled: false)
    }
}

extension MiniPlayerViewController: UIGestureRecognizerDelegate {
    @objc func didTapToShowPlayer(_ sender: UITapGestureRecognizer) {
        guard audioPlayer.player != nil else { return }
        if sender.state == .ended {
            delegate?.presentMainPlayerViewController()
        }
    }
}
