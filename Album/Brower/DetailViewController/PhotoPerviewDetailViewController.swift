//
//  PhotoPerviewDetailViewController.swift
//  Album
//
//  Created by Mister on 16/8/11.
//  Copyright © 2016年 aimobier. All rights reserved.
//

import UIKit
import Photos

class PhotoPerviewDetailViewController: UIViewController {
    
    var pageIndex:NSIndexPath!
    
    var asset:PHAsset!
    
    var imageView:UIImageView!
    var scrollView:UIScrollView!
    
    var videoplayer:AVPlayer!
    var videoItem:AVPlayerItem!
    
    private var pan:UIPanGestureRecognizer!
    private var pinch:UIPinchGestureRecognizer!
    
    var imageTap:UITapGestureRecognizer!
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    init(asset:PHAsset,pageIndex:NSIndexPath,imageTap:UITapGestureRecognizer){

        super.init(nibName: nil, bundle: nil)
        
        self.asset = asset
        self.pageIndex = pageIndex
        self.imageTap = imageTap
        
        self.view.backgroundColor = UIColor.clearColor()
        self.automaticallyAdjustsScrollViewInsets = false
        
        self.scrollView = UIScrollView(frame: self.view.bounds)
        self.scrollView.autoresizingMask = [.FlexibleWidth,.FlexibleHeight,.FlexibleTopMargin,.FlexibleLeftMargin,.FlexibleRightMargin,.FlexibleBottomMargin]
        self.scrollView.delegate = self
        self.scrollView.tag = 406
        self.scrollView.maximumZoomScale = 3
        self.scrollView.minimumZoomScale = 1
        self.scrollView.zoomScale = 1
        self.view.addSubview(self.scrollView)
        
        self.pinch = UIPinchGestureRecognizer(target: self, action: #selector(PhotoPerviewDetailViewController.pinchActionBlock(_:)))
        self.pinch.delegate = self
        self.scrollView.addGestureRecognizer(self.pinch)

        self.imageView = UIImageView(frame: self.view.bounds)
        self.imageView.autoresizingMask = [.FlexibleWidth,.FlexibleHeight,.FlexibleTopMargin,.FlexibleLeftMargin,.FlexibleRightMargin,.FlexibleBottomMargin]
        self.imageView.contentMode = .ScaleAspectFit
        self.imageView.clipsToBounds = true
        self.imageView.tag = 506
        self.scrollView.addSubview(self.imageView)
        
        let doubleTap = UITapGestureRecognizer(target: self, action: #selector(PhotoPerviewDetailViewController.doubleTapActionBlock(_:)))
        doubleTap.numberOfTapsRequired = 2
        self.imageView.userInteractionEnabled = true
        self.imageView.addGestureRecognizer(doubleTap)

        imageTap.requireGestureRecognizerToFail(doubleTap)
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
            
            AttributedStringLoader.sharedLoader.asyncImageByAsset(self.asset, cache: false, size: PHImageManagerMaximumSize, finish: { (image) in
                
                dispatch_async(dispatch_get_main_queue(), {
                    
                    self.imageView.image = image
                    
                    self.imageView.setNeedsLayout()
                    
                    self.setMaxMinZoomScalesForCurrentBounds()
                })
            })
        })
    }
    
    
    /**
     处理 pinch 动作
     
     - parameter recongnizer: 动作
     */
    func pinchActionBlock(recognizer:UIPinchGestureRecognizer) {
  
    }
    
    func imageTapActionBlock(gestureRecognizer:UIGestureRecognizer){
        self.setNeedsStatusBarAppearanceUpdate()
        self.prefersStatusBarHidden()
        self.navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    func doubleTapActionBlock(gestureRecognizer:UIGestureRecognizer){
        if self.scrollView.zoomScale > self.scrollView.minimumZoomScale {
            self.scrollView.setZoomScale(self.scrollView.minimumZoomScale, animated: true)
        } else {
            let touchPoint = gestureRecognizer.locationInView(self.imageView)
            self.scrollView.zoomToRect(self.zoomRectForScrollViewWith(self.scrollView.maximumZoomScale, touchPoint: touchPoint), animated: true)
        }
    }
    
    func zoomRectForScrollViewWith(scale: CGFloat, touchPoint: CGPoint) -> CGRect {
        let w = self.scrollView.frame.size.width / scale
        let h = self.scrollView.frame.size.height / scale
        let x = touchPoint.x - (w / 2.0)
        let y = touchPoint.y - (h / 2.0)
        
        return CGRect(x: x, y: y, width: w, height: h)
    }
    
    func setMaxMinZoomScalesForCurrentBounds() {
        
        self.scrollView.maximumZoomScale = 1
        self.scrollView.minimumZoomScale = 1
        self.scrollView.zoomScale = 1
        
        
        let boundsSize = self.scrollView.bounds.size
        let imageSize = self.imageView.frame.size
        
        let xScale = boundsSize.width / imageSize.width
        let yScale = boundsSize.height / imageSize.height
        let minScale: CGFloat = min(xScale, yScale)
        var maxScale: CGFloat!
        
        let scale = UIScreen.mainScreen().scale
        let deviceScreenWidth = UIScreen.mainScreen().bounds.width * scale // width in pixels. scale needs to remove if to use the old algorithm
        let deviceScreenHeight = UIScreen.mainScreen().bounds.height * scale // height in pixels. scale needs to remove if to use the old algorithm
        
        if self.imageView.frame.width < deviceScreenWidth {
            // I think that we should to get coefficient between device screen width and image width and assign it to maxScale. I made two mode that we will get the same result for different device orientations.
            if UIApplication.sharedApplication().statusBarOrientation.isPortrait {
                maxScale = deviceScreenHeight / self.imageView.frame.width
            } else {
                maxScale = deviceScreenWidth / self.imageView.frame.width
            }
        } else if self.imageView.frame.width > deviceScreenWidth {
            maxScale = 1.0
        } else {
            // here if photoImageView.frame.width == deviceScreenWidth
            maxScale = 2.5
        }
        
        self.scrollView.maximumZoomScale = maxScale
        self.scrollView.minimumZoomScale = minScale
        self.scrollView.zoomScale = minScale
        
        // reset position
        self.imageView.frame = CGRect(x: 0, y: 0, width: self.imageView.frame.size.width, height: self.imageView.frame.size.height)
        self.scrollView.setNeedsLayout()
        
        
        
    }
    
    /**
     让图片居中
     */
    func centerImageView (){
        
        self.scrollView.bounces = false
        self.scrollView.alwaysBounceVertical = false
        self.scrollView.alwaysBounceHorizontal = true
        
        let boundsSize = self.scrollView.bounds.size
        var frameToCenter = self.imageView.frame
        
        // horizon
        frameToCenter.origin.x = frameToCenter.size.width < boundsSize.width ? floor((boundsSize.width - frameToCenter.size.width) / 2) : 0
        // vertical
        frameToCenter.origin.y = frameToCenter.size.height < boundsSize.height ? floor((boundsSize.height - frameToCenter.size.height) / 2) : 0
        // Center
        if !CGRectEqualToRect(self.imageView.frame, frameToCenter) {
            self.imageView.frame = frameToCenter
        }
    }
}

extension PhotoPerviewDetailViewController : UIScrollViewDelegate{

    // MARK: - UIScrollViewDelegate
    func viewForZoomingInScrollView(scrollView: UIScrollView) -> UIView? {
        return imageView
    }
    
    func scrollViewWillBeginZooming(scrollView: UIScrollView, withView view: UIView?) {
        //        photoBrowser?.cancelControlHiding()
    }
    
    func scrollViewDidZoom(scrollView: UIScrollView) {
        
        
        self.centerImageView()
        
        self.scrollView.layoutIfNeeded()
        self.imageView.layoutIfNeeded()
    }
    
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        
//        print(scrollView.contentOffset.x)
    }
    
}



extension PhotoPerviewDetailViewController : UIGestureRecognizerDelegate{

    
    
}