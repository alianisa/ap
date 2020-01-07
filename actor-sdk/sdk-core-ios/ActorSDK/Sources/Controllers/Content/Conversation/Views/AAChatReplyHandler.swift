//
//  AAChatReplyHandler.swift
//  AloSDK
//
//  Created by Alcyone on 14.02.2018.
//

import UIKit
//import SlackTextViewController

extension ConversationViewController {
    func setupReplyView() {
        replyView = ReplyView.instantiateFromNib()
        replyView.backgroundColor = textInputbar.addonContentView.backgroundColor
        replyView.frame = textInputbar.addonContentView.bounds
        replyView.onClose = stopReplying
        
        textInputbar.addonContentView.addSubview(replyView)
    }

    
    func reply(to message: String, sid: jint, onlyQuote: Bool = false) {
        replyView.alpha = 0
        let user = Actor.getUserWithUid(sid)
        replyView.username.text = user.getNameModel().get()
        replyView.message.text = message.truncated(limit: 28)
        
        UIView.animate(withDuration: 0.25, animations: ({
            self.textInputbar.addonContentViewHeight = 50
            self.textInputbar.layoutIfNeeded()
            self.replyView.frame = self.textInputbar.addonContentView.bounds
            self.textDidUpdate(false)
        }), completion: ({ _ in
            UIView.animate(withDuration: 0.25) {
                self.replyView.alpha = 1
            }
        }))
        
        textView.becomeFirstResponder()
        
//        replyString = " @\(replyView.username.text)\(replyView.message.text)"
        replyString = "*| \(replyView.username.text ?? "")* \n*|* \(replyView.message.text ?? "")"

        
//        scrollToBottom()
    }
    
    func stopReplying() {
        replyView.alpha = 1
        
        UIView.animate(withDuration: 0.25, animations: ({
            self.replyView.alpha = 0
        }), completion: ({ _ in
            UIView.animate(withDuration: 0.25) {
                self.textInputbar.addonContentViewHeight = 0
                self.textInputbar.layoutIfNeeded()
                self.replyView.frame = self.textInputbar.addonContentView.bounds
                self.textDidUpdate(false)
            }
        }))
        
        replyString = ""
    }
    
}
extension String {
    enum TruncationPosition {
        case head
        case middle
        case tail
    }
    
    func truncated(limit: Int, position: TruncationPosition = .tail, leader: String = "...") -> String {
        guard self.count > limit else { return self }
        
        switch position {
        case .head:
            return leader + self.suffix(limit)
        case .middle:
            let headCharactersCount = Int(ceil(Float(limit - leader.count) / 2.0))
            
            let tailCharactersCount = Int(floor(Float(limit - leader.count) / 2.0))
            
            return "\(self.prefix(headCharactersCount))\(leader)\(self.suffix(tailCharactersCount))"
        case .tail:
            return self.prefix(limit) + leader
        }
    }
}
