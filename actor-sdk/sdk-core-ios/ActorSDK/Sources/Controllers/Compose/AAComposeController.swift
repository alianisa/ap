//
//  Copyright (c) 2014-2016 Actor LLC. <https://actor.im>
//

import UIKit

open class AAComposeController: AAContactsListContentController, AAContactsListContentControllerDelegate {

    public override init() {
        super.init()
        
        self.delegate = self
        self.isSearchAutoHide = false
        
        self.navigationItem.title = AALocalized("ComposeTitle")
        
        if AADevice.isiPad {
            self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: AALocalized("NavigationCancel"), style: UIBarButtonItemStyle.plain, target: self, action: #selector(self.dismissController))
        }
    }

    public required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    open func willAddContacts(_ controller: AAContactsListContentController, section: AAManagedSection) {
        section.custom { (r:AACustomRow<AAContactActionCell>) -> () in
            
            r.height = 56
            
            r.closure = { (cell) -> () in
                cell.bind("ic_add_user", actionTitle: AALocalized("CreateGroup"))
            }
            
            r.selectAction = { () -> Bool in
                self.navigateNext(AAGroupCreateViewController(isChannel: false), removeCurrent: true)
                return false
            }
        }
        
        section.custom { (r:AACustomRow<AAContactActionCell>) -> () in
            
            r.height = 56
            
            r.closure = { (cell) -> () in
                cell.bind("ic_create_channel", actionTitle: AALocalized("CreateChannel"))
            }
            
            r.selectAction = { () -> Bool in
                self.navigateNext(AAGroupCreateViewController(isChannel: true), removeCurrent: true)
                return false
            }
        }
        
        
        if(ActorSDK.sharedActor().enablePredefinedGroups){
            section.custom { (r:AACustomRow<AAContactActionCell>) -> () in
                
                r.height = 56
                
                r.closure = { (cell) -> () in
                    cell.bind("ic_pre_groups", actionTitle: AALocalized("GroupsPre"))
                }
                
                r.selectAction = { () -> Bool in
                    let gruposPredefinidosController = AAGrouppreListController(groupType:JavaLangInteger(value: ACGroupType.group()))
                    gruposPredefinidosController.title = AALocalized("GroupsPre")
                    self.navigateNext(gruposPredefinidosController, removeCurrent: false)
                    return false
                }
            }
            
            section.custom { (r:AACustomRow<AAContactActionCell>) -> () in
                
                r.height = 56
                
                r.closure = { (cell) -> () in
                    cell.bind("ic_pre_channels", actionTitle: AALocalized("ChannelsPre"))
                }
                
                r.selectAction = { () -> Bool in
                    let gruposPredefinidosController = AAGrouppreListController(groupType:JavaLangInteger(value: ACGroupType.channel()))
                    gruposPredefinidosController.title = AALocalized("ChannelsPre")
                    self.navigateNext(gruposPredefinidosController, removeCurrent: false)
                    return false
                }
            }
        }
        
    }
    
    open func contactDidTap(_ controller: AAContactsListContentController, contact: ACContact) -> Bool {
        if let customController = ActorSDK.sharedActor().delegate.actorControllerForConversation(ACPeer_userWithInt_(contact.uid)) {
            navigateDetail(customController)
        } else {
            navigateDetail(ConversationViewController(peer: ACPeer_userWithInt_(contact.uid)))
        }
        return false
    }
}
