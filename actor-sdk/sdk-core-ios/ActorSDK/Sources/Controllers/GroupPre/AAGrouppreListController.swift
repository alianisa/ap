//
//  Copyright (c) 2014-2016 Actor LLC. <https://actor.im>
//

import Foundation
import ActorSDK

open class AAGrouppreListController: UITableViewController {
    
    var tipo:String!
    var parentId:jlong!
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(GrupoCell.self, forCellReuseIdentifier: "cellid")
        
        tableView.tableFooterView = UIView(frame: CGRect.zero)
        tableView.tableFooterView?.hideView()
        
        let userId = ActorSDK.sharedActor().messenger.myUid()
        
        let listParams:JavaUtilListProtocol = JavaUtilArrayList()
        listParams.add(withId: ARApiMapValueItem(nsString: "id", with: ARApiInt64Value(long: jlong(userId))))
        listParams.add(withId: ARApiMapValueItem(nsString: "tipo", with: ARApiStringValue(nsString: self.tipo)))
        
        if let idPai = idGrupoPai{
            listParams.add(withId: ARApiMapValueItem(nsString: "idPai", with: ARApiInt64Value(long: idPai)))
        }

    }
    
    open override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return grupos.count
    }
    
    let imageCache:NSCache<NSString,NSData> = NSCache<NSString,NSData>()
    
    open override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell:GrupoCell = tableView.dequeueReusableCell(withIdentifier: "cellid", for: indexPath) as! GrupoCell
        
        let grupo = grupos[indexPath.row]
        cell.setGrupo(grupo)
        cell.setTipo(tipo)
        
        if let avatarUrl = grupo.avatarUrl{
            if let data = imageCache.object(forKey: avatarUrl as NSString){
                cell.setImageData(data)
            }else{
                XLCocoaHttpRuntime.getMethod(avatarUrl).then { (resp:ARHTTPResponse!) in
                    if(resp.code == 200){
                        let data = NSData(data: resp.content.toNSData())
                        self.imageCache.setObject(data, forKey: avatarUrl as NSString)
                        cell.setImageData(data)
                    }
                }
            }
        }
        return cell
    }
    
    open override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 76.0
    }
    
    open override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let grupo = grupos[indexPath.row]
        
        if(grupo.possuiFilhos)!{
            let gruposPredefinidosController = XLGruposPreDefinidosController()
            gruposPredefinidosController.tipo =  self.tipo
            gruposPredefinidosController.title = grupo.title
            gruposPredefinidosController.idGrupoPai = grupo.id
            self.navigateNext(gruposPredefinidosController, removeCurrent: false)
        }else{
            if(grupo.isMember)!{
                let controller = ConversationViewController(peer: ACPeer.group(with: jint(grupo.id!)))
                controller.removeExcedentControllers = false
                //self.navigateNext(controller, removeCurrent: false)
                self.navigateDetail(controller)
            }else{
                self.executePromise(Actor.joinGroup(byGid: jint(grupo.id!))).then({ (void:Any!) in
                    let controller = ConversationViewController(peer: ACPeer.group(with: jint(grupo.id!)))
                    controller.removeExcedentControllers = false
                    //self.navigateNext(controller, removeCurrent: false)
                    
                    self.navigateDetail(controller)
                }).failure(withClosure: { (erro:JavaLangException!) in
                    self.alertUser(erro.getMessage())
                })
            }
        }
    }
    
}


