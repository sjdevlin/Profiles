
//
//  MicrophoneMonitor.swift
//  SoundVisualizer
//
//  Created by Stephen Devlin on 31/08/2022.
//

import Foundation
import AVFoundation
import SoundAnalysis
import DequeModule  // used for lifo stack


class MicrophoneMonitor: ObservableObject

{
    private var audioRecorder: AVAudioRecorder
    private var timer: Timer?
    

    private var peakmix: Float = 1.0 // initialise stereo field at 1 (equal balance)
    // peak values used rather than average as these seemed to provide better stereo separation
    
    private let audioEngine: AVAudioEngine = AVAudioEngine()
    private let inputBus: AVAudioNodeBus = AVAudioNodeBus(0)
    private var inputFormat: AVAudioFormat!
    private var streamAnalyzer: SNAudioStreamAnalyzer!
    private let resultsObserver = SoundResultsObserver()

    // sound classification is performed asynchronously in this queue
    private let analysisQueue = DispatchQueue(label: "com.example.SoundAnalysisQueue")
    
    // this is a queue to allow mic levels to be synchronised with sound classifier
    // which is delayed by at least the value of the classification window duration
    private var energyBufferClient: Deque<Float> = []
    private var energyBufferCoach: Deque<Float> = []

    private var currentTalker:Int = kCoach
    private var currentListener:Int = kClient

    
    
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
        
        // need to check if this is robust
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
        
        // +++++++++++++++++++++++++++++++++
        // !!! this area needs rewrite.  I currently can't seem to find frontdata source
        // from metadata.  I set it so far by trial and error - knowing only that the one
        //i want is the second in the list from this log output below

        print (dataSources[0].dataSourceName)
        print (dataSources[1].dataSourceName)
        print (dataSources[2].dataSourceName)
        
        let frontDataSource = dataSources[1]
        do {
            try audioSession.preferredInput?.setPreferredDataSource(frontDataSource)
        } catch {
            print("Unable to set preferred datasource.")
        }
        
        // end of section to be rewritten
        // +++++++++++++++++++++++++++++++++
        
        do {
            try audioSession.setPreferredInputOrientation(AVAudioSession.StereoOrientation.landscapeLeft)
            try frontDataSource.setPreferredPolarPattern(.stereo)
            // Update the input orientation to match the current user interface orientation
        } catch {
            fatalError("Unable to select the data source.")
        }
        
        // we have to record with mic but don't want to keep the audio
        // so the URL is set to null
        let url = URL(fileURLWithPath: "/dev/null", isDirectory: true)

        // need to play around here to see if this makes any difference
        // so far I can't perceive any difference and I think the
        // tap is actually native bitstream and this sample rate only
        // refers to the recording output (which goes to null anyway)
        let recorderSettings: [String:Any] = [
            AVFormatIDKey: NSNumber(value: kAudioFormatAppleLossless),
            AVSampleRateKey: 16000,
            AVNumberOfChannelsKey: 2 ,
            AVLinearPCMBitDepthKey: 16
        ]
        
        inputFormat = audioEngine.inputNode.inputFormat(forBus: inputBus)
        
        do {
            audioRecorder = try AVAudioRecorder(url: url, settings: recorderSettings)
        } catch {
            fatalError(error.localizedDescription)
        }
        
        // finally...
        // we create a meeting object that is published and add two participants
        // the two participants [0] and [1] are the "coach" and the "client"
        // I use two constants kCoach and kClient to make this clear going forward
        
        meeting = MeetingData()
        meeting.participant.append(Participant()) // create participant for Coach
        meeting.participant.append(Participant()) // create participant for Client

        
    }
    
    func startResumeMonitoring(mode: String) {
        
        audioRecorder.isMeteringEnabled = true
        audioRecorder.record()
        
        do {
            try audioEngine.start()
        }
        catch{fatalError(error.localizedDescription)}

        // not sure what the optimum buffer size should be - i have guessed at 4096
        if mode == "Start"
        {
            audioEngine.inputNode.installTap(onBus: inputBus,
                                             bufferSize: 4096,
                                             format: inputFormat, block: analyzeAudio(buffer:at:))
            
            streamAnalyzer = SNAudioStreamAnalyzer(format: inputFormat)
            
            do {
                let request = try SNClassifySoundRequest(classifierIdentifier: SNClassifierIdentifier.version1)
                // window duration for classification improves accuracy but creates more lag
                // i think 1.5 seconds works well
                request.windowDuration = CMTimeMakeWithSeconds(1.5, preferredTimescale: 1000)
                // overlap factor refers to the overlap of classification windows - I use 50%
                // for performance this could be reduced - but it seems fine
                request.overlapFactor = 0.5
                try streamAnalyzer.add(request,
                                       withObserver: resultsObserver)
            }
            catch
            {
                print ("Sound Classifier set up request failed")
            }
        }
        
        // the results of the sound classifier are checked every "kInterval" seconds
        // this needs to be sub seconds to ensure that we get a nice rolling average and pick up on
        // audio peaks that help identify location.  But no advantage in this being too small.
        // I have found 0.1 or 0.2 is fine.  kInterval is set in constants file.

        // weak self is supposed to stop memory leak here - but not 100% sure why !
        timer = Timer.scheduledTimer(withTimeInterval: kInterval, repeats: true, block: { [weak self] (timer) in
            guard let self = self else { return }

            // this timer fires every interval (normally about ~0.1 secs)
            
            self.meeting.elapsedTimeIntervals += 1
            if self.meeting.elapsedTimeIntervals >= (60 * kIntervalsPerSecond)
            {
                self.meeting.elapsedTimeIntervals = 0
                self.meeting.elapsedTimeMins += 1
            }
            
            self.audioRecorder.updateMeters()

            // put latest peak audio energy levels into lifo stack
            self.energyBufferCoach.append(self.audioRecorder.peakPower(forChannel: kCoach))
            self.energyBufferClient.append(self.audioRecorder.peakPower(forChannel: kClient))
            
            if speech != nil // speech boolean is nil until the first classification window is complete
            // this ensures that the levels we are looking at in the lifo stack are in step
            //with the classification.  There should always be something in the buffer but just in case
            // we offer -50 db as a default
            {
                let bufferCoach = self.energyBufferCoach.popFirst() ?? kMinimumDBThreshold
                let bufferClient = self.energyBufferClient.popFirst() ?? kMinimumDBThreshold

                // if peak of either channel is above a minimum threshold AND the classifier
                //says that it is speech then we assume someone is talking
                // in future kMinimum threshold could be set dynamically
                
                //Apply a basic low pass filter to remove natural RMS variance in speech
                if ((bufferCoach > kMinimumDBThreshold || bufferClient > kMinimumDBThreshold) && speech!) {
                    
                    self.peakmix = (self.peakmix * kGamma) + (kAlpha * bufferCoach/bufferClient)
 
                    if self.peakmix > kCoachThreshold // Coach is talking
                    {
                        self.currentTalker = kCoach
                        self.currentListener = kClient
                    }
                    else
                    {
                        self.currentTalker = kClient
                        self.currentListener = kCoach
                    }

                    self.meeting.participant[self.currentTalker].isTalking = true
                    self.meeting.participant[self.currentTalker].talkingAccumulator += 1

                    self.meeting.participant[self.currentListener].isTalking = false
                    self.meeting.participant[self.currentListener].talkingAccumulator = 0
                        
                    // only increment metrics once a second
                    if self.meeting.participant[self.currentTalker].talkingAccumulator > kIntervalsPerSecond
                    {
                        print ("Talking: \(self.currentTalker) total talk: \(self.meeting.participant[self.currentTalker].totalTalkTimeSecs))")
                        
                        if self.meeting.lastTalker != self.currentTalker
                        {
                            self.meeting.participant[self.currentListener].numTurns += 1
                            self.meeting.history.append(Turn(talker: self.currentListener, turnLengthSecs: self.meeting.participant[self.currentListener].currentTurnDuration, coachShare: Float(self.meeting.participant[kCoach].totalTalkTimeSecs)/Float(self.meeting.totalTalkTimeSecs)))
                            
                            self.meeting.lastTalker = self.currentTalker
                        }
                        
                        self.meeting.participant[self.currentTalker].currentTurnDuration += 1
                        self.meeting.participant[self.currentTalker].totalTalkTimeSecs += 1
                        self.meeting.participant[self.currentTalker].talkingAccumulator = 0
                        
                        self.meeting.participant[self.currentListener].currentTurnDuration = 0
                        
                        self.meeting.totalTalkTimeSecs += 1
                        
                        self.meeting.participant[self.currentTalker].voiceShare = Float(self.meeting.participant[self.currentTalker].totalTalkTimeSecs) / Float(self.meeting.totalTalkTimeSecs)
                        
                        self.meeting.participant[self.currentListener].voiceShare = Float(self.meeting.participant[self.currentListener].totalTalkTimeSecs) / Float(self.meeting.totalTalkTimeSecs)

                    }

                }
                else
                {
                    self.peakmix =   (self.peakmix * kGamma) + (kAlpha) // fade to 1.0
                }

            }
        })
    }
    
    // called during the meeting.  Just pauses the engine and disables the timing logic while user is
    // asked if they want to end or resume
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
