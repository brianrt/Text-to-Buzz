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
    var phonemes = ["ah", "a", "uh", "awe", "ow", "I", "e", "er", "A", "i", "E", "O", "oy", "uu", "oo", "b", "ch", "d", "thh", "f", "g", "h", "j", "k", "l", "m", "n", "ng", "p", "r", "s", "sh", "t", "th", "v", "w", "y", "z", "shz"]
    var vowels = ["ah", "a", "uh", "awe", "ow", "I", "e", "er", "A", "i", "E", "O", "oy", "uu", "oo"]
    let phoneme_human: Dictionary<String, String> = ["AA": "ah", "AE": "a", "AH": "uh", "AO": "awe", "AW": "ow", "AY": "I", "EH": "e", "ER": "er", "EY": "A", "IH": "i", "IY": "E", "OW": "O", "OY": "oy", "UH": "uu", "UW": "oo", "B": "b", "CH": "ch", "D": "d", "DH": "thh", "F": "f", "G": "g", "HH": "h", "JH": "j", "K": "k", "L": "l", "M": "m", "N": "n", "NG": "ng", "P": "p", "R": "r", "S": "s", "SH": "sh", "T": "t", "TH": "th", "V": "v", "W": "w", "Y": "y", "Z": "z", "ZH": "shz"]
    
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
                            phonemes = phonemes.map { removeNumbersFromStrings(word: $0) }
                            // Replace phonemes with human readable ones
                            phonemes = phonemes.map { phoneme_human[$0, default: ""] }
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
    
    private func removeNumbersFromStrings(word: String) -> String {
        return word.components(separatedBy: CharacterSet.decimalDigits).joined()
    }
    
    private func replaceApostropheWithSingleQuote(word: String) -> String {
        return word.replacingOccurrences(of: "’", with: "\'", options: .literal, range: nil)
    }
    
    private func removePunctuationFromStrings(word: String) -> String {
        let punctuationSet: CharacterSet = [",", "?", "!", "."]
        return word.components(separatedBy: punctuationSet).joined()
    }
    
    private func extractPunctuation(word: String) -> String {
        let punctuationSet: CharacterSet = [",", "?", "!", "."]
        return word.components(separatedBy: punctuationSet.inverted).joined()
    }
    
    public func sentenceToPhonemes(sentence: String) -> [(String,[String])] {
        var sentencePhonemes: [(String,[String])] = []
        let words = sentence.components(separatedBy: " ")
        for word in words {
            let wordPhonemes = wordToPhonemes(word: removePunctuationFromStrings(word: word))
            sentencePhonemes.append((word,wordPhonemes))
            if word.containsPunctuation {
                sentencePhonemes.append((extractPunctuation(word: word),[""]))
            }
        }
        return sentencePhonemes
    }

    public func wordToPhonemes(word: String) -> [String] {
        // iOS keyboard uses apostrophe whereas phonemes_dict uses single quote
        let word_uppercased = replaceApostropheWithSingleQuote(word: word).uppercased()
        var wordPhonemes = self.wordToPhonemesDict[word_uppercased, default: [""]]
        wordPhonemes.append("")
        return wordPhonemes
    }
    
    public func isVowel(phoneme: String) -> Bool {
        return vowels.contains(phoneme)
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
