import Foundation
import AVFoundation

class SoundManager {
    
    ///Audio player responsible for playing sound files.
    var audioPlayer: AVAudioPlayer?
    fileprivate var audioRouter = AAAudioRouter()

    static let shared = SoundManager()
    
    func incomingTone() {
//        let url = URL(fileURLWithPath: QiscusRTC.bundle.path(forResource: "incoming", ofType: "mp3")!)
//        self.playSound(url, loop: true)
    }
    
    func dialingTone() {
//        let url = URL(fileURLWithPath: QiscusRTC.bundle.path(forResource: "dialing", ofType: "mp3")!)
        let url = URL(fileURLWithPath: Bundle.framework.path(forResource: "alo_signaling", ofType: "mp3")!)
        self.playSound(url, loop: true, internalSpeaker : true, volume : false)
    }
    
    func ringingTone() {
        let url = URL(fileURLWithPath: Bundle.framework.path(forResource: "alo_ringing", ofType: "mp3")!)
        self.playSound(url, loop: true, internalSpeaker : true, volume : false)
    }
    
    func connectTone() {
        let url = URL(fileURLWithPath: Bundle.framework.path(forResource: "alo_connect", ofType: "mp3")!)
        self.playSound(url, loop: false, internalSpeaker : true, volume : false)
    }
    
    func disconnectTone() {
        let url = URL(fileURLWithPath: Bundle.framework.path(forResource: "alo_disconnect", ofType: "mp3")!)
        self.playSound(url, loop: true, internalSpeaker : true, volume : false)
    }
    
    func busyTone() {
        let url = URL(fileURLWithPath: Bundle.framework.path(forResource: "alo_busy", ofType: "mp3")!)
        self.playSound(url, loop: true, internalSpeaker : true, volume : false)
    }
    
    func endTone() {
        let url = URL(fileURLWithPath: Bundle.framework.path(forResource: "alo_end", ofType: "caf")!)
        self.playSound(url, loop: true, internalSpeaker : true, volume : false)
    }
    
    func connectingTone() {
        let url = URL(fileURLWithPath: Bundle.framework.path(forResource: "tone", ofType: "mp3")!)
        self.playSound(url, loop: true, internalSpeaker : true, volume : true)
    }
    
    func failTone() {
        let url = URL(fileURLWithPath: Bundle.framework.path(forResource: "alo_fail", ofType: "caf")!)
        self.playSound(url, loop: true, internalSpeaker : true, volume : false)
    }
    
    func reconnectTone() {
//        let url = URL(fileURLWithPath: QiscusRTC.bundle.path(forResource: "reconnecting", ofType: "mp3")!)
//        self.playSound(url, loop: true)
    }
    
    // audio player
    func stop() {
        if self.audioPlayer != nil {
            if (self.audioPlayer?.isPlaying)! {
                self.audioPlayer?.stop()
                self.audioPlayer?.prepareToPlay()
//                self.audioRouter.deactivateAudioSession()
                print("stop ringtone")
            }
        }
    }
    
    private func playSound(_ url: URL, loop: Bool = false,internalSpeaker : Bool = false, volume : Bool) {
        //Play the sound
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: url, fileTypeHint: nil)

            if (internalSpeaker) {
//                try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayAndRecord)
//                try AVAudioSession.sharedInstance().setMode(AVAudioSessionModeVoiceChat)
//                try AVAudioSession.sharedInstance().setActive(true)
            }else{
//                try? AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayAndRecord, with: AVAudioSessionCategoryOptions.defaultToSpeaker)
            }
            self.audioPlayer?.prepareToPlay()
            audioPlayer?.play()
            
            if volume {
                audioPlayer?.volume = 0.5
            }
            
            if loop {
                print("play sound loop")
                audioPlayer?.numberOfLoops = -1
            }
        } catch {
            debugPrint("error call tone \(error)")
        }
    }
}
