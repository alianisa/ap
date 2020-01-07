import Foundation
import AVFoundation

public enum Route {
    case speaker
    case receiver
}

open class AAAudioRouter {
    
    fileprivate static let sharedManager = AAAudioRouter()
    
    public static func sharedAudio() -> AAAudioRouter {
        return sharedManager
    }
    
    fileprivate var isBatchedUpdate = false
    fileprivate var isInvalidated = false
    
    open var isEnabled = false {
        willSet(v) {
            if isEnabled != v {
                isInvalidated = true
            }
        }
        didSet(v) {
            onChanged()
        }
    }
    
    open var isRTCEnabled = false {
        willSet(v) {
            if isRTCEnabled != v {
                isInvalidated = true
            }
        }
        didSet(v) {
            onChanged()
        }
    }
    
    open var currentRoute = Route.receiver {
        willSet(v) {
            if currentRoute != v {
                isInvalidated = true
            }
        }
        didSet(v) {
            onChanged()
        }
    }
    
    open var mode = AVAudioSession.Mode.default {
        willSet(v) {
            if mode != v {
                isInvalidated = true
            }
        }
        didSet(v) {
            onChanged()
        }
    }
    
    open var category = AVAudioSession.Category.soloAmbient {
        willSet(v) {
            if category != v {
                isInvalidated = true
            }
        }
        didSet(v) {
            onChanged()
        }
    }
    
    public init() {
        fixSession()
//        NotificationCenter.default.addObserver(forName: NSNotification.Name.AVAudioSessionRouteChange,
//                                               object: nil, queue: OperationQueue.main) { (note) -> Void in
//                                                let notification: Notification = note as Notification
//                                                if let info = (notification as NSNotification).userInfo {
//                                                    let numberReason: NSNumber = info[AVAudioSessionRouteChangeReasonKey] as! NSNumber
//                                                    if let reason = AVAudioSessionRouteChangeReason(rawValue: UInt(numberReason.intValue)) {
//                                                        self.routeChanged(reason)
//                                                    }
//                                                }
//        }
    }
    
    func batchedUpdate(_ closure: ()->()) {
        isInvalidated = false
        isBatchedUpdate = true
        closure()
        isBatchedUpdate = false
        if isInvalidated {
            isInvalidated = false
            fixSession()
        }
    }
    
    fileprivate func onChanged() {
        if !isBatchedUpdate && isInvalidated {
            isInvalidated = false
            fixSession()
        }
    }
    
    fileprivate func fixSession() {
        
        let session = AVAudioSession.sharedInstance()
        
        if isRTCEnabled {
            do {
//                if session.category != AVAudioSessionCategoryPlayAndRecord {
//                    try session.setCategory(category)
//                }
//
//                if session.mode != AVAudioSessionModeVoiceChat {
//                    try AVAudioSession.sharedInstance().setMode(mode)
                try session.setCategory(.playAndRecord, mode: .default, options: [])
                try session.setMode(AVAudioSession.Mode.voiceChat)
//                    try session.setPreferredSampleRate(48000.0)
                    try session.setPreferredSampleRate(44100.0)
                    try session.setPreferredIOBufferDuration(0.005)
//                }
            } catch let error as NSError {
                print("📡 Audio Session: (isRTCEnabled) \(error.description)")
            }
            
            do {
//                if let route: AVAudioSessionRouteDescription = session.currentRoute {
//                    for port in route.outputs {
//                        let portDescription: AVAudioSessionPortDescription = port as AVAudioSessionPortDescription
//                        if (self.currentRoute == .receiver && portDescription.portType != AVAudioSessionPortBuiltInReceiver) {
//                            try session.overrideOutputAudioPort(.none)
//                        } else if (self.currentRoute == .speaker && portDescription.portType != AVAudioSessionPortBuiltInSpeaker) {
//                            try session.overrideOutputAudioPort(AVAudioSessionPortOverride.speaker)
//                        }
//                    }
//                }
                if (self.currentRoute == .receiver) {
//                    try AVAudioSession.sharedInstance().setCategory(category, with: AVAudioSessionCategoryOptions.defaultToSpeaker)
                    try AVAudioSession.sharedInstance().overrideOutputAudioPort(.none)
                } else {
                    try AVAudioSession.sharedInstance().overrideOutputAudioPort(.speaker)
                }
            } catch let error as NSError {
                print("📡 Audio Session: (portDescription) \(error.description)")
            }
        } else {
            do {
//                if session.category != category {
//                    try session.setCategory(category)
//                }
//
//                if session.mode != mode {
//                    try AVAudioSession.sharedInstance().setMode(mode)
//                    try session.setPreferredSampleRate(48000.0)
//                    try session.setPreferredIOBufferDuration(0.005)
//                }
                
                try session.setCategory(.playAndRecord, mode: .default, options: [])
                try session.setMode(AVAudioSession.Mode.voiceChat)
                try session.setPreferredSampleRate(44100.0)
//                try? session.setPreferredSampleRate(48000.0)
                try session.setPreferredIOBufferDuration(0.005)

//                if let route: AVAudioSessionRouteDescription = session.currentRoute {
//                    for port in route.outputs {
//                        let portDescription: AVAudioSessionPortDescription = port as AVAudioSessionPortDescription
//                        if (self.currentRoute == .receiver && portDescription.portType != AVAudioSessionPortBuiltInReceiver) {
//                            try session.overrideOutputAudioPort(.none)
//                        } else if (self.currentRoute == .speaker && portDescription.portType != AVAudioSessionPortBuiltInSpeaker) {
//                            try session.overrideOutputAudioPort(AVAudioSessionPortOverride.speaker)
//                        }
//                    }
//                }
                if (self.currentRoute == .receiver) {
                    //                    try AVAudioSession.sharedInstance().setCategory(category, with: AVAudioSessionCategoryOptions.defaultToSpeaker)
                    try AVAudioSession.sharedInstance().overrideOutputAudioPort(.none)
                } else {
                    try AVAudioSession.sharedInstance().overrideOutputAudioPort(.speaker)
                }
            } catch let error as NSError {
                print("📡 Audio Session: \(error.description)")
            }
            
            do {
//                let session = AVAudioSession.sharedInstance()
//                try session.setCategory(AVAudioSessionCategoryPlayAndRecord)
//                try session.setMode(AVAudioSessionModeVoiceChat)
//                try session.setPreferredSampleRate(44100.0)
//                try session.setPreferredIOBufferDuration(0.005)
//                try session.setActive(isEnabled)
            } catch let error as NSError {
                print("📡 Audio Session: (session.setActive) \(error.description)")
            }
        }
    }
    
    fileprivate func isHeadsetPluggedIn() -> Bool {
        let route: AVAudioSessionRouteDescription = AVAudioSession.sharedInstance().currentRoute
        for port in route.outputs {
            let portDescription: AVAudioSessionPortDescription = port as AVAudioSessionPortDescription
            if portDescription.portType == AVAudioSession.Port.headphones || portDescription.portType == AVAudioSession.Port.headsetMic {
                return true
            }
        }
        return false
    }
    
//    fileprivate func routeChanged(_ reason: AVAudioSessionRouteChangeReason) {
//        if reason == .newDeviceAvailable {
//            if isHeadsetPluggedIn() {
//                self.currentRoute = .receiver
//                return
//            }
//        } else if reason == .oldDeviceUnavailable {
//            if !isHeadsetPluggedIn() {
//                self.currentRoute = .receiver
//                return
//            }
//        }
//
//        if reason == .override || reason == .routeConfigurationChange {
//            fixSession()
//        }
//    }
//    func proximityChanged(notification: NSNotification) {
//        if let device = notification.object as? UIDevice {
//            print("\(device) detected!")
//        }
//    }
//
//    open func activateProximitySensor() {
//        let device = UIDevice.current
//        device.isProximityMonitoringEnabled = true
//        if device.isProximityMonitoringEnabled {
//            NotificationCenter.default.addObserver(self, selector: "proximityChanged:", name: NSNotification.Name(rawValue: "UIDeviceProximityStateDidChangeNotification"), object: device)
//        }
//    }
    
    open func deactivateAudioSession() {
//        try? AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategorySoloAmbient)
        try? AVAudioSession.sharedInstance().setCategory(.soloAmbient, mode: .default, options: [.defaultToSpeaker])
        try? AVAudioSession.sharedInstance().setMode(AVAudioSession.Mode.default)
        try? AVAudioSession.sharedInstance().setActive(false)
    }
}
