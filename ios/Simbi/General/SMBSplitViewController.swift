//
//  SMBSplitViewController.swift
//  Simbi
//
//  Created by flynn on 10/6/14.
//  Copyright (c) 2014 SimbiSocial. All rights reserved.
//

import UIKit


@objc protocol SMBSplitViewChild {
    func splitViewDidScroll(splitView: SMBSplitViewController, position: CGFloat)
}


class SMBSplitViewController: UIViewController {
    
    let scrollView = UIScrollView()
    
    var currentIndex = 0
    var viewControllers: [UIViewController] = [] {
        
        willSet {
            for vc in viewControllers {
                vc.view.removeFromSuperview()
                vc.removeFromParentViewController()
            }
        }
        didSet {
            scrollView.contentSize = CGSizeMake(self.view.frame.width*CGFloat(viewControllers.count), self.view.frame.height)
            scrollView.scrollRectToVisible(CGRectMake(0, 0, self.view.frame.width, self.view.frame.height), animated: false)
            
            currentIndex = 0
            
            for (index, vc) in enumerate(viewControllers) {
                self.addChildViewController(vc)
                scrollView.addSubview(vc.view)
                vc.view.frame = CGRectMake(self.view.frame.size.width*index.CG, 0, vc.view.frame.width, vc.view.frame.height)
            }
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        scrollView.frame = CGRectMake(0, 0, self.view.frame.width, self.view.frame.height)
        scrollView.delegate = self
        scrollView.bounces = false
        scrollView.decelerationRate = 0
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.showsVerticalScrollIndicator = false
        self.view.addSubview(scrollView)
        
        self.automaticallyAdjustsScrollViewInsets = false
    }
    
    
    func readjustScrollView(scrollView: UIScrollView) {
        
        let section = currentIndex.CG * scrollView.frame.width
        let xPos = scrollView.contentOffset.x
        let width = scrollView.frame.width
        let height = scrollView.frame.height
        
        if xPos <= section - width/3 {
            currentIndex--
        }
        else if xPos >= section + width/3 {
            currentIndex++
        }
        
        scrollView.scrollRectToVisible(CGRectMake(currentIndex.CG * width, 0, width, height), animated: true)
    }
    
    
    func scrollToIndex(index: Int, animated: Bool = true) {
        
        if 0 <= index && index < viewControllers.count {
            
            let width = scrollView.frame.width
            let height = scrollView.frame.height
            
            currentIndex = index
            scrollView.scrollRectToVisible(CGRectMake(currentIndex.CG * width, 0, width, height), animated: animated)
        }
    }
}


// MARK: - UIScrollViewDelegate Extension

extension SMBSplitViewController: UIScrollViewDelegate {
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        
        for (index, vc) in enumerate(viewControllers) {
            if vc is SMBSplitViewChild {
                (vc as! SMBSplitViewChild).splitViewDidScroll(self, position: scrollView.contentOffset.x-index.CG*scrollView.frame.width)
            }
        }
    }
    
    
    func scrollViewDidEndDragging(scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        
        self.view.endEditing(true)
        
        if !decelerate {
            readjustScrollView(scrollView)
        }
    }
    
    
    func scrollViewWillBeginDecelerating(scrollView: UIScrollView) {
        readjustScrollView(scrollView)
    }
    
    
    func scrollViewDidEndScrollingAnimation(scrollView: UIScrollView) {
        // Empty implementation
    }
}

