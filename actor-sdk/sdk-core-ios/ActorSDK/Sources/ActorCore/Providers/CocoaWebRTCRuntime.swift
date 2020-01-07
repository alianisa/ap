import Foundation
import AVFoundation
//import WebRTC

let queue = DispatchQueue(label: "My Queue", attributes: []);

class CocoaWebRTCRuntime: NSObject, ARWebRTCRuntime {

    fileprivate var isInited: Bool = false
    fileprivate var peerConnectionFactory: RTCPeerConnectionFactory = RTCPeerConnectionFactory()
    fileprivate var videoSource: RTCVideoSource!
//    fileprivate var videoSource: RTCVideoSource = peerConnectionFactory.videoSource()

    fileprivate var videoSourceLoaded = false
    fileprivate var audioSource: RTCAudioSource!
    fileprivate var iceServers: [RTCIceServer] = []
    
    fileprivate var mediaConstraint: RTCMediaConstraints {
        let constraints = ["minWidth": "640", "minHeight": "480", "maxWidth" : "1280", "maxHeight": "720", "minFrameRate": "30"]
        return RTCMediaConstraints(mandatoryConstraints: constraints, optionalConstraints: nil)
    }
    
    var captureController: RTCCapturer!
    
    internal static var mediaStream: RTCMediaStream!
    
//
//    enum Identifiers: String {
//        case mediaStream = "ARDAMS",
//        videoTrack = "ARDAMSv0",
//        audioTrack = "ARDAMSa0"
//        //        dataChannelSignaling = "signaling"
//    }

    override init() {
        
    }
    
    func getUserMedia(withIsAudioEnabled isAudioEnabled: jboolean, withIsVideoEnabled isVideoEnabled: jboolean) -> ARPromise {
        
        return ARPromise { (resolver) -> () in
            queue.async {
                
                self.initRTC()
                
                // Unfortinatelly building capture source "on demand" causes some weird internal crashes
                if !AVCaptureState.isVideoDisabled {
                    self.initVideo()
                } else {
                    // show alert for video permission disabled
                }
                
                let factory = self.peerConnectionFactory

                let stream = factory.mediaStream(withStreamId: "ARDAMSv0")
                
//                let stream = self.peerConnectionFactory.mediaStream(withStreamId: "ARDAMSv0")
                
                
                // Audio
                //
                if isAudioEnabled {


                    let audioSourceConstraints = RTCMediaConstraints(mandatoryConstraints: nil, optionalConstraints: nil)
                    self.audioSource = self.peerConnectionFactory.audioSource(with: audioSourceConstraints)

                    let audio = self.peerConnectionFactory.audioTrack(with: self.audioSource, trackId: "audio0")


                    stream.addAudioTrack(audio)
                }
//
////                if isAudioEnabled {
//                    let audio = factory.audioTrack(withTrackId: "audio0")
//                    stream.addAudioTrack(audio)
//
////                }
                
                //
                // Video
                //
                if isVideoEnabled {
                    if self.videoSource != nil {
                        let localVideoTrack = factory.videoTrack(with: self.videoSource, trackId: "video0")
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
                resolver.result(CocoaWebRTCPeerConnection(servers: servers, peerConnectionFactory: self.peerConnectionFactory))
            }
        }
    }
    
    
    func initRTC() {
        if !isInited {
            isInited = true
            //            RTCPeerConnectionFactory.initializeSSL()
            RTCInitializeSSL()
//            RTCPeerConnectionFactory.initialize()
//            peerConnectionFactory = RTCPeerConnectionFactory()
            self.peerConnectionFactory = RTCPeerConnectionFactory()
        }
    }
    
    func initVideo() {
            if !self.videoSourceLoaded {
                self.videoSourceLoaded = true
                
                self.videoSource = self.peerConnectionFactory.videoSource()

                self.videoSource.adaptOutputFormat(toWidth: 1280, height: 720, fps: 30);
//                self.videoSource.captureSession.canSetSessionPreset(AVCaptureSessionPreset1280x720);
                
                let settingsModel = RTCCapturerSettingsModel()
                let capturer = RTCCameraVideoCapturer(delegate: self.videoSource)
                capturer.captureSession.canSetSessionPreset(AVCaptureSession.Preset.hd1280x720)
                self.captureController = RTCCapturer.init(withCapturer: capturer, settingsModel: settingsModel)
                self.captureController.startCapture()


        }
    }
    
    func supportsPreConnections() -> jboolean {
        return false
    }
    
}


private extension CocoaWebRTCRuntime {
    func localStream() -> RTCMediaStream {
        let factory = self.peerConnectionFactory
        let localStream = factory.mediaStream(withStreamId: "ARDAMSv0")
        
        CocoaWebRTCRuntime.mediaStream = localStream
        
        //        if self.isVideoCall {
        //            if !AVCaptureState.isVideoDisabled {
        //                let videoSource = factory.avFoundationVideoSource(with: self.mediaConstraint)
        //                let videoTrack = factory.videoTrack(with: videoSource, trackId: "video0")
        //                localStream.addVideoTrack(videoTrack)
        //            } else {
        //
        //            }
        //        }
        
        //        if !AVCaptureState.isAudioDisabled {
        let audioTrack = factory.audioTrack(withTrackId: "audio0")
        localStream.addAudioTrack(audioTrack)
        //        } else {
        //
        //        }
        print("WebRTC: getUserMedia \(String(describing: localStream))")
        
        return localStream
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
            print("WebRTC: audioTracks - \(stream.audioTracks[i])")
        }
        for i in 0..<stream.videoTracks.count {
            let track = CocoaVideoTrack(videoTrack: stream.videoTracks[i] )
            videoTracks.replaceObject(at: UInt(i), with: track)
            allTracks.replaceObject(at: UInt((Int(i).advanced(by: Int(audioTracks.length())))), with: track)
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
    
    public let audioTrack: RTCAudioTrack
    
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
    
    public let videoTrack: RTCVideoTrack
    
    public init(videoTrack: RTCVideoTrack) {
        self.videoTrack = videoTrack
    }
    
    open func getType() -> jint {
        return ARWebRTCTrackType_VIDEO
    }

    
    open func setEnabledWithBoolean(_ isEnabled: jboolean) {
        videoTrack.isEnabled = isEnabled
    }
    
    open func isEnabled() -> jboolean {
        return videoTrack.isEnabled
    }
}

class CocoaWebRTCPeerConnection: NSObject, ARWebRTCPeerConnection, RTCPeerConnectionDelegate {

    fileprivate var peerConnection: RTCPeerConnection!
    fileprivate var callbacks = [ARWebRTCPeerConnectionCallback]()
    fileprivate let peerConnectionFactory: RTCPeerConnectionFactory
    fileprivate var ownStreams = [ARCountedReference]()
    
    fileprivate let defaultConnectionConstraint = RTCMediaConstraints(mandatoryConstraints: nil, optionalConstraints: nil)
    
    init(servers: [ARWebRTCIceServer], peerConnectionFactory: RTCPeerConnectionFactory) {
        self.peerConnectionFactory = peerConnectionFactory
        super.init()
        
        let configuration = RTCConfiguration()
        
        let iceServers = servers.map { (src) -> RTCIceServer in
            configuration.iceServers = [RTCIceServer.init(urlStrings: [src.url], username: src.username, credential: src.credential)]

            if (src.username == nil || src.credential == nil) {
                return RTCIceServer(urlStrings: [src.url], username: src.username, credential: src.credential)
            } else {
                return RTCIceServer(urlStrings: [src.url], username: src.username, credential: src.credential)
            }
        }

        peerConnection = peerConnectionFactory.peerConnection(with: configuration, constraints: defaultConnectionConstraint, delegate: self)

        AAAudioManager.sharedAudio().peerConnectionStarted()
    }
    
    func add(_ callback: ARWebRTCPeerConnectionCallback) {
        
//        if !callbacks.contains(where: { callback.isEqual($0) }) {
//            callbacks.append(callback)
//        }
    }
    
    func remove(_ callback: ARWebRTCPeerConnectionCallback) {
//        let index = callbacks.index(where: { callback.isEqual($0) })
//        if index != nil {
//            callbacks.remove(at: index!)
//        }
    }
    func addCandidate(with index: jint, withId id_: String, withSDP sdp: String) {
        peerConnection.add(RTCIceCandidate(sdp: sdp, sdpMLineIndex: index, sdpMid: id_))
    }
    
    func addOwnStream(_ stream: ARCountedReference) {
        stream.acquire()
        let ms = (stream.get() as! MediaStream)
        ownStreams.append(stream)
        peerConnection.add(ms.stream)
    }
    
    func removeOwnStream(_ stream: ARCountedReference) {
        if ownStreams.contains(stream) {
            let ms = (stream.get() as! MediaStream)
            peerConnection.remove(ms.stream)
            stream.release__()
        }
    }
    
    func createAnswer() -> ARPromise {
        return ARPromise(closure: { (resolver) -> () in
            let constraints = RTCMediaConstraints(mandatoryConstraints: ["OfferToReceiveAudio": "true", "OfferToReceiveVideo": "true"], optionalConstraints: nil)
            
            self.peerConnection.answer(for: constraints) { (description, err) in
                if let e = err {
                    print("failed to create answer", e)
                }
                if let d = description {
//                    self.peerConnection.setRemoteDescription(d, completionHandler: { (error) in
                        // nothing todo
//                        if error != nil {
//                            print("error set local description \(String(describing: error?.localizedDescription))")
//                            resolver.error(JavaLangException(nsString: "Error \(error!)"))
//                            return
//                        }
                        resolver.result(ARWebRTCSessionDescription(type: "answer", withSDP: d.sdp))
                        print("WebRTC: createAnswer \(d.sdp)")
//                    })
                }
            }
        })
    }
    
    func creteOffer() -> ARPromise {
        return ARPromise(closure: { (resolver) -> () in
            let constraints = RTCMediaConstraints(mandatoryConstraints: ["OfferToReceiveAudio": "true", "OfferToReceiveVideo": "true"], optionalConstraints: nil)
            self.peerConnection.offer(for: constraints) { (description, err) in
                if let e = err {
                    print("failed to create offer", e)
                }
                if let d = description {
//                    self.peerConnection.setLocalDescription(d, completionHandler: { (error) in
                        // nothing todo
//                        if error != nil {
//                            print("error set local description \(String(describing: error?.localizedDescription))")
//                            resolver.error(JavaLangException(nsString: "Error \(error!)"))
//                            return
//                        }
                        resolver.result(ARWebRTCSessionDescription(type: "offer", withSDP: d.sdp))
                        print("WebRTC: createOffer \(d.sdp)")
//                    })
                }
            }
        })
    }

    func setRemoteDescription(_ description_: ARWebRTCSessionDescription) -> ARPromise {
        let type = description_.type
        switch (type) {
        case "offer":
            print("WebRTC: RemoteDescription Received offer ...")
        case "answer":
            print("WebRTC: RemoteDescription Received answer ...")
        default: break

        }
        return ARPromise(executor: AAPromiseFunc(closure: { (resolver) -> () in
            let d = RTCSessionDescription(type: RTCSessionDescription.type(for: type), sdp: description_.sdp)
            self.peerConnection.setRemoteDescription(d) { (error) in
                if (error == nil) {
                    resolver.result(description_)
                } else {
                    print("failed to set remote offer", error)
                    resolver.error(JavaLangException(nsString: "Error \(error)"))
                }
            }
        }))
    }

    func setLocalDescription(_ description_: ARWebRTCSessionDescription) -> ARPromise {
        let type = description_.type
        switch (type) {
        case "offer":
            print("WebRTC: LocalDescription Received offer ...")

        case "answer":
            print("WebRTC: LocalDescription Received answer ...")

        default:
            break
        }
        return ARPromise(executor: AAPromiseFunc(closure: { (resolver) -> () in
            let d = RTCSessionDescription(type: RTCSessionDescription.type(for: type), sdp: description_.sdp)
            self.peerConnection.setLocalDescription(d, completionHandler: { (error) -> () in
                if (error == nil) {
                    print("WebRTC: LocalDescription description \(description_.type)")
                    resolver.result(description_)
                } else {
                    resolver.error(JavaLangException(nsString: "Error \(error)"))
                }
            })
        }))

    }
    
    func close() {
        for s in ownStreams {
            let ms = s.get() as! MediaStream
            peerConnection.remove(ms.stream)
            s.release__()
        }
        ownStreams.removeAll()
        peerConnection.close()
        AAAudioManager.sharedAudio().peerConnectionEnded()
    }

    public func peerConnection(_ peerConnection: RTCPeerConnection, didChange stateChanged: RTCSignalingState) {
        
    }
    
    public func peerConnection(_ peerConnection: RTCPeerConnection, didAdd stream: RTCMediaStream) {
        
//        if stream.audioTracks.count > 0 {
//            self.delegate?.rtcClient(client: self, didReceiveRemoteAudioTrack: stream.audioTracks[0])
//        }
        
        //if stream.videoTracks.count > 0 {
        //    self.delegate?.rtcClient(client: self, didReceiveRemoteVideoTrack: stream.videoTracks[0])
        //}
//        self.onStreamAdded?(stream)
        
        for c in callbacks {
            c.onStreamAdded(MediaStream(stream: stream))
        }
    }
    
    public func peerConnection(_ peerConnection: RTCPeerConnection, didRemove stream: RTCMediaStream) {
        for c in callbacks {
            c.onStreamRemoved(MediaStream(stream: stream))
        }
        
    }
    
    public func peerConnectionShouldNegotiate(_ peerConnection: RTCPeerConnection) {
        
    }
    
    public func peerConnection(_ peerConnection: RTCPeerConnection, didChange newState: RTCIceConnectionState) {
        
        
//        guard let delegate = callStateDelegate else {
//            return
//        }
//
//        switch newState.rawValue {
//
//        case 0://RTCIceConnectionStateNew
//            break
//
//        case 1://RTCIceConnectionStateChecking
//            delegate.onStateChange(state: RTCClientConnectionState.Connecting)
//            break
//
//        case 2://RTCIceConnectionStateConnected
//            delegate.onStateChange(state: RTCClientConnectionState.Connected)
//            break
//
//        case 3://RTCIceConnectionStateCompleted
//            delegate.onStateChange(state: RTCClientConnectionState.Connected)
//            break
//
//        case 4://RTCIceConnectionStateFailed
//            delegate.onStateChange(state: RTCClientConnectionState.Failed)
//            break
//
//        case 5://RTCIceConnectionStateDisconnected
//            delegate.onStateChange(state: RTCClientConnectionState.Disconnected)
//            break
//
//        case 6://RTCIceConnectionStateClosed
//            delegate.onStateChange(state: RTCClientConnectionState.Closed)
//            break
//
//        case 7://RTCIceConnectionStateCount
//            break
//
//        default:
//            break
//        }
//
//        self.delegate?.rtcClient(client: self, didChangeConnectionState: newState)
    }
    
    public func peerConnection(_ peerConnection: RTCPeerConnection, didChange newState: RTCIceGatheringState) {
        
    }
    
    public func peerConnection(_ peerConnection: RTCPeerConnection, didGenerate candidate: RTCIceCandidate) {
//        self.delegate?.rtcClient(client: self, didGenerateIceCandidate: candidate)
//        sendCandidate(candidate: candidate)
//        self.onCandidateReceived?(candidate)

        for c in callbacks {
            c.onCandidate(withLabel: jint(candidate.sdpMLineIndex), withId: candidate.sdpMid, withCandidate: candidate.sdp)
        }
    }
    
    public func peerConnection(_ peerConnection: RTCPeerConnection, didRemove candidates: [RTCIceCandidate]) {
        
    }
    
    public func peerConnection(_ peerConnection: RTCPeerConnection, didOpen dataChannel: RTCDataChannel) {
        
    }
}
class AAPeerConnectionDelegate: NSObject, RTCPeerConnectionDelegate {

    var onCandidateReceived: ((RTCIceCandidate)->())?
    var onStreamAdded: ((RTCMediaStream) -> ())?


    public func peerConnection(_ peerConnection: RTCPeerConnection, didChange stateChanged: RTCSignalingState) {

    }

    public func peerConnection(_ peerConnection: RTCPeerConnection, didAdd stream: RTCMediaStream) {
        onStreamAdded?(stream)
    }

    public func peerConnection(_ peerConnection: RTCPeerConnection, didRemove stream: RTCMediaStream) {


    }

    public func peerConnectionShouldNegotiate(_ peerConnection: RTCPeerConnection) {

    }

    public func peerConnection(_ peerConnection: RTCPeerConnection, didChange newState: RTCIceConnectionState) {

    }

    public func peerConnection(_ peerConnection: RTCPeerConnection, didChange newState: RTCIceGatheringState) {

    }

    public func peerConnection(_ peerConnection: RTCPeerConnection, didGenerate candidate: RTCIceCandidate) {
        onCandidateReceived?(candidate)
    }

    public func peerConnection(_ peerConnection: RTCPeerConnection, didRemove candidates: [RTCIceCandidate]) {

    }

    public func peerConnection(_ peerConnection: RTCPeerConnection, didOpen dataChannel: RTCDataChannel) {

    }
}
