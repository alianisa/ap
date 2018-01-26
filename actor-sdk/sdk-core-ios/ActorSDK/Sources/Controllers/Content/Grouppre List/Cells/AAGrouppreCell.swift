
class AAGrouppreCell: AATableViewCell {
    
    fileprivate let binder = AABinder()
    
    fileprivate var groupVm: ACGroupVM!
    fileprivate var groupPreVm: ACGroupPreVM!
    fileprivate var groupPre: ACGroupPre!
    
    fileprivate var title: YYLabel!
    fileprivate var titleMemberQuantity: YYLabel!
    fileprivate var avatarView = AAAvatarView()
    fileprivate var chevronView: UIImageView!
    fileprivate var checkView: UIImageView!
    fileprivate var groupTypeView: UIImageView!
    
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
    
        contentView.addSubview(avatarView)
        contentView.addSubview(title)
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
        self.chevronView = UIImageView(image: #imageLiteral(resourceName: "ic_chevron_right"))
        self.chevronView.frame = CGRect(x: width - 40, y: (76/2)-(30/2), width: 30, height: 30)
        contentView.addSubview(self.chevronView)
    }
    
    func removerChevron(){
        if let v = self.chevronView{
            v.removeFromSuperview()
        }
    }
    
    func exibirCheck(){
        let width = self.contentView.frame.width
        self.checkView = UIImageView(image: #imageLiteral(resourceName: "ic_check_outline"))
        self.checkView.frame = CGRect(x: width - 40, y: (76/2)-(21/2), width: 21, height: 21)
        
        contentView.addSubview(self.checkView)
    }
    
    func removerCheck(){
        if let v = self.checkView {
            v.removeFromSuperview()
        }
    }
    
    open override func prepareForReuse() {
        super.prepareForReuse()
        binder.unbindAll()
    }
    
    func bindLayout(){
     
        binder.bind(groupVm.getMembersCountModel(), closure: { (qtdMembersCount:JavaLangInteger!) -> () in
            self.titleMemberQuantity.text = "\(jint(truncating: qtdMembersCount)) membros"
        })
        
    }
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        
        if(!self.viewInitialized){
            
            let width = self.contentView.frame.width
            let leftPadding = CGFloat(76)
            let padding = CGFloat(14)
            
            let titleFrame = CGRect(x: leftPadding+22, y: 16, width: width - leftPadding - (padding + 50), height: 21)

            UIView.performWithoutAnimation {
                self.title.frame = titleFrame
                if(groupPre != nil && groupPre.hasChildren.booleanValue()){
                    self.title.center.y = contentView.center.y
                }
            }
            
            if (groupPre.hasChildren.booleanValue()){
                let titleQuantityMembersFrame = CGRect(x: leftPadding, y: 16+21, width: width - leftPadding - (padding + 50), height: 21)
                UIView.performWithoutAnimation {
                    self.titleMemberQuantity.frame = titleQuantityMembersFrame
                    contentView.addSubview(self.titleMemberQuantity)
                }
            }
            
            if(groupVm.groupType == ACGroupType.channel()){
                let tipoGrupoFrame = CGRect(x: leftPadding, y: 16, width: 21, height: 21)
                self.groupTypeView = UIImageView(image: #imageLiteral(resourceName: "ic_create_channel"))
                self.groupTypeView.frame = tipoGrupoFrame
                
                if(groupPre.hasChildren.booleanValue()){
                    self.groupTypeView.center.y = contentView.center.y
                }
                contentView.addSubview(self.groupTypeView)
            }else if(groupVm.groupType == ACGroupType.group()){
                let tipoGrupoFrame = CGRect(x: leftPadding, y: 16, width: 21, height: 21)
                self.groupTypeView = UIImageView(image: #imageLiteral(resourceName: "ic_group"))
                self.groupTypeView.frame = tipoGrupoFrame
                
                if(groupPre.hasChildren.booleanValue()){
                    self.groupTypeView.center.y = contentView.center.y
                }
                contentView.addSubview(self.groupTypeView)
            }
           
            let dialogAvatarSize = CGFloat(50)
            let avatarPadding = padding + (50 - dialogAvatarSize) / 2
            self.avatarView.frame = CGRect(x: avatarPadding, y: avatarPadding, width: dialogAvatarSize, height: dialogAvatarSize)
            
            self.avatarView.bind(groupVm.name.get(), id: Int(truncating: groupPre.groupId), avatar: groupVm.avatar.get());
            
            self.title.text = groupVm.description
            
            if(groupPre.hasChildren.booleanValue()){
                exibirChevron()
            }else{
                removerChevron()
                if(groupVm.isMember.get().booleanValue()){
                    exibirCheck()
                }else{
                    removerChevron()
                }
            }
        }
        self.viewInitialized = true
    }
}
