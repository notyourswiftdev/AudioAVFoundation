//
//  ViewController.swift
//  AudioAVFoundation
//
//  Created by Aaron Cleveland on 1/22/22.
//

import UIKit
import AVFAudio

class ViewController: UIViewController {
    
    lazy var timeLabel: UILabel = {
        let label = UILabel()
        label.text = "00:00:00"
        label.textColor = .darkGray
        return label
    }()
    
    lazy var recordButton: UIButton = {
        let button = UIButton()
        button.setTitle("RECORD", for: .normal)
        button.backgroundColor = .red
        
        button.addTarget(self, action: #selector(onRecordAction), for: .touchUpInside)
        return button
    }()
    
    lazy var playButton: UIButton = {
        let button = UIButton()
        button.setTitle("PLAY", for: .normal)
        button.backgroundColor = .blue
        
        button.addTarget(self, action: #selector(onPlayAction), for: .touchUpInside)
        return button
    }()
    
    lazy var verticalStackView: UIStackView = {
        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .vertical
        return stack
    }()
    
    var audioStatus: AudioStatus = AudioStatus.Stopped
    var audioRecord: AVAudioRecorder!
    var audioPlayer: AVAudioPlayer!

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        configureViewControllerUI()
    }
    
    private func setPlayButtonOn(flag: Bool) {
        if flag == true {
            playButton.setTitle("Playing", for: .normal)
        } else {
            playButton.setTitle("Not Playing", for: .normal)
        }
    }
    
    @objc func onRecordAction() {
        if appHasMicAccess == true {
            if audioStatus != .Playing {
                switch audioStatus {
                case .Stopped:
                    recordButton.setTitle("Record", for: .normal)
                case .Recording:
                    recordButton.setTitle("Stop Recording", for: .normal)
                    stopRecording()
                default:
                    break;
                }
            }
        } else {
            recordButton.isEnabled = false
            let alertController = UIAlertController(title: "Requires Microphone Access", message: "Go to Settings > AudioAVFoundation > Allow AudioAVFoundation to Access Microphone. \nSet switch to enable.", preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alertController, animated: true, completion: nil)
        }
    }
    
    @objc func onPlayAction() {
        if audioStatus != .Recording {
            switch audioStatus {
            case .Stopped:
                play()
            case .Playing:
                stopPlayback()
            default:
                break;
            }
        }
    }
}

extension ViewController {
    private func configureViewControllerUI() {
        verticalStackView.addArrangedSubview(timeLabel)
        verticalStackView.addArrangedSubview(recordButton)
        verticalStackView.addArrangedSubview(playButton)
        view.addSubview(verticalStackView)
        NSLayoutConstraint.activate([
            verticalStackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            verticalStackView.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
}

extension ViewController: AVAudioPlayerDelegate, AVAudioRecorderDelegate {
    
    // MARK: Recording
    func setupRecorder() {
        
    }
    
    func record() {
        audioStatus = .Recording
    }
    
    func stopRecording() {
        recordButton.setTitle("Stop Recording", for: .normal)
        audioStatus = .Stopped
    }
    
    func play() {
        setPlayButtonOn(flag: true)
        audioStatus = .Playing
    }
    
    func stopPlayback() {
        setPlayButtonOn(flag: false)
        audioStatus = .Stopped
    }
    
    // MARK: Delegates

    // MARK: Notifications
    
    // MARK: Helpers
    
    func getURLForMemo() -> NSURL {
        let tempDir = NSTemporaryDirectory()
        let filePath = tempDir + "/TempMemo.caf"
        
        return NSURL.fileURL(withPath: filePath) as NSURL
    }
}
