//
//  Utils.swift
//  AudioAVFoundation
//
//  Created by Aaron Cleveland on 1/22/22.
//

import Foundation

var appHasMicAccess = true

enum AudioStatus: Int, CustomStringConvertible {
    case Stopped = 0,
    Playing,
    Recording
    
    var audioName: String {
        let audioNames = [
            "Audio: Stopped",
            "Audio: Playing",
            "Audio: Recording"]
        return audioNames[rawValue]
    }
    
    var description: String {
        return audioName
    }
}
