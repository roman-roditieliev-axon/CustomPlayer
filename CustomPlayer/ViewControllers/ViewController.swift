//
//  ViewController.swift
//  CustomPlayer
//
//  Created by User on 15.09.2021.
//

import UIKit

class ViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var audioUrlTextField: UITextField!
    @IBOutlet weak var playLocaleAudioButton: UIButton!

    private let podcastRepo = PodcastRepository.shared

    override func viewDidLoad() {
        super.viewDidLoad()
        audioUrlTextField.delegate = self
    }

    private func openPlayer(with model: Podcast) {
        let viewModel = PlayerViewModel(podcastRepo: podcastRepo)
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let viewController: PlayerViewController = storyboard.instantiateViewController(identifier: "PlayerViewController")
        viewController.viewModel = viewModel
        self.present(viewController, animated: true, completion: nil)
        AudioPlayer.shared.playPodcast(with: model, completion: nil)
    }

    @IBAction func playLocaleAudioAction(_ sender: Any) {
        let podcast = Podcast(title: "PMO title", duration: TimeInterval(27), likeCount: 2, url: URL(string: "http://podcasts.cnn.net/cnn/services/podcasting/onscreen/audio/2007/05/onscreen0508.mp3"), podcastID: "339071d2-fa42-4f61-992e-f30c28ef90ae", createAt: "2021-07-21T06:48:29.942024", status: "", reactionType: .liked)
        openPlayer(with: podcast)
    }

    func textFieldDidEndEditing(_ textField: UITextField) {

    }
}

