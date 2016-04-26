//
//  MomentReusableView.swift
//  Album
//
//  Created by Mister on 16/4/26.
//  Copyright © 2016年 aimobier. All rights reserved.
//

import UIKit
import Photos

class MomentReusableView:UICollectionReusableView{

    var indexPath:NSIndexPath!
    
    @IBOutlet var tabBarView: UITabBar!
    
    @IBOutlet var LeftDescLabel: UILabel!
    @IBOutlet var RightDescLabel: UILabel!
    
    
    func setPHAssetCollection(collection:PHAssetCollection){
    
        self.RightDescLabel.hidden = true
        self.LeftDescLabel.hidden = true
        
        guard let location = collection.approximateLocation else {
            
            self.LeftDescLabel.hidden = false
            return self.LeftDescLabel.text = collection.startDate?.PictureCreateTimeStr()
        }
        
        self.RightDescLabel.hidden = false
        self.RightDescLabel.text = collection.startDate?.PictureCreateTimeStr()
        
        GeocoderLocationLoader.sharedLoader.locationStr(location) { (location, locationStr) in
            
            self.LeftDescLabel.hidden = false
            self.LeftDescLabel.text = locationStr
        }
    }
}



class GeocoderLocationLoader {
    
    lazy var cache = NSCache()
    
    class var sharedLoader:GeocoderLocationLoader!{
        get{
            struct backTaskLeton{
                static var predicate:dispatch_once_t = 0
                static var instance:GeocoderLocationLoader? = nil
            }
            dispatch_once(&backTaskLeton.predicate, { () -> Void in
                backTaskLeton.instance = GeocoderLocationLoader()
            })
            return backTaskLeton.instance
        }
    }
    
    func locationStr(location:CLLocation,completionHandler:((location:CLLocation,locationStr:String)->())){
    
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), {()in
            let key = "\(location.coordinate.latitude) - \(location.coordinate.longitude)"
            
            let locationStr = self.cache.objectForKey(key) as? String
            
            if let loca = locationStr {
                dispatch_async(dispatch_get_main_queue(), {() in
                    completionHandler(location: location, locationStr: loca)
                })
                return
            }
            
            let geocoder = CLGeocoder()
            geocoder.reverseGeocodeLocation(location, completionHandler: { (placemarks, error) in
                
                if let placemark = placemarks{
                    
                    let locati = placemark[0] as CLPlacemark
                    
                    let value = "\(locati.locality!) - \(locati.subLocality!) "
                    self.cache.setObject(value, forKey: key)
                    dispatch_async(dispatch_get_main_queue(), {() in
                        completionHandler(location: location, locationStr: value)
                    })
                }
            })
            
        })
    }
}
