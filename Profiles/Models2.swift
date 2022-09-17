//
//  Models.swift
//  Profiles
//
//  Created by Stephen Devlin on 14/09/2022.
//

import Foundation
import SwiftUI

// Struct for storing settings and limits for different types of meeting
struct MeetingLimits: Codable {
    let  id:UUID
    var  meetingName: String
    var  meetingDurationMins: Int
    var  maxShareVoice: Int
    var  maxTurnLengthSecs: Int
    var  alwaysVisible: Bool
    
    init(meetingName: String, meetingDurationMins: Int, maxShareVoice: Int, maxTurnLengthSecs: Int, alwaysVisible: Bool) {
        self.id = UUID()
        self.meetingName = meetingName
        self.meetingDurationMins = meetingDurationMins
        self.maxShareVoice = maxShareVoice
        self.maxTurnLengthSecs = maxTurnLengthSecs
        self.alwaysVisible = alwaysVisible
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
