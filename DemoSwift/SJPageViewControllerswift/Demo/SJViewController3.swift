//
//  SJViewController3.swift
//  SJPageViewControllerswift_Example
//
//  Created by BlueDancer on 2020/2/9.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import UIKit
import SJPageViewController

class SJViewController3: UIViewController {

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

extension SJViewController3: SJPageViewControllerDataSource {
    func numberOfViewControllers(in pageViewController: SJPageViewController) -> Int {
        return 3
    }
    
    func pageViewController(_ pageViewController: SJPageViewController, viewControllerAt index: Int) -> UIViewController {
        return SJDemoTableViewController.init()
    }
    
    func viewForHeader(in pageViewController: SJPageViewController) -> UIView? {
        let headerView = UIImageView.init(frame: .init(x: 0, y: 0, width: self.view.bounds.width, height: 300))
        headerView.backgroundColor = .red
        headerView.image = UIImage.init(named: "cover1")
        headerView.clipsToBounds = true
        headerView.contentMode = .scaleAspectFill
        
        let label = UILabel.init(frame: .zero)
        label.text = "左右滑动切换vc"
        label.backgroundColor = .green
        headerView.addSubview(label)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.centerXAnchor.constraint(equalTo: headerView.centerXAnchor).isActive = true
        label.bottomAnchor.constraint(equalTo: headerView.bottomAnchor).isActive = true
        label.widthAnchor.constraint(equalToConstant: self.view.bounds.width).isActive = true
        label.heightAnchor.constraint(equalToConstant: 44).isActive = true
        return headerView
    }
    
    func heightForHeaderBounds(with pageViewController: SJPageViewController) -> CGFloat {
        return pageViewController.headerView?.frame.height ?? 0
    }
    
    func heightForHeaderPinToVisibleBounds(with pageViewController: SJPageViewController) -> CGFloat {
        return 44
    }
    
    func modeForHeader(with pageViewController: SJPageViewController) -> SJPageViewController.HeaderMode {
        return .scaleAspectFill
    }
}

extension SJViewController3: SJPageViewControllerDelegate {
    
}
