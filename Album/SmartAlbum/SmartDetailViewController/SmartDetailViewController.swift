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
    
    var AssetCollection:PHAssetCollection!
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        if let title =  self.AssetCollection.localizedTitle { self.title = title }
        
        let fetchOptions = PHFetchOptions()
        
        fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: true)]
        
        self.FetchResult = PHAsset.fetchAssetsInAssetCollection(self.AssetCollection, options: fetchOptions)
        
        PHPhotoLibrary.sharedPhotoLibrary().registerChangeObserver(self)
    }
    
    private var isFirst = true
    
    override func viewWillAppear(animated: Bool) {
        
        super.viewWillAppear(animated)
        
        if !isFirst { return }
        
        isFirst = false
        
        dispatch_async(dispatch_get_main_queue()) {
            
            self.collectionView.scrollToBottom(false)
        }
    }
    
    override func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
        
        super.viewWillTransitionToSize(size, withTransitionCoordinator: coordinator)
        
        if let indexPath = self.collectionView.indexPathsForVisibleItems().last {
            
            coordinator.animateAlongsideTransition({ (_) in
                
                self.collectionView.collectionViewLayout.invalidateLayout()
                
                self.collectionView.scrollToItemAtIndexPath(indexPath, atScrollPosition: UICollectionViewScrollPosition.Bottom, animated: false)
                
                }, completion: nil)
        }
    }
}


extension SmartDetailViewController : PHPhotoLibraryChangeObserver{
    
    func photoLibraryDidChange(changeInstance: PHChange) {
        dispatch_async(dispatch_get_main_queue()) {
            guard let collectionChanges = changeInstance.changeDetailsForFetchResult(self.FetchResult) else { return }
            
            self.FetchResult = collectionChanges.fetchResultAfterChanges
            
            if !collectionChanges.hasIncrementalChanges || collectionChanges.hasMoves {
                self.collectionView.reloadData()
            } else {
                
                self.collectionView.performBatchUpdates({
                    let removedIndexes = collectionChanges.removedIndexes
                    if (removedIndexes?.count ?? 0) != 0 {
                        self.collectionView.deleteItemsAtIndexPaths(removedIndexes!.map{NSIndexPath(forItem: $0, inSection: 0)})
                    }
                    
                    let insertedIndexes = collectionChanges.insertedIndexes
                    if (insertedIndexes?.count ?? 0) != 0 {
                        self.collectionView.insertItemsAtIndexPaths(insertedIndexes!.map{NSIndexPath(forItem: $0, inSection: 0)})
                    }
                    
                    let changedIndexes = collectionChanges.changedIndexes
                    if (changedIndexes?.count ?? 0) != 0 {
                        self.collectionView.reloadItemsAtIndexPaths(changedIndexes!.map{NSIndexPath(forItem: $0, inSection: 0)})
                    }
                    
                    }, completion: nil)
                
            }
        }
    }
}

//MARK: --- UICollectionViewDataSource
extension SmartDetailViewController:UICollectionViewDataSource{
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return self.FetchResult.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("cell", forIndexPath: indexPath) as! MomentCell
        
        if let asset = self.FetchResult.objectAtIndex(indexPath.item) as? PHAsset{
            
            cell.setPHAsset(asset: asset)
        }
        
        if (self.traitCollection.forceTouchCapability == UIForceTouchCapability.Available) {
            
            if let perView = cell.viewControllerPreviewing {
            
                self.unregisterForPreviewingWithContext(perView)
            }
            
            cell.viewControllerPreviewing =  self.registerForPreviewingWithDelegate(self, sourceView: cell)
        }
        
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView{
        
        if kind == UICollectionElementKindSectionFooter && indexPath.section == collectionView.numberOfSections()-1 {
            
            let reusableView = collectionView.dequeueReusableSupplementaryViewOfKind(UICollectionElementKindSectionFooter, withReuseIdentifier: "countview", forIndexPath: indexPath) as! CountReusableView
            
            reusableView.setPHAssetCollection(self.FetchResult)
            
            return reusableView
        }
        
        return UICollectionReusableView()
    }
}


//MARK: --- UICollectionViewDelegateFlowLayout
extension SmartDetailViewController:UICollectionViewDelegateFlowLayout{
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize{
        
        let ScreenSize = UIScreen.mainScreen().bounds.size
        
        let ScreenWidth = ScreenSize.width > ScreenSize.height ? ScreenSize.height : ScreenSize.width
        
        let CellWidth = (ScreenWidth-1.5)/4
        
        return CGSize(width: CellWidth, height: CellWidth)
    }
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAtIndex section: Int) -> UIEdgeInsets{
        
        return UIEdgeInsetsZero
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAtIndex section: Int) -> CGFloat{
        
        return 0.5
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAtIndex section: Int) -> CGFloat{
        
        return 0.5
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize{
        
        return CGSizeZero
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize{
        
        if section == collectionView.numberOfSections()-1 {
            
            return CGSize(width: 0, height: 80)
        }
        return CGSizeZero
    }
}


//MARK: --- UICollectionViewDelegate
extension SmartDetailViewController:UICollectionViewDelegate,UIViewControllerPreviewingDelegate{
    
    func previewingContext(previewingContext: UIViewControllerPreviewing, commitViewController viewControllerToCommit: UIViewController) {
        
        self.navigationController?.pushViewController(viewControllerToCommit, animated: false)
    }
    
    func previewingContext(previewingContext: UIViewControllerPreviewing, viewControllerForLocation location: CGPoint) -> UIViewController? {
        
        if let cell = previewingContext.sourceView as? MomentCell,indexPath = self.collectionView.indexPathForCell(cell){
            
            let viewController = PhotoPerviewViewController(pageIndex: indexPath, momentViewController: self)
            
            viewController.isMoments = false
            
            if let asset = self.FetchResult.objectAtIndex(indexPath.item) as? PHAsset{
                
                if asset.pixelWidth > asset.pixelHeight {
                    
                    let height = CGFloat(asset.pixelHeight)/(CGFloat(asset.pixelWidth)/UIScreen.mainScreen().bounds.width)
                    
                    viewController.preferredContentSize = CGSize(width: UIScreen.mainScreen().bounds.width, height: height)
                }else{
                    
                    let width = CGFloat(asset.pixelWidth)/(CGFloat(asset.pixelHeight)/UIScreen.mainScreen().bounds.height)
                    
                    viewController.preferredContentSize = CGSize(width: width, height: UIScreen.mainScreen().bounds.height)
                }
            }
            
            return viewController
        }
        return nil
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        
        let viewController = PhotoPerviewViewController(pageIndex: indexPath, momentViewController: self)
        
        viewController.isMoments = false

        self.navigationController?.pushViewController(viewController, animated: true)
    }
}