//
//  ViewController.swift
//  AudioAVFoundation
//
//  Created by Aaron Cleveland on 1/22/22.
//

import UIKit
import AVFAudio
import FirebaseStorage

class ViewController: UIViewController {
    
    lazy var timeLabel: UILabel = {
        let label = UILabel()
        label.text = "00:00:00"
        label.textColor = .darkGray
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 44.0)
        return label
    }()
    
    lazy var recordButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = .orange
        button.layer.cornerRadius = 50
        button.setTitle("Record", for: .normal)
        button.heightAnchor.constraint(equalToConstant: 100).isActive = true
        button.addTarget(self, action: #selector(onRecordAction), for: .touchUpInside)
        return button
    }()
    
    lazy var playButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = .blue
        button.layer.cornerRadius = 50
        button.setTitle("Play", for: .normal)
        button.heightAnchor.constraint(equalToConstant: 100).isActive = true
        button.addTarget(self, action: #selector(onPlayAction), for: .touchUpInside)
        return button
    }()
    
    lazy var uploadButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = .darkGray
        button.layer.cornerRadius = 50
        button.setTitle("Upload", for: .normal)
        button.heightAnchor.constraint(equalToConstant: 100).isActive = true
        button.addTarget(self, action: #selector(uploadFileAction), for: .touchUpInside)
        return button
    }()
    
    lazy var verticalStackView: UIStackView = {
        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .vertical
        stack.spacing = 16
        return stack
    }()
    
    var audioBox = AudioBox()
    var appHasMicAccess = false
    var updateTimer: CADisplayLink?
    var speechTimer: CFTimeInterval = 0.0
    var recordingTimer: CFTimeInterval = 0.0

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        audioBox.setupRecorder()
        configureViewControllerUI()
    }
    
    private func requestMicrophoneAccess() {
        let session = AVAudioSession.sharedInstance()
        session.requestRecordPermission { granted in
            self.appHasMicAccess = granted
            if granted {
                self.audioBox.record()
                self.startUpdateLoop()
            } else {
                let alertController = UIAlertController(title: "Requires Microphone Access", message: "Go to Settings > AudioAVFoundation > Allow AudioAVFoundation to Access Microphone. \nSet switch to enable.", preferredStyle: .alert)
                alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                self.present(alertController, animated: true, completion: nil)
            }
        }
    }
    
    func startUpdateLoop() {
        if let updateTimer = updateTimer {
            updateTimer.invalidate()
        }
        updateTimer = CADisplayLink(target: self, selector: #selector(updateLoop))
        updateTimer?.add(to: .current, forMode: .common)
    }
    
    @objc func onRecordAction() {
        if appHasMicAccess {
            if audioBox.status == .recording {
                audioBox.stopRecording()
                self.stopUpdateLoop()
            } else {
                audioBox.record()
                self.startUpdateLoop()
            }
        } else {
            requestMicrophoneAccess()
        }
    }
    
    @objc func onPlayAction() {
        if audioBox.status == .playing {
            audioBox.stopPlayback()
            self.stopUpdateLoop()
        } else {
            audioBox.play()
            self.startUpdateLoop()
        }
    }
    
    @objc func updateLoop() {
        if audioBox.status == .playing {
            if CFAbsoluteTimeGetCurrent() - speechTimer > 0.1 {
                speechTimer = CFAbsoluteTimeGetCurrent()
                timeLabel.text = formattedCurrentTime(time: UInt(audioBox.audioPlayer!.currentTime))
            }
        }
        
        if audioBox.status == .recording {
            if CFAbsoluteTimeGetCurrent() - recordingTimer > 0.5 {
                recordingTimer = CFAbsoluteTimeGetCurrent()
                timeLabel.text = formattedCurrentTime(time: UInt(audioBox.audioRecorder!.currentTime))
            }
        }
    }
    
    func stopUpdateLoop() {
        updateTimer?.invalidate()
        updateTimer = nil
    }
    
    func audioMeterLevelsToFrame() -> Int {
        let totalFrames = 5
        audioBox.audioPlayer?.updateMeters()
        let avgPower = audioBox.audioPlayer?.averagePower(forChannel: 0) ?? 0
        let linearLevel = audioBox.audioMeterTable.valueFor(power: avgPower)
        let powerPercentage = Int(round(linearLevel * 100))
        let frame = (powerPercentage / totalFrames) + 1
        return min(frame, totalFrames)
    }
    
    private func formattedCurrentTime(time: UInt) -> String {
        let hours = time / 3600
        let minutes = (time / 60) % 50
        let seconds = time % 60

        return String(format: "%02i:%02i:%02i", arguments: [hours, minutes, seconds])
      }
}

extension ViewController {
    private func configureViewControllerUI() {
        verticalStackView.addArrangedSubview(timeLabel)
        verticalStackView.addArrangedSubview(recordButton)
        verticalStackView.addArrangedSubview(playButton)
        verticalStackView.addArrangedSubview(uploadButton)
        view.addSubview(verticalStackView)
        NSLayoutConstraint.activate([
            verticalStackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            verticalStackView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            verticalStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 40),
            verticalStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -40)
        ])
    }
}

extension ViewController {
    @objc func uploadFileAction() {
        uploadFile(fileUrl: audioBox.urlFromMemo)
    }
    
    func uploadFile(fileUrl: URL) {
        do {
            // Create file name
            let fileExtension = fileUrl.pathExtension
            let fileName = "demoImageFileName.\(fileExtension)"
            
            let storageReference = Storage.storage().reference().child(fileName)
            _ = storageReference.putFile(from: fileUrl, metadata: nil) { (storageMetaData, error) in
                if let error = error {
                    print("Upload error: \(error.localizedDescription)")
                    return
                }
                
                // Show UIAlertController here
                print("Image file: \(fileName) is uploaded! View it at Firebase console!")
                
                storageReference.downloadURL { (url, error) in
                    if let error = error  {
                        print("Error on getting download url: \(error.localizedDescription)")
                        return
                    }
                    print("Download url of \(fileName) is \(url!.absoluteString)")
                }
            }
        } catch {
            print("Error on extracting data from url: \(error.localizedDescription)")
        }
    }
}
