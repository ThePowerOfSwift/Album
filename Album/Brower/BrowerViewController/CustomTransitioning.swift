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

    func navigationController(_ navigationController: UINavigationController, animationControllerFor operation: UINavigationControllerOperation, from fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        
        if operation == .pop { return CustomPopAnimatedTransitioning() }
        
        return CustomPushAnimatedTransitioning()
    }
    
    func navigationController(_ navigationController: UINavigationController, interactionControllerFor animationController: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        
        return nil
    }
    
}

class CustomPopAnimatedTransitioning:NSObject, UIViewControllerAnimatedTransitioning {
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        
        return 0.5
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        
        guard let toViewController = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.to) as? BaseAlbumViewController else { return transitionContext.completeTransition(true) }
        guard let fromViewController = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.from) as? PhotoPerviewViewController else { return transitionContext.completeTransition(true) }
        guard let toDetailViewController = fromViewController.pageViewController.viewControllers?.first as? PhotoPerviewDetailViewController else { return transitionContext.completeTransition(true) }
        
        let containerView = transitionContext.containerView
        
        containerView.addSubview(fromViewController.view)
        containerView.addSubview(toViewController.view)
        
        toViewController.collectionView.scrollToItem(at: fromViewController.pageIndex as IndexPath, at: UICollectionViewScrollPosition.centeredVertically, animated: false)
        
        DispatchQueue.main.async { 
            
            guard let cell = toViewController.collectionView.cellForItem(at: toDetailViewController.pageIndex as IndexPath) as? MomentCell else { return transitionContext.completeTransition(true) }
            
            let toFrame = cell.convert(cell.imageView.bounds, to: toViewController.view)
            
            let imageView = cell.cloneImageView(toDetailViewController.asset)
            
            let fromFrame = fromViewController.view.convert(toDetailViewController.imageView.bounds, from: toDetailViewController.view)
            imageView.frame = fromFrame
            
            
            containerView.addSubview(imageView)
            
            cell.imageView.alpha = 0
            toDetailViewController.imageView.alpha = 0
            
            imageView.contentMode = .scaleAspectFit
            
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0, options: UIViewAnimationOptions(), animations: {
                imageView.contentMode = .scaleAspectFill
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
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        
        return 0.5
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        
        guard let toViewController = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.to) as? PhotoPerviewViewController else { return transitionContext.completeTransition(true) }
        guard let toDetailViewController = toViewController.pageViewController.viewControllers?.first as? PhotoPerviewDetailViewController else { return transitionContext.completeTransition(true) }
        guard let fromViewController = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.from) as? BaseAlbumViewController else { return transitionContext.completeTransition(true) }
        guard let cell = fromViewController.collectionView.cellForItem(at: toViewController.pageIndex as IndexPath) as? MomentCell else { return transitionContext.completeTransition(true) }
        
        let containerView = transitionContext.containerView
        
        containerView.addSubview(fromViewController.view)
        containerView.addSubview(toViewController.view)
        
        let imageView = cell.cloneImageView(toDetailViewController.asset)
        
        DispatchQueue.global(qos: DispatchQoS.QoSClass.background).async {
            
            AttributedStringLoader.sharedLoader.asyncImageByAsset(toDetailViewController.asset, cache: false, size: PHImageManagerMaximumSize, finish: { (image) in
                
                DispatchQueue.main.async(execute: {
                    
                    imageView.image = image
                })
            })
        }
        
        let fromFrame = cell.convert(cell.imageView.bounds, to: fromViewController.view)
        imageView.frame = fromFrame
        let toFrame = toDetailViewController.scrollView.convert(toDetailViewController.imageView.bounds, to: toDetailViewController.view)
        
        containerView.addSubview(imageView)
        
        cell.imageView.alpha = 0
        toDetailViewController.imageView.alpha = 0
        
        imageView.contentMode = .scaleAspectFill
        
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0, options: UIViewAnimationOptions(), animations: {
            imageView.contentMode = .scaleAspectFit
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
    func cloneImageView(_ asset:PHAsset) -> UIImageView{
        
        let imageView = UIImageView()
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleToFill
        imageView.image = asset.scaleImage(self.frame.width)
        
        return imageView
    }
    
    /**
     是不是第一行
     
     - parameter collectionView: <#collectionView description#>
     
     - returns: <#return value description#>
     */
    func isFirstLine(_ collectionView:UICollectionView) -> Bool{
    
        if let item = (collectionView.indexPath(for: self) as NSIndexPath?)?.item {
        
            let screenWidth = UIScreen.main.bounds.width
            let screenHeight = UIScreen.main.bounds.width
            
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
    func scaleImage(_ width:CGFloat) -> UIImage{
    
        let ssize = CGSize(width: width, height: CGFloat(self.pixelHeight)/(CGFloat(self.pixelWidth)/width)).CGSizeScale()
        
        return AttributedStringLoader.sharedLoader.syncImageByAsset(self,cache: false, size: ssize)
    }
}
