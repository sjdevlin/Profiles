//
//  Motion Checker.swift
//  Profiles
//
//  Created by Stephen Devlin on 06/10/2022.
//

import Foundation
import CoreMotion

class Motion:ObservableObject {
    var motionManager: CMMotionManager!
    @Published var isFlat:Bool = false
    var newz:Double = 0.0
    var oldz:Double = 0.0
    var difference:Double = 1.0
    var motionTimer: Timer?
    
    
    init() {
        motionManager = CMMotionManager()
        motionManager.startAccelerometerUpdates()
    }
    
    func position() -> Double
    {
        if let accelerometerData = motionManager.accelerometerData
        {
            return (accelerometerData.acceleration.z)
            
        }
        else
        {
            return (0.0)
        }
    }
    
    func startMonitoring() {
        motionTimer = Timer.scheduledTimer(withTimeInterval: 0.01, repeats: true, block: { [weak self] (timer) in
            
            guard let self = self else { return }

            self.newz = self.position()
            self.difference = (0.9 * self.difference) + (0.1 * (self.newz - self.oldz))
            self.oldz = self.newz
            if ( abs(self.difference) < 0.0001 && self.newz > -0.997 && self.newz < -0.994)
            {
                self.motionManager.stopAccelerometerUpdates()
                self.isFlat = true
                self.motionTimer?.invalidate()
                
            }
        })
        
    }
}
