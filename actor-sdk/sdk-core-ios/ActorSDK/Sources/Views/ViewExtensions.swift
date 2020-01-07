//
//  Copyright (c) 2014-2016 Actor LLC. <https://actor.im>
//

import Foundation

public extension UITabBarItem {
    
    public  convenience init(title: String, img: String, selImage: String) {
        
        let unselectedIcon = ActorSDK.sharedActor().style.tabUnselectedIconColor
        let unselectedText = ActorSDK.sharedActor().style.tabUnselectedTextColor
        let selectedIcon = ActorSDK.sharedActor().style.tabSelectedIconColor
        let selectedText = ActorSDK.sharedActor().style.tabSelectedTextColor
        
        self.init(title: AALocalized(title), image: UIImage.tinted(img, color: unselectedIcon), selectedImage: UIImage.tinted(selImage, color: selectedIcon))
//        self.init(title: AALocalized(title), image: UIImage(named: img), selectedImage: UIImage.tinted(selImage, color: selectedIcon))
//        self.init(title: AALocalized(title), image: UIImage(named: img), selectedImage: UIImage(named: selImage))
//        setTitleTextAttributes([NSAttributedString.Key.foregroundColor: unselectedText], for: UIControl.State())
//        setTitleTextAttributes([NSAttributedString.Key.foregroundColor: selectedText], for: UIControl.State.selected)
        
    }
}
