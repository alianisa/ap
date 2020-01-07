//
//  Copyright (c) 2014-2016 Actor LLC. <https://actor.im>
//

import UIKit

open class AASettingsImageQualityController: AATableViewController {
    
    fileprivate var quality = Actor.getQuality()
    
    // MARK: -
    // MARK: Constructors
    
    fileprivate let CellIdentifier = "CellIdentifier"
    
    public init() {
        super.init(style: UITableView.Style.grouped)
        
        title = AALocalized("QualityImage")
        
        content = ACAllEvents_Settings.notifications()
    }
    
    public required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: -
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.register(AACommonCell.self, forCellReuseIdentifier: CellIdentifier)
        tableView.backgroundColor = appStyle.vcBackyardColor
        tableView.separatorColor = appStyle.vcSeparatorColor
        
        view.backgroundColor = tableView.backgroundColor
    }
    
    // MARK: -
    // MARK: UITableView Data Source
    
    open override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    open override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 4
    }
    
    open func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return nil
    }
    
    open func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        return nil
    }
    
    fileprivate func qualityCell(_ indexPath: IndexPath) -> AACommonCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: CellIdentifier, for: indexPath) as! AACommonCell
        
        if (indexPath as NSIndexPath).row == 0 {
            
            cell.setContent(AALocalized("QualityImageNoneCompress"))
            
            if (self.quality == "none") {
                cell.style = .checkmark
            } else {
                cell.style = .normal
            }
            
        } else if (indexPath as NSIndexPath).row == 1 {
            
            cell.setContent(AALocalized("QualityImageLarge"))
            
            if (self.quality == "large") {
                cell.style = .checkmark
            } else {
                cell.style = .normal
            }
            
        } else if (indexPath as NSIndexPath).row == 2 {
            
            cell.setContent(AALocalized("QualityImageMedium"))
            
            if (self.quality == "medium") {
                cell.style = .checkmark
            } else {
                cell.style = .normal
            }
            
        } else if (indexPath as NSIndexPath).row == 3 {
            
            cell.setContent(AALocalized("QualityImageSmall"))
            
            if (self.quality == "small") {
                cell.style = .checkmark
            } else {
                cell.style = .normal
            }
            
        }
        
        cell.selectionStyle = UITableViewCell.SelectionStyle.none
        cell.bottomSeparatorVisible = false
        cell.topSeparatorVisible = false
        cell.bottomSeparatorLeftInset = 0
        cell.topSeparatorLeftInset = 0
        
        return cell
    }
    
    open override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return qualityCell(indexPath)
    }
    
    open func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        let header: UITableViewHeaderFooterView = view as! UITableViewHeaderFooterView
        header.textLabel!.textColor = ActorSDK.sharedActor().style.cellFooterColor
    }
    
    open func tableView(_ tableView: UITableView, willDisplayFooterView view: UIView, forSection section: Int) {
        let header: UITableViewHeaderFooterView = view as! UITableViewHeaderFooterView
        header.textLabel!.textColor = ActorSDK.sharedActor().style.cellFooterColor
    }
    
    
    open func tableView(_ tableView: UITableView, didSelectRowAtIndexPath indexPath: IndexPath) {
        
        if (indexPath as NSIndexPath).row == 0 {
            
            Actor.setQualityWithQuality("none")
            
        } else if (indexPath as NSIndexPath).row == 1 {
            
            Actor.setQualityWithQuality("large")
            
        } else if (indexPath as NSIndexPath).row == 2 {
            
            Actor.setQualityWithQuality("medium")
            
        } else if (indexPath as NSIndexPath).row == 3 {
            
            Actor.setQualityWithQuality("small")
            
        }
        
        self.quality = Actor.getQuality()
        self.tableView.reloadData()
        
    }
    
}
