//
//  PHImageLoader.swift
//  Album
//
//  Created by Mister on 16/8/11.
//  Copyright © 2016年 aimobier. All rights reserved.
//

import Photos

extension CGSize{
    
    func CGSizeScale(scale:CGFloat = UIScreen.mainScreen().scale) -> CGSize{
        
        return CGSize(width: self.width*scale, height: self.height*scale)
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
     根据提供的String 继而 同步的方式 提取图片 并且返回
     
     - parameter string: 原本 字符串
     - parameter font:   字体 对象 默认为 系统2号字体
     
     - returns: 返回属性字符串
     */
    func syncImageByAsset(asset:PHAsset,cache:Bool=true,imageManager:PHImageManager = PHImageManager.defaultManager(),size:CGSize) -> UIImage {
        
        if cache {
            
            if let image = self.cache.objectForKey(asset) as? UIImage { return image }
        }
        
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
        if cache {
            
            self.cache.setObject(image, forKey: asset)
        }
        
        return image
    }
    
    /**
     根据提供的String 继而 同步的方式 提取图片 并且返回
     
     - parameter string: 原本 字符串
     - parameter font:   字体 对象 默认为 系统2号字体
     
     - returns: 返回属性字符串
     */
    func asyncImageByAsset(asset:PHAsset,cache:Bool=true,imageManager:PHImageManager = PHImageManager.defaultManager(),size:CGSize,finish:((image:UIImage)->Void)) {
        
        if cache {
            
            if let image = self.cache.objectForKey(asset) as? UIImage { return finish(image: image) }
        }
        
        let options = PHImageRequestOptions()
        options.synchronous = true
        options.deliveryMode = PHImageRequestOptionsDeliveryMode.HighQualityFormat
        options.networkAccessAllowed = true
        options.resizeMode = PHImageRequestOptionsResizeMode.Exact
        options.deliveryMode = PHImageRequestOptionsDeliveryMode.Opportunistic
        
        imageManager.requestImageForAsset(asset, targetSize: size, contentMode: PHImageContentMode.AspectFill, options: options) { (resimg, info) in
            
            if let image = resimg {
                if cache {
                    
                    self.cache.setObject(image, forKey: asset)
                }
                
                finish(image: image)
            }
        }
    }
}
