//
//
//  quiz
//  
//  Created on 08.03.2021
//  
//  

import AVFoundation

extension AVAudioPlayer {

    enum AudioTypes: String {
        case mp3
        case wav
        case m4a
    }

    convenience init?(file: String, type: AudioTypes, volume: Float? = nil) {
        guard let path = Bundle.main.path(forResource: file, ofType: type.rawValue) else { print("Incorrect audio path"); return nil }
        let url = URL(fileURLWithPath: path)
        try? self.init(contentsOf: url)
        if let validVolume = volume, validVolume >= 0.0 && validVolume <= 1.0 {
            self.volume = validVolume
        }
    }

    func setVolumeLevel(to volume: Float, duration: TimeInterval? = nil) {
        self.setVolume(volume, fadeDuration: duration ?? 0)
    }
}


enum SoundEffect {
    static let correct = AVAudioPlayer(file: "success1", type: .wav)
    static let incorrect = AVAudioPlayer(file: "error1", type: .wav)

    static func playSuccess() {
        DispatchQueue.global(qos: .userInteractive).async {
            correct?.play()
        }
    }

    static func playError() {
        DispatchQueue.global(qos: .userInteractive).async {
            incorrect?.play()
        }
    }
}
