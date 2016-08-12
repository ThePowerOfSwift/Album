//
//  AlbumTableViewCell.swift
//  Album
//
//  Created by Mister on 16/8/12.
//  Copyright © 2016年 aimobier. All rights reserved.
//

import UIKit
import Photos

class AlbumTableViewCell:UITableViewCell{
    
    @IBOutlet var titleLabel:UILabel!
    @IBOutlet var assetNumberLabel:UILabel!
    @IBOutlet var thumbnailImageView1:UIImageView!
    @IBOutlet var thumbnailImageView2:UIImageView!
    @IBOutlet var thumbnailImageView3:UIImageView!
    
    func setAssetCollection(collection:PHAssetCollection){
        
        self.titleLabel.text = collection.localizedTitle!
        
        dispatch_async(dispatch_get_main_queue(), {
            
            self.assetNumberLabel.text = "\(collection.photosCount)"
        })
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
            
            let images = ThumbnailImageLoader.sharedLoader.syncImagesByCollection(collection,cache: false, size: self.thumbnailImageView1.frame.size.CGSizeScale())
            
            dispatch_async(dispatch_get_main_queue(), {
                
                if images.count > 0 { self.thumbnailImageView1.image = images[0] }
                if images.count > 1 { self.thumbnailImageView2.image = images[1] }
                if images.count > 2 { self.thumbnailImageView3.image = images[2] }
            })
        })
    }
}


extension PHAssetCollection {
    var photosCount: Int {
        let fetchOptions = PHFetchOptions()
        //        fetchOptions.predicate = NSPredicate(format: "mediaType == %d", PHAssetMediaType.Image.rawValue)
        let result = PHAsset.fetchAssetsInAssetCollection(self, options: fetchOptions)
        return result.count
    }
}



/// 属性字符串 缓存器
class ThumbnailImageLoader:NSObject {
    
    lazy var cache = NSCache()
    
    class var sharedLoader:ThumbnailImageLoader!{
        get{
            struct backTaskLeton{
                static var predicate:dispatch_once_t = 0
                static var instance:ThumbnailImageLoader? = nil
            }
            dispatch_once(&backTaskLeton.predicate, { () -> Void in
                backTaskLeton.instance = ThumbnailImageLoader()
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
    func syncImagesByCollection(collection:PHAssetCollection,cache:Bool=true,size:CGSize) -> [UIImage] {
        
        if cache {
            
            if let image = self.cache.objectForKey(collection) as? [UIImage] { return image }
        }
        
        
        let options = PHFetchOptions()
        options.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        options.fetchLimit = 3
        let result = PHAsset.fetchAssetsInAssetCollection(collection, options: options)
        
        var images = [UIImage]()
        
        result.enumerateObjectsUsingBlock { (assert, index, _) in
            
            if let asset = assert as? PHAsset {
                let image = AttributedStringLoader.sharedLoader.syncImageByAsset(asset, size: size)
                images.append(image)
            }
        }
        
        if cache { self.cache.setObject(images, forKey: collection) }
        
        return images
    }
    
}

