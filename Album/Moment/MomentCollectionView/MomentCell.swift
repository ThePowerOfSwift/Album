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

    @IBOutlet var imageView: UIImageView!
    
    private func CGSizeScale(size:CGSize,scale:CGFloat) -> CGSize{
    
        return CGSize(width: size.width*scale, height: size.height*scale)
    }
    
    
    func setPHAsset(imageManager:PHCachingImageManager,asset:PHAsset){
    
        let size = CGSizeScale(self.frame.size, scale: UIScreen.mainScreen().scale)
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
            
            let image =  AttributedStringLoader.sharedLoader.imageByAsset(asset, imageManager: imageManager, size: size)
            
            dispatch_async(dispatch_get_main_queue(), {
                
                self.imageView.image = image
            })
        })
    }
}



/// 属性字符串 缓存器
class AttributedStringLoader {
    
    lazy var cache = NSCache()
    
    class var sharedLoader:AttributedStringLoader!{
        get{
            struct backTaskLeton{
                static var predicate:dispatch_once_t = 0
                static var instance:AttributedStringLoader? = nil
            }
            dispatch_once(&backTaskLeton.predicate, { () -> Void in
                backTaskLeton.instance = AttributedStringLoader()
            })
            return backTaskLeton.instance
        }
    }
    
    /**
     根据提供的String 继而提供 属性字符串
     
     - parameter string: 原本 字符串
     - parameter font:   字体 对象 默认为 系统2号字体
     
     - returns: 返回属性字符串
     */
    func imageByAsset(asset:PHAsset,imageManager:PHCachingImageManager,size:CGSize) -> UIImage {
        
        if let image = self.cache.objectForKey(asset) as? UIImage { return image }
        
        let options = PHImageRequestOptions()
        options.synchronous = true
        options.deliveryMode = PHImageRequestOptionsDeliveryMode.HighQualityFormat
        options.networkAccessAllowed = true
        options.resizeMode = PHImageRequestOptionsResizeMode.Exact
        options.deliveryMode = PHImageRequestOptionsDeliveryMode.Opportunistic
        
        var image:UIImage!
        
        imageManager.requestImageForAsset(asset, targetSize: size, contentMode: PHImageContentMode.AspectFill, options: options) { (resimg, info) in
            
            image = resimg
        }
        
        self.cache.setObject(asset, forKey: image)
        
        return image
    }
}
