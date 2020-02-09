//
//  SJViewController0.swift
//  SJPageViewControllerswift_Example
//
//  Created by BlueDancer on 2020/2/9.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import UIKit
import SJPageViewController

class SJViewController0: UIViewController {

    var pageViewController: SJPageViewController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "左右滑动切换vc"
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

extension SJViewController0: SJPageViewControllerDataSource {    
    func numberOfViewControllers(in pageViewController: SJPageViewController) -> Int {
        return 3
    }
    
    func pageViewController(_ pageViewController: SJPageViewController, viewControllerAt index: Int) -> UIViewController {
        return SJDemoTableViewController.init()
    }
}

extension SJViewController0: SJPageViewControllerDelegate {
    
}
