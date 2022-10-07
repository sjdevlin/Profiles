//
//  SoundResultsObserver.swift
//  SoundVisualizer
//
//  Created by Stephen Devlin on 03/09/2022.
//

import Foundation
import SoundAnalysis

class SoundResultsObserver: NSObject, SNResultsObserving {
    
    func request(_ request: SNRequest, didProduce result: SNResult) {
        
        guard let result = result as? SNClassificationResult else { return }
        
        guard let classification = result.classifications.first else { return }
                
//     let confidence = classification.confidence * 100.0
//       let percentString = String(format: "%.2f%%", confidence)
//        print("\(classification.identifier): \(percentString) confidence.\n")

        if (classification.identifier == "speech" && classification.confidence > kSpeechClassifierThreshold) {
            speech = true
            // currently I just use a global bool to share the output
            // this could be improved - not sure how best to do it
        }
        else{
            speech = false
        }
    }
    
    func request(_ request: SNRequest, didFailWithError error: Error) {
        print("The the analysis failed: \(error.localizedDescription)")
    }
    
    func requestDidComplete(_ request: SNRequest) {
        print("The request completed successfully!")
    }
}
