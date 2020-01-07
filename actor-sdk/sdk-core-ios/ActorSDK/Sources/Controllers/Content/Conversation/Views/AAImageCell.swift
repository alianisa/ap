//
//  ImageCell.swift
//  ImagePickerTrayController
//
//  Created by Laurin Brandner on 15.10.16.
//  Copyright © 2016 Laurin Brandner. All rights reserved.
//

import UIKit
import Photos

class AAImageCell: UICollectionViewCell {
    
    let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.isUserInteractionEnabled = true
        imageView.clipsToBounds = true

        return imageView
    }()

    
    var animated            : Bool!
    var indexPath           : IndexPath!
    fileprivate let shadowView = UIImageView(image: UIImage(bundledName: "ImageCell-Shadow"))
    
    fileprivate let videoIndicatorView = UIImageView(image: UIImage(bundledName: "ImageCell-Video"))
    
    fileprivate let cloudIndicatorView = UIImageView(image: UIImage(bundledName: "ImageCell-Cloud"))
    
    fileprivate let checkmarkView = UIImageView(image: UIImage(bundledName: "ImageCell-Selected"))
    
    var isCheckSelected     : Bool!
    var bindedThumbView : AAThumbnailView!
    var bindedPhotoModel : PHAsset!
    let imgSelected         : UIImageView!
    
    var num:Int = 0{
        didSet{
            if num == 0{
//                numLabel.isHidden = true
                checkmarkView.isHidden = !isSelected
                self.bindedThumbView.removeSelectedModel(self.bindedPhotoModel,animated:self.animated)
                self.isCheckSelected = false

            }else{
//                numLabel.isHidden = false
//                numLabel.text = "\(num)"
//                playAnimate()
                self.bindedThumbView.addSelectedModel(self.bindedPhotoModel,animated:self.animated)
                self.isCheckSelected = true
            }
        }
    }
    
    var isVideo = false {
        didSet {
            reloadAccessoryViews()
        }
    }
    
    var isRemote = false {
        didSet {
            reloadAccessoryViews()
        }
    }
    
    override var isSelected: Bool {
        didSet {
            reloadCheckmarkView()

        }
    }
    
    // MARK: - Initialization
    
    override init(frame: CGRect) {
        
        self.imgSelected = UIImageView()
        self.imgSelected.backgroundColor = UIColor.clear
        self.imgSelected.isUserInteractionEnabled = true
        self.imgSelected.contentMode = UIView.ContentMode.scaleAspectFill
//        self.isCheckSelected = false
        self.animated        = false
        
        super.init(frame: frame)
        
        initialize()

        
//        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(AAImageCell.handleSingleTap))
//        tapRecognizer.cancelsTouchesInView = false
//        self.imgSelected.addGestureRecognizer(tapRecognizer)

    }
    
    required init?(coder aDecoder: NSCoder) {
//        super.init(coder: aDecoder)
        fatalError("init(coder:) has not been implemented")

        initialize()
        

    }

    
    fileprivate func initialize() {
        contentView.addSubview(imageView)
        contentView.addSubview(shadowView)
        contentView.addSubview(videoIndicatorView)
        contentView.addSubview(cloudIndicatorView)
        contentView.addSubview(checkmarkView)
        contentView.addSubview(imgSelected)
        reloadAccessoryViews()
        reloadCheckmarkView()
//        checkmarkView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(AAImageCell.handleSingleTap)))
//        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(AAImageCell.handleSingleTap))
//        tapGesture.cancelsTouchesInView = false
//        self.checkmarkView.addGestureRecognizer(tapGesture)
    }
    
    // MARK: - Other Methods
    
    fileprivate func reloadAccessoryViews() {
        videoIndicatorView.isHidden = !isVideo
        cloudIndicatorView.isHidden = !isRemote
        shadowView.isHidden = videoIndicatorView.isHidden && cloudIndicatorView.isHidden
    }
    
    fileprivate func reloadCheckmarkView() {
        checkmarkView.isHidden = !isSelected

//        if !isSelected {
//            self.isCheckSelected = false
//        } else {
//        }
//        if checkmarkView.isHidden {
//            if self.bindedPhotoModel == nil {
//
//            } else {
//                self.isCheckSelected = false
//                self.bindedThumbView.removeSelectedModel(self.bindedPhotoModel, animated: true)
//            }
//        }
        

    }
    
    @objc func handleSingleTap() {
        
        if (self.isCheckSelected == false) {
            
////            print(animated)
//            let selectedAssets = AAThumbnailView()
//            if selectedAssets.selectedAssets.count == 0 {
//                self.bindedThumbView.addSelectedModel(self.bindedPhotoModel,animated:self.animated)
//                self.isCheckSelected = true
//            }

        } else {
//            if isSelected {
                self.bindedThumbView.removeSelectedModel(self.bindedPhotoModel,animated:self.animated)
                self.isCheckSelected = false
//            }
        }
        
    }
        
    override func prepareForReuse() {
        super.prepareForReuse()
//        let thv = AAThumbnailView()
//        thv.reloadView()
//        imageView.image = nil
        isVideo = false
        isRemote = false
    }
    
    // MARK: - Layout
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        imageView.frame = bounds
        let inset: CGFloat = 8
        
        let shadowHeight = shadowView.image?.size.height ?? 0
        shadowView.frame = CGRect(origin: CGPoint(x: bounds.minX, y: bounds.maxY-shadowHeight), size: CGSize(width: bounds.width, height: shadowHeight))
        
        let videoIndicatorViewSize = videoIndicatorView.image?.size ?? .zero
        let videoIndicatorViewOrigin = CGPoint(x: bounds.minX + inset, y: bounds.maxY - inset - videoIndicatorViewSize.height)
        videoIndicatorView.frame = CGRect(origin: videoIndicatorViewOrigin, size: videoIndicatorViewSize)
        
        let cloudIndicatorViewSize = cloudIndicatorView.image?.size ?? .zero
        let cloudIndicatorViewOrigin = CGPoint(x: bounds.maxX - inset - cloudIndicatorViewSize.width, y: bounds.maxY - inset - cloudIndicatorViewSize.height)
        cloudIndicatorView.frame = CGRect(origin: cloudIndicatorViewOrigin, size: cloudIndicatorViewSize)
        
        let checkmarkSize = checkmarkView.frame.size
        checkmarkView.center = CGPoint(x: bounds.maxX-checkmarkSize.width/2-4, y: bounds.maxY-checkmarkSize.height/2-4)
//        checkmarkView.isUserInteractionEnabled = true
//        let imgSelected = self.imgSelected.frame.size
//        self.imgSelected.frame = bounds
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(AAImageCell.handleSingleTap))
        tapRecognizer.cancelsTouchesInView = false
        if !isSelected  {
            print(checkmarkView.isHidden)
            self.imageView.addGestureRecognizer(tapRecognizer)
        }
    }
    
}

