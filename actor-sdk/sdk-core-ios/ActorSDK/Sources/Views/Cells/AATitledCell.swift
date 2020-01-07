//
//  Copyright (c) 2014-2016 Actor LLC. <https://actor.im>
//

import UIKit

open class AATitledCell: AATableViewCell {
    
    fileprivate var isAction: Bool = false
    public let titleLabel: UILabel = UILabel()
    public let contentLabel: UILabel = UILabel()
    
    public override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        titleLabel.textColor = appStyle.cellTintColor
        
        contentLabel.textAlignment = .right
        
        contentView.addSubview(titleLabel)
        contentView.addSubview(contentLabel)
    }

    public required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    open func setContent(_ title: String, content: String, isAction: Bool) {
        titleLabel.text = title
        contentLabel.text = content
        if isAction {
            contentLabel.textColor = UIColor.lightGray
        } else {
            contentLabel.textColor = appStyle.cellTextColor
        }
    }
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        
        titleLabel.frame = CGRect(x: separatorInset.left, y: 11, width: contentView.bounds.width - separatorInset.left - 10, height: 22)
        contentLabel.frame = CGRect(x: separatorInset.left, y: 11, width: contentView.bounds.width - separatorInset.left - 10, height: 22)
    }
}
