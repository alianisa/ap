//
//  Copyright (c) 2014-2016 Actor LLC. <https://actor.im>
//

import UIKit

open class AARecentViewController: AADialogsListContentController, AADialogsListContentControllerDelegate {

    fileprivate var isBinded = true
    
    let activityIndicator = ActivityIndicator.shared
    
    public override init() {
        
        super.init()
        
        // Enabling dialogs page tracking
        
        content = ACAllEvents_Main.recent()
        
        // Setting delegate
        
        self.delegate = self

        
        // Setting UITabBarItem
        
        tabBarItem = UITabBarItem(title: "", img: "TabIconChats", selImage: "TabIconChatsHighlighted")

        
        
        
//        let andicatorViewFrame = CGRect(x: -85, y: 23, width: (navigationView.frame.width - 0), height: 18)
//        let activityIndicatorView = NVActivityIndicatorView(frame: andicatorViewFrame, type: NVActivityIndicatorType.ballPulse, color: UIColor(red:0.03, green:0.50, blue:1.00, alpha:1.0))
//        self.navigationView.addSubview(activityIndicatorView)
        
        // Setting navigation item
       self.navigationItem.title = AALocalized("TabMessages")
        
        navigationItem.leftBarButtonItem = editButtonItem
        navigationItem.leftBarButtonItem!.title = AALocalized("NavigationEdit")
        if #available(iOS 11.0, *) {
            navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: UIBarButtonItem.Style.plain, target: nil, action: nil)
            
            
            
            // Bar button item
//            var button = MIBadgeButton(type: .custom)
//            
////            rightBarButtomItem.addBadge(number: 10)
////            let badgeButton : MIBadgeButton = MIBadgeButton(frame: CGRect(x: 0, y: 0, width: 40, height: 40))
//            button.frame = CGRect(x: 0, y: 0, width: 70, height: 40)
//            button.badgeEdgeInsets = UIEdgeInsetsMake(10, 0, 0, 15)
//            button.setTitle("test", for: .normal)
//            button.setTitleColor(.black, for: .normal)
//            button.badgeString = "100";
//            
//            let barButton = UIBarButtonItem(customView: button)
//            
//            navigationItem.leftBarButtonItem = barButton
            
            
//            navigationItem.backBarButtonItem = rightBarButtomItem
            
        } else {
//            navigationItem.backBarButtonItem = UIBarButtonItem(title: AALocalized("DialogsBack"), style: UIBarButtonItemStyle.plain, target: nil, action: nil)
        }
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.compose, target: self, action: #selector(AARecentViewController.compose))
        
        bindCounter()
    }

    public required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // Implemention of editing
    
    open override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        tableView.setEditing(editing, animated: animated)
        
        if (editing) {
            self.navigationItem.leftBarButtonItem!.title = AALocalized("NavigationDone")
            self.navigationItem.leftBarButtonItem!.style = UIBarButtonItem.Style.done
            
            navigationItem.rightBarButtonItem = nil
        } else {
            self.navigationItem.leftBarButtonItem!.title = AALocalized("NavigationEdit")
            self.navigationItem.leftBarButtonItem!.style = UIBarButtonItem.Style.plain
            
            navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.compose, target: self, action: #selector(AARecentViewController.compose))
        }
        
        if editing == true {
            navigationItem.rightBarButtonItem = nil
        } else {
            navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.compose, target: self, action: #selector(AARecentViewController.compose))
        }
    }
    
    @objc open func compose() {
        if let composeController = ActorSDK.sharedActor().delegate.actiorControllerForCompose() {
            if AADevice.isiPad {
                self.presentElegantViewController(AANavigationController(rootViewController: composeController))
            } else {
                navigateNext(composeController)
            }
        }else{
            if AADevice.isiPad {
                self.presentElegantViewController(AANavigationController(rootViewController: AAComposeController()))
            } else {
                navigateNext(AAComposeController())
            }
        }
        
        
    }
    
    // Tracking app state
    
    open override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        bindCounter()
        bindCheckingConnections()
    }
    
    func bindCounter() {
        if !isBinded {
            isBinded = true
            dispatchOnUi { () -> Void in
                self.binder.bind(Actor.getGlobalState().globalCounter, closure: { (value: JavaLangInteger?) -> () in
                    if value != nil {
                        if value!.intValue > 0 {
                            self.tabBarItem.badgeValue = "\(value!.intValue)"
                        } else {
                            self.tabBarItem.badgeValue = nil
                        }
                    } else {
                        self.tabBarItem.badgeValue = nil
                    }
                })
            }
            
        }
    }
    
    func bindCheckingConnections() {
        dispatchOnUi { () -> Void in
            self.binder.bind((Actor.getGlobalState().isSyncing)!, valueModel2: Actor.getGlobalState().isConnecting) {
                (isSyncing: JavaLangBoolean?, isConnecting: JavaLangBoolean?) -> () in
                
                if isSyncing!.booleanValue() || isConnecting!.booleanValue() {
                    if isConnecting!.booleanValue() {
                        //self.navigationItem.title = AALocalized("StatusConnecting")
                        
                        self.activityIndicator.animateActivity(title: AALocalized("StatusConnecting"), view: self.view, navigationItem: self.navigationItem)

                    } else {
                        //self.navigationItem.title = AALocalized("StatusSyncing")
                        
                        self.activityIndicator.animateActivity(title: AALocalized("StatusSyncing"), view: self.view, navigationItem: self.navigationItem)
                    }
                } else {
                    
                    self.navigationItem.title = AALocalized("TabMessages")
                    self.activityIndicator.stopAnimating(navigationItem: self.navigationItem)
                }
            }
        }
    }
    

    func back() {
        self.navigationController?.popViewController(animated: true)
    }
    
    open override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        isBinded = false
    }
    
    open override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        Actor.onDialogsOpen()
    }
    
    open override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        Actor.onDialogsClosed()
    }
    
    // Handling selections
    
    open func recentsDidTap(_ controller: AADialogsListContentController, dialog: ACDialog) -> Bool {
        if let customController = ActorSDK.sharedActor().delegate.actorControllerForConversation(dialog.peer) {
            self.navigateDetail(customController)
        } else {
            
//            print("dialog: \(dialog.)")
            let nav = AANavigationController()
            nav.navigateDetail(ConversationViewController(peer: dialog.peer))
        }
        return false
    }
    
    open func searchDidTap(_ controller: AADialogsListContentController, entity: ACSearchResult) {
        if let customController = ActorSDK.sharedActor().delegate.actorControllerForConversation(entity.peer) {
            self.navigateDetail(customController)
        } else {
            self.navigateDetail(ConversationViewController(peer: entity.peer))
        }
    }
}


///////

public class BadgeProperties {
    
    /**
     The initial frame of the badge.
     Defaults to CGRect.zero
     */
    public var originalFrame: CGRect
    
    /**
     The minimum width the badge can be.
     Defaults to 8.0
     */
    public var minimumWidth: CGFloat
    
    /**
     The additional horizontal padding of the badge
     Defaults to 4.0
     */
    public var horizontalPadding: CGFloat
    
    /**
     The additional vertical padding of the badge.
     Defaults to 0.0
     */
    public var verticalPadding: CGFloat
    
    public var font: UIFont
    public var textColor: UIColor
    public var backgroundColor: UIColor
    
    
    public init(
        originalFrame: CGRect = CGRect.zero,
        minimumWidth: CGFloat = 8.0,
        horizontalPadding: CGFloat = 8.0,
        verticalPadding: CGFloat = 0.0,
        font: UIFont = UIFont.systemFont(ofSize: 12.0),
        textColor: UIColor = UIColor.black,
        backgroundColor: UIColor = UIColor.green
        ) {
        self.originalFrame = originalFrame
        self.minimumWidth = minimumWidth
        self.horizontalPadding = horizontalPadding
        self.verticalPadding = verticalPadding
        self.font = font
        self.textColor = textColor
        self.backgroundColor = backgroundColor
    }
}

import QuartzCore

open class BadgedBarButtonItem: UIBarButtonItem {
    
    var badgeLabel: UILabel = UILabel()
    @IBInspectable public var badgeValue: Int = 0 {
        didSet {
            updateBadgeValue()
        }
    }
    
    fileprivate var _badgeValueString: String?
    fileprivate var badgeValueString: String {
        get {
            if let customString = _badgeValueString {
                return customString
            }
            
            return "\(badgeValue)"
        }
        set {
            _badgeValueString = newValue
        }
    }
    
    /**
     When the badgeValue is set to `0`, this flag will be checked to determine if the
     badge should be hidden.  Defaults to true.
     */
    public var shouldHideBadgeAtZero: Bool = true
    
    /**
     Flag indicating if the `badgeValue` should be animated when the value is changed.
     Defaults to true.
     */
    public var shouldAnimateBadge: Bool = true
    
    /**
     A collection of properties that define the layout and behavior of the badge.
     Accessable after initialization if run-time updates are required.
     */
    public var badgeProperties: BadgeProperties
    
    public init(customView: UIView, value: Int, badgeProperties: BadgeProperties = BadgeProperties()) {
        self.badgeProperties = badgeProperties
        super.init()
        
        badgeValue = value
        self.customView = customView
        
        commonInit()
        updateBadgeValue()
    }
    
    public init(startingBadgeValue: Int,
                frame: CGRect,
                title: String? = nil,
                image: UIImage?,
                badgeProperties: BadgeProperties = BadgeProperties()) {
        
        self.badgeProperties = badgeProperties
        super.init()
        
        performStoryboardInitalizationSetup(with: frame, title: title, image: image)
        self.badgeValue = startingBadgeValue
        updateBadgeValue()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        self.badgeProperties = BadgeProperties()
        super.init(coder: aDecoder)
        
        var buttonFrame: CGRect = CGRect.zero
        if let image = self.image {
            buttonFrame = CGRect(x: 0.0, y: 0.0, width: image.size.width, height: image.size.height)
        } else if let title = self.title {
            let lbl = UILabel()
            lbl.text = title
            let textSize = lbl.sizeThatFits(CGSize(width: 100.0, height: 100.0))
            buttonFrame = CGRect(x: 0.0, y: 0.0, width: textSize.width + 2.0, height: textSize.height)
        }
        
        
        performStoryboardInitalizationSetup(with: buttonFrame, title: self.title, image: self.image)
        commonInit()
    }
    
    
    private func performStoryboardInitalizationSetup(with frame: CGRect, title: String? = nil, image: UIImage?) {
        let btn = createInternalButton(frame: frame, title: title, image: image)
        self.customView = btn
//        btn.addTarget(self, action: #selector(internalButtonTapped(_:)), for: .touchUpInside)
    }
    
    private func commonInit() {
        badgeLabel.font = badgeProperties.font
        badgeLabel.textColor = badgeProperties.textColor
        badgeLabel.backgroundColor = badgeProperties.backgroundColor
    }
}

// MARK: - Public Functions
public extension BadgedBarButtonItem {
    
    /**
     Programmatically adds a target-action pair to the BadgedBarButtonItem
     */
    public func addTarget(_ target: AnyObject, action: Selector, for controlEvents: UIControl.Event){
        self.target = target
        self.action = action
    }
    
    /**
     Creates the internal UIButton to be used as the custom view of the UIBarButtonItem.
     
     - Note: Subclassable for further customization.
     
     - Parameter frame: The frame of the final BadgedBarButtonItem
     - Parameter title: The title of the BadgedBarButtonItem. Optional. Defaults to nil.
     - Parameter image: The image of the BadgedBarButtonItem. Optional.
     */
    public func createInternalButton(frame: CGRect,
                                     title: String? = nil,
                                     image: UIImage?) -> UIButton {
        
        let btn = UIButton(type: .custom)
        btn.setImage(image, for: UIControl.State())
        btn.setTitle(title, for: UIControl.State())
        btn.setTitleColor(UIColor.black, for: UIControl.State())
        btn.frame = frame
        
        return btn
    }
    
    /**
     Calculates the update position of the badge using the button's frame.
     
     Can be subclassed for further customization.
     */
    public func calculateUpdatedBadgeFrame(usingFrame frame: CGRect) {
        let offset = CGFloat(4.0)
        badgeProperties.originalFrame.origin.x = (frame.size.width - offset) - badgeLabel.frame.size.width/2
    }
}


// MARK: - Private Functions
fileprivate extension BadgedBarButtonItem {
    
    func updateBadgeValue() {
        guard !shouldBadgeHide(badgeValue) else {
            if (badgeLabel.superview != nil) {
                removeBadge()
            }
            return
        }
        
        if (badgeLabel.superview != nil) {
            animateBadgeValueUpdate()
        } else {
            badgeLabel = self.createBadgeLabel()
            updateBadgeProperties()
            customView?.addSubview(badgeLabel)
            
            // Pull the setting of the value and layer border radius off onto the next event loop.
            DispatchQueue.main.async() { () -> Void in
                self.badgeLabel.text = self.badgeValueString
                self.updateBadgeFrame()
            }
        }
    }
    
    func animateBadgeValueUpdate() {
        if shouldAnimateBadge, badgeLabel.text != badgeValueString {
            let animation: CABasicAnimation = CABasicAnimation()
            animation.keyPath = "transform.scale"
            animation.fromValue = 1.5
            animation.toValue = 1
            animation.duration = 0.2
            animation.timingFunction = CAMediaTimingFunction(controlPoints: 0.4, 1.3, 1.0, 1.0)
            badgeLabel.layer.add(animation, forKey: "bounceAnimation")
        }
        
        badgeLabel.text = badgeValueString;
        
        UIView.animate(withDuration: 0.2) {
            self.updateBadgeFrame()
        }
    }
    
    func updateBadgeFrame() {
        let expectedLabelSize: CGSize = badgeExpectedSize()
        var minHeight = expectedLabelSize.height
        
        minHeight = (minHeight < badgeProperties.minimumWidth) ? badgeProperties.minimumWidth : expectedLabelSize.height
        var minWidth = expectedLabelSize.width
        let horizontalPadding = badgeProperties.horizontalPadding
        
        minWidth = (minWidth < minHeight) ? minHeight : expectedLabelSize.width
        
        let nFrame = CGRect(
            x: badgeProperties.originalFrame.origin.x,
            y: badgeProperties.originalFrame.origin.y,
            width: minWidth + horizontalPadding,
            height: minHeight + horizontalPadding
        )
        
        UIView.animate(withDuration: 0.2) {
            self.badgeLabel.frame = nFrame
        }
        
        self.badgeLabel.layer.cornerRadius = (minHeight + horizontalPadding) / 2
    }
    
    func removeBadge() {
        let duration = shouldAnimateBadge ? 0.08 : 0.0
        
        let currentTransform = badgeLabel.layer.transform
        let tf = CATransform3DMakeScale(0.001, 0.001, 1.0)
        badgeLabel.layer.transform = tf
        let scaleAnimation = CABasicAnimation()
        scaleAnimation.fromValue = currentTransform
        scaleAnimation.duration = duration
        scaleAnimation.isRemovedOnCompletion = true
        badgeLabel.layer.add(scaleAnimation, forKey: "transform")
        
        badgeLabel.layer.opacity = 0.0
        let opacityAnimation = CABasicAnimation()
        opacityAnimation.fromValue = 1.0
        opacityAnimation.duration = duration
        opacityAnimation.isRemovedOnCompletion = true
        opacityAnimation.delegate = self
        badgeLabel.layer.add(opacityAnimation, forKey: "opacity")
    }
    
    func createBadgeLabel() -> UILabel {
        let frame = CGRect(
            x: badgeProperties.originalFrame.origin.x,
            y: badgeProperties.originalFrame.origin.y,
            width: badgeProperties.originalFrame.width,
            height: badgeProperties.originalFrame.height
        )
        let label = UILabel(frame: frame)
        label.textColor = badgeProperties.textColor
        label.font = badgeProperties.font
        label.backgroundColor = badgeProperties.backgroundColor
        label.textAlignment = NSTextAlignment.center
        label.layer.cornerRadius = frame.size.width / 2
        label.clipsToBounds = true
        
        return label
    }
    
    func badgeExpectedSize() -> CGSize {
        let frameLabel: UILabel = self.duplicateLabel(badgeLabel)
        frameLabel.sizeToFit()
        let expectedLabelSize: CGSize = frameLabel.frame.size
        
        return expectedLabelSize
    }
    
    func duplicateLabel(_ labelToCopy: UILabel) -> UILabel {
        let dupLabel = UILabel(frame: labelToCopy.frame)
        dupLabel.text = labelToCopy.text
        dupLabel.font = labelToCopy.font
        
        return dupLabel
    }
    
    func shouldBadgeHide(_ value: Int) -> Bool {
        return (value == 0) && shouldHideBadgeAtZero
    }
    
    func updateBadgeProperties() {
        if let customView = self.customView {
            calculateUpdatedBadgeFrame(usingFrame: customView.frame)
        }
    }
    
//    @objc func internalButtonTapped(_ sender: UIButton) {
//        guard let action = self.action, let target = self.target else {
//            preconditionFailure("Developer Error: The BadgedBarButtonItem requires a target-action pair")
//        }
//        
//        UIApplication.shared.sendAction(action, to: target, from: self, for: nil)
//    }
}

extension BadgedBarButtonItem: CAAnimationDelegate {
    public func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        if flag {
            self.badgeLabel.removeFromSuperview()
        }
    }
}
