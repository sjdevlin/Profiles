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

let kRectangleWidth:CGFloat = UIScreen.main.bounds.width * 0.6
let kRectangleHeight:CGFloat = UIScreen.main.bounds.height * 0.6

let kShareRectangleWidth = UIScreen.main.bounds.width * 0.6
let kShareRadius:CGFloat = 30.0

let kShareArc:CGFloat = 350
var kShareTangentPoint:CGFloat = pow((UIScreen.main.bounds.width / 2),2) / ((pow(kShareArc,2) - pow((UIScreen.main.bounds.width / 2),2)).squareRoot())



let kCoachThreshold:Float = 1.0 // volume difference across stereo mics that indicate which speaker...
let kClientThreshold:Float = 0.95 // ...eventually these needs to be dynamically calculated

let kIntervalsPerSecond = Int(1.0/kInterval) // Samples per second

let kMinimumDBThreshold:Float = -40
let kSpeechClassifierThreshold:Double = 0.6

let kAlpha:Float = 0.2 // this is the low pass filter used in the signal to smooth
let kGamma:Float = 1 - kAlpha

var speech:Bool? // this is only non-nil after first results from classification queue
// done like this so that we know when to start popping items from the stack without trying
//to guess the time lag in classification window + processing delay
