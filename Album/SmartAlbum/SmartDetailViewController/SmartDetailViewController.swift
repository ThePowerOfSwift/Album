//
//  SmartDetailViewController.swift
//  Album
//
//  Created by Mister on 16/8/12.
//  Copyright © 2016年 aimobier. All rights reserved.
//

import UIKit
import Photos

class SmartDetailViewController: BaseAlbumViewController {
    
    var FetchResult:PHFetchResult<PHAsset>!
    
    var AssetCollection:PHAssetCollection!
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        if let title =  self.AssetCollection.localizedTitle { self.title = title }
        
        let fetchOptions = PHFetchOptions()
        
        fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: true)]
        
        self.FetchResult = PHAsset.fetchAssets(in: self.AssetCollection, options: fetchOptions)
        
        PHPhotoLibrary.shared().register(self)
    }
    
    fileprivate var isFirst = true
    
    override func viewWillAppear(_ animated: Bool) {
        
        super.viewWillAppear(animated)
        
        if !isFirst { return }
        
        isFirst = false
        
        DispatchQueue.main.async {
            
            self.collectionView.scrollToBottom(false)
        }
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        
        super.viewWillTransition(to: size, with: coordinator)
        
        if let indexPath = self.collectionView.indexPathsForVisibleItems.last {
            
            coordinator.animate(alongsideTransition: { (_) in
                
                self.collectionView.collectionViewLayout.invalidateLayout()
                
                self.collectionView.scrollToItem(at: indexPath, at: UICollectionViewScrollPosition.bottom, animated: false)
                
                }, completion: nil)
        }
    }
}


extension SmartDetailViewController : PHPhotoLibraryChangeObserver{
    
    func photoLibraryDidChange(_ changeInstance: PHChange) {
        DispatchQueue.main.async {
            guard let collectionChanges = changeInstance.changeDetails(for: self.FetchResult) else { return }
            
            self.FetchResult = collectionChanges.fetchResultAfterChanges
            
            if !collectionChanges.hasIncrementalChanges || collectionChanges.hasMoves {
                self.collectionView.reloadData()
            } else {
                
                self.collectionView.performBatchUpdates({
                    let removedIndexes = collectionChanges.removedIndexes
                    if (removedIndexes?.count ?? 0) != 0 {
                        self.collectionView.deleteItems(at: removedIndexes!.map{IndexPath(item: $0, section: 0)})
                    }
                    
                    let insertedIndexes = collectionChanges.insertedIndexes
                    if (insertedIndexes?.count ?? 0) != 0 {
                        self.collectionView.insertItems(at: insertedIndexes!.map{IndexPath(item: $0, section: 0)})
                    }
                    
                    let changedIndexes = collectionChanges.changedIndexes
                    if (changedIndexes?.count ?? 0) != 0 {
                        self.collectionView.reloadItems(at: changedIndexes!.map{IndexPath(item: $0, section: 0)})
                    }
                    
                    }, completion: nil)
                
            }
        }
    }
}

//MARK: --- UICollectionViewDataSource
extension SmartDetailViewController:UICollectionViewDataSource{
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return self.FetchResult.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! MomentCell
        
        let asset = self.FetchResult.object(at: (indexPath as NSIndexPath).item)
            
        cell.setPHAsset(asset: asset)
        
        if (self.traitCollection.forceTouchCapability == UIForceTouchCapability.available) {
            
            if let perView = cell.viewControllerPreviewing {
            
                self.unregisterForPreviewing(withContext: perView)
            }
            
            cell.viewControllerPreviewing =  self.registerForPreviewing(with: self, sourceView: cell)
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView{
        
        if kind == UICollectionElementKindSectionFooter && (indexPath as NSIndexPath).section == collectionView.numberOfSections-1 {
            
            let reusableView = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionElementKindSectionFooter, withReuseIdentifier: "countview", for: indexPath) as! CountReusableView
            
            reusableView.setPHAssetCollection()
            
            return reusableView
        }
        
        return UICollectionReusableView()
    }
}


//MARK: --- UICollectionViewDelegateFlowLayout
extension SmartDetailViewController:UICollectionViewDelegateFlowLayout{
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize{
        
        let ScreenSize = UIScreen.main.bounds.size
        
        let ScreenWidth = ScreenSize.width > ScreenSize.height ? ScreenSize.height : ScreenSize.width
        
        let CellWidth = (ScreenWidth-1.5)/4
        
        return CGSize(width: CellWidth, height: CellWidth)
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets{
        
        return UIEdgeInsets.zero
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat{
        
        return 0.5
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat{
        
        return 0.5
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize{
        
        return CGSize.zero
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize{
        
        if section == collectionView.numberOfSections-1 {
            
            return CGSize(width: 0, height: 80)
        }
        return CGSize.zero
    }
}


//MARK: --- UICollectionViewDelegate
extension SmartDetailViewController:UICollectionViewDelegate,UIViewControllerPreviewingDelegate{
    
    func previewingContext(_ previewingContext: UIViewControllerPreviewing, commit viewControllerToCommit: UIViewController) {
        
        self.navigationController?.pushViewController(viewControllerToCommit, animated: false)
    }
    
    func previewingContext(_ previewingContext: UIViewControllerPreviewing, viewControllerForLocation location: CGPoint) -> UIViewController? {
        
        if let cell = previewingContext.sourceView as? MomentCell,let indexPath = self.collectionView.indexPath(for: cell){
            
            let viewController = PhotoPerviewViewController(pageIndex: indexPath, momentViewController: self)
            
            viewController.isMoments = false
            
            if let asset = self.FetchResult.object(at: (indexPath as NSIndexPath).item) as? PHAsset{
                
                if asset.pixelWidth > asset.pixelHeight {
                    
                    let height = CGFloat(asset.pixelHeight)/(CGFloat(asset.pixelWidth)/UIScreen.main.bounds.width)
                    
                    viewController.preferredContentSize = CGSize(width: UIScreen.main.bounds.width, height: height)
                }else{
                    
                    let width = CGFloat(asset.pixelWidth)/(CGFloat(asset.pixelHeight)/UIScreen.main.bounds.height)
                    
                    viewController.preferredContentSize = CGSize(width: width, height: UIScreen.main.bounds.height)
                }
            }
            
            return viewController
        }
        return nil
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let viewController = PhotoPerviewViewController(pageIndex: indexPath, momentViewController: self)
        
        viewController.isMoments = false

        self.navigationController?.pushViewController(viewController, animated: true)
    }
}
