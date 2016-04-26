//
//  CollectionViewDelegate.swift
//  Album
//
//  Created by Mister on 16/4/26.
//  Copyright © 2016年 aimobier. All rights reserved.
//

import UIKit
import Photos

extension MomentViewController:UICollectionViewDelegate{
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        
        self.SettingHeaderBlur(scrollView)
        
        self.updateCachedAssets()
    }
    
    /// 当时图开始滑动的时候，进行试图的监测，完成header的膜玻璃设置。始终只让第一个油膜玻璃效果
    private func SettingHeaderBlur(scrollView: UIScrollView){
        
        if let collectionView = scrollView as? UICollectionView{
            
            // 排序 获取第一个 Section
            let indexPaths = collectionView.indexPathsForVisibleSupplementaryElementsOfKind(UICollectionElementKindSectionHeader).sort({ (index1, index2) -> Bool in
                
                return index1.section < index2.section
            })
            
            //
            for (index,indexPath) in indexPaths.enumerate() {
                
                if let resuab = collectionView.supplementaryViewForElementKind(UICollectionElementKindSectionHeader, atIndexPath: indexPath) as? MomentReusableView,layout = self.collectionView.collectionViewLayout as? MomentCollectionLayout{
                    
                    let originY = self.view.convertRect(resuab.frame, fromView: self.collectionView).origin.y
                    
                    if originY <= layout.naviHeight {
                        
                        resuab.tabBarView.hidden = false
                        resuab.backgroundColor = UIColor.clearColor()
                    }else{
                        
                        resuab.tabBarView.hidden = true
                        
                        resuab.backgroundColor = UIColor.whiteColor()
                    }
                    
                    let translat = scrollView.panGestureRecognizer.translationInView(self.view)
                    
                    if translat.y > 0 && index == 0 && scrollView.contentOffset.y >= -layout.naviHeight{
                        
                        resuab.tabBarView.hidden = false
                        resuab.backgroundColor = UIColor.clearColor()
                    }
                }
            }
        }
    }
    
    func updateCachedAssets() {
        let isViewVisible = self.isViewLoaded() && self.view.window != nil
        if !isViewVisible {
            return
        }
        
        let preheatRect = CGRectInset(collectionView.bounds, 0.0, -0.5 * CGRectGetHeight(collectionView.bounds));
        let delta = abs(CGRectGetMidY(preheatRect) - CGRectGetMidY(self.previousPreheatRect));
        
        if delta > CGRectGetHeight(collectionView.bounds)/3.0 {
            
            var addedIndexPaths  = [NSIndexPath]()
            var removedIndexPaths  = [NSIndexPath]()
            
            computeDifferenceBetweenRect(previousPreheatRect, newRect: preheatRect, removedHandler: { (removedRect) in
                if self.collectionView.pyp_IndexPathsForElementsInRect(removedRect) != nil {
                    removedIndexPaths = self.collectionView.pyp_IndexPathsForElementsInRect(removedRect)!
                    
                }
                
                }, addedHandler: { (addedHandler) in
                    if self.collectionView.pyp_IndexPathsForElementsInRect(addedHandler) != nil {
                        addedIndexPaths = self.collectionView.pyp_IndexPathsForElementsInRect(addedHandler)!
                        
                    }
                    
            })
            
            
            let assetsToStartCaching = assetsAtIndexPaths(addedIndexPaths)
            let assetsToStopCaching = assetsAtIndexPaths(removedIndexPaths)
            let size = CGSizeZero
            imageManager.startCachingImagesForAssets(assetsToStartCaching, targetSize: size, contentMode: .AspectFill, options: nil)
            imageManager.stopCachingImagesForAssets(assetsToStopCaching, targetSize: size, contentMode: .AspectFill, options: nil)
            previousPreheatRect = preheatRect
        }
        
    }
    
    func computeDifferenceBetweenRect(oldRect:CGRect, newRect:CGRect, removedHandler:(CGRect)->Void,addedHandler:(CGRect)->Void) {
        
        
        if CGRectIntersectsRect(newRect, oldRect) {
            let oldMaxY = CGRectGetMaxY(oldRect)
            let oldMinY = CGRectGetMinY(oldRect)
            let newMaxY = CGRectGetMaxY(newRect)
            let newMinY = CGRectGetMinY(newRect)
            
            if (newMaxY > oldMaxY) {
                let rectToAdd = CGRectMake(newRect.origin.x, oldMaxY, newRect.size.width, (newMaxY - oldMaxY))
                
                addedHandler(rectToAdd)
            }
            
            if (oldMinY > newMinY) {
                let rectToAdd = CGRectMake(newRect.origin.x, newMinY, newRect.size.width, (oldMinY - newMinY))
                addedHandler(rectToAdd)
            }
            
            if (newMaxY < oldMaxY) {
                let rectToRemove = CGRectMake(newRect.origin.x, newMaxY, newRect.size.width, (oldMaxY - newMaxY))
                removedHandler(rectToRemove)
            }
            
            if (oldMinY < newMinY) {
                let rectToRemove = CGRectMake(newRect.origin.x, oldMinY, newRect.size.width, (newMinY - oldMinY))
                removedHandler(rectToRemove)
            }
        } else {
            addedHandler(newRect)
            removedHandler(oldRect)
        }
    }
    
    
    
    func assetsAtIndexPaths(indexPaths:[NSIndexPath]) -> [PHAsset]{
        
        var assets = [PHAsset]()
        
        if indexPaths.count == 0 {return assets}
        
        for indexPath in indexPaths {
            
            if let collection = self.FetchResult.objectAtIndex(indexPath.section) as? PHAssetCollection{
                
                let sortOptions = PHFetchOptions()
                sortOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: true)]
                let assetsFetchResult = PHAsset.fetchAssetsInAssetCollection(collection, options: sortOptions)
                
                assets.append(assetsFetchResult.objectAtIndex(indexPath.item) as! PHAsset)
            }
        }
        return assets
    }
}


extension UICollectionView {
    func pyp_IndexPathsForElementsInRect(rect:CGRect) -> [NSIndexPath]? {
        let allLayoutAttributes = self.collectionViewLayout.layoutAttributesForElementsInRect(rect)
        
        if allLayoutAttributes?.count == 0 {
            return nil
        }
        var indexPaths = [NSIndexPath]()
        for layoutAttributes in allLayoutAttributes! {
            let indexPath = layoutAttributes.indexPath
            indexPaths.append(indexPath)
        }
        return indexPaths
        
    }
}