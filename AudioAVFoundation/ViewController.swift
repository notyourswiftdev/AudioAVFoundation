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
        button.backgroundColor = .orange
        button.addTarget(self, action: #selector(onRecordAction), for: .touchUpInside)
        return button
    }()
    
    lazy var playButton: UIButton = {
        let button = UIButton()
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
    
    var audioBox = AudioBox()
    var appHasMicAccess = false

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
            } else {
                let alertController = UIAlertController(title: "Requires Microphone Access", message: "Go to Settings > AudioAVFoundation > Allow AudioAVFoundation to Access Microphone. \nSet switch to enable.", preferredStyle: .alert)
                alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                self.present(alertController, animated: true, completion: nil)
            }
        }
    }
    
    @objc func onRecordAction() {
        if audioBox.status == .stopped {
            if appHasMicAccess {
                audioBox.record()
                recordButton.backgroundColor = .red
            } else {
                requestMicrophoneAccess()
            }
        } else {
            audioBox.stopRecording()
            recordButton.backgroundColor = .orange
        }
    }
    
    @objc func onPlayAction() {
        if audioBox.status == .playing {
            audioBox.stopPlayback()
            playButton.backgroundColor = .blue
        } else {
            audioBox.play()
            playButton.backgroundColor = .green
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
