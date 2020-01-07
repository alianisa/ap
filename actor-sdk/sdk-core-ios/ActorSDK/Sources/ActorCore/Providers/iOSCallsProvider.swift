//
//  Copyright (c) 2014-2016 Actor LLC. <https://actor.im>
//

import Foundation
import AVFoundation

class iOSCallsProvider: NSObject, ACCallsProvider {

//    var beepPlayer: AVAudioPlayer! = nil
//    var ringtonePlayer: AVAudioPlayer! = nil
    var latestNotification: UILocalNotification!
    
    fileprivate var audioRouter = AAAudioRouter()

    private let tone = SoundManager.shared
    
//    @available(iOS 10.0, *)
//    private lazy var callCenter = AACallCenter(delegate: self)
    


//    @available(iOS 10.0, *)
//    private lazy var callCenter = AACallCenter(delegate: self)

    
    func onCallStart(withCallId callId: jlong) {
//        let call: ACCallVM
//        call = ActorSDK.sharedActor().messenger.getCallWithCallId(callId)
//        let user = Actor.getUserWithUid(call.peer.peerId)
//        let peerTitle = user.getNameModel()
//
//        if #available(iOS 10.0, *) {
//            self.callCenter.delegate = self
//            self.callCenter.setup(appName: "Alo", appIcon: UIImage.bundled("logo"))
//            self.callCenter.startOutgoingCall(of: peerTitle.get(), isVideo: false)
//
//        } else {
//        }
        print("onCallStarted")
//        AAAudioManager.sharedAudio().callStart(Actor.getCallWithCallId(callId))
        
        dispatchOnUi() {
            let rootController = ActorSDK.sharedActor().bindedToWindow.rootViewController!
//            if let presented = rootController.presentedViewController {
//                presented.dismiss(animated: true, completion: { () -> Void in
//                    rootController.modalPresentationStyle = .formSheet
//                    rootController.present(AACallViewController(callId: callId), animated: true, completion: nil)
//                })
//            } else {
            let window = ActorSDK.sharedActor()
            window.present(AACallViewController(callId: callId))
//            (newController: AACallViewController(callId: callId))
//                rootController.present(AACallViewController(callId: callId), animated: false, completion: nil)
//            }
        }
    }
    
    func onCallAnswered(withCallId callId: jlong) {
//        self.tone.connectTone()
//        AAAudioManager.sharedAudio().callAnswered(Actor.getCallWithCallId(callId))
//        startOutgoingTone(path: "alo_connect", loops: 1)

    }
    
    func onCallEnd(withCallId callId: jlong) {
//        self.tone.endTone();
//        let call: ACCallVM
//        call = ActorSDK.sharedActor().messenger.getCallWithCallId(callId)
//        let user = Actor.getUserWithUid(call.peer.peerId)
//        let peerTitle = user.getNameModel()
//        if #available(iOS 10.0, *) {
//            self.callCenter.endCall(of: peerTitle.get())
//        } else {
//            // Fallback on earlier versions
//        }
        AAAudioManager.sharedAudio().callEnd(Actor.getCallWithCallId(callId))
    }
    
    func onCallBusy(withCallId callId: jlong) {
//        let call: ACCallVM
//        let binder = AABinder()
//        call = ActorSDK.sharedActor().messenger.getCallWithCallId(callId)
//        call.state.change(withValue: ACCallState.busy)
        Actor.busyCall(withCallId: callId);

//        binder.bind(call.state) { (value: ACCallState?) -> () in
//            print("CallState: \(value!)")

//            call.state.change(withValue: ACCallState_Enum.BUSY)
//            let window = ActorSDK.sharedActor()
//            window.present(AACallViewController(callId: callId))
//        }
    }
    func startOutgoingBeep(withBoolean connected: jboolean) {
//        if (beepPlayer == nil) {
//            do {
//                if connected {
//                    beepPlayer = try AVAudioPlayer(contentsOf: URL(fileURLWithPath: Bundle.framework.path(forResource: "alo_ringing", ofType: "mp3")!))
//
//                } else {
//                    beepPlayer = try AVAudioPlayer(contentsOf: URL(fileURLWithPath: Bundle.framework.path(forResource: "alo_signaling", ofType: "mp3")!))
//
//                }
//                beepPlayer.prepareToPlay()
//                beepPlayer.numberOfLoops = -1
//            } catch let error as NSError {
//                print("Error: \(error.description)")
//            }
//        }
//        self.audioRouter.isEnabled = true
//        beepPlayer.play()
    }
    
    func startOutgoingTone(path: String, loops: Int) {
        
//        if (beepPlayer == nil) {
//            do {
//                beepPlayer = try AVAudioPlayer(contentsOf: URL(fileURLWithPath: Bundle.framework.path(forResource: path, ofType: "mp3")!))
//                beepPlayer.prepareToPlay()
//                beepPlayer.numberOfLoops = loops
//            } catch let error as NSError {
//                print("Error: \(error.description)")
//            }
//        }
//        self.audioRouter.isEnabled = true
//        beepPlayer.play()
    }
    
    
//
    func stopOutgoingBeep() {
//        if beepPlayer != nil {
//            beepPlayer.stop()
//            beepPlayer = nil
//        }
    }
    
}


