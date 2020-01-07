//
//  AACallsViewController.swift
//  AloSDK
//
//  Created by Alcyone on 26.08.17.
//  Copyright © 2017 Steve Kite. All rights reserved.
//

import Foundation
import AVFoundation
import UIKit
import CallKit

open class AACallsViewController: AAViewController {
    
    public override init() {
        super.init()
        
//        content = ACAllEvents_Main.contacts()
        
//        tabBarItem = UITabBarItem(title: "TabPeople", img: "TabIconContacts", selImage: "TabIconContactsHighlighted")
//        
//        navigationItem.title = AALocalized("TabPeople")
//        navigationItem.backBarButtonItem = UIBarButtonItem(title: AALocalized("ContactsBack"), style: UIBarButtonItemStyle.plain, target: nil, action: nil)
//        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.add, target: self, action: #selector(presentCallView))
        
    }

    public required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override open func viewDidLoad() {
        super.viewDidLoad()
        if #available(iOS 10.0, *) {
//            presentCallView()
        }
    }
    

    func presentCallView() {
//        userCoreDataInstance.StoreCallDataLog(_callerID: IncomingCallController.CallToAction == true ? IncomingCallController.dialPhoneNumber : LinphoneManager.getCallerNb(), _callerName: IncomingCallController.CallToAction == true ? "" : LinphoneManager.getContactName(), _callDuration: callDuration, _callIndicatorIcon: IncomingCallController.CallToAction == true ? "outgoing-call-icon" : "incoming-call-icon")
        
//        print("--- SAVED", IncomingCallController.dialPhoneNumber)
//            let storyboardBundle = Bundle(for: InternalCallController.self)
//            let storyBoard: UIStoryboard = UIStoryboard(name: "Call", bundle: storyboardBundle)
//            let newViewController = storyBoard.instantiateViewController(withIdentifier: "InternalCallController")
////            let rootController = ActorSDK.sharedActor().bindedToWindow.rootViewController!
//            //        let main = ActorSDK.sharedActor().
////            rootController.present(newViewController, animated: true, completion: nil)
//            UIApplication.topViewController()?.present(newViewController, animated: true, completion: nil)
        
        
//        let frameworkBundle = Bundle(for: AACallsViewController.self) //getting the bundle for the framework
        let s: UIStoryboard = UIStoryboard(name: "Call", bundle: nil)
        let vc = s.instantiateViewController(withIdentifier: "DialerN")
//        self.present(vc, animated: true, completion: nil)
        let rootController = ActorSDK.sharedActor().bindedToWindow.rootViewController!
        rootController.present(vc, animated: true, completion: nil)
    }
}
