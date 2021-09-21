//
//  ViewController.swift
//  CustomPlayer
//
//  Created by User on 15.09.2021.
//

import UIKit

protocol MiniPlayerViewControllerDelegate: AnyObject {
    func presentMainPlayerViewController()
}

class ViewController: UIViewController {

    @IBOutlet weak var audioUrlTextField: UITextField!
    @IBOutlet weak var playLocaleAudioButton: UIButton!

    // MARK: - create mini player
    lazy var miniPlayerVC: MiniPlayerViewController = {
        let view = MiniPlayerViewController()
        view.viewModel = viewModel
        view.delegate = self
        return view
    }()

    private lazy var miniPlayerContainerView: UIView = {
        let containerView = UIView()
        containerView.backgroundColor = .systemGray5
        containerView.translatesAutoresizingMaskIntoConstraints = false
        return containerView
    }()

    var viewModel: PlayerViewModeling!

    // MARK: - Configure mini player
    override func viewDidLoad() {
        super.viewDidLoad()
        AudioPlayer.shared.miniPlayerDelegate = self
    }

    private func configureView() {
        let layoutGuide = view.safeAreaLayoutGuide
        view.addSubview(miniPlayerContainerView)
        addChild(miniPlayerVC)
        miniPlayerContainerView.addSubview(miniPlayerVC.view)
        miniPlayerVC.didMove(toParent: self)
        miniPlayerVC.view.translatesAutoresizingMaskIntoConstraints = false
        guard let miniPlayerView = miniPlayerVC.view else { return }
        NSLayoutConstraint.activate([
            miniPlayerContainerView.leadingAnchor.constraint(equalTo: layoutGuide.leadingAnchor),
            miniPlayerContainerView.trailingAnchor.constraint(equalTo: layoutGuide.trailingAnchor),
            miniPlayerContainerView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: -50),
            miniPlayerContainerView.heightAnchor.constraint(equalToConstant: MiniPlayerViewController.playerHeight),

            miniPlayerView.leadingAnchor.constraint(equalTo: miniPlayerContainerView.leadingAnchor),
            miniPlayerView.trailingAnchor.constraint(equalTo: miniPlayerContainerView.trailingAnchor),
            miniPlayerView.topAnchor.constraint(equalTo: miniPlayerContainerView.topAnchor),
            miniPlayerView.bottomAnchor.constraint(equalTo: miniPlayerContainerView.bottomAnchor),
        ])
    }

    // MARK: - Play action
    @IBAction func playLocaleAudioAction(_ sender: Any) {
        let stringUrl = self.audioUrlTextField.text ?? ""
        let url = URL(string: stringUrl)

        if !stringUrl.isEmpty {
            let name = stringUrl.split(separator: "/").last ?? "Test Name"

            let podcast = Podcast(title: String(name), duration: TimeInterval(240), likeCount: 2, dislikeCount: 1, audioUrl: url, imageUrl: nil, podcastID: String(name), categoryID: "", createdAt: "2021-07-21T06:48:29.942024", publishedAt: "2021-07-21T06:48:29.942024", status: "", reactionType: .liked)
            openPlayer(with: podcast)
        }
    }

    // MARK: - Open player
    private func openPlayer(with model: Podcast) {
        presentMainPlayer()
        AudioPlayer.shared.playPodcast(with: model, completion: nil)
    }

    private func presentMainPlayer() {
        let viewModel = PlayerViewModel()
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let viewController: PlayerViewController = storyboard.instantiateViewController(identifier: "PlayerViewController")
        viewController.viewModel = viewModel
        self.present(viewController, animated: true, completion: nil)
    }
}

// MARK: - Player delegates
extension ViewController: MiniPlayerPresenterDelegate {
    func presentMiniPlayer() {
        self.configureView()
    }
}

extension ViewController: MiniPlayerViewControllerDelegate {
    func presentMainPlayerViewController() {
        presentMainPlayer()
    }
}
