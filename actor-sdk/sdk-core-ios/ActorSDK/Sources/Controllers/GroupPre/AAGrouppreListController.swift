//
//  AAGrouppreListController.swift
//  ActorSDK
//
//  Created by Diego Ferreira da Silva on 16/01/2018.
//  Copyright © 2018 Steve Kite. All rights reserved.
//

import Foundation

open class AAGrouppreListController: AASimpleContentTableController{
    
    
   
    
    open var enableDeletion: Bool = true
    
    var type:String!
    var parentId:JavaLangInteger!
    
    public init() {
        super.init(style: .plain)
        unbindOnDissapear = true
    }
    
    public required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    open override func tableDidLoad() {
        
        managedTable.canEditAll = true
        managedTable.canDeleteAll = true
        managedTable.fixedHeight = 76
        tableView.estimatedRowHeight = 76
        tableView.rowHeight = 76
        
        section { (s) -> () in
            
            s.autoSeparatorsInset = 75
            
            s.binded { (r:AASimpleBindedRows<AAGroupreCell>) -> () in
                
                r.differental = true
                
                r.animated = true
                
                r.displayList = Actor.getGroupsPreSimpleDisplayList(withParentId: parentId!, with: )
                
                r.selectAction = { (dialog: ACGroupPre) -> Bool in

                    return true
                }
                
                r.editAction = { (dialog: ACGroupPre) -> () in
                    
                }
            }
        }
        
        placeholder.setImage(
            UIImage.bundled("chat_list_placeholder"),
            title: AALocalized("Placeholder_Dialogs_Title"),
            subtitle: AALocalized("Placeholder_Dialogs_Message"))
        
    }
    
    open override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        binder.bind(Actor.getAppState().isDialogsEmpty, closure: { (value: Any?) -> () in
            if let empty = value as? JavaLangBoolean {
                if Bool(empty.booleanValue()) == true {
                    self.navigationItem.leftBarButtonItem = nil
                    self.showPlaceholder()
                } else {
                    self.hidePlaceholder()
                    self.navigationItem.leftBarButtonItem = self.editButtonItem
                }
            }
        })
    }
}
