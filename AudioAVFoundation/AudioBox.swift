//
//  AudioBox.swift
//  AudioAVFoundation
//
//  Created by Aaron Cleveland on 1/22/22.
//

import Foundation
import AVFoundation

class AudioBox: NSObject, ObservableObject {
    
    var status: AudioStatus = .stopped
    var audioRecorder: AVAudioRecorder?
    var audioPlayer: AVAudioPlayer?
    let audioMeterTable = AudioMeterTable(tableSize: 100)
    
    var urlFromMemo: URL {
        let fileManager = FileManager.default
        let tempDir = fileManager.temporaryDirectory
        let filePath = "TempMemo.caf"
        
        return tempDir.appendingPathComponent(filePath)
    }
    
    override init() {
        super.init()
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(handleRouteChange), name: AVAudioSession.routeChangeNotification, object: nil)
        notificationCenter.addObserver(self, selector: #selector(handleInterruption), name: AVAudioSession.interruptionNotification, object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc func handleRouteChange(notification: Notification) {
        if let info = notification.userInfo,
           let rawValue = info[AVAudioSessionRouteChangeReasonKey] as? UInt {
            let reason = AVAudioSession.RouteChangeReason(rawValue: rawValue)
            if reason == .oldDeviceUnavailable {
                guard let previousRoute = info[AVAudioSessionRouteChangePreviousRouteKey] as? AVAudioSessionRouteDescription,
                      let previousOutput = previousRoute.outputs.first else {
                          return
                      }
                if previousOutput.portType == .headphones {
                    if status == .playing {
                        stopPlayback()
                    } else if status == .recording {
                        stopRecording()
                    }
                }
            }
        }
    }
    
    @objc func handleInterruption(notification: Notification) {
        if let info = notification.userInfo,
           let rawValue = info[AVAudioSessionInterruptionTypeKey] as? UInt {
            let type = AVAudioSession.InterruptionType(rawValue: rawValue)
            if type == .began {
                if status == .playing {
                    stopPlayback()
                } else if status == .recording {
                    stopRecording()
                }
            } else {
                if let rawValue = info[AVAudioSessionInterruptionOptionKey] as? UInt {
                    let options = AVAudioSession.InterruptionOptions(rawValue: rawValue)
                    if options == .shouldResume {
                        // restart audio or restart recording
                    }
                }
            }
        }
    }
    
    func setupRecorder() {
        let recordingSettings: [String: Any] = [
            AVFormatIDKey: Int(kAudioFormatLinearPCM),
            AVSampleRateKey: 44100.0,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
        ]
        
        do {
            audioRecorder = try AVAudioRecorder(url: urlFromMemo, settings: recordingSettings)
        } catch {
            print("Error creating audioRecorder")
        }
    }
    
    func record() {
        audioRecorder?.record()
        status = .recording
    }
    
    func stopRecording() {
        audioRecorder?.stop()
        status = .stopped
    }
    
    func play() {
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: urlFromMemo)
        } catch {
            print(error.localizedDescription)
        }
        
        guard let audioPlayer = audioPlayer else { return }
        audioPlayer.delegate = self
        if audioPlayer.duration > 0.0 {
            audioPlayer.isMeteringEnabled = true
            audioPlayer.play()
            status = .playing
        }
    }
    
    func stopPlayback() {
        audioPlayer?.stop()
        status = .stopped
    }
}

extension AudioBox: AVAudioRecorderDelegate {
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        status = .stopped
    }
}

extension AudioBox: AVAudioPlayerDelegate {
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        status = .stopped
    }
}
