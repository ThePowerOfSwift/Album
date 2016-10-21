//
//  PhotoAuthProtocol.swift
//  Album
//
//  Created by Mister on 16/4/25.
//  Copyright © 2016年 aimobier. All rights reserved.
//

import UIKit
import Photos

protocol PhotoAuthProtocol{}
extension PhotoAuthProtocol where Self:NSObject{

    /**
     获取相册访问情况
     
     - parameter complete: 反回为true 表示可以访问 否则为限制
     */
    func AuthorizationStatus(_ complete:@escaping ((Bool)->Void)){
    
        if PHPhotoLibrary.authorizationStatus() == .authorized{return complete(true)} // 如果用户已经同意访问直接返回 true
        
        if PHPhotoLibrary.authorizationStatus() == .denied || PHPhotoLibrary.authorizationStatus() == .restricted{return complete(true)} // 如果用户已经拒绝访问 或者  为限制访问，直接返回 false
        
        if  PHPhotoLibrary.authorizationStatus() == .notDetermined{ // 如果相册为还没有验证过，需要用户决定是否同意，则请求用户同意访问
        
            PHPhotoLibrary.requestAuthorization({ (status) in
                
                if PHPhotoLibrary.authorizationStatus() == .authorized{return complete(true)} /// 如果用户同意 则反回 true
                
                return complete(false) /// 否则一律反回 false
            })
        }
    }
}
