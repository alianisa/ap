
class AAGrouppreCell: AATableViewCell {
    
    fileprivate var grupo: GrupoDomain!
    fileprivate var tipoGrupo: String!
    fileprivate var title: YYLabel!
    fileprivate var titleMemberQuantity: YYLabel!
    fileprivate var avatarView: UIImageView!
    fileprivate var avatarImageData:NSData!
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
        
        avatarView = UIImageView()
        
        contentView.addSubview(avatarView)
        contentView.addSubview(title)
        
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setGrupo(_ grupo:GrupoDomain){
        self.grupo = grupo
    }
    
    func setTipo(_ tipo:String){
        self.tipoGrupo = tipo
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
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        
        
        if(!self.viewInitialized){
            let width = self.contentView.frame.width
            let leftPadding = CGFloat(76)
            let padding = CGFloat(14)
            
            let titleFrame = CGRect(x: leftPadding+22, y: 16, width: width - leftPadding - (padding + 50), height: 21)
            
            UIView.performWithoutAnimation {
                self.title.frame = titleFrame
                if(grupo.possuiFilhos != nil && grupo.possuiFilhos!){
                    self.title.center.y = contentView.center.y
                }
            }
            
            if !(grupo.possuiFilhos!){
                let titleQuantityMembersFrame = CGRect(x: leftPadding, y: 16+21, width: width - leftPadding - (padding + 50), height: 21)
                UIView.performWithoutAnimation {
                    self.titleMemberQuantity.frame = titleQuantityMembersFrame
                    self.titleMemberQuantity.text = "\(jint(grupo.qtdMembros!)) membros"
                    contentView.addSubview(self.titleMemberQuantity)
                }
            }
            
            if(tipoGrupo == "C"){
                let tipoGrupoFrame = CGRect(x: leftPadding, y: 16, width: 21, height: 21)
                self.groupTypeView = UIImageView(image: #imageLiteral(resourceName: "ic_megaphone"))
                self.groupTypeView.frame = tipoGrupoFrame
                
                if(grupo.possuiFilhos)!{
                    self.groupTypeView.center.y = contentView.center.y
                }
                contentView.addSubview(self.groupTypeView)
            }else if (tipoGrupo == "G"){
                let tipoGrupoFrame = CGRect(x: leftPadding, y: 16, width: 21, height: 21)
                self.groupTypeView = UIImageView(image: #imageLiteral(resourceName: "ic_group"))
                self.groupTypeView.frame = tipoGrupoFrame
                
                if(grupo.possuiFilhos)!{
                    self.groupTypeView.center.y = contentView.center.y
                }
                contentView.addSubview(self.groupTypeView)
            }
            
            
            let dialogAvatarSize = CGFloat(50)
            let avatarPadding = padding + (50 - dialogAvatarSize) / 2
            self.avatarView.frame = CGRect(x: avatarPadding, y: avatarPadding, width: dialogAvatarSize, height: dialogAvatarSize)
            
            setTitle(grupo.title!)
            
            
            if let imageData = self.avatarImageData{
                setImageData(imageData)
            }else{
                setImageTitle(grupo.title!)
            }
            
            if(grupo.possuiFilhos)!{
                exibirChevron()
            }else{
                removerChevron()
                if(grupo.isMember)!{
                    exibirCheck()
                }else{
                    removerChevron()
                }
            }
        }
        self.viewInitialized = true
    }
    
    open func setTitle(_ title: String) {
        self.title.text = title
    }
    
    open func setImageTitle(_ title: String) {
        self.avatarView.setImageWith(title, color: nil, circular: true)
    }
    
    open func setImageData(_ data: NSData) {
        self.avatarImageData = data
        self.avatarView.image = UIImage(data: data as Data)
        self.avatarView.layer.cornerRadius = self.avatarView.frame.size.width / 2
        self.avatarView.clipsToBounds = true
    }
}
