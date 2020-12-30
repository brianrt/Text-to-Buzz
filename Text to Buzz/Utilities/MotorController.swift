//
//  MotorController.swift
//  Text to Buzz
//
//  Created by Brian Thompson on 12/27/20.
//

import Foundation

class MotorController: NSObject {
    
    var phonemeToIntensities: Dictionary<String, [UInt8]> = [:]
    let NUM_MOTOR_INTENSITIES = 256
    let NUM_MOTORS = 4
    let NUM_STATES = 4294967296
    let NUM_PHONEMES = 39
    let PADDING = 1
    
    init(phonemes: [String]) {
        super.init()
        calculateIntensities(phonemes: phonemes)
    }
    
    private func calculateIntensities(phonemes: [String]) {
        let total_num_values = NUM_PHONEMES + (2 * PADDING)
        var count = 0
        for raw_value in stride(from: 0, through: NUM_STATES, by: Int(NUM_STATES / total_num_values)) {
            if (count >= PADDING) && (count < total_num_values - PADDING) {
                let index = count - PADDING
                let motorValues = decimalToBase256(value: raw_value)
                phonemeToIntensities[phonemes[index]] = motorValues
            }
            count += 1
        }
    }
    
    private func decimalToBase256(value: Int) -> [UInt8]{
        if (value == 0) {
            return [0,0,0,0]
        }
        var number = value
        var remainder = 0
        var motorValues: [UInt8] = []
        while (number > 0) {
            remainder = number % NUM_MOTOR_INTENSITIES
            number = Int(number / NUM_MOTOR_INTENSITIES)
            motorValues.insert(UInt8(remainder), at: 0)
            
        }
        return motorValues
    }
    
    public func getIntensities(phoneme: String) -> [UInt8] {
        return self.phonemeToIntensities[phoneme, default: [0,0,0,0]]
    }
    
    
}
