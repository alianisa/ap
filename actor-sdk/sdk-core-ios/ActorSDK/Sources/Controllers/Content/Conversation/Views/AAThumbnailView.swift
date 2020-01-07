import UIKit
import Photos

//public enum ImagePickerMediaType {
//    case image
//    case video
//    case imageAndVideo
//}

public protocol AAThumbnailViewDelegate {
    func thumbnailSelectedUpdated(_ selectedAssets: [(PHAsset,Bool)])
}


open class AAThumbnailView: UIView,UICollectionViewDelegate , UICollectionViewDataSource {
    
    open var delegate : AAThumbnailViewDelegate?
    
    fileprivate var collectionView:UICollectionView!
    fileprivate let mediaType: ImagePickerMediaType = ImagePickerMediaType.image
    
    fileprivate let itemSpacing: CGFloat = 1
    
    fileprivate var imageManager = PHCachingImageManager()
//    fileprivate var assets = [PHAsset]()
    fileprivate lazy var requestOptions: PHImageRequestOptions = {
        let options = PHImageRequestOptions()
        options.deliveryMode = .highQualityFormat
        options.resizeMode = .fast
        
        return options
    }()
    
    fileprivate var assets = [(PHAsset,Bool)]()
    var selectedAssets = [(PHAsset, Bool)]()
    var assetsFetchResults: PHFetchResult<PHAsset>!
    var maxSelected:Int = Int.max

//    fileprivate var imageManager : PHCachingImageManager!
    
//    fileprivate let minimumPreviewHeight: CGFloat = 90
//    fileprivate var maximumPreviewHeight: CGFloat = 90
//
//    fileprivate let previewCollectionViewInset: CGFloat = 5
    
//    fileprivate lazy var requestOptions: PHImageRequestOptions = {
//        let options = PHImageRequestOptions()
//        options.deliveryMode = .highQualityFormat
//        options.resizeMode = .fast
//
//        return options
//    }()
    
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.collectionViewSetup()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    ///
    
    open func open() {
        
        dispatchBackground { () -> Void in
            
            if PHPhotoLibrary.authorizationStatus() == .authorized {
                self.imageManager = PHCachingImageManager()
                self.fetchAssets()
                DispatchQueue.main.async {
                    self.collectionView.reloadData()
                }
                
            } else if PHPhotoLibrary.authorizationStatus() == .notDetermined {
                
                PHPhotoLibrary.requestAuthorization() { status in
                    if status == .authorized {
                        DispatchQueue.main.async {
                            self.imageManager = PHCachingImageManager()
                            self.fetchAssets()
                            self.collectionView.reloadData()
                        }
                    }
                }
                
            }
            
        }
        
    }
    
//    fileprivate func fetchAssets() {
//        self.assets = [(PHAsset,Bool)]()
//
//        let options = PHFetchOptions()
//        options.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
//
//        switch mediaType {
//        case .image:
//            options.predicate = NSPredicate(format: "mediaType = %d", PHAssetMediaType.image.rawValue)
//        case .video:
//            options.predicate = NSPredicate(format: "mediaType = %d", PHAssetMediaType.video.rawValue)
//        case .imageAndVideo:
//            options.predicate = NSPredicate(format: "mediaType = %d OR mediaType = %d", PHAssetMediaType.image.rawValue, PHAssetMediaType.video.rawValue)
//        }
//
//        options.predicate = NSPredicate(format: "mediaType = %d", PHAssetMediaType.image.rawValue)
//
//        let fetchLimit = 100
//        if #available(iOS 9, *) {
//            options.fetchLimit = fetchLimit
//        }
//
//        let result = PHAsset.fetchAssets(with: options)
//        let requestOptions = PHImageRequestOptions()
//        requestOptions.isSynchronous = true
//        requestOptions.deliveryMode = .fastFormat
//
//        result.enumerateObjects ({ asset, _, stop in
//
//            if self.assets.count > fetchLimit {
//                stop.initialize(to: true)
//            }
//
//            if let asset = asset as? PHAsset {
//                var isGIF = false
//                self.imageManager.requestImageData(for: asset, options: requestOptions) { data, _, _, info in
//                    if data != nil {
//                        let gifMarker = info!["PHImageFileURLKey"] as! URL
//                        print(gifMarker.pathExtension)
//                        isGIF = (gifMarker.pathExtension == "GIF") ? true : false
//                        print(isGIF)
//                        self.prefetchImagesForAsset(asset)
//                    }
//                    self.assets.append((asset,isGIF))
//                }
//            }
//        })
//    }
    
//    fileprivate func prefetchImagesForAsset(_ asset: PHAsset) {
//        let targetSize = sizeForAsset(asset, scale: UIScreen.main.scale)
//        imageManager.startCachingImages(for: [asset], targetSize: targetSize, contentMode: .aspectFill, options: requestOptions)
//    }
    
//    fileprivate func requestImageForAsset(_ asset: PHAsset, completion: @escaping (_ image: UIImage?) -> ()) {
//        let targetSize = sizeForAsset(asset, scale: UIScreen.main.scale)
//        requestOptions.isSynchronous = false
//
//        // Workaround because PHImageManager.requestImageForAsset doesn't work for burst images
//        if asset.representsBurst {
//            imageManager.requestImageData(for: asset, options: requestOptions) { data, _, _, _ in
//                let image = data.flatMap { UIImage(data: $0) }
//                completion(image)
//            }
//        }
//        else {
//            imageManager.requestImage(for: asset, targetSize: targetSize, contentMode: .aspectFill, options: requestOptions) { image, _ in
//                completion(image)
//            }
//        }
//    }
    
    
//    fileprivate func sizeForAsset(_ asset: PHAsset, scale: CGFloat = 1) -> CGSize {
//
//        var complitedCGSize : CGSize!
//
//        if asset.pixelWidth > asset.pixelHeight {
//            complitedCGSize = CGSize(width: CGFloat(asset.pixelHeight),height: CGFloat(asset.pixelHeight))
//        } else {
//            complitedCGSize = CGSize(width: CGFloat(asset.pixelWidth),height: CGFloat(asset.pixelWidth))
//        }
//
//        return complitedCGSize
//    }
    
    /// collection view delegate
    
    fileprivate var imageSize: CGSize = .zero
    
    fileprivate func prepareAssets() {
        fetchAssets()
    }
    
    fileprivate func fetchAssets() {
        let options = PHFetchOptions()
        options.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
//        let fetchLimit = 100
        options.fetchLimit = 100
        
        let result = PHAsset.fetchAssets(with: options)
//        result.enumerateObjects({ asset, index, stop in
//            self.assets.append(asset)
//        })
        result.enumerateObjects ({ asset, _, stop in
            
//            if self.assets.count > fetchLimit {
//                stop.initialize(to: true)
//            }
//
//            if let asset = asset as? PHAsset {
                var isGIF = false
//                self.imageManager.requestImageData(for: asset, options: self.requestOptions) { data, _, _, info in
//                    if data != nil {
//                        let gifMarker = info!["PHImageFileURLKey"] as! URL
//                        print(gifMarker.pathExtension)
//                        isGIF = (gifMarker.pathExtension == "GIF") ? true : false
//                        print(isGIF)
//                        self.prefetchImages(for: asset)
//                    }
                    self.assets.append((asset,isGIF))
//                }
            
//            }
        })
    }
    
    fileprivate func requestImage(for asset: PHAsset, completion: @escaping (_ image: UIImage?) -> ()) {
        requestOptions.isSynchronous = true
        let size = scale(imageSize: imageSize)
        
        // Workaround because PHImageManager.requestImageForAsset doesn't work for burst images
        if asset.representsBurst {
            imageManager.requestImageData(for: asset, options: requestOptions) { data, _, _, _ in
                let image = data.flatMap { UIImage(data: $0) }
                completion(image)
            }
        }
        else {
            imageManager.requestImage(for: asset, targetSize: size, contentMode: .aspectFill, options: requestOptions) { image, _ in
                completion(image)
            }
        }
    }
    
    fileprivate func prefetchImages(for asset: PHAsset) {
        let size = scale(imageSize: imageSize)
        imageManager.startCachingImages(for: [asset], targetSize: size, contentMode: .aspectFill, options: requestOptions)
    }
    
    fileprivate func scale(imageSize size: CGSize) -> CGSize {
        let scale = UIScreen.main.scale
        return CGSize(width: size.width * scale, height: size.height * scale)
    }
    
    @objc public func convertToImage(asset: PHAsset, callback: @escaping (UIImage?, [AnyHashable: Any]?)->()) {
        let manager = PHImageManager()
        
        let options = PHImageRequestOptions()
        options.resizeMode = .fast
        options.deliveryMode = .fastFormat
        options.isSynchronous = true
        
        manager.requestImage(for: asset, targetSize: PHImageManagerMaximumSize, contentMode: PHImageContentMode.default, options: options) { (image, info) in
            callback(image, info)
        }
    }
    
    open func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    open func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.assets.count
    }
    
    open func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
//        let cell = self.collectionView.dequeueReusableCell(withReuseIdentifier: "AAThumbnailCollectionCell", for: indexPath) as! AAThumbnailCollectionCell
        
        let cell = self.collectionView.dequeueReusableCell(withReuseIdentifier: NSStringFromClass(AAImageCell.self), for: indexPath) as! AAImageCell

        cell.bindedThumbView = self
//        
        let photoModel = self.assets[(indexPath as NSIndexPath).row].0
        let animated = self.assets[(indexPath as NSIndexPath).row].1
//
        cell.bindedPhotoModel = photoModel
        
        cell.imageView.layer.setValue(indexPath.row, forKey: "index")
//        cell.isSelected = true
//
//        if self.selectedAssets.contains(photoModel) {
//            cell.isCheckSelected = true
//            cell.imgSelected.image = UIImage.bundled("ImageSelectedOn")
//            cell.isSelected = true
////
//        } else {
//            cell.isCheckSelected = false
//            cell.imgSelected.image = UIImage.bundled("ImageSelectedOff")
//            cell.isSelected = false
//        }
        
//        if arr_selected.contains(indexPath.row){
//            cell.isSelected = true
//        }else{
//            cell.isSelected = false
//        }
        
//        cell.backgroundColor = UIColor.white
        
//        let asset = assets[(indexPath as NSIndexPath).row].0
//
//        requestImage(for: asset) { image in
//
//            var complitedImage : UIImage!
//
//            if image!.size.width > image!.size.height {
//                complitedImage = self.imageByCroppingImage(image!, toSize: CGSize(width: image!.size.height,height: image!.size.height))
//            } else {
//                complitedImage = self.imageByCroppingImage(image!, toSize: CGSize(width: image!.size.width,height: image!.size.width))
//            }
//
//            cell.imgThumbnails.image = complitedImage
//            cell.animated = animated
//
//        }
        
//        let asset = assets[indexPath.item]
        let asset = assets[(indexPath as NSIndexPath).row].0
//        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: NSStringFromClass(AAImageCell.self), for: indexPath) as! AAImageCell
//        cell.isVideo = (asset.mediaType == .video)
//        cell.isRemote = (asset.sourceType != .typeUserLibrary)
//        requestImage(for: asset) { cell.imageView.image = $0 }
        requestImage(for: asset) {
            cell.imageView.image = $0
            cell.animated = animated
            
        }

        return cell
    }
    
    open func selectedCount() -> Int {
        return self.collectionView.indexPathsForSelectedItems?.count ?? 0
    }
    
    
    open func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let cell = collectionView.cellForItem(at: indexPath) as? AAImageCell {
//            let cell = self.collectionView.dequeueReusableCell(withReuseIdentifier: NSStringFromClass(AAImageCell.self), for: indexPath) as! AAImageCell

            let count = self.selectedCount()
            if count > self.maxSelected {
                collectionView.deselectItem(at: indexPath, animated: false)

            }
            else{
                cell.num = count
//                completeButton.num = count
                if count > 0 && !cell.isSelected{
//                    cell.isSelected = true
                    self.delegate?.thumbnailSelectedUpdated(self.selectedAssets)
                    cell.isCheckSelected = true
                }
//                cell.playAnimate()
            }
        }
    }
    
    open func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        if let cell = collectionView.cellForItem(at: indexPath) as? AAImageCell {
            let count = self.selectedCount()
            cell.num = count
            let photoModel = self.assets[(indexPath as NSIndexPath).row].0
            cell.bindedPhotoModel = photoModel
            if count == 0{
//                cell.isSelected = false
                if self.selectedAssets.contains(photoModel) {
                    cell.isCheckSelected = true
//                    cell.imgSelected.image = UIImage.bundled("ImageSelectedOn")
//                    cell.isSelected = true
                    //
                } else {
                    cell.isCheckSelected = false
//                    cell.imgSelected.image = UIImage.bundled("ImageSelectedOff")
//                    cell.isSelected = false
                }

            }
            cell.bindedThumbView.removeSelectedModel(cell.bindedPhotoModel,animated:false)

        }
    }
    
    open func addSelectedModel(_ model:PHAsset, animated:Bool) {
        //        if self.selectedAssets.count == 0 {
        self.selectedAssets.append((model,animated))
        //        for (index, element) in self.selectedAssets.enumerated() {
        //            if element.0 == model {
        //                if index == index {
        self.delegate?.thumbnailSelectedUpdated(self.selectedAssets)
        
        //                }
        //            }
        //        }
        //        }
    }
    
    //    open func index(formSelect assets: PHAsset,animated:Bool) -> Int? {
    //        return self.selectedAssets.index(of: assets,animated)
    //    }
    
    open func removeSelectedModel(_ model:PHAsset,animated:Bool) {
        for (index, element) in self.selectedAssets.enumerated() {
            if element.0 == model {
                self.selectedAssets.wcl_removeSafe(at: index)
            }
        }

        self.delegate?.thumbnailSelectedUpdated(self.selectedAssets)
    }
    
    
    open func reloadView() {
        self.collectionView.reloadData()
    }
    
    open func collectionViewSetup() {
        
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.scrollDirection = .horizontal
//        flowLayout.minimumLineSpacing = 1
        flowLayout.sectionInset = UIEdgeInsets(top: 1, left: 0, bottom: 2, right: 1)
//        flowLayout.itemSize = CGSize(width: 90, height: 90)
        flowLayout.minimumInteritemSpacing = 1
        flowLayout.minimumLineSpacing = 1
        
        
//        self.collectionView = UICollectionView(frame: self.bounds, collectionViewLayout: flowLayout)
//        self.collectionView.backgroundColor = UIColor.clear
//        self.collectionView.showsHorizontalScrollIndicator = false
//        self.collectionView.delegate = self
//        self.collectionView.dataSource = self
//        self.collectionView.register(AAThumbnailCollectionCell.self, forCellWithReuseIdentifier: "AAThumbnailCollectionCell")
        
        self.collectionView = UICollectionView(frame: self.bounds, collectionViewLayout: flowLayout)
        self.collectionView.contentInset = UIEdgeInsets(top: 1, left: 0, bottom: 2, right: 1)
        self.collectionView.translatesAutoresizingMaskIntoConstraints = false
        self.collectionView.backgroundColor = UIColor.clear
        self.collectionView.dataSource = self
        self.collectionView.delegate = self
        self.collectionView.showsHorizontalScrollIndicator = false
        self.collectionView.alwaysBounceHorizontal = true
//        self.collectionView.heightAnchor.constraint(equalToConstant: 216).isActive = true
//        self.collectionView.leftAnchor.constraint(equalTo: self.leftAnchor).isActive = true
//        self.collectionView.rightAnchor.constraint(equalTo: self.rightAnchor).isActive = true
//        self.collectionView.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        self.collectionView.allowsMultipleSelection = true
        self.collectionView.allowsSelection = true
        self.collectionView.register(AAThumbnailCollectionCell.self, forCellWithReuseIdentifier: "AAThumbnailCollectionCell")
        self.collectionView.register(AAImageCell.self, forCellWithReuseIdentifier: NSStringFromClass(AAImageCell.self))

        let collectionViewWidth = collectionView.frame.size.width
        let numberOfRows = (UIDevice.current.userInterfaceIdiom == .pad) ? 4 : 4
        let totalItemSpacing = CGFloat(numberOfRows-1)*itemSpacing + collectionView.contentInset.vertical
        let side = round((collectionViewWidth-totalItemSpacing)/CGFloat(numberOfRows))
        self.imageSize = CGSize(width: side, height: side)
        flowLayout.itemSize = self.imageSize
        self.addSubview(self.collectionView)
        self.collectionView.reloadData()
    }
    
//    open func imageByCroppingImage(_ image:UIImage,toSize:CGSize) -> UIImage {
//
//        let refWidth = image.cgImage?.width
//        let refHeight = image.cgImage?.height
//
//        let x = CGFloat((refWidth! - Int(toSize.width)) / 2)
//        let y = CGFloat((refHeight! - Int(toSize.height)) / 2)
//
//        let cropRect = CGRect(x: x, y: y, width: toSize.height, height: toSize.width)
//        let imageRef = (image.cgImage?.cropping(to: cropRect)!)! as CGImage
//
//        let cropped = UIImage(cgImage: imageRef, scale: 0.0, orientation: UIImageOrientation.up)
//
//        return cropped
//    }
    
    
    
    open func getSelectedAsImages(_ completion: @escaping (_ images:[(Data,Bool)]) -> ()) {
        
        let arrayModelsForSend = self.selectedAssets
        
        var compliedArray = [(Data,Bool)]()
        var isGif = false
        for (_,model) in arrayModelsForSend.enumerated() {
            self.imageManager.requestImageData(for: model.0, options: requestOptions, resultHandler: { (data, _, _, info) -> Void in
                if data != nil {
                    let gifMarker = info!["PHImageFileURLKey"] as! URL
                    isGif = (gifMarker.pathExtension == "GIF") ? true : false
                    print(isGif)
                    compliedArray.append((data!,isGif))
                    if compliedArray.count == arrayModelsForSend.count {
                        completion(compliedArray)
                    }
                }
            })
        }
    }
    
    open func dismiss() {
        self.selectedAssets = []
        self.reloadView()
    }
}

//public enum PickerMediaType {
//    case image
//    case video
//    case imageAndVideo
//}
//
//public protocol AAThumbnailViewDelegate {
//    func thumbnailSelectedUpdated(_ selectedAssets: [(PHAsset,Bool)])
//}
//
//open class AAThumbnailView: UIView,UICollectionViewDelegate , UICollectionViewDataSource {
//
//    open var delegate : AAThumbnailViewDelegate?
//
//    fileprivate var collectionView:UICollectionView!
//    fileprivate let mediaType: PickerMediaType = PickerMediaType.image
//
//    fileprivate var assets = [(PHAsset,Bool)]()
//    fileprivate var selectedAssets = [(PHAsset, Bool)]()
//    fileprivate var imageManager : PHCachingImageManager!
//
//    fileprivate let minimumPreviewHeight: CGFloat = 90
//    fileprivate var maximumPreviewHeight: CGFloat = 90
//
//    fileprivate let previewCollectionViewInset: CGFloat = 5
//
//    private let enlargementAnimationDuration = 0.3
//    private let tableViewRowHeight: CGFloat = 50.0
//    private let tableViewPreviewRowHeight: CGFloat = 140.0
//    private let tableViewEnlargedPreviewRowHeight: CGFloat = 243.0
//    private let collectionViewInset: CGFloat = 5.0
//
//
//    fileprivate lazy var requestOptions: PHImageRequestOptions = {
//        let options = PHImageRequestOptions()
//        options.deliveryMode = .highQualityFormat
//        options.resizeMode = .fast
//
//        return options
//    }()
//
//
//    public override init(frame: CGRect) {
//        super.init(frame: frame)
//
//        self.collectionViewSetup()
//    }
//
//    public required init?(coder aDecoder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
//
//    ///
//
//    open func open() {
//
//        dispatchBackground { () -> Void in
//
//            if PHPhotoLibrary.authorizationStatus() == .authorized {
//                self.imageManager = PHCachingImageManager()
//                self.fetchAssets()
//                DispatchQueue.main.async {
//                    self.collectionView.reloadData()
//                }
//
//            } else if PHPhotoLibrary.authorizationStatus() == .notDetermined {
//
//                PHPhotoLibrary.requestAuthorization() { status in
//                    if status == .authorized {
//                        DispatchQueue.main.async {
//                            self.imageManager = PHCachingImageManager()
//                            self.fetchAssets()
//                            self.collectionView.reloadData()
//                        }
//                    }
//                }
//
//            }
//
//        }
//
//    }
//
//    fileprivate func fetchAssets() {
//        self.assets = [(PHAsset,Bool)]()
//
//        let options = PHFetchOptions()
//        options.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
//
//        switch mediaType {
//        case .image:
//            options.predicate = NSPredicate(format: "mediaType = %d", PHAssetMediaType.image.rawValue)
//        case .video:
//            options.predicate = NSPredicate(format: "mediaType = %d", PHAssetMediaType.video.rawValue)
//        case .imageAndVideo:
//            options.predicate = NSPredicate(format: "mediaType = %d OR mediaType = %d", PHAssetMediaType.image.rawValue, PHAssetMediaType.video.rawValue)
//        }
//
//        options.predicate = NSPredicate(format: "mediaType = %d", PHAssetMediaType.image.rawValue)
//
//        let fetchLimit = 500
//        if #available(iOS 9, *) {
//            options.fetchLimit = fetchLimit
//        }
//
//        let result = PHAsset.fetchAssets(with: options)
//        let requestOptions = PHImageRequestOptions()
//        requestOptions.isSynchronous = true
//        requestOptions.deliveryMode = .fastFormat
//
//        result.enumerateObjects ({ asset, _, stop in
//
//            if self.assets.count > fetchLimit {
//                stop.initialize(to: true)
//            }
//
//            if let asset = asset as? PHAsset {
//                var isGIF = false
//                self.imageManager.requestImageData(for: asset, options: requestOptions) { data, _, _, info in
//                    if data != nil {
//                        let gifMarker = info!["PHImageFileURLKey"] as! URL
//                        print(gifMarker.pathExtension)
//                        isGIF = (gifMarker.pathExtension == "GIF") ? true : false
//                        print(isGIF)
//                        let size = self.sizeForAsset(asset)
//                        self.prefetchImagesForAsset(asset, size: size)
//                    }
//                    self.assets.append((asset,isGIF))
//                }
//            }
//        })
//    }
//
////    fileprivate func prefetchImagesForAsset(_ asset: PHAsset) {
////        let targetSize = sizeForAsset(asset, scale: UIScreen.main.scale)
////        imageManager.startCachingImages(for: [asset], targetSize: targetSize, contentMode: .aspectFill, options: requestOptions)
////    }
////
////    fileprivate func requestImageForAsset(_ asset: PHAsset, completion: @escaping (_ image: UIImage?) -> ()) {
////        let targetSize = sizeForAsset(asset, scale: UIScreen.main.scale)
////        requestOptions.isSynchronous = false
////
////        // Workaround because PHImageManager.requestImageForAsset doesn't work for burst images
////        if asset.representsBurst {
////            imageManager.requestImageData(for: asset, options: requestOptions) { data, _, _, _ in
////                let image = data.flatMap { UIImage(data: $0) }
////                completion(image)
////            }
////        }
////        else {
////            imageManager.requestImage(for: asset, targetSize: targetSize, contentMode: .aspectFill, options: requestOptions) { image, _ in
////                completion(image)
////            }
////        }
////    }
////
////    fileprivate func sizeForAsset(_ asset: PHAsset, scale: CGFloat = 1) -> CGSize {
////
////        var complitedCGSize : CGSize!
////
////        if asset.pixelWidth > asset.pixelHeight {
////            complitedCGSize = CGSize(width: CGFloat(asset.pixelHeight),height: CGFloat(asset.pixelHeight))
////        } else {
////            complitedCGSize = CGSize(width: CGFloat(asset.pixelWidth),height: CGFloat(asset.pixelWidth))
////        }
////
////        return complitedCGSize
////    }
//
//    private func prefetchImagesForAsset(_ asset: PHAsset, size: CGSize) {
//        // Not necessary to cache image because PHImageManager won't return burst images
//        if !asset.representsBurst {
//            let targetSize = targetSizeForAssetOfSize(size)
//            imageManager.startCachingImages(for: [asset], targetSize: targetSize, contentMode: .aspectFill, options: nil)
//        }
//    }
//
//    fileprivate func requestImageForAsset(_ asset: PHAsset, size: CGSize? = nil, deliveryMode: PHImageRequestOptionsDeliveryMode = .opportunistic, completion: @escaping (_ image: UIImage?) -> Void) {
//        var targetSize = PHImageManagerMaximumSize
//        if let size = size {
//            targetSize = targetSizeForAssetOfSize(size)
//        }
//
//        let options = PHImageRequestOptions()
//        options.deliveryMode = deliveryMode;
//
//        // Workaround because PHImageManager.requestImageForAsset doesn't work for burst images
//        if asset.representsBurst {
//            imageManager.requestImageData(for: asset, options: options) { data, _, _, _ in
//                let image = UIImage(data: data!)
//                completion(image)
//            }
//        }
//        else {
//            imageManager.requestImage(for: asset, targetSize: targetSize, contentMode: .aspectFill, options: options) { image, _ in
//                completion(image)
//            }
//        }
//    }
//
//    fileprivate(set) var enlargedPreviews = false
//
//    fileprivate func sizeForAsset(_ asset: PHAsset) -> CGSize {
//        let proportion = CGFloat(asset.pixelWidth)/CGFloat(asset.pixelHeight)
//
//        let height: CGFloat = {
//            let rowHeight = self.enlargedPreviews ? tableViewEnlargedPreviewRowHeight : tableViewPreviewRowHeight
//            return rowHeight-2.0*collectionViewInset
//        }()
//
//        return CGSize(width: CGFloat(floorf(Float(proportion*height))), height: height)
//    }
//
//    fileprivate func targetSizeForAssetOfSize(_ size: CGSize) -> CGSize {
//        let scale = UIScreen.main.scale
//        return CGSize(width: scale*size.width, height: scale*size.height)
//    }
//
//    /// collection view delegate
//
//    open func numberOfSections(in collectionView: UICollectionView) -> Int {
//        return 1
//    }
//
//    open func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
//        return self.assets.count
//    }
//
//    open func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
//
//        let cell = self.collectionView.dequeueReusableCell(withReuseIdentifier: "AAThumbnailCollectionCell", for: indexPath) as! AAThumbnailCollectionCell
//
//        cell.bindedThumbView = self
//
//        let photoModel = self.assets[(indexPath as NSIndexPath).row].0
//        let animated = self.assets[(indexPath as NSIndexPath).row].1
//
//        cell.bindedPhotoModel = photoModel
//
//        if self.selectedAssets.contains(photoModel) {
//            cell.isCheckSelected = true
//            cell.imgSelected.image = UIImage.bundled("ImageSelectedOn")
//
//        } else {
//            cell.isCheckSelected = false
//            cell.imgSelected.image = UIImage.bundled("ImageSelectedOff")
//        }
//
//        cell.backgroundColor = UIColor.white
//
//        let asset = assets[(indexPath as NSIndexPath).row].0
//
//        let size = sizeForAsset(asset)
//
//        requestImageForAsset(asset, size: size) { image in
//            cell.imgThumbnails.image = image
//            cell.animated = animated
//
//        }
//
////        requestImageForAsset(asset) { image in
////
////            var complitedImage : UIImage!
////
////            if image!.size.width > image!.size.height {
////                complitedImage = self.imageByCroppingImage(image!, toSize: CGSize(width: image!.size.height,height: image!.size.height))
////            } else {
////                complitedImage = self.imageByCroppingImage(image!, toSize: CGSize(width: image!.size.width,height: image!.size.width))
////            }
////
////            cell.imgThumbnails.image = complitedImage
////            cell.animated = animated
////
////        }
//
//
//        return cell
//    }
//
//    ///
//
//    open func reloadView() {
//        self.collectionView.reloadData()
//    }
//
//    open func collectionViewSetup() {
//
//        let flowLayout = UICollectionViewFlowLayout()
//        flowLayout.scrollDirection = .horizontal
//        flowLayout.minimumLineSpacing = 4
//        flowLayout.sectionInset = UIEdgeInsetsMake(5.0, 4.0, 5.0, 4.0)
//        flowLayout.itemSize = CGSize(width: 90, height: 90)
//
//        self.collectionView = UICollectionView(frame: self.bounds, collectionViewLayout: flowLayout)
//        self.collectionView.backgroundColor = UIColor.clear
//        self.collectionView.showsHorizontalScrollIndicator = false
//        self.collectionView.delegate = self
//        self.collectionView.dataSource = self
//        self.collectionView.register(AAThumbnailCollectionCell.self, forCellWithReuseIdentifier: "AAThumbnailCollectionCell")
//        self.addSubview(self.collectionView)
//    }
//
//    open func imageByCroppingImage(_ image:UIImage,toSize:CGSize) -> UIImage {
//
//        let refWidth = image.cgImage?.width
//        let refHeight = image.cgImage?.height
//
//        let x = CGFloat((refWidth! - Int(toSize.width)) / 2)
//        let y = CGFloat((refHeight! - Int(toSize.height)) / 2)
//
//        let cropRect = CGRect(x: x, y: y, width: toSize.height, height: toSize.width)
//        let imageRef = (image.cgImage?.cropping(to: cropRect)!)! as CGImage
//
//        let cropped = UIImage(cgImage: imageRef, scale: 0.0, orientation: UIImageOrientation.up)
//
//        return cropped
//    }
//
//    open func addSelectedModel(_ model:PHAsset, animated:Bool) {
//        self.selectedAssets.append((model,animated))
//        self.delegate?.thumbnailSelectedUpdated(self.selectedAssets)
//    }
//
//    open func removeSelectedModel(_ model:PHAsset,animated:Bool) {
//        for (index, element) in self.selectedAssets.enumerated() {
//            if element.0 == model {
//                self.selectedAssets.remove(at: index)
//            }
//        }
//        self.delegate?.thumbnailSelectedUpdated(self.selectedAssets)
//    }
//
//    open func getSelectedAsImages(_ completion: @escaping (_ images:[(Data,Bool)]) -> ()) {
//
//        let arrayModelsForSend = self.selectedAssets
//
//        var compliedArray = [(Data,Bool)]()
//        var isGif = false
//        for (_,model) in arrayModelsForSend.enumerated() {
//            self.imageManager.requestImageData(for: model.0, options: requestOptions, resultHandler: { (data, _, _, info) -> Void in
//                if data != nil {
//                    let gifMarker = info!["PHImageFileURLKey"] as! URL
//                    isGif = (gifMarker.pathExtension == "GIF") ? true : false
//                    print(isGif)
//                    compliedArray.append((data!,isGif))
//                    if compliedArray.count == arrayModelsForSend.count {
//                        completion(compliedArray)
//                    }
//                }
//            })
//        }
//    }
//
//    open func dismiss() {
//        self.selectedAssets = []
//        self.reloadView()
//    }
//}

