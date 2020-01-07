import Foundation
import JDStatusBarNotification
import PushKit
import SafariServices
import DZNWebViewController
import Reachability
import UserNotifications
import CallKit

@objc open class ActorSDK: NSObject, PKPushRegistryDelegate, UNUserNotificationCenterDelegate {
    
//    @available(iOS 10.0, *)
//    public func providerDidReset(_ provider: CXProvider) {
//    }
//
//    @available(iOS 10.0, *)
//    public func provider(_ provider: CXProvider, perform action: CXAnswerCallAction) {
//        action.fulfill()
//    }
//
//    @available(iOS 10.0, *)
//    public func provider(_ provider: CXProvider, perform action: CXEndCallAction) {
//        action.fulfill()
//    }
    
    
    //
    // Shared instance
    //
    
    fileprivate static let shared =  ActorSDK()
    
    public static func sharedActor() -> ActorSDK {
        return shared
    }
    
    //
    //  Root Objects
    //
//    open var contactsList:ARBindedDisplayList!
//
//    open var displayList:ARBindedDisplayList!
//
//    open let switchRootController = Notification.Name(rawValue:"rootViewController")
    
    /// Main Messenger object
    open var messenger : ACCocoaMessenger!
    
    open var modules : ACModules!
    
    // Actor Style
    public let style = ActorStyle()
    
    /// SDK Delegate
    open var delegate: ActorSDKDelegate = ActorSDKDelegateDefault()
    
    /// SDK Analytics
    open var analyticsDelegate: ActorSDKAnalytics?
    
    
    open var backgroundSessionCompletionHandler: (() -> Void)?
    
    //
    //  Configuration
    //
    
    /// Server Endpoints
    open var endpoints = [
//        "tcp://srv1-uz.messenger.uz:9070",
//        "tcp://srv3-uz.messenger.uz:9070"
        //"tcp://srv3-uz.messenger.uz:9070"
        "tcp://srv-lcl.alome.uz:9070"
//        "tls://alo-mt3.messenger.uz",
//        "tls://alo-mt1.messenger.uz"
        ] {
        didSet {
            trustedKeys = []
        }
    }
    
    /// Trusted Server Keys
    open var trustedKeys = [
        "92ee073faa8a3ce935206df71548244e59ffb0520eef965870e1dfa588088d4c"
    ]
    
    /// API ID
    open var apiId = 2
    
    /// API Key
    open var apiKey = "eYdDUXGdsz1W5IHeFWI9snA6sU+qjCcBQ7Sjep1a2DxnWWb+qHg8rGYlMjHsWakBXvtudy5sgFCj6KLP02a6iA=="
    
    /// Push registration mode
    open var autoPushMode = AAAutoPush.fromStart
    
    /// Push token registration id. Required for sending push tokens
    open var apiPushId: Int? = nil
    
    /// Strategy about authentication
    open var authStrategy = AAAuthStrategy.phoneOnly
    
    /// Enable phone book import
    open var enablePhoneBookImport = true
    
    /// Invitation URL for apps
    open var inviteUrl: String = "https://alome.uz/dl"
    
    /// Invitation URL for apps
    open var invitePrefix: String? = "https://alome.uz/join/"
    
    /// Invitation URL for apps
    open var invitePrefixShort: String? = "alome.uz/join/"
    
    /// Privacy Policy URL
    open var privacyPolicyUrl: String? = nil
    
    /// Privacy Policy Text
    open var privacyPolicyText: String? = nil
    
    /// Terms of Service URL
    open var termsOfServiceUrl: String? = nil
    
    /// Terms of Service Text
    open var termsOfServiceText: String? = nil
    
    /// App name
    open var appName: String = "Alo"
    
    /// Use background on welcome screen
    open var useBackgroundOnWelcomeScreen: Bool? = false
    
    /// Support email
    open var supportEmail: String? = nil
    
    /// Support email
    open var supportActivationEmail: String? = nil
    
    /// Support account
    open var supportAccount: String? = nil
    
    /// Support home page
    open var supportHomepage: String? = "https://messenger.uz"
    
    /// Support account
    open var supportTwitter: String? = "aloapp"
    
    /// Invite url scheme
    open var inviteUrlScheme: String? = "alome"
    
    /// Web Invite Domain host
    open var inviteUrlHost: String? = "https://alome.uz"
    
    /// Enable voice calls feature
    open var enableCalls: Bool = true
    
    /// Enable video calls feature
    open var enableVideoCalls: Bool = true
    
    /// Enable custom sound on Groups and Chats
    open var enableChatGroupSound: Bool = true
    
    /// Enable experimental features
    open var enableExperimentalFeatures: Bool = false
    
    /// Auto Join Groups
    open var autoJoinGroups = [String]()
    
    /// Should perform auto join only after first message or contact
    open var autoJoinOnReady = true
    
    // Use call to active app
    open var enableCallToValidateCode = true
    
    //
    // User Onlines
    //
    
    /// Is User online
    fileprivate(set) open var isUserOnline = false
    
    /// Disable this if you want manually handle online states
    open var automaticOnlineHandling = true
    
    static public var isDebugMode = false
    
    weak var commentsLabel: UILabel!
    
    open var show = false
    
    //
    // Local Settings
    //
    
    // Local Shared Settings
    fileprivate static var udStorage = UDPreferencesStorage()
    
    open var isPhotoAutoDownloadGroup: Bool = udStorage.getBoolWithKey("local.photo_download.group", withDefault: true) {
        willSet(v) {
            ActorSDK.udStorage.putBool(withKey: "local.photo_download.group", withValue: v)
        }
    }
    
    open var isPhotoAutoDownloadPrivate: Bool = udStorage.getBoolWithKey("local.photo_download.private", withDefault: true) {
        willSet(v) {
            ActorSDK.udStorage.putBool(withKey: "local.photo_download.private", withValue: v)
        }
    }
    
    open var isAudioAutoDownloadGroup: Bool = udStorage.getBoolWithKey("local.audio_download.group", withDefault: true) {
        willSet(v) {
            ActorSDK.udStorage.putBool(withKey: "local.audio_download.group", withValue: v)
        }
    }
    
    open var isAudioAutoDownloadPrivate: Bool = udStorage.getBoolWithKey("local.audio_download.private", withDefault: true) {
        willSet(v) {
            ActorSDK.udStorage.putBool(withKey: "local.audio_download.private", withValue: v)
        }
    }
    
    open var isGIFAutoplayEnabled: Bool = udStorage.getBoolWithKey("local.autoplay_gif", withDefault: true) {
        willSet(v) {
            ActorSDK.udStorage.putBool(withKey: "local.autoplay_gif", withValue: v)
        }
    }
    
    
    //
    // Internal State
    //
    
    /// Is Actor Started
    fileprivate(set) open var isStarted = false
    
    fileprivate var binder = AABinder()
    fileprivate var syncTask: UIBackgroundTaskIdentifier?
    fileprivate var completionHandler: ((UIBackgroundFetchResult) -> Void)?
    
    // View Binding info
    fileprivate(set) open var bindedToWindow: UIWindow!
    
    // Reachability
    fileprivate var reachability: Reachability!
    
    public override init() {
        super.init()
        // Auto Loading Application name
        if let name = Bundle.main.object(forInfoDictionaryKey: String(kCFBundleNameKey)) as? String {
            self.appName = name
        }
//        UNUserNotificationCenter.current().delegate = self
//        UNUserNotificationCenter.current().requestAuthorization(
//            options: [.alert,.sound,.badge],
//            completionHandler: { (granted,error) in
//                //                self.isGrantedAccess = granted
//                if granted{
//                    self.setCategories()
//                } else {
//
//                }
//        })
        requestPush()
        if autoPushMode == .afterLogin {
            requestPush()
        }
    }
    
    open func createActor() {
        
        if isStarted {
            return
        }
        isStarted = true
        
        AAActorRuntime.configureRuntime()
        
        let builder = ACConfigurationBuilder()
        
        // Api Connections
        let deviceKey = UUID().uuidString
        let deviceName = UIDevice.current.name
        let appTitle = "Alo iOS"
        let deviceIp = UIDevice.current.ipAddressCell
        let deviceLocation = "Uzbekistan, Tashkent"
        let deviceOS = "\(UIDevice.current.systemName) \(UIDevice.current.systemVersion)"
        
        for url in endpoints {
            builder.addEndpoint(url)
        }
        for key in trustedKeys {
            builder.addTrustedKey(key)
        }
        
        builder.setOnClientPrivacyEnabled(jboolean(delegate.useOnClientPrivacy()))
        
//        builder.setApiConfiguration(ACApiConfiguration(appTitle: appName, withAppId: jint(apiId), withAppKey: apiKey, withDeviceTitle: deviceName, withDeviceId: deviceKey))
        
        builder.setApiConfiguration(ACApiConfiguration(appTitle: appName, withAppId: jint(apiId), withAppKey: apiKey, withDeviceTitle: deviceName, withDeviceIpAddress: deviceIp, withDeviceLocation: deviceLocation, withDeviceOS: deviceOS, withDeviceId: deviceKey))
        
        // Providers
        builder.setPhoneBookProvider(PhoneBookProvider())
        builder.setNotificationProvider(iOSNotificationProvider())
        builder.setCallsProvider(iOSCallsProvider())
        
        // Stats
        builder.setPlatformType(ACPlatformType.ios())
        builder.setDeviceCategory(ACDeviceCategory.mobile())
        
        // Locale
        for lang in Locale.preferredLanguages {
            log("Found locale :\(lang)")
            builder.addPreferredLanguage(lang)
        }
        
        // TimeZone
        let timeZone = TimeZone.current.identifier
        log("Found time zone :\(timeZone)")
        builder.setTimeZone(timeZone)
        
        // AutoJoin
        for s in autoJoinGroups {
            builder.addAutoJoinGroup(withToken: s)
        }
        if autoJoinOnReady {
            builder.setAutoJoinType(ACAutoJoinType.after_INIT())
        } else {
            builder.setAutoJoinType(ACAutoJoinType.immediately())
        }
        
        // Logs
        // builder.setEnableFilesLogging(true)
        
        // Application name
        builder.setCustomAppName(appName)
        
        // Config
        builder.setPhoneBookImportEnabled(jboolean(enablePhoneBookImport))
        builder.setVoiceCallsEnabled(jboolean(enableCalls))
        builder.setVideoCallsEnabled(jboolean(enableCalls))
        builder.setIsEnabledGroupedChatList(true)
        // builder.setEnableFilesLogging(true)

        
        // Creating messenger
        messenger = ACCocoaMessenger(configuration: builder.build())
        
        // Configure bubbles
        AABubbles.layouters = delegate.actorConfigureBubbleLayouters(AABubbles.builtInLayouters)
        
        checkAppState()
        
        // Bind Messenger LifeCycle
        
        binder.bind(messenger.getGlobalState().isSyncing, closure: { (value: JavaLangBoolean?) -> () in
            if value!.booleanValue() {
                if self.syncTask == nil {
                    self.syncTask = UIApplication.shared.beginBackgroundTask(withName: "Background Sync", expirationHandler: { () -> Void in
                        
                    })
                }
            } else {
                if self.syncTask != nil {
                    UIApplication.shared.endBackgroundTask(self.syncTask!)
                    self.syncTask = nil
                }
                if self.completionHandler != nil {
                    self.completionHandler!(UIBackgroundFetchResult.newData)
                    self.completionHandler = nil
                }
            }
        })
        
        // Bind badge counter
        
        binder.bind(Actor.getGlobalState().globalCounter, closure: { (value: JavaLangInteger?) -> () in
            if let v = value {
                UIApplication.shared.applicationIconBadgeNumber = Int(v.intValue)
            } else {
                UIApplication.shared.applicationIconBadgeNumber = 0
            }
        })
        
        // Push registration
        
        if autoPushMode == .fromStart {
            requestPush()
        }
        
        // Subscribe to network changes
        
        reachability = Reachability()!
        
        if reachability != nil {
            reachability.whenReachable = { reachability in
                self.messenger.forceNetworkCheck()
            }
            
            do {
                try reachability.startNotifier()
            } catch {
                log("Unable to start Reachability")
            }
        } else {
            log("Unable to create Reachability")
        }
        
//        UIMenuController.shared.menuItems = [UIMenuItem(title: AALocalized("NavigationEdit"), action: #selector(AABubbleTextCell.edit(_:)))]
        
//        let edit = UIMenuItem.init(title: AALocalized("NavigationEdit"), action: #selector(AABubbleTextCell.edit(_:)))
//        let reply = UIMenuItem.init(title: AALocalized("Reply"), action: #selector(AABubbleTextCell.reply(_:)))
//        UIMenuController.shared.menuItems = [edit,reply]
    }
    
    func didLoggedIn() {
        // Push registration
        if autoPushMode == .afterLogin {
            requestPush()
        }
        
        self.showMainController()

    }
    
    open func didLoggedInWithoutPush() {
        self.showMainController()
    }
    fileprivate var first: Bool = false

    func showMainController(){
        var controller = delegate.actorControllerForStart()
        
        if controller == nil {
            
            let tab = AARootTabViewController()
            
            tab.viewControllers = self.getMainNavigations()
            
            if let index = self.delegate.actorRootInitialControllerIndex() {
                tab.selectedIndex = index
            } else {
                tab.selectedIndex = 1
            }
            
            if (AADevice.isiPad) {
                let splitController = AARootSplitViewController()
                splitController.viewControllers = [tab, AANoSelectionViewController()]
                controller = splitController
            } else {
                controller = tab
            }
        }
        bindedToWindow.rootViewController = controller!
    }
    
    //
    // Push support
    //
    
    /// Token need to be with stripped everything except numbers and letters
    func pushRegisterToken(_ token: String) {
        
        if !isStarted {
            fatalError("Messenger not started")
        }
        
        if apiPushId != nil {
            
            log("PUSH Fazendo o registro no push pushRegisterToken")
            messenger.registerApplePush(withApnsId: jint(apiPushId!), withToken: token)
        }
    }
    
    func pushRegisterKitToken(_ token: String) {
        if !isStarted {
            fatalError("Messenger not started")
        }
        
        if apiPushId != nil {
            log("PUSHKIT Fazendo o registro no pushkit pushRegisterKitToken")
            messenger.registerApplePushKit(withApnsId: jint(apiPushId!), withToken: token)
        }
        
    }
    
    fileprivate func requestPush() {
        if #available(iOS 10.0, *){
            UNUserNotificationCenter.current().delegate = self
            UNUserNotificationCenter.current().requestAuthorization(options: [.badge, .sound, .alert], completionHandler: {(granted, error) in
                if (granted){
                    DispatchQueue.main.async {
                        self.setCategories()
                        UIApplication.shared.registerForRemoteNotifications()
                    }

                }else{
                    log("PUSH Acesso ao permitido para notificacoes")
                }
            })
        }
        else{
            let types: UIUserNotificationType = [.alert, .badge, .sound]
            let settings: UIUserNotificationSettings = UIUserNotificationSettings(types: types, categories: nil)
            UIApplication.shared.registerUserNotificationSettings(settings)
            UIApplication.shared.registerForRemoteNotifications()
        }
        
        log("PUSHKIT Vai requisitar o pushkit")
        self.requestPushKit()
    }
    
    fileprivate func requestPushKit() {
        log("PUSHKIT Requisitando o pushKit requestPushKit e registrando o delegate")
        let voipRegistry = PKPushRegistry(queue: DispatchQueue.main)
        voipRegistry.delegate = self
        voipRegistry.desiredPushTypes = Set([PKPushType.voIP])
    }

//    @objc open func pushRegistry(_ registry: PKPushRegistry, didUpdate pushCredentials: PKPushCredentials, for type: PKPushType) {
//        print(pushCredentials.token.map { String(format: "%02.2hhx", $0) }.joined())
//    }
    

    
    @objc open func pushRegistry(_ registry: PKPushRegistry, didUpdate pushCredentials: PKPushCredentials, for type: PKPushType) {
//        if (type == PKPushType.voIP) {
            let tokenString = pushCredentials.token.map { String(format: "%02.2hhx", $0) }.joined()
            log("PUSHKIT Vai registrar o voip para o token: \(tokenString)")
            pushRegisterKitToken(tokenString.replace(" ", dest: "").replace("<", dest: "").replace(">", dest: ""))
//        }
    }

    @available(iOS 11.0, *)
    @objc open func pushRegistry(_ registry: PKPushRegistry, didReceiveIncomingPushWith payload: PKPushPayload, for type: PKPushType, completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        
        //        let config = CXProviderConfiguration(localizedName: "My App")
        //        config.iconTemplateImageData = UIImagePNGRepresentation(UIImage(named: "pizza")!)
        //        config.ringtoneSound = "ringtone.caf"
        ////        config.includesCallsInRecents = false;
        //        config.supportsVideo = true;
        //        let provider = CXProvider(configuration: config)
        //        provider.setDelegate(self, queue: nil)
        //        let update = CXCallUpdate()
        //        update.remoteHandle = CXHandle(type: .generic, value: "Pete Za")
        //        update.hasVideo = true
        //        provider.reportNewIncomingCall(with: UUID(), update: update, completion: { error in })
        //        completion()
        
        if !messenger.isLoggedIn() {
            self.messenger.forceNetworkCheck()
            completionHandler(UIBackgroundFetchResult.noData)
            return
        }
        self.completionHandler = completionHandler
    }
    

    @objc public func pushRegistry(_ registry: PKPushRegistry, didReceiveIncomingPushWith payload: PKPushPayload, for type: PKPushType) {
        
//        if (type == PKPushType.voIP) {
//            
//        }
    }
    
//



    @objc open func pushRegistry(_ registry: PKPushRegistry, didInvalidatePushTokenFor type: PKPushType) {
        log("PUSHKIT Invalidando o push token para voip didInvalidatePushTokenForType")
        if (type == PKPushType.voIP) {
            
        }
    }
    
//    @objc open func pushRegistry(_ registry: PKPushRegistry, didReceiveIncomingPushWith payload: PKPushPayload, for type: PKPushType) {
//        log("Recebendo pushKit notification didReceiveIncomingPushWith")
//        if (type == PKPushType.voIP) {
//            let aps = payload.dictionaryPayload["aps"] as! [NSString: AnyObject]
//            if let callId = aps["callId"] as? String {
//                if let attempt = aps["attemptIndex"] as? String {
//                    Actor.checkCall(jlong(callId)!, withAttempt: jint(attempt)!)
//                } else {
//                    Actor.checkCall(jlong(callId)!, withAttempt: 0)
//                }
//            } else if let seq = aps["seq"] as? String {
//                Actor.onPushReceived(withSeq: jint(seq)!, withAuthId: 0)
//            }
//        }
//    }
    
    /// Get main navigations with check in delegate for customize from SDK
    fileprivate func getMainNavigations() -> [AANavigationController] {
        
        let allControllers = self.delegate.actorRootControllers()
        
        if let all = allControllers {
            
            var mainNavigations = [AANavigationController]()
            
            for controller in all {
                mainNavigations.append(AANavigationController(rootViewController: controller))
            }
            
            return mainNavigations
        } else {
            
            var mainNavigations = [AANavigationController]()
            
            ////////////////////////////////////
            // Contacts
            ////////////////////////////////////
            
            if let contactsController = self.delegate.actorControllerForContacts() {
                mainNavigations.append(AANavigationController(rootViewController: contactsController))
            } else {
                mainNavigations.append(AANavigationController(rootViewController: AAContactsViewController()))
            }
            
            ////////////////////////////////////
            // Calls
            ////////////////////////////////////
            
//            if let callsController = self.delegate.actorControllerForCalls() {
//                mainNavigations.append(AANavigationController(rootViewController: callsController))
//            } else {
//                mainNavigations.append(AANavigationController(rootViewController: AACallsViewController()))
//            }
            
            
            ////////////////////////////////////
            // Recent dialogs
            ////////////////////////////////////
            
            if let recentDialogs = self.delegate.actorControllerForDialogs() {
                mainNavigations.append(AANavigationController(rootViewController: recentDialogs))
            } else {
                mainNavigations.append(AANavigationController(rootViewController: AARecentViewController()))
            }
            
            ////////////////////////////////////
            // Settings
            ////////////////////////////////////
            
            if let settingsController = self.delegate.actorControllerForSettings() {
                mainNavigations.append(AANavigationController(rootViewController: settingsController))
            } else {
                mainNavigations.append(AANavigationController(rootViewController: AASettingsViewController()))
            }
            
            
            return mainNavigations
        }
    }
    
    
    
    
    //
    // Presenting Messenger
    //
    
    open func presentMessengerInWindow(_ window: UIWindow) {
        if !isStarted {
            fatalError("Messenger not started")
        }
        
        self.bindedToWindow = window
        
        if messenger.isLoggedIn() {
            var sessionsCell: ARApiAuthSession?
            func loadSessions() {
                Actor.loadSessionsCommand()
            }
            loadSessions()
            
            if sessionsCell?.getAuthHolder().ordinal() != ARApiAuthHolder.thisdevice().ordinal() {
                
            } else {
                
//                Actor.resetAuth()
//                Actor.signOut()
//                ARStorage.resetStorage()
                window.rootViewController = AAWelcomeController()
//                self.onAfterReset()
            }

            if autoPushMode == .afterLogin {
//                log("PUSH requisitando o push em presentMessengerInWindow")
                requestPush()
            }
            
            var controller: UIViewController! = delegate.actorControllerForStart()
            if controller == nil {
                let tab = AARootTabViewController()
                tab.viewControllers = self.getMainNavigations()
                
                if let index = self.delegate.actorRootInitialControllerIndex() {
                    tab.selectedIndex = index
                } else {
                    tab.selectedIndex = 1
                }
                
                if (AADevice.isiPad) {
                    let splitController = AARootSplitViewController()
                    splitController.viewControllers = [tab, AANoSelectionViewController()]
                    controller = splitController
                } else {
                    controller = tab
                }
            }
            window.rootViewController = controller!
        } else {
            let controller: UIViewController! = delegate.actorControllerForAuthStart()
            if controller == nil {
                window.rootViewController = AAWelcomeController()
            } else {
                window.rootViewController = controller
            }
        }
        
        
        // Bind Status Bar connecting
        
        if !style.statusBarConnectingHidden {
            
            //            JDStatusBarNotification.setDefaultStyle { (style) -> JDStatusBarStyle! in
            //                style?.barColor = self.style.statusBarConnectingBgColor
            //                style?.textColor = self.style.statusBarConnectingTextColor
            //                return style
            //            }
            
            dispatchOnUi { () -> Void in
                self.binder.bind(self.messenger.getGlobalState().isSyncing, valueModel2: self.messenger.getGlobalState().isConnecting) {
                    (isSyncing: JavaLangBoolean?, isConnecting: JavaLangBoolean?) -> () in
                    
                    if isSyncing!.booleanValue() || isConnecting!.booleanValue() {
                        if isConnecting!.booleanValue() {
                            //                            JDStatusBarNotification.show(withStatus: AALocalized("StatusConnecting"))
                            WaitMBProgress().status(text: AALocalized("StatusConnecting"))
                        } else {
                            //                            JDStatusBarNotification.show(withStatus: AALocalized("StatusSyncing"))
                            WaitMBProgress().status(text: AALocalized("StatusSyncing"))
                        }
                    } else {
                        //                        JDStatusBarNotification.dismiss()
                        WaitMBProgress().hide()
                    }
                }
            }
        }
    }
    
    open func swapRootViewController(newController: UIViewController) {
        let window = self.bindedToWindow
        if (window != nil) {
            
            let dismiss = window?.rootViewController?.dismiss(animated: false, completion: nil)
            
            let currentRoot = window?.rootViewController
            
            UIView.transition(with: window!, duration: 0.3, options: .transitionCrossDissolve, animations: {
                window?.rootViewController = newController
                
            }, completion: nil)
        }
        window?.makeKeyAndVisible()
    }
    
    open func present(_ presented: UIViewController)
    {
        presented.modalTransitionStyle = .crossDissolve
        presented.modalPresentationStyle = .formSheet
        let window = self.bindedToWindow
        let currentRoot = window?.rootViewController
        currentRoot?.present(presented, animated: true)
    }
    
    open func presentMessengerInNewWindow() {
        let window = UIWindow(frame: UIScreen.main.bounds);
//        let window:UIWindow = ((UIApplication.shared.delegate?.window)!)!

//        window.backgroundColor = UIColor.white
        presentMessengerInWindow(window)
        window.makeKeyAndVisible()
    }
    
    //
    // Data Processing
    //
    
    /// Handling URL Opening in application
    open func openUrl(_ url: String) {
        if let u = URL(string: url) {
            
            // Handle phone call
            if (u.scheme?.lowercased() == "telprompt") {
                UIApplication.shared.openURL(u)
                return
            }
            
            // Handle web invite url
            if (u.scheme?.lowercased() == "http" || u.scheme?.lowercased() == "https") &&  inviteUrlHost != nil {
                
                if u.host == inviteUrlHost {
                    let token = u.lastPathComponent
                    joinGroup(token)
                    return
                }
            }
            
            // Handle custom scheme invite url
            if (u.scheme?.lowercased() == inviteUrlScheme?.lowercased()) {
                
                if (u.host == "invite") {
                    let token = u.query?.components(separatedBy: "=")[1]
                    if token != nil {
                        joinGroup(token!)
                        return
                    }
                }
                
                if let bindedController = bindedToWindow?.rootViewController {
                    let alert = UIAlertController(title: nil, message: AALocalized("ErrorUnableToJoin"), preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: AALocalized("AlertOk"), style: .cancel, handler: nil))
                    bindedController.present(alert, animated: true, completion: nil)
                }
                
                return
            }
            
            
            
            if (url.isValidUrl()){
                
                if let bindedController = bindedToWindow?.rootViewController {
                    // Dismiss Old Presented Controller to show new one
                    if let presented = bindedController.presentedViewController {
                        presented.dismiss(animated: true, completion: nil)
                    }
                    
                    // Building Controller for Web preview
                    let controller: UIViewController
                    if #available(iOS 9.0, *) {
                        controller = SFSafariViewController(url: u)
                    } else {
                        controller = AANavigationController(rootViewController: DZNWebViewController(url: u))
                    }
                    if AADevice.isiPad {
                        controller.modalPresentationStyle = .fullScreen
                    }
                    
                    // Presenting controller
                    bindedController.present(controller, animated: true, completion: nil)
                } else {
                    // Just Fallback. Might never happend
                    UIApplication.shared.openURL(u)
                }
            }
        }
    }
    
    /// Handling joining group by token
    func joinGroup(_ token: String) {
        if let bindedController = bindedToWindow?.rootViewController {
            let alert = UIAlertController(title: nil, message: AALocalized("GroupJoinMessage"), preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: AALocalized("AlertNo"), style: .cancel, handler: nil))
            alert.addAction(UIAlertAction(title: AALocalized("GroupJoinAction"), style: .default){ (action) -> Void in
                AAExecutions.execute(Actor.joinGroupViaLinkCommand(withToken: token), type: .safe, ignore: [], successBlock: { (val) -> Void in
                    
                    // TODO: Fix for iPad
                    let groupId = val as! JavaLangInteger
                    let tabBarController = bindedController as! UITabBarController
                    let index = tabBarController.selectedIndex
                    let navController = tabBarController.viewControllers![index] as! UINavigationController
                    if let customController = ActorSDK.sharedActor().delegate.actorControllerForConversation(ACPeer.group(with: groupId.int32Value)) {
                        navController.pushViewController(customController, animated: true)
                    } else {
                        navController.pushViewController(ConversationViewController(peer: ACPeer.group(with: groupId.int32Value)), animated: true)
                    }
                    
                }, failureBlock: nil)
            })
            bindedController.present(alert, animated: true, completion: nil)
        }
    }
    
    /// Tracking page visible
    func trackPageVisible(_ page: ACPage) {
        analyticsDelegate?.analyticsPageVisible(page)
    }
    
    /// Tracking page hidden
    func trackPageHidden(_ page: ACPage) {
        analyticsDelegate?.analyticsPageHidden(page)
    }
    
    /// Tracking event
    func trackEvent(_ event: ACEvent) {
        analyticsDelegate?.analyticsEvent(event)
    }
    
    //
    // File System
    //
    
    open func fullFilePathForDescriptor(_ descriptor: String) -> String {
        return CocoaFiles.pathFromDescriptor(descriptor)
    }
    
    //
    // Manual Online handling
    //
    
    open func didBecameOnline() {
        
        if automaticOnlineHandling {
            fatalError("Manual Online handling not enabled!")
        }
        
        if !isStarted {
            fatalError("Messenger not started")
        }
        
        if !isUserOnline {
            isUserOnline = true
            messenger.onAppVisible()
        }
    }
    
    open func didBecameOffline() {
        if automaticOnlineHandling {
            fatalError("Manual Online handling not enabled!")
        }
        
        if !isStarted {
            fatalError("Messenger not started")
        }
        
        if isUserOnline {
            isUserOnline = false
            messenger.onAppHidden()
        }
    }
    
    //
    // Automatic Online handling
    //
    
    func checkAppState() {
        if UIApplication.shared.applicationState == .active {
            if !isUserOnline {
                isUserOnline = true
                
                // Mark app as visible
                messenger.onAppVisible()
                
                // Notify Audio Manager about app visiblity change
                AAAudioManager.sharedAudio().appVisible()
                
                // Notify analytics about visibilibty change
                // Analytics.track(ACAllEvents.APP_VISIBLEWithBoolean(true))
                
                // Hack for resync phone book
                Actor.onPhoneBookChanged()
            }
        } else {
            if isUserOnline {
                isUserOnline = false
                
                // Notify Audio Manager about app visiblity change
                AAAudioManager.sharedAudio().appHidden()
                
                // Mark app as hidden
                messenger.onAppHidden()
                
                // Notify analytics about visibilibty change
                // Analytics.track(ACAllEvents.APP_VISIBLEWithBoolean(false))
            }
        }
    }
    
    open func applicationDidFinishLaunching(_ application: UIApplication) {
        if !automaticOnlineHandling || !isStarted {
            return
        }
        checkAppState()
    }
    
    open func applicationDidBecomeActive(_ application: UIApplication) {
        if !automaticOnlineHandling || !isStarted {
            return
        }
        checkAppState()
    }
    
    open func applicationWillEnterForeground(_ application: UIApplication) {
        if !automaticOnlineHandling || !isStarted {
            return
        }
        checkAppState()
    }
    
    open func applicationDidEnterBackground(_ application: UIApplication) {
        if !automaticOnlineHandling || !isStarted {
            return
        }
        checkAppState()
        
        // Keep application running for 40 secs
        if messenger.isLoggedIn() {
            var completitionTask: UIBackgroundTaskIdentifier = UIBackgroundTaskIdentifier.invalid
            
            completitionTask = application.beginBackgroundTask(withName: "Completition", expirationHandler: { () -> Void in
                application.endBackgroundTask(completitionTask)
                completitionTask = UIBackgroundTaskIdentifier.invalid
            })
            
            // Wait for 40 secs before app shutdown
            DispatchQueue.global(qos: DispatchQoS.QoSClass.default).asyncAfter(deadline: DispatchTime.now() + Double(Int64(40.0 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)) { () -> Void in
                application.endBackgroundTask(completitionTask)
                completitionTask = UIBackgroundTaskIdentifier.invalid
            }
        }
    }
    
    open func applicationWillResignActive(_ application: UIApplication) {
        if !automaticOnlineHandling || !isStarted {
            return
        }
        
        //
        // This event is fired when user press power button and lock screeen.
        // In iOS power button also cancel ongoint call.
        //
        // messenger.probablyEndCall()
        
        checkAppState()
    }
    
    //
    // Handling remote notifications
    //
    
//    open func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
//        NSLog("PUSH Recebendo notificacao normal didReceiveRemoteNotification")
//        if !messenger.isLoggedIn() {
//            completionHandler(UIBackgroundFetchResult.noData)
//            return
//        }
//        self.completionHandler = completionHandler
//    }
    
    open func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {

        switch application.applicationState {

        case .inactive:
            print("PUSH Recebendo notificacao normal didReceiveRemoteNotification Inactive")
            //Show the view with the content of the push

            if !messenger.isLoggedIn() {
//                self.showMainController()
                self.messenger.forceNetworkCheck()
                completionHandler(.newData)
                return
            }

            self.completionHandler = completionHandler

        case .background:
            print("PUSH Recebendo notificacao normal didReceiveRemoteNotification Background")
            //Refresh the local model
            if !messenger.isLoggedIn() {
//                self.showMainController()
                self.messenger.forceNetworkCheck()
                self.showMainController()
                completionHandler(.newData)
                
                return
            }

            self.completionHandler = completionHandler

        case .active:
            print("PUSH Recebendo notificacao normal didReceiveRemoteNotification Active")
            //Show an in-app banner

            if !messenger.isLoggedIn() {
                completionHandler(UIBackgroundFetchResult.noData)
                return
            }
            self.completionHandler = completionHandler
        }
    }
    
    

    open func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any]) {
        // Nothing?
        log("PUSH Recebendo notificacao normal 2 didReceiveRemoteNotification")
    }

    open func application(_ application: UIApplication, didRegisterUserNotificationSettings notificationSettings: UIUserNotificationSettings) {
         requestPushKit()
    }
    
    //
    // Handling background fetch events
    //
    
    func setCategories(){
        if #available(iOS 10.0, *) {
            let replyAction = UNTextInputNotificationAction(identifier: "reply", title: "Reply message", options: [])
            let replyCategory = UNNotificationCategory(identifier: "reply.category",actions: [replyAction],intentIdentifiers: [], options: [])
            UNUserNotificationCenter.current().setNotificationCategories([replyCategory])
        } else {
            // Fallback on earlier versions
        }
        
    }
    

    @available(iOS 10.0, *)
    public func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        log("PUSH IOS10 Perform with fetch userNotificationCenter")
        let identifier = response.actionIdentifier
        let request = response.notification.request
        //        if !messenger.isLoggedIn() {
        //            self.messenger.forceNetworkCheck()
        //            completionHandler(UIBackgroundFetchResult.noData)
        //            return
        //        }
    
        let peer = request.content.threadIdentifier
        let peerR = ACPeer.fromUniqueId(withLong: jlong(peer)!)

        let nav = AANavigationController()
        nav.navigateDetail(ConversationViewController(peer: peerR!))
        
        if identifier == "reply" {
            let textResponse = response as? UNTextInputNotificationResponse
            let newContent = request.content.threadIdentifier
            let peerR = newContent

            messenger.sendMessage(with: ACPeer.fromUniqueId(withLong: jlong(peerR)!), withText: textResponse?.userText ?? "")

        }
        //        self.completionHandler = completionHandler
        completionHandler()
        
    }
    
        @available(iOS 10.0, *)
        public func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
                log("PUSH IOS10 Perform with fetch userNotificationCenter .badge")
                completionHandler([.badge])
        }

    
//    public func userNotificationCenter(_ center: UNUserNotificationCenter,
    

    
    open func application(_ application: UIApplication, performFetchWithCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        log("PUSH Perform with fetch performFetchWithCompletionHandler")
        if !messenger.isLoggedIn() {
            self.messenger.forceNetworkCheck()
            completionHandler(UIBackgroundFetchResult.noData)
            return
        }
        self.completionHandler = completionHandler
    }
    
//    public func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
//        completionHandler([.alert,.sound])
//        print("comment 1")
//
//    }
    

    
//    open func application(_ application: UIApplication, handleEventsForBackgroundURLSession identifier: String, completionHandler: @escaping () -> Void) {
//        debugPrint("handleEventsForBackgroundURLSession: \(identifier)")
//        backgroundCompletionHandler = completionHandler
//    }
    open func application(_ application: UIApplication, handleEventsForBackgroundURLSession identifier: String, completionHandler: @escaping () -> Void) {
        debugPrint("handleEventsForBackgroundURLSession: \(identifier)")
        self.messenger.forceNetworkCheck()
        backgroundSessionCompletionHandler = completionHandler
    }

    
//    func application(application: UIApplication, handleEventsForBackgroundURLSession identifier: String, completionHandler: @escaping () -> Void) {
//        backgroundCompletionHandler = completionHandler
//    }
    
//    private func initUrlSessionWith(identifier: String) {
//        let config = URLSessionConfiguration.background(withIdentifier: identifier)
//        config.sharedContainerIdentifier = "group.de.stefantrauth.Downloader"
//        urlSession = URLSession(configuration: config, delegate: self, delegateQueue: OperationQueue.main)
//    }
//
//
//    func application(application: UIApplication, handleEventsForBackgroundURLSession identifier: String, completionHandler: @escaping () -> Void) {
//        print("handleEventsForBackgroundURLSession")
//        initUrlSessionWith(identifier: identifier)
//        urlSessionBackgroundCompletionHandler = completionHandler
//    }
//
//    func urlSessionDidFinishEvents(forBackgroundURLSession session: URLSession) {
//        DispatchQueue.main.async {
//            print("urlSessionDidFinishEvents")
//            self.urlSessionBackgroundCompletionHandler?()
//            self.urlSessionBackgroundCompletionHandler = nil
//        }
//    }
    
//    func urlSessionDidFinishEvents(forBackgroundURLSession session: URLSession) {
//        DispatchQueue.main.async {
//            guard let appDelegate = UIApplication.shared.delegate as? ActorSDK,
//                let backgroundCompletionHandler =
//                appDelegate.backgroundCompletionHandler else {
//                    return
//            }
//            backgroundCompletionHandler()
//        }
//    }
    
//    open func application(_ application: UIApplication, performFetchWithCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
//        logger.log.debug("Perform Fetch with completion handler TEST")
//    }
    
    
    //
    // Handling invite url
    //
    
    func application(_ application: UIApplication, openURL url: URL, sourceApplication: String?, annotation: AnyObject) -> Bool {
        
        dispatchOnUi { () -> Void in
            self.openUrl(url.absoluteString)
        }
        
        return true
    }
    
    open func application(_ application: UIApplication, handleOpenURL url: URL) -> Bool {
        
        dispatchOnUi { () -> Void in
            self.openUrl(url.absoluteString)
        }
        
        return true
    }
    
    open func resetAuth() {
        
        messenger.resetAuth()
        
    }
    open func onAfterReset() {
//        isStarted = false
        self.bindedToWindow.rootViewController = AAWelcomeController()
//        modules.run()
//        modules.onLoggedIn(withBoolean: false)
//        isStarted = false
        
    }
    
}

public enum AAAutoPush {
    case none
    case fromStart
    case afterLogin
}

public enum AAAuthStrategy {
    case phoneOnly
    case emailOnly
    case phoneEmail
}
