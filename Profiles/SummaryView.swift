//
//  SummaryView.swift
//  Profiles
//
//  Created by Stephen Devlin on 25/09/2022.
//

import SwiftUI

struct SummaryView: View {
    let meeting: MeetingData
    var body: some View {
        VStack (spacing:0){
            Text("Turn History").font(.system(size: 24))
            HStack {
                Spacer()
                Text ("You").font(.system(size: 20))
                Spacer()
                Spacer()
                Spacer()
                Text ("Them").font(.system(size: 20))
                Spacer()
            }.frame(height: 50)
                .padding()
            VStack (spacing:0){
                ForEach (meeting.history) { turn in
                    Rectangle ()
                        .fill(turn.talker == kCoach ? Color(.lightGray):Color.cyan)
                        .frame(width:CGFloat(turn.turnLengthSecs), height:CGFloat(200/meeting.history.count ))
                        .position(x: (turn.talker == kCoach ?  CGFloat(200 - (turn.turnLengthSecs/2)):CGFloat(200 + turn.turnLengthSecs/2)))
                }}.frame(width: 400, height: 200, alignment: .leading)
            
            Text ("Meeting Duration").font(.system(size: 20))
        }.navigationBarTitle("Meeting Summary", displayMode: .inline)
        
    }
}

