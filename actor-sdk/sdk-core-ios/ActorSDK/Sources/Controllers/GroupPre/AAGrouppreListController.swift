//
//  Copyright (c) 2014-2016 Actor LLC. <https://actor.im>
//

import Foundation

open class AAGrouppreListController: UITableViewController {
    
    var groupType:JavaLangInteger!
    var parentId:JavaLangInteger = 0
    var groupsList:ARSimpleBindedDisplayList!
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(AAGrouppreCell.self, forCellReuseIdentifier: "cellid")
        
        tableView.tableFooterView = UIView(frame: CGRect.zero)
        tableView.tableFooterView?.hideView()
        
        _ = ActorSDK.sharedActor().messenger.myUid()
        //{ (typing:JavaLangBoolean?, presence:ACUserPresence?) ->
        groupsList = Actor.getGroupsPreSimpleDisplayList(parentId, filter: {value in
            let groupPre = value as! ACGroupPre
            let groupVm = Actor.getGroupWithGid(groupPre.groupId.intValue())
            return jboolean(groupVm.groupType == self.groupType.intValue())
        })
    }
    
    open override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Int(groupsList.size())
    }
    
    let imageCache:NSCache<NSString,NSData> = NSCache<NSString,NSData>()
    
    open override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell:AAGrouppreCell = tableView.dequeueReusableCell(withIdentifier: "cellid", for: indexPath) as! AAGrouppreCell
        
        let groupPre = groupsList.value(with: jint(indexPath.row)) as! ACGroupPre
        cell.setGroupPre(groupPre: groupPre)
        
        return cell
    }
    
    open override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 76.0
    }
    
    open override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let grupoPre = groupsList.value(with: jint(indexPath.row))
        
//        if(grupo.possuiFilhos)!{
//            let gruposPredefinidosController = XLGruposPreDefinidosController()
//            gruposPredefinidosController.tipo =  self.tipo
//            gruposPredefinidosController.title = grupo.title
//            gruposPredefinidosController.idGrupoPai = grupo.id
//            self.navigateNext(gruposPredefinidosController, removeCurrent: false)
//        }else{
//            if(grupo.isMember)!{
//                let controller = ConversationViewController(peer: ACPeer.group(with: jint(grupo.id!)))
//                controller.removeExcedentControllers = false
//                //self.navigateNext(controller, removeCurrent: false)
//                self.navigateDetail(controller)
//            }else{
//                self.executePromise(Actor.joinGroup(byGid: jint(grupo.id!))).then({ (void:Any!) in
//                    let controller = ConversationViewController(peer: ACPeer.group(with: jint(grupo.id!)))
//                    controller.removeExcedentControllers = false
//                    //self.navigateNext(controller, removeCurrent: false)
//
//                    self.navigateDetail(controller)
//                }).failure(withClosure: { (erro:JavaLangException!) in
//                    self.alertUser(erro.getMessage())
//                })
//            }
//        }
    }
    
}


