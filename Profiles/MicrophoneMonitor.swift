
//
//  MicrophoneMonitor.swift
//  SoundVisualizer
//
//  Created by Stephen Devlin on 31/08/2022.
//

import Foundation
import AVFoundation
import SoundAnalysis
import DequeModule


var speech:Bool?

class MicrophoneMonitor: ObservableObject {
    
    // 1
    private var audioRecorder: AVAudioRecorder
    private var timer: Timer?
    private let alpha:Float = 0.1
    private let gamma:Float = 0.9

    // 2
    @Published public var peakmix: Float = 0.5
    @Published public var avgmix: Float = 0.5
        
    private let audioEngine: AVAudioEngine = AVAudioEngine()
    private let inputBus: AVAudioNodeBus = AVAudioNodeBus(0)
    private var inputFormat: AVAudioFormat!
    private var streamAnalyzer: SNAudioStreamAnalyzer!
    private let resultsObserver = SoundResultsObserver()
    private let analysisQueue = DispatchQueue(label: "com.example.SoundAnalysisQueue")

    var energyBuffer0: Deque<Float> = []// this is a queue to allow mic levels to be synchronised with sound classifier
    var energyBuffer1: Deque<Float> = []// which is delayed by at least the value of the classification window duration

    init() {
        
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(.record)
            try audioSession.setActive(true)
        } catch {
            fatalError("Failed to configure and activate session.")
        }

        if audioSession.recordPermission != .granted {
            audioSession.requestRecordPermission { (isGranted) in
                if !isGranted {
                    fatalError("You must allow audio recording for this demo to work")
                }
            }
        }

        // need to change this !
        let availableInputs = audioSession.availableInputs
        let builtInMicInput = availableInputs?.first(where: { $0.portType == .builtInMic })
        do {
            try audioSession.setPreferredInput(builtInMicInput)

        } catch {
            print("Unable to set the built-in mic as the preferred input.")
        }
        
        // Make the built-in microphone input the preferred input.
        guard
            let preferredInput = audioSession.preferredInput,
            let dataSources = preferredInput.dataSources
        else
            {
            print ("shit")
            audioRecorder = AVAudioRecorder()  // need to fix this all up !!!!!
            return
        }

        print (dataSources[0].dataSourceName)
        print (dataSources[1].dataSourceName)
        print (dataSources[2].dataSourceName)

        let frontDataSource = dataSources[1] // need to fix this too !
        do {
            try audioSession.preferredInput?.setPreferredDataSource(frontDataSource)
        } catch {
            print("Unable to set preferred datasource.")
        }

        do {
            try audioSession.setPreferredInputOrientation(AVAudioSession.StereoOrientation.landscapeLeft)
            try frontDataSource.setPreferredPolarPattern(.stereo)
            // Update the input orientation to match the current user interface orientation
            } catch {
                fatalError("Unable to select the data source.")
            }
        
        let url = URL(fileURLWithPath: "/dev/null", isDirectory: true)
        
        let recorderSettings: [String:Any] = [
            AVFormatIDKey: NSNumber(value: kAudioFormatAppleLossless),
            AVSampleRateKey: 16000,
            AVNumberOfChannelsKey: 2 ,
            AVLinearPCMBitDepthKey: 16
        ]
                
        inputFormat = audioEngine.inputNode.inputFormat(forBus: inputBus) // Mark 1

        do {
            audioRecorder = try AVAudioRecorder(url: url, settings: recorderSettings)
        } catch {
            fatalError(error.localizedDescription)
        }



        
    }
    
    // 6
    func startMonitoring() {
        audioRecorder.isMeteringEnabled = true
        audioRecorder.record()

        do {
        try audioEngine.start()
        }
        catch{fatalError(error.localizedDescription)}

        audioEngine.inputNode.installTap(onBus: inputBus,
                                             bufferSize: 4096,
                                             format: inputFormat, block: analyzeAudio(buffer:at:))
            
        streamAnalyzer = SNAudioStreamAnalyzer(format: inputFormat)

        do {
            let request = try SNClassifySoundRequest(classifierIdentifier: SNClassifierIdentifier.version1)
            request.windowDuration = CMTimeMakeWithSeconds(1.5, preferredTimescale: 1000)
            request.overlapFactor = 0.5
            try streamAnalyzer.add(request,
                               withObserver: resultsObserver) // Mark 6
        }
        catch
        {
            print ("SNC request failed")
        }
        




        timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true, block: { [weak self] (timer) in
            guard let self = self else { return }
            // 7
            self.audioRecorder.updateMeters()
            self.energyBuffer0.append(self.audioRecorder.peakPower(forChannel: 0))
            self.energyBuffer1.append(self.audioRecorder.peakPower(forChannel: 1))
//            print ("in")
//            print ("raw 0: \(self.audioRecorder.averagePower(forChannel: 0))")


//            let avg0Power = self.audioRecorder.averagePower(forChannel: 0)
//            let avg1Power = self.audioRecorder.averagePower(forChannel: 1)
//            let peak0Power = self.audioRecorder.peakPower(forChannel: 0)
//            let peak1Power = self.audioRecorder.peakPower(forChannel: 1)
//            let avg2Power = self.audioRecorder.peakPower(forChannel: 2)
//            if ((peak1Power > -10 || peak0Power > -10) && speech) {
            //            self.avgmix = (self.alpha * avg0Power / avg1Power) + (self.gamma * self.avgmix)
            //            self.peakmix = (self.alpha * peak0Power / peak1Power) + (self.gamma * self.peakmix)
            //                print("0:    \(avg0Power),    ...  1:    \(avg1Power)")
                if speech != nil
            {
                    let buffer0 = self.energyBuffer0.popFirst() ?? 1.0
                    let buffer1 = self.energyBuffer1.popFirst() ?? 1.0

                    if ((buffer0 > -40 || buffer1 > -40) && speech!) {
//                        self.peakmix =   (self.alpha * buffer0 / buffer1) + (self.gamma * self.peakmix)
                        if (buffer0>buffer1) {
                            self.peakmix = (self.alpha) + (self.gamma * self.peakmix)
                            print ("pos")
                        }else{
                            print ("neg")
                            self.peakmix = (-1 * self.alpha) + (self.gamma * self.peakmix)
                        }
                    
                    } else
                    {
                        print ("0")
                        self.peakmix =   self.gamma * self.peakmix // fade to zero
                    }
                }
        })
    }
    
    func analyzeAudio(buffer: AVAudioBuffer, at time: AVAudioTime) {
        analysisQueue.async {
            self.streamAnalyzer.analyze(buffer,
                                        atAudioFramePosition: time.sampleTime)
        }
    }
    
    // 8
    deinit {
        timer?.invalidate()
        audioRecorder.stop()
    }
    
}
