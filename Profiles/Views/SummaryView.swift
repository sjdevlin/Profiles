//
//  SummaryView.swift
//  Profiles
//
//  Created by Stephen Devlin on 25/09/2022.
//

import SwiftUI

struct SummaryView: View {
    let meeting: MeetingData
    let limits: MeetingLimits
    
    var body: some View {
        NavigationView{
            VStack {
                Text("Meeting Summary").font(.system(size: 24))
                    .padding(.top, 10)
                    .padding(.bottom, 30)
                
                Divider()
                    .frame(height:2)
                    .overlay(Color(.lightGray))
                
                ScrollView{
                    
                    HStack {
                        Spacer()
                        VStack(alignment: .leading){
                            Text ("Meeting Type:").font(.system(size: 24))
                                .padding(.bottom, 20)
                            Text ("Duration:").font(.system(size: 24))
                        }
                        Spacer()
                        VStack(alignment: .trailing){
                            Text (limits.meetingName).font(.system(size: 24))
                                .padding(.bottom, 20)
                            Text ("\(meeting.elapsedTimeMins) mins").font(.system(size: 24))
                        }
                        Spacer()
                    }.padding(.top, 30)
                    
                    
                    Text("Voice Share").font(.system(size: 24))
                        .padding(.top, 40)
                        .padding(.bottom, 20)
                    
                    
                    
                    HStack (alignment: .bottom, spacing:0 ){
                        ForEach (meeting.history) { turn in
                            
                            Rectangle ()
                                .fill(turn.coachShare > Float(limits.maxShareVoice)/100.0 ? Color.red:Color.cyan)
                                .frame(width:CGFloat(200/meeting.history.count ), height:CGFloat(100 * turn.coachShare))
                        }
                        
                    }
                    
                    
                    
                    
                    
                    Text("Turn History").font(.system(size: 24))
                        .padding(.top, 40)
                    HStack {
                        Spacer()
                        Text ("Coach").font(.system(size: 22))
                            .foregroundColor(Color.cyan)
                        Spacer()
                        Spacer()
                        Text ("Client").font(.system(size: 22))
                        Spacer()
                    }.padding(.top, 20)
                    
                    VStack (spacing:0){
                        ForEach (meeting.history) { turn in
                            Rectangle ()
                                .fill(turn.talker == kCoach ? (turn.turnLengthSecs > limits.maxTurnLengthSecs ? Color.red:Color.cyan):Color.white)
                                .frame(width:CGFloat(turn.turnLengthSecs), height:CGFloat(200/meeting.history.count ))
                                .position(x: (turn.talker == kCoach ?  CGFloat(200 - (turn.turnLengthSecs/2)):CGFloat(200 + turn.turnLengthSecs/2)))
                        }}.frame(width: 400, height: 200, alignment: .leading)
                    
                    HStack {
                        Spacer()
                        Spacer()
                    }.frame(height: 10)
                        .padding(.top ,10 )
                    HStack {
                        Spacer()
                        Text (String(meeting.participant[kCoach].totalTalkTimeSecs / meeting.participant[kCoach].numTurns) + " s").font(.system(size: 24))
                            .foregroundColor(Color.cyan)
                        Spacer()
                        Text ("Average\nturn length").font(.system(size: 20))
                        Spacer()
                        Text (String(meeting.participant[kClient].totalTalkTimeSecs / meeting.participant[kClient].numTurns) + " s").font(.system(size: 24))
                            .foregroundColor(Color.white)
                        Spacer()
                    }
                    .multilineTextAlignment(.center)
                    .padding()
                    
                    
                }
                
            }  .toolbar {
                // 1
                ToolbarItem(placement: .navigationBarLeading) {
                    
                    NavigationLink("Done", destination: ContentView()) 
                    
                }
                
            }
        }
        
    }
}
struct SummaryView_Previews: PreviewProvider {
    static var previews: some View {
        
        SummaryView(meeting: MeetingData.example, limits: MeetingLimits.example)
            .preferredColorScheme(.dark)
        
    }
}

