//
//  PHImageLoader.swift
//  Album
//
//  Created by Mister on 16/8/11.
//  Copyright © 2016年 aimobier. All rights reserved.
//

import Photos

extension CGSize{
    
    func CGSizeScale(_ scale:CGFloat = UIScreen.main.scale) -> CGSize{
        
        return CGSize(width: self.width*scale, height: self.height*scale)
    }
}


/// 属性字符串 缓存器
class AttributedStringLoader {
    
    let cache = NSCache<AnyObject,AnyObject>()
    
    static let sharedLoader:AttributedStringLoader = AttributedStringLoader()
    
    /**
     根据提供的String 继而 同步的方式 提取图片 并且返回
     
     - parameter string: 原本 字符串
     - parameter font:   字体 对象 默认为 系统2号字体
     
     - returns: 返回属性字符串
     */
    func syncImageByAsset(_ asset:PHAsset,cache:Bool=true,imageManager:PHImageManager = PHImageManager.default(),size:CGSize) -> UIImage {
        
        if cache {
            
            if let image = self.cache.object(forKey: asset) as? UIImage { return image }
        }
        
        let options = PHImageRequestOptions()
        options.isSynchronous = true
        options.deliveryMode = PHImageRequestOptionsDeliveryMode.highQualityFormat
        options.isNetworkAccessAllowed = true
        options.resizeMode = PHImageRequestOptionsResizeMode.exact
        options.deliveryMode = PHImageRequestOptionsDeliveryMode.opportunistic
        
        var image:UIImage!
        
        imageManager.requestImage(for: asset, targetSize: size, contentMode: PHImageContentMode.aspectFill, options: options) { (resimg, info) in
            
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
    func asyncImageByAsset(_ asset:PHAsset,cache:Bool=true,imageManager:PHImageManager = PHImageManager.default(),size:CGSize,finish:@escaping ((_ image:UIImage)->Void)) {
        
        if cache {
            
            if let image = self.cache.object(forKey: asset) as? UIImage { return finish(image) }
        }
        
        let options = PHImageRequestOptions()
        options.isSynchronous = true
        options.deliveryMode = PHImageRequestOptionsDeliveryMode.highQualityFormat
        options.isNetworkAccessAllowed = true
        options.resizeMode = PHImageRequestOptionsResizeMode.exact
        options.deliveryMode = PHImageRequestOptionsDeliveryMode.opportunistic
        
        imageManager.requestImage(for: asset, targetSize: size, contentMode: PHImageContentMode.aspectFill, options: options) { (resimg, info) in
            
            if let image = resimg {
                if cache {
                    
                    self.cache.setObject(image, forKey: asset)
                }
                
                finish(image)
            }
        }
    }
}
