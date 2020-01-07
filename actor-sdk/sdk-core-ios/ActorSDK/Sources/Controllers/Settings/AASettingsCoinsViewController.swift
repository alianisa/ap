//
//  AASettingsCoinsViewController.swift
//
//  Created by Alcyone on 17.11.16.
//  Copyright © 2016 Steve Kite. All rights reserved.
//

import Foundation
import UnityAds

class ViewController: UIViewController, UnityAdsDelegate {
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    func unityAdsReady(_ placementId: String) {
        //Called when Unity Ads is ready to show an ad
    }
    
    func unityAdsDidStart(_ placementId: String) {
        //Called when Uniy Ads begins playing a video
    }
    
    func unityAdsDidFinish(_ placementId: String, with state: UnityAdsFinishState) {
        //Called when a video completes
    }
    
    func unityAdsDidError(_ error: UnityAdsError, withMessage message: String) {
    }
}
