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
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        
        return self.FetchResult.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return self.FetchResult.object(at: section).estimatedAssetCount
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! MomentCell
        
        cell.setPHAsset(imageManager, asset: PHAsset.SoreCreateTime(self.FetchResult.object(at: indexPath.section)).object(at: indexPath.item) as! PHAsset)
        
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
        
        let reusableView = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionElementKindSectionHeader, withReuseIdentifier: "TimeResableView", for: indexPath) as! MomentReusableView
        
        if (indexPath as NSIndexPath).section == 0 {
            
            reusableView.tabBarView.isHidden = false
            reusableView.backgroundColor = UIColor.clear
        }
        
        reusableView.setPHAssetCollection(self.FetchResult.object(at: (indexPath as NSIndexPath).section))
        
        let tapGesture = UITapGestureRecognizer(closure: { (_) in
            
            if let attribs = self.collectionView.layoutAttributesForItem(at: indexPath){
                
                let topOfHeader = CGPoint(x: 0, y: attribs.frame.origin.y - (self.collectionView.collectionViewLayout as! MomentCollectionLayout).naviHeight - 50)
                
                self.collectionView.setContentOffset(topOfHeader, animated: true)
            }
        })
        
        reusableView.addGestureRecognizer(tapGesture)
        
        return reusableView
    }
}


//MARK: --- UICollectionViewDelegateFlowLayout
extension MomentViewController:UICollectionViewDelegateFlowLayout{
    
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
        
        return CGSize(width: 0, height: 50)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize{
        
        if section == collectionView.numberOfSections-1 {
        
            return CGSize(width: 0, height: 80)
        }
        
        return CGSize.zero
    }
}

//MARK: --- UICollectionViewDelegate
extension MomentViewController:UICollectionViewDelegate,UIViewControllerPreviewingDelegate{
    
    func previewingContext(_ previewingContext: UIViewControllerPreviewing, commit viewControllerToCommit: UIViewController) {
        
        self.navigationController?.pushViewController(viewControllerToCommit, animated: false)
    }
    
    func previewingContext(_ previewingContext: UIViewControllerPreviewing, viewControllerForLocation location: CGPoint) -> UIViewController? {
        
        if let cell = previewingContext.sourceView as? MomentCell,let indexPath = self.collectionView.indexPath(for: cell){
            
            let viewController = PhotoPerviewViewController(pageIndex: indexPath, momentViewController: self)

            if let collection = self.FetchResult.object(at: (indexPath as NSIndexPath).section) as? PHAssetCollection,let asset = PHAsset.SoreCreateTime(collection).object(at: (indexPath as NSIndexPath).item) as? PHAsset{
                
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
        
        let viewC = PhotoPerviewViewController(pageIndex: indexPath, momentViewController: self)
        
        self.navigationController?.pushViewController(viewC, animated: true)
    }
    
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        self.SettingHeaderBlur(scrollView)
        
//        self.updateCachedAssets()
    }
    
    /// 当时图开始滑动的时候，进行试图的监测，完成header的膜玻璃设置。始终只让第一个油膜玻璃效果
    fileprivate func SettingHeaderBlur(_ scrollView: UIScrollView){
        
        if let collectionView = scrollView as? UICollectionView{
            
            // 排序 获取第一个 Section
            let indexPaths = collectionView.indexPathsForVisibleSupplementaryElements(ofKind: UICollectionElementKindSectionHeader).sorted(by: { (index1, index2) -> Bool in
                
                return (index1 as NSIndexPath).section < (index2 as NSIndexPath).section
            })
            
            if indexPaths.count <= 0 { return }
            
            if indexPaths.count == 1 {
                guard let firindexPath = indexPaths.first,let resuab = collectionView.supplementaryView(forElementKind: UICollectionElementKindSectionHeader, at: firindexPath) as? MomentReusableView else { return }
                resuab.tabBarView.isHidden = false
                resuab.backgroundColor = UIColor.clear
                return
            }
            
            for indexPath in indexPaths {
                guard let resuab = collectionView.supplementaryView(forElementKind: UICollectionElementKindSectionHeader, at: indexPath) as? MomentReusableView else{ return }
                resuab.tabBarView.isHidden = true
                resuab.backgroundColor = UIColor.white
            }
            
            guard let layout = self.collectionView.collectionViewLayout as? MomentCollectionLayout else{ return }
            
            guard let firindexPath = indexPaths.first,let firresuab = collectionView.supplementaryView(forElementKind: UICollectionElementKindSectionHeader, at: firindexPath) as? MomentReusableView else{ return }
            let firoriginY = self.view.convert(firresuab.frame, from: self.collectionView).origin.y
            
            guard let secresuab = collectionView.supplementaryView(forElementKind: UICollectionElementKindSectionHeader, at: indexPaths[1]) as? MomentReusableView else{ return }
            

            let sc = firoriginY+firresuab.frame.height >= layout.naviHeight ? firresuab : secresuab
            
            sc.tabBarView.isHidden = false
            sc.backgroundColor = UIColor.clear
            
            if firoriginY > layout.naviHeight+2 && (firindexPath as NSIndexPath).section == 0{
                firresuab.tabBarView.isHidden = true
                firresuab.backgroundColor = UIColor.white
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
