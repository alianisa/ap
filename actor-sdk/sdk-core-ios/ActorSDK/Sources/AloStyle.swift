

import Foundation

open class ActorStyle {
    
    //
    // Main colors of app
    //
    
    /// Is Application have dark theme. Default is false.
    open var isDarkApp = false
    
    /// Tint Color. Star button
    open var vcStarButton = UIColor(red: 255/255.0, green: 255/255.0, blue: 255/255.0, alpha: 1)
    /// Tint Color. Used for "Actions". Default is sytem blue.
//    open var vcTintColor = UIColor(rgb: 0x4b0082)
    open var vcTintColor = UIColor(rgb: 0x000000)

    open var vcSelectedIconColor = UIColor(rgb: 0x280ce5)
    /// Color of desctructive actions. Default is red
    open var vcDestructiveColor = UIColor.red
    /// Default background color
    open var vcDefaultBackgroundColor = UIColor.white
    /// Main Text color of app
    open var vcTextColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0xDE/255.0)
    /// Text Hint colors
    open var vcHintColor = UIColor(red: 127/255.0, green: 127/255.0, blue: 127/255.0, alpha: 1)
    /// App's main status bar style. Default is light content.
    open var vcStatusBarStyle = UIStatusBarStyle.lightContent
    /// UITableView separator color. Also used for other separators or borders.
    open var vcSeparatorColor = UIColor(rgb: 0xdededf)
    /// Cell Selected color
    open var vcSelectedColor = UIColor(rgb: 0xd9d9d9)
    /// Header/Footer text color
    open var vcSectionColor = UIColor(rgb: 0x5b5a60)
    /// Pacgkround of various panels like UITabBar. Default is white.
    open var vcPanelBgColor = UIColor.white
    /// UISwitch off border color
    open var vcSwitchOff = UIColor(rgb: 0xe6e6e6)
    /// UISwitch on color
    open var vcSwitchOn = UIColor(rgb: 0x4bd863)
    /// View Controller background color
    open var vcBgColor = UIColor.white
    /// View Controller background color for settings
    open var vcBackyardColor = UIColor(rgb: 0xf0eff5)
    
    //
    // UINavigationBar
    //
    /// Main Navigation bar color
    open var navigationBgColor: UIColor = UIColor(red: 30.0/255.0, green: 14.0/255.0, blue: 176.0/255.0, alpha: 1)
    /// Main Navigation bar hairline color
    open var navigationHairlineHidden = false
    /// Main Navigation bar hairline color
    open var navigationIsTransluent = false
    /// Navigation Bar icons colors
    open var navigationTintColor: UIColor = UIColor(rgb: 0xffffff)
    /// Navigation Bar title color
    open var navigationTitleColor: UIColor = UIColor(rgb: 0xffffff)
    /// Navigation Bar subtitle color, default is 0.8 alhpa of navigationTitleColor
    open var navigationSubtitleColor: UIColor {
        get { return _navigationSubtitleColor != nil ? _navigationSubtitleColor! : navigationTitleColor.alpha(0.8) }
        set(v) { _navigationSubtitleColor = v }
    }
    fileprivate var _navigationSubtitleColor: UIColor?
    /// Navigation Bar actove subtitle color, default is navigationTitleColor
    open var navigationSubtitleActiveColor: UIColor {
        get { return _navigationSubtitleActiveColor != nil ? _navigationSubtitleActiveColor! : navigationTitleColor }
        set(v) { _navigationSubtitleActiveColor = v }
    }
    fileprivate var _navigationSubtitleActiveColor: UIColor?

    //
    // Token Field. Used at entering members of new group.
    //
    
    /// Token Text Color. Default is vcTextColor.
    open var vcTokenFieldTextColor: UIColor {
        get { return _vcTokenFieldTextColor != nil ? _vcTokenFieldTextColor! : vcTextColor }
        set(v) { _vcTokenFieldTextColor = v }
    }
    fileprivate var _vcTokenFieldTextColor: UIColor?
    /// Background Color of Token field. Default is vcBgColor.
    open var vcTokenFieldBgColor: UIColor {
        get { return _vcTokenFieldBgColor != nil ? _vcTokenFieldBgColor! : vcBgColor }
        set(v) { _vcTokenFieldBgColor = v }
    }
    fileprivate var _vcTokenFieldBgColor: UIColor?
    /// Token Tint Color. Default is vcTintColor.
    open var vcTokenTintColor: UIColor {
        get { return _vcTokenTintColor != nil ? _vcTokenTintColor! : vcTintColor }
        set(v) { _vcTokenTintColor = v }
    }
    fileprivate var _vcTokenTintColor: UIColor?
    
    //
    // Search style
    //
    
    /// Style of status bar when search is active.
    open var searchStatusBarStyle = UIStatusBarStyle.default
    /// Background Color of search bar
    open var searchBackgroundColor: UIColor {
        get { return _searchBackgroundColor != nil ? _searchBackgroundColor! : UIColor.white  }
        set(v) { _searchBackgroundColor = v }
    }
    fileprivate var _searchBackgroundColor: UIColor?
    /// Cancel button color
    open var searchCancelColor: UIColor {
        get { return _searchCancelColor != nil ? _searchCancelColor! : vcTintColor }
        set(v) { _searchCancelColor = v }
    }
    fileprivate var _searchCancelColor: UIColor?
    /// Search Input Field background color
    open var searchFieldBgColor = UIColor(rgb: 0xededed)
    /// Search Input Field text color
    open var searchFieldTextColor = UIColor.black.alpha(0.56)
    
    //
    // UITabBarView style
    //
    
    /// Selected Text Color of UITabViewItem. Default is vcTintColor.
//    open var tabSelectedTextColor: UIColor {
//        get { return _tabSelectedTextColor != nil ? _tabSelectedTextColor! : vcTintColor }
//        set(v) { _tabSelectedTextColor = v }
//    }
//    fileprivate var _tabSelectedTextColor: UIColor?
    open var tabSelectedTextColor = UIColor(red:0.00, green:0.35, blue:1.00, alpha:1.0)
    /// Selected Icon Color of UITableViewItem. Default is vcTintColor.
//    open var tabSelectedIconColor: UIColor {
//        get { return _tabSelectedIconColor != nil ? _tabSelectedIconColor! : vcSelectedIconColor }
//        set(v) { _tabSelectedIconColor = v }
//    }
//    fileprivate var _tabSelectedIconColor: UIColor?
    open var tabSelectedIconColor = UIColor(red:0.00, green:0.35, blue:1.00, alpha:1.0)
    /// Unselected Text Color of UITabViewItem. Default is vcHintColor.
//    open var tabUnselectedTextColor: UIColor {
//        get { return _tabUnselectedTextColor != nil ? _tabUnselectedTextColor! : tabSelectedIconColor }
//        set(v) { _tabUnselectedTextColor = v }
//    }
//    fileprivate var _tabUnselectedTextColor: UIColor?
    open var tabUnselectedTextColor = UIColor.gray
//    /// Unselected Icon Color of UITableViewItem. Default is vcHintColor.
//    fileprivate var _tabUnselectedIconColor: UIColor?
//    open var tabUnselectedIconColor: UIColor {
//        get { return _tabUnselectedIconColor != nil ? _tabUnselectedIconColor! : vcHintColor }
//        set(v) { _tabUnselectedIconColor = v }
//    }
    open var tabUnselectedIconColor = UIColor.gray
    /// Background color of UITabBarView. Default is vcPanelBgColor.
//    fileprivate var _tabBgColor: UIColor?
//    open var tabBgColor: UIColor {
//        get { return _tabBgColor != nil ? _tabBgColor! : vcPanelBgColor }
//        set(v) { _tabBgColor = v }
//    }
    
    open var tabBgColor = UIColor.white
    
    //
    // Cell View style
    //
    
    /// Cell Background color. Default is vcBgColor.
    open var cellBgColor: UIColor {
        get { return _cellBgColor != nil ? _cellBgColor! : vcBgColor }
        set(v) { _cellBgColor = v }
    }
    fileprivate var _cellBgColor: UIColor?
    /// Cell Background selected color. Default is vcSelectedColor.
    open var cellBgSelectedColor: UIColor {
        get { return _cellBgSelectedColor != nil ? _cellBgSelectedColor! : vcSelectedColor }
        set(v) { _cellBgSelectedColor = v }
    }
    fileprivate var _cellBgSelectedColor: UIColor?
    /// Cell text color. Default is vcTextColor.
    open var cellTextColor: UIColor {
        get { return _cellTextColor != nil ? _cellTextColor! : vcTextColor }
        set(v) { _cellTextColor = v }
    }
    fileprivate var _cellTextColor: UIColor?
    /// Cell hint text color. Default is vcHintColor.
    open var cellHintColor: UIColor {
        get { return _cellHintColor != nil ? _cellHintColor! : vcHintColor }
        set(v) { _cellHintColor = v }
    }
    fileprivate var _cellHintColor: UIColor?
    /// Cell action color. Default is vcTintColor.
    open var cellTintColor: UIColor {
        get { return _cellTintColor != nil ? _cellTintColor! : vcTintColor }
        set(v) { _cellTintColor = v }
    }
    fileprivate var _cellTintColor: UIColor?
    /// Cell desctructive color. Default is vcDestructiveColor.
    open var cellDestructiveColor: UIColor {
        get { return _cellDestructiveColor != nil ? _cellDestructiveColor! : vcDestructiveColor }
        set(v) { _cellDestructiveColor = v }
    }
    fileprivate var _cellDestructiveColor: UIColor?
    /// Section header color. Default is vcSectionColor.
    open var cellHeaderColor: UIColor {
        get { return _cellHeaderColor != nil ? _cellHeaderColor! : vcSectionColor }
        set(v) { _cellHeaderColor = v }
    }
    fileprivate var _cellHeaderColor: UIColor?
    /// Section footer color. Default is vcSectionColor.
    open var cellFooterColor: UIColor {
        get { return _cellFooterColor != nil ? _cellFooterColor! : vcSectionColor }
        set(v) { _cellFooterColor = v }
    }
    fileprivate var _cellFooterColor: UIColor?
    
    //
    // Full screen placeholder style
    //
    
    /// Big Placeholder background color
    open var placeholderBgColor: UIColor {
        get { return _placeholderBgColor != nil ? _placeholderBgColor! : navigationBgColor.fromTransparentBar() }
        set(v) { _placeholderBgColor = v }
    }
    fileprivate var _placeholderBgColor: UIColor?
    /// Big placeholder title color
    open var placeholderTitleColor: UIColor {
        get { return _placeholderTitleColor != nil ? _placeholderTitleColor! : vcTextColor }
        set(v) { _placeholderTitleColor = v }
    }
    fileprivate var _placeholderTitleColor: UIColor?
    /// Bit Placeholder hint color
    open var placeholderHintColor: UIColor {
        get { return _placeholderHintColor != nil ? _placeholderHintColor! : vcHintColor }
        set(v) { _placeholderHintColor = v }
    }
    fileprivate var _placeholderHintColor: UIColor?
    
    //
    // Avatar Placeholder and name colors
    //
    
    open var avatarTextColor = UIColor.white
    
    open var avatarLightBlue = UIColor(rgb: 0x72d5fd)
    open var nameLightBlue = UIColor(rgb: 0x72d5fd)
    open var avatarLightBlueGradient = UIColor(rgb: 0x2a9ef1)
    
    //    open var avatarDarkBlue = UIColor(rgb: 0x1d4e6f)
    //    open var nameDarkBlue = UIColor(rgb: 0x1d4e6f)
    //    open var avatarDarkBlueGradient = UIColor(rgb: 0x4f87ad)
    
    open var avatarPurple = UIColor(rgb: 0xd652ea)
    open var namePurple = UIColor(rgb: 0xd652ea)
    open var avatarPurpleGradient = UIColor(rgb: 0xeb8af9)
    
    open var avatarPink = UIColor(rgb: 0xff885e)
    open var namePink = UIColor(rgb: 0xff885e)
    open var avatarPinkGradient = UIColor(rgb: 0xff516a)
    
    open var avatarOrange = UIColor(rgb: 0xffcd6a)
    open var nameOrange = UIColor(rgb: 0xffcd6a)
    open var avatarOrangeGradient = UIColor(rgb: 0xffa85c)
    
    open var avatarYellow = UIColor(rgb: 0xe0a2f3)
    open var nameYellow = UIColor(rgb: 0xe0a2f3)
    open var avatarYellowGradient = UIColor(rgb: 0xd669ed)
    
    open var avatarGreen = UIColor(rgb: 0xa0de7e)
    open var nameGreen = UIColor(rgb: 0xa0de7e)
    open var avatarGreenGradient = UIColor(rgb: 0x54cb68)
    
    open var avatarIndigo = UIColor(rgb: 0x82b1ff)
    open var nameIndigo = UIColor(rgb: 0x82b1ff)
    open var avatarIndigoGradient = UIColor(rgb: 0x665fff)

    
    fileprivate var _avatarColors1: [UIColor]?
    open var avatarColors1: [UIColor] {
        get {
            if _avatarColors1 == nil {
                return [
                    avatarLightBlue,
//                    avatarDarkBlue,
                    avatarPurple,
                    avatarPink,
                    avatarOrange,
                    avatarYellow,
                    avatarGreen,
                    avatarIndigo
                ]
            } else {
                return _avatarColors1!
            }
        }
        set(v) { _avatarColors1 = v }
    }
    
    fileprivate var _avatarColors2: [UIColor]?
    open var avatarColors2: [UIColor] {
        get {
            if _avatarColors2 == nil {
                return [
                    avatarLightBlueGradient,
//                    avatarDarkBlueGradient,
                    avatarPurpleGradient,
                    avatarPinkGradient,
                    avatarOrangeGradient,
                    avatarYellowGradient,
                    avatarGreenGradient,
                    avatarIndigoGradient
                ]
            } else {
                return _avatarColors2!
            }
        }
        set(v) { _avatarColors2 = v }
    }
    
    fileprivate var _nameColors: [UIColor]?
    open var nameColors: [UIColor] {
        get {
            if _nameColors == nil {
                return [
                    nameLightBlue,
//                    nameDarkBlue,
                    namePurple,
                    namePink,
                    nameOrange,
                    nameYellow,
                    nameGreen
                ]
            } else {
                return _nameColors!
            }
        }
        set(v) { _nameColors = v }
    }
    
    //
    // Bubble styles
    //
    
    // Text colors
    
    fileprivate var _chatTextColor: UIColor?
    open var chatTextColor: UIColor {
        get { return _chatTextColor != nil ? _chatTextColor! : vcTextColor }
        set(v) { _chatTextColor = v }
    }
    
//    fileprivate var _chatUrlColor: UIColor?
//    open var chatUrlColor: UIColor {
//        get { return _chatUrlColor != nil ? _chatUrlColor! : vcTintColor }
//        set(v) { _chatUrlColor = v }
//    }
    open var chatUrlColor = UIColor.blue
    
    fileprivate var _chatTextUnsupportedColor: UIColor?
    open var chatTextUnsupportedColor: UIColor {
        get { return _chatTextUnsupportedColor != nil ? _chatTextUnsupportedColor! : vcTintColor.alpha(0.54) }
        set(v) { _chatTextUnsupportedColor = v }
    }
    
//    fileprivate var _chatTextOutColor: UIColor?
//    open var chatTextOutColor: UIColor {
//        get { return _chatTextOutColor != nil ? _chatTextOutColor! : chatTextColor }
//        set(v) { _chatTextOutColor = v }
//    }
//    open var chatTextOutColor = UIColor.alphaBlack(0.9)
    open var chatTextOutColor = UIColor.black
//    open var chatTextOutColor = UIColor.white



    fileprivate var _chatTextInColor: UIColor?
    open var chatTextInColor: UIColor {
        get { return _chatTextInColor != nil ? _chatTextInColor! : chatTextColor }
        set(v) { _chatTextInColor = v }
    }

    fileprivate var _chatTextOutUnsupportedColor: UIColor?
    open var chatTextOutUnsupportedColor: UIColor {
        get { return _chatTextOutUnsupportedColor != nil ? _chatTextOutUnsupportedColor! : chatTextUnsupportedColor }
        set(v) { _chatTextOutUnsupportedColor = v }
    }
    
    fileprivate var _chatTextInUnsupportedColor: UIColor?
    open var chatTextInUnsupportedColor: UIColor {
        get { return _chatTextInUnsupportedColor != nil ? _chatTextInUnsupportedColor! : chatTextUnsupportedColor }
        set(v) { _chatTextInUnsupportedColor = v }
    }

    open var chatDateTextColor = UIColor.white
    
    open var chatServiceTextColor = UIColor.white
    
    open var chatUnreadTextColor = UIColor.white
    
    // Date colors

    open var chatTextDateOutColor = UIColor(red:0.03, green:0.50, blue:1.00, alpha:1.0)
    open var chatTextDateInColor = UIColor(rgb: 0x979797)

    open var chatMediaDateColor = UIColor.white
    open var chatMediaDateBgColor = UIColor.black.alpha(0.4)
    
    // Bubble Colors
    
    open var chatTextBubbleOutColor = UIColor(red:0.88, green:0.98, blue:1.00, alpha:1.0)
//    open var chatTextBubbleOutColor = UIColor(red:0.03, green:0.50, blue:1.00, alpha:1.0)

    open var chatTextBubbleOutSelectedColor = UIColor.lightGray
    
    open var chatTextBubbleOutBorderColor = UIColor(red:0.03, green:0.50, blue:1.00, alpha:1.0)
    
    open var chatTextBubbleInColor = UIColor.white
    
    open var chatTextBubbleInSelectedColor = UIColor.blue
    
    open var chatTextBubbleInBorderColor = UIColor(rgb: 0xffffff)
    
    open var chatMediaBubbleColor = UIColor.white
    open var chatMediaBubbleBorderColor = UIColor(rgb: 0xc4e8fb)

    open var chatDateBubbleColor = UIColor.black.alpha(0.1)
    
    open var chatServiceBubbleColor = UIColor.black.alpha(0.1)
    
    open var chatUnreadBgColor = UIColor(red:0.11, green:0.48, blue:0.77, alpha:0.2)
    
    open var chatReadMediaColor = UIColor(red:0.03, green:0.50, blue:1.00, alpha:1.0)
    
    // Bubble Shadow
    
    open var bubbleShadowEnabled = false
    
//    open var chatTextBubbleShadowColor = UIColor.alphaBlack(0.7)
    open var chatTextBubbleShadowColor = UIColor.gray.alpha(0.7)
    
    // Status Colors
    
    open lazy var chatIconCheck1 = UIImage.templated("msg_check_1")
    open lazy var chatIconCheck2 = UIImage.templated("msg_check_2")
    open lazy var chatIconError = UIImage.templated("msg_error")
    open lazy var chatIconWarring = UIImage.templated("msg_warring")
    open lazy var chatIconClock = UIImage.templated("msg_clock")
    open lazy var chatIconDialog = UIImage.templated("bubble_service_bg")
    
    fileprivate var _chatStatusActive: UIColor?
    open var chatStatusActive: UIColor {
        get { return _chatStatusActive != nil ? _chatStatusActive! : vcTintColor }
        set(v) { _chatStatusActive = v }
    }
    
    fileprivate var _chatStatusPassive: UIColor?
    open var chatStatusPassive: UIColor {
        get { return _chatStatusPassive != nil ? _chatStatusPassive! : vcHintColor }
        set(v) { _chatStatusPassive = v }
    }
    
    fileprivate var _chatStatusDanger: UIColor?
    open var chatStatusDanger: UIColor {
        get { return _chatStatusDanger != nil ? _chatStatusDanger! : vcDestructiveColor }
        set(v) { _chatStatusDanger = v }
    }
    
    fileprivate var _chatStatusMediaActive: UIColor?
    open var chatStatusMediaActive: UIColor {
        get { return _chatStatusMediaActive != nil ? _chatStatusMediaActive! : chatReadMediaColor }
        set(v) { _chatStatusMediaActive = v }
    }

    fileprivate var _chatStatusMediaPassive: UIColor?
    open var chatStatusMediaPassive: UIColor {
        get { return _chatStatusMediaPassive != nil ? _chatStatusMediaPassive! : UIColor.white }
        set(v) { _chatStatusMediaPassive = v }
    }
    
    fileprivate var _chatStatusMediaDanger: UIColor?
    open var chatStatusMediaDanger: UIColor {
        get { return _chatStatusMediaDanger != nil ? _chatStatusMediaDanger! : chatStatusDanger }
        set(v) { _chatStatusMediaDanger = v }
    }
    
//    fileprivate var _chatStatusSending: UIColor?
//    open var chatStatusSending: UIColor {
//        get { return _chatStatusSending != nil ? _chatStatusSending! : chatStatusPassive }
//        set(v) { _chatStatusSending = v }
//    }

    open var chatStatusSending = UIColor(rgb: 0x59599e, alpha: 1.0)
    
//    fileprivate var _chatStatusSent: UIColor?
//    open var chatStatusSent: UIColor {
//        get { return _chatStatusSent != nil ? _chatStatusSent! : chatStatusPassive }
//        set(v) { _chatStatusSent = v }
//    }
    
    open var chatStatusSent = UIColor.gray
    
//    fileprivate var _chatStatusReceived: UIColor?
//    open var chatStatusReceived: UIColor {
//        get { return _chatStatusReceived != nil ? _chatStatusReceived! : chatStatusPassive }
//        set(v) { _chatStatusReceived = v }
//    }
    
    open var chatStatusReceived = UIColor.gray
    
//    fileprivate var _chatStatusRead: UIColor?
//    open var chatStatusRead: UIColor {
//        get { return _chatStatusRead != nil ? _chatStatusRead! : chatStatusActive }
//        set(v) { _chatStatusRead = v }
//    }
    
    open var chatStatusRead = UIColor(red:0.03, green:0.50, blue:1.00, alpha:1.0)
    
    fileprivate var _chatStatusError: UIColor?
    open var chatStatusError: UIColor {
        get { return _chatStatusError != nil ? _chatStatusError! : chatStatusDanger }
        set(v) { _chatStatusError = v }
    }
    
    fileprivate var _chatStatusMediaSending: UIColor?
    open var chatStatusMediaSending: UIColor {
        get { return _chatStatusMediaSending != nil ? _chatStatusMediaSending! : chatStatusMediaPassive }
        set(v) { _chatStatusMediaSending = v }
    }
    
    fileprivate var _chatStatusMediaSent: UIColor?
    open var chatStatusMediaSent: UIColor {
        get { return _chatStatusMediaSent != nil ? _chatStatusMediaSent! : chatStatusMediaPassive }
        set(v) { _chatStatusMediaSent = v }
    }
    
    fileprivate var _chatStatusMediaReceived: UIColor?
    open var chatStatusMediaReceived: UIColor {
        get { return _chatStatusMediaReceived != nil ? _chatStatusMediaReceived! : chatStatusMediaPassive }
        set(v) { _chatStatusMediaReceived = v }
    }
    
    fileprivate var _chatStatusMediaRead: UIColor?
    open var chatStatusMediaRead: UIColor {
        get { return _chatStatusMediaRead != nil ? _chatStatusMediaRead! : chatStatusMediaActive }
        set(v) { _chatStatusMediaRead = v }
    }
    
    fileprivate var _chatStatusMediaError: UIColor?
    open var chatStatusMediaError: UIColor {
        get { return _chatStatusMediaError != nil ? _chatStatusMediaError! : chatStatusMediaDanger }
        set(v) { _chatStatusMediaError = v }
    }

    // Chat screen
    
    fileprivate var _chatInputField: UIColor?
    open var chatInputFieldBgColor: UIColor {
        get { return _chatInputField != nil ? _chatInputField! : vcPanelBgColor }
        set(v) { _chatInputField = v }
    }
        
//    fileprivate var _chatAttachColor: UIColor?
//    open var chatAttachColor: UIColor {
//        get { return _chatAttachColor != nil ? _chatAttachColor! : vcTintColor }
//        set(v) { _chatAttachColor = v }
//    }
    
    open var chatAttachColor = UIColor(rgb: 0x0505a7, alpha: 1.0)
    
//    fileprivate var _chatSendColor: UIColor?
//    open var chatSendColor: UIColor {
//        get { return _chatSendColor != nil ? _chatSendColor! : vcTintColor }
//        set(v) { _chatSendColor = v }
//    }
    
    open var chatSendColor = UIColor(rgb: 0x0505a7, alpha: 1.0)

    fileprivate var _chatSendDisabledColor: UIColor?
    open var chatSendDisabledColor: UIColor {
        get { return _chatSendDisabledColor != nil ? _chatSendDisabledColor! : vcTintColor.alpha(0.64) }
        set(v) { _chatSendDisabledColor = v }
    }
    
    fileprivate var _chatAutocompleteHighlight: UIColor?
    open var chatAutocompleteHighlight: UIColor {
        get { return _chatAutocompleteHighlight != nil ? _chatAutocompleteHighlight! : vcTintColor }
        set(v) { _chatAutocompleteHighlight = v }
    }
    
//    open lazy var chatBgColor = UIColor(patternImage: UIImage.bundled("chat_bg")!)
    open lazy var chatBgColor = UIColor(rgb: 0xdee3e9, alpha: 0.9)
    //
    // Dialogs styles
    //
    
    fileprivate var _dialogTitleColor: UIColor?
    open var dialogTitleColor: UIColor {
        get { return _dialogTitleColor != nil ? _dialogTitleColor! : vcTextColor }
        set(v) { _dialogTitleColor = v }
    }
    
//    fileprivate var _dialogTextColor: UIColor?
//    open var dialogTextColor: UIColor {
//        get { return _dialogTextColor != nil ? _dialogTextColor! : dialogTitleColor.alpha(0.64) }
//        set(v) { _dialogTextColor = v }
//    }
    
    open var dialogTextColor = UIColor.gray
    
//    fileprivate var _dialogTextActiveColor: UIColor?
//    open var dialogTextActiveColor: UIColor {
//        get { return _dialogTextActiveColor != nil ? _dialogTextActiveColor! : vcTextColor }
//        set(v) { _dialogTextActiveColor = v }
//    }
    
    open var dialogTextActiveColor = UIColor(red:0.00, green:0.35, blue:1.00, alpha:1.0)
    
    fileprivate var _dialogDateColor: UIColor?
    open var dialogDateColor: UIColor {
        get { return _dialogDateColor != nil ? _dialogDateColor! : vcHintColor }
        set(v) { _dialogDateColor = v }
    }

    open var dialogCounterBgColor: UIColor = UIColor(rgb: 0x0066cc)
    
    open var dialogCounterColor: UIColor = UIColor.white
    
    fileprivate var _dialogStatusActive: UIColor?
    open var dialogStatusActive: UIColor {
        get { return _dialogStatusActive != nil ? _dialogStatusActive! : chatStatusActive }
        set(v) { _dialogStatusActive = v }
    }
    
    fileprivate var _dialogStatusPassive: UIColor?
    open var dialogStatusPassive: UIColor {
        get { return _dialogStatusPassive != nil ? _dialogStatusPassive! : chatStatusPassive }
        set(v) { _dialogStatusPassive = v }
    }

    fileprivate var _dialogStatusDanger: UIColor?
    open var dialogStatusDanger: UIColor {
        get { return _dialogStatusDanger != nil ? _dialogStatusDanger! : chatStatusDanger }
        set(v) { _dialogStatusDanger = v }
    }

    fileprivate var _dialogStatusSending: UIColor?
    open var dialogStatusSending: UIColor {
        get { return _dialogStatusSending != nil ? _dialogStatusSending! : dialogStatusPassive }
        set(v) { _dialogStatusSending = v }
    }
    
    fileprivate var _dialogStatusSent: UIColor?
    open var dialogStatusSent: UIColor {
        get { return _dialogStatusSent != nil ? _dialogStatusSent! : dialogStatusPassive }
        set(v) { _dialogStatusSent = v }
    }
    
    fileprivate var _dialogStatusReceived: UIColor?
    open var dialogStatusReceived: UIColor {
        get { return _dialogStatusReceived != nil ? _dialogStatusReceived! : dialogStatusPassive }
        set(v) { _dialogStatusReceived = v }
    }
    
    fileprivate var _dialogStatusRead: UIColor?
    open var dialogStatusRead: UIColor {
        get { return _dialogStatusRead != nil ? _dialogStatusRead! : dialogStatusActive }
        set(v) { _dialogStatusRead = v }
    }
    
    fileprivate var _dialogStatusError: UIColor?
    open var dialogStatusError: UIColor {
        get { return _dialogStatusError != nil ? _dialogStatusError! : dialogStatusDanger }
        set(v) { _dialogStatusError = v }
    }
    
    open var dialogAvatarSize: CGFloat = 60
    
    fileprivate var _statusBackgroundIcon: UIImage?
    open var statusBackgroundImage:UIImage {
        get {
            if (_statusBackgroundIcon == nil){

                let statusImage:UIImage = UIImage.bundled("bubble_service_bg")!.aa_imageWithColor(UIColor.black.withAlphaComponent(0.7)).withRenderingMode(UIImage.RenderingMode.alwaysOriginal)
                
                let center:CGPoint = CGPoint(x: statusImage.size.width / 2.0, y: statusImage.size.height / 2.0);
                let capInsets:UIEdgeInsets = UIEdgeInsets(top: center.y, left: center.x, bottom: center.y, right: center.x);
                
                _statusBackgroundIcon = statusImage.resizableImage(withCapInsets: capInsets, resizingMode: UIImage.ResizingMode.stretch)
                return _statusBackgroundIcon!
            } else {
                return _statusBackgroundIcon!
            }
        }
    }
    
    //
    // Contacts styles
    //

    fileprivate var _contactTitleColor: UIColor?
    open var contactTitleColor: UIColor {
        get { return _contactTitleColor != nil ? _contactTitleColor! : vcTextColor }
        set(v) { _contactTitleColor = v }
    }
    
    //
    // Online styles
    //
    
    fileprivate var _userOnlineColor: UIColor?
    open var userOnlineColor: UIColor {
        get { return _userOnlineColor != nil ? _userOnlineColor! : vcTintColor }
        set(v) { _userOnlineColor = v }
    }
    
//    open var userOnlineColor = UIColor.alphaWhite(0.4)
    
    fileprivate var _userOfflineColor: UIColor?
    open var userOfflineColor: UIColor {
        get { return _userOfflineColor != nil ? _userOfflineColor! : vcTextColor.alpha(0.54) }
        set(v) { _userOfflineColor = v }
    }

//    open var userOfflineColor = UIColor.alphaWhite(0.4)
    
//    fileprivate var _userOnlineNavigationColor: UIColor?
//    open var userOnlineNavigationColor: UIColor {
//        get { return _userOnlineNavigationColor != nil ? _userOnlineNavigationColor! : userOnlineColor }
//        set(v) { _userOnlineNavigationColor = v }
//    }
    
//    open var userOnlineNavigationColor = UIColor.alphaWhite(0.8)
    open var userOnlineNavigationColor = UIColor(red:0.00, green:0.35, blue:1.00, alpha:1.0)

    
//    fileprivate var _userOfflineNavigationColor: UIColor?
//    open var userOfflineNavigationColor: UIColor {
//        get { return _userOfflineNavigationColor != nil ? _userOfflineNavigationColor! : navigationSubtitleColor }
//        set(v) { _userOfflineNavigationColor = v }
//    }
    
    open var userOfflineNavigationColor = UIColor.alphaWhite(0.8)
    
    //
    // Compose styles
    //
    
    fileprivate var _composeAvatarBgColor: UIColor?
    open var composeAvatarBgColor: UIColor {
        get { return _composeAvatarBgColor != nil ? _composeAvatarBgColor! : vcBgColor }
        set(v) { _composeAvatarBgColor = v }
    }

    fileprivate var _composeAvatarBorderColor: UIColor?
    open var composeAvatarBorderColor: UIColor {
        get { return _composeAvatarBorderColor != nil ? _composeAvatarBorderColor! : vcSeparatorColor }
        set(v) { _composeAvatarBorderColor = v }
    }
    
    fileprivate var _composeAvatarTextColor: UIColor?
    open var composeAvatarTextColor: UIColor {
        get { return _composeAvatarTextColor != nil ? _composeAvatarTextColor! : vcHintColor }
        set(v) { _composeAvatarTextColor = v }
    }
    
    
    //
    // Status Bar progress
    //
    
    /// Is Status Bar connecting status hidden
    open var statusBarConnectingHidden = true
    
    /// Is Status Bar background color
    fileprivate var _statusBarConnectingBgColor : UIColor?
    open var statusBarConnectingBgColor: UIColor {
        get { return _statusBarConnectingBgColor != nil ? _statusBarConnectingBgColor! : navigationBgColor }
        set(v) { _statusBarConnectingBgColor = v }
    }

    /// Is Status Bar background color
    fileprivate var _statusBarConnectingTextColor : UIColor?
    open var statusBarConnectingTextColor: UIColor {
        get { return _statusBarConnectingTextColor != nil ? _statusBarConnectingTextColor! : navigationTitleColor }
        set(v) { _statusBarConnectingTextColor = v }
    }
    
    // 
    // Welcome
    //
    
    /// Welcome Page Background color
    open var welcomeBgColor = UIColor(red: 30, green: 14, blue: 176)
    
    /// Welcome Page Background image
    open var welcomeBgImage: UIImage? = nil
    
    /// Welcome Page Title Color
    open var welcomeTitleColor = UIColor.white

    /// Welcome Page Tagline Color
    open var welcomeTaglineColor = UIColor.white
    
    /// Welcome Page Signup Background Color
    open var welcomeSignupBgColor = UIColor.white
    
    /// Welcome Page Signup Text Color
    open var welcomeSignupTextColor = UIColor(red: 94, green: 142, blue: 192)
    
    /// Welcome Page Login Text Color
    open var welcomeLoginTextColor = UIColor.white
    
    /// Welcome Logo
    open var welcomeLogo:     UIImage? = UIImage.bundled("logo_welcome")
    open var welcomeLogoSize: CGSize = CGSize(width: 90, height: 90)
    open var logoViewVerticalGap: CGFloat = 145
    
    //
    // Auth Screen
    //
    
    open var authTintColor = UIColor(rgb: 0x1e0eb0)
    
    open var authTitleColor = UIColor.black.alpha(0.87)
    
    open var authHintColor = UIColor.alphaBlack(0.64)
    
    open var authTextColor = UIColor.alphaBlack(0.87)
    
    open var authSeparatorColor = UIColor.black.alpha(0.2)
    
    //
    // Settings VC
    //
    
    open var vcSettingsContactsHeaderTextColor: UIColor {
        get { return _vcSettingsContactsHeaderTextColor != nil ? _vcSettingsContactsHeaderTextColor! : vcTextColor }
        set(v) { _vcSettingsContactsHeaderTextColor = v }
    }
    fileprivate var _vcSettingsContactsHeaderTextColor : UIColor?
}




