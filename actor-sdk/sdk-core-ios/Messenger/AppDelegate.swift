//
//  Copyright (c) 2014-2016 Actor LLC. <https://actor.im>
//

import Foundation
import CoreData
import AloSDK
import UIKit

open class AppDelegate : ActorApplicationDelegate {
    
//    var window: UIWindow?
    var window: UIWindow?
    
    override init() {
        super.init()
        
//        ActorSDK.sharedActor().inviteUrlHost = "alome.uz"
//        ActorSDK.sharedActor().inviteUrlScheme = "alome"
        
        ActorSDK.sharedActor().style.searchStatusBarStyle = .lightContent
        
        // Enabling experimental features
        ActorSDK.sharedActor().enableExperimentalFeatures = true
        
        ActorSDK.sharedActor().enableCalls = true
        
        ActorSDK.sharedActor().enableVideoCalls = false
        
        // Setting Development Push Id
        ActorSDK.sharedActor().apiPushId = 868548
        
        ActorSDK.sharedActor().authStrategy = .phoneEmail
        
//        ActorSDK.sharedActor().style.dialogAvatarSize = 72
        
        ActorSDK.sharedActor().autoJoinGroups = ["alonews"]
        
        // Creating Actor
        ActorSDK.sharedActor().createActor()
        
    }
    
    //open override func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey : Any]?) -> Bool {
    //    super.application(application, didFinishLaunchingWithOptions: launchOptions)
    //
    //    ActorSDK.sharedActor().presentMessengerInNewWindow()
    //
    //    return true
    //}
    
//    open override func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey : Any]?) -> Bool {
//
//
////        if #available(iOS 9.0, *) {
//////            if let shortcutIttems = application.shortcutItems , shortcutIttems.isEmpty {
//////                let dynamicShortcut = UIMutableApplicationShortcutItem(type: "newmessage", localizedTitle: "New Message", localizedSubtitle: "Staart", icon: UIApplicationShortcutIcon(type: .compose), userInfo: nil)
//////                application.shortcutItems = [dynamicShortcut]
//////            }
////        } else {
////            // Fallback on earlier versions
////        }
//        let _ = super.application(application, didFinishLaunchingWithOptions: launchOptions)
//        //#注册切换Root控制器通知
//        NotificationCenter.default.addObserver(self, selector: #selector(switchRootViewController), name: ActorSDK.sharedActor().switchRootController, object: nil)
//        //        ActorSDK.sharedActor().presentMessengerInNewWindow()
//
//        window = UIWindow(frame:UIScreen.main.bounds)
//        window?.backgroundColor = UIColor.white
//        window?.rootViewController = WelcomeViewController()
//        window?.makeKeyAndVisible()
//
//
//        //#启动图
////        addLaunchController()
//        return true
//    }
//
//    //    open override func actorRootControllers() -> [UIViewController]? {
//    //        return [AAContactsViewController(), AARecentViewController(), AASettingsViewController()]
//    //    }
//
//    open override func actorRootInitialControllerIndex() -> Int? {
//        return 1
//    }
//    func switchRootViewController(){
//        ActorSDK.sharedActor().presentMessengerInNewWindow()
//    }
////    private func addLaunchController() {
////        image.delegate = self
////        image.getLaunchImage()
////    }
    
    open override func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]?) -> Bool {
        super.application(application, didFinishLaunchingWithOptions: launchOptions)
        
        ActorSDK.sharedActor().presentMessengerInNewWindow()
        
        return true
    }
    
    open override func actorRootControllers() -> [UIViewController]? {
        return [AAContactsViewController(), AARecentViewController(), AASettingsViewController()]
    }
    
    open override func actorRootInitialControllerIndex() -> Int? {
        return 1
    }
    
    open override func showStickersButton() -> Bool{
        return true
    }
    
    open override func useOnClientPrivacy() -> Bool{
        return true
    }
}
