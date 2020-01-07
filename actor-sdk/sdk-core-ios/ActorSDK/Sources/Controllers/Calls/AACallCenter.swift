import UIKit
import CallKit
import AVFoundation

@available(iOS 10.0, *)
protocol AACallCenterDelegate {
    func callCenter(_ callCenter: AACallCenter, startCall session: String)
    func callCenter(_ callCenter: AACallCenter, answerCall session: String)
    func callCenter(_ callCenter: AACallCenter, muteCall muted: Bool, session: String)
    func callCenter(_ callCenter: AACallCenter, declineCall session: String)
    func callCenter(_ callCenter: AACallCenter, endCall session: String)
    func callCenterDidActiveAudioSession(_ callCenter: AACallCenter)
}

@available(iOS 10.0, *)
class AACallCenter: NSObject {
    
    var delegate: AACallCenterDelegate?

//    fileprivate static let sharedManager = AACallCenter()
//
//    open static func sharedCallCenter() -> AACallCenter {
//        return sharedManager
//    }

    
    
    fileprivate let controller = CXCallController()
    private var provider : CXProvider?
    fileprivate var sessionPool = [UUID: String]()
    
    
    
    // MARK: Call State Properties
    
    var connectingDate: Date? {
        didSet {
            stateDidChange?()
            hasStartedConnectingDidChange?()
        }
    }
    var connectDate: Date? {
        didSet {
            stateDidChange?()
            hasConnectedDidChange?()
        }
    }
    var endDate: Date? {
        didSet {
            stateDidChange?()
            hasEndedDidChange?()
        }
    }
    var isOnHold = false {
        didSet {
            stateDidChange?()
        }
    }
    
    // MARK: State change callback blocks
    
    var stateDidChange: (() -> Void)?
    var hasStartedConnectingDidChange: (() -> Void)?
    var hasConnectedDidChange: (() -> Void)?
    var hasEndedDidChange: (() -> Void)?
    
    // MARK: Derived Properties
    
    var hasStartedConnecting: Bool {
        get {
            return connectingDate != nil
        }
        set {
            connectingDate = newValue ? Date() : nil
        }
    }
    var hasConnected: Bool {
        get {
            return connectDate != nil
        }
        set {
            connectDate = newValue ? Date() : nil
        }
    }
    var hasEnded: Bool {
        get {
            return endDate != nil
        }
        set {
            endDate = newValue ? Date() : nil
        }
    }
    var duration: TimeInterval {
        guard let connectDate = connectDate else {
            return 0
        }
        
        return Date().timeIntervalSince(connectDate)
    }
    
    init(delegate: AACallCenterDelegate) {
        super.init()
        self.delegate = delegate
    }
    
    deinit {
        provider?.invalidate()
    }
    
    func setup(appName: String, appIcon: UIImage?) {
        let providerConfiguration = CXProviderConfiguration(localizedName: appName)
        providerConfiguration.supportsVideo = false
        providerConfiguration.maximumCallsPerCallGroup = 1
        providerConfiguration.maximumCallGroups = 1
        providerConfiguration.supportedHandleTypes = [.generic]
        
        if let icon = appIcon {
            providerConfiguration.iconTemplateImageData = icon.pngData()
        }
        
        self.provider = CXProvider(configuration: providerConfiguration)
        provider?.setDelegate(self, queue: nil)
    }
    
    func showIncomingCall(of session: String, isVideo: Bool) {
        
        let callId = jlong(session)
        let call: ACCallVM
        call = ActorSDK.sharedActor().messenger.getCallWithCallId(callId!)
        
        let user = Actor.getUserWithUid(call.peer.peerId)
        let userName = user.getNameModel().get()
        
        let callUpdate = CXCallUpdate()
        callUpdate.remoteHandle = CXHandle(type: .generic, value: String(call.peer.peerId))
        callUpdate.localizedCallerName = userName!
        callUpdate.hasVideo = isVideo
        callUpdate.supportsDTMF = false
        callUpdate.supportsHolding  = false
        callUpdate.supportsGrouping = false
        
        let uuid = pairedUUID(of: session)
        print("CallKit: showIncomingCall UUID: \(pairedUUID(of: session))")

        provider?.reportNewIncomingCall(with: uuid, update: callUpdate, completion: { error in
            if let error = error {
                print("reportNewIncomingCall error: \(error.localizedDescription)")
            }
        })
    }
    
    func startOutgoingCall(of session: String, isVideo: Bool) {
        
        let callId = jlong(session)
        let call: ACCallVM
        call = ActorSDK.sharedActor().messenger.getCallWithCallId(callId!)
        
        let user = Actor.getUserWithUid(call.peer.peerId)
        let userName = user.getNameModel().get()
        
        let handle = CXHandle(type: .generic, value: String(call.peer.peerId))
        let uuid = pairedUUID(of: session)
        let startCallAction = CXStartCallAction(call: uuid, handle: handle)
        startCallAction.isVideo = isVideo
        try? AVAudioSession.sharedInstance().setCategory(.playAndRecord, mode: .default, options: [])
        try? AVAudioSession.sharedInstance().setMode(AVAudioSession.Mode.default)
//        AAExecutions.execute(ActorSDK.sharedActor().messenger.doCall(withUid: jint(session)!))
        

        
        print("CallKit: startOutgoingCall UUID: \(uuid)")
//        provider?.reportOutgoingCall(with: uuid, startedConnectingAt: nil)
//        self.hasStartedConnectingDidChange = { [weak self] in
//        hasStartedConnecting = true
//        provider?.reportOutgoingCall(with: uuid, startedConnectingAt: self.connectingDate)
//        }
        
        hasConnected = true
        
        //        self.hasConnectedDidChange = { [weak self] in
//        provider?.reportOutgoingCall(with: uuid, connectedAt: self.connectDate)
        provider?.reportOutgoingCall(with: uuid, connectedAt: nil)

        //        }
        if let call = currentCall(of: uuid) {

            print("CallKit: setCallConnected UUID: \(uuid) isOutgoing \(call.isOutgoing) hasEnded \(call.hasEnded) hasConnected \(call.hasConnected) connectDate \(self.connectDate)")
        }
        
        let transaction = CXTransaction(action: startCallAction)
        controller.request(transaction) { (error) in
            if let error = error {
                print("startOutgoingSession failed: \(error.localizedDescription)")
            }
        }
    }
    
    func setCallConnected(of session: String) {
        let uuid = pairedUUID(of: session)

        if let call = currentCall(of: uuid), call.isOutgoing, !call.hasConnected, !call.hasEnded {
//        if let call = currentCall(of: uuid) {
        
        hasConnected = true

//        self.hasConnectedDidChange = { [weak self] in
            provider?.reportOutgoingCall(with: uuid, connectedAt: self.connectDate)
//        }
//        let call = currentCall(of: uuid)

            print("CallKit: setCallConnected UUID: \(uuid) isOutgoing \(call.isOutgoing) hasEnded \(call.hasEnded) hasConnected \(call.hasConnected) connectDate \(self.connectDate)")

//            provider?.reportOutgoingCall(with: uuid, connectedAt: nil)

        }
    }
    
    func setCallBusy(of session: String) {
        let uuid = pairedUUID(of: session)
        
//        if let call = currentCall(of: uuid), call.isOutgoing, !call.hasEnded {
        
//            hasConnected = true
            let call = currentCall(of: uuid)

//            provider?.reportOutgoingCall(with: uuid, connectedAt: self.connectDate)
            provider?.reportCall(with: uuid, endedAt: nil, reason: CXCallEndedReason.unanswered)

            
        print("CallKit: setCallConnected UUID: \(uuid) isOutgoing \(call?.isOutgoing) hasEnded \(call?.hasEnded) hasConnected \(call?.hasConnected) connectDate \(self.connectDate)")
        
//        }
    }
    
    func muteAudio(of session: String, muted: Bool) {
        let muteCallAction = CXSetMutedCallAction(call: pairedUUID(of: session), muted: muted)
        let transaction = CXTransaction(action: muteCallAction)
        controller.request(transaction) { (error) in
            if let error = error {
                print("muteSession \(muted) failed: \(error.localizedDescription)")
            }
        }
    }
    
    func endCall(of session: String) {
        let endCallAction = CXEndCallAction(call: pairedUUID(of: session))
        print("CallKit: endCall UUID: \(pairedUUID(of: session))")
        let transaction = CXTransaction(action: endCallAction)
        controller.request(transaction) { error in
            if let error = error {
                print("endSession failed: \(error.localizedDescription)")
            }
        }
    }
    
    private func requestTransaction(_ transaction: CXTransaction) {
        controller.request(transaction) { error in
            if let error = error {
                print("Error requesting transaction: \(error)")
            } else {
                print("Requested transaction successfully")
            }
        }
    }
    
    
}

@available(iOS 10.0, *)
extension AACallCenter: CXProviderDelegate {
    func providerDidReset(_ provider: CXProvider) {
        sessionPool.removeAll()
    }
    
    func provider(_ provider: CXProvider, perform action: CXStartCallAction) {
        guard let session = pairedSession(of:action.callUUID) else {
            action.fail()
            return
        }
        print("CallKit CXStartCallAction")
        
        let callId = jlong(session)
        let call: ACCallVM
        call = ActorSDK.sharedActor().messenger.getCallWithCallId(callId!)
        
        let user = Actor.getUserWithUid(call.peer.peerId)
        let userName = user.getNameModel().get()
        
        let callUpdate = CXCallUpdate()
        callUpdate.remoteHandle = action.handle
//        callUpdate.hasVideo = true
        callUpdate.localizedCallerName = userName!
        callUpdate.supportsDTMF = false
        provider.reportCall(with: action.callUUID, updated: callUpdate)
    
        
        delegate?.callCenter(self, startCall: session)
        action.fulfill()
        
//        hasStartedConnecting = true
//        provider.reportOutgoingCall(with: action.callUUID, startedConnectingAt: self.connectDate)
        provider.reportOutgoingCall(with: action.callUUID, startedConnectingAt: nil)


    }
    
    func provider(_ provider: CXProvider, perform action: CXSetMutedCallAction) {
        guard let session = pairedSession(of:action.callUUID) else {
            action.fail()
            return
        }
        
        delegate?.callCenter(self, muteCall: action.isMuted, session: session)
        action.fulfill()
    }
    
    func provider(_ provider: CXProvider, perform action: CXAnswerCallAction) {
        guard let session = pairedSession(of:action.callUUID) else {
            action.fail()
            return
        }
        let callId = jlong(session)
        AAAudioManager.sharedAudio().callAnswered(Actor.getCallWithCallId(callId!))

        delegate?.callCenter(self, answerCall: session)
        action.fulfill()
    }
    
    func provider(_ provider: CXProvider, perform action: CXEndCallAction) {
        guard let session = pairedSession(of:action.callUUID) else {
            action.fail()
            return
        }
        
        if let call = currentCall(of: action.callUUID) {
            if call.isOutgoing || call.hasConnected {
                delegate?.callCenter(self, endCall: session)
            } else {
                delegate?.callCenter(self, declineCall: session)
            }
        }
        
        sessionPool.removeAll()
        action.fulfill()
    }
    
    func provider(_ provider: CXProvider, didActivate audioSession: AVAudioSession) {
        delegate?.callCenterDidActiveAudioSession(self)
    }
}

@available(iOS 10.0, *)
extension AACallCenter {
    func pairedUUID(of session: String) -> UUID {
        for (u, s) in sessionPool {
            if s == session {
                return u
            }
        }
        
        let uuid = UUID()
        sessionPool[uuid] = session
        return uuid
    }
    
    func pairedSession(of uuid: UUID) -> String? {
        return sessionPool[uuid]
    }
    
    func currentCall(of uuid: UUID) -> CXCall? {
        let calls = controller.callObserver.calls
        if let index = calls.firstIndex(where: {$0.uuid == uuid}) {
            return calls[index]
        } else {
            return nil
        }
    }
}

