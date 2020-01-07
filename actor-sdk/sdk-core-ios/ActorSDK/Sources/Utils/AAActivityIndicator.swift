//
//  AAActivityIndicator.swift
//  AloSDK
//
//  Created by Alcyone on 30/12/2019.
//

import Foundation
import UIKit


class ActivityIndicator {
    private init() {}
    
    //1
    static let shared = ActivityIndicator()
    
    //2
    let activityLabel = UILabel(frame: CGRect(x: 24, y: 0, width: 140, height: 50))
    
    //3
    let activityIndicator = UIActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 20, height: 20))
    
    //4
    let activityView = UIView()
    
    func animateActivity(title: String, view: UIView, navigationItem: UINavigationItem) {
        guard navigationItem.titleView == nil else { return }
        
        //1
//        activityIndicator.style = .gray
        activityLabel.text = title
        activityLabel.font = UIFont.boldSystemFont(ofSize: UIFont.systemFontSize)
        activityLabel.isHighlighted = true
        
        //2
        activityLabel.sizeToFit()
        
        
        //3
        let xPoint = view.frame.midX
        let yPoint = navigationItem.accessibilityFrame.midY
        let widthForActivityView = activityLabel.frame.width + activityIndicator.frame.width
        activityView.frame = CGRect(x: xPoint, y: yPoint, width: widthForActivityView, height: 50)
        
        activityLabel.center.y = activityView.center.y
        activityIndicator.center.y = activityView.center.y
        
        //4
        activityView.addSubview(activityIndicator)
        activityView.addSubview(activityLabel)
        
        //5
        navigationItem.titleView = activityView
//        if #available(iOS 11.0, *) {
//            navigationItem.largeTitleDisplayMode = .never
//        } else {
//            // Fallback on earlier versions
//        }
        activityIndicator.startAnimating()
    }
    
    func stopAnimating(navigationItem: UINavigationItem) {
        activityIndicator.stopAnimating()
        navigationItem.titleView = nil
        if #available(iOS 11.0, *) {
            navigationItem.largeTitleDisplayMode = .automatic
        } else {
            // Fallback on earlier versions
        }
        activityLabel.font = UIFont.systemFont(ofSize: UIFont.systemFontSize)
        activityLabel.isHighlighted = false
    }
}
