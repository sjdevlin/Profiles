//
//  test.swift
//  Profiles
//
//  Created by Stephen Devlin on 27/09/2022.
//

import SwiftUI

struct test: View {
    var body: some View {
 //       let percentageRemaining = 0.04
   //     let percentageGone:CGFloat = 1 - percentageRemaining
        let radius = 30.0
        let goneRectangle:CGFloat = 20
        let remainRectangle:CGFloat = 430

        VStack(spacing:0){

                    Rectangle()
            .fill(Color(.systemGray3))
            .frame(width: goneRectangle > radius ? kRectangleWidth:kRectangleWidth-10 , height:goneRectangle )
            .padding(.bottom,remainRectangle > radius ? radius: remainRectangle)
            .cornerRadius(radius)
            .padding(.bottom,remainRectangle > radius ? -radius: -remainRectangle)
        
        Rectangle()
            .fill(Color.orange)
            .frame(width: remainRectangle > radius ? kRectangleWidth:kRectangleWidth-10 , height:( remainRectangle))
            .padding(.top,goneRectangle > radius ? radius : goneRectangle)
            .cornerRadius(radius)
            .padding(.top,goneRectangle > radius ? -radius : -goneRectangle)
        }




    }
}

struct test_Previews: PreviewProvider {
    static var previews: some View {
        test()
    }
}
