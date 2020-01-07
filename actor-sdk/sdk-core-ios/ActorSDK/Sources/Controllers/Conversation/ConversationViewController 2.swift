import Foundation
import UIKit
import MobileCoreServices
import AddressBook
import AddressBookUI
import AVFoundation
//import RevealMenuController
//import ImagePickerTrayController
//import ImagePickerController
import Lightbox
import AVKit

import MBProgressHUD

import Photos
//import ISEmojiView

import NVActivityIndicatorView

class AVCaptureState {
    static var isVideoDisabled: Bool {
        let status = AVCaptureDevice.authorizationStatus(for: AVMediaType.video)
        return status == .restricted || status == .denied
    }
    
    static var isAudioDisabled: Bool {
        let status = AVCaptureDevice.authorizationStatus(for: AVMediaType.audio)
        return status == .restricted || status == .denied
    }
}

public struct ErrorDomain {
    static let videoPermissionDenied = "Access permission denied. You can enable access to camera in Privacy Settings"
    static let audioPermissionDenied = "Access permission denied. You can enable access to microphone in Privacy Settings"
}

public class ConversationViewController:
    AAConversationContentController,
    UIDocumentMenuDelegate,
    UIDocumentPickerDelegate,
    UIImagePickerControllerDelegate,
    UINavigationControllerDelegate,
    AALocationPickerControllerDelegate,
    ABPeoplePickerNavigationControllerDelegate,
    AAAudioRecorderDelegate,
    AAConvActionSheetDelegate,
    AAStickersKeyboardDelegate,
    LightboxControllerDismissalDelegate,
    GalleryControllerDelegate,
    NVActivityIndicatorViewable
{

    // Data binder
    fileprivate let binder = AABinder()
    
    // Internal state
    // Members for autocomplete
    var filteredMembers = [ACMentionFilterResult]()
    var groupMembers = [ACMentionFilterResult]()
    let content: ACPage!
    var appStyle: ActorStyle { get { return ActorSDK.sharedActor().style } }
    
    open var nextBatch: IOSByteArray! = nil
    
    //
    // Views
    //
    
    fileprivate let titleView: UILabel = UILabel()
    public let subtitleView: UILabel = UILabel()
    fileprivate let navigationView: UIView = UIView()
    fileprivate let avatarView = AABarAvatarView()
    fileprivate let backgroundView = UIImageView()
    fileprivate var audioButton: UIButton = UIButton()
    fileprivate var voiceRecorderView : AAVoiceRecorderView!
    fileprivate let inputOverlay = UIView()
    fileprivate let inputOverlayLabel = UILabel()
    
    
    
    
    ///
    fileprivate(set) var leftBarButton: BadgedBarButtonItem?
    fileprivate var leftCount = 0
    fileprivate var isBinded = false

    public var isSent = false
    
    let hud = WaitMBProgress()
    var oldNumber:Int = 0
    
    ///
    //
    // Stickers
    //
    
    fileprivate var stickersView: AAStickersKeyboard!
    open var stickersButton : UIButton!
    fileprivate var stickersOpen = false
    
    ///
    //
    // Image Picker
    //
    
    fileprivate var imagePickerView: AAConvActionSheet!
    fileprivate var imagePickerOpen = false
    
    open var gallery: GalleryController!
    public let editor: VideoEditing = VideoEditor()
    
//    let emojiView = ISEmojiView()
    
    //
    // Audio Recorder
    //
    
    open var audioRecorder: AAAudioRecorder!
    
    
    //
    // Mode
    //
    
    fileprivate var textMode:Bool!
    fileprivate var micOn: Bool! = true
    
    open var removeExcedentControllers = true
    
    fileprivate var preIid: jint?
    
    //
    // Editing Message
    //
    var editingId:Int64!
    
    
    //
    // Reply Message
    //
    var replyView: ReplyView!
    var replyString: String = ""
    
    open var isAvatarUpdated: Bool? {
        print("isAvatarUpdated 2")
        self.avatarView.reload()
        return true
    }
    
    var buttonScrollToBottom: UIButton!
    var buttonScrollToBottomMarginConstraint: NSLayoutConstraint?
    
    var activityIndicatorView: NVActivityIndicatorView?
    
//    var scrollToBottomButtonIsVisible: Bool = false {
//        didSet {
//            self.buttonScrollToBottom.superview?.layoutIfNeeded()
//
//            if self.scrollToBottomButtonIsVisible {
//                guard let collectionView = collectionView else {
//                    scrollToBottomButtonIsVisible = false
//                    return
//                }
//
//                let collectionViewBottom = collectionView.frame.origin.y + collectionView.frame.height
//                self.buttonScrollToBottomMarginConstraint?.constant = (collectionViewBottom - view.frame.height) - 40
//            } else {
//                self.buttonScrollToBottomMarginConstraint?.constant = 50
//            }
//
//            if scrollToBottomButtonIsVisible != oldValue {
//                UIView.animate(withDuration: 0.5) {
//                    self.buttonScrollToBottom.superview?.layoutIfNeeded()
//                }
//            }
//        }
//    }
    

//    func resetView() {
//        self.view.setNeedsDisplay()
//    }

    @available(iOS 10.0, *)
    private lazy var callCenter = AACallCenter(delegate: self)

    
    ////////////////////////////////////////////////////////////
    // MARK: - Init
    ////////////////////////////////////////////////////////////
    
   
    required override public init(peer: ACPeer) {
        
        // Data
        
        self.content = ACAllEvents_Chat_viewWithACPeer_(peer)
        
        // Create controller
        
        super.init(peer: peer)
        
        if #available(iOS 10.0, *) {
            self.callCenter.delegate = self
        } else {
            
        }
 
        
        //
        // Background
        //
        
        backgroundView.clipsToBounds = true
        backgroundView.contentMode = .scaleAspectFill
        //        backgroundView.backgroundColor = appStyle.chatBgColor
        
        backgroundView.image = UIImage.bundled("chat_bg.png")
        
        
        // Custom background if available
        if let bg = Actor.getSelectedWallpaper(){
            if bg != "default" {
                if bg.startsWith("local:") {
                    backgroundView.image = UIImage.bundled(bg.skip(6))
                } else {
                    let path = CocoaFiles.pathFromDescriptor(bg.skip(5))
                    backgroundView.image = UIImage(contentsOfFile:path)
                }
            }
        }
//        self.buttonScrollToBottom = UIButton(type: UIButtonType.system)
//        self.buttonScrollToBottom.setImage(UIImage.bundled("sticker_button"), for: UIControlState())
        view.insertSubview(backgroundView, at: 0)
        
//        view.addSubview(buttonScrollToBottom)
//        view.bringSubview(toFront: buttonScrollToBottom)
        
//        view.setNeedsDisplay()
        
        //
        // slk settings
        //
        self.bounces = false
        self.isKeyboardPanningEnabled = true
        self.registerPrefixes(forAutoCompletion: ["@"])
        
//        self.isInverted = false

        self.shakeToClearEnabled = true
        self.shouldScrollToBottomAfterKeyboardShows = false
        
        
        //
        // Text Input
        //
        self.textInputbar.backgroundColor = appStyle.chatInputFieldBgColor
        self.textInputbar.autoHideRightButton = false
        self.textInputbar.isTranslucent = false
        self.textInputbar.backgroundColor = UIColor(red:0.96, green:0.98, blue:0.98, alpha:1.0)
        
        //
        // Text view
        //
        self.textView.placeholder = AALocalized("ChatPlaceholder")
        self.textView.keyboardAppearance = ActorSDK.sharedActor().style.isDarkApp ? .dark : .light
        
        self.textView.delegate = self
        self.textView.keyboardType = .default
        
        //
        // Overlay
        //
        self.inputOverlay.addSubview(inputOverlayLabel)
        self.inputOverlayLabel.textAlignment = .center
        //        self.inputOverlayLabel.font = UIFont.systemFont(ofSize: 18)
        self.inputOverlayLabel.font = UIFont(name: "HelveticaNeue-Light", size: 18)
        self.inputOverlayLabel.textColor = ActorSDK.sharedActor().style.vcTintColor
        self.inputOverlay.viewDidTap = {
            self.onOverlayTap()
        }
        

        
        //
        // Add stickers button
        //
        self.stickersButton = UIButton(type: UIButton.ButtonType.system)
//        self.stickersButton.tintColor = UIColor.lightGray.withAlphaComponent(1)
        self.stickersButton.tintColor = UIColor(rgb: 0x87909a)
        self.stickersButton.setImage(UIImage.bundled("sticker_button"), for: UIControl.State())
        self.stickersButton.addTarget(self, action: #selector(ConversationViewController.changeKeyboard), for: UIControl.Event.touchUpInside)
        if(ActorSDK.sharedActor().delegate.showStickersButton()){
            self.textInputbar.addSubview(stickersButton)
        }
        
//        //
//        // Add Image Pickers button
//        //
//        self.stickersButton = UIButton(type: UIButtonType.system)
//        //        self.stickersButton.tintColor = UIColor.lightGray.withAlphaComponent(1)
//        self.stickersButton.tintColor = UIColor(rgb: 0x87909a)
//        self.stickersButton.setImage(UIImage.bundled("sticker_button"), for: UIControlState())
//        self.stickersButton.addTarget(self, action: #selector(ConversationViewController.changeKeyboard), for: UIControlEvents.touchUpInside)
//        if(ActorSDK.sharedActor().delegate.showStickersButton()){
//            self.textInputbar.addSubview(stickersButton)
//        }
        
        //
        //Editing Configurations
        //
        
        self.textInputbar.editorLeftButton.setTitle(AALocalized("NavigationCancel"), for: .normal)
        self.textInputbar.editorRightButton.setTitle(AALocalized("NavigationSave"), for: .normal)
        
        
        //
        // Check text for set right button
        //
        let checkText = Actor.loadDraft(with: peer)!.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        
        if (checkText.isEmpty) {
            
            self.textMode = false
            
//            self.rightButton.tintColor = appStyle.chatSendColor
//            self.rightButton.tintColor = UIColor(rgb: 0x280d8c)
            self.rightButton.setImage(UIImage.tinted("aa_micbutton", color: UIColor.gray), for: UIControl.State())
            self.rightButton.setTitle("", for: UIControl.State())
            self.rightButton.isEnabled = true
            
            self.rightButton.layoutIfNeeded()
            
            self.rightButton.addTarget(self, action: #selector(ConversationViewController.beginRecord(_:event:)), for: UIControl.Event.touchDown)
            self.rightButton.addTarget(self, action: #selector(ConversationViewController.mayCancelRecord(_:event:)), for: UIControl.Event.touchDragInside.union(UIControl.Event.touchDragOutside))
            self.rightButton.addTarget(self, action: #selector(ConversationViewController.finishRecord(_:event:)), for: UIControl.Event.touchUpInside.union(UIControl.Event.touchCancel).union(UIControl.Event.touchUpOutside))
            
        } else {
            
            self.textMode = true
            
            self.stickersButton.isHidden = true
            
            self.rightButton.setTitle("", for: UIControl.State())
//            self.rightButton.setTitleColor(appStyle.chatSendColor, for: UIControlState())
//            self.rightButton.setTitleColor(appStyle.chatSendDisabledColor, for: UIControlState.disabled)
//            self.rightButton.setImage(nil, for: UIControlState())
            self.rightButton.setImage(UIImage.bundled("conv_send"), for: UIControl.State())
            
            self.rightButton.isEnabled = true
            
            self.rightButton.layoutIfNeeded()
        }
        
        
        //
        // Voice Recorder
        //
        self.audioRecorder = AAAudioRecorder()
        self.audioRecorder.delegate = self
        
//        self.leftButton.setImage(UIImage.tinted("conv_attach", color: appStyle.chatAttachColor), for: UIControlState())
        self.leftButton.setImage(UIImage.tinted("conv_attach", color: UIColor(rgb: 0x87909a)), for: UIControl.State())
        
        self.leftButton.addTarget(self, action: #selector(ConversationViewController.changeImagePicker), for: UIControl.Event.touchUpInside)

        
        //
        // Navigation Title
        //
        
        navigationView.frame = CGRect(x: 0, y: 0, width: 200, height: 44)
        navigationView.autoresizingMask = UIView.AutoresizingMask.flexibleWidth
        
        titleView.font = UIFont.mediumSystemFontOfSize(17)
        titleView.adjustsFontSizeToFitWidth = false
        titleView.textAlignment = NSTextAlignment.left
        titleView.lineBreakMode = NSLineBreakMode.byTruncatingTail
        titleView.autoresizingMask = UIView.AutoresizingMask.flexibleWidth
        if #available(iOS 11.0, *) {
            titleView.textColor = UIColor.black
        } else {
            titleView.textColor = UIColor.black
        }
        
        
        subtitleView.font = UIFont.systemFont(ofSize: 12)
//        subtitleView.font = UIFont(name: "HelveticaNeue-Light", size: 13)
        
        subtitleView.adjustsFontSizeToFitWidth = true
        subtitleView.textAlignment = NSTextAlignment.left
        subtitleView.lineBreakMode = NSLineBreakMode.byTruncatingTail
        subtitleView.autoresizingMask = UIView.AutoresizingMask.flexibleWidth
        
        
        navigationView.addSubview(titleView)
        navigationView.addSubview(subtitleView)
        
        self.navigationItem.titleView = navigationView
        ///
//        let image = UIImage.bundled("sticker_button")
//        let buttonFrame: CGRect = CGRect(x: -20, y: 10, width: image!.size.width, height: image!.size.height)
//        
//        let barButton = BadgedBarButtonItem(startingBadgeValue: 0, frame: buttonFrame, image: image)
//        leftBarButton = barButton
//        leftBarButton?.badgeProperties.backgroundColor = UIColor.red
//        leftBarButton?.badgeProperties.textColor = UIColor.white
//        leftBarButton?.addTarget(self, action: #selector(ConversationViewController.changeKeyboard), for: UIControlEvents.touchUpInside)
//        //        leftBarButton?.badgeValue = 200
//        //        leftBarButton?.addTarget(self, action: #selector(ConversationViewController.beginRecord(_:event:)), for: UIControlEvents.touchDown)
//        
//        self.navigationItem.leftBarButtonItem = leftBarButton
        bindCounter()
        
        
        //
        // Navigation Avatar
        //
        avatarView.frame = CGRect(x: 0, y: 0, width: 38, height: 38)
        avatarView.viewDidTap = onAvatarTap
        
        let barItem = UIBarButtonItem(customView: avatarView)
        self.navigationItem.leftItemsSupplementBackButton = true
        self.navigationItem.leftBarButtonItems = [barItem]

        let isBot: Bool
        if (peer.isPrivate) {
            isBot = Bool(Actor.getUserWithUid(peer.peerId).isBot())
        } else {
            isBot = false
        }
        if (ActorSDK.sharedActor().enableCalls && !isBot && peer.isPrivate) {
            if ActorSDK.sharedActor().enableVideoCalls {
//                let callButtonView = AACallButton(image: UIImage.bundled("ic_call_outline_22")?.tintImage(UIColor(red:0.03, green:0.50, blue:1.00, alpha:1.0)))
//                
//                callButtonView.viewDidTap = onCallTap
//                func barItemWithView(view: UIView, rect: CGRect) -> UIBarButtonItem {
//                    let container = UIView(frame: rect)
//                    container.addSubview(view)
//                    view.frame = rect
//                    return UIBarButtonItem(customView: container)
//                }
//                let callButtonItem = barItemWithView(view: callButtonView, rect: CGRect(x: 0, y: 0, width: 25, height: 25))
//                let callButtonItem = UIBarButtonItem(customView: callButtonView)
//
//                let videoCallButtonView = AACallButton(image: UIImage.bundled("ic_video_outline_22")?.tintImage(UIColor(red:0.03, green:0.50, blue:1.00, alpha:1.0)))
//                videoCallButtonView.viewDidTap = onVideoCallTap
                
//                let callVideoButtonItem = UIBarButtonItem(customView: videoCallButtonView)
//                let callVideoButtonItem = barItemWithView(view: videoCallButtonView, rect: CGRect(x: -14, y: 0, width: 25, height: 25))
//
//                self.navigationItem.rightBarButtonItems = [callVideoButtonItem, callButtonItem]
            } else {
                let callButtonView = AACallButton(image: UIImage.bundled("ic_call_outline_22")?.tintImage(UIColor(red:0.03, green:0.50, blue:1.00, alpha:1.0)))
                callButtonView.frame = CGRect(x: -21, y: 0, width: 25, height: 25)

                callButtonView.viewDidTap = onCallTap
                
                func barItemWithView(view: UIView, rect: CGRect) -> UIBarButtonItem {
                    let container = UIView(frame: rect)
                    container.addSubview(view)
                    view.frame = rect
                    return UIBarButtonItem(customView: container)
                }
                let callButtonItem = barItemWithView(view: callButtonView, rect: CGRect(x: 0, y: 0, width: 25, height: 25))
                
//                let callButtonItem = UIBarButtonItem(customView: callButtonView)
                self.navigationItem.rightBarButtonItems = [callButtonItem]
            }
        } else {
        
        }
    }
    

    
    func bindCounter() {
        if !isBinded {
            isBinded = true
            binder.bind(Actor.getGlobalState().globalCounter, closure: { (value: JavaLangInteger?) -> () in
                if value != nil {
                    if value!.intValue > 0 {
                        self.leftBarButton?.badgeValue = value!.intValue
                    } else {
                        self.leftBarButton?.badgeValue = 0
                    }
                } else {
                    self.leftBarButton?.badgeValue = 0
                }
            })
            
        }
    }
    
    
    required public init(coder aDecoder: NSCoder!) {
        fatalError("init(coder:) has not been implemented")
    }

    
    override open func viewDidLoad() {
        super.viewDidLoad()

        
        self.voiceRecorderView = AAVoiceRecorderView(frame: CGRect(x: 0, y: 0, width: view.width - 30, height: 44))
        self.voiceRecorderView.isHidden = true
        self.voiceRecorderView.binedController = self
        self.textInputbar.addSubview(self.voiceRecorderView)
        
        self.inputOverlay.backgroundColor = UIColor(red:0.96, green:0.98, blue:0.98, alpha:1.0)
        self.inputOverlay.isHidden = false
        self.textInputbar.addSubview(self.inputOverlay)
    
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: UIBarButtonItem.Style.plain, target: nil, action: nil)
        
        if #available(iOS 11.0, *) {
            navigationItem.largeTitleDisplayMode = .never
        } else {
            // Fallback on earlier versions
        }
        let frame = CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: 216)
        self.stickersView = AAStickersKeyboard(frame: frame)
        self.stickersView.delegate = self
        
        let frameIP = CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: 250)
        self.imagePickerView = AAConvActionSheet(frame: frameIP)
        self.imagePickerView.delegate = self
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(ConversationViewController.updateStickersStateOnCloseKeyboard),
            name: NSNotification.Name.SLKKeyboardWillHide,
            object: nil)
        
        
        
//        if buttonScrollToBottomMarginConstraint == nil {
//            buttonScrollToBottomMarginConstraint = buttonScrollToBottom.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 50)
//            buttonScrollToBottomMarginConstraint?.isActive = true
//        }
        
        setupReplyView()
    }
    
    open override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        
        self.stickersButton.frame = CGRect(x: self.view.frame.size.width-77, y: self.textInputbar.frame.height - 32, width: 25, height: 25)
        self.voiceRecorderView.frame = CGRect(x: 0, y: 0, width: view.width - 30, height: 44)
        self.inputOverlay.frame = CGRect(x: 0, y: 0, width: view.width, height: 44)
        self.inputOverlayLabel.frame = CGRect(x: 0, y: 0, width: view.width, height: 44)
    }
    
    ////////////////////////////////////////////////////////////
    // MARK: - Lifecycle
    ////////////////////////////////////////////////////////////
    
    override open func viewWillAppear(_ animated: Bool) {
        
        super.viewWillAppear(animated)
        keyboardFrame?.updateFrame()

//               self.view.setNeedsDisplay()
        
//        let andicatorViewFrame = CGRect(x: view.bounds.midX, y: view.bounds.midY,width: 50 , height: 50)
        
        let andicatorViewFrame = CGRect(x: -85, y: 24, width: (navigationView.frame.width - 0), height: 17)
//        let activityIndicatorView = NVActivityIndicatorView(frame: andicatorViewFrame, type: NVActivityIndicatorType.ballPulse, color: UIColor(red:0.03, green:0.50, blue:1.00, alpha:1.0))
        activityIndicatorView = NVActivityIndicatorView(frame: andicatorViewFrame, type: NVActivityIndicatorType.ballPulse, color: UIColor(red:0.03, green:0.50, blue:1.00, alpha:1.0))

        self.navigationView.addSubview(activityIndicatorView!)
        
        // Installing bindings
        if (peer.peerType == ACPeerType.private()) {
            
            let user = Actor.getUserWithUid(peer.peerId)
            let nameModel = user.getNameModel()
            _ = user.isBlockedModel().get().booleanValue()
            
            binder.bind(nameModel, closure: { (value: NSString?) -> () in
                self.titleView.text = String(value!)
                self.navigationView.sizeToFit()
            })
            binder.bind(user.getAvatarModel(), closure: { (value: ACAvatar?) -> () in
                self.avatarView.bind(user.getNameModel().get(), id: Int(user.getId()), avatar: value)
//                self.avatarView.layer.setNeedsDisplay()
//                if value?.smallImage != nil {
//                    print("avatar: 1 \(value!.smallImage?.fileReference.getFileId())")
//                }
//                print("avatar get: \(user.getNameModel().get())")
//                self.value = nil
//                self.avatarView.reload()
//                self.view.setNeedsDisplay()

            })
            
            self.subtitleView.frame = CGRect(x: 30, y: 21, width: (self.navigationView.frame.width - 0), height: 20)

            
            binder.bind(Actor.getTypingWithUid(peer.peerId), valueModel2: user.getPresenceModel(), closure:{ (typing:JavaLangBoolean?, presence:ACUserPresence?) -> () in

                if (typing != nil && typing!.booleanValue()) {
                    self.subtitleView.frame = CGRect(x: 30, y: 21, width: (self.navigationView.frame.width - 0), height: 20)
                    
                    self.subtitleView.text = Actor.getFormatter().formatTyping()
                    self.activityIndicatorView?.startAnimating()
                    self.subtitleView.textColor = UIColor(red:0.03, green:0.50, blue:1.00, alpha:1.0)
                    self.subtitleView.font = UIFont.boldSystemFont(ofSize: 12)
                    
//                        self.subtitleView.textColor = self.appStyle.navigationSubtitleActiveColor
                    
                } else if typing!.booleanValue() == false {
                    if (user.isBot()) {
                        self.activityIndicatorView?.stopAnimating()
                        self.subtitleView.frame = CGRect(x: 3, y: 21, width: (self.navigationView.frame.width - 0), height: 20)
                        self.activityIndicatorView?.stopAnimating()
                        self.subtitleView.text = "bot"
//                        self.subtitleView.textColor = self.appStyle.userOnlineNavigationColor
                        self.subtitleView.textColor = UIColor.gray
                    } else {
                        self.activityIndicatorView?.stopAnimating()
                        self.subtitleView.frame = CGRect(x: 3, y: 21, width: (self.navigationView.frame.width - 0), height: 20)
                        let stateText = Actor.getFormatter().formatPresence(presence, withSex: user.getSex())
                        self.subtitleView.text = stateText
                        let state = presence!.state.ordinal()
                        if (state == ACUserPresence_State.online().ordinal()) {
//                            self.subtitleView.textColor = self.appStyle.userOnlineNavigationColor
                            self.subtitleView.textColor = UIColor(red:0.03, green:0.50, blue:1.00, alpha:1.0)
                            self.subtitleView.font = UIFont.systemFont(ofSize: 12)

                        } else {
//                            self.subtitleView.textColor = self.appStyle.userOfflineNavigationColor
                            self.subtitleView.font = UIFont.systemFont(ofSize: 12)
                            self.subtitleView.textColor = UIColor.gray
                        }
                    }
                }
            })
            
            self.inputOverlay.isHidden = true
        } else if (peer.peerType == ACPeerType.group()) {
            let group = Actor.getGroupWithGid(peer.peerId)
            let nameModel = group.name
            
            binder.bind(nameModel, closure: { (value: NSString?) -> () in
                self.titleView.text = String(value!);
                self.navigationView.sizeToFit();
            })
            binder.bind(group.avatar, closure: { (value: ACAvatar?) -> () in
                self.avatarView.bind(group.name.get(), id: Int(group.getId()), avatar: value)
            })
            binder.bind(Actor.getGroupTyping(withGid: group.getId()), valueModel2: group.membersCount, valueModel3: group.presence, closure: { (typingValue:IOSIntArray?, membersCount: JavaLangInteger?, onlineCount:JavaLangInteger?) -> () in
                if (!group.isMember.get().booleanValue()) {
                    self.subtitleView.text = AALocalized("ChatNoGroupAccess")
//                    self.subtitleView.textColor = self.appStyle.navigationSubtitleColor
                    self.subtitleView.textColor = UIColor.gray
                    return
                }
                
                if (typingValue != nil && typingValue!.length() > 0) {
//                    self.subtitleView.textColor = self.appStyle.navigationSubtitleActiveColor
                    self.subtitleView.textColor = UIColor.gray
                    if (typingValue!.length() == 1) {
                        let uid = typingValue!.int(at: 0);
                        let user = Actor.getUserWithUid(uid)
                        self.subtitleView.text = Actor.getFormatter().formatTyping(withName: user.getNameModel().get())
                    } else {
                        self.subtitleView.text = Actor.getFormatter().formatTyping(withCount: typingValue!.length());
                    }
                } else {
                    var membersString = Actor.getFormatter().formatGroupMembers(membersCount!.intValue())
//                    self.subtitleView.textColor = self.appStyle.navigationSubtitleColor
                    self.subtitleView.textColor = UIColor.gray
                    if (onlineCount == nil || onlineCount!.intValue == 0) {
                        self.subtitleView.text = membersString;
                    } else {
                        membersString = membersString! + ", ";
                        let onlineString = Actor.getFormatter().formatGroupOnline(onlineCount!.intValue());
                        let attributedString = NSMutableAttributedString(string: (membersString! + onlineString!))
                        attributedString.addAttribute(NSAttributedString.Key.foregroundColor, value: self.appStyle.userOnlineNavigationColor, range: NSMakeRange(membersString!.length, onlineString!.length))
                        self.subtitleView.attributedText = attributedString
                    }
                }
            })
            
            binder.bind(group.isMember, valueModel2: group.isCanWriteMessage, valueModel3: group.isCanJoin, closure: { (isMember: JavaLangBoolean?, canWriteMessage: JavaLangBoolean?, canJoin: JavaLangBoolean?) in
                
                if canWriteMessage!.booleanValue() {
                    self.stickersButton.isHidden = false
                    self.leftButton.isHidden = false
                    self.rightButton.isHidden = false
                    self.inputOverlay.isHidden = true
                    self.textInputbar.textView.isHidden = false

                } else {
                    if !isMember!.booleanValue() {
                        if canJoin!.booleanValue() {
                            self.inputOverlayLabel.text = AALocalized("ChatJoin")
                        } else {
                            self.inputOverlayLabel.text = AALocalized("ChatNoGroupAccess")
                        }
                    } else {
                        if Actor.isNotificationsEnabled(with: self.peer) {
                            self.inputOverlayLabel.text = AALocalized("ActionMute")
                        } else {
                            self.inputOverlayLabel.text = AALocalized("ActionUnmute")
                        }
                    }
                    self.stickersButton.isHidden = true
                    self.leftButton.isHidden = true
                    self.rightButton.isHidden = true
                    self.stopAudioRecording()
                    self.textInputbar.textView.text = ""
                    self.inputOverlay.isHidden = false
                    self.textInputbar.textView.isHidden = true
                }
            })
            
            
            binder.bind(group.isDeleted) { (isDeleted: JavaLangBoolean?) in
                if isDeleted!.booleanValue() {
                    self.alertUser(AALocalized("ChatDeleted")) {
                        self.execute(Actor.deleteChatCommand(with: self.peer), successBlock: { (r) in
                            self.navigateBack()
                        })
                    }
                }
            }

        }
        
        Actor.onConversationOpen(with: peer)
        ActorSDK.sharedActor().trackPageVisible(content)
        
        if textView.isFirstResponder == false {
            textView.resignFirstResponder()
        }
        
        textView.text = Actor.loadDraft(with: peer)

    }
    
    internal func resetScrollToBottomButtonPosition() {
//        scrollToBottomButtonIsVisible = !chatLogIsAtBottom()
    }
    
//    internal func scrollToBottom(_ animated: Bool = false) {
//        let boundsHeight = collectionView?.bounds.size.height ?? 0
//        let sizeHeight = collectionView?.contentSize.height ?? 0
//        let offset = CGPoint(x: 0, y: max(sizeHeight - boundsHeight, 0))
//        collectionView?.setContentOffset(offset, animated: animated)
//        scrollToBottomButtonIsVisible = false
//    }
    
//    private func setupScrollToBottomButton() {
//        buttonScrollToBottom.layer.cornerRadius = 25
//        buttonScrollToBottom.layer.borderColor = UIColor.lightGray.cgColor
//        buttonScrollToBottom.layer.borderWidth = 1
//    }
//
//    private func buttonScrollToBottomPressed(_ sender: UIButton) {
//        scrollToBottom(true)
//    }
    
    open func onOverlayTap() {
        if peer.isGroup {
            let group = Actor.getGroupWithGid(peer.peerId)
            if !group.isMember.get().booleanValue() {
                if group.isCanJoin.get().booleanValue() {
                    _ = executePromise(Actor.joinGroup(withGid: peer.peerId))
                } else {
                    // DO NOTHING
                }
            } else if !group.isCanWriteMessage.get().booleanValue() {
                if Actor.isNotificationsEnabled(with: peer) {
                    Actor.changeNotificationsEnabled(with: peer, withValue: false)
                    inputOverlayLabel.text = AALocalized("ActionUnmute")
                } else {
                    Actor.changeNotificationsEnabled(with: peer, withValue: true)
                    inputOverlayLabel.text = AALocalized("ActionMute")
                }
            }
        } else if peer.isPrivate {
            
        }
    }
    
    override open func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        backgroundView.frame = view.bounds
        
        titleView.frame = CGRect(x: 3, y: 3, width: (navigationView.frame.width - 0), height: 20)
        if self.activityIndicatorView?.isAnimating == false {
            subtitleView.frame = CGRect(x: 3, y: 21, width: (navigationView.frame.width - 0), height: 20)
        }
        
        stickersView.frame = CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: 216)
        
//        imagePickerView.frame = CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: 250)

        
        
        self.textInputbar.editorTitle.text = AALocalized("EditingMessage")
        self.textInputbar.editorLeftButton.sizeToFit()
        self.textInputbar.editorRightButton.sizeToFit()
        
    }
    
    override open func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if self.removeExcedentControllers {
            if navigationController!.viewControllers.count > 2 {
                let firstController = navigationController!.viewControllers[0]
                let currentController = navigationController!.viewControllers[navigationController!.viewControllers.count - 1]
                navigationController!.setViewControllers([firstController, currentController], animated: false)
            }
        }
        
        if !AADevice.isiPad {
            AANavigationBadge.showBadge()
        }
    }
    
    override open func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        Actor.onConversationClosed(with: peer)
        ActorSDK.sharedActor().trackPageHidden(content)
        
        if !AADevice.isiPad {
            AANavigationBadge.hideBadge()
        }
        
        // Closing keyboard
        self.textView.resignFirstResponder()
    }
    
    override open func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        Actor.saveDraft(with: peer, withDraft: textView.text)
        
        // Releasing bindings
        binder.unbindAll()
    }
    
    ////////////////////////////////////////////////////////////
    // MARK: - Chat avatar tap
    ////////////////////////////////////////////////////////////
    
    func onAvatarTap() {
        let id = Int(peer.peerId)
        var controller: AAViewController!

        if (peer.peerType == ACPeerType.private()) {
            controller = ActorSDK.sharedActor().delegate.actorControllerForUser(id)
            if controller == nil {
                controller = AAUserViewController(uid: id)
            }
        } else if (peer.peerType == ACPeerType.group()) {
            controller = ActorSDK.sharedActor().delegate.actorControllerForGroup(id)
            if controller == nil {
                controller = AAGroupViewController(gid: id)
            }
        } else {
            return
        }
        
        if (AADevice.isiPad) {
            let navigation = AANavigationController()
            navigation.viewControllers = [controller]
            let popover = UIPopoverController(contentViewController:  navigation)
            controller.popover = popover
            popover.present(from: navigationItem.rightBarButtonItem!,
                            permittedArrowDirections: UIPopoverArrowDirection.up,
                            animated: true)
        } else {
            navigateNext(controller, removeCurrent: false)
        }
    }
    
    public override func onEditMessageTap(rid:Int64, msg:String){
        self.textView.text = msg
        self.editingId = rid
        self.textInputbar.beginTextEditing()
    }
    
    public override func onReplyMessageTap(sid:jint, msg:String){
//        self.textView.text = msg
//        self.editingId = rid
//        self.textInputbar.beginTextEditing()
//        let msg = "msg"
//        message.user = "rid"
//        message.user?.username = "TesteUser"
//        message.text = "TestMessage"
        reply(to: msg, sid: sid)
    }
    
    open override func didCommitTextEditing(_ sender: Any){
        if(self.editingId != nil){
            Actor.updateMessage(with: peer, withText: textView.text, withRid: self.editingId).failure { (e: JavaLangException!) -> () in
                if let re:ACRpcException = (e as! ACRpcException){
                    if re.tag == "NOT_IN_TIME_WINDOW"{
                        self.alertUser(AALocalized("MessageToOld"))
                    } else if re.tag == "NOT_LAST_MESSAGE" {
                        self.alertUser(AALocalized("IsNotLastMessage"))
                    } else {
                        self.alertUser(e.getMessage())
                    }
                }
            }
            self.editingId = nil
        }
        super.didCommitTextEditing(sender)
    }
    
    func onCallTap() {
        if !AVCaptureState.isAudioDisabled {

            if (self.peer.isGroup) {
                execute(ActorSDK.sharedActor().messenger.doCall(withGid: self.peer.peerId))
            } else if (self.peer.isPrivate) {
//                execute(ActorSDK.sharedActor().messenger.doCall(withUid: self.peer.peerId))
                execute(ActorSDK.sharedActor().messenger.doCall(withUid: self.peer.peerId))

            }
        } else {
            // show alert for audio permission disabled
            let error = ErrorDomain.audioPermissionDenied
            self.alertUser(error)
        }
    }
    
    func onVideoCallTap() {
        if !AVCaptureState.isVideoDisabled {
            if (self.peer.isPrivate) {
                execute(ActorSDK.sharedActor().messenger.doVideoCall(withUid: self.peer.peerId))
            }
        } else {
            // show alert for audio permission disabled
            let error = ErrorDomain.videoPermissionDenied
            self.alertUser(error)
        }
    }
    
    ////////////////////////////////////////////////////////////
    // MARK: - Text bar actions
    ////////////////////////////////////////////////////////////
    
    override open func textDidUpdate(_ animated: Bool) {
        super.textDidUpdate(animated)
        checkTextInTextView()
    }
    
    func checkTextInTextView() {
        
        let text = self.textView.text.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        self.rightButton.isEnabled = true
        
        //change button's
        
        if !text.isEmpty && textMode == false {
//            self.activityIndicatorView?.stopAnimating()
            self.rightButton.removeTarget(self, action: #selector(ConversationViewController.beginRecord(_:event:)), for: UIControl.Event.touchDown)
            self.rightButton.removeTarget(self, action: #selector(ConversationViewController.mayCancelRecord(_:event:)), for: UIControl.Event.touchDragInside.union(UIControl.Event.touchDragOutside))
            self.rightButton.removeTarget(self, action: #selector(ConversationViewController.finishRecord(_:event:)), for: UIControl.Event.touchUpInside.union(UIControl.Event.touchCancel).union(UIControl.Event.touchUpOutside))
            
            self.rebindRightButton()
            
            self.stickersButton.isHidden = true
            
            self.rightButton.setTitle("", for: UIControl.State())
//            self.rightButton.setTitleColor(appStyle.chatSendColor, for: UIControlState())
//            self.rightButton.setTitleColor(appStyle.chatSendDisabledColor, for: UIControlState.disabled)
//            self.rightButton.setImage(nil, for: UIControlState())
            self.rightButton.setImage(UIImage.bundled("conv_send"), for: UIControl.State())

            self.rightButton.layoutIfNeeded()
            self.textInputbar.layoutIfNeeded()
            
            self.textMode = true
            
        } else if (text.isEmpty && textMode == true) {
            
            self.rightButton.addTarget(self, action: #selector(ConversationViewController.beginRecord(_:event:)), for: UIControl.Event.touchDown)
            self.rightButton.addTarget(self, action: #selector(ConversationViewController.mayCancelRecord(_:event:)), for: UIControl.Event.touchDragInside.union(UIControl.Event.touchDragOutside))
            self.rightButton.addTarget(self, action: #selector(ConversationViewController.finishRecord(_:event:)), for: UIControl.Event.touchUpInside.union(UIControl.Event.touchCancel).union(UIControl.Event.touchUpOutside))
            
            self.stickersButton.isHidden = false
            
            
            self.rightButton.setImage(UIImage.tinted("aa_micbutton", color: UIColor.gray), for: UIControl.State())
            self.rightButton.setTitle("", for: UIControl.State())
            self.rightButton.isEnabled = true
            
            self.rightButton.layoutIfNeeded()
            self.textInputbar.layoutIfNeeded()

            self.textMode = false
            
        }
        
        if textMode == true {
            Actor.onTyping(with: peer)
        }

        
    }
    
    
    ////////////////////////////////////////////////////////////
    // MARK: - Right/Left button pressed
    ////////////////////////////////////////////////////////////
    
    override open func didPressRightButton(_ sender: Any!) {
//        scrollToBottom()
        if !self.textView.text.isEmpty {
            
//            textView.text = ""
            let messageText = textView.text
            let replyString = self.replyString
            stopReplying()
            
            let text = "\(replyString ?? "") \n\n\(messageText ?? "")"
//            Actor.sendMessage(withMentionsDetect: peer, withText: text)
            let mText = "> \(text)"
            Actor.sendMessage(withMentionsDetect: peer, withText: text)
            super.didPressRightButton(sender)
        }
    }
    
//    override open func didPressLeftButton(_ sender: Any!) {
//        super.didPressLeftButton(sender)
//
//        self.textInputbar.textView.resignFirstResponder()
//
//        self.rightButton.layoutIfNeeded()
//
//        if !ActorSDK.sharedActor().delegate.actorConversationCustomAttachMenu(self) {
//            let actionSheet = AAConvActionSheet()
//            actionSheet.addCustomButton("SendDocument")
//            actionSheet.addCustomButton("ShareLocation")
//            actionSheet.addCustomButton("ShareContact")
//            actionSheet.delegate = self
//            actionSheet.presentInController(self)
//            //Create the AlertController and add Its action like button in Actionsheet
//
////            let revealController = RevealMenuController(title: "Contact Support", position: .bottom)
////            let webImage = UIImage(named: "IconHome")
////            let emailImage = UIImage(named: "IconEmail")
////            let phoneImage = UIImage(named: "IconCall")
////
////            let webAction = RevealMenuAction(title: "Open web page", image: webImage, alignment: .left, handler: { (controller, action) in
////                print(action.title)
////                controller.dismiss(animated: true, completion: nil)
////            })
////            revealController.addAction(webAction)
////
////            // Add first group
////            let techGroup = RevealMenuActionGroup(title: "Contact tech. support", alignment: .left, actions: [
////                RevealMenuAction(title: "tech.support@apple.com", image: emailImage, handler: { (controller, action) in
////                    print(action.title)
////                }),
////                RevealMenuAction(title: "1-866-752-7753", image: phoneImage, alignment: .left, handler: { (controller, action) in
////                    print(action.title)
////                })
////                ])
////            revealController.addAction(techGroup)
////
////            // Add second group
////            let customersGroup = RevealMenuActionGroup(title: "Contact custommers support", alignment: .left, actions: [
////                RevealMenuAction(title: "customers@apple.com", image: emailImage, alignment: .left, handler: { (controller, action) in
////                    print(action.title)
////                }),
////                RevealMenuAction(title: "1-800-676-2775", image: phoneImage, alignment: .left, handler: { (controller, action) in
////                    print(action.title)
////                })
////                ])
////            revealController.addAction(customersGroup)
////
////            // Display controller
////            revealController.displayOnController(self)
////
////
////        var preferredStatusBarStyle: UIStatusBarStyle {
////            return .lightContent
////        }
//        }
//    }
    

    ////////////////////////////////////////////////////////////
    // MARK: - Completition
    ////////////////////////////////////////////////////////////
    
    override open func didChangeAutoCompletionPrefix(_ prefix: String!, andWord word: String!) {
        if self.peer.peerType == ACPeerType.group() {
            if prefix == "@" {

                let oldCount = filteredMembers.count
                filteredMembers.removeAll(keepingCapacity: true)

                let res = Actor.findMentions(withGid: self.peer.peerId, withQuery: word)!
                for index in 0..<res.size() {
                    filteredMembers.append(res.getWith(index) as! ACMentionFilterResult)
                }

                if oldCount == filteredMembers.count {
                    self.autoCompletionView.reloadData()
                }

                dispatchOnUi { () -> Void in
                    self.showAutoCompletionView(self.filteredMembers.count > 0)
                }
                return
            }
        }

        dispatchOnUi { () -> Void in
            self.showAutoCompletionView(false)
        }
    }
    
    ////////////////////////////////////////////////////////////
    // MARK: - TableView for completition
    ////////////////////////////////////////////////////////////
    
    override open func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredMembers.count
    }
    
    override open func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let res = AAAutoCompleteCell(style: UITableViewCell.CellStyle.default, reuseIdentifier: "user_name")
        res.bindData(filteredMembers[(indexPath as NSIndexPath).row], highlightWord: foundWord!)
        return res
    }
    
    override open func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let user = filteredMembers[(indexPath as NSIndexPath).row]
        
        var postfix = " "
        if foundPrefixRange.location == 0 {
            postfix = ": "
        }
        
        acceptAutoCompletion(with: user.mentionString + postfix ?? "", keepPrefix: !user.isNickname)
    }
    
    override open func heightForAutoCompletionView() -> CGFloat {
        let cellHeight: CGFloat = 44.0;
        return cellHeight * CGFloat(filteredMembers.count)
    }
    
    override open func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.separatorInset = UIEdgeInsets.zero
        cell.preservesSuperviewLayoutMargins = false
        cell.layoutMargins = UIEdgeInsets.zero
        tableView.keyboardDismissMode = .interactive
    }
    
    ////////////////////////////////////////////////////////////
    //   ImagePicker
    ////////////////////////////////////////////////////////////
    
    @objc open func changeImagePicker() {
        if self.imagePickerOpen == false {
            
            
            let actionSheet = AAConvActionSheet()
//            self.textInputbar.textView.inputView = self.imagePickerView
//            self.textInputbar.textView.inputView?.isOpaque = false
//            self.textInputbar.textView.inputView?.backgroundColor = UIColor.clear
//            self.textInputbar.textView.refreshFirstResponder()
//            self.textInputbar.textView.refreshInputViews()
//            self.textInputbar.textView.becomeFirstResponder()
            
            
            self.textInputbar.textView.resignFirstResponder()
            self.rightButton.layoutIfNeeded()
            
            if !ActorSDK.sharedActor().delegate.actorConversationCustomAttachMenu(self) {
                
//                actionSheet.addCustomButton("SendDocument")
//                actionSheet.addCustomButton("ShareLocation")
//                actionSheet.addCustomButton("ShareContact")
                actionSheet.addCustomButton("Gallery")
                actionSheet.delegate = self
                actionSheet.presentInController(self)
            }
            
//            var config = YPImagePicker
//            config.onlySquareImages = false
//            config.libraryTargetImageSize = .original
//            config.showsVideo = true
//            config.usesFrontCamera = true
//            config.showsFilters = true
//            config.shouldSaveNewPicturesToAlbum = true
//            config.videoCompression = AVAssetExportPresetHighestQuality
//            config.albumName = "MyGreatAppName"
            
            // Build a picker with your configuration
//            let picker = YPImagePicker()
            
//            let picker = YPImagePicker()
            
            // unowned is Mandatory since it would create a retain cycle otherwise :)
//            picker.didSelectImage = { [unowned picker] img in
//                // image picked
//                print(img.size)
////                self.imageView.image = img
//                picker.dismiss(animated: true, completion: nil)
//            }
//            picker.didSelectVideo = { videoData, videoThumbnailImage in
//                // video picked
////                self.imageView.image = videoThumbnailImage
//                picker.dismiss(animated: true, completion: nil)
//            }
//            present(picker, animated: true, completion: nil)
            
//            var configuration = Configuration()
//            configuration.doneButtonTitle = "Отправить"
//            configuration.noImagesTitle = "Sorry! There are no images here!"
//            configuration.recordLocation = false
//            configuration.backgroundColor = UIColor.white
//
//            let imagePicker = ImagePickerController(configuration: configuration)
//
//            imagePicker.delegate = self
//            present(imagePicker, animated: true, completion: nil)
            
            
//            imagePickerView.delegate = self
//            

            
//            showImagePickerTray()
//            let controller = init(ImagePickerTrayController
//            controller.add(action: .cameraAction { _ in
//                print("Show Camera")
//                })
//            controller.add(action: .libraryAction { _ in
//                print("Show Library")
//                })
//            controller.delegate = self
            
//            init
            
//            showImagePickerTray()
            
            self.imagePickerOpen = true
        } else {
            
//            self.textInputbar.textView.inputView = nil
//
//            self.textInputbar.textView.refreshFirstResponder()
//            self.textInputbar.textView.refreshInputViews()
//            self.textInputbar.textView.becomeFirstResponder()
            
//            hideImagePickerTray()
            
            self.imagePickerOpen = false
        }
        self.textInputbar.layoutIfNeeded()
        self.view.layoutIfNeeded()
    }
    

        
//    override open func didPressLeftButton(_ sender: Any!) {
//        super.didPressLeftButton(sender)
//
//
////        self.textInputbar.textView.didNotResignFirstResponder()
//        self.textInputbar.textView.inputView = self.imagePickerView
//
//        self.rightButton.layoutIfNeeded()
//
//        showImagePickerTray()
//    }
//    @objc fileprivate func toggleImagePickerTray(_: UIBarButtonItem) {
//        if presentedViewController != nil {
//            hideImagePickerTray()
//        }
//        else {
//            showImagePickerTray()
//        }
//    }
    
//    fileprivate func showImagePickerTray() {
    
//        let controller = ImagePickerTrayController()
//        controller.add(action: .cameraAction { _ in
//            print("Show Camera")
//            })
//        controller.add(action: .libraryAction { _ in
//            print("Show Library")
//            })
//        let rootController = ActorSDK.sharedActor().bindedToWindow.rootViewController!
//        modalPresentationStyle = .custom
//        controller.delegate = self
//        present(controller, animated: true, completion: nil)
//    }
    
    open func showActionPhotoGallery() {
//        var configuration = Configuration()
//        configuration.doneButtonTitle = "Отправить"
//        configuration.noImagesTitle = "Sorry! There are no images here!"
//        configuration.recordLocation = false
//        configuration.backgroundColor = UIColor.white
//
//        let imagePicker = ImagePickerController(configuration: configuration)
//
//        imagePicker.delegate = self
//        present(imagePicker, animated: true, completion: nil)
        
        let gallery = GalleryController()
//        Gallery.
        gallery.delegate = self
        present(gallery, animated: true, completion: nil)
    }
    
//    
//    // MARK: - LightboxControllerDismissalDelegate
//
//    public func lightboxControllerWillDismiss(_ controller: LightboxController) {
//
//    }
//
//    // MARK: - GalleryControllerDelegate
//
//    public func galleryControllerDidCancel(_ controller: GalleryController) {
//        controller.dismiss(animated: true, completion: nil)
//        gallery = nil
//    }
//
//    public func galleryController(_ controller: GalleryController, didSelectVideo video: Video) {
//        controller.dismiss(animated: true, completion: nil)
//        gallery = nil
//
//
//        editor.edit(video: video) { (editedVideo: Video?, tempPath: URL?) in
//            DispatchQueue.main.async {
//                if let tempPath = tempPath {
//                    let controller = AVPlayerViewController()
//                    controller.player = AVPlayer(url: tempPath)
//
//                    self.present(controller, animated: true, completion: nil)
//                }
//            }
//        }
//    }
//
//    public func galleryController(_ controller: GalleryController, didSelectImages images: [(Image)]) {
//        controller.dismiss(animated: true, completion: nil)
//        gallery = nil
//
//
//
//
////        Actor.sendUIImag(imageData!, peer: peer, animated:false)
////        for (i) in images {
////
////            let imageData = UIImageJPEGRepresentation(i, 1.0)
////            Actor.sendUIImage(imageData!, peer: peer, animated:false)
////        }
//    }
//
//    public func galleryController(_ controller: GalleryController, requestLightbox images: [Image]) {
//        LightboxConfig.DeleteButton.enabled = true
//
//        let lightboxImages = images.flatMap { $0.uiImage(ofSize: UIScreen.main.bounds.size) }.map({ LightboxImage(image: $0) })
//
//        guard lightboxImages.count == images.count else {
//            return
//        }
//
//        let lightbox = LightboxController(images: lightboxImages, startIndex: 0)
//        lightbox.dismissalDelegate = self
//
//        controller.present(lightbox, animated: true, completion: nil)
//    }
    
    // MARK: - LightboxControllerDismissalDelegate

    public func lightboxControllerWillDismiss(_ controller: LightboxController) {

    }

    // MARK: - GalleryControllerDelegate

    public func galleryControllerDidCancel(_ controller: GalleryController) {
        controller.dismiss(animated: true, completion: nil)
        gallery = nil
    }

    public func galleryController(_ controller: GalleryController, didSelectVideo video: Video) {
        controller.dismiss(animated: true, completion: nil)
//        gallery = nil
        
        


        editor.edit(video: video) { (editedVideo: Video?, tempPath: URL?) in
            DispatchQueue.main.async {
                if let tempPath = tempPath {
                    let controller = AVPlayerViewController()
                    controller.player = AVPlayer(url: tempPath)

                    self.present(controller, animated: true, completion: nil)
//                    Actor.sendVideo(tempPath, peer: self.peer)
                }
            }
        }
    }

    public func galleryController(_ controller: GalleryController, didSelectImages images: [Image]) {
        controller.dismiss(animated: true, completion: nil)
//        gallery = nil
        Image.resolve(images: images) { (selectedImages: [UIImage?]) in
            let explicitSelectedImages: [UIImage] = selectedImages.filter({ (image: UIImage?) -> Bool in
                return image != nil
            }).map({$0!})
            
//            self.didSetImage?(explicitSelectedImages)
//            self.gallery.dismiss(animated: true) {
//                self.completion?(explicitSelectedImages)
//            }
            for (i) in explicitSelectedImages {
                let image = UIImage()
                let imageData = image.jpegData(compressionQuality: 0.80)
                Actor.sendUIImage(imageData!, peer: self.peer, animated:false)
            }
        }
        
    }

    public func galleryController(_ controller: GalleryController, requestLightbox images: [Image]) {
        LightboxConfig.DeleteButton.enabled = true
//
////        SVProgressHUD.show()
//        var hud: MBProgressHUD?
//        hud = showProgress()
        Image.resolve(images: images, completion: { [weak self] resolvedImages in
//            SVProgressHUD.dismiss()
//            hud?.hide(animated: true)
            self?.showLightbox(images: resolvedImages.compactMap({ $0 }))
        })
    }

    // MARK: - Helper

    public func showLightbox(images: [UIImage]) {
        guard images.count > 0 else {
            return
        }

        let lightboxImages = images.map({ LightboxImage(image: $0) })
        let lightbox = LightboxController(images: lightboxImages, startIndex: 0)
        lightbox.dismissalDelegate = self

        gallery.present(lightbox, animated: true, completion: nil)
    }
    
    
//
//    @objc fileprivate func willShowImagePickerTray(notification: Notification) {
//        guard let userInfo = notification.userInfo,
//            let frame = userInfo[ImagePickerTrayFrameUserInfoKey] as? CGRect else {
//                return
//        }
//
//        let duration: TimeInterval = (userInfo[ImagePickerTrayAnimationDurationUserInfoKey] as? TimeInterval) ?? 0
//        animateContentInset(inset: frame.height, duration: duration, curve: UIViewAnimationCurve(rawValue: 0)!)
//    }
//
//    @objc fileprivate func willHideImagePickerTray(notification: Notification) {
//        guard let userInfo = notification.userInfo else {
//            return
//        }
//
//        let duration: TimeInterval = (userInfo[ImagePickerTrayAnimationDurationUserInfoKey] as? TimeInterval) ?? 0
//        animateContentInset(inset: 0, duration: duration, curve: UIViewAnimationCurve(rawValue: 0)!)
//    }
//
//    fileprivate func animateContentInset(inset bottomInset: CGFloat, duration: TimeInterval, curve: UIViewAnimationCurve) {
//        //        var inset = tableView.contentInset
//        //        inset.bottom = bottomInset
//
//        //        var offset = tableView.contentOffset
//        //        offset.y = max(0, offset.y - bottomInset)
//
//        let options = UIViewAnimationOptions(rawValue: UInt(curve.rawValue) << 16)
//        UIView.animate(withDuration: duration, delay: 0, options: options, animations: {
//            //            self.tableView.contentInset = inset
//            //            self.tableView.contentOffset = offset
//            //            self.tableView.scrollIndicatorInsets = inset
//        }, completion: nil)
//    }
    
    ////////////////////////////////////////////////////////////
    // MARK: - Picker
    ////////////////////////////////////////////////////////////
    
    open func actionSheetPickedImages(_ images:[(Data,Bool)]) {
        for (i,j) in images {
            Actor.sendUIImage(i, peer: peer, animated:j)
        }
    }
    
    open func actionSheetPickCamera() {
        pickImage(.camera)
    }
    
    open func actionSheetPickGallery() {
        pickImage(.photoLibrary)
    }
    
    open func actionSheetCustomButton(_ index: Int) {
        if index == 0 {
            showActionPhotoGallery()
        } else if index == 1 {
            pickDocument()
        } else if index == 2 {
            pickLocation()
        } else if index == 3 {
            pickContact()
        }
    }
    
    open func pickContact() {
        let pickerController = ABPeoplePickerNavigationController()
        pickerController.peoplePickerDelegate = self
        self.present(pickerController, animated: true, completion: nil)
    }
    
    open func pickLocation() {
        let pickerController = AALocationPickerController()
        pickerController.delegate = self
        self.present(AANavigationController(rootViewController:pickerController), animated: true, completion: nil)
    }
    
    open func pickDocument() {
        let documentPicker = UIDocumentMenuViewController(documentTypes: UTTAll as [String], in: UIDocumentPickerMode.import)
        documentPicker.view.backgroundColor = UIColor.clear
        documentPicker.delegate = self
        self.present(documentPicker, animated: true, completion: nil)
    }
    
    ////////////////////////////////////////////////////////////
    // MARK: - Document picking
    ////////////////////////////////////////////////////////////
    
    open func documentMenu(_ documentMenu: UIDocumentMenuViewController, didPickDocumentPicker documentPicker: UIDocumentPickerViewController) {
        documentPicker.delegate = self
        self.present(documentPicker, animated: true, completion: nil)
    }
    
    open func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentAt url: URL) {
        
        // Loading path and file name
        let path = url.path
        let fileName = url.lastPathComponent
        
        // Check if file valid or directory
        var isDir : ObjCBool = false
        if !FileManager.default.fileExists(atPath: path, isDirectory: &isDir) {
            // Not exists
            return
        }
        
        // Destination file
        let descriptor = "/tmp/\(UUID().uuidString)"
        let destPath = CocoaFiles.pathFromDescriptor(descriptor)
        
        if isDir.boolValue {
            
            // Zipping contents and sending
            execute(AATools.zipDirectoryCommand(path, to: destPath)) { (val) -> Void in
                Actor.sendDocument(with: self.peer, withName: fileName, withMime: "application/zip", withDescriptor: descriptor)
            }
        } else {
            
            // Sending file itself
            execute(AATools.copyFileCommand(path, to: destPath)) { (val) -> Void in
                Actor.sendDocument(with: self.peer, withName: fileName, withMime: "application/octet-stream", withDescriptor: descriptor)
            }
        }
    }
    
    
    ////////////////////////////////////////////////////////////
    // MARK: - Image picking
    ////////////////////////////////////////////////////////////
    
    func pickImage(_ source: UIImagePickerController.SourceType) {
        
        if(source == .camera && (AVAudioSession.sharedInstance().recordPermission == AVAudioSession.RecordPermission.undetermined || AVAudioSession.sharedInstance().recordPermission == AVAudioSession.RecordPermission.denied)){
            AVAudioSession.sharedInstance().requestRecordPermission({_ in (Bool).self})
        }
        
        let pickerController = AAImagePickerController()
        pickerController.sourceType = source
        pickerController.mediaTypes = [kUTTypeImage as String,kUTTypeMovie as String]
        
        pickerController.delegate = self
        
        self.present(pickerController, animated: true, completion: nil)
    }
    
    open func imagePickerController(_ picker: UIImagePickerController, didFinishPickingImage image: UIImage, editingInfo: [String : AnyObject]?) {
        picker.dismiss(animated: true, completion: nil)
        let imageData = image.jpegData(compressionQuality: 0.8)
        Actor.sendUIImage(imageData!, peer: peer, animated:false)
    }
    
    open func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        picker.dismiss(animated: true, completion: nil)
        if let image = info[.originalImage] as? UIImage {
            let imageData = image.jpegData(compressionQuality: 0.8)
            
            //TODO: Need implement assert fetching here to get images
            Actor.sendUIImage(imageData!, peer: peer, animated:false)
            
        } else {
            Actor.sendVideo(info[UIImagePickerController.InfoKey.mediaURL] as! URL, peer: peer)
        }
        
    }
    
    open func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
    ////////////////////////////////////////////////////////////
    // MARK: - Location picking
    ////////////////////////////////////////////////////////////
    open func locationPickerDidCancelled(_ controller: AALocationPickerController) {
        controller.dismiss(animated: true, completion: nil)
    }
    
    open func locationPickerDidPicked(_ controller: AALocationPickerController, latitude: Double, longitude: Double) {
        Actor.sendLocation(with: self.peer, withLongitude: JavaLangDouble(value: longitude), withLatitude: JavaLangDouble(value: latitude), withStreet: nil, withPlace: nil)
        controller.dismiss(animated: true, completion: nil)
    }
    
    ////////////////////////////////////////////////////////////
    // MARK: - Contact picking
    ////////////////////////////////////////////////////////////
    
    open func peoplePickerNavigationController(_ peoplePicker: ABPeoplePickerNavigationController, didSelectPerson person: ABRecord) {
        
        // Dismissing picker
        
        peoplePicker.dismiss(animated: true, completion: nil)
        
        // Names
        
        let name = ABRecordCopyCompositeName(person)?.takeRetainedValue() as String?
        
        // Avatar
        
        var jAvatarImage: String? = nil
        let hasAvatarImage = ABPersonHasImageData(person)
        if (hasAvatarImage) {
            let imgData = ABPersonCopyImageDataWithFormat(person, kABPersonImageFormatOriginalSize).takeRetainedValue()
            let image = UIImage(data: imgData as Data)?.resizeSquare(90, maxH: 90)
            if (image != nil) {
                let thumbData = image?.jpegData(compressionQuality: 0.55)
                jAvatarImage = thumbData?.base64EncodedString(options: NSData.Base64EncodingOptions())
            }
        }
        
        // Phones
        
        let jPhones = JavaUtilArrayList()
        let phoneNumbers: ABMultiValue = ABRecordCopyValue(person, kABPersonPhoneProperty).takeRetainedValue()
        let phoneCount = ABMultiValueGetCount(phoneNumbers)
        for i in 0 ..< phoneCount {
            let phone = (ABMultiValueCopyValueAtIndex(phoneNumbers, i).takeRetainedValue() as! String).trim()
            jPhones?.add(withId: phone)
        }
        
        
        // Email
        let jEmails = JavaUtilArrayList()
        let emails: ABMultiValue = ABRecordCopyValue(person, kABPersonEmailProperty).takeRetainedValue()
        let emailsCount = ABMultiValueGetCount(emails)
        for i in 0 ..< emailsCount {
            let email = (ABMultiValueCopyValueAtIndex(emails, i).takeRetainedValue() as! String).trim()
            if (email.length > 0) {
                jEmails?.add(withId: email)
            }
        }
        
        // Sending
        
        Actor.sendContact(with: self.peer, withName: name!, withPhones: jPhones!, withEmails: jEmails!, withPhoto: jAvatarImage)
    }
    
//    ////////////////////////////////////////////////////////////
//    // MARK: - Picker
//    ////////////////////////////////////////////////////////////
//
//    open func actionSheetPickedImages(_ images:[(Data,Bool)]) {
//        for (i,j) in images {
//            Actor.sendUIImage(i, peer: peer, animated:j)
//        }
//    }
//
//    open func actionSheetPickCamera() {
//        pickImage(.camera)
//    }
//
//    open func actionSheetPickGallery() {
//        pickImage(.photoLibrary)
//    }
//
//    open func actionSheetCustomButton(_ index: Int) {
//        if index == 0 {
//            pickDocument()
//        } else if index == 1 {
//            pickLocation()
//        } else if index == 2 {
//            pickContact()
//        }
//    }
//
//    open func pickContact() {
//        let pickerController = ABPeoplePickerNavigationController()
//        pickerController.peoplePickerDelegate = self
//        self.present(pickerController, animated: true, completion: nil)
//    }
//
//    open func pickLocation() {
//        let pickerController = AALocationPickerController()
//        pickerController.delegate = self
//        self.present(AANavigationController(rootViewController:pickerController), animated: true, completion: nil)
//    }
//
//    open func pickDocument() {
//        let documentPicker = UIDocumentMenuViewController(documentTypes: UTTAll as [String], in: UIDocumentPickerMode.import)
//        documentPicker.view.backgroundColor = UIColor.clear
//        documentPicker.delegate = self
//        self.present(documentPicker, animated: true, completion: nil)
//    }
//
//    ////////////////////////////////////////////////////////////
//    // MARK: - Document picking
//    ////////////////////////////////////////////////////////////
//
//    open func documentMenu(_ documentMenu: UIDocumentMenuViewController, didPickDocumentPicker documentPicker: UIDocumentPickerViewController) {
//        documentPicker.delegate = self
//        self.present(documentPicker, animated: true, completion: nil)
//    }
//
//    open func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentAt url: URL) {
//
//        // Loading path and file name
//        let path = url.path
//        let fileName = url.lastPathComponent
//
//        // Check if file valid or directory
//        var isDir : ObjCBool = false
//        if !FileManager.default.fileExists(atPath: path, isDirectory: &isDir) {
//            // Not exists
//            return
//        }
//
//        // Destination file
//        let descriptor = "/tmp/\(UUID().uuidString)"
//        let destPath = CocoaFiles.pathFromDescriptor(descriptor)
//
//        if isDir.boolValue {
//
//            // Zipping contents and sending
//            execute(AATools.zipDirectoryCommand(path, to: destPath)) { (val) -> Void in
//                Actor.sendDocument(with: self.peer, withName: fileName, withMime: "application/zip", withDescriptor: descriptor)
//            }
//        } else {
//
//            // Sending file itself
//            execute(AATools.copyFileCommand(path, to: destPath)) { (val) -> Void in
//                Actor.sendDocument(with: self.peer, withName: fileName, withMime: "application/octet-stream", withDescriptor: descriptor)
//            }
//        }
//    }
//
//
//    ////////////////////////////////////////////////////////////
//    // MARK: - Image picking
//    ////////////////////////////////////////////////////////////
//
//    func pickImage(_ source: UIImagePickerControllerSourceType) {
//
//        if(source == .camera && (AVAudioSession.sharedInstance().recordPermission() == AVAudioSessionRecordPermission.undetermined || AVAudioSession.sharedInstance().recordPermission() == AVAudioSessionRecordPermission.denied)){
//            AVAudioSession.sharedInstance().requestRecordPermission({_ in (Bool).self})
//        }
//
//        let pickerController = AAImagePickerController()
//        pickerController.sourceType = source
//        pickerController.mediaTypes = [kUTTypeImage as String,kUTTypeMovie as String]
//
//        pickerController.delegate = self
//
//        self.present(pickerController, animated: true, completion: nil)
//    }
//
//    open func imagePickerController(_ picker: UIImagePickerController, didFinishPickingImage image: UIImage, editingInfo: [String : AnyObject]?) {
//        picker.dismiss(animated: true, completion: nil)
//        let imageData = UIImageJPEGRepresentation(image, 0.8)
//        Actor.sendUIImage(imageData!, peer: peer, animated:false)
//    }
//
//    open func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
//        picker.dismiss(animated: true, completion: nil)
//        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
//            let imageData = UIImageJPEGRepresentation(image, 0.8)
//
//            //TODO: Need implement assert fetching here to get images
//            Actor.sendUIImage(imageData!, peer: peer, animated:false)
//
//        } else {
//            Actor.sendVideo(info[UIImagePickerControllerMediaURL] as! URL, peer: peer)
//        }
//
//    }
//
//    open func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
//        picker.dismiss(animated: true, completion: nil)
//    }
//
//    ////////////////////////////////////////////////////////////
//    // MARK: - Location picking
//    ////////////////////////////////////////////////////////////
//
//    open func locationPickerDidCancelled(_ controller: AALocationPickerController) {
//        controller.dismiss(animated: true, completion: nil)
//    }
//
//    open func locationPickerDidPicked(_ controller: AALocationPickerController, latitude: Double, longitude: Double) {
//        Actor.sendLocation(with: self.peer, withLongitude: JavaLangDouble(value: longitude), withLatitude: JavaLangDouble(value: latitude), withStreet: nil, withPlace: nil)
//        controller.dismiss(animated: true, completion: nil)
//    }
//
//    ////////////////////////////////////////////////////////////
//    // MARK: - Contact picking
//    ////////////////////////////////////////////////////////////
//
//    open func peoplePickerNavigationController(_ peoplePicker: ABPeoplePickerNavigationController, didSelectPerson person: ABRecord) {
//
//        // Dismissing picker
//
//        peoplePicker.dismiss(animated: true, completion: nil)
//
//        // Names
//
//        let name = ABRecordCopyCompositeName(person)?.takeRetainedValue() as String?
//
//        // Avatar
//
//        var jAvatarImage: String? = nil
//        let hasAvatarImage = ABPersonHasImageData(person)
//        if (hasAvatarImage) {
//            let imgData = ABPersonCopyImageDataWithFormat(person, kABPersonImageFormatOriginalSize).takeRetainedValue()
//            let image = UIImage(data: imgData as Data)?.resizeSquare(90, maxH: 90)
//            if (image != nil) {
//                let thumbData = UIImageJPEGRepresentation(image!, 0.55)
//                jAvatarImage = thumbData?.base64EncodedString(options: NSData.Base64EncodingOptions())
//            }
//        }
//
//        // Phones
//
//        let jPhones = JavaUtilArrayList()
//        let phoneNumbers: ABMultiValue = ABRecordCopyValue(person, kABPersonPhoneProperty).takeRetainedValue()
//        let phoneCount = ABMultiValueGetCount(phoneNumbers)
//        for i in 0 ..< phoneCount {
//            let phone = (ABMultiValueCopyValueAtIndex(phoneNumbers, i).takeRetainedValue() as! String).trim()
//            jPhones?.add(withId: phone)
//        }
//
//
//        // Email
//        let jEmails = JavaUtilArrayList()
//        let emails: ABMultiValue = ABRecordCopyValue(person, kABPersonEmailProperty).takeRetainedValue()
//        let emailsCount = ABMultiValueGetCount(emails)
//        for i in 0 ..< emailsCount {
//            let email = (ABMultiValueCopyValueAtIndex(emails, i).takeRetainedValue() as! String).trim()
//            if (email.length > 0) {
//                jEmails?.add(withId: email)
//            }
//        }
//
//        // Sending
//
//        Actor.sendContact(with: self.peer, withName: name!, withPhones: jPhones!, withEmails: jEmails!, withPhoto: jAvatarImage)
//    }
    
    
    ////////////////////////////////////////////////////////////
    // MARK: -
    // MARK: Audio recording statments + send
    ////////////////////////////////////////////////////////////
    
    func onAudioRecordingStarted() {
        print("onAudioRecordingStarted\n")
        stopAudioRecording()
        
        // stop voice player when start recording
        if (self.voicePlayer?.playbackPosition() != 0.0) {
            self.voicePlayer?.audioPlayerStopAndFinish()
        }
        
        audioRecorder.delegate = self
        audioRecorder.start()
    }
    
    func onAudioRecordingFinished() {
        print("onAudioRecordingFinished\n")
        
        audioRecorder.finish { (path: String?, duration: TimeInterval) -> Void in
            
            if (nil == path) {
                print("onAudioRecordingFinished: empty path")
                return
            }
            
            NSLog("onAudioRecordingFinished: %@ [%lfs]", path!, duration)
            let range = path!.range(of: "/tmp", options: NSString.CompareOptions(), range: nil, locale: nil)
            let descriptor = path!.substring(from: range!.lowerBound)
            NSLog("Audio Recording file: \(descriptor)")
            
            Actor.sendAudio(with: self.peer, withName: NSString.localizedStringWithFormat("%@.ogg", UUID().uuidString) as String,
                            withDuration: jint(duration*1000), withDescriptor: descriptor)
        }
        self.textInputbar.textView.isHidden = false
        self.leftButton.isHidden = false
        audioRecorder.cancel()
    }
    
    open func audioRecorderDidStartRecording() {
        self.voiceRecorderView.recordingStarted()
        
    }
    
    func onAudioRecordingCancelled() {
        stopAudioRecording()
        self.textInputbar.textView.isHidden = false
    }
    
    func stopAudioRecording() {
        if (audioRecorder != nil) {
            audioRecorder.delegate = nil
            audioRecorder.cancel()
        }
    }
    
    @objc func beginRecord(_ button:UIButton,event:UIEvent) {
        self.textInputbar.textView.isHidden = true
        self.voiceRecorderView.startAnimation()
        
        self.voiceRecorderView.isHidden = false
        self.stickersButton.isHidden = true
        self.leftButton.isHidden = true
        
        let touches : Set<UITouch> = event.touches(for: button)!
        let touch = touches.first!
        let location = touch.location(in: button)
        
        self.voiceRecorderView.trackTouchPoint = location
        self.voiceRecorderView.firstTouchPoint = location
        
        
        self.onAudioRecordingStarted()
    }
    
    @objc func mayCancelRecord(_ button:UIButton,event:UIEvent) {
        let touches : Set<UITouch> = event.touches(for: button)!
        let touch = touches.first!
        let currentLocation = touch.location(in: button)
        
        if (currentLocation.x < self.rightButton.frame.origin.x) {
            
            if (self.voiceRecorderView.trackTouchPoint.x > currentLocation.x) {
                self.voiceRecorderView.updateLocation(currentLocation.x - self.voiceRecorderView.trackTouchPoint.x,slideToRight: false)
            } else {
                self.voiceRecorderView.updateLocation(currentLocation.x - self.voiceRecorderView.trackTouchPoint.x,slideToRight: true)
            }
            
        }
        
        self.voiceRecorderView.trackTouchPoint = currentLocation
        
        let loct = self.voiceRecorderView.firstTouchPoint.x - self.voiceRecorderView.trackTouchPoint.x
        
        print("currentLocation \(loct)")

        
        if ((self.voiceRecorderView.firstTouchPoint.x - self.voiceRecorderView.trackTouchPoint.x) > 5) {
            //cancel
            print("mayCancelRecord")

            self.voiceRecorderView.isHidden = true
            self.stickersButton.isHidden = false
            self.leftButton.isHidden = false
            self.textInputbar.textView.isHidden = false
            
            self.stopAudioRecording()
            self.voiceRecorderView.recordingStoped()
            button.cancelTracking(with: event)
            
            closeRecorderAnimation()
            
        }
        
        
    }
    
    func closeRecorderAnimation() {
        
        let leftButtonFrame = self.leftButton.frame
        leftButton.frame.origin.x = -100
        
        let textViewFrame = self.textView.frame
        textView.frame.origin.x = textView.frame.origin.x + 500
        
        let stickerViewFrame = self.stickersButton.frame
        stickersButton.frame.origin.x = self.stickersButton.frame.origin.x + 500
        
        UIView.animate(withDuration: 1.5, delay: 0.0, usingSpringWithDamping: 0.5, initialSpringVelocity: 1.0, options: UIView.AnimationOptions.curveLinear, animations: { () -> Void in
            
            self.leftButton.frame = leftButtonFrame
            self.textView.frame = textViewFrame
            self.stickersButton.frame = stickerViewFrame
            
        }, completion: { (complite) -> Void in
            
            // animation complite
            
        })
        
    }
    
    @objc func finishRecord(_ button:UIButton,event:UIEvent) {
        closeRecorderAnimation()
        self.voiceRecorderView.isHidden = true
        self.stickersButton.isHidden = false
        self.onAudioRecordingFinished()
        self.voiceRecorderView.recordingStoped()
    }
    
    ////////////////////////////////////////////////////////////
    // MARK: - Stickers actions
    ////////////////////////////////////////////////////////////
    
    @objc open func updateStickersStateOnCloseKeyboard() {
        self.stickersOpen = false
        self.stickersButton.setImage(UIImage.bundled("sticker_button"), for: UIControl.State())
        self.textInputbar.textView.inputView = nil
        
    }
    
    @objc open func changeKeyboard() {
        if self.stickersOpen == false {
            self.textInputbar.textView.inputView = self.stickersView
            self.textInputbar.textView.inputView?.isOpaque = false
            self.textInputbar.textView.inputView?.backgroundColor = UIColor.clear
            self.textInputbar.textView.refreshFirstResponder()
            self.textInputbar.textView.refreshInputViews()
            self.textInputbar.textView.becomeFirstResponder()
            
            self.stickersButton.setImage(UIImage.bundled("keyboard_button"), for: UIControl.State())
            
            self.stickersOpen = true
        } else {
            self.textInputbar.textView.inputView = nil
            
            self.textInputbar.textView.refreshFirstResponder()
            self.textInputbar.textView.refreshInputViews()
            self.textInputbar.textView.becomeFirstResponder()
            
            self.stickersButton.setImage(UIImage.bundled("sticker_button"), for: UIControl.State())
            
            self.stickersOpen = false
        }
        self.textInputbar.layoutIfNeeded()
        self.view.layoutIfNeeded()
    }
    
    // keyboardHeightConstraint is the same as keyboardHC in SLKTextViewController
    weak var keyboardHeightConstraint: NSLayoutConstraint?
    weak var textInputbarBackgroundHeightConstraint: NSLayoutConstraint?
    
    var keyboardFrame: KeyboardFrameView?
    let textInputbarBackground = UIToolbar()
    var oldTextInputbarBgIsTransparent = false
    
    private func enableInteractiveKeyboardDismissal() {
        keyboardFrame = KeyboardFrameView(withDelegate: self)
    }
    
    // Enables for the interactive keyboard dismissal.
    // Gets called updateKeyboardConstraints(frame:) which is a
    // required method of the KeyboardFrameViewDelegate
    private func updateKeyboardConstraints(frame: CGRect) {
        if keyboardHeightConstraint == nil {
            keyboardHeightConstraint = self.view.constraints.first {
                ($0.firstItem as? UIView) == self.view &&
                    ($0.secondItem as? SLKTextInputbar) == self.textInputbar
            }
        }
        
        // Adding textInputBar background so that the app can support devices with safe area insets.
        // The tool bar (textInputBar) background sometimes dissapears on keyboard slide outs,
        // with no real fix for it provided by Apple in UIKit.
        updateTextInputbarBackground()
        
        var keyboardHeight = frame.height
        
        if #available(iOS 11.0, *) {
            keyboardHeight = keyboardHeight > view.safeAreaInsets.bottom ? keyboardHeight : view.safeAreaInsets.bottom
        }
        
        keyboardHeightConstraint?.constant = keyboardHeight
    }

    private func updateTextInputbarBackground() {
        if #available(iOS 11.0, *) {
            if !textInputbar.subviews.contains(textInputbarBackground) {
                insertTextInputbarBackground()
            }
            
            // Making the old background for textInputView, transparent
            // after the safeAreaInsets are set. (Initially zero)
            // This helps improve the translucency effect of the bar.
            if !oldTextInputbarBgIsTransparent, view.safeAreaInsets.bottom > 0 {
                textInputbar.setBackgroundImage(UIImage(), forToolbarPosition: .any, barMetrics: .default)
                textInputbar.backgroundColor = UIColor.clear
                oldTextInputbarBgIsTransparent = true
            }
            
            if let textInputbarHC = textInputbarBackgroundHeightConstraint, textInputbarHC.constant != view.safeAreaInsets.bottom {
                textInputbarHC.constant = view.safeAreaInsets.bottom
            }
        }
    }
    
    private func insertTextInputbarBackground() {
        if #available(iOS 11.0, *) {
            textInputbar.insertSubview(textInputbarBackground, at: 0)
            textInputbarBackground.translatesAutoresizingMaskIntoConstraints = false
            
            textInputbarBackgroundHeightConstraint = textInputbarBackground.heightAnchor.constraint(equalTo: textInputbar.heightAnchor, multiplier: 1, constant: view.safeAreaInsets.bottom)
            textInputbarBackgroundHeightConstraint?.isActive = true
            
            textInputbarBackground.widthAnchor.constraint(equalTo: textInputbar.widthAnchor).isActive = true
            textInputbarBackground.topAnchor.constraint(equalTo: textInputbar.topAnchor).isActive = true
            textInputbarBackground.centerXAnchor.constraint(equalTo: textInputbar.centerXAnchor).isActive = true
        }
    }
    
    open func stickerDidSelected(_ keyboard: AAStickersKeyboard, sticker: ACSticker) {
        Actor.sendSticker(with: self.peer, with: sticker)
    }
    
    /*
     public func emojiKeyboardView(_ emojiKeyboardView: AGEmojiKeyboardView!, imageForSelectedCategory category: AGEmojiKeyboardViewCategoryImage) -> UIImage{
     switch category {
     case .recent:
            return UIImage.bundled("ic_smiles_recent")!
        case .face:
            return UIImage.bundled("ic_smiles_smile")!
        case .car:
            return UIImage.bundled("ic_smiles_car")!
        case .bell:
            return UIImage.bundled("ic_smiles_bell")!
        case .flower:
            return UIImage.bundled("ic_smiles_flower")!
        case .characters:
            return UIImage.bundled("ic_smiles_grid")!
        }
    }
    
    public func emojiKeyboardView(_ emojiKeyboardView: AGEmojiKeyboardView!, imageForNonSelectedCategory category: AGEmojiKeyboardViewCategoryImage) -> UIImage!{
        switch category {
        case .recent:
            return UIImage.bundled("ic_smiles_recent")!
        case .face:
            return UIImage.bundled("ic_smiles_smile")!
        case .car:
            return UIImage.bundled("ic_smiles_car")!
        case .bell:
            return UIImage.bundled("ic_smiles_bell")!
        case .flower:
            return UIImage.bundled("ic_smiles_flower")!
        case .characters:
            return UIImage.bundled("ic_smiles_grid")!
        }
    }
    
    public func backSpaceButtonImage(for emojiKeyboardView: AGEmojiKeyboardView!) -> UIImage!{
        return UIImage.bundled("ic_smiles_backspace")!
    }
    
    public func emojiKeyBoardView(_ emojiKeyBoardView: AGEmojiKeyboardView!, didUseEmoji emoji: String!){
        self.textView.text = self.textView.text.appending(emoji)
    }

    public func emojiKeyBoardViewDidPressBackSpace(_ emojiKeyBoardView: AGEmojiKeyboardView!){
        self.textView.deleteBackward()
    }
 */
}

extension ConversationViewController {
    override public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        super.scrollViewDidScroll(scrollView)
        
        if scrollView.contentOffset.y < -10 {
//            if let message = dataController.oldestMessage() {
//                loadMoreMessagesFrom(date: message.createdAt)
//            }
        }
//        resetScrollToBottomButtonPosition()
    }
}
extension ConversationViewController: KeyboardFrameViewDelegate {
    func keyboardDidChangeFrame(frame: CGRect?) {
        if let frame = frame {
            updateKeyboardConstraints(frame: frame)
        }
//        resetScrollToBottomButtonPosition()
    }
    
    var keyboardProxyView: UIView? {
        return textInputbar.inputAccessoryView?.superview
    }
}
class AABarAvatarView : AAAvatarView {
    
    //    override init(frameSize: Int, type: AAAvatarType) {
    //        super.init(frameSize: frameSize, type: type)
    //    }
    //
    //    required init(coder aDecoder: NSCoder) {
    //        fatalError("init(coder:) has not been implemented")
    //    }
    
    override var alignmentRectInsets : UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 18, bottom: 0, right: 0)
    }
    
}

class AACallButton: UIImageView {
    override init(image: UIImage?) {
        super.init(image: image)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override var alignmentRectInsets : UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 12)
    }
}

@available(iOS 10.0, *)
extension ConversationViewController : AACallCenterDelegate {
    
    func callCenter(_ callCenter: AACallCenter, startCall session: String) {
        print("CallKit CVC startCall")

    }
    
    func callCenter(_ callCenter: AACallCenter, answerCall session: String) {
        
    }
    
    func callCenter(_ callCenter: AACallCenter, muteCall muted: Bool, session: String) {
        
    }
    
    func callCenter(_ callCenter: AACallCenter, declineCall session: String) {
        
    }
    
    func callCenter(_ callCenter: AACallCenter, endCall session: String) {
        
    }
    
    func callCenterDidActiveAudioSession(_ callCenter: AACallCenter) {
        
    }
}
