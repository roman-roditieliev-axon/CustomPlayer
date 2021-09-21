//
//  UIImageView.swift
//  CustomPlayer
//
//  Created by User on 17.09.2021.
//

import Kingfisher
import UIKit

extension UIImageView {
    func setImage(url: URL?, animated: Bool = true) {
        guard let url = url else {
            self.image = PlayerImageConstants.defaultImage
            return
        }
        kf.setImage(with: url, options: animated ? [.transition(.fade(0.9))] : []) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let result):
                    self?.image = result.image
                case .failure(_):
                    self?.image = PlayerImageConstants.defaultImage
                }
            }
        }
    }
}
