//
//  Constants.swift
//  Profiles
//
//  Created by Stephen Devlin on 22/09/2022.
//

import SwiftUI

let kInterval = 0.1  // how often audio levels are checked
let kAmber = 0.85 // how close to limit before alert is triggered

let kCoach = 0 // the meeting organiser
let kClient = 1 // the other person

let kRectangleWidth:CGFloat = UIScreen.main.bounds.width * 0.52
let kRectangleHeight:CGFloat = UIScreen.main.bounds.height * 0.52

let kShareRectangleWidth = kRectangleWidth
let kShareRadius:CGFloat = 30.0

let kCoachThreshold:Float = 1.0 // volume difference across stereo mics that indicate which speaker...
let kClientThreshold:Float = 0.95 // ...eventually these needs to be dynamically calculated

let kTalkThresholdIntervals = Int(1.0/kInterval) // granularity of talking is seconds.  So this is related to how often we sample.

// this is the low pass filter used in the signal to smooth
let kAlpha:Float = 0.2
let kGamma:Float = 1 - kAlpha
