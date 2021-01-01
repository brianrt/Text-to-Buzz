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
    
    // Current motor state
    var motorValues: [UInt8] = [0,0,0,0]
    
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
        var seconds = 0.0
        self.phonemeLabel.text = ""
        let sentencePhonemes = self.phonemes.sentenceToPhonemes(sentence: textInput.text!.trimmingCharacters(in: .whitespacesAndNewlines))
        for wordPhonemes in sentencePhonemes {
//            let word = wordPhonemes.0
            let phonemes = wordPhonemes.1
            for phoneme in phonemes {
                Timer.scheduledTimer(timeInterval: seconds, target: self, selector: #selector(playPhoneme(sender:)), userInfo: phoneme, repeats: false)
                seconds += 0.5
            }
        }
        Timer.scheduledTimer(timeInterval: seconds, target: self, selector: #selector(endSentence), userInfo: nil, repeats: false)
    }
    
    @objc func playPhoneme(sender: Timer) {
        let phoneme = sender.userInfo as! String
        let motorValues = self.motorController.getIntensities(phoneme: phoneme)
        self.phonemeLabel.text = self.phonemeLabel.text! + "\(phoneme) "
        self.buzz.vibrateMotors(motorValues: motorValues)
    }
    
    @objc func endSentence() {
        self.phonemeLabel.text = ""
        self.buzz.vibrateMotors(motorValues: [0,0,0,0])
    }
    
    @IBAction func didPressReleaseBuzz(_ sender: Any) {
        self.trainingView.isHidden = true
        self.buzz.vibrateMotors(motorValues: [0,0,0,0])
        self.buzz.releaseBuzz()
    }
    
    @IBAction func didPressClear(_ sender: Any) {
        self.textInput.text = ""
    }
    
}

extension MainViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true;
    }
}
