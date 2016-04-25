//
//  CollectionViewController.swift
//  Album
//
//  Created by Mister on 16/4/25.
//  Copyright © 2016年 aimobier. All rights reserved.
//

import UIKit
import Photos

class CollectionViewController: UIViewController {
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        let smartAlbums = PHAssetCollection.fetchAssetCollectionsWithType(PHAssetCollectionType.Moment, subtype: PHAssetCollectionSubtype.Any, options: nil)
        
        
        
        print(smartAlbums.count)
    }
}
