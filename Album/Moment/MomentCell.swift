//
//  MomentCollectionViewCell.swift
//  Album
//
//  Created by Mister on 16/4/26.
//  Copyright © 2016年 aimobier. All rights reserved.
//

import UIKit
import Photos

//MARK:  MomentCell
class MomentCell:UICollectionViewCell{

    var viewControllerPreviewing:UIViewControllerPreviewing?
    
    @IBOutlet var imageView: UIImageView!
    
    func setPHAsset(_ imageManager:PHImageManager = PHImageManager.default(),asset:PHAsset){
    
        let size = self.frame.size.CGSizeScale(1)
        
        DispatchQueue.global(qos: DispatchQoS.QoSClass.background).async {
            
            let image =  AttributedStringLoader.sharedLoader.syncImageByAsset(asset,cache: false, imageManager: imageManager, size: size)
            
            DispatchQueue.main.async(execute: {
                
                self.imageView.image = image
            })
        }

        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double(Int64(0.1 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC), execute: {
            
            DispatchQueue.global(qos: DispatchQoS.QoSClass.background).async {
                
                AttributedStringLoader.sharedLoader.asyncImageByAsset(asset,cache: false, size: self.frame.size.CGSizeScale(), finish: { (image) in
                    
                    DispatchQueue.main.async(execute: {
                        
                        self.imageView.image = image
                    })
                })
            }
        })
    }
}

//MARK:  UICollectionReusableView
class CountReusableView:UICollectionReusableView{
    
    @IBOutlet var countlabel: UILabel!
    
    func setPHAssetCollection(_ fetchResult:PHFetchResult<PHAssetCollection>?=nil){
        
        var string = ""
        
        let imageCount = fetchResult?.countOfAssets(with: .image) ?? PHAsset.fetchAssets(with: PHAssetMediaType.image, options: nil).countOfAssets(with: .image)
        let videoCount = fetchResult?.countOfAssets(with: .image) ?? PHAsset.fetchAssets(with: PHAssetMediaType.image, options: nil).countOfAssets(with: .video)
        let audioCount = fetchResult?.countOfAssets(with: .image) ?? PHAsset.fetchAssets(with: PHAssetMediaType.image, options: nil).countOfAssets(with: .audio)
        
        if imageCount > 0 { string += "\(imageCount)张照片" }
        if videoCount > 0 { string += " \(videoCount)个视频" }
        if audioCount > 0 { string += " \(audioCount)个音频" }
        
        self.countlabel.text = string
    }
}

//MARK:  UICollectionReusableView
class MomentReusableView:UICollectionReusableView{
    
    var indexPath:IndexPath!
    
    @IBOutlet var tabBarView: UITabBar!
    
    @IBOutlet var LeftDescLabel: UILabel!
    @IBOutlet var RightDescLabel: UILabel!
    
    
    func setPHAssetCollection(_ collection:PHAssetCollection){
        
        self.RightDescLabel.isHidden = true
        self.LeftDescLabel.isHidden = true
        
        guard let location = collection.approximateLocation else {
            
            self.LeftDescLabel.isHidden = false
            return self.LeftDescLabel.text = collection.startDate?.PictureCreateTimeStr()
        }
        
        self.RightDescLabel.isHidden = false
        self.RightDescLabel.text = collection.startDate?.PictureCreateTimeStr()
        
        GeocoderLocationLoader.sharedLoader.locationStr(location) { (location, locationStr) in
            
            self.LeftDescLabel.isHidden = false
            self.LeftDescLabel.text = locationStr
        }
    }
}

//MARK:  地理位置缓存器
class GeocoderLocationLoader {
    
    lazy var cache = NSCache<AnyObject,AnyObject>()
    
    static let sharedLoader = GeocoderLocationLoader()
    
    func locationStr(_ location:CLLocation,completionHandler:@escaping ((_ location:CLLocation,_ locationStr:String)->())){
        
        
        DispatchQueue.global(qos: DispatchQoS.QoSClass.background).async {
            
            let key = "\(location.coordinate.latitude) - \(location.coordinate.longitude)"
            
            let locationStr = self.cache.object(forKey: key as AnyObject) as? String
            
            if let loca = locationStr {
                DispatchQueue.main.async(execute: {() in
                    completionHandler(location, loca)
                })
                return
            }
            
            let geocoder = CLGeocoder()
            geocoder.reverseGeocodeLocation(location, completionHandler: { (placemarks, error) in
                
                if let placemark = placemarks{
                    
                    let locati = placemark[0] as CLPlacemark
                    
                    let value = (locati.locality ?? "未知") + (locati.subLocality ?? "未知")
                    
                    self.cache.setObject(value as AnyObject, forKey: key as AnyObject)
                    DispatchQueue.main.async(execute: {() in
                        completionHandler(location, value)
                    })
                }
            })
        }
    }
}
