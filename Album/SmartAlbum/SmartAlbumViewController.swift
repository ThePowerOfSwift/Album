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
        
        PHPhotoLibrary.shared().register(self)
        
        self.reloadTableViewDataSource()
    }
    
    fileprivate func reloadTableViewDataSource(){
        
        let sortOptions = PHFetchOptions()
        
        sortOptions.sortDescriptors = [NSSortDescriptor(key: "startDate", ascending: true)]
        
        
        let SmartAlbumResults = PHAssetCollection.fetchAssetCollections(with: PHAssetCollectionType.smartAlbum, subtype: PHAssetCollectionSubtype.any, options: sortOptions)
        let AlbumResults = PHAssetCollection.fetchAssetCollections(with: PHAssetCollectionType.album, subtype: PHAssetCollectionSubtype.any, options: sortOptions)
        
        let CopyAlbumResults = AlbumResults.objects(at: IndexSet(integersIn: NSRange(location: 0, length: AlbumResults.count).toRange() ?? 0..<0)).filter({ $0.photosCount > 0 })
        let CopySmartAlbumResults = SmartAlbumResults.objects(at: IndexSet(integersIn: NSRange(location: 0, length: SmartAlbumResults.count).toRange() ?? 0..<0)).filter({ $0.photosCount > 0 })
        
        let newResults = NSMutableArray(array: CopySmartAlbumResults)
        newResults.addObjects(from: CopyAlbumResults)
        
        self.FetchResult = newResults
        
        self.tableView.reloadData()
    }
}

extension SmartAlbumViewController : PHPhotoLibraryChangeObserver{
    
    func photoLibraryDidChange(_ changeInstance: PHChange) {
        
        DispatchQueue.main.async {
            
            self.reloadTableViewDataSource()
        }
    }
}

extension SmartAlbumViewController:UITableViewDataSource{

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return self.FetchResult.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "albumcell") as! AlbumTableViewCell
        
        if let collection = self.FetchResult.object(at: (indexPath as NSIndexPath).row) as? PHAssetCollection{
        
            cell.setAssetCollection(collection)
        }
        
        return cell
    }
}


extension SmartAlbumViewController:UITableViewDelegate{

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if let collection = self.FetchResult.object(at: (indexPath as NSIndexPath).row) as? PHAssetCollection{
            
            let viewController = self.getSmartDetailViewController(collection)
            
            self.navigationController?.pushViewController(viewController, animated: true)
        }
    }
    
    
    fileprivate func getSmartDetailViewController(_ collection:PHAssetCollection) -> SmartDetailViewController{
    
        let viewController = self.storyboard?.instantiateViewController(withIdentifier: "SmartDetailViewController") as! SmartDetailViewController
        
        viewController.AssetCollection = collection
        
        return viewController
    }
}
