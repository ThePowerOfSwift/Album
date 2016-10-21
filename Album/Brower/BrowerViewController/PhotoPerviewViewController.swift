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
    var pageIndex:IndexPath = IndexPath(item: 0, section: 0)
    var pageViewController:UIPageViewController!
    var momentViewController:BaseAlbumViewController!
    var imageTap:UITapGestureRecognizer!
    var hiddenStatusBar = false
    
    override var prefersStatusBarHidden : Bool {
        
        return hiddenStatusBar
    }
    
    init(pageIndex:IndexPath,momentViewController:BaseAlbumViewController!) {
        
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
        
        self.pageViewController = UIPageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal, options: [UIPageViewControllerOptionInterPageSpacingKey : 30])
        self.pageViewController.delegate = self
        self.pageViewController.dataSource = self
        self.pageViewController.automaticallyAdjustsScrollViewInsets = false
        self.automaticallyAdjustsScrollViewInsets = false
        
        self.addChildViewController(self.pageViewController)
        self.pageViewController.didMove(toParentViewController: self)
        self.view.addSubview(self.pageViewController.view)
        
        self.pageViewController.view.snp.makeConstraints { (make) in
            make.edges.equalTo(self.view)
        }
        
        self.view.backgroundColor = UIColor.white
        self.pageViewController.view.backgroundColor = UIColor.white
        
        imageTap = UITapGestureRecognizer(target: self, action: #selector(PhotoPerviewViewController.imageTapActionBlock(_:)))
        imageTap.numberOfTapsRequired = 1
        self.view.addGestureRecognizer(imageTap)
        
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: UIBarButtonItemStyle.plain, closure: { 
            
        })
        
        self.reloadData()
        
        self.InitTitleLabel()
        
        self.PageFinishAnimatingChangeTitle()
    }
    
    fileprivate func InitTitleLabel(){
        
        self.titleView.frame = CGRect(origin: CGPoint.zero, size: CGSize(width: 200, height: 30))
        
        self.navigationItem.titleView = self.titleView

        self.titleLabel.textAlignment = .center
        self.subTitleLabel.textAlignment = .center
        
        self.titleLabel.textColor = UIColor.black
        self.subTitleLabel.textColor = UIColor.black
        
        self.titleLabel.font = UIFont.systemFont(ofSize: 15)
        self.subTitleLabel.font = UIFont.systemFont(ofSize: 11)
        
        self.titleView.addSubview(self.titleLabel)
        self.titleView.addSubview(self.subTitleLabel)
        
        self.titleLabel.snp.makeConstraints { (make) in
            
            make.centerX.equalTo(self.titleView)
            make.top.equalTo(1)
        }
        
        self.subTitleLabel.snp.makeConstraints { (make) in
            
            make.centerX.equalTo(self.titleView)
            make.top.equalTo(self.titleLabel.snp.bottom)
        }
    }
    
    override var previewActionItems : [UIPreviewActionItem] {
        
        let action1 = UIPreviewAction(title: "即使如此", style: UIPreviewActionStyle.default) { (_, _) in
            
        }
        
        let action2 = UIPreviewAction(title: "我们大家", style: UIPreviewActionStyle.selected) { (_, _) in
            
        }
        
        let action3 = UIPreviewAction(title: "还是如此的快乐", style: UIPreviewActionStyle.destructive) { (_, _) in
            
        }
        
        return [action1,action2,action3]
    }
    
    func imageTapActionBlock(_ gestureRecognizer:UIGestureRecognizer){
        
        let hidden = self.prefersStatusBarHidden
        self.hiddenStatusBar = !hidden
        
        self.navigationController?.setNavigationBarHidden(self.hiddenStatusBar, animated: false)
        
        self.tabBarController?.tabBar.isHidden = self.hiddenStatusBar
        self.setNeedsStatusBarAppearanceUpdate()
        self.view.backgroundColor = self.hiddenStatusBar ? UIColor.black : UIColor.white
        self.pageViewController.view.backgroundColor = self.view.backgroundColor
    }
    
    func reloadData(){
        
        if isMoments {
        
            if let viewController = self.momentViewController as? MomentViewController{
                
                let collection =  viewController.FetchResult.object(at: (pageIndex as NSIndexPath).section)
                
                let asset = PHAsset.SoreCreateTime(collection).object(at: (pageIndex as NSIndexPath).item) as! PHAsset
                
                let viewController = PhotoPerviewDetailViewController(asset: asset, pageIndex: self.pageIndex,imageTap: self.imageTap)
                
                self.pageViewController.setViewControllers([viewController], direction: .forward, animated: false, completion: nil)
            }
        }else{
        
            if let viewController = self.momentViewController as? SmartDetailViewController{
                
                if let asset = viewController.FetchResult.object(at: (pageIndex as NSIndexPath).item) as? PHAsset{
                    
                    let viewController = PhotoPerviewDetailViewController(asset: asset, pageIndex: self.pageIndex,imageTap: self.imageTap)
                    
                    self.pageViewController.setViewControllers([viewController], direction: .forward, animated: false, completion: nil)
                }
            }
            
            
        }
    }
}


extension PhotoPerviewViewController : UIPageViewControllerDelegate,UIPageViewControllerDataSource{

    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController?{
        
        let collectionView = self.momentViewController.collectionView
        
        var toviewController:PhotoPerviewDetailViewController!
        
        guard let viewC = viewController as? PhotoPerviewDetailViewController,let npageIndex = viewC.pageIndex.indexPathPrevious(collectionView!) else { return nil }
        
        if let viewController = self.momentViewController as? MomentViewController {
        
            let collection = viewController.FetchResult.object(at: (npageIndex as NSIndexPath).section)
            
            if let asset = PHAsset.SoreCreateTime(collection).object(at: (npageIndex as NSIndexPath).item) as? PHAsset {
                
                toviewController = PhotoPerviewDetailViewController(asset: asset, pageIndex: npageIndex,imageTap: self.imageTap)
            }
        }
        
        if let viewController = self.momentViewController as? SmartDetailViewController {
            
            let asset = viewController.FetchResult.object(at: (npageIndex as NSIndexPath).item)
            
            toviewController = PhotoPerviewDetailViewController(asset: asset, pageIndex: npageIndex,imageTap: self.imageTap)
        }

        self.pageIndex = npageIndex
        
        return toviewController
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController?{
    
        let collectionView = self.momentViewController.collectionView
        
        var toviewController:PhotoPerviewDetailViewController!
        
        guard let viewC = viewController as? PhotoPerviewDetailViewController,let npageIndex = viewC.pageIndex.indexPathNext(collectionView!) else { return nil }
        
        if let viewController = self.momentViewController as? MomentViewController {
            
            let collection = viewController.FetchResult.object(at: (npageIndex as NSIndexPath).section)
            
            if let asset = PHAsset.SoreCreateTime(collection).object(at: (npageIndex as NSIndexPath).item) as? PHAsset {
                
                toviewController = PhotoPerviewDetailViewController(asset: asset, pageIndex: npageIndex,imageTap: self.imageTap)
            }
        }
        
        if let viewController = self.momentViewController as? SmartDetailViewController {
            
            let asset = viewController.FetchResult.object(at: (npageIndex as NSIndexPath).item)
            
            toviewController = PhotoPerviewDetailViewController(asset: asset, pageIndex: npageIndex,imageTap: self.imageTap)
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
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        
        if completed {
            
            self.PageFinishAnimatingChangeTitle()
        }
    }
    
    /**
     修复 标题 和 字标题
     */
    fileprivate func PageFinishAnimatingChangeTitle(){
    
        if let createData = (self.pageViewController.viewControllers?.first as? PhotoPerviewDetailViewController)?.asset.creationDate {
            
            self.titleLabel.text = createData.PictureCreateTimeStr()
            
            let string = createData.hour() > 12 ? "下午" : "上午"
            
            self.subTitleLabel.text = "\(string)\(createData.toString(DateFormat.custom("h:mm")))"
            
            self.titleView.layoutIfNeeded()
        }
    }
}





