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


    @IBAction func playLocaleAudioAction(_ sender: Any) {

    }

    func textFieldDidEndEditing(_ textField: UITextField) {

    }
}

