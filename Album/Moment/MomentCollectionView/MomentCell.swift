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
    

    
    func setPHAsset(imageManager:PHCachingImageManager,asset:PHAsset){
    
        let size = self.frame.size.CGSizeScale(1)
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
            
            let image =  AttributedStringLoader.sharedLoader.syncImageByAsset(asset, imageManager: imageManager, size: size)
            
            dispatch_async(dispatch_get_main_queue(), {
                
                self.imageView.image = image
                
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW,Int64(0.01 * Double(NSEC_PER_SEC))),dispatch_get_main_queue(), {
                    
                    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
                        
                        AttributedStringLoader.sharedLoader.asyncImageByAsset(asset,cache: false, size: self.frame.size.CGSizeScale(), finish: { (image) in
                            
                            dispatch_async(dispatch_get_main_queue(), {
                                
                                self.imageView.image = image
                            })
                        })
                    })
                })
            })
        })
    }
}

