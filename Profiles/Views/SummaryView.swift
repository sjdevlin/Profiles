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
    @EnvironmentObject var appState: AppState
    
    var body: some View {
        VStack {
            Text ("Meeting Summary")
                .font(.system(size: 26))
            
            Divider()
                .frame(height:2)
                .overlay(Color(.lightGray))
                .navigationBarTitle("Meeting Summary", displayMode: .inline)
                .padding(.top, 10)
                .padding(.bottom, 30)
            
            
            ScrollView
            {VStack {
                
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
                    .padding(.bottom, 20)
                
                VStack (spacing:0){
                    ForEach (meeting.history) { turn in
                        Rectangle ()
                            .fill(turn.talker == kCoach ? (turn.turnLengthSecs > limits.maxTurnLengthSecs ? Color.red:Color.cyan):Color.white)
                            .frame(width:CGFloat(turn.turnLengthSecs*5), height:CGFloat(200/meeting.history.count ))
                            .position(x: (turn.talker == kCoach ?  CGFloat(200 - ((turn.turnLengthSecs*5)/2)):CGFloat(200 + (turn.turnLengthSecs*5)/2)))
                    }}.frame(width: 400, height: 200, alignment: .leading)
                    .padding(.top, 20)
                
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
                
                
            }}
            Spacer()
            Button("Done", action: {appState.rootViewId = UUID()})
                .font(.system(size:24))
                .padding(.top, 10)
                .padding(.bottom, 10)
                .padding(.leading, 30)
                .padding(.trailing, 30)
                .foregroundColor(.white)
                .background(Color(.orange))
                .clipShape(Capsule())
                .padding(.top, 20)

            
            //                NavigationLink(destination: ContentView()) {
            //                    Text("Done")
            //                        .font(Font.system(size: 24))
            //                        .foregroundColor(.white)
            //                        .padding()
            //                        .background(Color(.orange))
            //                        .clipShape(Capsule())
            //                        .padding(.top, 30)}
            

            }.navigationBarBackButtonHidden(true)
            .navigationBarHidden(true)

    }
}
struct SummaryView_Previews: PreviewProvider {
    static var previews: some View {
        
        SummaryView(meeting: MeetingData.example, limits: MeetingLimits.example)
            .preferredColorScheme(.dark)
        
    }
}

