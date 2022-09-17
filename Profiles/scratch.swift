//
//  scratch.swift
//  Profiles
//
//  Created by Stephen Devlin on 16/09/2022.
//

import Foundation
//
//  MeetingDetail.swift
//  Profiles
//
//  Created by Stephen Devlin on 13/09/2022.
//

import SwiftUI

struct IntDoubleBinding {
    let intValue : Binding<Int>
    
    let doubleValue : Binding<Double>
    
    init(_ intValue : Binding<Int>) {
        self.intValue = intValue
        
        self.doubleValue = Binding<Double>(get: {
            return Double(intValue.wrappedValue)
        }, set: {
            intValue.wrappedValue = Int($0)
        })
    }
}


struct DetailView: View
{
    
    @State var score:Int = 0
    
    @Binding var limits: MeetingLimits
    @State private var isEditing = false
    
    let meetingDurationOptionList = [15,20,30,45,50,60]
    let turnDurationOptionList = [30,45,60,90,120]
    let maxShareVoiceOptionList = [15,25,50,75,100]
    
    var body: some View
    {
        VStack
        {
            if isEditing == true
            {TextField("",text:$limits.meetingName)
                            .font(Font.system(size: 20))
                            .frame(alignment: .center)
            }
            else
            {
            Text(limits.meetingName)
                                .font(Font.system(size: 20))
                                .frame(alignment: .center)
            }

            
            Text(limits.meetingDurationMins)
            
            if isEditing == true
            {
                Slider(value: IntDoubleBinding($limits.meetingDurationMins).doubleValue, in: 10...90.0, step: 5.0)
            }
                    Section
                    {
                        Picker("Maximum voice share", selection: $limits.maxShareVoice)
                        {
                            ForEach(maxShareVoiceOptionList, id:\.self){Text("\($0)")}
                        }
                        .pickerStyle(.segmented)
                    }
                    header :
                    {
                        Text ("Maximum voice share (%)")
                            .font(.system(size: 16))
                    }
                    
                    Section
                    {
                        Picker("Meeting Duration", selection: $limits.meetingDurationMins) {
                            ForEach(meetingDurationOptionList, id:\.self){Text("\($0)")}
                        }
                            .pickerStyle(.segmented)
                    }
                    header :
                    {
                        Text ("Meeting Duration (Minutes)")
                            .font(.system(size: 16))
                        
                    }
                    .listRowBackground(isEditing ? Color.gray : Color.clear)
                    .foregroundColor(isEditing ? Color.white : Color.orange)
                    
                    Section
                    {
                        Picker("Maximum Turn Length", selection: $limits.maxTurnLengthSecs) {
                            ForEach(turnDurationOptionList, id:\.self){Text("\($0)")}
                        }.disabled(!self.isEditing)
                            .pickerStyle(.segmented)
                    }
                    header :
                    {
                        Text ("Maximum Turn Length (Seconds)")
                            .font(.system(size: 16))
                    }
                    .listRowBackground(isEditing ? Color.gray : Color.clear)
                    .foregroundColor(isEditing ? Color.white : Color.orange)
                    
                    Toggle("Always Visible", isOn: $limits.alwaysVisible).disabled(!self.isEditing)
                        .listRowBackground(Color.cyan)
                        .foregroundColor(isEditing ? Color.white : Color.orange)
                    
                    
                
            }
            
            Button{print ("button")} label:
            {
                Text ("Start").font(.system(size: 28).bold())
                    .foregroundColor(Color.white)
                    .frame(minWidth: 200, minHeight: 60)
            }
            .background(RoundedRectangle(cornerRadius: 8).fill(Color.red))
            
        }
        .navigationBarItems(trailing: Button(isEditing ? "Save" : "Edit")
                            {
            if self.isEditing == true
            {
                updateMeetingLimits(updatedMeetingLimits: limits)
                self.isEditing = false
            } else
            {
                self.isEditing = true
            }
        })
        
        
    }
}
/*
 struct DetailView_Previews: PreviewProvider {
 static var previews: some View {
 DetailView(limits: MeetingLimits)
 }
 }*/
