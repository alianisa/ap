//
//  Copyright (c) 2014-2016 Actor LLC. <https://actor.im>
//

import Foundation

open class AAGrouppreListController: UITableViewController {
    
    var groupType:JavaLangInteger!
    var parentId:JavaLangInteger!
    var groupsList:ARSimpleBindedDisplayList!
    
    public init(groupType:JavaLangInteger,_ parentId:JavaLangInteger = ACGroupPre.default_ID()) {
        super.init(style: UITableViewStyle.plain)
        self.groupType = groupType
        self.parentId = parentId
        
        self.groupsList = Actor.getGroupsPreSimpleDisplayList(self.parentId, filter: {value in
            let groupPre = value as! ACGroupPre
            let groupVm = Actor.getGroupWithGid(groupPre.groupId.intValue())
            return jboolean(groupVm.groupType == self.groupType.intValue())
        })
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(AAGrouppreCell.self, forCellReuseIdentifier: "cellid")
        tableView.tableFooterView = UIView(frame: CGRect.zero)
        tableView.tableFooterView?.hideView()
    }
    
    open override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Int(groupsList.size())
    }
    
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
        let groupPre = groupsList.value(with: jint(indexPath.row)) as! ACGroupPre
        let groupVm = Actor.getGroupWithGid(groupPre.groupId.intValue())
        
        if(groupPre.hasChildren.booleanValue()){
            let gruposPredefinidosController = AAGrouppreListController(groupType:self.groupType, groupPre.groupId)
            gruposPredefinidosController.title = groupVm.name.get()
            self.navigateNext(gruposPredefinidosController, removeCurrent: false)
        }else{
            if(groupVm.isMember.get().booleanValue()){
                let controller = ConversationViewController(peer: ACPeer.group(with: groupPre.groupId.intValue()))
                controller.removeExcedentControllers = false
                self.navigateDetail(controller)
            }else{
                self.executePromise(Actor.joinGroup(byGid: groupPre.groupId.intValue())).then({ (void:Any!) in
                    let controller = ConversationViewController(peer: ACPeer.group(with: groupPre.groupId.intValue()))
                    controller.removeExcedentControllers = false
                    self.navigateDetail(controller)
                }).failure(withClosure: { (erro:JavaLangException!) in
                    self.alertUser(erro.getMessage())
                })
            }
        }
    }
    
    
    open override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.groupsList.setListChangeListenerWith(SimpleListChangeListener(closure: {value in
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }))
    }
    
    open override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.groupsList.setListChangeListenerWith(nil)
    }
    
}


