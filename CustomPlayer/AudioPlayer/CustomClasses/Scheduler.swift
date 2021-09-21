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

final class Scheduler {
    var timer: Timer!
    var endTime: Float = 0
    var schedulerMulticast = MulticastDelegate<SchedulerTimerViewControllerDelegate>()
    private var audioPlayer = AudioPlayer.shared
    
    static let shared = Scheduler()
    
    var currentTime: Float = 0 {
        didSet {
            schedulerMulticast.invokeDelegates({ delegate in delegate.updateTimerInfo(endTime: endTime, currentTime: currentTime) })
        }
    }
    
    func setTimer(endTime: Float) {
        if self.timer != nil {
            self.timer = nil
        }
        
        if audioPlayer.currentTime + endTime > audioPlayer.duration {
            self.endTime = audioPlayer.duration
        } else {
            self.endTime = audioPlayer.currentTime + endTime
        }
        
        setupTimer()
    }
    
    private func setupTimer() {
        let timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(update), userInfo: nil, repeats: true)
        self.timer = timer
    }
    
    @objc private func update() {
        if audioPlayer.currentTime >= self.endTime {
            audioPlayer.stopPlaying()
            self.timer.invalidate()
        }
        
        if audioPlayer.player == nil {
            timer.invalidate()
        }
        
        currentTime = self.endTime - audioPlayer.currentTime
        
        self.currentTime = Float(currentTime)
    }
}
