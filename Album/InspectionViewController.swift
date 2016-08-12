//
//  InspectionViewController.swift
//  Album
//
//  Created by Mister on 16/4/25.
//  Copyright © 2016年 aimobier. All rights reserved.
//

import UIKit
import Photos

class InspectionViewController: UIViewController,PhotoAuthProtocol {

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        self.AuthorizationStatus { (auth) in
            
            let identifier =  auth ? "yes" : "no"
            
            self.performSegueWithIdentifier(identifier, sender: nil)
        }
    }
}



class BaseAlbumViewController:UIViewController{
    
    var FetchResult:PHFetchResult!
    
    @IBOutlet var collectionView: UICollectionView!
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        let back = UIBarButtonItem()
        back.title = ""
        self.navigationItem.backBarButtonItem = back
        
    }
}