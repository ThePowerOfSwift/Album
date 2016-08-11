//
//  PhotoPerviewViewController.swift
//  Album
//
//  Created by Mister on 16/8/10.
//  Copyright © 2016年 aimobier. All rights reserved.
//

import UIKit
import Photos
import SnapKit

class PhotoPerviewViewController: UIViewController {
    
    var pageIndex:NSIndexPath = NSIndexPath(forItem: 0, inSection: 0)
    
    var pageViewController:UIPageViewController!
    
    var momentViewController:MomentViewController!
    
    var imageTap:UITapGestureRecognizer!
    
    var hiddenStatusBar = false
    
    override func prefersStatusBarHidden() -> Bool {
        
        return hiddenStatusBar
    }
    
    init(pageIndex:NSIndexPath,momentViewController:MomentViewController!) {
        super.init(nibName: nil, bundle: nil)
        
        self.pageIndex = pageIndex
        self.momentViewController = momentViewController
        
//        self.hidesBottomBarWhenPushed = true
        self.momentViewController.navigationController?.delegate = self
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        self.pageViewController = UIPageViewController(transitionStyle: .Scroll, navigationOrientation: .Horizontal, options: [UIPageViewControllerOptionInterPageSpacingKey : 30])
        self.pageViewController.delegate = self
        self.pageViewController.dataSource = self
        self.pageViewController.automaticallyAdjustsScrollViewInsets = false
        self.automaticallyAdjustsScrollViewInsets = false
        
        self.addChildViewController(self.pageViewController)
        self.pageViewController.didMoveToParentViewController(self)
        self.view.addSubview(self.pageViewController.view)
        
        self.pageViewController.view.snp_makeConstraints { (make) in
            make.edges.equalTo(self.view)
        }
        
        self.view.backgroundColor = UIColor.whiteColor()
        self.pageViewController.view.backgroundColor = UIColor.whiteColor()
        
        imageTap = UITapGestureRecognizer(target: self, action: #selector(PhotoPerviewViewController.imageTapActionBlock(_:)))
        imageTap.numberOfTapsRequired = 1
        self.view.addGestureRecognizer(imageTap)
        
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: UIBarButtonItemStyle.Plain, closure: { 
            
        })
        
        self.reloadData()
    }
    
    func imageTapActionBlock(gestureRecognizer:UIGestureRecognizer){
        
        let hidden = self.prefersStatusBarHidden()
        self.hiddenStatusBar = !hidden
        
        self.navigationController?.setNavigationBarHidden(self.hiddenStatusBar, animated: false)
        
        UIView.animateWithDuration(0.4) {
            self.tabBarController?.tabBar.hidden = self.hiddenStatusBar
            self.setNeedsStatusBarAppearanceUpdate()
            self.view.backgroundColor = self.hiddenStatusBar ? UIColor.blackColor() : UIColor.whiteColor()
            self.pageViewController.view.backgroundColor = self.view.backgroundColor
        }
    }
    
    func reloadData(){
    
        if let collection = self.momentViewController.FetchResult.objectAtIndex(pageIndex.section) as? PHAssetCollection{
            
            let asset = PHAsset.SoreCreateTime(collection).objectAtIndex(pageIndex.item) as! PHAsset
            
            let viewController = PhotoPerviewDetailViewController(asset: asset, pageIndex: self.pageIndex,imageTap: self.imageTap)
            
            self.pageViewController.setViewControllers([viewController], direction: .Forward, animated: false, completion: nil)
        }
    }
}


extension PhotoPerviewViewController : UIPageViewControllerDelegate,UIPageViewControllerDataSource{

    func pageViewController(pageViewController: UIPageViewController, viewControllerBeforeViewController viewController: UIViewController) -> UIViewController?{
        
        let collectionView = self.momentViewController.collectionView
        
        guard let viewC = viewController as? PhotoPerviewDetailViewController,npageIndex = viewC.pageIndex.indexPathPrevious(collectionView),collection = self.momentViewController.FetchResult.objectAtIndex(npageIndex.section) as? PHAssetCollection,asset = PHAsset.SoreCreateTime(collection).objectAtIndex(npageIndex.item) as? PHAsset else { return nil }
        
        self.pageIndex = npageIndex
        
        let viewController = PhotoPerviewDetailViewController(asset: asset, pageIndex: npageIndex,imageTap: self.imageTap)
        
        return viewController
    }
    
    func pageViewController(pageViewController: UIPageViewController, viewControllerAfterViewController viewController: UIViewController) -> UIViewController?{
    
        let collectionView = self.momentViewController.collectionView
        
        guard let viewC = viewController as? PhotoPerviewDetailViewController,npageIndex = viewC.pageIndex.indexPathNext(collectionView),collection = self.momentViewController.FetchResult.objectAtIndex(npageIndex.section) as? PHAssetCollection,asset = PHAsset.SoreCreateTime(collection).objectAtIndex(npageIndex.item) as? PHAsset else { return nil }
        
        self.pageIndex = npageIndex
        
        let viewController = PhotoPerviewDetailViewController(asset: asset, pageIndex: npageIndex,imageTap: self.imageTap)
        
        return viewController
    }
}





