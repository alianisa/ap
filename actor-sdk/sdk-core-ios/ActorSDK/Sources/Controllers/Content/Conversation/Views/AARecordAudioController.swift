//
//  Copyright (c) 2014-2016 Actor LLC. <https://actor.im>
//

import UIKit
import AVFoundation

class AARecordAudioController: UIViewController,UIViewControllerTransitioningDelegate {
    
    ////////////////////////////////
    
    var buttonClose : UIButton!
    var recorderView : UIView!
    var timerLabel : UILabel!
    var chatController : ConversationViewController!
    
    var startRecButton  : UIButton!
    var stopRecButton   : UIButton!
    var playRecButton   : UIButton!
    var sendRecord      : UIButton!
    var cleanRecord     : UIButton!
    
    //
    
    var filePath : String!
    var fileDuration : TimeInterval!
    
    var recorded : Bool! = false
    
    fileprivate let audioRecorder: AAAudioRecorder! = AAAudioRecorder()
    fileprivate var audioPlayer: AAModernConversationAudioPlayer!
    
    var meterTimer:Timer!
    var soundFileURL:URL?
    
    ////////////////////////////////
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
        
        self.commonInit()
        
    }
    
    override init(nibName nibNameOrNil: String!, bundle nibBundleOrNil: Bundle!)  {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        
        self.commonInit()
        
    }
    
    func commonInit() {
        self.modalPresentationStyle = .custom
        self.transitioningDelegate = self
    }
    
    override var preferredStatusBarStyle : UIStatusBarStyle {
        return UIStatusBarStyle.lightContent
    }
    
    
    // ---- UIViewControllerTransitioningDelegate methods
    
    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        
        if presented == self {
            return AACustomPresentationController(presentedViewController: presented, presenting: presenting)
        }
        
        return nil
    }
    
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        
        if presented == self {
            return AACustomPresentationAnimationController(isPresenting: true)
        }
        else {
            return nil
        }
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        
        if dismissed == self {
            return AACustomPresentationAnimationController(isPresenting: false)
        }
        else {
            return nil
        }
    }
    
    override func loadView() {
        super.loadView()
        
        self.recorderView = UIView()
        self.recorderView.frame = CGRect(x: self.view.frame.width/2 - 120, y: self.view.frame.height/2 - 80, width: 240, height: 160)
        self.recorderView.backgroundColor = UIColor.white
        self.recorderView.layer.cornerRadius = 10
        self.recorderView.layer.masksToBounds = true
        self.view.addSubview(self.recorderView)
        
        self.buttonClose = UIButton(type: UIButton.ButtonType.system)
        self.buttonClose.addTarget(self, action: #selector(AARecordAudioController.closeController), for: UIControl.Event.touchUpInside)
        self.buttonClose.tintColor = UIColor.white
        self.buttonClose.setImage(UIImage.bundled("aa_closerecordbutton"), for: UIControl.State())
        self.buttonClose.frame = CGRect(x: 205, y: 5, width: 25, height: 25)
        self.recorderView.addSubview(self.buttonClose)
        
        let separatorView = UIView()
        separatorView.frame = CGRect(x: 0, y: 80, width: 240, height: 0.5)
        separatorView.backgroundColor = UIColor.gray
        self.recorderView.addSubview(separatorView)
        
        self.timerLabel = UILabel()
        self.timerLabel.text = "00:00"
        self.timerLabel.font = UIFont(name: "HelveticaNeue-Medium", size: 17)!
        self.timerLabel.textColor = ActorSDK.sharedActor().style.vcHintColor
        self.timerLabel.frame = CGRect(x: 70, y: 5, width: 100, height: 40)
        self.timerLabel.textAlignment = .center
        self.timerLabel.backgroundColor = UIColor.clear
        self.recorderView.addSubview(self.timerLabel)
        
        self.startRecButton = UIButton(type: UIButton.ButtonType.system)
        self.startRecButton.tintColor = UIColor.red
        self.startRecButton.setImage(UIImage.bundled("aa_startrecordbutton"), for: UIControl.State())
        self.startRecButton.addTarget(self, action: #selector(AARecordAudioController.startRec), for: UIControl.Event.touchUpInside)
        self.startRecButton.frame = CGRect(x: 100, y: 110, width: 40, height: 40)
        
        self.recorderView.addSubview(self.startRecButton)
        
        self.stopRecButton = UIButton(type: UIButton.ButtonType.system)
        self.stopRecButton.tintColor = UIColor.red
        self.stopRecButton.setImage(UIImage.bundled("aa_pauserecordbutton"), for: UIControl.State())
        self.stopRecButton.addTarget(self, action: #selector(AARecordAudioController.stopRec), for: UIControl.Event.touchUpInside)
        self.stopRecButton.frame = CGRect(x: 100, y: 110, width: 40, height: 40)
        
        self.recorderView.addSubview(self.stopRecButton)
        
        self.stopRecButton.isHidden = true
        
        self.playRecButton = UIButton(type: UIButton.ButtonType.system)
        self.playRecButton.tintColor = UIColor.green
        self.playRecButton.setImage(UIImage.bundled("aa_playrecordbutton"), for: UIControl.State())
        self.playRecButton.addTarget(self, action: #selector(AARecordAudioController.play), for: UIControl.Event.touchUpInside)
        self.playRecButton.frame = CGRect(x: 100, y: 110, width: 40, height: 40)
        
        self.recorderView.addSubview(self.playRecButton)
        
        self.playRecButton.isHidden = true
        
        self.sendRecord = UIButton(type: UIButton.ButtonType.system)
        self.sendRecord.tintColor = UIColor.green
        self.sendRecord.setImage(UIImage.bundled("aa_sendrecord"), for: UIControl.State())
        self.sendRecord.addTarget(self, action: #selector(AARecordAudioController.sendRecordMessage), for: UIControl.Event.touchUpInside)
        self.sendRecord.frame = CGRect(x: 190, y: 115, width: 40, height: 40)
        self.sendRecord.isEnabled = false
        
        self.recorderView.addSubview(self.sendRecord)
        
        
        self.cleanRecord = UIButton(type: UIButton.ButtonType.system)
        self.cleanRecord.tintColor = UIColor.red
        self.cleanRecord.setImage(UIImage.bundled("aa_deleterecord"), for: UIControl.State())
        self.cleanRecord.addTarget(self, action: #selector(AARecordAudioController.sendRecordMessage), for: UIControl.Event.touchUpInside)
        self.cleanRecord.frame = CGRect(x: 10, y: 120, width: 30, height: 30)
        self.cleanRecord.isEnabled = false
        
        self.recorderView.addSubview(self.cleanRecord)
        
        //cx_deleterecord
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        
    }
    
    // actions
    
    @objc func closeController() {
        
        self.audioRecorder.cancel()
        self.dismiss(animated: true, completion: nil)
    }
    
    
    
    @objc func startRec() {
        
        //log.debug("recording. recorder nil")
        
        playRecButton.isHidden    = true
        stopRecButton.isHidden    = false
        startRecButton.isHidden   = true
        
        
        startTimer()
        recordWithPermission()
        
    }
    
    @objc func stopRec() {
        
        //log.debug("stop")
        
        meterTimer.invalidate()
        
        playRecButton.isHidden    = false
        startRecButton.isHidden   = true
        stopRecButton.isHidden    = true
        
        audioRecorder.finish({ (path: String?, duration: TimeInterval) -> Void in
            if (nil == path) {
                print("onAudioRecordingFinished: empty path")
                return
            }
            
            self.filePath = path!
            self.fileDuration = duration
            
            DispatchQueue.main.async(execute: { () -> Void in
                self.sendRecord.isEnabled = true
                self.cleanRecord.isEnabled = true
            })
            
        })
        
    }
    
    func stopAudioRecording()
    {
        if (audioRecorder != nil)
        {
            audioRecorder.delegate = nil
            audioRecorder.cancel()
        }
    }
    
    @objc func play() {
        
        self.audioPlayer = AAModernConversationAudioPlayer(filePath:self.filePath)
        self.audioPlayer.play(0)
        
        playRecButton.isHidden    = true
        startRecButton.isHidden   = true
        stopRecButton.isHidden    = false
        
    }
    
    // setup record
    func recordWithPermission() {
        let session:AVAudioSession = AVAudioSession.sharedInstance()
        // ios 8 and later
        if (session.responds(to: #selector(AVAudioSession.requestRecordPermission(_:)))) {
            AVAudioSession.sharedInstance().requestRecordPermission({(granted: Bool)-> Void in
                if granted {
                    print("Permission to record granted")
                    self.setSessionPlayAndRecord()
                    self.meterTimer = Timer.scheduledTimer(timeInterval: 0.1,
                                                           target:self,
                                                           selector:#selector(AARecordAudioController.updateAudioMeter(_:)),
                                                           userInfo:nil,
                                                           repeats:true)
                } else {
                    print("Permission to record not granted")
                }
            })
        } else {
            print("requestRecordPermission unrecognized")
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    
    func startTimer() {
        self.meterTimer = Timer.scheduledTimer(timeInterval: 0.1,
                                               target:self,
                                               selector:#selector(AARecordAudioController.updateAudioMeter(_:)),
                                               userInfo:nil,
                                               repeats:true)
    }
    
    @objc func updateAudioMeter(_ timer:Timer) {
        
        if (self.audioRecorder != nil) {
            
            let dur = self.audioRecorder.currentDuration()
            
            let min = Int(dur / 60)
            let sec = Int(dur.truncatingRemainder(dividingBy: 60))
            let s = String(format: "%02d:%02d", min, sec)
            
            self.timerLabel.text = s
            
        }
    }
    
    func setSessionPlayback() {
        
        let session:AVAudioSession = AVAudioSession.sharedInstance()
        
        do {
            try! session.setCategory(.playback, mode: .default, options: [])

        }
        
        
        do {
            try! session.setActive(true)
        }
        
    }
    
    
    func setSessionPlayAndRecord() {
        
        let session:AVAudioSession = AVAudioSession.sharedInstance()
        
        do {
            try! session.setCategory(.playAndRecord, mode: .default, options: [])
        }
        
        do {
            try! session.setActive(true)
        }
        
        self.audioRecorder.start()
        
    }
    
    @objc func sendRecordMessage() {
        
        self.dismiss(animated: true, completion: nil)
        //self.chatController.sendVoiceMessage(self.filePath, duration: self.fileDuration)
        
    }
    
}
