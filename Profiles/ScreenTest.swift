//
//  ScreenTest.swift
//  Profiles
//
//  Created by Stephen Devlin on 26/09/2022.
//

import SwiftUI



struct ScreenTest: View {
    var body: some View {

//        ZStack{
            VStack(spacing:0){
                
        Rectangle()
            .fill(Color(.systemGray3))
            .frame(width: 200, height:300)
        
        Rectangle()
            .fill(Color.orange)
            .frame(width: 200, height: 100)
            }
            .mask(RoundedRectangle(cornerRadius:30)
                .frame(width: 200, height: 400))
            
        }


  //  }
}

struct ScreenTest_Previews: PreviewProvider {
    static var previews: some View {
        ScreenTest()
            .preferredColorScheme(.dark)
        
    }
}
