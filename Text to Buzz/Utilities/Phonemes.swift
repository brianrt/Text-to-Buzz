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
                            self.wordToPhonemesDict[word] = phonemes
                        }
                    }
                }
                print("done")
            } catch {
                print(error)
            }
        }
    }
    
    private func removeNumbersFromStrings(phoneme: String) -> String {
        return phoneme.components(separatedBy: CharacterSet.decimalDigits).joined()
    }
    
//    public func sentenceToPhonemes(sentence: String) -> [[String]] {
//
//    }
//
    public func wordToPhonemes(word: String) -> [String] {
        return self.wordToPhonemesDict[word.uppercased()]!
    }
}

extension String {
    var isAlphabetic: Bool {
        return !isEmpty && range(of: "[^A-Z]", options: .regularExpression) == nil
    }
    
    var isNumeric: Bool {
        return !isEmpty && rangeOfCharacter(from: .decimalDigits) != nil
    }
}
