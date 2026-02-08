import Foundation
import AVFoundation
import Combine

class AmbienceAudioManager: ObservableObject {
    static let shared = AmbienceAudioManager()
    
    @Published var currentSound: AmbienceSound?
    @Published var isPlaying = false
    
    private var audioPlayer: AVAudioPlayer?
    
    private init() {
        // Configure audio session for macOS
        #if os(macOS)
        // No audio session needed on macOS
        #else
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("Failed to set audio session category: \(error)")
        }
        #endif
    }
    
    func toggleSound(_ sound: AmbienceSound) {
        print("Toggle sound: \(sound.name)")
        if currentSound == sound {
            // Toggle off - stop playing
            print("Stopping current sound")
            stop()
        } else {
            // Play new sound
            print("Playing new sound: \(sound.fileName)")
            play(sound)
        }
    }
    
    private func play(_ sound: AmbienceSound) {
        // Stop current sound if playing
        stop()
        
        // Try multiple extensions
        let extensions = ["mp3", "m4a", "wav"]
        var url: URL?
        
        for ext in extensions {
            if let foundURL = Bundle.main.url(forResource: sound.fileName, withExtension: ext) {
                url = foundURL
                print("✅ Found audio file: \(sound.fileName).\(ext)")
                break
            }
        }
        
        guard let audioURL = url else {
            print("❌ Audio file not found for: \(sound.fileName)")
            print("Bundle path: \(Bundle.main.bundlePath)")
            print("Bundle resources: \(Bundle.main.paths(forResourcesOfType: nil, inDirectory: nil))")
            return
        }
        
        print("✅ Loading audio from: \(audioURL.path)")
        
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: audioURL)
            audioPlayer?.numberOfLoops = -1 // Loop indefinitely (-1 means infinite loop)
            audioPlayer?.volume = 0.7
            
            if audioPlayer?.prepareToPlay() == true {
                let success = audioPlayer?.play() ?? false
                print(success ? "✅ Audio playing successfully" : "❌ Failed to start audio playback")
                
                if success {
                    currentSound = sound
                    isPlaying = true
                    print("Duration: \(audioPlayer?.duration ?? 0) seconds")
                }
            } else {
                print("❌ Failed to prepare audio player")
            }
        } catch {
            print("❌ Error creating audio player: \(error.localizedDescription)")
        }
    }
    
    private func stop() {
        audioPlayer?.stop()
        audioPlayer = nil
        currentSound = nil
        isPlaying = false
        print("Audio stopped")
    }
}
