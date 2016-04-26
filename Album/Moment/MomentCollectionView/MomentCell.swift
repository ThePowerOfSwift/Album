//
//  MomentCollectionViewCell.swift
//  Album
//
//  Created by Mister on 16/4/26.
//  Copyright © 2016年 aimobier. All rights reserved.
//

import UIKit
import Photos

class MomentCell:UICollectionViewCell{

    var asset:PHAsset!
    var representedAssetIdentifier:String!
    
    @IBOutlet var imageView: UIImageView!
    
    private func CGSizeScale(size:CGSize,scale:CGFloat) -> CGSize{
    
        return CGSize(width: size.width*scale, height: size.height*scale)
    }
    
    
    func setPHAsset(imageManager:PHCachingImageManager,asset:PHAsset){
    
        self.asset = asset
        
        let options = PHImageRequestOptions()
        
        options.deliveryMode = PHImageRequestOptionsDeliveryMode.HighQualityFormat
        options.networkAccessAllowed = true
        options.resizeMode = PHImageRequestOptionsResizeMode.Exact
        options.deliveryMode = PHImageRequestOptionsDeliveryMode.Opportunistic
        
        imageManager.requestImageForAsset(asset, targetSize: CGSizeScale(self.frame.size, scale: UIScreen.mainScreen().scale), contentMode: PHImageContentMode.AspectFill, options: options) { (image, info) in
            
            self.imageView.image = image
        }
        
    }
}