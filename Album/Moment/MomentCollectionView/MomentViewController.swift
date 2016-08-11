//
//  MomentViewController.swift
//  Album
//
//  Created by Mister on 16/4/25.
//  Copyright © 2016年 aimobier. All rights reserved.
//

import UIKit
import Photos

class MomentViewController: UIViewController {
    
    @IBOutlet var collectionView: UICollectionView!
    
    var FetchResult:PHFetchResult!
    var previousPreheatRect = CGRectZero
    var imageManager:PHCachingImageManager!
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        imageManager = PHCachingImageManager()
        
        let sortOptions = PHFetchOptions()
        
        sortOptions.sortDescriptors = [NSSortDescriptor(key: "startDate", ascending: true)]
        
        self.FetchResult = PHAssetCollection.fetchAssetCollectionsWithType(PHAssetCollectionType.Moment, subtype: PHAssetCollectionSubtype.Any, options: sortOptions)
    }
    
    override func viewWillAppear(animated: Bool) {
        
        super.viewWillAppear(animated)
        
        dispatch_async(dispatch_get_main_queue()) { 
            
            self.collectionView.scrollToBottom(false)
        }
    }
    
    override func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
        
        super.viewWillTransitionToSize(size, withTransitionCoordinator: coordinator)
        
        if let indexPath = self.collectionView.indexPathsForVisibleItems().last,layout = self.collectionView.collectionViewLayout as? MomentCollectionLayout {
        
            layout.naviHeight = size.width > size.height  ? 44 : 64
            
            coordinator.animateAlongsideTransition({ (_) in
                
                self.collectionView.collectionViewLayout.invalidateLayout()
                
                self.collectionView.scrollToItemAtIndexPath(indexPath, atScrollPosition: UICollectionViewScrollPosition.Bottom, animated: false)
                
                }, completion: nil)
        }
    }
}