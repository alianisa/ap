//
//  Copyright (c) 2014-2016 Actor LLC. <https://actor.im>
//

import Foundation
import UIKit
import MobileCoreServices

class AASettingsWallpapersController: AATableViewController {
    
    // MARK: -
    // MARK: Constructors
    
    fileprivate let CellIdentifier1 = "CellIdentifier1"
    fileprivate let CellIdentifier2 = "CellIdentifier2"
    
    init() {
        
        super.init(style: UITableView.Style.grouped)
        title = AALocalized("WallpapersTitle")
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.register(AAWallpapersCell1.self, forCellReuseIdentifier: CellIdentifier1)
        tableView.register(AAWallpapersCell2.self, forCellReuseIdentifier: CellIdentifier2)
        tableView.backgroundColor = appStyle.vcBackyardColor
        tableView.separatorColor = appStyle.vcSeparatorColor
        
        view.backgroundColor = tableView.backgroundColor
    }
    
    // MARK: -
    // MARK: UITableView Data Source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if (indexPath as NSIndexPath).section == 0 {
            return photosLibrary(indexPath)
        }
        if (indexPath as NSIndexPath).section == 1 {
            return wallpapersCell1(indexPath)
        } else {
            return wallpapersCell2(indexPath)
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAtIndexPath indexPath: IndexPath) {
        //
        self.tableView.deselectRow(at: indexPath, animated: true)
        
        if (indexPath as NSIndexPath).section == 0 {
            
            self.pickImage(.photoLibrary)
            
        }
        
    }
    
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return nil
    }
    
    func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        return nil
    }
    
    func tableView(_ tableView: UITableView, heightForRowAtIndexPath indexPath: IndexPath) -> CGFloat {
        if (indexPath as NSIndexPath).section == 0 {
            return 40
        } else {
            return 180
        }
    }
    
    // MARK: -
    // MARK: Create cells
    
    fileprivate func photosLibrary(_ indexPath: IndexPath) -> AACommonCell {
        let cell = AACommonCell()
        
        cell.textLabel?.text = AALocalized("WallpapersPhoto")
        cell.style = .navigation
        cell.textLabel?.textColor = appStyle.cellTextColor
        
        
        return cell
    }
    
    fileprivate func wallpapersCell1(_ indexPath: IndexPath) -> AAWallpapersCell1 {
        let cell = tableView.dequeueReusableCell(withIdentifier: CellIdentifier1, for: indexPath) as! AAWallpapersCell1
        
        cell.selectionStyle = UITableViewCell.SelectionStyle.none
        cell.wallpapperDidTap = { [unowned self] (name) -> () in
            self.present(AAWallpapperPreviewController(imageName: name), animated: true, completion: nil)
        }
        
        return cell
    }
    
    fileprivate func wallpapersCell2(_ indexPath: IndexPath) -> AAWallpapersCell2 {
        let cell = tableView.dequeueReusableCell(withIdentifier: CellIdentifier2, for: indexPath) as! AAWallpapersCell2
        
        cell.selectionStyle = UITableViewCell.SelectionStyle.none
        cell.wallpapperDidTap = { [unowned self] (name) -> () in
            self.present(AAWallpapperPreviewController(imageName: name), animated: true, completion: nil)
        }
        
        return cell
    }
    
    // MARK: -
    // MARK: Picker delegate
    
    override func imagePickerController(_ picker: UIImagePickerController, didFinishPickingImage image: UIImage, editingInfo: [String : AnyObject]?) {
        
        picker.navigationController?.pushViewController(AAWallpapperPreviewController(selectedImage: image), animated: true)
        
    }
    
    override func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        if let image = info[.originalImage] as? UIImage {
            picker.pushViewController(AAWallpapperPreviewController(selectedImage: image), animated: true)
        }
    }
    
    override func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
    // MARK: -
    // MARK: Image picking
    
    func pickImage(_ source: UIImagePickerController.SourceType) {
        let pickerController = AAImagePickerController()
        pickerController.sourceType = source
        pickerController.mediaTypes = [kUTTypeImage as String]
        pickerController.delegate = self
        
        self.present(pickerController, animated: true, completion: nil)
    }
    
    
}
