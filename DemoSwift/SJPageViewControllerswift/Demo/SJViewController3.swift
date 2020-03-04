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
        pageMenuBar.scrollIndicatorLayoutMode = .equalItemViewLayoutWidth
        pageMenuBar.dataSource = self
        pageMenuBar.delegate = self

        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1) { [weak self] in
            guard let self = self else { return }
            for index in 0...5 {
                self.items.append(SJPageMenuItem.init(title: String.init(index)))
            }
            self.pageViewController.reload()
            self.pageMenuBar.reload()
            self.pageMenuBar.scrollToItem(at: 4, animated: false)
            // or
            // self.pageViewController.setViewController(at: 4)
        }
        
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        pageViewController.view.frame = self.view.bounds
    }
}

extension SJViewController3: SJPageViewControllerDataSource {
    func numberOfViewControllers(in pageViewController: SJPageViewController) -> Int {
        return items.count
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
        
        headerView.addSubview(pageMenuBar!)
        pageMenuBar.translatesAutoresizingMaskIntoConstraints = false
        pageMenuBar.centerXAnchor.constraint(equalTo: headerView.centerXAnchor).isActive = true
        pageMenuBar.bottomAnchor.constraint(equalTo: headerView.bottomAnchor).isActive = true
        pageMenuBar.widthAnchor.constraint(equalToConstant: self.view.bounds.width).isActive = true
        pageMenuBar.heightAnchor.constraint(equalToConstant: 44).isActive = true
        return headerView
    }
    
    func heightForHeaderPinToVisibleBounds(with pageViewController: SJPageViewController) -> CGFloat {
        return 44
    }
    
    func modeForHeader(with pageViewController: SJPageViewController) -> SJPageViewController.HeaderMode {
        return .scaleAspectFill
    }
}

extension SJViewController3: SJPageViewControllerDelegate {
    func pageViewController(_ pageViewController: SJPageViewController, didScrollIn range: NSRange, distanceProgress progress: CGFloat) {
        pageMenuBar.scroll(inRange: range, distaneProgress: progress)
    }
}

extension SJViewController3: SJPageMenuBarDataSource {
    func numberOfItems(in menuBar: SJPageMenuBar) -> Int {
        return pageViewController.numberOfViewControllers
    }
    
    func pageMenuBar(_ menuBar: SJPageMenuBar, viewForItemAt index: Int) -> SJPageMenuItemViewProtocol {
        let menuItemView = SJPageMenuItemView.init(frame: .zero)
        menuItemView.text = items[index].title
        return menuItemView
    }
}

extension SJViewController3: SJPageMenuBarDelegate {
    func pageMenuBar(_ bar: SJPageMenuBar, focusedIndexDidChange index: Int) {
        if pageViewController.isViewControllerVisible(at: index) == false {
            pageViewController.setViewController(at: index)
        }
    }
}
