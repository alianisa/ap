//
//  AATitledMoreCell.swift
//  AloSDK
//
//  Created by Alcyone on 07.01.2020.
//  Copyright © 2020 Steve Kite. All rights reserved.
//

import UIKit

open class AATitledMoreCell: AATableViewCell {
    
    fileprivate var isAction: Bool = false
    public let titleLabel: UILabel = UILabel()
    public let hintLabel: UILabel = UILabel()
    public let hintLabel2: UILabel = UILabel()

    public let contentLabel: UILabel = UILabel()
    
    public override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        titleLabel.textColor = appStyle.cellTintColor
        
        contentLabel.textAlignment = .right
        
        contentView.addSubview(titleLabel)
        contentView.addSubview(hintLabel)
        contentView.addSubview(hintLabel2)
        contentView.addSubview(contentLabel)
    }

    public required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    open func setContent(_ title: String, hint: String, hint2: String, content: String, isAction: Bool) {
        titleLabel.text = title
        titleLabel.font = UIFont.boldSystemFont(ofSize: 17)
        hintLabel.text = hint
        hintLabel.font = UIFont.systemFont(ofSize: 14)
        hintLabel2.text = hint2
        contentLabel.text = content
        contentLabel.font = UIFont.systemFont(ofSize: 10)
        contentLabel.textColor = UIColor.blue


//        if isAction {
        hintLabel2.textColor = UIColor.gray
        hintLabel2.font = UIFont.systemFont(ofSize: 12)
//        } else {
//            contentLabel.textColor = appStyle.cellTextColor
//        }
    }
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        
        titleLabel.frame = CGRect(x: 15, y: 5, width: contentView.bounds.width - separatorInset.left - 10, height: 22)
        
        hintLabel.frame = CGRect(x: 15, y: 25, width: contentView.bounds.width - separatorInset.left - 10, height: 15)
        
        hintLabel2.frame = CGRect(x: 15, y: 40, width: contentView.bounds.width - separatorInset.left - 10, height: 15)
        
        contentLabel.frame = CGRect(x: separatorInset.left, y: 11, width: contentView.bounds.width - separatorInset.left - 10, height: 10)
    }
}
