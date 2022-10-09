//
//  Models.swift
//  Profiles
//
//  Created by Stephen Devlin on 14/09/2022.
//

import Foundation
import SwiftUI

// Struct for storing settings and limits for different types of meeting
struct MeetingLimits: Codable
{
    let  id:UUID
    var  meetingName: String
    var  meetingDurationMins: Int
    var  maxShareVoice: Int
    var  maxTurnLengthSecs: Int
    var  alwaysVisible: Bool
    
    static let example = MeetingLimits(meetingName: "Interview", meetingDurationMins: 45, maxShareVoice: 35, maxTurnLengthSecs: 60, alwaysVisible: false)
    
    init(meetingName: String, meetingDurationMins: Int, maxShareVoice: Int, maxTurnLengthSecs: Int, alwaysVisible: Bool)
    {
        self.id = UUID()
        self.meetingName = meetingName
        self.meetingDurationMins = meetingDurationMins
        self.maxShareVoice = maxShareVoice
        self.maxTurnLengthSecs = maxTurnLengthSecs
        self.alwaysVisible = alwaysVisible
    }
}

struct Participant {
    var isTalking:Bool = false
    var numTurns: Int = 1 //  Need to check this
    var currentTurnDuration: Int = 0
    var talkingAccumulator: Int = 0
    var totalTalkTimeSecs: Int = 0
    var voiceShare:Float = 0.5
}

struct Turn: Identifiable {
    var id: UUID
    var talker:Int
    var turnLengthSecs: Int
    var coachShare:Float

    init(talker:Int, turnLengthSecs:Int, coachShare:Float)
    {
        self.id = UUID()
        self.talker = talker
        self.turnLengthSecs = turnLengthSecs
        self.coachShare = coachShare
    }
}

struct MeetingData {
    let id:UUID
    var participant:[Participant]
    var lastTalker: Int = kCoach
    var history:[Turn] = []
    var elapsedTimeIntervals:Int = 0
    var elapsedTimeMins:Int = 0
    var totalTalkTimeSecs:Int = 0
    
    // the following example static constants are just so we can use previews
    
    static let exampleParticipant = [Participant(isTalking: true, numTurns: 5, currentTurnDuration: 44,
                                                talkingAccumulator: 0, totalTalkTimeSecs: 456, voiceShare: 0.34),
                                     Participant(isTalking: false, numTurns: 5, currentTurnDuration: 0,  talkingAccumulator: 0, totalTalkTimeSecs: 999, voiceShare: 0.66)
    ]

    static let exampleHistory = [Turn(talker: 0, turnLengthSecs: 12, coachShare: 1),Turn(talker: 1, turnLengthSecs: 22, coachShare: 0.4), Turn(talker: 0, turnLengthSecs: 6, coachShare: 0.6),Turn(talker: 1, turnLengthSecs: 32, coachShare: 0.5),Turn(talker: 0, turnLengthSecs: 8, coachShare: 0.4),Turn(talker: 1, turnLengthSecs: 75, coachShare: 0.3),Turn(talker: 0, turnLengthSecs: 32, coachShare: 0.35),Turn(talker: 1, turnLengthSecs: 8, coachShare: 0.25),Turn(talker: 0, turnLengthSecs: 14, coachShare: 0.3),Turn(talker: 1, turnLengthSecs: 62, coachShare: 0.27), Turn(talker: 0, turnLengthSecs: 30, coachShare: 0.3)
    ]

    static let example = MeetingData(participant:exampleParticipant, history: exampleHistory, elapsedTime: 48)

    
    init(participant:[Participant] = [], history:[Turn] = [])
    {
        self.elapsedTimeIntervals = 0
        self.elapsedTimeMins = 0
        self.id = UUID()
        self.participant = participant
        self.history = history
    }
    
    init(participant:[Participant] = [], history:[Turn] = [], elapsedTime:Int)
    {
        self.elapsedTimeIntervals = 0
        self.elapsedTimeMins = elapsedTime
        self.id = UUID()
        self.participant = participant
        self.history = history
    }

}

// Save and retrieve meeting limit data

func updateMeetingLimits(updatedMeetingLimits: MeetingLimits){
    
    let jsonMeetingLimits = UserDefaults.standard.object(forKey: "userMeetingLimits") as? Data
    let decoder = JSONDecoder()
    var userMeetingLimits: [MeetingLimits] = [] // put this into the catch below
    
    do { try userMeetingLimits = decoder.decode([MeetingLimits].self, from: jsonMeetingLimits!)}
    catch {print("Err")}
    
    if let row = userMeetingLimits.firstIndex(where: {$0.id == updatedMeetingLimits.id}) {
        userMeetingLimits[row] = updatedMeetingLimits  // can i do this simpler?
    } else {userMeetingLimits.append(updatedMeetingLimits)}
    
    let encoder = JSONEncoder()
    do {let jsonMeetingLimits = try encoder.encode(userMeetingLimits)
        UserDefaults.standard.set(jsonMeetingLimits, forKey: "userMeetingLimits")
    }catch {print("err")}
    
}

func saveMeetingLimits(meetingLimits: [MeetingLimits]){
    
    let encoder = JSONEncoder()
    do {let jsonMeetingLimits = try encoder.encode(meetingLimits)
        UserDefaults.standard.set(jsonMeetingLimits, forKey: "userMeetingLimits")
    }catch {print("err")}
    
}

//retrieve data method
//sets defaults if there is no data stored (usually only at first run)

func getMeetingLimits() -> [MeetingLimits]{
    
    guard let jsonMeetingLimits = UserDefaults.standard.object(forKey: "userMeetingLimits") as? Data else
    
    // no data returned.  So set to default and save
    {
        let userMeetingLimits = defaultMeetingData()
        saveMeetingLimits(meetingLimits: userMeetingLimits)
        return(userMeetingLimits)}
    
    // data returned in json format, so decode and return
    do{
        let decoder = JSONDecoder()
        let userMeetingLimits = try decoder.decode([MeetingLimits].self, from: jsonMeetingLimits)
        return userMeetingLimits
    }catch {
        return([])
    }
}

func defaultMeetingData() -> [MeetingLimits]{
    
    var defaultMeetingLimits:[MeetingLimits] = []
    
    defaultMeetingLimits.append(MeetingLimits(meetingName: "Interview", meetingDurationMins: 45, maxShareVoice: 30, maxTurnLengthSecs: 90, alwaysVisible: true))
    defaultMeetingLimits.append(MeetingLimits(meetingName: "Appraisal", meetingDurationMins: 60, maxShareVoice: 60, maxTurnLengthSecs: 180, alwaysVisible: false))
    defaultMeetingLimits.append(MeetingLimits(meetingName: "Counselling Session", meetingDurationMins: 50, maxShareVoice: 20, maxTurnLengthSecs: 60, alwaysVisible: false))
    
    return(defaultMeetingLimits)
}
