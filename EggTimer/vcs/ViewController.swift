//
//  ViewController.swift
//  EggTimer
//
//  Created by macintosh on 2018/10/29.
//  Copyright © 2018 macintosh. All rights reserved.
//

import Cocoa
import AVFoundation

class ViewController: NSViewController {

    @IBOutlet weak var timeLeftField: NSTextField!
    @IBOutlet weak var eggImageView: NSImageView!
    @IBOutlet weak var startButton: NSButton!
    @IBOutlet weak var stopButton: NSButton!
    @IBOutlet weak var resetButton: NSButton!
    
    var eggTimer = EggTimer()
    var prefs = Preferences()
    
    var soundPlayer: AVAudioPlayer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        eggTimer.delegate = self
        setupPrefs()
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    @IBAction func startButtonClick(_ sender: Any) {
        prepareSound()
        if eggTimer.isPaused  {
            eggTimer.resumeTimer()
        } else {
            eggTimer.duration = prefs.selectedTime
            eggTimer.startTimer()
        }
        configureButtonsAndMenus()
    }
    
    @IBAction func stopButtonClick(_ sender: Any) {
        eggTimer.stopTimer()
        configureButtonsAndMenus()
    }
    
    @IBAction func resetButtonClick(_ sender: Any) {
        eggTimer.resetTimer()
        updateDisplay(for: prefs.selectedTime)
        configureButtonsAndMenus()
    }
    
    /// menu items
    @IBAction func startTimerMenuItemSelected(_ sender: Any) {
        startButtonClick(sender)
    }
    
    @IBAction func stopTimerMenuItemSelected(_ sender: Any) {
        stopButtonClick(sender)
    }
    
    @IBAction func resetTimerMenuItemSelected(_ sender: Any) {
        resetButtonClick(sender)
    }
}

extension ViewController: EggTimerProtocol {
    func timeRemainingOnTimer(_ timer: EggTimer, timeRemaining: TimeInterval) {
        updateDisplay(for: timeRemaining)
    }
    
    func timerHasFinished(_ timer: EggTimer) {
        playSound()
        updateDisplay(for: 0)
    }
}

extension ViewController {
    
    // MARK: - 显示
    func updateDisplay(for timeRemaining: TimeInterval) {
        timeLeftField.stringValue = textToDisplay(for: timeRemaining)
        eggImageView.image = imageToDisplay(for: timeRemaining)
    }
    
    private func textToDisplay(for timeRemaining: TimeInterval) -> String {
        if timeRemaining == 0 {
            return "Done!"
        }
        let minutesRemaining = floor(timeRemaining / 60)
        let secondsRemaining = timeRemaining - (minutesRemaining * 60)
        
        let secondsDisplay = String(format: "%02d", Int(secondsRemaining))
        let timeRemainingDisplay = "\(Int(minutesRemaining)):\(secondsDisplay)"
        
        return timeRemainingDisplay
    }
    
    private func imageToDisplay(for timeRemaining: TimeInterval) -> NSImage? {
        let percentageComplete = 100 - (timeRemaining / prefs.selectedTime * 100)
        
        if eggTimer.isStopped {
            let stoppedImageName = (timeRemaining == 0) ? "100" : "stopped"
            return NSImage(named: stoppedImageName)
        }
        
        let imageName: String
        switch percentageComplete {
        case 0 ..< 25:
            imageName = "0"
        case 25 ..< 50:
            imageName = "25"
        case 50 ..< 75:
            imageName = "50"
        case 75 ..< 100:
            imageName = "75"
        default:
            imageName = "100"
        }
        
        return NSImage(named: imageName)
    }
}

extension ViewController {
    func configureButtonsAndMenus() {
        let enableStart: Bool
        let enableStop:  Bool
        let enableReset: Bool
        
        if eggTimer.isStopped {
            enableStart = true
            enableStop  = false
            enableReset = false
        } else if eggTimer.isPaused {
            enableStart = true
            enableStop  = false
            enableReset = true
        } else {
            enableStart = false
            enableStop  = true
            enableReset = false
        }
        
        startButton.isEnabled = enableStart
        stopButton.isEnabled  = enableStop
        resetButton.isEnabled = enableReset
        
        if let appDel = NSApplication.shared.delegate as? AppDelegate {
            appDel.enableMenus(start: enableStart, stop: enableStop, reset: enableReset)
        }
    }
}

extension ViewController {
    
    func setupPrefs() {
        updateDisplay(for: prefs.selectedTime)
        let notificationName = Notification.Name(rawValue: "PrefsChanged")
        NotificationCenter.default.addObserver(forName: notificationName,
                                               object: nil, queue: nil) {
                                                (notification) in
                self.checkForResetAfterPrefsChange()
        }
    }
    
    func checkForResetAfterPrefsChange() {
        if eggTimer.isStopped || eggTimer.isPaused {
            // 1
            updateFromPrefs()
        } else {
            // 2
            let alert = NSAlert()
            alert.messageText = "Reset timer with the new settings?"
            alert.informativeText = "This will stop your current timer!"
            alert.alertStyle = .warning
            
            // 3
            alert.addButton(withTitle: "Reset")
            alert.addButton(withTitle: "Cancel")
            
            // 4
            let response = alert.runModal()
            if response == NSApplication.ModalResponse.alertFirstButtonReturn {
                self.updateFromPrefs()
            }
        }
    }
    
    func updateFromPrefs() {
        self.eggTimer.duration = self.prefs.selectedTime
        self.resetButtonClick(self)
    }
}

/// Voice
extension ViewController {
    func prepareSound() {
        guard let audioFileUrl = Bundle.main.url(forResource: "ding",
                                                 withExtension: "mp3") else { return }
        do {
            soundPlayer = try AVAudioPlayer(contentsOf: audioFileUrl)
            soundPlayer?.prepareToPlay()
        } catch {
            print("Sound player not available: \(error)")
        }
    }
    
    func playSound() {
        soundPlayer?.play()
    }
}
