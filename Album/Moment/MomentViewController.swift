//
//  MomentViewController.swift
//  Album
//
//  Created by Mister on 16/4/25.
//  Copyright © 2016年 aimobier. All rights reserved.
//

import UIKit
import Photos

class MomentViewController: BaseAlbumViewController {
    
    
    var previousPreheatRect = CGRectZero
    var imageManager:PHCachingImageManager!
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        imageManager = PHCachingImageManager()
        
        let sortOptions = PHFetchOptions()
        
        sortOptions.sortDescriptors = [NSSortDescriptor(key: "startDate", ascending: true)]
        
        self.FetchResult = PHAssetCollection.fetchAssetCollectionsWithType(PHAssetCollectionType.Moment, subtype: PHAssetCollectionSubtype.Any, options: sortOptions)
        
        PHPhotoLibrary.sharedPhotoLibrary().registerChangeObserver(self)
    }
    
    private var isFirst = true
    
    override func viewWillAppear(animated: Bool) {
        
        super.viewWillAppear(animated)
        
        if !isFirst { return }
        
        isFirst = false
        
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



extension MomentViewController : PHPhotoLibraryChangeObserver{

    func photoLibraryDidChange(changeInstance: PHChange) {
        dispatch_async(dispatch_get_main_queue()) {
            guard let collectionChanges = changeInstance.changeDetailsForFetchResult(self.FetchResult) else { return }
            
            self.FetchResult = collectionChanges.fetchResultAfterChanges
            
            if !collectionChanges.hasIncrementalChanges || collectionChanges.hasMoves {
                self.collectionView.reloadData()
            } else {
                
                self.collectionView.reloadData()
//                self.collectionView.performBatchUpdates({
//                    let removedIndexes = collectionChanges.removedIndexes
//                    if (removedIndexes?.count ?? 0) != 0 {
//                        self.collectionView.deleteItemsAtIndexPaths(removedIndexes!.indexPaths(from: 0))
//                    }
//                    
//                    let insertedIndexes = collectionChanges.insertedIndexes
//                    if (insertedIndexes?.count ?? 0) != 0 {
//                        self.collectionView.insertItemsAtIndexPaths(insertedIndexes!.indexPaths(from: 0))
//                    }
//                    
//                    let changedIndexes = collectionChanges.changedIndexes
//                    if (changedIndexes?.count ?? 0) != 0 {
//                        self.collectionView.reloadItemsAtIndexPaths(changedIndexes!.indexPaths(from: 0))
//                    }
//                    
//                    }, completion: nil)
            }
        }
    }
}