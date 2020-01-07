import UIKit

open class AANavigationController: UINavigationController {
    
    fileprivate let binder = AABinder()
    
    public init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    public override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    public override init(rootViewController: UIViewController) {
        super.init(rootViewController: rootViewController)
    }

    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        
        styleNavBar()
        
//         Enabling app state sync progress
//        self.setPrimaryColor(MainAppTheme.navigation.progressPrimary)
//        self.setSecondaryColor(MainAppTheme.navigation.progressSecondary)
//        
//        binder.bind(Actor.getAppState().isSyncing, valueModel2: Actor.getAppState().isConnecting) { (value1: JavaLangBoolean?, value2: JavaLangBoolean?) -> () in
//            if value1!.booleanValue() || value2!.booleanValue() {
//                self.showProgress()
//                self.setIndeterminate(true)
//            } else {
//                self.finishProgress()
//            }
//        }
    }
    
    open override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        styleNavBar()
        
        if #available(iOS 11.0, *) {
            UIApplication.shared.setStatusBarStyle(UIStatusBarStyle.default, animated: true)
        } else {
            UIApplication.shared.setStatusBarStyle(UIStatusBarStyle.default, animated: true)

        }
        
    }
    
    open override var preferredStatusBarStyle : UIStatusBarStyle {
        return ActorSDK.sharedActor().style.vcStatusBarStyle
    }
    
// navigationBar image
    
    fileprivate func image(fromLayer layer: CALayer) -> UIImage {
        UIGraphicsBeginImageContext(layer.frame.size)
        layer.render(in: UIGraphicsGetCurrentContext()!)
        let outputImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return outputImage!
    }

    fileprivate func styleNavBar() {
        
//        navigationBar.barTintColor = ActorSDK.sharedActor().style.navigationBgColor
        
        
        
//        navigationBar.hairlineHidden = ActorSDK.sharedActor().style.navigationHairlineHidden
        if #available(iOS 11.0, *) {
        
            navigationBar.prefersLargeTitles = true
            //navigationBar.tintColor = .black
//            let searchController = UISearchController(ACSearchResult)
            navigationItem.largeTitleDisplayMode = .always
            //navigationBar.tintColor = UIColor(red:0.00, green:0.35, blue:1.00, alpha:1.0)
            //navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor(red:0.00, green:0.35, blue:1.00, alpha:1.0)]
            //navigationBar.hairlineHidden = true
            navigationBar.isTranslucent = false
            navigationBar.setTransparentBackground()

            
        } else {
            
            navigationBar.tintColor = .black
            //            let searchController = UISearchController(ACSearchResult)
            navigationBar.tintColor = UIColor(red:0.00, green:0.35, blue:1.00, alpha:1.0)
            navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor(red:0.00, green:0.35, blue:1.00, alpha:1.0)]

        }
            
//            navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor: ActorSDK.sharedActor().style.navigationTitleColor]
//            navigationBar.tintColor = ActorSDK.sharedActor().style.navigationTintColor
//            // navigationBar set Gradient
//            let gradient = CAGradientLayer()
//            let defaultNavigationBarFrame = CGRect(x: 0, y: UIScreen.main.applicationFrame.height - 2, width: UIScreen.main.applicationFrame.width, height: 2)
//            //let color1 = UIColor(red: 0.12, green: 0.05, blue: 0.69, alpha: 1.0).cgColor as CGColor
//            let color1 = UIColor(red:0.03, green:0.65, blue:1.00, alpha:1.0).cgColor as CGColor
//            //let color2 = UIColor(red:0.35, green:0.03, blue:0.64, alpha:1.0).cgColor as CGColor
//            let color3 = UIColor(red:0.00, green:0.35, blue:1.00, alpha:1.0).cgColor as CGColor
//
//            gradient.frame = defaultNavigationBarFrame
//            gradient.colors = [color1, color3]
//            gradient.startPoint = CGPoint(x: 0.0, y: 0.5)
//            gradient.endPoint = CGPoint(x: 1, y: 0.5)
//            navigationBar.setBackgroundImage(image(fromLayer: gradient), for: .default)
//        }
        view.backgroundColor = ActorSDK.sharedActor().style.vcBgColor
    }
}

