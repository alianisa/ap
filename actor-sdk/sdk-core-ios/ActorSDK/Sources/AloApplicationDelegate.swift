import Foundation
import CoreData
import CallKit
import Reachability
import UserNotifications

//@available(iOS 10.0, *)
//let personService = UserProfileCoreData()
//let appDelegate = UIApplication.shared.delegate as! ActorApplicationDelegate
//@available(iOS 10.0, *)
//let manageObjectContext  = appDelegate.persistentContainer.viewContext





open class ActorApplicationDelegate: ActorSDKDelegateDefault, UIApplicationDelegate, UNUserNotificationCenterDelegate {

    func displayIncomingCall(uuid: UUID, handle: String, completion: ((NSError?) -> Void)?) {
        
//        if #available(iOS 10.0, *) {
//            let callKitManager = CallKitCallInit(uuid: UUID(), handle: "")
//            var providerDelegate: ProviderDelegate = ProviderDelegate(callKitManager: callKitManager)
//            providerDelegate.reportIncomingCall(uuid: uuid, handle: handle, completion: completion)
//        }
    }
    
    public override init() {
        super.init()
        ActorSDK.sharedActor().delegate = self
    }
    
    open func applicationDidFinishLaunching(_ application: UIApplication) {
        ActorSDK.sharedActor().applicationDidFinishLaunching(application)
    }
    
    open func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        ActorSDK.sharedActor().applicationDidFinishLaunching(application)
        if #available(iOS 10.0, *) {
//            var linphoneManager: LinphoneManager?
//            linphoneManager = LinphoneManager()
//            linphoneManager?.LinphoneInit()
        } else {
            // Fallback on earlier versions
        }
        return true
    }
    
    open func applicationDidBecomeActive(_ application: UIApplication) {
        ActorSDK.sharedActor().applicationDidBecomeActive(application)
    }
    
    open func applicationWillEnterForeground(_ application: UIApplication) {
        ActorSDK.sharedActor().applicationWillEnterForeground(application)
    }
    
    open func applicationDidEnterBackground(_ application: UIApplication) {
        ActorSDK.sharedActor().applicationDidEnterBackground(application)
    }
    
    open func applicationWillResignActive(_ application: UIApplication) {
        ActorSDK.sharedActor().applicationWillResignActive(application)
    }
    
    open func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any]) {
        log("PUSH ActorApplicationDelegate Receive notification 1...")
        ActorSDK.sharedActor().application(application, didReceiveRemoteNotification: userInfo)
    }
//    
    open func application(_ application: UIApplication, didRegister notificationSettings: UIUserNotificationSettings) {
        ActorSDK.sharedActor().application(application, didRegisterUserNotificationSettings: notificationSettings)
    }
//    
    open func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        let tokenString = deviceToken.map { String(format: "%02.2hhx", $0) }.joined()
        log("PUSH Registrando o servico de notificacoes para o token \(tokenString)")
        ActorSDK.sharedActor().pushRegisterToken(tokenString.replace(" ", dest: "").replace("<", dest: "").replace(">", dest: ""))
    }
    
    open func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        log("PUSH ActorApplicationDelegate Receive notification 2...")
        ActorSDK.sharedActor().application(application, didReceiveRemoteNotification: userInfo, fetchCompletionHandler: completionHandler)
    }
    
    open func application(_ application: UIApplication, performFetchWithCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        log("PUSH ActorApplicationDelegate Receive notification 3...")
        ActorSDK.sharedActor().application(application, performFetchWithCompletionHandler: completionHandler)
    }
    
    
//    open func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
//        log("PUSH IOS10 Perform with fetch userNotificationCenter 1")
//        ActorSDK.sharedActor().userNotificationCenter(center, didReceive: response, withCompletionHandler: completionHandler)
//        
////        (userNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: completionHandler)
//    }
    
//    public func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
//        
//        log("PUSH IOS10 Perform with fetch userNotificationCenter 2")
//        
//        ActorSDK.sharedActor().userNotificationCenter(center, willPresent: notification, withCompletionHandler: completionHandler)
//    }

    open func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
        return ActorSDK.sharedActor().application(application, openURL: url, sourceApplication: sourceApplication, annotation: annotation as AnyObject)
    }
    
    open func application(_ application: UIApplication, handleOpen url: URL) -> Bool {
        return ActorSDK.sharedActor().application(application, handleOpenURL: url)
    }
    
    @available(iOS 9.0, *)
    open func application(_ application: UIApplication, performActionFor shortcutItem: UIApplicationShortcutItem, completionHandler: @escaping (Bool) -> Void) {
        if shortcutItem.type == "newmessage" {
            let nav = AANavigationController()
            nav.navigateDetail(AAComposeController())
        }
    }
    
    open func application(_ application: UIApplication, handleEventsForBackgroundURLSession identifier: String, completionHandler: @escaping () -> Void) {
        return ActorSDK.sharedActor().application(application, handleEventsForBackgroundURLSession: identifier, completionHandler: completionHandler)
    }
    
    open func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        guard let handle = url.startCallHandle else {
            print("Could not determine start call handle from URL: \(url)")
            return false
        }

        AAExecutions.execute(Actor.findUsersCommand(withQuery: handle), successBlock: { (val) -> () in
            var user: ACUserVM?

            user = val as? ACUserVM
            if user == nil {
                if let users = val as? IOSObjectArray {
                    if Int(users.length()) > 0 {
                        if let tempUser = users.object(at: 0) as? ACUserVM {
                            user = tempUser
                        }
                    }
                }
            }
            
            if #available(iOS 10.0, *) {
                AAExecutions.execute(ActorSDK.sharedActor().messenger.doCall(withUid: user!.getId()))
            } else {
                // Fallback on earlier versions
            }
        }, failureBlock: { (val) -> () in

        })
        
        return true
    }
    
    open func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([Any]?) -> Void) -> Bool {
        if #available(iOS 10.0, *) {
            guard let handle = userActivity.startCallHandle else {
                print("Could not determine start call handle from user activity: \(userActivity)")
                return false
            }
            guard let video = userActivity.video else {
                print("Could not determine video from user activity: \(userActivity)")
                return false
            }
            
//            AACallCenter.sharedCallCenter().startOutgoingCall(of: handle, isVideo: video)

//            AAExecutions.execute(Actor.findUsersCommand(withQuery: handle), successBlock: { (val) -> () in
//                var user: ACUserVM?
//
//                user = val as? ACUserVM
//                if user == nil {
//                    if let users = val as? IOSObjectArray {
//                        if Int(users.length()) > 0 {
//                            if let tempUser = users.object(at: 0) as? ACUserVM {
//                                user = tempUser
//                            }
//                        }
//                    }
//                }
//                AAExecutions.execute(ActorSDK.sharedActor().messenger.doCall(withUid: user!.getId()))
            AAExecutions.execute(ActorSDK.sharedActor().messenger.doCall(withUid: jint(handle)!))


//            }, failureBlock: { (val) -> () in
//
//            })
            
        } else {
            // Fallback on earlier versions
        }
        
        return true

    }
    
    // MARK: - Core Data stack
    
//    @available(iOS 10.0, *)
//    lazy var persistentContainer: NSPersistentContainer = {
//        /*
//         The persistent container for the application. This implementation
//         creates and returns a container, having loaded the store for the
//         application to it. This property is optional since there are legitimate
//         error conditions that could cause the creation of the store to fail.
//         */
//        let container = NSPersistentContainer(name: "CallData")
//        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
//            if let error = error as NSError? {
//                // Replace this implementation with code to handle the error appropriately.
//                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
//                
//                /*
//                 Typical reasons for an error here include:
//                 * The parent directory does not exist, cannot be created, or disallows writing.
//                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
//                 * The device is out of space.
//                 * The store could not be migrated to the current model version.
//                 Check the error message to determine what the actual problem was.
//                 */
//                fatalError("Unresolved error \(error), \(error.userInfo)")
//            }
//        })
//        return container
//    }()
    // MARK: - Core Data Saving support
//    @available(iOS 10.0, *)
//    func saveContext () {
//        let context = persistentContainer.viewContext
//        if context.hasChanges {
//            do {
//                try manageObjectContext.save()
//            } catch {
//                // Replace this implementation with code to handle the error appropriately.
//                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
//                let nserror = error as NSError
//                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
//            }
//        }
//    }
    
    var reachability: Reachability!
}
