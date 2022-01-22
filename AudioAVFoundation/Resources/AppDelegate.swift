//
//  AppDelegate.swift
//  AudioAVFoundation
//
//  Created by Aaron Cleveland on 1/22/22.
//

import UIKit
import AVFoundation

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
//        let session = AVAudioSession.sharedInstance()
//        do {
//            try session.setCategory(AVAudioSession.Category.playAndRecord, options: AVAudioSession.CategoryOptions.defaultToSpeaker)
//            try session.setActive(true)
//            
//            // Check for microphone permission...
//            session.requestRecordPermission { granted in
//                if granted {
//                    appHasMicAccess = true
//                } else {
//                    appHasMicAccess = false
//                }
//            }
//        } catch let error as NSError {
//            print("AVAudioSession configuration error: \(error.localizedDescription)")
//        }
//        
        return true
    }

    // MARK: UISceneSession Lifecycle
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {}


}

