//
//  AudioSettingsViewController.swift
//  AudioAVFoundation
//
//  Created by Aaron Cleveland on 1/23/22.
//

import UIKit

class AudioSettingsViewController: UIViewController {
    
    lazy var pitchLabel: UILabel = {
        let label = UILabel()
        label.text = "Pitch"
        return label
    }()
    
    lazy var reverbLabel: UILabel = {
        let label = UILabel()
        label.text = "Reverb"
        return label
    }()
    
    lazy var pitchSlider: UISlider = {
        let slider = UISlider()
        slider.minimumValue = 0
        slider.maximumValue = 10
        slider.value = 5
        return slider
    }()
    
    lazy var reverbSlider: UISlider = {
        let slider = UISlider()
        slider.minimumValue = 0
        slider.maximumValue = 10
        slider.value = 5
        return slider
    }()
    
    lazy var verticalStackView: UIStackView = {
        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .vertical
        stack.spacing = 16
        return stack
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(red: 173/255, green: 216/255, blue: 230/255, alpha: 1.0)
        configureViewControllerUI()
    }
}

extension AudioSettingsViewController {
    private func configureViewControllerUI() {
        verticalStackView.addArrangedSubview(pitchLabel)
        verticalStackView.addArrangedSubview(pitchSlider)
        verticalStackView.addArrangedSubview(reverbLabel)
        verticalStackView.addArrangedSubview(reverbSlider)
        view.addSubview(verticalStackView)
        NSLayoutConstraint.activate([
            verticalStackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            verticalStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 40),
            verticalStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -40)
        ])
    }
}
