//
//  Sheet.swift
//  Profiles
//
//  Created by Stephen Devlin on 05/10/2022.
//

import SwiftUI
import CoreMotion

struct LayFlat: View {

    @StateObject var motion = Motion()
    let limits:MeetingLimits
    
    var body: some View {
        VStack(alignment: .center)
        {
            NavigationLink(destination: MonitorView(limits: limits), isActive: $motion.isFlat,
                           label: { EmptyView() }
            ).navigationBarHidden(true)
                .navigationBarBackButtonHidden(true)

            Spacer()
            Text ("Place phone on the desk\n with the charging port\npointing towards you ")
                .font(.system(size: 22))
                .frame(width:300)
                .multilineTextAlignment(.center)
            Spacer()
            Image("iphoneline")
                .resizable()
                .frame(width: 200, height:200)
                .scaledToFit()
            Spacer()
        }.onAppear(
            perform: {motion.startMonitoring()
            })
    }
    
}
        
        struct Sheet_Previews: PreviewProvider {
            static var previews: some View {
                LayFlat(limits:MeetingLimits.example).preferredColorScheme(.dark)
            }
        }


