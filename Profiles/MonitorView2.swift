//
//  MonitorView2.swift
//  Profiles
//
//  Created by Stephen Devlin on 18/09/2022.
//

import SwiftUI

//struct RoundedCorner: Shape {
//
//    var radius: CGFloat = .infinity
//    var corners: UIRectCorner = .allCorners
//
//    func path(in rect: CGRect) -> Path {
//        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
//        return Path(path.cgPath)
//    }
//}

struct MonitorView: View {

    @ObservedObject var mic = MicrophoneMonitor()
    @State var meeting = MeetingData()
    @State var isListening = false

    init () {
        mic.startMonitoring()
    }
    
    var body: some View {
        TabView{
            TimeView()
            ShareView()
            TurnView()
        }.tabViewStyle(.page)
    }
}
struct TimeView: View {
    let radius = 40.0
    var body: some View {
        VStack(spacing:0){
            HStack {
                Text ("Minutes\nRemaining")
                    .font(.system(size: 32))
                Spacer()
                Text("2")
                    .font(.system(size: 72))
                    .foregroundColor(Color.red)
                Spacer()
            }.padding([.leading], 30)

            Spacer()
        Rectangle()
                .fill(Color(.systemGray3))
            .frame(width: 250, height:300)
            .padding(.bottom,radius)
            .cornerRadius(radius)
            .padding(.bottom,-radius)

            Rectangle()
                .fill(Color(.lightGray))
            .frame(width: 250, height:200)
            .padding(.top,radius)
            .cornerRadius(radius)
            .padding(.top,-radius)
            Spacer()
        }
        
    }
}

struct ShareView: View {
    let radius = 30.0
    var body: some View {
        VStack(spacing:0){
            HStack {
                Text ("Voice\nShare")
                    .font(.system(size: 32))
                Spacer()
                Text("2")
                    .font(.system(size: 72))
                    .foregroundColor(Color.red)
                Spacer()
            }.padding([.leading], 30)

            Spacer()
        Rectangle()
                .fill(Color(.systemGray3))
            .frame(width: 250, height:300)
            .padding(.bottom,radius)
            .cornerRadius(radius)
            .padding(.bottom,-radius)
        Rectangle()
                .fill(Color(.lightGray))
            .frame(width: 250, height:200)
            .padding(.top,radius)
            .cornerRadius(radius)
            .padding(.top,-radius)
            Spacer()
        }
        
    }
}

struct MonitorView_Previews: PreviewProvider {
    static var previews: some View {
        MonitorView()
            .previewInterfaceOrientation(.portraitUpsideDown)
            .preferredColorScheme(.dark)

    }
}

//struct TurnView: View
//{
//    
//    let radius: CGFloat = 150
//    let pi = Double.pi
//    let dotCount = 60
//    let dotLength: CGFloat = 5
//    let spaceLength: CGFloat
//    
//    init() {
//        let circumerence: CGFloat = CGFloat(2.0 * pi) * radius
//        spaceLength = circumerence / CGFloat(dotCount) - dotLength
//    }
//    
//    var body: some View {
//        Circle()
//            .stroke(Color.blue, style: StrokeStyle(lineWidth: 6, lineCap: .butt, lineJoin: .miter, miterLimit: 0, dash: [dotLength, spaceLength], dashPhase: 0))
//            .frame(width: radius * 2, height: radius * 2)
//    }
//}
