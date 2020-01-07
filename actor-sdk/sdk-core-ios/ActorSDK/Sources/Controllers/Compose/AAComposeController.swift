
import UIKit

open class AAComposeController: AAContactsListContentController, AAContactsListContentControllerDelegate {

    public override init() {
        super.init()
        
        self.delegate = self
        self.isSearchAutoHide = false
        
        self.navigationItem.title = AALocalized("ComposeTitle")
        
        if AADevice.isiPad {
            self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: AALocalized("NavigationCancel"), style: UIBarButtonItem.Style.plain, target: self, action: #selector(self.dismissController))
        }
    }

    public required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    open func willAddContacts(_ controller: AAContactsListContentController, section: AAManagedSection) {
        _ = section.custom { (r:AACustomRow<AAContactActionCell>) -> () in
            
            r.height = 56
            
            r.closure = { (cell) -> () in
                cell.bind("ic_create_group", actionTitle: AALocalized("CreateGroup"))
            }
            
            r.selectAction = { () -> Bool in
                self.navigateNext(AAGroupCreateViewController(isChannel: false), removeCurrent: true)
                return false
            }
        }
        
        _ = section.custom { (r:AACustomRow<AAContactActionCell>) -> () in
            
            r.height = 56
            
            r.closure = { (cell) -> () in
                cell.bind("ic_create_channel", actionTitle: AALocalized("CreateChannel"))
            }
            
            r.selectAction = { () -> Bool in
                self.navigateNext(AAGroupCreateViewController(isChannel: true), removeCurrent: true)
                return false
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
