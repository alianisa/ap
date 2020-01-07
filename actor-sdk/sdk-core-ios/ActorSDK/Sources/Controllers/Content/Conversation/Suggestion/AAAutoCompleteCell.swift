//
//  Copyright (c) 2014-2016 Actor LLC. <https://actor.im>
//

import Foundation
import TTTAttributedLabel

class AAAutoCompleteCell: AATableViewCell {
    
    var avatarView = AAAvatarView()
    var nickView = TTTAttributedLabel(frame: CGRect.zero)
    var nameView = TTTAttributedLabel(frame: CGRect.zero)
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: UITableViewCell.CellStyle.default, reuseIdentifier: reuseIdentifier)
        
        // avatarView.enableAnimation = false
        nickView.font = UIFont.systemFont(ofSize: 14)
        nickView.textColor = ActorSDK.sharedActor().style.cellTextColor
        
        nameView.font = UIFont.systemFont(ofSize: 14)
        nameView.textColor = ActorSDK.sharedActor().style.cellHintColor
        
        self.contentView.addSubview(avatarView)
        self.contentView.addSubview(nickView)
        self.contentView.addSubview(nameView)
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func bindData(_ user: ACMentionFilterResult, highlightWord: String) {
        
        avatarView.bind(user.mentionString, id: Int(user.uid), avatar: user.avatar)
        
        var nickText: String
        var nameText: String
        
        nickText = user.mentionString
        if user.originalString != nil {
            nameText = " \u{2022} \(user.originalString)";
        } else {
            nameText = ""
        }
        
        let nickAttrs = NSMutableAttributedString(string: nickText)
        let nameAttrs = NSMutableAttributedString(string: nameText)
        
        nickAttrs.addAttribute(NSAttributedString.Key.font, value: UIFont.systemFont(ofSize: 14), range: NSMakeRange(0, nickText.length))
        nickAttrs.addAttribute(NSAttributedString.Key.foregroundColor, value: ActorSDK.sharedActor().style.cellTextColor, range: NSMakeRange(0, nickText.length))
        
        nameAttrs.addAttribute(NSAttributedString.Key.font, value: UIFont.systemFont(ofSize: 14), range: NSMakeRange(0, nameText.length))
        nameAttrs.addAttribute(NSAttributedString.Key.foregroundColor, value: ActorSDK.sharedActor().style.cellHintColor, range: NSMakeRange(0, nameText.length))
        
        if user.mentionMatches != nil {
            for i in 0..<user.mentionMatches.size() {
                let match = user.mentionMatches.getWith(i) as! ACStringMatch
                let nsRange = NSMakeRange(Int(match.getStart()), Int(match.getLength()))
                nickAttrs.addAttribute(NSAttributedString.Key.foregroundColor, value: appStyle.chatAutocompleteHighlight, range: nsRange)
            }
        }
        
        //        if user.originalString != nil {
        if user.originalMatches != nil {
            for i in 0..<user.originalMatches.size() {
                let match = user.originalMatches.getWith(i) as! ACStringMatch
                let nsRange = NSMakeRange(Int(match.getStart()) + 3, Int(match.getLength()))
                nameAttrs.addAttribute(NSAttributedString.Key.foregroundColor, value: appStyle.chatAutocompleteHighlight, range: nsRange)
            }
        }
        
        nickView.setText(nickAttrs)
        nameView.setText(nameAttrs)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        avatarView.frame = CGRect(x: 6, y: 6, width: 38, height: 38)
        nickView.frame = CGRect(x: 44, y: 6, width: 100, height: 32)
        nickView.sizeToFit()
        nickView.frame = CGRect(x: 44, y: 6, width: nickView.frame.width, height: 32)
        
        let left = 44 + nickView.frame.width
        nameView.frame = CGRect(x: left, y: 6, width: self.contentView.frame.width - left, height: 32)
    }
}
