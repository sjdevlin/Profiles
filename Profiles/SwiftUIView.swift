//
//  SwiftUIView.swift
//  Profiles
//
//  Created by Stephen Devlin on 18/09/2022.
//

import SwiftUI

struct TurnView: View
{
    
    let radius: CGFloat = 130
    let pi = Double.pi
    let dotCount = 60
    let dotLength: CGFloat = 5
    let spaceLength: CGFloat
    
    init() {
        let circumerence: CGFloat = CGFloat(2.0 * pi) * radius
        spaceLength = circumerence / CGFloat(dotCount) - dotLength
    }
    
    var body: some View {
        ZStack{
            Circle()
                .trim(from: 0.0, to: 0.85)
                .rotation(.degrees(-90))
                .stroke(Color.white, style: StrokeStyle(lineWidth: 12, lineCap: .butt, lineJoin: .miter, miterLimit: 0, dash: [dotLength, spaceLength], dashPhase: 0))
                .frame(width: radius * 2, height: radius * 2)
            
            Circle()
                .trim(from: 0.85, to: 0.95)
                .rotation(.degrees(-90))
                .stroke(Color.orange, style: StrokeStyle(lineWidth: 12, lineCap: .butt, lineJoin: .miter, miterLimit: 0, dash: [dotLength, spaceLength], dashPhase: 0))
                .frame(width: radius * 2, height: radius * 2)

            VStack {
                Text ("Turn\nLength")
                    .font(.system(size: 32))
                Spacer()
            }
            HStack {
                Text("56 s")
                    .font(.system(size: 72))
                    .foregroundColor(Color.orange)

            }
        }
    }
}

struct TurnView_Previews: PreviewProvider {
    static var previews: some View {
        TurnView()
            .previewInterfaceOrientation(.portraitUpsideDown)
            .preferredColorScheme(.dark)
    }
}
