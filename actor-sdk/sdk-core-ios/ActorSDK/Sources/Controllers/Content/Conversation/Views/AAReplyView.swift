//
//  AAReplyView.swift
//  AloSDK
//
//  Created by Alcyone on 14.02.2018.
//

import Foundation

class ReplyView: UIView {
    @IBOutlet weak var username: UILabel!
    @IBOutlet weak var message: UILabel!
    
    var onClose: (() -> Void)?
    
    @IBAction func closePressed(_ sender: UIButton) {
        onClose?()
    }
}
