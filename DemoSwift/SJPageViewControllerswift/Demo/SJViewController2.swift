//
//  SJViewController2.swift
//  SJPageViewControllerswift_Example
//
//  Created by BlueDancer on 2020/2/9.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import UIKit
import SJPageViewController

class SJViewController2: UIViewController {

    var pageViewController: SJPageViewController!
    
    override func viewDidLoad() {
        super.viewDidLoad() 
        self.view.backgroundColor = .black
        pageViewController = SJPageViewController.init(options: [.interPageSpacing:CGFloat(3)], dataSource: self, delegate: self)
        pageViewController.bounces = false;
        self.addChild(pageViewController)
        self.view.addSubview(pageViewController.view)
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        pageViewController.view.frame = self.view.bounds
    }
}

extension SJViewController2: SJPageViewControllerDataSource {
    func numberOfViewControllers(in pageViewController: SJPageViewController) -> Int {
        return 3
    }
    
    func pageViewController(_ pageViewController: SJPageViewController, viewControllerAt index: Int) -> UIViewController {
        return SJDemoTableViewController.init()
    }
    
    func viewForHeader(in pageViewController: SJPageViewController) -> UIView? {
        let headerView = UIView.init(frame: .init(x: 0, y: 0, width: self.view.bounds.size.width, height: 300))
        headerView.backgroundColor = .red
        
        let label = UILabel.init(frame: .init(x: 0, y: 300 - 44, width: self.view.bounds.size.width, height: 44))
        label.text = "左右滑动切换vc"
        label.backgroundColor = .green
        headerView.addSubview(label)
        return headerView
    }
    
    func heightForHeaderBounds(with pageViewController: SJPageViewController) -> CGFloat {
        return 300
    }
    
    func heightForHeaderPinToVisibleBounds(with pageViewController: SJPageViewController) -> CGFloat {
        return 44
    }
    
    func modeForHeader(with pageViewController: SJPageViewController) -> SJPageViewController.HeaderMode {
        return .pinnedToTop
    }
}

extension SJViewController2: SJPageViewControllerDelegate {
    
}
