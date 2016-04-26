//
//  CollectionViewDataSource.swift
//  Album
//
//  Created by Mister on 16/4/26.
//  Copyright © 2016年 aimobier. All rights reserved.
//

import UIKit
import Photos

private extension PHAsset{

    class func SoreCreateTime(collection:PHAssetCollection) -> PHFetchResult{
    
        let sortOptions = PHFetchOptions()
        sortOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: true)]
        return PHAsset.fetchAssetsInAssetCollection(collection, options: sortOptions)
    }
}

private extension CGSize{

    func byScale(scale:CGFloat) -> CGSize{
    
        return CGSize(width: self.width*scale, height: self.height*scale)
    }
}

extension PHCachingImageManager{

    func requestImageForAsset(asset:PHAsset,size:CGSize,resultHandler: (UIImage?, [NSObject : AnyObject]?) -> Void){
    
        let options = PHImageRequestOptions()
        
        options.networkAccessAllowed = true
        options.resizeMode = PHImageRequestOptionsResizeMode.Exact
        options.deliveryMode = PHImageRequestOptionsDeliveryMode.Opportunistic
        
        self.requestImageForAsset(asset, targetSize: size.byScale(UIScreen.mainScreen().scale), contentMode: .AspectFill, options: options, resultHandler: resultHandler)
    }
}

extension MomentViewController:UICollectionViewDataSource{
    
    private func CGSizeScale(size:CGSize,scale:CGFloat) -> CGSize{
        
        return CGSize(width: size.width*scale, height: size.height*scale)
    }
    
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
            
            let assetsFetchResult = PHAsset.SoreCreateTime(collection)
            
            let asset = assetsFetchResult.objectAtIndex(indexPath.item) as! PHAsset
            
            cell.representedAssetIdentifier = asset.localIdentifier
            
            let options = PHImageRequestOptions()
            
            options.networkAccessAllowed = true
            options.resizeMode = PHImageRequestOptionsResizeMode.Exact
            options.deliveryMode = PHImageRequestOptionsDeliveryMode.Opportunistic
            
            imageManager.requestImageForAsset(asset, size: cell.frame.size, resultHandler: { (image, _) in
                
                if (cell.representedAssetIdentifier == asset.localIdentifier) {
                    
                    cell.imageView.image = image
                }
            })
        }
        
        return cell
    }
    
    
    func collectionView(collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView{
        
        let reusableView = collectionView.dequeueReusableSupplementaryViewOfKind(UICollectionElementKindSectionHeader, withReuseIdentifier: "TimeResableView", forIndexPath: indexPath) as! MomentReusableView
        
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
