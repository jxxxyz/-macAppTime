//
//  EggTimer.swift
//  EggTimer
//
//  Created by macintosh on 2018/10/29.
//  Copyright © 2018 macintosh. All rights reserved.
//

import Foundation
protocol EggTimerProtocol {
    func timeRemainingOnTimer(_ timer: EggTimer, timeRemaining: TimeInterval)
    func timerHasFinished(_ timer: EggTimer)
}

class EggTimer {
    var timer: Timer? = nil
    var startTime: Date?
    var duration: TimeInterval = 360 // 默认的计时时间是 6 分钟
    var elapsedTime: TimeInterval = 0
    var delegate: EggTimerProtocol?
    
    @objc dynamic func timerAction() {
        guard let startTime = startTime else { return }
        elapsedTime = -startTime.timeIntervalSinceNow
        let secondsRemaining = (duration - elapsedTime).rounded()
        if secondsRemaining <= 0 {
            resetTimer()
            delegate?.timerHasFinished(self)
        } else {
            delegate?.timeRemainingOnTimer(self, timeRemaining: secondsRemaining)
        }
    }
    
    func startTimer() {
        startTime = Date()
        elapsedTime = 0
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(timerAction), userInfo: nil, repeats: true)
        timerAction()
    }
    
    func resumeTimer() {
        startTime = Date(timeIntervalSinceNow: -elapsedTime)
        timer = Timer.scheduledTimer(timeInterval: 1,
                                     target: self,
                                     selector: #selector(timerAction),
                                     userInfo: nil,
                                     repeats: true)
        timerAction()
    }
    
    func stopTimer() {
        timer?.invalidate()
        timer = nil
        timerAction()
    }
    
    func resetTimer() {
        timer?.invalidate()
        timer = nil
        startTime = nil
        duration = 360
        elapsedTime = 0
        timerAction()
    }
}

/// 计算属性
extension EggTimer {
    var isStopped: Bool {
         return timer == nil && elapsedTime == 0
    }
    
    var isPaused: Bool {
        return timer == nil &&  elapsedTime > 0
    }
}
