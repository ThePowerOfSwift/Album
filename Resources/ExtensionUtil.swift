//
//  ExtensionUtil.swift
//  Album
//
//  Created by Mister on 16/4/26.
//  Copyright © 2016年 aimobier. All rights reserved.
//

import UIKit
import Photos

extension Date{

    func PictureCreateTimeStr() -> String{
    
        if self.isToday() {return "今天"}
        if self.isYesterday() {return "昨天"}
        if self.isThisWeek() {return self.weekday().WeekStr()}
        if self.isThisYear(){return self.toString(DateFormat.custom("M月d日"))}
        return self.toString(DateFormat.custom("yyyy年M月d日"))
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
    
    class func SoreCreateTime(_ collection:PHAssetCollection) -> PHFetchResult<AnyObject>{
        
        let sortOptions = PHFetchOptions()
        sortOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: true)]
        return PHAsset.fetchAssets(in: collection, options: sortOptions) as! PHFetchResult<AnyObject>
    }
}

private extension CGSize{
    
    func byScale(_ scale:CGFloat) -> CGSize{
        
        return CGSize(width: self.width*scale, height: self.height*scale)
    }
}

extension PHCachingImageManager{
    
    func requestImageForAsset(_ asset:PHAsset,size:CGSize,resultHandler: @escaping (UIImage?, [AnyHashable: Any]?) -> Void){
        
        let options = PHImageRequestOptions()
        
        options.isNetworkAccessAllowed = true
        options.resizeMode = PHImageRequestOptionsResizeMode.exact
        options.deliveryMode = PHImageRequestOptionsDeliveryMode.opportunistic
        
        self.requestImage(for: asset, targetSize: size.byScale(UIScreen.main.scale), contentMode: .aspectFill, options: options, resultHandler: resultHandler)
    }
}


extension IndexPath {

    /**
     获取前一个NSIndexPath
     
     - parameter collectionView: collectionView
     
     - returns: 返回的NsindexPath
     */
    func indexPathPrevious(_ collectionView:UICollectionView) -> IndexPath?{
    
        if (self as NSIndexPath).section == 0 && (self as NSIndexPath).item == 0 { return nil}
        
        if (self as NSIndexPath).item == 0 {
        
            return IndexPath(row: collectionView.numberOfItems(inSection: (self as NSIndexPath).section-1)-1, section: (self as NSIndexPath).section-1)
        }
        
        return IndexPath(row: (self as NSIndexPath).item-1, section: (self as NSIndexPath).section)
    }
    
    /**
     获取下一个NSIndexPath
     
     - parameter collectionView: collectionView
     
     - returns: 返回的NsindexPath
     */
    func indexPathNext(_ collectionView:UICollectionView) -> IndexPath?{
        
        if (self as NSIndexPath).section == collectionView.numberOfSections-1 && (self as NSIndexPath).item == collectionView.maxRow(section) { return nil}
        
        if (self as NSIndexPath).item == collectionView.maxRow(section) {
            
            return IndexPath(row: 0, section: (self as NSIndexPath).section+1)
        }
        
        return IndexPath(row: (self as NSIndexPath).item+1, section: (self as NSIndexPath).section)
    }
}


extension UICollectionView{

    /**
     最大的行数
     
     - parameter section: <#section description#>
     
     - returns: <#return value description#>
     */
    func maxRow(_ section:Int) -> Int{
    
        return self.numberOfItems(inSection: section)-1
    }
    
    /**
     最大的行数
     
     - parameter section: <#section description#>
     
     - returns: <#return value description#>
     */
    func maxSection() -> Int{
        
        return self.numberOfSections-1
    }
    
    /**
     最大的 NSIndexPath
     */
    func maxIndexPath() -> IndexPath{
    
        return IndexPath(item: self.maxRow(self.maxSection()), section: self.maxSection())
    }
    
    /**
     滑动到最底端
     
     - parameter animated: 是否有动画
     */
    func scrollToBottom (_ animated:Bool = true){
    
        self.scrollToItem(at: self.maxIndexPath(), at: UICollectionViewScrollPosition.bottom, animated: animated)
    }
}
