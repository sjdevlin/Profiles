
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


class MicrophoneMonitor: ObservableObject

{
    
    // 1
    private var audioRecorder: AVAudioRecorder
    private var timer: Timer?
    
    // 2
    private var peakmix: Float = 0.5
    private var avgmix: Float = 0.5
    
    private let audioEngine: AVAudioEngine = AVAudioEngine()
    private let inputBus: AVAudioNodeBus = AVAudioNodeBus(0)
    private var inputFormat: AVAudioFormat!
    private var streamAnalyzer: SNAudioStreamAnalyzer!
    private let resultsObserver = SoundResultsObserver()
    private let analysisQueue = DispatchQueue(label: "com.example.SoundAnalysisQueue")
    
    var energyBuffer0: Deque<Float> = []// this is a queue to allow mic levels to be synchronised with sound classifier
    var energyBuffer1: Deque<Float> = []// which is delayed by at least the value of the classification window duration
    
    // this is the object that updates the view
    @Published var meeting:MeetingData
    
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
        guard let preferredInput = audioSession.preferredInput
        else {
            fatalError("Failed to set preferred input")
        }
        
        guard let dataSources =  preferredInput.dataSources
        else {
            fatalError("Failed to set preferred input")
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
        
        // finally...
        // we create a meeting object that is published
        
        meeting = MeetingData()
        meeting.participant.append(Participant()) // create participant for Coach
        meeting.participant.append(Participant()) // create participant for Client

        
    }
    
    // 6
    func startResumeMonitoring(mode: String) {
        
        audioRecorder.isMeteringEnabled = true
        audioRecorder.record()
        
        do {
            try audioEngine.start()
        }
        catch{fatalError(error.localizedDescription)}
        
        if mode == "Start"
        {
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
        }
        
        timer = Timer.scheduledTimer(withTimeInterval: kInterval, repeats: true, block: { [weak self] (timer) in
            guard let self = self else { return }
            
            self.meeting.elapsedTimeIntervals += 1
            if self.meeting.elapsedTimeIntervals == 60
            {
                self.meeting.elapsedTimeIntervals = 0
                self.meeting.elapsedTimeMins += 1
            }
            
            self.audioRecorder.updateMeters()
            self.energyBuffer0.append(self.audioRecorder.peakPower(forChannel: 0))
            self.energyBuffer1.append(self.audioRecorder.peakPower(forChannel: 1))
            
            if speech != nil
            {
                let buffer0 = self.energyBuffer0.popFirst() ?? -50
                let buffer1 = self.energyBuffer1.popFirst() ?? -50

                if ((buffer0 > -40 || buffer1 > -40) && speech!) {
                    self.peakmix = (self.peakmix * kGamma) + (kAlpha * buffer0/buffer1)
                }
                else
                {
                    self.peakmix =   (self.peakmix * kGamma) + (kAlpha) // fade to zero
                }


                if self.peakmix > kCoachThreshold
                {
//                    print ("Stevie Talking \(self.peakmix)")
                    self.meeting.totalTalkTimeSecs += 1
                    self.meeting.participant[kCoach].isTalking = true
                    self.meeting.participant[kClient].isTalking = false
                    self.meeting.participant[kClient].talkingAccumulator = 0
                    self.meeting.participant[kCoach].talkingAccumulator += 1
                    
                    if self.meeting.participant[kCoach].talkingAccumulator > kTalkThresholdIntervals
                    {
                        print ("Stevie Talking \(self.meeting.participant[kCoach].totalTalkTimeSecs))")
                        self.meeting.participant[kCoach].talkingAccumulator = 0
                        self.meeting.participant[kClient].currentTurnDuration = 0
                        self.meeting.participant[kCoach].currentTurnDuration += 1
                        self.meeting.participant[kCoach].totalTalkTimeSecs += 1
                        self.meeting.participant[kCoach].voiceShare = Float(self.meeting.participant[kCoach].totalTalkTimeSecs) / Float(self.meeting.totalTalkTimeSecs)
                    }

                }
//                else if self.peakmix < kClientThreshold
                else
                {
                            self.meeting.participant[kClient].isTalking = true
                            self.meeting.participant[kCoach].isTalking = false
                            self.meeting.participant[kCoach].talkingAccumulator = 0
                            self.meeting.participant[kClient].talkingAccumulator += 1
                            self.meeting.totalTalkTimeSecs += 1

                            if self.meeting.participant[kClient].talkingAccumulator > kTalkThresholdIntervals
                            {
                                print ("Gerry Talking \(self.meeting.participant[kClient].totalTalkTimeSecs))")
                                self.meeting.participant[kClient].talkingAccumulator = 0
                                self.meeting.participant[kCoach].currentTurnDuration = 0
                                self.meeting.participant[kClient].currentTurnDuration += 1
                                self.meeting.participant[kClient].totalTalkTimeSecs += 1
                                self.meeting.participant[kClient].voiceShare = Float(self.meeting.participant[kClient].totalTalkTimeSecs) / Float(self.meeting.totalTalkTimeSecs)

                            }

                }

            }
        })
    }
    
    func pauseMonitoring() {
        
        audioRecorder.pause()
        audioEngine.pause()
        self.timer?.invalidate()
        print ("Paused")

    }
        
    func stopMonitoring() {
        
        audioRecorder.stop()
        audioEngine.stop()
        self.timer?.invalidate()
        print ("Stopped")

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
