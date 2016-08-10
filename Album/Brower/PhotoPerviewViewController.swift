//
//  PhotoPerviewViewController.swift
//  Album
//
//  Created by Mister on 16/8/10.
//  Copyright © 2016年 aimobier. All rights reserved.
//

import UIKit

class PhotoPerviewViewController: UIViewController {
    
    private var pageViewController:UIPageViewController!
    
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
    }
}


extension PhotoPerviewViewController : UIPageViewControllerDelegate,UIPageViewControllerDataSource{

    
}