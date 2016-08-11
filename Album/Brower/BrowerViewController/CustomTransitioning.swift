//
//  CustomTransitioning.swift
//  Album
//
//  Created by Mister on 16/8/11.
//  Copyright © 2016年 aimobier. All rights reserved.
//

import UIKit
import Photos

extension PhotoPerviewViewController: UINavigationControllerDelegate{

    func navigationController(navigationController: UINavigationController, animationControllerForOperation operation: UINavigationControllerOperation, fromViewController fromVC: UIViewController, toViewController toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        
        if operation == .Pop { return CustomPopAnimatedTransitioning() }
        
        return CustomPushAnimatedTransitioning()
    }
    
    func navigationController(navigationController: UINavigationController, interactionControllerForAnimationController animationController: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        
        return nil
    }
    
}

class CustomPopAnimatedTransitioning:NSObject, UIViewControllerAnimatedTransitioning {
    
    func transitionDuration(transitionContext: UIViewControllerContextTransitioning?) -> NSTimeInterval {
        
        return 0.5
    }
    
    func animateTransition(transitionContext: UIViewControllerContextTransitioning) {
        
        guard let containerView = transitionContext.containerView() else { return transitionContext.completeTransition(true) }
        guard let toViewController = transitionContext.viewControllerForKey(UITransitionContextToViewControllerKey) as? MomentViewController else { return transitionContext.completeTransition(true) }
        guard let fromViewController = transitionContext.viewControllerForKey(UITransitionContextFromViewControllerKey) as? PhotoPerviewViewController else { return transitionContext.completeTransition(true) }
        guard let toDetailViewController = fromViewController.pageViewController.viewControllers?.first as? PhotoPerviewDetailViewController else { return transitionContext.completeTransition(true) }
        
        containerView.addSubview(fromViewController.view)
        containerView.addSubview(toViewController.view)
        
        toViewController.collectionView.scrollToItemAtIndexPath(fromViewController.pageIndex, atScrollPosition: UICollectionViewScrollPosition.CenteredVertically, animated: false)
        
        dispatch_async(dispatch_get_main_queue()) { 
            
            guard let cell = toViewController.collectionView.cellForItemAtIndexPath(toDetailViewController.pageIndex) as? MomentCell else { return transitionContext.completeTransition(true) }
            
            let toFrame = cell.convertRect(cell.imageView.bounds, toView: toViewController.view)
            
            let imageView = cell.cloneImageView(toDetailViewController.asset)
            
            let fromFrame = fromViewController.view.convertRect(toDetailViewController.imageView.bounds, fromView: toDetailViewController.view)
            imageView.frame = fromFrame
            
            
            containerView.addSubview(imageView)
            
            cell.imageView.alpha = 0
            toDetailViewController.imageView.alpha = 0
            
            UIView.animateWithDuration(0.5, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0, options: .CurveEaseInOut, animations: {
                imageView.contentMode = .ScaleAspectFill
                imageView.frame = toFrame
            }) { (_) in
                imageView.removeFromSuperview()
                cell.imageView.alpha = 1
                toDetailViewController.imageView.alpha = 1
                transitionContext.completeTransition(true)
            }
        }
    }
}


class CustomPushAnimatedTransitioning:NSObject, UIViewControllerAnimatedTransitioning {
    
    func transitionDuration(transitionContext: UIViewControllerContextTransitioning?) -> NSTimeInterval {
        
        return 0.5
    }
    
    func animateTransition(transitionContext: UIViewControllerContextTransitioning) {
        
        guard let containerView = transitionContext.containerView() else { return transitionContext.completeTransition(true) }
        guard let toViewController = transitionContext.viewControllerForKey(UITransitionContextToViewControllerKey) as? PhotoPerviewViewController else { return transitionContext.completeTransition(true) }
        guard let toDetailViewController = toViewController.pageViewController.viewControllers?.first as? PhotoPerviewDetailViewController else { return transitionContext.completeTransition(true) }
        guard let fromViewController = transitionContext.viewControllerForKey(UITransitionContextFromViewControllerKey) as? MomentViewController else { return transitionContext.completeTransition(true) }
        guard let cell = fromViewController.collectionView.cellForItemAtIndexPath(toViewController.pageIndex) as? MomentCell else { return transitionContext.completeTransition(true) }
        
        containerView.addSubview(fromViewController.view)
        containerView.addSubview(toViewController.view)
        
        let imageView = cell.cloneImageView(toDetailViewController.asset)
        
        let fromFrame = cell.convertRect(cell.imageView.bounds, toView: fromViewController.view)
        imageView.frame = fromFrame
        let toFrame = toDetailViewController.scrollView.convertRect(toDetailViewController.imageView.bounds, toView: toDetailViewController.view)
        
        containerView.addSubview(imageView)
        
        cell.imageView.alpha = 0
        toDetailViewController.imageView.alpha = 0
        
        UIView.animateWithDuration(0.5, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0, options: .CurveEaseInOut, animations: {
            imageView.contentMode = .ScaleAspectFit
            imageView.frame = toFrame
        }) { (_) in
            imageView.removeFromSuperview()
            cell.imageView.alpha = 1
            toDetailViewController.imageView.alpha = 1
            transitionContext.completeTransition(true)
        }
    }
}


extension MomentCell{

    /**
     根据提供的 cell 和一些列参数
     
     - parameter asset:              提供的获取照片的参数
     - parameter fromViewController: 来源数据
     
     - returns: 返回科隆的 UImageview
     */
    func cloneImageView(asset:PHAsset) -> UIImageView{
        
        let imageView = UIImageView()
        imageView.clipsToBounds = true
        imageView.contentMode = .ScaleToFill
        imageView.image = asset.scaleImage(self.frame.width)
        
        return imageView
    }
    
    /**
     是不是第一行
     
     - parameter collectionView: <#collectionView description#>
     
     - returns: <#return value description#>
     */
    func isFirstLine(collectionView:UICollectionView) -> Bool{
    
        if let item = collectionView.indexPathForCell(self)?.item {
        
            let screenWidth = UIScreen.mainScreen().bounds.width
            let screenHeight = UIScreen.mainScreen().bounds.width
            
            let sw = max(screenWidth, screenHeight)
            
            let lineNumber = Int(sw/((sw-1.5)/4))
            
            return item <= lineNumber
        }
        
        return true
    }
    
}



extension PHAsset{

    /**
     根据 PHAsset 对象 和 提供一个宽度  获取等比例的缩略图
     
     - parameter width: 宽度
     
     - returns: 返回生成的缩略图
     */
    func scaleImage(width:CGFloat) -> UIImage{
    
        let ssize = CGSize(width: width, height: CGFloat(self.pixelHeight)/(CGFloat(self.pixelWidth)/width)).CGSizeScale()
        
        return AttributedStringLoader.sharedLoader.syncImageByAsset(self,cache: false, size: ssize)
    }
}