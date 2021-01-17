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
    @IBOutlet weak var typeView: UIView!
    @IBOutlet weak var practiceView: UIView!
    
    // Motor visualizers
    @IBOutlet weak var motor1View: UIView!
    @IBOutlet weak var motor2View: UIView!
    @IBOutlet weak var motor3View: UIView!
    @IBOutlet weak var motor4View: UIView!
    
    // Playback speed UI
    @IBOutlet weak var playbackStepper: UIStepper!
    @IBOutlet weak var playbackSpeedLabel: UILabel!
    
    // For practice
    @IBOutlet weak var typePracticeSegment: UISegmentedControl!
    @IBOutlet weak var practiceWord1: UIButton!
    @IBOutlet weak var practiceWord2: UIButton!
    @IBOutlet weak var practiceWord3: UIButton!
    @IBOutlet weak var practiceWord4: UIButton!
    @IBOutlet weak var switchWords: UIButton!
    @IBOutlet weak var guessTheWord: UIButton!
    @IBOutlet weak var trainTestView: UIView!
    @IBOutlet weak var difficultyPicker: UISegmentedControl!
    @IBOutlet weak var selectDifficulty: UIButton!
    @IBOutlet weak var streakLabel: UILabel!
    @IBOutlet weak var maxLabel: UILabel!
    
    var practiceWordsArray: [UIButton]!
    var trainingWords: [String] = ["", "", "", ""]
    var testWord = ""
    var winningStreak = 0
    var maxStreak = 0
    
    // Motor value array
    var motorValueViews: [UIView]!
    var initialMotorViewHeight: CGFloat!
    var initialMotorViewY: CGFloat!
    
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
        playbackStepper.maximumValue = 10
        playbackStepper.value = 2
        playBackSpeed = playbackStepper.value
        playbackSpeedLabel.text = String(Int(playbackStepper.value))
        
        // Setup practice view
        practiceView.isHidden = true
        selectDifficulty.layer.cornerRadius = 2
        switchWords.layer.cornerRadius = 2
        guessTheWord.layer.cornerRadius = 2
        practiceWord1.addTarget(self, action: #selector(self.didPressTrainingWord(_:)), for: .touchUpInside)
        practiceWord2.addTarget(self, action: #selector(self.didPressTrainingWord(_:)), for: .touchUpInside)
        practiceWord3.addTarget(self, action: #selector(self.didPressTrainingWord(_:)), for: .touchUpInside)
        practiceWord4.addTarget(self, action: #selector(self.didPressTrainingWord(_:)), for: .touchUpInside)
        practiceWordsArray = [practiceWord1, practiceWord2, practiceWord3, practiceWord4]
    }

    @IBAction func didPressConnectToBuzz(_ sender: Any) {
        if (statusLabel.text == "Scanning for Buzz...") {
            return
        }
        buzz.takeOverBuzz()
        
        self.trainingView.isHidden = false

        
    }
    
    public func didUpdateStatus(status: String) {
        self.statusLabel.text = status
    }
    
    @IBAction func didPressPlaySentence(_ sender: Any) {
        playSentence.isEnabled = false
        playSentence(sentence: textInput.text!.trimmingCharacters(in: .whitespacesAndNewlines))
    }
    
    func playDifficultyOne(phoneme: String){
        var seconds = 0.0
        self.phonemeLabel.text = ""
        var duration = 0.8 / playBackSpeed
        // Make vowels longer
        if self.phonemes.isVowel(phoneme: phoneme) {
            duration *= 1.3
        }
        Timer.scheduledTimer(timeInterval: seconds, target: self, selector: #selector(playPhoneme(sender:)), userInfo: (phoneme, duration), repeats: false)
        seconds += duration
        // End playback
        Timer.scheduledTimer(timeInterval: seconds, target: self, selector: #selector(endSentence), userInfo: nil, repeats: false)
    }
    
    func playSentence(sentence: String) {
        playbackStepper.isEnabled = false
        guessTheWord.isEnabled = false
        if difficultyPicker.selectedSegmentIndex == 0 && typePracticeSegment.selectedSegmentIndex == 1 {
            playDifficultyOne(phoneme: sentence)
        } else {
            var seconds = 0.0
            let duration = 1.0 / playBackSpeed
            self.phonemeLabel.text = ""
            let sentencePhonemes = self.phonemes.sentenceToPhonemes(sentence: sentence)
            for wordPhonemes in sentencePhonemes {
                let phonemes = wordPhonemes.1
                for phoneme in phonemes {
                    Timer.scheduledTimer(timeInterval: seconds, target: self, selector: #selector(playPhoneme(sender:)), userInfo: (phoneme, duration), repeats: false)
                    seconds += duration
                    
//                    Timer.scheduledTimer(timeInterval: seconds, target: self, selector: #selector(zeroMotors), userInfo: nil, repeats: false)
//                    seconds += 0.2 * duration
                }
            }
            Timer.scheduledTimer(timeInterval: seconds, target: self, selector: #selector(endSentence), userInfo: nil, repeats: false)
        }
    }
    
    @objc func playPhoneme(sender: Timer) {
        let (phoneme, duration) = sender.userInfo as! (String, Double)
        self.phonemeLabel.text = phoneme
        var seconds = 0.0
        let subMotorValues = self.motorController.getSequence(phoneme: phoneme)
        self.updateMotorHeight(motorValues: self.motorController.getIntensities(phoneme: phoneme))
        for i in 0..<4 {
            let motorValues = subMotorValues[i]
            Timer.scheduledTimer(timeInterval: seconds, target: self, selector: #selector(playIntensities(sender:)), userInfo: (i, motorValues), repeats: false)
            seconds += (0.9 * duration) / 4.0
            
            Timer.scheduledTimer(timeInterval: seconds, target: self, selector: #selector(zeroMotors), userInfo: nil, repeats: false)
            seconds += (0.1 * duration) / 4.0
        }
    }
    
    @objc func playIntensities(sender: Timer) {
        let (i, motorValues) = sender.userInfo as! (Int, [UInt8])
        motorValueViews[i].backgroundColor = UIColor.orange
        if i > 0 {
            motorValueViews[i-1].backgroundColor = UIColor.red
        }
        self.buzz.vibrateMotors(motorValues: motorValues)
    }
    
    @objc func zeroMotors() {
        self.buzz.vibrateMotors(motorValues: [0,0,0,0])
    }
    
    @objc func endSentence() {
        self.phonemeLabel.text = ""
        self.buzz.vibrateMotors(motorValues: [0,0,0,0])
        self.playbackStepper.isEnabled = true
        self.playSentence.isEnabled = true
        self.guessTheWord.isEnabled = true
        self.updateMotorHeight(motorValues: [0,0,0,0])
        
        // Re-enable practice words
        for practiceWord in practiceWordsArray {
            practiceWord.isEnabled = true
        }
    }
    
    func updateMotorHeight(motorValues: [UInt8]) {
        for i in 0..<4 {
            let motorValue = motorValues[i]
            let heightRatio = CGFloat(motorValue) / 255.0
            let yRatio = 1.0 - heightRatio
            let newHeight = heightRatio * initialMotorViewHeight
            let newY = initialMotorViewY + (yRatio * initialMotorViewHeight)
            let motorView = motorValueViews[i]
            motorView.backgroundColor = UIColor.red
            UIView.animate(withDuration: 0.25 / playBackSpeed) {
                motorView.frame = CGRect(x: motorView.frame.origin.x, y: newY, width: motorView.frame.width, height: newHeight )
            }
        }
    }
    
    @IBAction func didChangeTypePracticeSegment(_ sender: Any) {
        if typePracticeSegment.selectedSegmentIndex == 0 {
            // Show Type view
            typeView.isHidden = false
            practiceView.isHidden = true
            phonemeLabel.isHidden = false
            for motorView in motorValueViews {
                motorView.isHidden = false
            }
        } else {
            // Show practice view
            typeView.isHidden = true
            practiceView.isHidden = false
            showDifficultySelection()
        }
    }
    
    func showTrainPracticeMode() {
    }
    
    func showDifficultySelection() {
        difficultyPicker.isHidden = false
        selectDifficulty.isHidden = false
        trainTestView.isHidden = true
    }
    
    @IBAction func didSelectDifficulty(_ sender: Any) {
        difficultyPicker.isHidden = true
        selectDifficulty.isHidden = true
        trainTestView.isHidden = false
        phonemeLabel.isHidden = false
        for motorView in motorValueViews {
            motorView.isHidden = false
        }
        populateWords()
    }
    
    @IBAction func didPressSwitchWords(_ sender: Any) {
        populateWords()
    }
    
    func populateWords() {
        // Get four words at that difficulty
        let practiceDifficulty = difficultyPicker.selectedSegmentIndex + 1
        trainingWords = self.phonemes.getRandomWords(difficulty: practiceDifficulty)
        practiceWord1.setTitle(trainingWords[0], for: .normal)
        practiceWord2.setTitle(trainingWords[1], for: .normal)
        practiceWord3.setTitle(trainingWords[2], for: .normal)
        practiceWord4.setTitle(trainingWords[3], for: .normal)
        testWord = ""
        winningStreak = 0
        maxStreak = 0
        streakLabel.text = String(winningStreak)
        maxLabel.text = String(maxStreak)
    }
    
    @IBAction func didPressPlayAndGuess(_ sender: Any) {
        // If new test word, choose a random one
        if testWord == "" {
            testWord = trainingWords[Int(arc4random_uniform(UInt32(4)))]
        }
        statusLabel.text = "Playing test word. Guess the correct word!"
        
        // Hide training aids
        phonemeLabel.isHidden = true
        for motorView in motorValueViews {
            motorView.isHidden = true
        }
        playSentence(sentence: testWord)
    }
    
    
    @objc func didPressTrainingWord(_ sender: UIButton){
        var selectedWord = ""
        
        // Grab word which was selected
        switch sender {
            case practiceWord1:
                selectedWord = trainingWords[0]
            case practiceWord2:
                selectedWord = trainingWords[1]
            case practiceWord3:
                selectedWord = trainingWords[2]
            case practiceWord4:
                selectedWord = trainingWords[3]
            default:
                print("not possible")
        }
        
        if testWord == "" { // training mode
            // Disable pressing words again until playback is finished
            for practiceWord in practiceWordsArray {
                practiceWord.isEnabled = false
            }
            
            statusLabel.text = "Playing \(selectedWord)"
            phonemeLabel.isHidden = false
            
            // Reset winning streak
            winningStreak = 0
            streakLabel.text = String(winningStreak)
            
            // Show training aids
            for motorView in motorValueViews {
                motorView.isHidden = false
            }
            playSentence(sentence: selectedWord)
        } else { // testing mode
            if selectedWord == testWord {
                statusLabel.text = "Correct! The word is \(testWord)"
                // Increment streak
                winningStreak += 1
                streakLabel.text = String(winningStreak)
                
                // Set new max
                if winningStreak > maxStreak {
                    maxStreak = winningStreak
                    maxLabel.text = String(maxStreak)
                }
            } else {
                statusLabel.text = "Incorrect, the word is \(testWord)"
                // Reset streak
                winningStreak = 0
                streakLabel.text = String(winningStreak)
            }
            testWord = ""
        }
    }
    
    @IBAction func didPressReleaseBuzz(_ sender: Any) {
        self.trainingView.isHidden = true
        self.buzz.vibrateMotors(motorValues: [0,0,0,0])
        self.buzz.releaseBuzz()
    }
    
    @IBAction func didPressClear(_ sender: Any) {
        self.textInput.text = ""
        self.textInput.becomeFirstResponder()
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

extension MainViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "basicStyleCell", for: indexPath)
        cell.textLabel?.text = "test"
        return cell
    }
    

}
