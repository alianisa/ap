import UIKit
import YYImage

open class AAAvatarView: UIView, YYAsyncLayerDelegate, ACFileEventCallback {
    
    
    fileprivate var title: String?
    fileprivate var id: Int?
    fileprivate var file: ACFileReference?
    fileprivate var fileName: String?
    fileprivate var showPlaceholder: Bool = false
//    fileprivate var user: ACUserVM?
    fileprivate var presenceBind: AAGroupMemberCell?
    public init() {
        super.init(frame: CGRect.zero)
        
        self.layer.delegate = self
        self.layer.contentsScale = UIScreen.main.scale
        self.backgroundColor = UIColor.clear
        self.isOpaque = false
        self.contentMode = .redraw;
        if Actor.isLoggedIn() {
            Actor.subscribe(toDownloads: self)
        }
    }
    
    open override func setNeedsDisplay() {
        if Thread.isMainThread {
            super.setNeedsDisplay()
        }
    }
    
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        if Actor.isLoggedIn() {
            //FIXME: crash on AvatarView
            //Actor.unsubscribeFromDownloads(self)
        }
    }
    
    open func onDownloaded(withLong fileId: jlong) {
        if self.file?.getFileId() == fileId {
            dispatchOnUi {
                if self.file?.getFileId() == fileId {
                    self.layer.setNeedsDisplay()
                }
            }
        }
    }

    
    //
    // Databinding
    //
    
    open func bind(_ title: String, id: Int, fileName: String?) {
        
        self.title = title
        self.id = id
        
        self.fileName = fileName
        self.file = nil
        self.showPlaceholder = false
        
        self.layer.setNeedsDisplay()
    }
    
    
    open func bind(_ title: String, id: Int, avatar: ACAvatar?) {
        
        if self.title == title
            && self.id == id
            && self.file == avatar
            && self.fileName == nil {
            // Do Nothing
            return
        }
        
        self.title = title
        self.id = id
        
        self.fileName = nil
        if avatar == nil {
            self.file = nil
            self.showPlaceholder = true
        } else {
            self.file = avatar!.smallImage?.fileReference
            self.showPlaceholder = false
        }
//        let user = Actor.getUserWithUid(jint(id))
//        user.getPresenceModel()
        self.layer.setNeedsDisplay()
    }
    
    open func bindPresence(_ user: ACUserVM) {
        let user = user
//        let presence = user.getPresenceModel().get()
//        Actor.getFormatter().formatPresence(presence, withSex: user.getSex())
//        presenceBind?.bind(user, isAdmin: false)
    }
    open func unbind() {
        self.title = nil
        self.id = nil
        
        self.fileName = nil
        self.file = nil
        self.showPlaceholder = false
        
        self.layer.setNeedsDisplay()
    }
    
    open override class var layerClass : AnyClass {
        return YYAsyncLayer.self
    }
    

    open func reload() {
        setNeedsDisplay()
    }
    
    open func newAsyncDisplayTask() -> YYAsyncLayerDisplayTask {
        let res = YYAsyncLayerDisplayTask()
        
        let _id = id
        let _title = title
        var _fileName = fileName
        var _file = file
        let _showPlaceholder = showPlaceholder
        
        res.display = { (context: CGContext,  size: CGSize, isCancelled: () -> Bool) -> () in
            let r = min(size.width, size.height) / 2
            let filePath: String?
            if _fileName != nil {
                filePath = _fileName
            } else if _file != nil {
                let desc = Actor.findDownloadedDescriptor(withFileId: _file!.getFileId())
                if isCancelled() {
                    return
                }
                if desc != nil {
                    filePath = CocoaFiles.pathFromDescriptor(desc!)
                } else {
                    // Request if not available
                    DispatchQueue.main.async {
                        Actor.startDownloading(with: _file!)
                    }
                    filePath = nil
                    return
                }
            } else {
                filePath = nil
            }
            
            if isCancelled() {
                return
            }
            
            
            if filePath == nil && _showPlaceholder && _id != nil && _title != nil {
                
                let colors1 = ActorSDK.sharedActor().style.avatarColors1
                let colors2 = ActorSDK.sharedActor().style.avatarColors2
                let color1 = colors1[_id! % colors1.count].cgColor
                let color2 = colors2[_id! % colors2.count].cgColor
                
                // Background
                
                
                func imageGradient(fromLayer layer: CALayer) -> UIImage {
                    UIGraphicsBeginImageContext(layer.frame.size)
                    layer.render(in: UIGraphicsGetCurrentContext()!)
                    let outputImage = UIGraphicsGetImageFromCurrentImageContext()
                    UIGraphicsEndImageContext()
                    return outputImage!
                }
                
                // set Gradient
                let gradient = CAGradientLayer()
                
                let sizeLength = UIScreen.main.bounds.size.height * 2
                let frame = CGRect(x: 0, y: 0, width: sizeLength, height: 60)
                gradient.frame = frame
                gradient.colors = [color1, color2]
                
                let image: UIImage? = imageGradient(fromLayer: gradient)
                
                // Background
                UIBezierPath(roundedRect: CGRect(x: 0, y: 0, width: r * 2,  height: r * 2), cornerRadius: r).addClip()
                image!.draw(in: CGRect(x: 0, y: 0, width: r * 2, height: r * 2))
                
                context.drawPath(using: .fill)
                
                if isCancelled() {
                    return
                }
                
                // Text
                
                UIColor.white.set()
                
                if isCancelled() {
                    return
                }
                
                //let fontName = UIFont(name: ".SFCompactRounded-Semibold", size: r)!
                if #available(iOS 13.0, *) {
                    
                    let descriptor = UIFont.systemFont(ofSize: r, weight: .semibold).fontDescriptor.withDesign(.rounded)
                    let fontName = UIFont(descriptor: descriptor!, size: r)
                    var rect = CGRect(x: 0, y: 0, width: r * 2, height: r * 2)
                    rect.origin.y = round(CGFloat(r * 2 * 44 / 100) - fontName.pointSize / 2)
                
                    let style : NSMutableParagraphStyle = NSParagraphStyle.default.mutableCopy() as! NSMutableParagraphStyle
                    style.alignment = NSTextAlignment.center
                    style.lineBreakMode = NSLineBreakMode.byWordWrapping
                    
                    let avatarTextColor = UIColor.white
                    
                    let short = _title!.trim().smallValue()
                    short.draw(in: rect, withAttributes: [NSAttributedString.Key.paragraphStyle:style, NSAttributedString.Key.font:fontName, NSAttributedString.Key.foregroundColor:avatarTextColor])
                    
                } else {
                    
                    let fontName = UIFont(name: ".SFCompactRounded-Semibold", size: r)!
                    var rect = CGRect(x: 0, y: 0, width: r * 2, height: r * 2)
                    rect.origin.y = round(CGFloat(r * 2 * 44 / 100) - fontName.pointSize / 2)
                    
                    let style : NSMutableParagraphStyle = NSParagraphStyle.default.mutableCopy() as! NSMutableParagraphStyle
                    style.alignment = NSTextAlignment.center
                    style.lineBreakMode = NSLineBreakMode.byWordWrapping
                    
                    let avatarTextColor = UIColor.white
                    
                    let short = _title!.trim().smallValue()
                    short.draw(in: rect, withAttributes: [NSAttributedString.Key.paragraphStyle:style, NSAttributedString.Key.font:fontName, NSAttributedString.Key.foregroundColor:avatarTextColor])
                    
                    }
                if isCancelled() {
                    return
                }
                    
            } else if let fp = filePath {
                
                let image: UIImage? = UIImage(contentsOfFile: fp)
                
                if isCancelled() {
                    return
                }
                
                if image != nil {
                    
                    // Background
                    UIBezierPath(roundedRect: CGRect(x: 0, y: 0, width: r * 2,  height: r * 2), cornerRadius: r).addClip()
                    
                    if isCancelled() {
                        return
                    }
                    
                    image!.draw(in: CGRect(x: 0, y: 0, width: r * 2, height: r * 2))
                } else {
                    
                    // Clean BG
                    context.setFillColor(UIColor.white.cgColor)
                    
                    context.addEllipse(in: CGRect(x: 0, y: 0, width: r * 2, height: r * 2))
                    
                    if isCancelled() {
                        return
                    }
                    
                    context.drawPath(using: .fill)
                }
                
                if isCancelled() {
                    return
                }
            } else {
                // Clean BG
                context.setFillColor(UIColor.white.cgColor)
                
                if isCancelled() {
                    return
                }
                
                context.addEllipse(in: CGRect(x: 0, y: 0, width: r * 2, height: r * 2))
                
                if isCancelled() {
                    return
                }
                
                context.drawPath(using: .fill)
                
                if isCancelled() {
                    return
                }
            }
            
            // Border
            
            context.setStrokeColor(UIColor(red: 0, green: 0, blue: 0, alpha: 0x10/255.0).cgColor)
            
            if isCancelled() {
                return
            }
            
            context.addEllipse(in: CGRect(x: 0, y: 0, width: r * 2, height: r * 2))
            
            if isCancelled() {
                return
            }
            
            context.drawPath(using: .stroke)
        }
        return res
    }
}
