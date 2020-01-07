//
//  Copyright (c) 2014-2016 Actor LLC. <https://actor.im>
//

import UIKit
import Photos

public protocol AAConvActionSheetDelegate {
    func actionSheetPickedImages(_ images:[(Data,Bool)])
    func actionSheetPickCamera()
    func actionSheetPickGallery()
    func actionSheetCustomButton(_ index: Int)
}

open class AAConvActionSheet: UIView, AAThumbnailViewDelegate {
    
    open var delegate: AAConvActionSheetDelegate?
    
    fileprivate let sheetView = UIView()
    fileprivate let backgroundView = UIView()
    fileprivate var sheetViewHeight: CGFloat = 0
    fileprivate var sheetViewWidth: CGFloat = 0
    
    fileprivate var thumbnailView: AAThumbnailView!
    fileprivate var buttons = [UIButton]()
    fileprivate var btnGallery: UIButton!
    fileprivate var btnLibrary: UIButton!
    fileprivate var btnPlace: UIButton!
    fileprivate var btnFile: UIButton!
    fileprivate var btnContact: UIButton!
    fileprivate var btnCancel: UIButton!
    fileprivate var btnSend: UIButton!
    fileprivate var txtLabelGallery: UILabel!
    fileprivate var txtLabelPlace: UILabel!
    fileprivate var txtLabelFile: UILabel!
    fileprivate var txtLabelContact: UILabel!
    
    fileprivate weak var presentedInController: UIViewController! = nil
    
    open var enablePhotoPicker: Bool = true
    fileprivate var customActions = [String]()
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.clear
    }
    
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    open func addCustomButton(_ title: String){
        customActions.append(title)
    }
    
    open func presentInController(_ controller: UIViewController) {
        
        if controller.navigationController != nil {
            self.presentedInController = controller.navigationController
        } else {
            self.presentedInController = controller
        }
        
        if let navigation = presentedInController as? UINavigationController {
            navigation.interactivePopGestureRecognizer?.isEnabled = false
        } else if let navigation = presentedInController.navigationController {
            navigation.interactivePopGestureRecognizer?.isEnabled = false
        }
        
        frame = presentedInController.view.bounds
        presentedInController.view.addSubview(self)
        
        setupAllViews()
        
//        self.sheetView.frame = CGRect(x: 0, y: self.frame.height, width: self.frame.width, height: sheetViewHeight)
        self.sheetView.frame = CGRect(x: 0, y: self.frame.height, width: sheetViewWidth, height: sheetViewHeight)

        self.backgroundView.alpha = 0
        dispatchOnUi { () -> Void in
            UIView.animate(withDuration: 0.4, delay: 0.0, usingSpringWithDamping: 0.7,
                           initialSpringVelocity: 0.6, options: UIView.AnimationOptions(), animations: {
                            self.sheetView.frame = CGRect(x: 0, y: self.frame.height - self.sheetViewHeight, width: self.frame.width, height: self.sheetViewHeight)
                            self.backgroundView.alpha = 1
            }, completion: nil)
        }
    }
    
    open func dismiss() {
        var nextFrame = self.sheetView.frame
        nextFrame.origin.y = self.presentedInController.view.height
        
        if let navigation = presentedInController as? UINavigationController {
            navigation.interactivePopGestureRecognizer?.isEnabled = true
        } else if let navigation = presentedInController.navigationController {
            navigation.interactivePopGestureRecognizer?.isEnabled = true
        }
        
        UIView.animate(withDuration: 0.25, animations: { () -> Void in
            self.sheetView.frame = nextFrame
            self.backgroundView.alpha = 0}, completion: { (bool) -> Void in
                self.delegate = nil
                if self.thumbnailView != nil {
                    self.thumbnailView.dismiss()
                    self.thumbnailView = nil
                }
                self.removeFromSuperview()
        })
    }
    
    fileprivate func setupAllViews() {
        
        
        //
        // Root Views
        //
        
        let superWidth = presentedInController.view.width
        let superHeight = presentedInController.view.height
        let screenWidth = UIScreen.main.bounds.width
        
        self.backgroundView.frame = presentedInController.view.bounds
        self.backgroundView.backgroundColor = UIColor.alphaBlack(0.5)
        self.backgroundView.alpha = 0
        self.addSubview(self.backgroundView)
        
        
        //
        // Init Action Views
        //
        
        self.sheetViewHeight = 0
        self.sheetViewWidth = screenWidth
        
//        self.buttons.removeAll()
        
        if enablePhotoPicker {
            
            self.thumbnailView = AAThumbnailView(frame: CGRect(x: 0, y: 5, width: superWidth, height: 191))

            self.thumbnailView.delegate = self
            self.thumbnailView.open()
            

//            self.thumbnailView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(AAImageCell.handleSingleTap)))

            let imageSize:CGSize = CGSize(width: 25, height: 25)

            self.btnGallery = {
//                let button = UIButton(type: UIButtonType.system)
                let button:UIButton = UIButton(type: UIButton.ButtonType.custom)
//                button.tintColor = UIColor(red: 5.0/255.0, green: 124.0/255.0, blue: 226.0/255.0, alpha: 1)
//                button.titleLabel?.font = UIFont.systemFont(ofSize: 12)
//                button.setTitleColor(UIColor.blue, for: .normal)
//                button.setTitle("Gal", for: UIControlState())
//                button.titleEdgeInsets = UIEdgeInsetsMake(60,0,0,0)
                button.frame = CGRect(x: 25, y: 20, width: 50, height: 50)
                button.layer.cornerRadius = button.frame.height/2
                button.clipsToBounds = true
                button.backgroundColor = UIColor(red:0.00, green:0.40, blue:0.80, alpha:1.0)
                button.addTarget(self, action: #selector(AAConvActionSheet.btnCustomAction(_:)), for: UIControl.Event.touchUpInside)
                button.tag = 0
                button.setImage(UIImage.bundled("gallery"), for: .normal)
                button.imageEdgeInsets = UIEdgeInsets(top: button.frame.size.height/2 - imageSize.height/2, left: button.frame.size.width/2 - imageSize.width/2, bottom: button.frame.size.height/2 - imageSize.height/2, right: button.frame.size.width/2 - imageSize.width/2)

                return button
            }()
            
            self.txtLabelGallery = {
            // Text Label
            let textLabel = UILabel()
                textLabel.widthAnchor.constraint(equalToConstant: 100.0).isActive = true
                textLabel.heightAnchor.constraint(equalToConstant: 20.0).isActive = true
                textLabel.frame = CGRect(x: 25, y: 50, width: 50, height: 70)
                textLabel.font = UIFont(name: "HelveticaNeue-Medium", size: 12)
                textLabel.text = AALocalized("Gallery")
                textLabel.textColor = UIColor.alphaBlack(0.8)
                textLabel.textAlignment = .center
                
                return textLabel
            }()
            
            self.btnFile = {
                //                let button = UIButton(type: UIButtonType.system)
                let button:UIButton = UIButton(type: UIButton.ButtonType.custom)
                button.tintColor = UIColor(red: 5.0/255.0, green: 124.0/255.0, blue: 226.0/255.0, alpha: 1)
                button.titleLabel?.font = UIFont.systemFont(ofSize: 12)
                //                button.setTitleColor(UIColor.blue, for: .normal)
                //                button.setTitle("Gal", for: UIControlState())
                //                button.titleEdgeInsets = UIEdgeInsetsMake(60,0,0,0)
                button.frame = CGRect(x: 110, y: 20, width: 50, height: 50)
                button.layer.cornerRadius = button.frame.height/2
                button.clipsToBounds = true
                button.backgroundColor = UIColor(red:0.15, green:0.83, blue:0.40, alpha:1.0)
                button.addTarget(self, action: #selector(AAConvActionSheet.btnCustomAction(_:)), for: UIControl.Event.touchUpInside)
                button.tag = 1
                button.setImage(UIImage.bundled("file"), for: .normal)
                button.imageEdgeInsets = UIEdgeInsets(top: button.frame.size.height/2 - imageSize.height/2, left: button.frame.size.width/2 - imageSize.width/2, bottom: button.frame.size.height/2 - imageSize.height/2, right: button.frame.size.width/2 - imageSize.width/2)
                
                return button
            }()
            
            self.txtLabelFile = {
                // Text Label
                let textLabel = UILabel()
                textLabel.widthAnchor.constraint(equalToConstant: 100.0).isActive = true
                textLabel.heightAnchor.constraint(equalToConstant: 20.0).isActive = true
                textLabel.frame = CGRect(x: 110, y: 50, width: 50, height: 70)
                textLabel.font = UIFont(name: "HelveticaNeue-Medium", size: 12)
                textLabel.text = AALocalized("File")
                textLabel.textColor = UIColor.alphaBlack(0.8)
                textLabel.textAlignment = .center
                
                return textLabel
            }()
            
            self.btnPlace = {
                //                let button = UIButton(type: UIButtonType.system)
                let button:UIButton = UIButton(type: UIButton.ButtonType.custom)
                button.tintColor = UIColor(red: 5.0/255.0, green: 124.0/255.0, blue: 226.0/255.0, alpha: 1)
                button.titleLabel?.font = UIFont.systemFont(ofSize: 12)
                //                button.setTitleColor(UIColor.blue, for: .normal)
                //                button.setTitle("Gal", for: UIControlState())
                //                button.titleEdgeInsets = UIEdgeInsetsMake(60,0,0,0)
                button.frame = CGRect(x: 195, y: 20, width: 50, height: 50)
                button.layer.cornerRadius = button.frame.height/2
                button.clipsToBounds = true
                button.backgroundColor = UIColor(red:0.19, green:0.13, blue:0.83, alpha:1.0)
                button.addTarget(self, action: #selector(AAConvActionSheet.btnCustomAction(_:)), for: UIControl.Event.touchUpInside)
                button.tag = 2
                button.setImage(UIImage.bundled("place"), for: .normal)
                button.imageEdgeInsets = UIEdgeInsets(top: button.frame.size.height/2 - imageSize.height/2, left: button.frame.size.width/2 - imageSize.width/2, bottom: button.frame.size.height/2 - imageSize.height/2, right: button.frame.size.width/2 - imageSize.width/2)
                
                return button
            }()
            
            self.txtLabelPlace = {
                // Text Label
                let textLabel = UILabel()
                textLabel.widthAnchor.constraint(equalToConstant: 100.0).isActive = true
                textLabel.heightAnchor.constraint(equalToConstant: 20.0).isActive = true
                textLabel.frame = CGRect(x: 195, y: 50, width: 50, height: 70)
                textLabel.font = UIFont(name: "HelveticaNeue-Medium", size: 12)
                textLabel.text = AALocalized("Place")
                textLabel.textColor = UIColor.alphaBlack(0.8)
                textLabel.textAlignment = .center
                
                return textLabel
            }()
            

            
            self.btnContact = {
                //                let button = UIButton(type: UIButtonType.system)
                let button:UIButton = UIButton(type: UIButton.ButtonType.custom)
                button.tintColor = UIColor(red: 5.0/255.0, green: 124.0/255.0, blue: 226.0/255.0, alpha: 1)
                button.titleLabel?.font = UIFont.systemFont(ofSize: 12)
                //                button.setTitleColor(UIColor.blue, for: .normal)
                //                button.setTitle("Gal", for: UIControlState())
                //                button.titleEdgeInsets = UIEdgeInsetsMake(60,0,0,0)
                button.frame = CGRect(x: 280, y: 20, width: 50, height: 50)
                button.layer.cornerRadius = button.frame.height/2
                button.clipsToBounds = true
                button.backgroundColor = UIColor.gray
                button.addTarget(self, action: #selector(AAConvActionSheet.btnCustomAction(_:)), for: UIControl.Event.touchUpInside)
                button.tag = 3
                button.setImage(UIImage.bundled("gallery"), for: .normal)
                button.imageEdgeInsets = UIEdgeInsets(top: button.frame.size.height/2 - imageSize.height/2, left: button.frame.size.width/2 - imageSize.width/2, bottom: button.frame.size.height/2 - imageSize.height/2, right: button.frame.size.width/2 - imageSize.width/2)
                
                return button
            }()
            
            self.txtLabelContact = {
                // Text Label
                let textLabel = UILabel()
                textLabel.widthAnchor.constraint(equalToConstant: 100.0).isActive = true
                textLabel.heightAnchor.constraint(equalToConstant: 20.0).isActive = true
                textLabel.frame = CGRect(x: 280, y: 50, width: 50, height: 70)
                textLabel.font = UIFont(name: "HelveticaNeue-Medium", size: 12)
                textLabel.text = AALocalized("Contact")
                textLabel.textColor = UIColor.alphaBlack(0.8)
                textLabel.textAlignment = .center
                
                return textLabel
            }()
            
            self.buttons.append(self.btnGallery)

//            self.btnLibrary = {
//                let button = UIButton(type: UIButtonType.system)
//                button.tintColor = UIColor(red: 5.0/255.0, green: 124.0/255.0, blue: 226.0/255.0, alpha: 1)
//                button.titleLabel?.font = UIFont.systemFont(ofSize: 17)
//                button.setTitle(AALocalized("PhotoLibrary"), for: UIControlState())
//                button.addTarget(self, action: #selector(AAConvActionSheet.btnLibraryAction), for: UIControlEvents.touchUpInside)
//                return button
//            }()
//            self.buttons.append(self.btnLibrary)
            
            sheetViewHeight = 340
        }
        
//        for i in 0..<customActions.count {
//            let b = customActions[i]
//            self.buttons.append({
//                let button = UIButton(type: UIButtonType.system)
//                button.tintColor = UIColor(red: 5.0/255.0, green: 124.0/255.0, blue: 226.0/255.0, alpha: 1)
//                button.titleLabel?.font = UIFont.systemFont(ofSize: 17)
//                button.setTitle(AALocalized(b), for: UIControlState())
//                button.tag = i
//                button.addTarget(self, action: #selector(AAConvActionSheet.btnCustomAction(_:)), for: UIControlEvents.touchUpInside)
//                return button
//                }())
//        }
        
        self.btnCancel = {
            let button = UIButton(type: UIButton.ButtonType.system)
            button.tintColor = UIColor(red: 5.0/255.0, green: 124.0/255.0, blue: 226.0/255.0, alpha: 1)
            button.titleLabel?.font = UIFont.systemFont(ofSize: 17)
            button.setTitle(AALocalized("AlertCancel"), for: UIControl.State())
            button.addTarget(self, action: #selector(AAConvActionSheet.btnCloseAction), for: UIControl.Event.touchUpInside)
            
            return button
        }()
        
        self.btnSend = {
            let button = UIButton(type: UIButton.ButtonType.system)
            button.tintColor = UIColor(red: 5.0/255.0, green: 124.0/255.0, blue: 226.0/255.0, alpha: 1)
            button.titleLabel?.font = UIFont.systemFont(ofSize: 17)
            button.setTitle("", for: UIControl.State())
            button.addTarget(self, action: #selector(AAConvActionSheet.sendPhotos), for: UIControl.Event.touchUpInside)
            return button
        }()
//        self.buttons.append(self.btnCancel)
//
//        sheetViewHeight += CGFloat(self.buttons.count * 50)
        
        
        //
        // Adding Elements
        //
        
        for b in self.buttons {
            self.sheetView.addSubview(b)
            
        }
        self.sheetView.addSubview(btnCancel)
        self.sheetView.addSubview(btnSend)
        self.sheetView.addSubview(btnFile)
        self.sheetView.addSubview(btnPlace)
        self.sheetView.addSubview(btnContact)
        self.sheetView.addSubview(txtLabelFile)
        self.sheetView.addSubview(txtLabelGallery)
        self.sheetView.addSubview(txtLabelPlace)
        self.sheetView.addSubview(txtLabelContact)
        
        if self.thumbnailView != nil {
            self.sheetView.addSubview(self.thumbnailView)
        }
        
        
        //
        // Layouting
        //
        
        self.sheetView.frame = CGRect(x: 0, y: superHeight - sheetViewHeight, width: superWidth, height: sheetViewHeight)
        self.sheetView.backgroundColor = UIColor.white
        self.addSubview(self.sheetView)
        
        var topOffset: CGFloat = 10
        if self.thumbnailView != nil {
            self.thumbnailView.frame = CGRect(x: 0, y: 100, width: superWidth, height: 190)
            topOffset += 100
        }
        for b in self.buttons {

//            b.frame = CGRect(x: 0, y: 0, width: superWidth / 4, height: 100)
            

//            let spearator = UIView(frame: CGRect(x: 0, y: 0, width: superWidth, height: 1))
//            spearator.backgroundColor = UIColor.gray
//            self.sheetView.addSubview(spearator)

//            topOffset += 100
        }
        btnCancel.frame = CGRect(x: 0, y: 290, width: screenWidth / 2, height: 50)
        let spearator = UIView(frame: CGRect(x: screenWidth / 2, y: 288, width: 1, height: 50))
        spearator.backgroundColor = UIColor.lightGray
//        spearator.transform = CGAffineTransform(rotationAngle: (.pi / 2))
        btnSend.frame = CGRect(x: superWidth / 2, y: 290, width: screenWidth / 2, height: 50)
        self.sheetView.addSubview(spearator)
    }
    
    open func thumbnailSelectedUpdated(_ selectedAssets: [(PHAsset,Bool)]) {
        if selectedAssets.count > 0 {
            
            var sendString:String
            if selectedAssets.count == 1 {
                sendString = AALocalized("AttachmentsSendPhoto").replace("{count}", dest: "\(selectedAssets.count)")
            } else {
                sendString = AALocalized("AttachmentsSendPhotos").replace("{count}", dest: "\(selectedAssets.count)")
            }
            
            //
            // remove target
            //
//            self.btnCamera.removeTarget(self, action: #selector(AAConvActionSheet.btnCameraAction), for: UIControlEvents.touchUpInside)
            
            //
            // add new target
            //
            
            self.btnSend.setTitle(sendString, for: UIControl.State())
            self.btnSend.addTarget(self, action:#selector(AAConvActionSheet.sendPhotos), for: UIControl.Event.touchUpInside)
            self.btnSend.titleLabel?.font = UIFont(name: "HelveticaNeue-Medium", size: 17)
            
            
        } else {
            
            //
            // remove target
            //
//            self.btnGallery.removeTarget(self, action: #selector(AAConvActionSheet.sendPhotos), for: UIControlEvents.touchUpInside)
            
            //
            // add new target
            //
//            self.btnGallery.setTitle(AALocalized("PhotoCamera"), for: UIControlState())
//            self.btnGallery.addTarget(self, action: #selector(AAConvActionSheet.btnCameraAction), for: UIControlEvents.touchUpInside)
//            self.btnGallery.titleLabel?.font = UIFont.systemFont(ofSize: 17)
            
        }
    }
    
    //
    // Actions
    //
    
    @objc func sendPhotos() {
        if self.thumbnailView != nil {
            self.thumbnailView.getSelectedAsImages { (images:[(Data,Bool)]) -> () in
                (self.delegate?.actionSheetPickedImages(images))!
            }
        }
        dismiss()
    }
    
    @objc func btnCameraAction() {
//        delegate?.actionSheetPickCamera()
        var convAct: ConversationViewController?
        convAct?.showActionPhotoGallery()
        dismiss()
    }
    
    func btnLibraryAction() {
        delegate?.actionSheetPickGallery()
        dismiss()
    }
    
    @objc func btnCustomAction(_ sender: UIButton) {
        delegate?.actionSheetCustomButton(sender.tag)
        dismiss()
    }
    
    @objc func btnCloseAction() {
        dismiss()
    }
    
    open override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        dismiss()
    }
}

extension Array {
    subscript (wcl_safe index: Int) -> Element? {
        return (0..<count).contains(index) ? self[index] : nil
    }
    
    @discardableResult
    mutating func wcl_removeSafe(at index: Int) -> Bool {
        if (0..<count).contains(index) {
            self.remove(at: index)
            return true
        }
        return false
    }
}

//
//open class AAConvActionSheet: UIView, AAThumbnailViewDelegate {
//
//    open var delegate: AAConvActionSheetDelegate?
//
//    fileprivate let sheetView = UIView()
//    fileprivate let cancelView = UIView()
//    fileprivate let backgroundView = UIView()
//    fileprivate var sheetViewHeight: CGFloat = 0
//    fileprivate var cancelViewHeight: CGFloat = 0
//
//    fileprivate var thumbnailView: AAThumbnailView!
//    fileprivate var buttons = [UIButton]()
//    fileprivate var buttonCancel = [UIButton]()
//    fileprivate var btnCamera: UIButton!
//    fileprivate var btnLibrary: UIButton!
//    fileprivate var btnCancel: UIButton!
//
//    fileprivate weak var presentedInController: UIViewController! = nil
//
//    open var enablePhotoPicker: Bool = true
//    fileprivate var customActions = [String]()
//    fileprivate var cancelActions = [String]()
//
//
//    public init() {
//        super.init(frame: CGRect.zero)
//
//        self.backgroundColor = UIColor.clear
//    }
//
//    public required init?(coder aDecoder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
//
//    open func addCustomButton(_ title: String){
//        customActions.append(title)
//    }
//
//    open func addCancelButton(_ title: String){
//        cancelActions.append(title)
//    }
//
//    open func presentInController(_ controller: UIViewController) {
//
//        if controller.navigationController != nil {
//            self.presentedInController = controller.navigationController
//        } else {
//            self.presentedInController = controller
//        }
//
//        if let navigation = presentedInController as? UINavigationController {
//            navigation.interactivePopGestureRecognizer?.isEnabled = false
//        } else if let navigation = presentedInController.navigationController {
//            navigation.interactivePopGestureRecognizer?.isEnabled = false
//        }
//
//        frame = presentedInController.view.bounds
//        presentedInController.view.addSubview(self)
//
//        setupAllViews()
//
//        self.sheetView.frame = CGRect(x: 10, y: self.frame.height, width: self.frame.width, height: sheetViewHeight)
//        self.cancelView.frame = CGRect(x: 10, y: self.frame.height, width: self.frame.width, height: cancelViewHeight)
//        self.backgroundView.alpha = 0
//        dispatchOnUi { () -> Void in
//            UIView.animate(withDuration: 0.4, delay: 0.0, usingSpringWithDamping: 0.7,
//                initialSpringVelocity: 0.7, options: UIViewAnimationOptions(), animations: {
//                    self.sheetView.frame = CGRect(x: 10, y: self.frame.height - self.sheetViewHeight - 70, width: self.frame.width - 20, height: self.sheetViewHeight)
//                    self.cancelView.frame = CGRect(x: 10, y: self.frame.height - self.cancelViewHeight - 5, width: self.frame.width - 20, height: self.cancelViewHeight)
//                    self.backgroundView.alpha = 0.5
//                }, completion: nil)
//        }
//    }
//
//    open func dismiss() {
//        var nextFrame = self.sheetView.frame
//        nextFrame.origin.y = self.presentedInController.view.height
//
//        var nextCancelFrame = self.cancelView.frame
//        nextCancelFrame.origin.y = self.presentedInController.view.height
//
//        if let navigation = presentedInController as? UINavigationController {
//            navigation.interactivePopGestureRecognizer?.isEnabled = true
//        } else if let navigation = presentedInController.navigationController {
//            navigation.interactivePopGestureRecognizer?.isEnabled = true
//        }
//
//        UIView.animate(withDuration: 0.25, animations: { () -> Void in
//            self.sheetView.frame = nextFrame
//            self.cancelView.frame = nextCancelFrame
//            self.backgroundView.alpha = 0}, completion: { (bool) -> Void in
//                self.delegate = nil
//                if self.thumbnailView != nil {
//                    self.thumbnailView.dismiss()
//                    self.thumbnailView = nil
//                }
//                self.removeFromSuperview()
//        })
//    }
//
//    fileprivate func setupAllViews() {
//
//
//        //
//        // Root Views
//        //
//
//        let superWidth = presentedInController.view.width
//        let superHeight = presentedInController.view.height
//
//        self.backgroundView.frame = presentedInController.view.bounds
//        self.backgroundView.backgroundColor = UIColor.alphaBlack(0.7)
//        self.backgroundView.alpha = 0
//        self.addSubview(self.backgroundView)
//
//
//        //
//        // Init Action Views
//        //
//
//        self.sheetViewHeight = 10
//        self.cancelViewHeight = 10
//
//        self.buttons.removeAll()
//        self.buttonCancel.removeAll()
//
//        if enablePhotoPicker {
//
////            self.thumbnailView = AAThumbnailView(frame: CGRect(x: 30, y: 30, width: superWidth - 30, height: 90))
//            self.thumbnailView = AAThumbnailView(frame: CGRect(x: 0, y: 5, width: superWidth, height: 90))
//
//            self.thumbnailView.delegate = self
//            self.thumbnailView.layer.cornerRadius = 20
//            self.thumbnailView.open()
//
//            self.btnCamera = {
//                let button = UIButton(type: UIButtonType.system)
////                button.tintColor = UIColor(red: 5.0/255.0, green: 124.0/255.0, blue: 226.0/255.0, alpha: 1)
////                button.tintColor = UIColor(rgb: 0x000000)
////                button.titleLabel?.font = UIFont.systemFont(ofSize: 17)
//                button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 17)
//                button.setTitle(AALocalized("PhotoCamera"), for: UIControlState())
//                button.addTarget(self, action: #selector(AAConvActionSheet.btnCameraAction), for: UIControlEvents.touchUpInside)
//                return button
//            }()
//            self.buttons.append(self.btnCamera)
//
//            self.btnLibrary = {
//                let button = UIButton(type: UIButtonType.system)
////                button.tintColor = UIColor(red: 5.0/255.0, green: 124.0/255.0, blue: 226.0/255.0, alpha: 1)
////                button.tintColor = UIColor(rgb: 0x000000)
//                button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 17)
//                button.setTitle(AALocalized("PhotoLibrary"), for: UIControlState())
//                button.addTarget(self, action: #selector(AAConvActionSheet.btnLibraryAction), for: UIControlEvents.touchUpInside)
//                return button
//            }()
//            self.buttons.append(self.btnLibrary)
//
//            sheetViewHeight = 100
//        }
//
//        for d in 0..<customActions.count {
//            let b = customActions[d]
//            self.buttons.append({
//                let button = UIButton(type: UIButtonType.system)
////                button.tintColor = UIColor(red: 5.0/255.0, green: 124.0/255.0, blue: 226.0/255.0, alpha: 1)
////                button.titleLabel?.font = UIFont.systemFont(ofSize: 17)
//                button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 17)
//                button.setTitle(AALocalized(b), for: UIControlState())
//                button.tag = d
//                button.addTarget(self, action: #selector(AAConvActionSheet.btnCustomAction(_:)), for: UIControlEvents.touchUpInside)
//                return button
//            }())
//        }
//////        for i in 0..<cancelActions.count {
//////            let c = cancelActions[i]
////            self.buttonCancel.append({
////                let btnCancel = UIButton(type: UIButtonType.system)
//////                button.tintColor = UIColor(red: 5.0/255.0, green: 124.0/255.0, blue: 226.0/255.0, alpha: 1)
////                btnCancel.titleLabel?.font = UIFont.systemFont(ofSize: 17)
////                btnCancel.setTitle("Cancel", for: UIControlState())
//////                button.tag = i
//////                button.addTarget(self, action: #selector(AAConvActionSheet.btnCustomAction(_:)), for: UIControlEvents.touchUpInside)
////                btnCancel.addTarget(self, action: #selector(AAConvActionSheet.btnCloseAction), for: UIControlEvents.touchUpInside)
////                return btnCancel
////            }())
//////        }
//
//        self.btnCancel = {
//            let button = UIButton(type: UIButtonType.system)
////            button.tintColor = UIColor(red: 5.0/255.0, green: 124.0/255.0, blue: 226.0/255.0, alpha: 1)
////            button.titleLabel?.font = UIFont.systemFont(ofSize: 17)
//            button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 17)
//            button.setTitle(AALocalized("AlertCancel"), for: UIControlState())
//            button.addTarget(self, action: #selector(AAConvActionSheet.btnCloseAction), for: UIControlEvents.touchUpInside)
//            return button
//        }()
//        self.buttonCancel.append(self.btnCancel)
//
//
//
////        self.buttons.append(self.btnCancel)
//
//        sheetViewHeight += CGFloat(self.buttons.count * 50)
//        cancelViewHeight += CGFloat(self.buttonCancel.count * 50)
//
//        //
//        // Adding Elements
//        //
//
//        for b in self.buttons {
//            self.sheetView.addSubview(b)
//        }
//        for c in self.buttonCancel {
//            self.cancelView.addSubview(c)
//        }
//        if self.thumbnailView != nil {
//            self.sheetView.addSubview(self.thumbnailView)
//        }
//
//
//        //
//        // Layouting
//        //.,
//
//        self.sheetView.frame = CGRect(x: 10, y: superHeight - sheetViewHeight - 70, width: superWidth - 20, height: sheetViewHeight)
//        self.sheetView.backgroundColor = UIColor.white
//        self.sheetView.layer.cornerRadius = 14
//
//        self.cancelView.frame = CGRect(x: 10, y: superHeight - cancelViewHeight - 5, width: superWidth - 20, height: 10)
//        self.cancelView.backgroundColor = UIColor.white
//        self.cancelView.layer.cornerRadius = 14
//
//        self.addSubview(self.sheetView)
//        self.addSubview(self.cancelView)
//
//        var topOffset: CGFloat = 10
//        if self.thumbnailView != nil {
//            self.thumbnailView.frame = CGRect(x: 0, y: 5, width: superWidth, height: 90)
//            topOffset += 90
//        }
//        for b in self.buttons {
//
//            b.frame = CGRect(x: 0, y: topOffset, width: superWidth, height: 50)
//
//
//            let spearator = UIView(frame: CGRect(x: 0, y: topOffset - 1, width: superWidth - 20, height: 1))
//            spearator.backgroundColor = UIColor(red: 223.9/255.0, green: 223.9/255.0, blue: 223.9/255.0, alpha: 0.6)
//            self.sheetView.addSubview(spearator)
//
//            topOffset += 50
//        }
//
//        for c in self.buttonCancel {
//
//            c.frame = CGRect(x: 0, y: topOffset, width: superWidth, height: 50)
//
////            let spearator = UIView(frame: CGRect(x: 0, y: topOffset - 1, width: superWidth, height: 1))
////            spearator.backgroundColor = UIColor(red: 223.9/255.0, green: 223.9/255.0, blue: 223.9/255.0, alpha: 0.6)
////            self.cancelView.addSubview(spearator)
//
//            topOffset += 50
//        }
//    }
//
//    open func thumbnailSelectedUpdated(_ selectedAssets: [(PHAsset,Bool)]) {
//        if selectedAssets.count > 0 {
//
//            var sendString:String
//            if selectedAssets.count == 1 {
//                sendString = AALocalized("AttachmentsSendPhoto").replace("{count}", dest: "\(selectedAssets.count)")
//            } else {
//                sendString = AALocalized("AttachmentsSendPhotos").replace("{count}", dest: "\(selectedAssets.count)")
//            }
//
//            //
//            // remove target
//            //
//            self.btnCamera.removeTarget(self, action: #selector(AAConvActionSheet.btnCameraAction), for: UIControlEvents.touchUpInside)
//
//            //
//            // add new target
//            //
//
//            self.btnCamera.setTitle(sendString, for: UIControlState())
//            self.btnCamera.addTarget(self, action:#selector(AAConvActionSheet.sendPhotos), for: UIControlEvents.touchUpInside)
//            self.btnCamera.titleLabel?.font = UIFont(name: "HelveticaNeue-Medium", size: 17)
//
//
//        } else {
//
//            //
//            // remove target
//            //
//            self.btnCamera.removeTarget(self, action: #selector(AAConvActionSheet.sendPhotos), for: UIControlEvents.touchUpInside)
//
//            //
//            // add new target
//            //
//            self.btnCamera.setTitle(AALocalized("PhotoCamera"), for: UIControlState())
//            self.btnCamera.addTarget(self, action: #selector(AAConvActionSheet.btnCameraAction), for: UIControlEvents.touchUpInside)
//            self.btnCamera.titleLabel?.font = UIFont.systemFont(ofSize: 17)
//
//        }
//    }
//
//    //
//    // Actions
//    //
//
//    func sendPhotos() {
//        if self.thumbnailView != nil {
//            self.thumbnailView.getSelectedAsImages { (images:[(Data,Bool)]) -> () in
//                (self.delegate?.actionSheetPickedImages(images))!
//            }
//        }
//        dismiss()
//    }
//
//    func btnCameraAction() {
//        delegate?.actionSheetPickCamera()
//        dismiss()
//    }
//
//    func btnLibraryAction() {
//        delegate?.actionSheetPickGallery()
//        dismiss()
//    }
//
//    func btnCustomAction(_ sender: UIButton) {
//        delegate?.actionSheetCustomButton(sender.tag)
//        dismiss()
//    }
//
//    func btnCloseAction() {
//        dismiss()
//    }
//
//    open override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
//        dismiss()
//    }
//}

