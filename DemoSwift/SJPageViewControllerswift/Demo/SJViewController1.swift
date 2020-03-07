//
//  SJViewController1.swift
//  SJPageViewControllerswift_Example
//
//  Created by BlueDancer on 2020/2/9.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import UIKit
import SJPageViewController

struct SJPageMenuItem {
    var title: String?
}

class SJViewController1: UIViewController {

    var items = [SJPageMenuItem]()
    var pageViewController: SJPageViewController!
    var pageMenuBar: SJPageMenuBar!
    
    override func viewDidLoad() {
        super.viewDidLoad() 
        self.view.backgroundColor = .black
        pageViewController = SJPageViewController.init(options: [.interPageSpacing:CGFloat(3)], dataSource: self, delegate: self)
        pageViewController.bounces = false;
        self.addChild(pageViewController)
        self.view.addSubview(pageViewController.view)
        
        pageMenuBar = SJPageMenuBar.init(frame: .zero)
        pageMenuBar.distribution = .fillEqually
        pageMenuBar.scrollIndicatorLayoutMode = .specifiedWidth
        pageMenuBar.delegate = self

        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1) { [weak self] in
            guard let self = self else { return }
            for index in 0...5 {
                self.items.append(SJPageMenuItem.init(title: String.init(index)))
            }
            
            var views = [SJPageMenuItemView]()
            self.items.forEach {
                let itemView = SJPageMenuItemView.init(frame: .zero)
                itemView.text = $0.title
                views.append(itemView)
            }
            
            self.pageMenuBar.itemViews = views
            self.pageViewController.reload()
            self.pageMenuBar.scrollToItem(at: 4, animated: false)
        }

    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        pageViewController.view.frame = self.view.bounds
    }
}

extension SJViewController1: SJPageViewControllerDataSource {
    func numberOfViewControllers(in pageViewController: SJPageViewController) -> Int {
        return items.count
    }
    
    func pageViewController(_ pageViewController: SJPageViewController, viewControllerAt index: Int) -> UIViewController {
        return SJDemoTableViewController.init()
    }
    
    func viewForHeader(in pageViewController: SJPageViewController) -> UIView? {
        let headerView = UIView.init(frame: .init(x: 0, y: 0, width: view.bounds.width, height: 300))
        headerView.backgroundColor = .red
        
        pageMenuBar?.frame = CGRect.init(x: 0, y: 300 - 44, width: view.bounds.width, height: 44)
        headerView.addSubview(pageMenuBar!)
        return headerView
    }
    
    func heightForHeaderPinToVisibleBounds(with pageViewController: SJPageViewController) -> CGFloat {
        return 44
    }
    
    func modeForHeader(with pageViewController: SJPageViewController) -> SJPageViewController.HeaderMode {
        return .tracking
    }
}

extension SJViewController1: SJPageViewControllerDelegate {
    func pageViewController(_ pageViewController: SJPageViewController, didScrollIn range: NSRange, distanceProgress progress: CGFloat) {
        pageMenuBar.scroll(inRange: range, distanceProgress: progress)
    }
} 

extension SJViewController1: SJPageMenuBarDelegate {
    func pageMenuBar(_ bar: SJPageMenuBar, focusedIndexDidChange index: Int) {
        if pageViewController.isViewControllerVisible(at: index) == false {
            pageViewController.setViewController(at: index)
        }
    }
}
