//
//  Models.swift
//  Profiles
//
//  Created by Stephen Devlin on 14/09/2022.
//

import Foundation

// Struct for storing settings and limits for different types of meeting
/*class MeetingLimits: ObservableObject, Codable {
    
    let  meetingName: String
    var  meetingDurationMins: Int
    var  maxShareVoice: Float
    var  maxTurnLengthSecs: Int
    var  alwaysVisible: Bool
    
    init(meetingName: String, meetingDurationMins: Int, maxShareVoice: Float, maxTurnLengthSecs: Int, alwaysVisible: Bool) {
        self.meetingName = meetingName
        self.meetingDurationMins = meetingDurationMins
        self.maxShareVoice = maxShareVoice
        self.maxTurnLengthSecs = maxTurnLengthSecs
        self.alwaysVisible = alwaysVisible
    }

    
}


// Save and retrieve meeting limit data

func saveMeetingLimits(meetingLimits: [MeetingLimits]){
    do{
        let encoder = JSONEncoder()
        let jsonMeetingLimits = try encoder.encode(meetingLimits)
        UserDefaults.standard.set(jsonMeetingLimits, forKey: "userMeetingLimits")
    }catch let err{
        print(err)
    }
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
    
    defaultMeetingLimits.append(MeetingLimits(meetingName: "Interview", meetingDurationMins: 45, maxShareVoice: 0.3, maxTurnLengthSecs: 90, alwaysVisible: true))
    defaultMeetingLimits.append(MeetingLimits(meetingName: "Appraisal", meetingDurationMins: 60, maxShareVoice: 0.6, maxTurnLengthSecs: 180, alwaysVisible: false))
    defaultMeetingLimits.append(MeetingLimits(meetingName: "Counselling Session", meetingDurationMins: 50, maxShareVoice: 0.2, maxTurnLengthSecs: 60, alwaysVisible: false))

    return(defaultMeetingLimits)
}
*/
