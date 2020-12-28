//
//  Phonemes.swift
//  Text to Buzz
//
//  Created by Brian Thompson on 12/26/20.
//

import Foundation
import AVFoundation

class Phonemes: NSObject {
    
    var wordToPhonemesDict: Dictionary<String, [String]> = [:]
    let phonemes = ["AA", "AE", "AH", "AO", "AW", "AY", "B", "CH", "D", "DH", "EH", "ER", "EY", "F", "G", "HH", "IH", "IY", "JH", "K", "L", "M", "N", "NG", "OW", "OY", "P", "R", "S", "SH", "T", "TH", "UH", "UW", "V", "W", "Y", "Z", "ZH"]
    let phoneme_human: Dictionary<String, String> = ["AA": "ah", "AE": "a", "AH": "uh", "AO": "awe", "AW": "ow", "AY": "I", "B": "b", "CH": "ch", "D": "d", "DH": "thh", "EH": "e", "ER": "er", "EY": "A", "F": "f", "G": "g", "HH": "h", "IH": "i", "IY": "E", "JH": "j", "K": "k", "L": "l", "M": "m", "N": "n", "NG": "ng", "OW": "O", "OY": "oy", "P": "p", "R": "r", "S": "s", "SH": "sh", "T": "t", "TH": "th", "UH": "uu", "UW": "oo", "V": "v", "W": "w", "Y": "y", "Z": "z", "ZH": "shz"]
    
    override init() {
        super.init()
        self.loadDictFromFile()
    }
    
    private func loadDictFromFile() {
        if let path = Bundle.main.path(forResource: "phonemes_dict", ofType: "txt", inDirectory: "Resource") {
            do {
                let data = try String(contentsOfFile: path, encoding: .ascii)
                let lines = data.components(separatedBy: .newlines)
                for line in lines {
                    if String(line.prefix(1)).isAlphabetic {
                        // Split by spaces
                        let word_phonemes = line.components(separatedBy: "  ")
                        let word = word_phonemes[0]
                        if !word.isNumeric {
                            var phonemes = word_phonemes[1].components(separatedBy: " ")
                            // Remove numbers from phonemes
                            phonemes = phonemes.map { removeNumbersFromStrings(phoneme: $0) }
                            // Replace phonemes with human readable ones
                            phonemes = phonemes.map { phoneme_human[$0, default: ""] }
                            self.wordToPhonemesDict[word] = phonemes
                        }
                    }
                }
            } catch {
                print(error)
            }
        }
    }
    
    private func removeNumbersFromStrings(phoneme: String) -> String {
        return phoneme.components(separatedBy: CharacterSet.decimalDigits).joined()
    }
    
    private func removePunctuationFromStrings(phoneme: String) -> String {
        let punctuationSet: CharacterSet = [",", "?", "!", "."]
        return phoneme.components(separatedBy: punctuationSet).joined()
    }
    
    public func sentenceToPhonemes(sentence: String) -> [[String]] {
        var phonemes: [[String]] = []
        let words = sentence.components(separatedBy: " ")
        for word in words {
            let phoneme = wordToPhonemes(word: removePunctuationFromStrings(phoneme: word))
            phonemes.append(phoneme)
            if word.containsPunctuation {
                phonemes.append([""])
            }
        }
        return phonemes
    }

    public func wordToPhonemes(word: String) -> [String] {
        return self.wordToPhonemesDict[word.uppercased(), default: [""]]
    }
}

extension String {
    var isAlphabetic: Bool {
        return !isEmpty && range(of: "[^A-Z]", options: .regularExpression) == nil
    }
    
    var isNumeric: Bool {
        return !isEmpty && rangeOfCharacter(from: .decimalDigits) != nil
    }
    
    var containsPunctuation: Bool {
        let punctuationSet: CharacterSet = [",", "?", "!", "."]
        return !isEmpty && rangeOfCharacter(from: punctuationSet) != nil
    }
}
