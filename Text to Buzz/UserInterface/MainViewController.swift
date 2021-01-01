//
//  MainViewController.swift
//  Text to Buzz
//
//  Created by Brian Thompson on 11/22/20.
//

import UIKit

class MainViewController: UIViewController {

    @IBOutlet weak var connectToBuzz: UIButton!
    @IBOutlet weak var releaseBuzz: UIButton!
    @IBOutlet weak var textInput: UITextField!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var playSentence: UIButton!
    @IBOutlet weak var trainingView: UIView!
    @IBOutlet weak var phonemeLabel: UILabel!
    
    // Motor visualizers
    @IBOutlet weak var motor1View: UIView!
    @IBOutlet weak var motor2View: UIView!
    @IBOutlet weak var motor3View: UIView!
    @IBOutlet weak var motor4View: UIView!
    
    // Playback speed UI
    @IBOutlet weak var playbackStepper: UIStepper!
    @IBOutlet weak var playbackSpeedLabel: UILabel!
    
    
    // Motor value array
    var motorValueViews: [UIView]!
    var initialMotorViewHeight: CGFloat!
    var initialMotorViewY: CGFloat!
    
    // Current motor state
    var motorValues: [UInt8] = [0,0,0,0]
    
    // Time allowed for each phoneme vibration
    var playBackSpeed = 1.0
    
    // Class instances
    var buzz: Buzz!
    var phonemes: Phonemes!
    var motorController: MotorController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        buzz = Buzz(didUpdateStatus: didUpdateStatus)
        phonemes = Phonemes()
        motorController = MotorController(phonemes: phonemes.phonemes)
        intializeUI()
    }
    
    
    private func intializeUI() {
        self.connectToBuzz.layer.cornerRadius = 4
        self.releaseBuzz.layer.cornerRadius = 4
        self.playSentence.layer.cornerRadius = 4
        self.trainingView.isHidden = true
        self.textInput.delegate = self
        
        // Setup motorViews
        self.motorValueViews = [motor1View, motor2View, motor3View, motor4View]
        initialMotorViewHeight = motor1View.frame.height
        initialMotorViewY = motor1View.frame.origin.y
        updateMotorHeight(motorValues: [0,0,0,0])
        motor1View.layer.cornerRadius = 4
        motor2View.layer.cornerRadius = 4
        motor3View.layer.cornerRadius = 4
        motor4View.layer.cornerRadius = 4
        
        // Setup stepper
        playbackStepper.wraps = true
        playbackStepper.autorepeat = true
        playbackStepper.minimumValue = 1
        playbackStepper.maximumValue = 5
        playbackStepper.value = 1
    }
    
    private func initializeMotors() {
        motorValues = [0,0,0,0]
    }

    @IBAction func didPressConnectToBuzz(_ sender: Any) {
        if (statusLabel.text == "Scanning for Buzz...") {
            return
        }
        initializeMotors()
        buzz.takeOverBuzz()
        
        self.trainingView.isHidden = false

        
    }
    
    public func didUpdateStatus(status: String) {
        self.statusLabel.text = status
    }
    
    @IBAction func didPressPlaySentence(_ sender: Any) {
        playbackStepper.isEnabled = false
        var seconds = 0.0
        self.phonemeLabel.text = ""
        let sentencePhonemes = self.phonemes.sentenceToPhonemes(sentence: textInput.text!.trimmingCharacters(in: .whitespacesAndNewlines))
        for wordPhonemes in sentencePhonemes {
//            let word = wordPhonemes.0
            let phonemes = wordPhonemes.1
            for phoneme in phonemes {
                Timer.scheduledTimer(timeInterval: seconds, target: self, selector: #selector(playPhoneme(sender:)), userInfo: phoneme, repeats: false)
                var phonemeTime = 0.8 / playBackSpeed
                // Make vowels longer
                if self.phonemes.isVowel(phoneme: phoneme) {
                    phonemeTime *= 1.3
                }
                seconds += phonemeTime
                Timer.scheduledTimer(timeInterval: seconds, target: self, selector: #selector(zeroMotors), userInfo: phoneme, repeats: false)
                seconds += 0.2 / playBackSpeed
            }
        }
        Timer.scheduledTimer(timeInterval: seconds, target: self, selector: #selector(endSentence), userInfo: nil, repeats: false)
    }
    
    @objc func playPhoneme(sender: Timer) {
        let phoneme = sender.userInfo as! String
        let motorValues = self.motorController.getIntensities(phoneme: phoneme)
        self.phonemeLabel.text = phoneme
        self.buzz.vibrateMotors(motorValues: motorValues)
        self.updateMotorHeight(motorValues: motorValues)
    }
    
    @objc func zeroMotors() {
        self.buzz.vibrateMotors(motorValues: [0,0,0,0])
    }
    
    @objc func endSentence() {
        self.phonemeLabel.text = ""
        self.buzz.vibrateMotors(motorValues: [0,0,0,0])
        self.playbackStepper.isEnabled = true
    }
    
    func updateMotorHeight(motorValues: [UInt8]) {
        
        for i in 0..<4 {
            let motorValue = motorValues[i]
            let heightRatio = CGFloat(motorValue) / 255.0
            let yRatio = 1.0 - heightRatio
            let newHeight = heightRatio * initialMotorViewHeight
            let newY = initialMotorViewY + (yRatio * initialMotorViewHeight)
            let motorView = motorValueViews[i]
            UIView.animate(withDuration: min(0.5 / playBackSpeed, 0.25)) {
                motorView.frame = CGRect(x: motorView.frame.origin.x, y: newY, width: motorView.frame.width, height: newHeight )
            }
        }
    }
        
    @IBAction func didPressReleaseBuzz(_ sender: Any) {
        self.trainingView.isHidden = true
        self.buzz.vibrateMotors(motorValues: [0,0,0,0])
        self.buzz.releaseBuzz()
    }
    
    @IBAction func didPressClear(_ sender: Any) {
        self.textInput.text = ""
    }
    
    @IBAction func didPressStepper(_ sender: Any) {
        self.playBackSpeed = playbackStepper.value
        self.playbackSpeedLabel.text = String(Int(playbackStepper.value))
    }
    
    
}

extension MainViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true;
    }
}
