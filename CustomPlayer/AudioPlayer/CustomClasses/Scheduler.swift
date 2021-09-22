//
//  Scheduler.swift
//  AxonPodcasts
//
//  Created by Evhen Petrovskyi on 18.07.2021.
//

import Foundation

protocol SchedulerTimerViewControllerDelegate: AnyObject {
    func updateTimerInfo(endTime: Float, currentTime: Float)
}

class Scheduler {
    var timer: Timer!
    var endTime: Float = 0
    var schedulerMulticast = MulticastDelegate<SchedulerTimerViewControllerDelegate>()
    private var audioPlayer: AudioPlayer?
    // Updated: remove singelton
    var currentTime: Float = 0 {
        didSet {
            schedulerMulticast.invokeDelegates({ delegate in delegate.updateTimerInfo(endTime: endTime, currentTime: currentTime) })
        }
    }
    
    func setTimer(endTime: Float) {
        if self.timer != nil {
            self.timer = nil
        }

        guard let player = self.audioPlayer else { return }
        if player.currentTime + endTime > player.duration {
            self.endTime = player.duration
        } else {
            self.endTime = player.currentTime + endTime
        }
        
        setupTimer()
    }
    
    private func setupTimer() {
        let timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(update), userInfo: nil, repeats: true)
        self.timer = timer
    }
    
    @objc private func update() {
        guard let player = self.audioPlayer else { return }

        if player.currentTime >= self.endTime {
            player.stopPlaying()
            self.timer.invalidate()
        }
        
        if player.player == nil {
            timer.invalidate()
        }
        
        currentTime = self.endTime - player.currentTime
        
        self.currentTime = Float(currentTime)
    }
}
