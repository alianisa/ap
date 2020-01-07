//
//  Copyright (c) 2014-2016 Actor LLC. <https://actor.im>
//

import UIKit
//import VideoSplashKit

class AAWelcomeController: AAViewController {
    
    let bgImage: UIImageView            = UIImageView()
    let logoView: UIImageView           = UIImageView()
    let appNameLabel: UILabel           = UILabel()
    let someInfoLabel: UILabel          = UILabel()
    let signupButton: UIButton          = UIButton()
    let signinButton: UIButton          = UIButton()
    var size: CGSize                    = CGSize()
    var logoViewVerticalGap: CGFloat    = CGFloat()
    
    public override init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    public required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    fileprivate func image(fromLayer layer: CALayer) -> UIImage {
        UIGraphicsBeginImageContext(layer.frame.size)
        layer.render(in: UIGraphicsGetCurrentContext()!)
        let outputImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return outputImage!
    }
    
    open override func loadView() {
        super.loadView()
        
        
//        let gradient = CAGradientLayer()
//        let defaultNavigationBarFrame = CGRect(x: 0, y: UIScreen.main.applicationFrame.height - 2, width: UIScreen.main.applicationFrame.width, height: 2)
////        let color1 = UIColor(red: 0.12, green: 0.05, blue: 0.69, alpha: 1.0).cgColor as CGColor
//        let color1 = UIColor(red:0.17, green:0.02, blue:0.56, alpha:1.0).cgColor as CGColor
//        //let color2 = UIColor(red:0.35, green:0.03, blue:0.64, alpha:1.0).cgColor as CGColor
//        let color3 = UIColor(red:0.35, green:0.02, blue:0.56, alpha:1.0).cgColor as CGColor
//
//        gradient.frame = defaultNavigationBarFrame
//        gradient.colors = [color1, color3]
//        gradient.startPoint = CGPoint(x: 0.5, y: 0.0)
//        gradient.endPoint = CGPoint(x: 0.5, y: 1.0)
//        navigationBar.setBackgroundImage(image(fromLayer: gradient), for: .default)
        
        
        
        self.view.backgroundColor = UIColor.white
        
//        self.bgImage.image = image(fromLayer: gradient)
//        self.bgImage.isHidden = ActorSDK.sharedActor().style.welcomeBgImage == nil
//        self.bgImage.contentMode = .scaleAspectFill
        
        self.logoView.image = ActorSDK.sharedActor().style.welcomeLogo
        self.size = ActorSDK.sharedActor().style.welcomeLogoSize
        self.logoViewVerticalGap = ActorSDK.sharedActor().style.logoViewVerticalGap
        
        appNameLabel.text = AALocalized("WelcomeTitle").replace("{app_name}", dest: ActorSDK.sharedActor().appName)
        appNameLabel.textAlignment = .center
        appNameLabel.backgroundColor = UIColor.clear
        appNameLabel.font = UIFont.mediumSystemFontOfSize(24)
        appNameLabel.textColor = UIColor.black
        
        someInfoLabel.text = AALocalized("WelcomeTagline")
        someInfoLabel.textAlignment = .center
        someInfoLabel.backgroundColor = UIColor.clear
        someInfoLabel.font = UIFont.systemFont(ofSize: 16)
        someInfoLabel.numberOfLines = 2
        someInfoLabel.textColor = UIColor.gray
        
        signupButton.setTitle(AALocalized("WelcomeSignUp"), for: UIControl.State())
        signupButton.titleLabel?.font = UIFont.mediumSystemFontOfSize(17)
        signupButton.setTitleColor(UIColor.white, for: UIControl.State())
        signupButton.setBackgroundImage(Imaging.roundedImage(UIColor(red:0.03, green:0.50, blue:1.00, alpha:1.0), radius: 20), for: UIControl.State())
        signupButton.setBackgroundImage(Imaging.roundedImage(ActorSDK.sharedActor().style.welcomeSignupBgColor.alpha(0.7), radius: 20), for: .highlighted)
        signupButton.addTarget(self, action: #selector(AAWelcomeController.signupAction), for: UIControl.Event.touchUpInside)
        
        signinButton.setTitle(AALocalized("WelcomeLogIn"), for: UIControl.State())
        signinButton.titleLabel?.font = UIFont.systemFont(ofSize: 17)
        signinButton.setTitleColor(ActorSDK.sharedActor().style.welcomeLoginTextColor, for: UIControl.State())
        signinButton.setTitleColor(ActorSDK.sharedActor().style.welcomeLoginTextColor.alpha(0.7), for: .highlighted)
        signinButton.addTarget(self, action: #selector(AAWelcomeController.signInAction), for: UIControl.Event.touchUpInside)
        
        self.view.addSubview(self.bgImage)
        self.view.addSubview(self.logoView)
        self.view.addSubview(self.appNameLabel)
        self.view.addSubview(self.someInfoLabel)
        self.view.addSubview(self.signupButton)
        //        self.view.addSubview(self.signinButton)
    }
    
    override open func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        if AADevice.isiPhone4 {
            logoView.frame = CGRect(x: (view.width - size.width) / 2, y: 90, width: size.width, height: size.height)
            appNameLabel.frame = CGRect(x: (view.width - 300) / 2, y: logoView.bottom + 30, width: 300, height: 29)
            someInfoLabel.frame = CGRect(x: (view.width - 300) / 2, y: appNameLabel.bottom + 8, width: 300, height: 56)
            
            signupButton.frame = CGRect(x: (view.width - 300) / 2, y: view.height - 44 - 80, width: 300, height: 44)
            //            signinButton.frame = CGRect(x: (view.width - 136) / 2, y: view.height - 44 - 25, width: 136, height: 44)
        } else {
            
            logoView.frame = CGRect(x: (view.width - size.width) / 2, y: logoViewVerticalGap, width: size.width, height: size.height)
            appNameLabel.frame = CGRect(x: (view.width - 300) / 2, y: logoView.bottom + 35, width: 300, height: 29)
            someInfoLabel.frame = CGRect(x: (view.width - 300) / 2, y: appNameLabel.bottom + 8, width: 300, height: 56)
            
            signupButton.frame = CGRect(x: (view.width - 300) / 2, y: view.height - 44 - 20, width: 300, height: 44)
            //            signinButton.frame = CGRect(x: (view.width - 136) / 2, y: view.height - 44 - 35, width: 136, height: 44)
        }
        
        self.bgImage.frame = view.bounds
    }
    
    @objc open func signupAction() {
        // TODO: Remove BG after auth?
        UIApplication.shared.keyWindow?.backgroundColor = ActorSDK.sharedActor().style.welcomeBgColor
        self.presentElegantViewController(AAAuthNavigationController(rootViewController: AAAuthNameViewController()))
//        self.presentElegantViewController(AAAuthNavigationController(rootViewController: AAAuthLogInViewController()))

    }
    
    @objc open func signInAction() {
        // TODO: Remove BG after auth?
        UIApplication.shared.keyWindow?.backgroundColor = ActorSDK.sharedActor().style.welcomeBgColor
        self.presentElegantViewController(AAAuthNavigationController(rootViewController: AAAuthLogInViewController()))
    }
    
    open override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // TODO: Fix after cancel?
        UIApplication.shared.setStatusBarStyle(.default, animated: true)
    }
}
