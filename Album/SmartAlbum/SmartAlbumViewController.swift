//
//  SmartAlbumViewController.swift
//  Album
//
//  Created by Mister on 16/8/12.
//  Copyright © 2016年 aimobier. All rights reserved.
//

import UIKit
import Photos

class SmartAlbumViewController: UIViewController {
    
    @IBOutlet var tableView: UITableView!
    
    var FetchResult = NSMutableArray()
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        self.tableView.estimatedRowHeight = 84
        
        PHPhotoLibrary.sharedPhotoLibrary().registerChangeObserver(self)
        
        self.reloadTableViewDataSource()
    }
    
    private func reloadTableViewDataSource(){
        
        let sortOptions = PHFetchOptions()
        
        sortOptions.sortDescriptors = [NSSortDescriptor(key: "startDate", ascending: true)]
        
        let results = PHAssetCollection.fetchAssetCollectionsWithType(PHAssetCollectionType.SmartAlbum, subtype: PHAssetCollectionSubtype.Any, options: sortOptions)
        
        guard let copyResults = results.objectsAtIndexes(NSIndexSet(indexesInRange: NSRange(location: 0, length: results.count))) as? [PHAssetCollection] else { return }
        
        let newResults = NSMutableArray(array: copyResults)
        
        results.enumerateObjectsUsingBlock { (coll, _, _) in
            
            if let collection = coll as? PHAssetCollection{
                
                if collection.photosCount <= 0 && newResults.containsObject(collection){
                
                    newResults.removeObject(collection)
                }
            }
        }
        
        self.FetchResult = newResults
        
        self.tableView.reloadData()
    }
}

extension SmartAlbumViewController : PHPhotoLibraryChangeObserver{
    
    func photoLibraryDidChange(changeInstance: PHChange) {
        
        dispatch_async(dispatch_get_main_queue()) {
            
            self.reloadTableViewDataSource()
        }
    }
}

extension SmartAlbumViewController:UITableViewDataSource{

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return self.FetchResult.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("albumcell") as! AlbumTableViewCell
        
        if let collection = self.FetchResult.objectAtIndex(indexPath.row) as? PHAssetCollection{
        
            cell.setAssetCollection(collection)
        }
        
        return cell
    }
}


extension SmartAlbumViewController:UITableViewDelegate{

    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        if let collection = self.FetchResult.objectAtIndex(indexPath.row) as? PHAssetCollection{
            
            let viewController = self.getSmartDetailViewController(collection)
            
            self.navigationController?.pushViewController(viewController, animated: true)
        }
    }
    
    
    private func getSmartDetailViewController(collection:PHAssetCollection) -> SmartDetailViewController{
    
        let viewController = self.storyboard?.instantiateViewControllerWithIdentifier("SmartDetailViewController") as! SmartDetailViewController
        
        viewController.AssetCollection = collection
        
        return viewController
    }
}