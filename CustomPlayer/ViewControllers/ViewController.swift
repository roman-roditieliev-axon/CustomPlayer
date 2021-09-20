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

    override func viewDidLoad() {
        super.viewDidLoad()
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
}

