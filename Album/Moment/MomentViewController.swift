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
    
    var FetchResult:PHFetchResult<PHAssetCollection>!
    
    var previousPreheatRect = CGRect.zero
    var imageManager:PHCachingImageManager!
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        imageManager = PHCachingImageManager()
        
        let sortOptions = PHFetchOptions()
        
        sortOptions.sortDescriptors = [NSSortDescriptor(key: "startDate", ascending: true)]
        
        self.FetchResult = PHAssetCollection.fetchAssetCollections(with: PHAssetCollectionType.moment, subtype: PHAssetCollectionSubtype.any, options: sortOptions)
        
        PHPhotoLibrary.shared().register(self)
    }
    
    fileprivate var isFirst = true
    
    override func viewWillAppear(_ animated: Bool) {
        
        super.viewWillAppear(animated)
        
        if !isFirst { return }
        
        isFirst = false
        
        DispatchQueue.main.async { 
            
            self.collectionView.scrollToBottom(false)
        }
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        
        super.viewWillTransition(to: size, with: coordinator)
        
        if let indexPath = self.collectionView.indexPathsForVisibleItems.last,let layout = self.collectionView.collectionViewLayout as? MomentCollectionLayout {
        
            layout.naviHeight = size.width > size.height  ? 44 : 64
            
            coordinator.animate(alongsideTransition: { (_) in
                
                self.collectionView.collectionViewLayout.invalidateLayout()
                
                self.collectionView.scrollToItem(at: indexPath, at: UICollectionViewScrollPosition.bottom, animated: false)
                
                }, completion: nil)
        }
    }
}



extension MomentViewController : PHPhotoLibraryChangeObserver{

    func photoLibraryDidChange(_ changeInstance: PHChange) {
        DispatchQueue.main.async {
            guard let collectionChanges = changeInstance.changeDetails(for: self.FetchResult) else { return }
            
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
