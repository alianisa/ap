
class AAGrouppreCell: AATableViewCell {
    
    fileprivate let binder = AABinder()
    
    fileprivate var groupVm: ACGroupVM!
    fileprivate var groupPreVm: ACGroupPreVM!
    fileprivate var groupPre: ACGroupPre!
    
    fileprivate var title = YYLabel()
    fileprivate var titleMemberQuantity = YYLabel()
    fileprivate var avatarView = AAAvatarView()
    fileprivate var chevronView = UIImageView()
    fileprivate var groupTypeView = UIImageView()
    
    fileprivate var viewInitialized: Bool = false
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        title = YYLabel()
        title.autoresizingMask = UIViewAutoresizing.flexibleWidth
        title.font = UIFont.systemFont(ofSize: 17.0)
        title.textColor = UIColor.black
        title.backgroundColor = UIColor.white
        
        titleMemberQuantity = YYLabel()
        titleMemberQuantity.autoresizingMask = UIViewAutoresizing.flexibleWidth
        titleMemberQuantity.font = UIFont.systemFont(ofSize: 13.0)
        titleMemberQuantity.textColor = UIColor.black
        titleMemberQuantity.backgroundColor = UIColor.white
    
        self.contentView.addSubview(avatarView)
        self.contentView.addSubview(title)
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setGroupPre(groupPre:ACGroupPre){
        self.groupPre = groupPre;
        self.groupPreVm = Actor.getGroupPreVM(withLong: jlong(truncating: groupPre.groupId))
        self.groupVm = Actor.getGroupWithGid(jint(truncating: groupPre.groupId))
    }
    
    func exibirChevron(){
        let width = self.contentView.frame.width
        self.chevronView.image = UIImage.bundled("ic_chevron_right")
        self.chevronView.frame = CGRect(x: width - 40, y: (76/2)-(30/2), width: 30, height: 30)
        self.contentView.addSubview(self.chevronView)
    }
    
    func removerChevron(){
        self.chevronView.image = UIImage()
        self.chevronView.removeFromSuperview()
    }
    
    open override func prepareForReuse() {
        super.prepareForReuse()
        self.binder.unbindAll()
        self.avatarView.unbind()
    }
    
    func bindLayout(){
        binder.bind(groupVm.membersCount, valueModel2: groupVm.isMember, valueModel3: groupVm.name,
                    closure: { (membersCount:JavaLangInteger!, isMember:JavaLangBoolean?, groupName:String?)  -> () in
            
            self.title.text = groupName
                        
            var membersText = "\(jint(truncating: membersCount)) members"
            if let isM = isMember{
                if(isM.booleanValue()){
                    membersText += ", including you"
                }
            }
            self.titleMemberQuantity.text = membersText
        })
        
        binder.bind(groupPreVm.getHasChildren(), closure: {(hasChildren: JavaLangBoolean!) -> () in
            if let hc = hasChildren {
                if(hc.booleanValue()){
                    self.title.center.y = self.contentView.center.y
                    self.titleMemberQuantity.removeFromSuperview()
                    self.groupTypeView.center.y = self.contentView.center.y
                    self.exibirChevron()
                }else{
                    self.contentView.addSubview(self.titleMemberQuantity)
                    self.removerChevron()
                }
            }
        })
        
        self.avatarView.bind(groupVm.name.get(), id: Int(truncating: groupPre.groupId), avatar: groupVm.avatar.get());
    }
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        
        if(!self.viewInitialized){
            
            let width = self.contentView.frame.width
            let leftPadding = CGFloat(76)
            let padding = CGFloat(14)
            
            let avatarSize = CGFloat(50)
            let avatarPadding = padding + (50 - avatarSize) / 2
            self.avatarView.frame = CGRect(x: avatarPadding, y: avatarPadding, width: avatarSize, height: avatarSize)
            
            let titleFrame = CGRect(x: leftPadding, y: 16, width: width - leftPadding - (padding + 50), height: 21)
            self.title.frame = titleFrame

            let titleQuantityMembersFrame = CGRect(x: leftPadding, y: 16+21, width: width - leftPadding - (padding + 50), height: 21)
            self.titleMemberQuantity.frame = titleQuantityMembersFrame

            if(groupVm.groupType == ACGroupType.channel()){
                self.groupTypeView.image = UIImage.bundled("ic_channel")
            }else if(groupVm.groupType == ACGroupType.group()){
                self.groupTypeView.image = UIImage.bundled("ic_group")
            }
            self.groupTypeView.frame = CGRect(x: leftPadding, y: 16, width: 21, height: 21)
            self.contentView.addSubview(self.groupTypeView)
            
            self.title.left = self.title.left+20
            
            self.bindLayout()
        }
        
        self.viewInitialized = true
    }
}
