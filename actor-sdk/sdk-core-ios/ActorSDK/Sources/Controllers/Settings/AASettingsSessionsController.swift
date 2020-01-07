//
//  Copyright (c) 2014-2016 Actor LLC. <https://actor.im>
//

import UIKit

open class AASettingsSessionsController: AAContentTableController {

//    fileprivate var sessionsCell: AAManagedArrayRows<ARApiAuthSession, AACommonCell>?
    fileprivate var sessionsCell: AAManagedArrayRows<ARApiAuthSession, AATitledMoreCell>?

    
    public init() {
        super.init(style: AAContentTableStyle.settingsGrouped)
        
        navigationItem.title = AALocalized("PrivacyAllSessions")
        
        content = ACAllEvents_Settings.privacy()
    }
    
    public required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    open override func tableDidLoad() {
        
        section { (s) -> () in
            
            s.footerText = AALocalized("PrivacyTerminateHint")
            
            s.danger("PrivacyTerminate") { (r) -> () in
                r.selectAction = { () -> Bool in
                    self.confirmDangerSheetUser("PrivacyTerminateAlert", tapYes: { [unowned self] () -> () in
                        // Terminating all sessions and reload list
                        self.executeSafe(Actor.terminateAllSessionsCommand(), successBlock: { (val) -> Void in
                            self.loadSessions()
                        })
                        }, tapNo: nil)
                    return true
                }
            }
        }
        
        section { (s) -> () in
//            self.sessionsCell = s.arrays() { (r: AAManagedArrayRows<ARApiAuthSession, AACommonCell>) -> () in
            self.sessionsCell = s.arrays() { (r: AAManagedArrayRows<ARApiAuthSession, AATitledMoreCell>) -> () in
                r.height = 65

                r.bindData = { (c: AATitledMoreCell, d: ARApiAuthSession) -> () in
                    if d.getAuthHolder().ordinal() != ARApiAuthHolder.thisdevice().ordinal() {
//                        c.style = .normal
//                        c.setContent(d.getDeviceTitle())
                    } else {
                        c.setContent("\(d.getAppTitle())", hint: "\(d.getDeviceTitle()), \(d.getDeviceOSVersion())", hint2: "\(d.getDeviceIpAddress()) - \(d.getDeviceLocation())", content: "Online", isAction: false)

//                        c.style = .navigation
//                        c.setContent("(Current) \(d.getDeviceTitle() d.getDeviceIpAddress()
//                            (d.getDeviceLocation() (d.getDeviceOSVersion()")
                        
                    }

                }
            
                            
                            
                
                
            }
        }
        
        // Request sessions load
        
        loadSessions()
    }
    
    fileprivate func loadSessions() {
        execute(Actor.loadSessionsCommand(), successBlock: { [unowned self] (val) -> Void in
            self.sessionsCell!.data = (val as! JavaUtilList).toArray().toSwiftArray()
            self.managedTable.tableView.reloadData()
            }, failureBlock: nil)
    }

}
