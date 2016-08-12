//
//  CollectionViewDelegate.swift
//  Album
//
//  Created by Mister on 16/4/26.
//  Copyright © 2016年 aimobier. All rights reserved.
//

import UIKit
import Photos


//MARK: --- UICollectionViewDataSource
extension MomentViewController:UICollectionViewDataSource{
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        
        return self.FetchResult.count
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        if let collection = self.FetchResult.objectAtIndex(section) as? PHAssetCollection{
            
            return collection.estimatedAssetCount
        }
        
        return 0
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("cell", forIndexPath: indexPath) as! MomentCell
        
        if let collection = self.FetchResult.objectAtIndex(indexPath.section) as? PHAssetCollection{
            
            cell.setPHAsset(imageManager, asset: PHAsset.SoreCreateTime(collection).objectAtIndex(indexPath.item) as! PHAsset)
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
            
            reusableView.setPHAssetCollection()
            
            return reusableView
        }
        
        let reusableView = collectionView.dequeueReusableSupplementaryViewOfKind(UICollectionElementKindSectionHeader, withReuseIdentifier: "TimeResableView", forIndexPath: indexPath) as! MomentReusableView
        
        if indexPath.section == 0 {
            
            reusableView.tabBarView.hidden = false
            reusableView.backgroundColor = UIColor.clearColor()
        }
        
        if let collection = self.FetchResult.objectAtIndex(indexPath.section) as? PHAssetCollection{
            
            reusableView.setPHAssetCollection(collection)
            
            let tapGesture = UITapGestureRecognizer(closure: { (_) in
                
                if let attribs = self.collectionView.layoutAttributesForItemAtIndexPath(indexPath){
                    
                    let topOfHeader = CGPoint(x: 0, y: attribs.frame.origin.y - (self.collectionView.collectionViewLayout as! MomentCollectionLayout).naviHeight - 50)
                    
                    self.collectionView.setContentOffset(topOfHeader, animated: true)
                }
            })
            
            reusableView.addGestureRecognizer(tapGesture)
            
            return reusableView
        }
        
        return reusableView
    }
}


//MARK: --- UICollectionViewDelegateFlowLayout
extension MomentViewController:UICollectionViewDelegateFlowLayout{
    
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
        
        return CGSize(width: 0, height: 50)
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize{
        
        if section == collectionView.numberOfSections()-1 {
        
            return CGSize(width: 0, height: 80)
        }
        
        return CGSizeZero
    }
}

//MARK: --- UICollectionViewDelegate
extension MomentViewController:UICollectionViewDelegate,UIViewControllerPreviewingDelegate{
    
    func previewingContext(previewingContext: UIViewControllerPreviewing, commitViewController viewControllerToCommit: UIViewController) {
        
        self.navigationController?.pushViewController(viewControllerToCommit, animated: false)
    }
    
    func previewingContext(previewingContext: UIViewControllerPreviewing, viewControllerForLocation location: CGPoint) -> UIViewController? {
        
        if let cell = previewingContext.sourceView as? MomentCell,indexPath = self.collectionView.indexPathForCell(cell){
            
            let viewController = PhotoPerviewViewController(pageIndex: indexPath, momentViewController: self)

            if let collection = self.FetchResult.objectAtIndex(indexPath.section) as? PHAssetCollection,asset = PHAsset.SoreCreateTime(collection).objectAtIndex(indexPath.item) as? PHAsset{
                
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
        
        let viewC = PhotoPerviewViewController(pageIndex: indexPath, momentViewController: self)
        
        self.navigationController?.pushViewController(viewC, animated: true)
    }
    
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        
        self.SettingHeaderBlur(scrollView)
        
//        self.updateCachedAssets()
    }
    
    /// 当时图开始滑动的时候，进行试图的监测，完成header的膜玻璃设置。始终只让第一个油膜玻璃效果
    private func SettingHeaderBlur(scrollView: UIScrollView){
        
        if let collectionView = scrollView as? UICollectionView{
            
            // 排序 获取第一个 Section
            let indexPaths = collectionView.indexPathsForVisibleSupplementaryElementsOfKind(UICollectionElementKindSectionHeader).sort({ (index1, index2) -> Bool in
                
                return index1.section < index2.section
            })
            
            if indexPaths.count <= 0 { return }
            
            if indexPaths.count == 1 {
                guard let firindexPath = indexPaths.first,resuab = collectionView.supplementaryViewForElementKind(UICollectionElementKindSectionHeader, atIndexPath: firindexPath) as? MomentReusableView else { return }
                resuab.tabBarView.hidden = false
                resuab.backgroundColor = UIColor.clearColor()
                return
            }
            
            for indexPath in indexPaths {
                guard let resuab = collectionView.supplementaryViewForElementKind(UICollectionElementKindSectionHeader, atIndexPath: indexPath) as? MomentReusableView else{ return }
                resuab.tabBarView.hidden = true
                resuab.backgroundColor = UIColor.whiteColor()
            }
            
            guard let layout = self.collectionView.collectionViewLayout as? MomentCollectionLayout else{ return }
            
            guard let firindexPath = indexPaths.first,firresuab = collectionView.supplementaryViewForElementKind(UICollectionElementKindSectionHeader, atIndexPath: firindexPath) as? MomentReusableView else{ return }
            let firoriginY = self.view.convertRect(firresuab.frame, fromView: self.collectionView).origin.y
            
            guard let secresuab = collectionView.supplementaryViewForElementKind(UICollectionElementKindSectionHeader, atIndexPath: indexPaths[1]) as? MomentReusableView else{ return }
            

            let sc = firoriginY+firresuab.frame.height >= layout.naviHeight ? firresuab : secresuab
            
            sc.tabBarView.hidden = false
            sc.backgroundColor = UIColor.clearColor()
            
            if firoriginY > layout.naviHeight+2 && firindexPath.section == 0{
                firresuab.tabBarView.hidden = true
                firresuab.backgroundColor = UIColor.whiteColor()
            }
        }
    }
    
//    func updateCachedAssets() {
//        let isViewVisible = self.isViewLoaded() && self.view.window != nil
//        if !isViewVisible {
//            return
//        }
//        
//        let preheatRect = CGRectInset(collectionView.bounds, 0.0, -0.5 * CGRectGetHeight(collectionView.bounds));
//        let delta = abs(CGRectGetMidY(preheatRect) - CGRectGetMidY(self.previousPreheatRect));
//        
//        if delta > CGRectGetHeight(collectionView.bounds)/3.0 {
//            
//            var addedIndexPaths  = [NSIndexPath]()
//            var removedIndexPaths  = [NSIndexPath]()
//            
//            computeDifferenceBetweenRect(previousPreheatRect, newRect: preheatRect, removedHandler: { (removedRect) in
//                if self.collectionView.pyp_IndexPathsForElementsInRect(removedRect) != nil {
//                    removedIndexPaths = self.collectionView.pyp_IndexPathsForElementsInRect(removedRect)!
//                    
//                }
//                
//                }, addedHandler: { (addedHandler) in
//                    if self.collectionView.pyp_IndexPathsForElementsInRect(addedHandler) != nil {
//                        addedIndexPaths = self.collectionView.pyp_IndexPathsForElementsInRect(addedHandler)!
//                        
//                    }
//                    
//            })
//            
//            
//            let assetsToStartCaching = assetsAtIndexPaths(addedIndexPaths)
//            let assetsToStopCaching = assetsAtIndexPaths(removedIndexPaths)
//            let size = CGSizeZero
//            imageManager.startCachingImagesForAssets(assetsToStartCaching, targetSize: size, contentMode: .AspectFill, options: nil)
//            imageManager.stopCachingImagesForAssets(assetsToStopCaching, targetSize: size, contentMode: .AspectFill, options: nil)
//            previousPreheatRect = preheatRect
//        }
//        
//    }
//    
//    func computeDifferenceBetweenRect(oldRect:CGRect, newRect:CGRect, removedHandler:(CGRect)->Void,addedHandler:(CGRect)->Void) {
//        
//        
//        if CGRectIntersectsRect(newRect, oldRect) {
//            let oldMaxY = CGRectGetMaxY(oldRect)
//            let oldMinY = CGRectGetMinY(oldRect)
//            let newMaxY = CGRectGetMaxY(newRect)
//            let newMinY = CGRectGetMinY(newRect)
//            
//            if (newMaxY > oldMaxY) {
//                let rectToAdd = CGRectMake(newRect.origin.x, oldMaxY, newRect.size.width, (newMaxY - oldMaxY))
//                
//                addedHandler(rectToAdd)
//            }
//            
//            if (oldMinY > newMinY) {
//                let rectToAdd = CGRectMake(newRect.origin.x, newMinY, newRect.size.width, (oldMinY - newMinY))
//                addedHandler(rectToAdd)
//            }
//            
//            if (newMaxY < oldMaxY) {
//                let rectToRemove = CGRectMake(newRect.origin.x, newMaxY, newRect.size.width, (oldMaxY - newMaxY))
//                removedHandler(rectToRemove)
//            }
//            
//            if (oldMinY < newMinY) {
//                let rectToRemove = CGRectMake(newRect.origin.x, oldMinY, newRect.size.width, (newMinY - oldMinY))
//                removedHandler(rectToRemove)
//            }
//        } else {
//            addedHandler(newRect)
//            removedHandler(oldRect)
//        }
//    }
//    
//    
//    
//    func assetsAtIndexPaths(indexPaths:[NSIndexPath]) -> [PHAsset]{
//        
//        var assets = [PHAsset]()
//        
//        if indexPaths.count == 0 {return assets}
//        
//        for indexPath in indexPaths {
//            
//            if let collection = self.FetchResult.objectAtIndex(indexPath.section) as? PHAssetCollection{
//                
//                let sortOptions = PHFetchOptions()
//                sortOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: true)]
//                let assetsFetchResult = PHAsset.fetchAssetsInAssetCollection(collection, options: sortOptions)
//                
//                assets.append(assetsFetchResult.objectAtIndex(indexPath.item) as! PHAsset)
//            }
//        }
//        return assets
//    }
}


//extension UICollectionView {
//    func pyp_IndexPathsForElementsInRect(rect:CGRect) -> [NSIndexPath]? {
//        let allLayoutAttributes = self.collectionViewLayout.layoutAttributesForElementsInRect(rect)
//        
//        if allLayoutAttributes?.count == 0 {
//            return nil
//        }
//        var indexPaths = [NSIndexPath]()
//        for layoutAttributes in allLayoutAttributes! {
//            let indexPath = layoutAttributes.indexPath
//            indexPaths.append(indexPath)
//        }
//        return indexPaths
//        
//    }
//}
