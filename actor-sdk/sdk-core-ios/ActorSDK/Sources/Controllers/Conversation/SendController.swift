//
//  SendController.swift
//  ActorSDK
//
//  Created by dingjinming on 2018/1/4.
//  Copyright © 2018年 Steve Kite. All rights reserved.
//
import UIKit
//转发view
class SendController: AADialogsListContentController, AADialogsListContentControllerDelegate {
    func recentsDidTap(_ controller: AADialogsListContentController, dialog: ACDialog) -> Bool {
        Actor.forwardContentContent(with: dialog.peer, with: message.content)
        back()
        return true
    }
    
    func searchDidTap(_ controller: AADialogsListContentController, entity: ACSearchResult) {
        Actor.forwardContentContent(with: entity.peer, with: message.content)
        back()
    }
    
    var message = ACMessage()
    
    public override init(){
        super.init()
        content = ACAllEvents_Main.recent()
        self.delegate = self
    }
    
    public required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc func back(){
        self.navigateBack()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Переслать"
        view.backgroundColor = .white
        
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Назад", style: .plain, target: self, action: #selector(back))
    }
}
