import AVFoundation

// Based on the class Audio-State-Demo.
class AlarmSound {
    var player: AVAudioPlayer?

    func play() -> Bool {
        if let path = Bundle.main.path(forResource: "snare_D1", ofType: "wav") {
            do {
                player = try AVAudioPlayer(contentsOf: URL(fileURLWithPath: path))
                player?.numberOfLoops = -1
                return player?.play() ?? false
            } catch {
                print("Could not play alarm: \(error)")
            }
        }
        return false
    }

    func stop() {
        player?.stop()
    }
}
