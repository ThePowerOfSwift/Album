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
    
    var titleView = UIView()
    var titleLabel = UILabel()
    var subTitleLabel = UILabel()
    
    var isMoments = true
    var pageIndex:NSIndexPath = NSIndexPath(forItem: 0, inSection: 0)
    var pageViewController:UIPageViewController!
    var momentViewController:BaseAlbumViewController!
    var imageTap:UITapGestureRecognizer!
    var hiddenStatusBar = false
    
    override func prefersStatusBarHidden() -> Bool {
        
        return hiddenStatusBar
    }
    
    init(pageIndex:NSIndexPath,momentViewController:BaseAlbumViewController!) {
        
        super.init(nibName: nil, bundle: nil)
        
        self.pageIndex = pageIndex
        
        self.momentViewController = momentViewController
        
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
        
        self.InitTitleLabel()
        
        self.PageFinishAnimatingChangeTitle()
    }
    
    private func InitTitleLabel(){
        
        self.titleView.frame = CGRect(origin: CGPointZero, size: CGSize(width: 200, height: 30))
        
        self.navigationItem.titleView = self.titleView

        self.titleLabel.textAlignment = .Center
        self.subTitleLabel.textAlignment = .Center
        
        self.titleLabel.textColor = UIColor.blackColor()
        self.subTitleLabel.textColor = UIColor.blackColor()
        
        self.titleLabel.font = UIFont.systemFontOfSize(15)
        self.subTitleLabel.font = UIFont.systemFontOfSize(11)
        
        self.titleView.addSubview(self.titleLabel)
        self.titleView.addSubview(self.subTitleLabel)
        
        self.titleLabel.snp_makeConstraints { (make) in
            
            make.centerX.equalTo(self.titleView)
            make.top.equalTo(1)
        }
        
        self.subTitleLabel.snp_makeConstraints { (make) in
            
            make.centerX.equalTo(self.titleView)
            make.top.equalTo(self.titleLabel.snp_bottom)
        }
    }
    
    override func previewActionItems() -> [UIPreviewActionItem] {
        
        let action1 = UIPreviewAction(title: "即使如此", style: UIPreviewActionStyle.Default) { (_, _) in
            
        }
        
        let action2 = UIPreviewAction(title: "我们大家", style: UIPreviewActionStyle.Selected) { (_, _) in
            
        }
        
        let action3 = UIPreviewAction(title: "还是如此的快乐", style: UIPreviewActionStyle.Destructive) { (_, _) in
            
        }
        
        return [action1,action2,action3]
    }
    
    func imageTapActionBlock(gestureRecognizer:UIGestureRecognizer){
        
        let hidden = self.prefersStatusBarHidden()
        self.hiddenStatusBar = !hidden
        
        self.navigationController?.setNavigationBarHidden(self.hiddenStatusBar, animated: false)
        
        self.tabBarController?.tabBar.hidden = self.hiddenStatusBar
        self.setNeedsStatusBarAppearanceUpdate()
        self.view.backgroundColor = self.hiddenStatusBar ? UIColor.blackColor() : UIColor.whiteColor()
        self.pageViewController.view.backgroundColor = self.view.backgroundColor
    }
    
    func reloadData(){
        
        if isMoments {
        
            if let collection = self.momentViewController.FetchResult.objectAtIndex(pageIndex.section) as? PHAssetCollection{
                
                let asset = PHAsset.SoreCreateTime(collection).objectAtIndex(pageIndex.item) as! PHAsset
                
                let viewController = PhotoPerviewDetailViewController(asset: asset, pageIndex: self.pageIndex,imageTap: self.imageTap)
                
                self.pageViewController.setViewControllers([viewController], direction: .Forward, animated: false, completion: nil)
            }
        }else{
        
            if let asset = self.momentViewController.FetchResult.objectAtIndex(pageIndex.item) as? PHAsset{
                
                let viewController = PhotoPerviewDetailViewController(asset: asset, pageIndex: self.pageIndex,imageTap: self.imageTap)
                
                self.pageViewController.setViewControllers([viewController], direction: .Forward, animated: false, completion: nil)
            }
        }
    }
}


extension PhotoPerviewViewController : UIPageViewControllerDelegate,UIPageViewControllerDataSource{

    func pageViewController(pageViewController: UIPageViewController, viewControllerBeforeViewController viewController: UIViewController) -> UIViewController?{
        
        let collectionView = self.momentViewController.collectionView
        
        var toviewController:PhotoPerviewDetailViewController!
        
        guard let viewC = viewController as? PhotoPerviewDetailViewController,npageIndex = viewC.pageIndex.indexPathPrevious(collectionView) else { return nil }
        
        if isMoments{
        
            if let collection = self.momentViewController.FetchResult.objectAtIndex(npageIndex.section) as? PHAssetCollection,asset = PHAsset.SoreCreateTime(collection).objectAtIndex(npageIndex.item) as? PHAsset {
                
                toviewController = PhotoPerviewDetailViewController(asset: asset, pageIndex: npageIndex,imageTap: self.imageTap)
            }
        }else{
        
            if let asset = self.momentViewController.FetchResult.objectAtIndex(npageIndex.item) as? PHAsset {
                
                toviewController = PhotoPerviewDetailViewController(asset: asset, pageIndex: npageIndex,imageTap: self.imageTap)
            }
        }
        
        self.pageIndex = npageIndex
        
        return toviewController
    }
    
    func pageViewController(pageViewController: UIPageViewController, viewControllerAfterViewController viewController: UIViewController) -> UIViewController?{
    
        let collectionView = self.momentViewController.collectionView
        
        var toviewController:PhotoPerviewDetailViewController!
        
        guard let viewC = viewController as? PhotoPerviewDetailViewController,npageIndex = viewC.pageIndex.indexPathNext(collectionView) else { return nil }
        
        if isMoments{
            
            if let collection = self.momentViewController.FetchResult.objectAtIndex(npageIndex.section) as? PHAssetCollection,asset = PHAsset.SoreCreateTime(collection).objectAtIndex(npageIndex.item) as? PHAsset {
                
                toviewController = PhotoPerviewDetailViewController(asset: asset, pageIndex: npageIndex,imageTap: self.imageTap)
            }
        }else{
            
            if let asset = self.momentViewController.FetchResult.objectAtIndex(npageIndex.item) as? PHAsset {
                
                toviewController = PhotoPerviewDetailViewController(asset: asset, pageIndex: npageIndex,imageTap: self.imageTap)
            }
        }
        
        self.pageIndex = npageIndex
        
        return toviewController
    }
    
    /**
     当滑动的视图 完成 时候
     
     - parameter pageViewController:      分页视图
     - parameter finished:                动画完成参数
     - parameter previousViewControllers: 预览的 视图ViewController
     - parameter completed:               <#completed description#>
     */
    func pageViewController(pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        
        if completed {
            
            self.PageFinishAnimatingChangeTitle()
        }
    }
    
    /**
     修复 标题 和 字标题
     */
    private func PageFinishAnimatingChangeTitle(){
    
        if let createData = (self.pageViewController.viewControllers?.first as? PhotoPerviewDetailViewController)?.asset.creationDate {
            
            self.titleLabel.text = createData.PictureCreateTimeStr()
            
            let string = createData.hour() > 12 ? "下午" : "上午"
            
            self.subTitleLabel.text = "\(string)\(createData.toString(format: DateFormat.Custom("h:mm")))"
            
            self.titleView.layoutIfNeeded()
        }
    }
}





