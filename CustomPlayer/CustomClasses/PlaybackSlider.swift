//
//  PlaybackSlider.swift
//  CustomPlayer
//
//  Created by User on 17.09.2021.
//

import UIKit

final class PlaybackSlider: UISlider {
    override func beginTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
        return true
    }
}
