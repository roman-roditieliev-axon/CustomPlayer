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

class ViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var audioUrlTextField: UITextField!
    @IBOutlet weak var playLocaleAudioButton: UIButton!

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

    override func viewDidLoad() {
        super.viewDidLoad()
        AudioPlayer.shared.miniPlayerDelegate = self
        audioUrlTextField.delegate = self
    }

    private func openPlayer(with model: Podcast) {
        let viewModel = PlayerViewModel()
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let viewController: PlayerViewController = storyboard.instantiateViewController(identifier: "PlayerViewController")
        viewController.viewModel = viewModel
        self.present(viewController, animated: true, completion: nil)
        AudioPlayer.shared.playPodcast(with: model, completion: nil)
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

    @IBAction func playLocaleAudioAction(_ sender: Any) {
        //https://s3.amazonaws.com/kargopolov/kukushka.mp3
        //https://www.learningcontainer.com/wp-content/uploads/2020/02/Kalimba.mp3

        let stringUrl = "https://www.soundhelix.com/examples/mp3/SoundHelix-Song-9.mp3"
        let url = URL(string: stringUrl)!
        let name = stringUrl.split(separator: "/").last!

        let podcast = Podcast(title: String(name), duration: TimeInterval(27), likeCount: 2, url: url, podcastID: String(name), createAt: "2021-07-21T06:48:29.942024", status: "", reactionType: .liked)
        openPlayer(with: podcast)
    }

    func textFieldDidEndEditing(_ textField: UITextField) {

    }

    private func presentMainPlayer() {
        let viewModel = PlayerViewModel()
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let viewController: PlayerViewController = storyboard.instantiateViewController(identifier: "PlayerViewController")
        viewController.viewModel = viewModel
        self.present(viewController, animated: true, completion: nil)
    }
}

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
