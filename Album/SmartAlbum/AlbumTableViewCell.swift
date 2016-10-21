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
    
    func setAssetCollection(_ collection:PHAssetCollection){
        
        self.titleLabel.text = collection.localizedTitle!
        
        DispatchQueue.main.async(execute: {
            
            self.assetNumberLabel.text = "\(collection.photosCount)"
        })
        
        DispatchQueue.global(qos: DispatchQoS.QoSClass.background).async {
            
            let images = ThumbnailImageLoader.sharedLoader.syncImagesByCollection(collection,cache: false, size: self.thumbnailImageView1.frame.size.CGSizeScale())
            
            DispatchQueue.main.async(execute: {
                
                if images.count > 0 { self.thumbnailImageView1.image = images[0] }
                if images.count > 1 { self.thumbnailImageView2.image = images[1] }
                if images.count > 2 { self.thumbnailImageView3.image = images[2] }
            })
        }
    }
}


extension PHAssetCollection {
    var photosCount: Int {
        let fetchOptions = PHFetchOptions()
        //        fetchOptions.predicate = NSPredicate(format: "mediaType == %d", PHAssetMediaType.Image.rawValue)
        let result = PHAsset.fetchAssets(in: self, options: fetchOptions)
        return result.count
    }
}

/// 属性字符串 缓存器
class ThumbnailImageLoader:NSObject {
    
    
    let cache = NSCache<AnyObject,AnyObject>()
    
    static let sharedLoader = ThumbnailImageLoader()

    
    /**
     根据提供的String 继而 同步的方式 提取图片 并且返回
     
     - parameter string: 原本 字符串
     - parameter font:   字体 对象 默认为 系统2号字体
     
     - returns: 返回属性字符串
     */
    func syncImagesByCollection(_ collection:PHAssetCollection,cache:Bool=true,size:CGSize) -> [UIImage] {
        
        if cache {
            
            if let image = self.cache.object(forKey: collection) as? [UIImage] { return image }
        }
        
        
        let options = PHFetchOptions()
        
        options.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        
        options.fetchLimit = 3
        
        var images = [UIImage]()
        
        let result:PHFetchResult<PHAsset> = PHAsset.fetchAssets(in: collection, options: options)
        
        result.enumerateObjects( { (assert, _, _) in
            
            let image = AttributedStringLoader.sharedLoader.syncImageByAsset(assert, size: size)
            
            images.append(image)
        })
        
        if cache { self.cache.setObject(images as AnyObject, forKey: collection) }
        
        return images
    }
    
}

