//
//  Copyright (c) 2014-2016 Actor LLC. <https://actor.im>
//

import Foundation
import AVFoundation
//import WebRTC
import Intents

//extension AACallViewController : RTCEAGLVideoViewDelegate {
//    func remoteView(_ remoteView: RTCEAGLVideoView, didChangeVideoSize size: CGSize) {}
//}


open class AACallViewController: AAViewController, ACFileEventCallback {

    @available(iOS 10.0, *)
    private lazy var callCenter = AACallCenter(delegate: self)

    
    public let audioManager =  AAAudioManager.sharedAudio()
    
    public let binder = AABinder()
    public let callId: jlong
    public let call: ACCallVM
    public let senderAvatar: AAAvatarView = AAAvatarView()
    //    open let avatar: ACAvatar
    public let peerTitle = UILabel()
    public let callState = UILabel()

    private let tone = SoundManager.shared
    
    var remoteView = RTCEAGLVideoView()
    var remoteVideoSize: CGSize!
    var localView = RTCEAGLVideoView()
    var localVideoSize: CGSize!


    var localVideoTrack: RTCVideoTrack!
    var remoteVideoTrack: RTCVideoTrack!

    public let answerCallButton = UIButton()
    public let answerCallButtonText = UILabel()
    public let declineCallButton = UIButton()
    public let declineCallButtonText = UILabel()

    public let muteButton = AACircleButton(size: 72)
//    open let videoButton = AACircleButton(size: 40)
    public let videoButton = UIButton(type: .custom)
    public let speakerButton = AACircleButton(size: 72)

    
    var remoteViewTopConstraint:NSLayoutConstraint?
    var remoteViewRightConstraint:NSLayoutConstraint?
    var remoteViewLeftConstraint:NSLayoutConstraint?
    var remoteViewBottomConstraint:NSLayoutConstraint?
    var localViewWidthConstraint:NSLayoutConstraint?
    var localViewHeightConstraint:NSLayoutConstraint?
    var localViewRightConstraint:NSLayoutConstraint?
    var localViewBottomConstraint:NSLayoutConstraint?
    var footerViewBottomConstraint:NSLayoutConstraint?
    var buttonContainerViewLeftConstraint:NSLayoutConstraint?
    
    var   isZoom:Bool = false; //used for double tap remote view
    
//    fileprivate var audioRouter = AAAudioRouter()
    
    var isScheduledDispose = false
    var timer: Timer?

    fileprivate var file: ACFileReference?
    
    public init(callId: jlong) {
        self.callId = callId
        self.call = ActorSDK.sharedActor().messenger.getCallWithCallId(callId)
        
        super.init()
        
        if #available(iOS 10.0, *) {
            self.callCenter.delegate = self
        } else {
        }
        
        
        if Actor.isLoggedIn() {
            Actor.subscribe(toDownloads: self)
        }
    }

    public required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
//    var avatarBg:UIImageView = UIImageView() {
//        didSet { setNeedsDisplay() }
//    }
    var avatarBg:UIImageView = UIImageView()

    

    
    open override func viewDidLoad() {
        super.viewDidLoad()
        
//        self.view.backgroundColor = UIColor(red:0.27, green:0.45, blue:0.65, alpha:1.0)
        self.view.backgroundColor = .clear
        
        
        if #available(iOS 10.0, *) {
            self.callCenter.setup(appName: "Alo", appIcon: UIImage.bundled("logo"))
        } else {
            // Fallback on earlier versions
        }
        
        let user = Actor.getUserWithUid(call.peer.peerId)
        binder.bind(user.getNameModel(), closure: { (value: String?) -> () in
            self.peerTitle.text = value
        })
        binder.bind(user.getAvatarModel(), closure: { (value: ACAvatar?) -> () in
            self.senderAvatar.bind(user.getNameModel().get(), id: Int(user.getId()), avatar: value)
        })
        //
        //                let avatar = self.group.getAvatarModel().get()
        //                if avatar != nil && avatar?.fullImage != nil {
        //
        //                    let full = avatar?.fullImage.fileReference
        //                    let small = avatar?.smallImage.fileReference
        //                    let size = CGSize(width: Int((avatar?.fullImage.width)!), height: Int((avatar?.fullImage.height)!))
        //
        //                    self.present(AAPhotoPreviewController(file: full!, previewFile: small, size: size, fromView: view), animated: true, completion: nil)
        //                }
        //
        //                self.view.layer.im
        //
        //        avatar.fullImage
        
//        }
        

        
//        if let fp = filePath {
////            self.view.backgroundColor = UIColor(patternImage: UIImage(contentsOfFile: fp)!)
//            let downloadQueue = DispatchQueue(label: "im.alo.downloadimage")
//
//            downloadQueue.async(){
//
//                //            var data = NSData(contentsOfURL: NSURL(string: url)!)
//
//                var avatarBg: UIImage?
//
//                if (fp != nil){
//
//                    avatarBg = UIImage(contentsOfFile: fp)!
//
//                }
//
//                DispatchQueue.main.async(){
//
//                    //                imageView.image = image
//                    Actor.startDownloading(with: full!)
//                    self.setNeedsDisplay()
//
//                }
//
//            }
//        }

//        self.view.backgroundColor = UIColor(patternImage: avatarBg)

        
//                }
        //
        //        if let img = UIImage(contentsOfFile: CocoaFiles.pathFromDescriptor(full)) {
        //            let previewImage = PreviewImage(image: img)
        //            let previewController = AAPhotoPreviewController(photos: [previewImage,previewImage], fromView: self.preview)
        //            previewController.autoShowBadge = true
        //            self.controller.present(previewController, animated: true, completion: nil)
        //            self.view.backgroundColor = UIColor(patternImage: UIImage(named: img)!)
        //        }




        //
        // Buttons
        //

        answerCallButton.setImage(UIImage.bundled("ic_call_answer_44")!.tintImage(UIColor.white), for: UIControl.State())
        answerCallButton.setBackgroundImage(Imaging.roundedImage(UIColor(red: 61/255.0, green: 217/255.0, blue: 90/255.0, alpha: 1.0), size: CGSize(width: 74, height: 74), radius: 37), for: UIControl.State())
        answerCallButton.viewDidTap = {
            Actor.answerCall(withCallId: self.callId)
        }
        answerCallButtonText.font = UIFont.thinSystemFontOfSize(16)
        answerCallButtonText.textColor = UIColor.white
        answerCallButtonText.textAlignment = NSTextAlignment.center
//        answerCallButtonText.text = AALocalized("CallsAnswer")
        answerCallButtonText.bounds = CGRect(x: 0, y: 0, width: 72, height: 44)
        answerCallButtonText.numberOfLines = 2

        declineCallButton.setImage(UIImage.bundled("ic_call_end_44")!.tintImage(UIColor.white), for: UIControl.State())
        declineCallButton.setBackgroundImage(Imaging.roundedImage(UIColor(red: 217/255.0, green: 80/255.0, blue:61/255.0, alpha: 1.0), size: CGSize(width: 74, height: 74), radius: 37), for: UIControl.State())
        declineCallButton.viewDidTap = {
            let outPeer = String(self.call.callId)
            if #available(iOS 10.0, *) {
                self.callCenter.endCall(of: outPeer)
            } else {
                // Fallback on earlier versions
            }
            Actor.endCall(withCallId: self.callId)
        }
        declineCallButtonText.font = UIFont.thinSystemFontOfSize(16)
        declineCallButtonText.textColor = UIColor.white
        declineCallButtonText.textAlignment = NSTextAlignment.center
//        declineCallButtonText.text = AALocalized("CallsDecline")
        declineCallButtonText.bounds = CGRect(x: 0, y: 0, width: 72, height: 44)
        declineCallButtonText.numberOfLines = 2


        //
        // Call Control
        //

        muteButton.image = UIImage.bundled("ic_mic_off_44")
//        muteButton.title = AALocalized("CallsMute")
        muteButton.alpha = 0
        muteButton.button.viewDidTap = {
            Actor.toggleCallMute(withCallId: self.callId)
        }
        
        
        
        speakerButton.image = UIImage.bundled("CallButtonSpeaker")
//        speakerButton.title = AALocalized("CallsMute")
        speakerButton.alpha = 0
        speakerButton.button.viewDidTap = {
            self.audioManager.speakerEnable()
            self.speakerButtonFilled()
        }
        


//        videoButton.image = UIImage.bundled("ic_video_44")
        videoButton.setImage(UIImage.bundled("ic_video_off_44"), for: .normal)

//        videoButton.title = AALocalized("CallsVideo")
        videoButton.alpha = 0

        videoButton.viewDidTap = {
            if !AVCaptureState.isVideoDisabled {
                Actor.toggleVideoEnabled(withCallId: self.callId)
            } else {
                // show alert for audio permission disabled
                let error = ErrorDomain.videoPermissionDenied
                self.alertUser(error)
            }
        }


        //
        // Video ViewPorts
        //

        localView.backgroundColor = UIColor.white
        localView.alpha = 0
        localView.layer.cornerRadius = 5
        localView.layer.borderWidth = 0
        localView.layer.borderColor = UIColor.gray.cgColor
        localView.layer.shadowRadius = 1
        localView.clipsToBounds = true
        localView.contentMode = .scaleAspectFill

        remoteView.alpha = 0
        remoteView.backgroundColor = UIColor.black
        remoteView.delegate = self as? RTCVideoViewDelegate
        remoteView.contentMode = .scaleAspectFit
//        remoteView.layoutMargins = UIEdgeInsets.zero
        
        remoteView.viewDidTap = {
            
            
            if self.muteButton.isHidden || self.speakerButton.isHidden || self.videoButton.isHidden || self.answerCallButton.isHidden || self.declineCallButton.isHidden || self.callState.isHidden
            {
                self.muteButton.showViewAnimated()
                self.speakerButton.showViewAnimated()
                self.videoButton.showViewAnimated()
                
                self.answerCallButton.isHidden = false
                self.declineCallButton.isHidden = false
                
                self.callState.isHidden = false
                
            } else {
                
                self.muteButton.hideViewAnimated()
                self.speakerButton.hideViewAnimated()
                self.videoButton.hideViewAnimated()
                
                self.answerCallButton.isHidden = true
                self.declineCallButton.isHidden = true
                
                self.callState.isHidden = true
            }
        }
        
        

        //
        // Peer Info
        //

        peerTitle.textColor = UIColor.white.alpha(0.87)
        peerTitle.textAlignment = NSTextAlignment.center
        peerTitle.font = UIFont.thinSystemFontOfSize(42)
        peerTitle.minimumScaleFactor = 0.3

        callState.textColor = UIColor.white
        callState.textAlignment = NSTextAlignment.center
        callState.font = UIFont.systemFont(ofSize: 19)

        avatarBg = {
            let avatarBg = UIImageView()

            let avatar = user.getAvatarModel().get()
            if avatar == nil {
                self.file = nil
                
            } else {
                self.file = avatar!.smallImage?.fileReference
                
            }
            
            var filePath: String?
            var _file = file
            
            if _file != nil {
                let desc = Actor.findDownloadedDescriptor(withFileId: _file!.getFileId())
                if desc != nil {
                    filePath = CocoaFiles.pathFromDescriptor(desc!)
                } else {
                    
                    filePath = nil
                    
                    DispatchQueue.main.async(){
                        Actor.startDownloading(with: _file!)

                    }
                    
                }
            } else {
                filePath = nil
            }

            
            
            if filePath == nil {
                avatarBg.image = UIImage.bundled("chat_bg.png")
                if let bg = Actor.getSelectedWallpaper(){
                    if bg != "default" {
                        if bg.startsWith("local:") {
                            avatarBg.image = UIImage.bundled(bg.skip(6))
                        } else {
                            let path = CocoaFiles.pathFromDescriptor(bg.skip(5))
                            avatarBg.image = UIImage(contentsOfFile:path)
                        }
                    }
                }
            } else {
                avatarBg.image = UIImage(contentsOfFile: filePath!)!
            }
            //            avatarFull = UIImage(contentsOfFile: filePath)!
            avatarBg.contentMode = .scaleAspectFill
            avatarBg.isUserInteractionEnabled = true
            avatarBg.clipsToBounds = true
            self.view.setNeedsDisplay()
            return avatarBg
        }()
        self.view.addSubview(avatarBg)
//        self.avatarBg.setNeedsDisplay()

        let blurEffect = UIBlurEffect(style: UIBlurEffect.Style.dark)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = view.bounds
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.view.addSubview(blurEffectView)

        

        self.view.addSubview(senderAvatar)
        self.view.addSubview(peerTitle)
        self.view.addSubview(remoteView)
        self.view.addSubview(callState)
        self.view.addSubview(answerCallButton)
        self.view.addSubview(answerCallButtonText)
        self.view.addSubview(declineCallButton)
        self.view.addSubview(declineCallButtonText)
        self.view.addSubview(muteButton)
        self.view.addSubview(speakerButton)
        self.view.addSubview(videoButton)
        self.view.addSubview(localView)
        
//        self.remoteView.translatesAutoresizingMaskIntoConstraints = no
//        self.localView.translatesAutoresizingMaskIntoConstraints = no

        
//        let centerX = NSLayoutConstraint(item: self.remoteView,
//                                         attribute: NSLayoutAttribute.centerX,
//                                         relatedBy: NSLayoutRelation.equal,
//                                         toItem: self.view,
//                                         attribute: NSLayoutAttribute.centerX,
//                                         multiplier: 1,
//                                         constant: 0);
//        self.view.addConstraint(centerX)
//        let centerY = NSLayoutConstraint(item: self.remoteView,
//                                         attribute: NSLayoutAttribute.centerY,
//                                         relatedBy: NSLayoutRelation.equal,
//                                         toItem: self.view,
//                                         attribute: NSLayoutAttribute.centerY,
//                                         multiplier: 1,
//                                         constant: 0);
//        self.view.addConstraint(centerY)
//        let width = NSLayoutConstraint(item: self.remoteView,
//                                       attribute: NSLayoutAttribute.width,
//                                       relatedBy: NSLayoutRelation.equal,
//                                       toItem: self.view,
//                                       attribute: NSLayoutAttribute.width,
//                                       multiplier: 1,
//                                       constant: 0);
//        self.view.addConstraint(width)
//        let height = NSLayoutConstraint(item: self.remoteView,
//                                        attribute: NSLayoutAttribute.height,
//                                        relatedBy: NSLayoutRelation.equal,
//                                        toItem: self.view,
//                                        attribute: NSLayoutAttribute.height,
//                                        multiplier: 1,
//                                        constant: 0);
//        self.view.addConstraint(height)
        
        
    }
    
    open func speakerButtonFilled() {
        if audioManager.speaker {
            self.speakerButton.filled = true
        } else {
            self.speakerButton.filled = false
        }
    }
    

    override open func viewDidLayoutSubviews() {
        avatarBg.frame = view.frame

        
    }
    
    open override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()


        senderAvatar.frame = CGRect(x: (self.view.width - 104) / 2, y: 60, width: 108, height: 108)
        peerTitle.frame = CGRect(x: 22, y: senderAvatar.bottom + 22, width: view.width - 44, height: 42)
        callState.frame = CGRect(x: 0, y: peerTitle.bottom + 8, width: view.width, height: 22)

        layoutButtons()
        layoutVideo()
    }

//    open func videoView(_ videoView: RTCEAGLVideoView!, didChangeVideoSize size: CGSize) {
//        if videoView == remoteView {
//            self.remoteVideoSize = size
//        } else if videoView == localView {
//            self.localVideoSize = size
//        }
//
//        layoutVideo()
//    }
    
//    open func videoView(_ videoView: RTCEAGLVideoView, didChangeVideoSize size: CGSize) {
//        let orientation: UIInterfaceOrientation = UIApplication.shared.statusBarOrientation
//        UIView.animate(withDuration: 0.4, animations: { () -> Void in
//            let containerWidth: CGFloat = self.view.frame.size.width
//            let containerHeight: CGFloat = self.view.frame.size.height
//            let defaultAspectRatio: CGSize = CGSize(width: 16, height: 9)
//            if videoView == self.localView {
//                self.localVideoSize = size
//                let aspectRatio: CGSize = size.equalTo(CGSize.zero) ? defaultAspectRatio : size
//                var videoRect: CGRect = self.view.bounds
//                if (self.remoteVideoTrack != nil) {
//                    videoRect = CGRect(x: 0.0, y: 0.0, width: self.view.frame.size.width / 4.0, height: self.view.frame.size.height / 4.0)
//                    if orientation == UIInterfaceOrientation.landscapeLeft || orientation == UIInterfaceOrientation.landscapeRight {
//                        videoRect = CGRect(x: 0.0, y: 0.0, width: self.view.frame.size.height / 4.0, height: self.view.frame.size.width / 4.0)
//                    }
//                }
//                let videoFrame: CGRect = AVMakeRect(aspectRatio: aspectRatio, insideRect: videoRect)
//                self.localViewWidthConstraint!.constant = videoFrame.size.width
//                self.localViewHeightConstraint!.constant = videoFrame.size.height
//                if (self.remoteVideoTrack != nil) {
//                    self.localViewBottomConstraint!.constant = 28.0
//                    self.localViewRightConstraint!.constant = 28.0
//                }
//                else{
//                    self.localViewBottomConstraint!.constant = containerHeight/2.0 - videoFrame.size.height/2.0
//                    self.localViewRightConstraint!.constant = containerWidth/2.0 - videoFrame.size.width/2.0
//                }
//            }
//            else if videoView == self.remoteView {
//                self.remoteVideoSize = size
//                let aspectRatio: CGSize = size.equalTo(CGSize.zero) ? defaultAspectRatio : size
//                let videoRect: CGRect = self.view.bounds
//                var videoFrame: CGRect = AVMakeRect(aspectRatio: aspectRatio, insideRect: videoRect)
////                if self.isZoom {
////                    let scale: CGFloat = max(containerWidth / videoFrame.size.width, containerHeight / videoFrame.size.height)
////                    videoFrame.size.width *= scale
////                    videoFrame.size.height *= scale
////                }
////                self.remoteViewTopConstraint!.constant = (containerHeight / 2.0 - videoFrame.size.height / 2.0)
////                self.remoteViewBottomConstraint!.constant = (containerHeight / 2.0 - videoFrame.size.height / 2.0)
////                self.remoteViewLeftConstraint!.constant = (containerWidth / 2.0 - videoFrame.size.width / 2.0)
////                self.remoteViewRightConstraint!.constant = (containerWidth / 2.0 - videoFrame.size.width / 2.0)
////
////                yourView.addConstraint(remoteViewTopConstraint)
////                NSLayoutConstraint.activate([remoteViewTopConstraint])
//
//
//                self.view.layoutIfNeeded()
//            }
//            self.view.layoutIfNeeded()
//        })
//    }
    
//    public func videoView(_ videoView: RTCEAGLVideoView!, didChangeVideoSize size: CGSize) {
//        // just keep aspect ratio
//        var viewSize : CGSize? = nil
//        if self.localView == videoView {
//            viewSize = CGSize(width: (self.localView.frame).size.width , height: (self.localView.frame).size.width * size.height / size.width)
//            self.localView.frame = CGRect(origin: (self.localView.frame).origin, size: viewSize!)
//        } else if self.remoteView == videoView {
//            viewSize = CGSize(width: (self.remoteView.frame).size.width , height: (self.remoteView.frame).size.width * size.height / size.width)
//            self.remoteView.frame = CGRect(origin: (self.remoteView.frame).origin, size: viewSize!)
//            if (self.remoteView.frame).size.height < self.view.frame.size.height {
//                viewSize = CGSize(width: self.view.frame.size.height * size.width / size.height, height: self.view.frame.size.height)
//                let x_orig = (self.remoteView.frame).origin.x - viewSize!.width / 2  + self.view.frame.size.width / 2
//                let y_orig = (self.remoteView.frame).origin.y
//                let newOrigin = CGPoint(x: x_orig, y: y_orig)
//                self.remoteView.frame = CGRect(origin: newOrigin, size:viewSize!)
//            }
//        }
//    }
    
    // MARK: - RTCEAGLVideoViewDelegate
    func videoView(_ videoView: RTCEAGLVideoView!, didChangeVideoSize size: CGSize) {
        let orientation = UIDevice.current.orientation
        UIView.animate(withDuration: 0.4) {
            let containerWidth = self.view.frame.size.width
            let containerHeight = self.view.frame.size.height
            let defaultAspectRatio = CGSize(width: 4, height: 3)
            if videoView == self.localView {
                // Resize the Local View depending if it is full screen or thumbnail
                self.localVideoSize = size
                let aspectRatio = __CGSizeEqualToSize(size, CGSize.zero) ? defaultAspectRatio : size
                var videoRect = self.view.bounds
                if self.remoteVideoTrack != nil {
                    videoRect = CGRect(x: 0.0, y: 0.0, width: self.view.frame.size.width/4.0, height: self.view.frame.size.height/4.0)
                    if orientation == UIDeviceOrientation.landscapeLeft || orientation == UIDeviceOrientation.landscapeRight {
                        videoRect = CGRect(x: 0.0, y: 0.0, width: self.view.frame.size.height/4.0, height: self.view.frame.size.width/4.0)
                    }
                }
                let videoFrame = AVMakeRect(aspectRatio: aspectRatio, insideRect: videoRect)
                
                // Resize the localView accordingly
//                self.localViewWidthConstraint.constant = videoFrame.size.width
//                self.localViewHeightConstraint.constant = videoFrame.size.height
//                if self.remoteVideoTrack != nil {
//                    self.localViewBottomConstraint.constant = 28.0 // bottom right corner
//                    self.localViewRightConstraint.constant = 28.0
//                } else {
//                    self.localViewBottomConstraint.constant = containerHeight/2.0 - videoFrame.size.height/2.0 // center
//                    self.localViewRightConstraint.constant = containerWidth/2.0 - videoFrame.size.width/2.0 // center
//                }
            } else if videoView == self.remoteView {
                // Resize Remote View
                self.remoteVideoSize = size
                let aspectRatio = __CGSizeEqualToSize(size, CGSize.zero) ? defaultAspectRatio : size
                let videoRect = self.view.bounds
                var videoFrame = AVMakeRect(aspectRatio: aspectRatio, insideRect: videoRect)
                if self.isZoom == true {
                    // Set Aspect Fill
                    let scale = max(containerWidth/videoFrame.size.width, containerHeight/videoFrame.size.height)
                    videoFrame.size.width *= scale
                    videoFrame.size.height *= scale
                }
//                self.remoteViewTopConstraint.constant = containerHeight/2.0 - videoFrame.size.height/2.0
//                self.remoteViewBottomConstraint.constant = containerHeight/2.0 - videoFrame.size.height/2.0
//                self.remoteViewLeftConstraint.constant = containerWidth/2.0 - videoFrame.size.width/2.0 // center
//                self.remoteViewRightConstraint.constant = containerWidth/2.0 - videoFrame.size.width/2.0 // center
            }
            self.view.layoutIfNeeded()
        }
    }
    
    open func onDownloaded(withLong fileId: jlong) {
        
        if self.file?.getFileId() == fileId {
            dispatchOnUi {
                if self.file?.getFileId() == fileId {
                    print("Call onDownloaded:")
                    self.view.setNeedsDisplay()
                    //                    self.avatarBg.setNeedsDisplay()
                    self.view.layer.setNeedsDisplay()
                    
                }
            }
        }
    }

    fileprivate func layoutButtons() {

//        speakerButton.frame = CGRect(x: (self.view.width / 3 - 84) / 2, y: self.view.height - 72 - 130, width: 84, height: 72 + 5 + 44)
        
        //speakerButton.frame = CGRect(x: 2 * self.view.width / 3 + (self.view.width / 3 - 84) / 2, y: self.view.height - 72 - 49, width: 84, height: 72 + 5 + 44)

        muteButton.frame = CGRect(x: (self.view.width / 3 - 84) / 2, y: self.view.height - 72 - 49, width: 84, height: 72 + 5 + 44)

//        videoButton.frame = CGRect(x: 2 * self.view.width / 3 + (self.view.width / 3 - 84) / 2, y: self.view.height - 72 - 49, width: 84, height: 72 + 5 + 44)
        //videoButton.frame = CGRect(x: 2 * self.view.width / 3 + (self.view.width / 3 - 24) / 2, y: self.view.height - (self.view.height - 60), width: 40, height: 40)

        
        //        if call.isVideoPreferred.boolValue {
        //            videoButton.isHidden = true
        //        } else {
        //            videoButton.isHidden = false
        //        }

        if !declineCallButton.isHidden || !answerCallButton.isHidden {
            if !declineCallButton.isHidden && !answerCallButton.isHidden {
                declineCallButton.frame = CGRect(x: 25, y: self.view.height - 72 - 49, width: 72, height: 72)
                declineCallButtonText.under(declineCallButton.frame, offset: 5)
                answerCallButton.frame = CGRect(x: self.view.width - 72 - 25, y: self.view.height - 72 - 49, width: 72, height: 72)
                answerCallButtonText.under(answerCallButton.frame, offset: 5)
            } else {
                if !answerCallButton.isHidden {
                    answerCallButton.frame = CGRect(x: (self.view.width - 72) / 2, y: self.view.height - 72 - 49, width: 72, height: 72)
                    answerCallButtonText.under(answerCallButton.frame, offset: 5)
                }
                if !declineCallButton.isHidden {
                    declineCallButton.frame = CGRect(x: (self.view.width - 72) / 2, y: self.view.height - 72 - 49, width: 72, height: 72)
                    //                    declineCallButton.frame = CGRect(x: self.view.width - 72 - 25, y: self.view.height - 72 - 49, width: 72, height: 72)
                    declineCallButtonText.under(declineCallButton.frame, offset: 5)
                }
            }
        }
    }

    @objc func myPanAction(recognizer: UIPanGestureRecognizer) {
        if ((recognizer.state != UIGestureRecognizer.State.ended) &&
            (recognizer.state != UIGestureRecognizer.State.failed)) {
            recognizer.view?.center = recognizer.location(in: recognizer.view?.superview)
        }
    }
    
    fileprivate func layoutVideo() {
//        if self.remoteVideoSize == nil {
//            remoteView.frame = CGRect(x: 0, y: 0, width: self.view.width, height: self.view.height)
//        } else {
//            remoteView.frame = AVMakeRect(aspectRatio: remoteVideoSize, insideRect: view.bounds)
//        }
        remoteView.frame = CGRect(x: 0, y: 0, width: view.frame.size.width, height: view.frame.size.height)

//        if self.localVideoSize == nil {
//            localView.frame = CGRect(x: self.view.width - 100 - 10, y: 50, width: 100, height: 120)
//        } else {
//            let rect = AVMakeRect(aspectRatio: localVideoSize, insideRect: CGRect(x: 0, y: 0, width: 100, height: 120))
//            localView.frame = CGRect(x: self.view.width - rect.width - 10, y: 50, width: rect.width, height: rect.height)
//        }
        
//        localView.frame = CGRect(x: self.view.width - 100 - 10, y: 90, width: view.frame.size.width / 4, height: view.frame.size.width / 4 * 960 / 640)
        
        localView.frame = CGRect(x: self.view.width - 100 - 10, y: self.view.height - 230 - 49, width: view.frame.size.width / 4, height: view.frame.size.width / 4 * 960 / 640)
        localView.isUserInteractionEnabled = true
        
        
        
        let myPanGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(myPanAction))
        
        myPanGestureRecognizer.minimumNumberOfTouches = 1
        myPanGestureRecognizer.maximumNumberOfTouches = 1
        
        localView.addGestureRecognizer(myPanGestureRecognizer)
        
        


//        let device = UIDevice.string(for: UIDevice.deviceType())
//
//        if (device != nil) {
//            self.localVideo = RTCEAGLVideoView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.height))
//            self.localVideo.tag = self.localVideoTAG
//            self.localVideo.delegate = self
//            self.remoteVideo = RTCEAGLVideoView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.height))
//            self.remoteVideo.tag = self.remoteVideoTAG
//            self.remoteVideo.delegate = self
//        }
        
    }

//    fileprivate func CGSizeAspectFit(_ aspectRatio:CGSize, boundingSize:CGSize) -> CGSize {
//        var aspectFitSize = boundingSize
//        let mW = boundingSize.width / aspectRatio.width
//        let mH = boundingSize.height / aspectRatio.height
//        if( mH < mW )
//        {
//            aspectFitSize.width = mH * aspectRatio.width
//        }
//        else if( mW < mH )
//        {
//            aspectFitSize.height = mW * aspectRatio.height
//        }
//        return aspectFitSize
//    }
//
//    fileprivate func CGSizeAspectFill(_ aspectRatio:CGSize, minimumSize:CGSize) -> CGSize {
//        var aspectFillSize = minimumSize
//        let mW = minimumSize.width / aspectRatio.width
//        let mH = minimumSize.height / aspectRatio.height
//        if( mH > mW )
//        {
//            aspectFillSize.width = mH * aspectRatio.width
//        }
//        else if( mW > mH )
//        {
//            aspectFillSize.height = mW * aspectRatio.height
//        }
//        return aspectFillSize
//    }

    open override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        // UI Configuration

        UIApplication.shared.setStatusBarStyle(UIStatusBarStyle.lightContent, animated: true)

        UIDevice.current.isProximityMonitoringEnabled = true

        //
        // Binding State
        //

        binder.bind(call.isAudioEnabled) { (value: JavaLangBoolean?) -> () in
            self.muteButton.filled = !value!.booleanValue()
        }
        

        let user = Actor.getUserWithUid(self.call.peer.peerId)
//        let outPeer = user.getNameModel()
//        let outPeer = self.peerTitle.text!
//        let outPeer = String(self.call.peer.peerId)
        let outPeer = String(self.call.callId)


        
        binder.bind(call.state) { (value: ACCallState?) -> () in
            if (ACCallState_Enum.RINGING == value!.toNSEnum()) {
                if (self.call.isOutgoing) {
//                    Actor.changeIsBusy(true)

                    self.tone.dialingTone()
                    
                    self.muteButton.showViewAnimated()
                    self.speakerButton.showViewAnimated()
                    self.videoButton.showViewAnimated()

                    self.answerCallButton.isHidden = true
                    self.answerCallButtonText.isHidden = true
                    self.declineCallButton.isHidden = false
                    self.declineCallButtonText.isHidden = true
                


                    self.callState.text = AALocalized("CallStateDialing")
                } else {
//                    self.tone.stop()
                    self.answerCallButton.isHidden = false
                    self.answerCallButtonText.isHidden = false
                    self.declineCallButton.isHidden = false
                    self.declineCallButtonText.isHidden = false
                    self.callState.text = AALocalized("CallStateIncoming")
//                    self.call.state.change(withValue: ACCallState_Enum.RINGING_REACHED)
                    if #available(iOS 10.0, *) {
                        self.callCenter.showIncomingCall(of: outPeer, isVideo: false)
//                        AAAudioRouter.sharedAudio().configureAudioSession()
                    } else {
                        // Fallback on earlier versions
                    }
                }

                self.layoutButtons()

            } else if (ACCallState_Enum.RINGING_REACHED == value!.toNSEnum()) {
                if (self.call.isOutgoing) {
//                    Actor.changeIsBusy(true)
                    

                    if #available(iOS 10.0, *) {
                        self.callCenter.startOutgoingCall(of: outPeer, isVideo: false)
                        // AAAudioRouter.sharedAudio().configureAudioSession()
                    } else {
                        // Fallback on earlier versions
                    }
                    self.tone.stop()
                    dispatchAfterOnUi(0.5) {
                        self.tone.ringingTone()
                    }
                    self.muteButton.showViewAnimated()
                    self.speakerButton.showViewAnimated()
                    self.videoButton.showViewAnimated()
                    
                    self.answerCallButton.isHidden = true
                    self.answerCallButtonText.isHidden = true
                    self.declineCallButton.isHidden = false
                    self.declineCallButtonText.isHidden = true
                    if #available(iOS 10.0, *) {
//                        self.callCenter.startOutgoingCall(of: self.peerTitle.text!, isVideo: false)
//                        self.callCenter.startOutgoingCall(of: outPeer.get(), isVideo: false)
//                        AAAudioRouter.sharedAudio().configureAudioSession()
                    } else {
                        // Fallback on earlier versions
                    }
                    self.callState.text = AALocalized("CallStateRinging")
                }

            } else if (ACCallState_Enum.CONNECTING == value!.toNSEnum()) {
                self.tone.stop()
                dispatchAfterOnUi(0.5) {
                    self.tone.connectingTone()
                }
                self.muteButton.showViewAnimated()
                self.speakerButton.showViewAnimated()
                self.videoButton.showViewAnimated()

                self.answerCallButton.isHidden = true
                self.answerCallButtonText.isHidden = true
                self.declineCallButton.isHidden = false
                self.declineCallButtonText.isHidden = true

                self.callState.text = AALocalized("CallStateConnecting")

                self.layoutButtons()


            } else if (ACCallState_Enum.IN_PROGRESS == value!.toNSEnum()) {
                
                if (self.call.isOutgoing) {

                    if #available(iOS 10.0, *) {
                        self.callCenter.setCallConnected(of: outPeer)
                        
                    } else {
                        // Fallback on earlier versions
                    }

                }
                self.tone.stop()
                dispatchAfterOnUi(0.5) {
                    self.tone.connectTone()
                }
                self.muteButton.showViewAnimated()
                self.speakerButton.showViewAnimated()
                self.videoButton.showViewAnimated()

                self.answerCallButton.isHidden = true
                self.answerCallButtonText.isHidden = true
                self.declineCallButton.isHidden = false
                self.declineCallButtonText.isHidden = true

                self.startTimer()
                
                self.layoutButtons()
                self.tone.stop()
                AAAudioManager.sharedAudio().callAnswered(Actor.getCallWithCallId(self.callId))

//                Actor.changeIsBusy(true)

            } else if (ACCallState_Enum.BUSY == value!.toNSEnum()) {
                
                self.tone.stop()
                dispatchAfterOnUi(0.5) {
                    self.tone.busyTone()
                }
                if #available(iOS 10.0, *) {
//                    self.callCenter.setCallConnected(of: outPeer)
//                    self.callCenter.setCallBusy(of: outPeer)
                    self.callCenter.endCall(of: outPeer)

                    
                } else {
                    // Fallback on earlier versions
                }
                
                dispatchAfterOnUi(7) {
                    Actor.endCall(withCallId: self.callId)
                }
                
                self.muteButton.hideViewAnimated()
                self.speakerButton.hideViewAnimated()
                self.videoButton.hideViewAnimated()
                
                self.answerCallButton.isHidden = true
                self.answerCallButtonText.isHidden = true
                self.declineCallButton.isHidden = false
                self.declineCallButtonText.isHidden = true
                
                self.callState.text = AALocalized("CallStateBusy")
                
                self.layoutButtons()
            } else if (ACCallState_Enum.NO_ANSWER == value!.toNSEnum()) {
                
                self.tone.stop()
                dispatchAfterOnUi(1) {
                    self.tone.busyTone()
                }
                

                if #available(iOS 10.0, *) {
                    //                    self.callCenter.setCallConnected(of: outPeer)
                    //                    self.callCenter.setCallBusy(of: outPeer)
                    self.callCenter.endCall(of: outPeer)

                    
                } else {
                    // Fallback on earlier versions
                }
                
                dispatchAfterOnUi(7) {
                    Actor.endCall(withCallId: self.callId)
                }
                
                self.muteButton.hideViewAnimated()
                self.speakerButton.hideViewAnimated()
                self.videoButton.hideViewAnimated()
                
                self.answerCallButton.isHidden = true
                self.answerCallButtonText.isHidden = true
                self.declineCallButton.isHidden = false
                self.declineCallButtonText.isHidden = true
                
                dispatchAfterOnUi(0.5) {
                    self.callState.text = AALocalized("CallStateNoAnswer")
                }
                
                self.layoutButtons()
            } else if (ACCallState_Enum.NOT_AVAILABLE == value!.toNSEnum()) {
                
                self.tone.stop()
                dispatchAfterOnUi(0.5) {
                    self.tone.failTone()
                }
//                dispatchAfterOnUi(4) {
//                    Actor.endCall(withCallId: self.callId)
//                }
                if #available(iOS 10.0, *) {
                    //                    self.callCenter.setCallConnected(of: outPeer)
                    //                    self.callCenter.setCallBusy(of: outPeer)
                    self.callCenter.endCall(of: outPeer)
                    
                } else {
                    // Fallback on earlier versions
                }
                
                self.muteButton.hideViewAnimated()
                self.speakerButton.hideViewAnimated()
                self.videoButton.hideViewAnimated()
                
                self.answerCallButton.isHidden = true
                self.answerCallButtonText.isHidden = true
                self.declineCallButton.isHidden = false
                self.declineCallButtonText.isHidden = true
                
                self.callState.text = AALocalized("CallStateNotAvailable")
                
                self.layoutButtons()
            } else if (ACCallState_Enum.ENDED == value!.toNSEnum()) {
                //                Actor.changeIsBusy(false)
                
                if #available(iOS 10.0, *) {
                    //                    self.callCenter.endCall(of: self.peerTitle.text!)
                    self.callCenter.endCall(of: outPeer)
                } else {
                    // Fallback on earlier versions
                }
                self.tone.endTone()
                self.muteButton.hideViewAnimated()
                self.speakerButton.hideViewAnimated()
                self.videoButton.hideViewAnimated()
                
                self.answerCallButton.isHidden = true
                self.answerCallButtonText.isHidden = true
                self.declineCallButton.isHidden = true
                self.declineCallButtonText.isHidden = true
                
                self.stopTimer()
                //                self.tone.stop()
                
                self.layoutButtons()
                
                if (!self.isScheduledDispose) {
                    self.isScheduledDispose = true
                    dispatchAfterOnUi(1.2) {
                        //                        self.tone.disconnectTone()
                        self.dismissController()
                        AAAudioRouter.sharedAudio().deactivateAudioSession()
                        //                        self.tone.stop()
                    }
                }
            } else {
//                if #available(iOS 10.0, *) {
//                    self.callCenter.endCall(of: self.peerTitle.text!)
//                } else {
//                    // Fallback on earlier versions
//                }
                fatalError("Unknown Call State!")
            }
        }



        //
        // Binding Title
        //

        if (call.peer.peerType == ACPeerType_PRIVATE) {
            let user = Actor.getUserWithUid(call.peer.peerId)
            binder.bind(user.getNameModel(), closure: { (value: String?) -> () in
                self.peerTitle.text = value
            })
            binder.bind(user.getAvatarModel(), closure: { (value: ACAvatar?) -> () in
                self.senderAvatar.bind(user.getNameModel().get(), id: Int(user.getId()), avatar: value)
            })
        } else if (call.peer.peerType == ACPeerType_GROUP) {
            let group = Actor.getGroupWithGid(call.peer.peerId)
            binder.bind(group.name, closure: { (value: String?) -> () in
                self.peerTitle.text = value
            })
            binder.bind(group.avatar, closure: { (value: ACAvatar?) -> () in
                self.senderAvatar.bind(group.name.get(), id: Int(group.getId()), avatar: value)
            })
        }
//        if (call.state.get().
        
//        if self.audioManager.endCall {
//            if #available(iOS 10.0, *) {
//                print("CallCenter EndCall")
//                self.callCenter.endCall(of: self.peerTitle.text!)
//            } else {
//                // Fallback on earlier versions
//            }
//        }


        //
        // Binding Video
        //

        // Calls Supported only in Private Chats
        if call.peer.isPrivate {

            // Bind Video Button
            binder.bind(call.isVideoEnabled) { (value: JavaLangBoolean!) -> () in
//                self.videoButton.filled = value.booleanValue()
                if (value.booleanValue() == true) {
                    self.videoButton.setImage(UIImage.bundled("ic_video_44"), for: .normal)
                } else {
                    self.videoButton.setImage(UIImage.bundled("ic_video_off_44"), for: .normal)
                }

                self.audioManager.speakerEnabled(value.booleanValue())
                self.speakerButtonFilled()

            }

            // Local Video can be only one, so we can just keep active track reference and handle changes
            binder.bind(call.ownVideoTracks, closure: { (videoTracks: ACArrayListMediaTrack?) in
                var needUnbind = true
                if videoTracks!.size() > 0 {

                    let track = (videoTracks!.getWith(0) as! CocoaVideoTrack).videoTrack
                    if self.localVideoTrack != track {
                        if self.localVideoTrack != nil {
                            self.localVideoTrack.remove(self.localView)
                        }
                        self.localVideoTrack = track
                        self.localView.showViewAnimated()
                        track.add(self.localView)
                    }
                    needUnbind = false
                }
                if needUnbind {
                    if self.localVideoTrack != nil {
                        self.localVideoTrack.remove(self.localView)
                        self.localVideoTrack = nil
                    }
                    self.localView.hideViewAnimated()
                }
            })

            // In Private Calls we can have only one video stream from other side
            // We will assume only one active peer connection
            binder.bind(call.theirVideoTracks, closure: { (videoTracks: ACArrayListMediaTrack?) in
                var needUnbind = true
                if videoTracks!.size() > 0 {

                    let track = (videoTracks!.getWith(0) as! CocoaVideoTrack).videoTrack
                    if self.remoteVideoTrack != track {
                        if self.remoteVideoTrack != nil {
                            self.remoteVideoTrack.remove(self.remoteView)
                        }
                        self.remoteVideoTrack = track
                        self.remoteView.showViewAnimated()
                        self.senderAvatar.hideViewAnimated()
                        self.peerTitle.hideViewAnimated()
                        track.add(self.remoteView)
                    }
                    needUnbind = false
                }
                if needUnbind {
                    if self.remoteVideoTrack != nil {
                        self.remoteVideoTrack.remove(self.remoteView)
                        self.remoteVideoTrack = nil
                    }
                    self.remoteView.hideViewAnimated()
                    self.senderAvatar.showViewAnimated()
                    self.peerTitle.showViewAnimated()
                }
            })

        } else {
//            self.videoButton.filled = false
            self.videoButton.isEnabled = false
        }
    }

    open override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.tone.disconnectTone()
        UIDevice.current.isProximityMonitoringEnabled = false
        UIApplication.shared.setStatusBarStyle(ActorSDK.sharedActor().style.vcStatusBarStyle, animated: true)
//        if #available(iOS 10.0, *) {
//            self.callCenter.endCall(of: self.peerTitle.text!)
//        } else {
//            // Fallback on earlier versions
//        }
        self.tone.stop()
        binder.unbindAll()
    }


    //
    // Timer
    //

    func startTimer() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(AACallViewController.updateTimer), userInfo: nil, repeats: true)
        updateTimer()
    }

    @objc func updateTimer() {
        if call.callStart > 0 {
            let end = call.callEnd > 0 ? call.callEnd : jlong(Date().timeIntervalSince1970 * 1000)
            let secs = Int((end - call.callStart) / 1000)

            let seconds = secs % 60
            let minutes = secs / 60

            self.callState.text = NSString(format: "%0.2d:%0.2d", minutes, seconds) as String
        } else {
            self.callState.text = "0:00"
            self.callState.isHidden = true
        }
    }

    func stopTimer() {
        timer?.invalidate()
        timer = nil
        updateTimer()
    }
}

//extension AACallViewController: RTCEAGLVideoViewDelegate {
//    func videoView(_ videoView: RTCEAGLVideoView, didChangeVideoSize size: CGSize) {
//        print("did change video size : \(size), TAG : \(videoView.tag)")
//        if self.localView != nil && self.remoteView != nil {
//            self.delegate.didChangedVideoSize(videoView: videoView, size: size, local: self.localVideo, remote: self.remoteView)
//        }
//    }
//}

    @available(iOS 10.0, *)
extension AACallViewController : AACallCenterDelegate {

    func callCenter(_ callCenter: AACallCenter, startCall session: String) {
        print("CallKit startCall")
    }
    
    func callCenter(_ callCenter: AACallCenter, answerCall session: String) {
//        self.callSignal?.accept()
//        self.callEnggine?.configureAudioSession()
        Actor.answerCall(withCallId: self.callId)
//        AAAudioRouter.sharedAudio().configureAudioSession()
//        AAAudioManager.sharedAudio().callAnswered(Actor.getCallWithCallId(self.callId))
//        AAAudioManager.sharedAudio().peerConnectionStarted()
//        AAAudioManager.sharedAudio().callStart(Actor.getCallWithCallId(self.callId))
    }
    
    func callCenter(_ callCenter: AACallCenter, declineCall session: String) {
        print("call declined")
//        self.finishCall()
        Actor.endCall(withCallId: self.callId)
    }
    
    func callCenter(_ callCenter: AACallCenter, muteCall muted: Bool, session: String) {

        Actor.toggleCallMute(withCallId: self.callId)
    }
    
    func callCenter(_ callCenter: AACallCenter, endCall session: String) {
//        self.finishCall()
        print("call ended")
        Actor.endCall(withCallId: self.callId)
    }
    
    func callCenterDidActiveAudioSession(_ callCenter: AACallCenter) {
//        self.callEnggine?.configureAudioSession()
        AAAudioManager.sharedAudio().callAnswered(Actor.getCallWithCallId(self.callId))
//        AAAudioManager.sharedAudio().peerConnectionStarted()
//        AAAudioRouter.sharedAudio().configureAudioSession()
//        AAAudioManager.sharedAudio().callStart(Actor.getCallWithCallId(callId))

    }
}


@available(iOS 10.0, *)
protocol StartCallConvertible {
    var startCallHandle: String? { get }
    var video: Bool? { get }
}

@available(iOS 10.0, *)
extension StartCallConvertible {
    
    var video: Bool? {
        return nil
    }
    
}

@available(iOS 10.0, *)
extension NSUserActivity: StartCallConvertible {
    
    var startCallHandle: String? {
        guard
            let interaction = interaction,
            let startCallIntent = interaction.intent as? SupportedStartCallIntent,
            let contact = startCallIntent.contacts?.first
            else {
                return nil
        }
        
        return contact.personHandle?.value
    }

    var video: Bool? {
        guard
            let interaction = interaction,
            let startCallIntent = interaction.intent as? SupportedStartCallIntent
            else {
                return nil
        }
        
        return startCallIntent is INStartVideoCallIntent
    }
    
}

@available(iOS 10.0, *)
protocol SupportedStartCallIntent {
    var contacts: [INPerson]? { get }
}

@available(iOS 10.0, *)
extension INStartAudioCallIntent: SupportedStartCallIntent {}
@available(iOS 10.0, *)
extension INStartVideoCallIntent: SupportedStartCallIntent {}

extension URL: StartCallConvertible {
    
    private struct Constants {
        static let URLScheme = "alome"
    }
    
    var startCallHandle: String? {
        guard scheme == Constants.URLScheme else {
            return nil
        }
        
        return host
    }
    
}

