import Foundation
import AVFoundation

let queue = DispatchQueue(label: "My Queue", attributes: []);

class CocoaWebRTCRuntime: NSObject, ARWebRTCRuntime {
    
    
    
    fileprivate var isInited: Bool = false
    fileprivate var peerConnectionFactory: RTCPeerConnectionFactory!
    fileprivate var videoSource: RTCAVFoundationVideoSource!
    fileprivate var videoSourceLoaded = false
//    fileprivate var constraintsFactory = ConstraintsFactory()
    fileprivate var cameraConstraints: RTCMediaConstraints
    
    enum Identifiers: String {
        case mediaStream = "ARDAMS",
        videoTrack = "ARDAMSv0",
        audioTrack = "ARDAMSa0",
        dataChannelSignaling = "signaling"
    }
    
//    override init() {
    
    }
    
    func getUserMedia(withIsAudioEnabled isAudioEnabled: jboolean, withIsVideoEnabled isVideoEnabled: jboolean) -> ARPromise {
        
        return ARPromise { (resolver) -> () in
            queue.async {
                
                self.initRTC()
                
                // Unfortinatelly building capture source "on demand" causes some weird internal crashes
                self.initVideo()
                
                let stream = self.peerConnectionFactory.mediaStream(withStreamId: "ARDAMSv0")
                
                //
                // Audio
                //
                if isAudioEnabled {
                    let audio = self.peerConnectionFactory.audioTrack(withTrackId: "audio0")
                    stream.addAudioTrack(audio)
                }
                
                //
                // Video
                //
                if isVideoEnabled {
                    if self.videoSource != nil {
                        let localVideoTrack = self.peerConnectionFactory.videoTrack(with: self.videoSource, trackId: Identifiers.videoTrack.rawValue)
                        stream.addVideoTrack(localVideoTrack)
                    }
                }
                
                resolver.result(MediaStream(stream:stream))
            }
        }
    }
    
    func createPeerConnection(withServers webRTCIceServers: IOSObjectArray!, with settings: ARWebRTCSettings!) -> ARPromise {
        let servers: [ARWebRTCIceServer] = webRTCIceServers.toSwiftArray()
        return ARPromise { (resolver) -> () in
            queue.async {
                self.initRTC()
//                resolver.result(CocoaWebRTCPeerConnection(servers: servers, peerConnectionFactory: self.peerConnectionFactory))
            }
        }
    }
    
    func initRTC() {
        if !isInited {
            isInited = true
            RTCPeerConnectionFactory.initialize()
            peerConnectionFactory = RTCPeerConnectionFactory()
        }
    }
    
//    // MARK: - Switch camera
//    func switchCamera() {
//        guard permissionsService.authorizationStatusForVideo() == .authorized else {
//            output?.didReceiveVideoStatusDenied()
//            return
//        }
//        
//        if let videoSource = CocoaVideoTrack?.self as? RTCAVFoundationVideoSource {
//            self.videoSource.useBackCamera = !self.videoSource.useBackCamera
//            output?.didSwitchCameraPosition(videoSource.useBackCamera)
//        } else if NSClassFromString("XCTest") != nil {
//            // We should not received nil localVideoTrack without granted permissions
//            output?.didSwitchCameraPosition(true)
//        }
//    }
    
    func initVideo() {
        if !self.videoSourceLoaded {
            self.videoSourceLoaded = true
            
            var cameraID: String?
            for captureDevice in AVCaptureDevice.devices(withMediaType: AVMediaTypeVideo) {
                if (captureDevice as AnyObject).position == AVCaptureDevicePosition.back {
                    cameraID = (captureDevice as AnyObject).localizedName
                }
            }
            let cameraConstraints = RTCMediaConstraints(mandatoryConstraints:nil, optionalConstraints:nil)
            
            
//            if(cameraID != nil) {
//                let videoCapturer = RTCVideoCapturer(deviceName: cameraID)
//                let videoCapturer = RTCAVFoundationVideoSource(with: constraintsFactory.cameraConstraints)
//                self.videoSource = self.peerConnectionFactory.videoSource(with: videoCapturer, constraints: RTCMediaConstraints())
                self.videoSource = self.peerConnectionFactory.avFoundationVideoSource(with: cameraConstraints)
                self.videoSource.useBackCamera = false
//            }
        }
    }
    
    func supportsPreConnections() -> jboolean {
        return false
    }
}

@objc class MediaStream: NSObject, ARWebRTCMediaStream {
    
    let stream: RTCMediaStream
    let audioTracks: IOSObjectArray
    let videoTracks: IOSObjectArray
    let allTracks: IOSObjectArray
    
    init(stream: RTCMediaStream) {
        self.stream = stream
        
        self.audioTracks = IOSObjectArray(length: UInt(stream.audioTracks.count), type: ARWebRTCMediaTrack_class_())
        self.videoTracks = IOSObjectArray(length: UInt(stream.videoTracks.count), type: ARWebRTCMediaTrack_class_())
        self.allTracks = IOSObjectArray(length: UInt(stream.audioTracks.count + stream.videoTracks.count), type: ARWebRTCMediaTrack_class_())
        
        for i in 0..<stream.audioTracks.count {
            let track = CocoaAudioTrack(audioTrack: stream.audioTracks[i] )
            audioTracks.replaceObject(at: UInt(i), with: track)
            allTracks.replaceObject(at: UInt(i), with: track)
        }
        for i in 0..<stream.videoTracks.count {
            let track = CocoaVideoTrack(videoTrack: stream.videoTracks[i] )
            videoTracks.replaceObject(at: UInt(i), with: track)
            allTracks.replaceObject(at: UInt(i + audioTracks.length()), with: track)
        }
    }
    
    func getAudioTracks() -> IOSObjectArray! {
        return audioTracks
    }
    
    func getVideoTracks() -> IOSObjectArray! {
        return videoTracks
    }
    
    func getTracks() -> IOSObjectArray! {
        return allTracks
    }
    
    func close() {
        for i in stream.audioTracks {
            (i ).isEnabled = false
            stream.removeAudioTrack(i )
        }
        for i in stream.videoTracks {
            (i ).isEnabled = false
            stream.removeVideoTrack(i )
        }
    }
}

open class CocoaAudioTrack: NSObject, ARWebRTCMediaTrack {
    
    open let audioTrack: RTCAudioTrack
    
    public init(audioTrack: RTCAudioTrack) {
        self.audioTrack = audioTrack
    }
    
    open func getType() -> jint {
        return ARWebRTCTrackType_AUDIO
    }
    
    open func setEnabledWithBoolean(_ isEnabled: jboolean) {
        audioTrack.isEnabled = isEnabled
    }
    
    open func isEnabled() -> jboolean {
        return audioTrack.isEnabled 
    }
}

open class CocoaVideoTrack: NSObject, ARWebRTCMediaTrack {
    
    open let videoTrack: RTCVideoTrack?
    
    public init(videoTrack: RTCVideoTrack) {
        self.videoTrack = videoTrack
    }
    
    open func getType() -> jint {
        return ARWebRTCTrackType_VIDEO
    }
    
    open func setEnabledWithBoolean(_ isEnabled: jboolean) {
        videoTrack?.isEnabled = isEnabled
    }
    
    open func isEnabled() -> jboolean {
        return videoTrack!.isEnabled == isEnabled()
    }
}

//class CocoaWebRTCPeerConnection: NSObject, ARWebRTCPeerConnection, RTCPeerConnectionDelegate {
//    
//    fileprivate var peerConnection: RTCPeerConnection!
//    fileprivate var callbacks = [ARWebRTCPeerConnectionCallback]()
//    fileprivate let peerConnectionFactory: RTCPeerConnectionFactory
//    fileprivate var ownStreams = [ARCountedReference]()
//    
//    init(servers: [ARWebRTCIceServer], peerConnectionFactory: RTCPeerConnectionFactory) {
//        self.peerConnectionFactory = peerConnectionFactory
//        super.init()
//        
//        let iceServers = servers.map { (src) -> RTCIceServer in
//            if (src.username == nil || src.credential == nil) {
////                return RTCIceServer(uri: URL(string: src.url), username: "", password: "")
//                return RTCIceServer(urlStrings: [src.url], username: "", credential: "")
//            } else {
//                return RTCIceServer(urlStrings: [src.url], username: src.username, credential: src.credential)
//            }
//        }
//        
//        let configuration = RTCConfiguration()
//        configuration.iceServers = iceServers
////        peerConnection = peerConnectionFactory.peerConnection(with: configuration, constraints: RTCMediaConstraints, delegate: self)
////        peerConnection = peerConnectionFactory.peerConnection(with: RTCConfiguration, constraints: RTCMediaConstraints, delegate: RTCPeerConnectionDelegate?)
////        peerConnection = peerConnectionFactory.peerConnection(with: configuration, constraints: RTCMediaConstraints, delegate: RTCPeerConnectionDelegate?)
//
//        AAAudioManager.sharedAudio().peerConnectionStarted()
//    }
//    
//    func add(_ callback: ARWebRTCPeerConnectionCallback) {
//        
//        if !callbacks.contains(where: { callback.isEqual($0) }) {
//            callbacks.append(callback)
//        }
//    }
//    
//    func remove(_ callback: ARWebRTCPeerConnectionCallback) {
//        let index = callbacks.index(where: { callback.isEqual($0) })
//        if index != nil {
//            callbacks.remove(at: index!)
//        }
//    }
//    func addCandidate(with index: jint, withId id_: String, withSDP sdp: String) {
////        peerConnection.add(RTCIceCandidate(mid: id_, index: Int(index), sdp: sdp))
//        peerConnection.add(RTCIceCandidate(sdp: sdp, sdpMLineIndex: index, sdpMid: id_))
//    }
//    
//    func addOwnStream(_ stream: ARCountedReference) {
//        stream.acquire()
//        let ms = (stream.get() as! MediaStream)
//        ownStreams.append(stream)
//        peerConnection.add(ms.stream)
//    }
//    
//    func removeOwnStream(_ stream: ARCountedReference) {
//        if ownStreams.contains(stream) {
//            let ms = (stream.get() as! MediaStream)
//            peerConnection.remove(ms.stream)
//            stream.release__()
//        }
//    }
//    
//    func createAnswer() -> ARPromise {
//        return ARPromise(closure: { (resolver) -> () in
//            let mandatoryConstraints = ["OfferToReceiveAudio": "true", "OfferToReceiveVideo": "true"]
//            let constraints = RTCMediaConstraints(mandatoryConstraints: mandatoryConstraints, optionalConstraints: [:])
//            self.peerConnection.answer(for: constraints, completionHandler: { (desc, error) -> () in
//                if error == nil {
//                    resolver.result(ARWebRTCSessionDescription(type: "answer", withSDP: desc!.description))
//                } else {
//                    resolver.error(JavaLangException(nsString: "Error \(error!)"))
//                }
//            })
//        })
//    }
//    
//    func creteOffer() -> ARPromise {
//        return ARPromise(closure: { (resolver) -> () in
//            let mandatoryConstraints = ["OfferToReceiveAudio": "true", "OfferToReceiveVideo": "true"]
//            let constraints = RTCMediaConstraints(mandatoryConstraints: mandatoryConstraints, optionalConstraints: [:])
//            self.peerConnection.offer(for: constraints, completionHandler: { (desc, error) -> () in
//                if error == nil {
//                    resolver.result(ARWebRTCSessionDescription(type: "offer", withSDP: desc!.description))
//                } else {
//                    resolver.error(JavaLangException(nsString: "Error \(error!)"))
//                }
//            })
//        })
//    }
//    
////    func setRemoteDescription(_ description_: ARWebRTCSessionDescription) -> ARPromise {
////        return ARPromise(executor: AAPromiseFunc(closure: { (resolver) -> () in
//////            let description_ = RTCSdpType(description_)
//////            self.peerConnection.setRemoteDescription(RTCSessionDescription(RTCSdpType(type: description_), sdp: description_.sdp) , completionHandler: <#T##((Error?) -> Void)?##((Error?) -> Void)?##(Error?) -> Void#>)
////            self.peerConnection.setRemoteDescription(RTCSessionDescription(type: RTCSdpType.answer, sdp: description_.sdp)), completionHandler: { (error) -> () in
////                if (error == nil) {
////                    resolver.result(description_)
////                } else {
////                    resolver.error(JavaLangException(nsString: "Error \(error)"))
////                }
////            })
////        }))
////    }
////    
////    func setLocalDescription(_ description_: ARWebRTCSessionDescription) -> ARPromise {
////        return ARPromise(executor: AAPromiseFunc(closure: { (resolver) -> () in
////            self.peerConnection.setLocalDescription(RTCSessionDescription(type: description_.type, sdp: description_.sdp), completionHandler: { (error) -> () in
////                if (error == nil) {
////                    resolver.result(description_)
////                } else {
////                    resolver.error(JavaLangException(nsString: "Error \(error)"))
////                }
////            })
////        }))
////        
////    }
//    
//    func close() {
//        for s in ownStreams {
//            let ms = s.get() as! MediaStream
//            peerConnection.remove(ms.stream)
//            s.release__()
//        }
//        ownStreams.removeAll()
//        peerConnection.close()
//        AAAudioManager.sharedAudio().peerConnectionEnded()
//    }
//    
//    //
//    // RTCPeerConnectionDelegate
//    //
//    
//    
//    @objc(peerConnection:didAddStream:) func peerConnection(_ peerConnection: RTCPeerConnection, didAdd stream: RTCMediaStream) {
//        for c in callbacks {
//            c.onStreamAdded(MediaStream(stream: stream))
//        }
//    }
//    
//    @objc(peerConnection:didRemoveStream:) func peerConnection(_ peerConnection: RTCPeerConnection, didRemove stream: RTCMediaStream) {
//        for c in callbacks {
//            c.onStreamRemoved(MediaStream(stream: stream))
//        }
//    }
//    
//    func peerConnection(onRenegotiationNeeded peerConnection: RTCPeerConnection!) {
//        for c in callbacks {
//            c.onRenegotiationNeeded()
//        }
//    }
//    
//    func peerConnection(_ peerConnection: RTCPeerConnection, didGenerate candidate: RTCIceCandidate) {
//        for c in callbacks {
//            c.onCandidate(withLabel: jint(candidate.sdpMLineIndex), withId: candidate.sdpMid, withCandidate: candidate.sdp)
//        }
//    }
//    
//    func peerConnection(_ peerConnection: RTCPeerConnection, didChange stateChanged: RTCSignalingState) {
//        
//    }
//    
//    func peerConnection(_ peerConnection: RTCPeerConnection, iceConnectionChanged newState: RTCIceConnectionState) {
//        
//    }
//    
//    func peerConnection(_ peerConnection: RTCPeerConnection, iceGatheringChanged newState: RTCIceGatheringState) {
//        
//    }
//    
//    func peerConnection(_ peerConnection: RTCPeerConnection, didOpen dataChannel: RTCDataChannel) {
//        
//    }
//}
