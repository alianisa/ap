//
//  Copyright (c) 2014-2016 Actor LLC. <https://actor.im>
//

import Foundation
import UIKit

open class AAContactCell : AATableViewCell, AABindedCell, AABindedSearchCell {
    
    public typealias BindData = ACContact
    
    public static func bindedCellHeight(_ table: AAManagedTable, item: BindData) -> CGFloat {
        return 56
    }
    
    public static func bindedCellHeight(_ item: BindData) -> CGFloat {
        return 56
    }
    
    public let avatarView = AAAvatarView()
//    open let shortNameView = YYLabel()
    public let titleView = YYLabel()
    public let onlineLabel = YYLabel()
    

    // Binder
    
    open var binder = AABinder()
    
    public override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        titleView.font = UIFont.systemFont(ofSize: 18)
        titleView.textColor = appStyle.contactTitleColor
        titleView.displaysAsynchronously = true
        
//        shortNameView.font = UIFont.boldSystemFont(ofSize: 18)
//        shortNameView.textAlignment = NSTextAlignment.center
//        shortNameView.textColor = appStyle.contactTitleColor
//        shortNameView.displaysAsynchronously = true
        
        onlineLabel.font = UIFont.systemFont(ofSize: 14)
        onlineLabel.textColor = UIColor.gray
        onlineLabel.displaysAsynchronously = true
        
        self.contentView.addSubview(avatarView)
//        self.contentView.addSubview(shortNameView)
        self.contentView.addSubview(titleView)
        self.contentView.addSubview(onlineLabel)
    }

    public required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    open func bind(_ item: ACContact, search: String?) {
        bind(item)
    }
    
    open func bind(_ item: ACContact, table: AAManagedTable, index: Int, totalCount: Int) {
        bind(item)
    }
    
    
    func bind(_ item: ACContact) {
//        avatarView.bind(item.name, id: Int(item.uid), avatar: item.avatar);
        
//        titleView.text = item.name;
        let user = Actor.getUserWithUid(item.uid)
        Actor.onUserVisible(withUid: item.uid)
        let name = user.getNameModel().get()!
        titleView.text = name
//        let presense = user.getPresenceModel().get()!
//        avatarView.bind(name, id: Int(user.getId()), avatar: user.getAvatarModel().get())
//        let avatarView = user.getAvatarModel().get()
//        onlineLabel.text = Actor.getFormatter().formatPresence(presense, withSex: user.getSex())
        
//        binder.bind(user.getPresenceModel()) { (presence: ACUserPresence?) -> () in
//            self.onlineLabel.text = Actor.getFormatter().formatPresence(presence, with: user.getSex())
//        }
        
//        func bind(_ user: ACUserVM) {
        
            // Bind name and avatar
//            let name = user.getNameModel().get()!
//            nameLabel.text = name
            avatarView.bind(name, id: Int(user.getId()), avatar: user.getAvatarModel().get())
            

            
            // Bind onlines
            
            if user.isBot() {
                self.onlineLabel.textColor = self.appStyle.userOnlineColor
                self.onlineLabel.text = "bot"
                self.onlineLabel.alpha = 1
            } else {
                binder.bind(user.getPresenceModel()) { (value: ACUserPresence?) -> () in
                    
                    if value == nil {
                        // self.onlineLabel.alpha = 0
                        // self.onlineLabel.text = ""
                        self.onlineLabel.isHidden = true
                    } else {
                        self.onlineLabel.showView()
                        self.onlineLabel.text = Actor.getFormatter().formatPresence(value!, withSex: user.getSex())
                        if value!.state.ordinal() == ACUserPresence_State.online().ordinal() {
                            self.onlineLabel.textColor = UIColor(red:0.00, green:0.35, blue:1.00, alpha:1.0)
                        } else {
                            self.onlineLabel.textColor = UIColor.gray
                        }
                    }
                }
            }
            
//        }
        
    }
    
//    open override func prepareForReuse() {
//        super.prepareForReuse()
//        binder.unbindAll()
//    }

    func bindDisabled(_ disabled: Bool) {
        if disabled {
            titleView.alpha = 0.5
            avatarView.alpha = 0.5
            onlineLabel.alpha = 0.5
        } else {
            titleView.alpha = 1
            avatarView.alpha = 1
            onlineLabel.alpha = 1
        }
    }
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        let width = self.contentView.frame.width;
//        shortNameView.frame = CGRect(x: 0, y: 8, width: 30, height: 40);
        avatarView.frame = CGRect(x: 10, y: 8, width: 44, height: 44);
        titleView.frame = CGRect(x: 60, y: 1, width: width - 60 - 14, height: 40);
        onlineLabel.frame = CGRect(x: 60, y: 22, width: width - 60 - 14, height: 40);
    }
}
