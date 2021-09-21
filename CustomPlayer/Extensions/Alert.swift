//
//  Alert.swift
//  CustomPlayer
//
//  Created by User on 21.09.2021.
//

import UIKit

extension UIViewController {
    /// Show allert to user if error occures
    func showAlert(text: String) {
        let alert  = UIAlertController(title: "Important!", message: text, preferredStyle: .alert)

        let action = UIAlertAction(title: "OK", style: .default) { (_) in
            alert.dismiss(animated: true, completion: nil)
        }

        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }

    /// Pop-up allert
    func showToast(message: String, seconds: Double, completion: @escaping () -> Void) {
        let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)

        alert.view.backgroundColor = .black
        alert.view.alpha = 0.5
        alert.view.layer.cornerRadius = 15

        self.present(alert, animated: true)

        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + seconds) {
            alert.dismiss(animated: true, completion: completion)
        }
    }
}
