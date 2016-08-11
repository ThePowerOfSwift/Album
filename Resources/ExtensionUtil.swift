//
//  ExtensionUtil.swift
//  Album
//
//  Created by Mister on 16/4/26.
//  Copyright © 2016年 aimobier. All rights reserved.
//

import UIKit
import Photos

extension NSDate{

    func PictureCreateTimeStr() -> String{
    
        if self.isToday() {return "今天"}
        if self.isYesterday() {return "昨天"}
        if self.isThisWeek() {return self.weekday().WeekStr()}
        if self.isThisYear(){return self.toString(format: DateFormat.Custom("M月d日"))}
        return self.toString(format: DateFormat.Custom("yyyy年M月d日"))
    }
}


private extension Int{

    func WeekStr() -> String{
    
        switch self {
        case 1:
            return "星期日"
        case 2:
            return "星期一"
        case 3:
            return "星期二"
        case 4:
            return "星期三"
        case 5:
            return "星期四"
        case 6:
            return "星期五"
        default:
            return "星期六"
        }
    }
}

extension PHAsset{
    
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


extension NSIndexPath {

    /**
     获取前一个NSIndexPath
     
     - parameter collectionView: collectionView
     
     - returns: 返回的NsindexPath
     */
    func indexPathPrevious(collectionView:UICollectionView) -> NSIndexPath?{
    
        if self.section == 0 && self.item == 0 { return nil}
        
        if self.item == 0 {
        
            return NSIndexPath(forRow: collectionView.numberOfItemsInSection(self.section-1)-1, inSection: self.section-1)
        }
        
        return NSIndexPath(forRow: self.item-1, inSection: self.section)
    }
    
    /**
     获取下一个NSIndexPath
     
     - parameter collectionView: collectionView
     
     - returns: 返回的NsindexPath
     */
    func indexPathNext(collectionView:UICollectionView) -> NSIndexPath?{
        
        if self.section == collectionView.numberOfSections()-1 && self.item == collectionView.maxRow(section) { return nil}
        
        if self.item == collectionView.maxRow(section) {
            
            return NSIndexPath(forRow: 0, inSection: self.section+1)
        }
        
        return NSIndexPath(forRow: self.item+1, inSection: self.section)
    }
}


extension UICollectionView{

    /**
     最大的行数
     
     - parameter section: <#section description#>
     
     - returns: <#return value description#>
     */
    func maxRow(section:Int) -> Int{
    
        return self.numberOfItemsInSection(section)-1
    }
    
    /**
     最大的行数
     
     - parameter section: <#section description#>
     
     - returns: <#return value description#>
     */
    func maxSection() -> Int{
        
        return self.numberOfSections()-1
    }
    
    /**
     最大的 NSIndexPath
     */
    func maxIndexPath() -> NSIndexPath{
    
        return NSIndexPath(forItem: self.maxRow(self.maxSection()), inSection: self.maxSection())
    }
    
    /**
     滑动到最底端
     
     - parameter animated: 是否有动画
     */
    func scrollToBottom (animated:Bool = true){
    
        self.scrollToItemAtIndexPath(self.maxIndexPath(), atScrollPosition: UICollectionViewScrollPosition.Bottom, animated: animated)
    }
}