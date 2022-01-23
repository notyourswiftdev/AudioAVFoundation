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
    
    var urlFromMemo: URL {
        let fileManager = FileManager.default
        let tempDir = fileManager.temporaryDirectory
        let filePath = "TempMemo.caf"
        
        return tempDir.appendingPathComponent(filePath)
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
