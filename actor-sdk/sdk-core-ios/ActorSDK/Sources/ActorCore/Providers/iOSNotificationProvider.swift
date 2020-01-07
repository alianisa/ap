//
//  Copyright (c) 2014-2015 Actor LLC. <https://actor.im>
//

import Foundation
import AVFoundation
import AudioToolbox.AudioServices
import UserNotifications

@objc class iOSNotificationProvider: NSObject, ACNotificationProvider {


//    var isLoaded = false
//    var internalMessage:SystemSoundID = 0
//    var sounds: [String: SystemSoundID] = [:]
//    var lastSoundPlay: Double = 0
//
//    override init() {
//        super.init()
//    }
//
//    func loadSound(_ soundFile:String? = ""){
//        if !isLoaded {
//            isLoaded = true
//
////            var path = Bundle.framework.url(forResource: "notification", withExtension: "caf")
////
////            if let fileURL: URL = URL(fileURLWithPath: "/Library/Ringtones/\(soundFile)") {
////                path = fileURL
////            }
//
////            AudioServicesCreateSystemSoundID(path! as CFURL, &internalMessage)
//            let filePath = Bundle.framework.path(forResource: "sent", ofType: "aif")
//            var chime3URL: NSURL?
//            var chime3ID:SystemSoundID = 0
//            chime3URL = NSURL(fileURLWithPath: filePath!)
//            AudioServicesCreateSystemSoundID(chime3URL!, &internalMessage)
//        }
//    }
//

    
    var isLoaded = false
    var internalMessage:SystemSoundID = 0
    var sounds: [String: SystemSoundID] = [:]
    var lastSoundPlay: Double = 0
    var chime3URL: NSURL?
    
    var isInApp = false
    
    
    override init() {
        super.init()
    }

    
    
    func loadSound(_ soundFile:String? = ""){
        if !isLoaded {
            isLoaded = true
            
//            var path = Bundle.framework.url(forResource: "notification", withExtension: "caf")
            var path = Bundle.framework.path(forResource: "notification", ofType: "aif")
//            if let fileURL: URL = URL(fileURLWithPath: "/Library/Ringtones/\(soundFile)") {
//                path = fileURL
//            }
                    chime3URL = NSURL(fileURLWithPath: path!)
                    AudioServicesCreateSystemSoundID(chime3URL!, &internalMessage)
//            AudioServicesCreateSystemSoundID(path! as CFURL, &internalMessage)
        }
    }
    
    func onMessageArriveInApp(with messenger: ACMessenger!) {
        let currentTime = Date().timeIntervalSinceReferenceDate
        if (currentTime - lastSoundPlay > 1) {
            let peer = ACPeer.user(with: jint(messenger.myUid()))
            let soundFileSting = messenger.getNotificationsSound(with: peer)
            loadSound(soundFileSting)
            AudioServicesPlaySystemSound(internalMessage)
            lastSoundPlay = currentTime
        }

//        var notification = topNotifications.description
//
//
//        messenger.getFormatter().formatNotificationText(n)
//
//        var message = messenger.getFormatter().formatNotificationText(n)
//        if (!messenger.isShowNotificationsText()) {
//            message = NSLocalizedString("NotificationSecretMessage", comment: "New Message")
//        }
//        var senderUser = messenger.getUserWithUid(n.sender)
//        var sender = senderUser.getNameModel().get()
//        var peer = n.peer
//
//        if (UInt(n.peer.peerType) == ACPeerType.group()) {
//            var group = messenger.getGroupWithGid(n.peer.peerId)
//            sender = "\(sender ?? "")@\(group.getNameModel().get() ?? "")"
//        }
//        if #available(iOS 10.0, *) {
//
//            let content = UNMutableNotificationContent()
//            content.title = sender!
//            content.body = message!
//            content.sound = UNNotificationSound.init(named: "iapetus.caf")
//            content.categoryIdentifier = "reply.category"
//            content.threadIdentifier = String(n.peer.getUnuqueId())
//
//
//            let trigger = UNTimeIntervalNotificationTrigger.init(timeInterval: 0.1, repeats: false) //покажет через 5 секунд
//            var requestID = random(8);
//            print("onNotification \(requestID)")
//            let request = UNNotificationRequest(identifier:requestID, content: content, trigger: trigger)
//
//            addNotification(content: content, trigger: trigger , indentifier: requestID)
//
//        } else {
//
//        }

        isInApp = true
//        inApp()
//        ActorSDK.sharedActor().show = true
        print("onMessageArriveInApp")
    }
    
    
//    func onNotificationWithMessenger(messenger: ACMessenger!, withTopNotifications topNotifications: JavaUtilListProtocol!, withMessagesCount messagesCount: jint, withConversationsCount conversationsCount: jint, withIsInApp isInApp: Bool) {
//
//
//
//    }
    
//    func onMessageArriveInApp(with messenger: ACMessenger!) {
//        let currentTime = Date().timeIntervalSinceReferenceDate
//        if (currentTime - lastSoundPlay > 0.2) {
//            let peer = ACPeer.user(with: jint(messenger.myUid()))
//            let soundFileSting = messenger.getNotificationsSound(with: peer)
//            loadSound(soundFileSting)
//            AudioServicesPlaySystemSound(internalMessage)
//            lastSoundPlay = currentTime
//        }
////        iOSNotificationProvider.playSent(true)
//        
//        print("onMessageArriveInApp")
//
//    }
    
    
    func onNotification(with messenger: ACMessenger!, withTopNotifications topNotifications: JavaUtilList!, withMessagesCount messagesCount: jint, withConversationsCount conversationsCount: jint) {
//        if (isInApp) {
//            let currentTime = Date().timeIntervalSinceReferenceDate
//            if (currentTime - lastSoundPlay > 0.2) {
//                let peer = ACPeer.user(with: jint(messenger.myUid()))
//                let soundFileSting = messenger.getNotificationsSound(with: peer)
//                loadSound(soundFileSting)
//                AudioServicesPlaySystemSound(internalMessage)
//                lastSoundPlay = currentTime
//            }
//        }
        
        //        if (isInApp) {
        //            if (messenger.isInAppNotificationSoundEnabled()) {
        //                var path = getNotificationSound(messenger)
        //                if (sounds[path] == nil) {
        //                    var fileUrl = NSBundle.mainBundle().URLForResource(path, withExtension: "caf");
        //                    var messageSound:SystemSoundID = 0
        //                    AudioServicesCreateSystemSoundID(fileUrl, &messageSound)
        //                    sounds[path] = messageSound
        //                }
        //                AudioServicesPlaySystemSound(sounds[path]!)
        //            }
        
        //            if (messenger.isInAppNotificationVibrationEnabled()) {
        //                AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
        //            }
        //            dispatchOnUi { () -> Void in
        //                TWMessageBarManager.sharedInstance().showMessage(withTitle: sender, description: message, type: TWMessageBarMessageType.info, callback: { () -> Void in
        //                    var root = UIApplication.shared.keyWindow!.rootViewController!
        //                    if let tab = root as? AARootTabViewController {
        //                        var controller = tab.viewControllers![tab.selectedIndex] as! AANavigationController
        //                        var destController = ConversationViewController(peer: peer)
        //                        destController.hidesBottomBarWhenPushed = true
        //                        controller.pushViewController(destController, animated: true)
        //                    } else if let split = root as? AARootSplitViewController {
        //                        split.navigateDetail(ConversationViewController(peer: peer))
        //                    }
        //                })
        //            }
        //        } else {
        //            dispatchOnUi { () -> Void in
        //                var localNotification =  UNMutableNotificationContent()
        //                localNotification.alertBody = "\(sender): \(message)"
        //                localNotification.body = "message"
        //                localNotification.title = "sender"
        
        var notification = topNotifications.description
        // Not Supported
        
        
//        print("onNotificationWithMessenger")
        
        let n = topNotifications.getWith(topNotifications.size() - 1) as! ACNotification
        
        
        
//        var n = topNotifications.getWith(0) as! ACNotification

//        messenger.getFormatter().formatNotificationText(n)
//
//        var message = messenger.getFormatter().formatNotificationText(n)
//        if (!messenger.isShowNotificationsText()) {
//            message = NSLocalizedString("NotificationSecretMessage", comment: "New Message")
//        }
//        let senderUser = messenger.getUserWithUid(n.sender)
//        var sender = senderUser.getNameModel().get()
//        let peer = n.peer as! ACPeer
//        let group = messenger.getGroupWithGid(n.peer.peerId)
//        //
////                if (peer.peerType == ACPeerType.group()) {
////
////                    sender = "\(sender ?? "")@\(group.getNameModel().get() ?? "")"
////                }
        
        messenger.getFormatter().formatNotificationText(n)
        
        var message = messenger.getFormatter().formatNotificationText(n)
        if (!messenger.isShowNotificationsText()) {
            message = NSLocalizedString("NotificationSecretMessage", comment: "New Message")
        }
        var senderUser = messenger.getUserWithUid(n.sender)
        var sender = senderUser.getNameModel().get()
        var peer = n.peer

        if (UInt(n.peer.peerType) == ACPeerType.group()) {
            var group = messenger.getGroupWithGid(n.peer.peerId)
            sender = "\(sender ?? "")@\(group.name.get() ?? "")"
        }
        if #available(iOS 10.0, *) {

            let content = UNMutableNotificationContent()
            content.title = sender!
            content.body = message!
            content.categoryIdentifier = "reply.category"
            content.threadIdentifier = String(n.peer.getUnuqueId())

            if self.isInApp == true {
                content.setValue("YES", forKeyPath: "shouldAlwaysAlertWhileAppIsForeground")
                self.isInApp = false
            } else {
                content.sound = UNNotificationSound.init(named: UNNotificationSoundName(rawValue: "iapetus.caf"))
            }
            
//            let now = Date(timeIntervalSince1970: TimeInterval(Double(n.date) / 1000.0))
//
//            let gregorian = Calendar(identifier: .gregorian)
//            let now = Date()
//            var components = gregorian.dateComponents([.year, .month, .day, .hour, .minute, .second], from: now)
            
            // Change the time to 7:00:00 in your locale
//            components.hour = 7
//            components.minute = 25
//            components.second = 0
            
//            let date = gregorian.date(from: components)!
//
//            let triggerDaily = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute, .second,], from: date)
//            let trigger = UNCalendarNotificationTrigger(dateMatching: triggerDaily, repeats: false)

            
//            print("onNotification date: \(components)")
            
            let trigger = UNTimeIntervalNotificationTrigger.init(timeInterval: 1, repeats: false)
            
            var requestID = random(8);
            print("onNotification \(requestID)")
            let request = UNNotificationRequest(identifier:requestID, content: content, trigger: trigger)
            
            if self.isInApp == false {
                addNotification(content: content, trigger: trigger , indentifier: requestID)
                self.isInApp = false
            }
            
        } else {
            
        }
        

        
    }
    
    func inApp() {
        
        if !(isInApp) {
        
            isInApp = true
        
            @available(iOS 10.0, *)
            func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
            log("PUSH IOS10 Perform with fetch userNotificationCenter .badge")
            completionHandler([.alert])
            }
        }
    }
    
    @available(iOS 10.0, *)
    func addNotification(content:UNNotificationContent,trigger:UNNotificationTrigger?, indentifier:String){
        let request = UNNotificationRequest(identifier: indentifier, content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request, withCompletionHandler: {
            (errorObject) in
            if let error = errorObject{
                print("Error \(error.localizedDescription) in notification \(indentifier)")
            }
        })
    }
    
    func random(_ n: Int) -> String
    {
        let a = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890"
        
        var s = ""
        
        for _ in 0..<n
        {
            let r = Int(arc4random_uniform(UInt32(a.count)))
            
            s += String(a[a.index(a.startIndex, offsetBy: r)])
        }
        
        return s
    }
    
//    func onNotificationWithMessenger(messenger: ACMessenger!, withTopNotifications topNotifications: JavaUtilList!, withMessagesCount messagesCount: jint, withConversationsCount conversationsCount: jint, withIsInApp isInApp: Bool) {
//
//        var n = topNotifications.getWithInt(0) as! ACNotification
//
//        messenger.getFormatter().formatNotificationText(n)
//
//        var message = messenger.getFormatter().formatNotificationText(n)
//        if (!messenger.isShowNotificationsText()) {
//            message = NSLocalizedString("NotificationSecretMessage", comment: "New Message")
//        }
//        var senderUser = messenger.getUserWithUid(n.getSender())
//        var sender = senderUser.getNameModel().get()
//        var peer = n.getPeer()
//
//        if (UInt(n.getPeer().getPeerType().ordinal()) == ACPeerType.GROUP.rawValue) {
//            var group = messenger.getGroupWithGid(n.getPeer().getPeerId())
//            sender = "\(sender)@\(group.getNameModel().get())"
//        }
//
//        if (isInApp) {
//            if (messenger.isInAppNotificationSoundEnabled()) {
//                var path = getNotificationSound(messenger)
//                if (sounds[path] == nil) {
//                    var fileUrl = NSBundle.mainBundle().URLForResource(path, withExtension: "caf");
//                    var messageSound:SystemSoundID = 0
//                    AudioServicesCreateSystemSoundID(fileUrl, &messageSound)
//                    sounds[path] = messageSound
//                }
//                AudioServicesPlaySystemSound(sounds[path]!)
//            }
//
//            if (messenger.isInAppNotificationVibrationEnabled()) {
//                AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
//            }
//            dispatchOnUi { () -> Void in
//                TWMessageBarManager.sharedInstance().showMessageWithTitle(sender, description: message, type: TWMessageBarMessageType.Info, callback: { () -> Void in
//                    var root = UIApplication.sharedApplication().keyWindow!.rootViewController!
//                    if let tab = root as? MainTabViewController {
//                        var controller = tab.viewControllers![tab.selectedIndex] as! AANavigationController
//                        var destController = ConversationViewController(peer: peer)
//                        destController.hidesBottomBarWhenPushed = true
//                        controller.pushViewController(destController, animated: true)
//                    } else if let split = root as? MainSplitViewController {
//                        split.navigateDetail(ConversationViewController(peer: peer))
//                    }
//                })
//            }
//        } else {
//            dispatchOnUi { () -> Void in
//                var localNotification =  UILocalNotification ()
//                localNotification.alertBody = "\(sender): \(message)"
//                if (messenger.isNotificationSoundEnabled()) {
//                    localNotification.soundName = "\(self.getNotificationSound(messenger)).caf"
//                }
//                UIApplication.sharedApplication().presentLocalNotificationNow(localNotification)
//            }
//        }
//    }
    
    func onUpdateNotification(with messenger: ACMessenger!, withTopNotifications topNotifications: JavaUtilList!, withMessagesCount messagesCount: jint, withConversationsCount conversationsCount: jint) {
        // Not Supported
        print("onUpdateNotification")
    }
    
    func hideAllNotifications() {
        dispatchOnUi { () -> Void in
            // Clearing notifications
            if let number = Actor.getGlobalState().globalCounter.get() {
                UIApplication.shared.applicationIconBadgeNumber = 0 // If current value will equals to number + 1
                UIApplication.shared.applicationIconBadgeNumber = number.intValue + 1
                UIApplication.shared.applicationIconBadgeNumber = number.intValue
            } else {
                UIApplication.shared.applicationIconBadgeNumber = 0
            }

            // Clearing local notifications
            UIApplication.shared.cancelAllLocalNotifications()
            print("hideAllNotifications")
            if #available(iOS 10.0, *) {
                let center = UNUserNotificationCenter.current()
                center.removeAllDeliveredNotifications() // To remove all delivered notifications
                center.removeAllPendingNotificationRequests()

            } else {
                // Fallback on earlier versions
            }

        }
    }
    
    func playSound() {
        let currentTime = Date().timeIntervalSinceReferenceDate
        if (currentTime - lastSoundPlay > 0.5) {
//            let send = Actor.isSendButton()
//            let sendButton = sendButton
            var chime3URL: NSURL?
            var chime3ID:SystemSoundID = 0
            let filePath = Bundle.framework.path(forResource: "sent-", ofType: "caf")
            chime3URL = NSURL(fileURLWithPath: filePath!)
            AudioServicesCreateSystemSoundID(chime3URL!, &chime3ID)
//            if sendButton {
                AudioServicesPlaySystemSound(chime3ID)
                lastSoundPlay = currentTime
                print("send:")
            lastSoundPlay = currentTime
//            }
        }
    }
    
//    var au:Bool = false
//    var cc : ConversationViewController?
//    var isau:Bool = true
//    var avatarView:AAAvatarView?
//
//    func onAvatarUpdated(withId uid: jlong) {
//        Actor.onAvatarUpdated(jint(uid))
//        au = true
//        isAvatarUpdated()
        
//
//        if cc!.isAvatarUpdated != nil {
//            print("isAvatarUpdated 1")
////            self.isau = true
//
//        } else {
//            print("isAvatarUpdated nil")
//        }
//     AAAvatarView.reload()
        
//    }
    
//    public func isAvatarUpdated() -> jboolean {
//        if au {
//           return true
//        }
//        return false
//    }

}
