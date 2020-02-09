//
//  SJViewController4.swift
//  SJPageViewControllerswift_Example
//
//  Created by BlueDancer on 2020/2/9.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import UIKit
import SJPageViewController

class SJNavigationBar: UIView {
    var contentView: UIView
    var backButton: UIButton
    
    override init(frame: CGRect) {
        contentView = UIView.init()
        contentView.backgroundColor = .orange
        contentView.layer.borderWidth = 0.5
        contentView.layer.borderColor = UIColor.black.cgColor
        
        backButton = UIButton.init(type: .system)
        backButton.setTitle("  <--返回按钮", for: .normal)
        super.init(frame: frame)
        self.addSubview(contentView)
        self.addSubview(backButton)
        
        contentView.translatesAutoresizingMaskIntoConstraints = false
        contentView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        contentView.leftAnchor.constraint(equalTo: self.leftAnchor).isActive = true
        contentView.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        contentView.rightAnchor.constraint(equalTo: self.rightAnchor).isActive = true
        
        backButton.translatesAutoresizingMaskIntoConstraints = false
        if #available(iOS 11.0, *) {
            backButton.topAnchor.constraint(equalTo: self.safeAreaLayoutGuide.topAnchor).isActive = true
        } else {
            let topCons = backButton.topAnchor.constraint(equalTo: self.topAnchor)
            topCons.constant = 20
            topCons.isActive = true
        }
        backButton.leftAnchor.constraint(equalTo: self.leftAnchor).isActive = true
        backButton.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        backButton.heightAnchor.constraint(equalToConstant: 44).isActive = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}


class SJViewController4: UIViewController {

    var pageViewController: SJPageViewController!
    var navBar: SJNavigationBar!
    
    override func viewDidLoad() {
        super.viewDidLoad() 
        self.view.backgroundColor = .black
        
        navBar = SJNavigationBar.init(frame: .zero)
        navBar.contentView.alpha = 0
        navBar.backButton.addTarget(self, action: #selector(backButtonWasTapped), for: .touchUpInside)
        
        pageViewController = SJPageViewController.init(options: [.interPageSpacing:CGFloat(3)], dataSource: self, delegate: self)
        pageViewController.bounces = false;
        self.addChild(pageViewController)
        self.view.addSubview(pageViewController.view)
        self.view.addSubview(navBar)
        
        navBar.translatesAutoresizingMaskIntoConstraints = false
        navBar.topAnchor.constraint(equalTo: self.view.topAnchor).isActive = true
        navBar.leftAnchor.constraint(equalTo: self.view.leftAnchor).isActive = true
        navBar.rightAnchor.constraint(equalTo: self.view.rightAnchor).isActive = true

        pageViewController.view.translatesAutoresizingMaskIntoConstraints = false
        pageViewController.view.topAnchor.constraint(equalTo: self.view.topAnchor).isActive = true
        pageViewController.view.leftAnchor.constraint(equalTo: self.view.leftAnchor).isActive = true
        pageViewController.view.bottomAnchor.constraint(equalTo: self.view.bottomAnchor).isActive = true
        pageViewController.view.rightAnchor.constraint(equalTo: self.view.rightAnchor).isActive = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    @objc func backButtonWasTapped() {
        self.navigationController?.popViewController(animated: true)
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        pageViewController.view.frame = self.view.bounds
    }
}

extension SJViewController4: SJPageViewControllerDataSource {
    func numberOfViewControllers(in pageViewController: SJPageViewController) -> Int {
        return 3
    }
    
    func pageViewController(_ pageViewController: SJPageViewController, viewControllerAt index: Int) -> UIViewController {
        return SJDemoTableViewController.init()
    }
    
    func viewForHeader(in pageViewController: SJPageViewController) -> UIView? {
        let headerView = UIView.init(frame: .init(x: 0, y: 0, width: self.view.bounds.size.width, height: 300))
        headerView.backgroundColor = .purple
        
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
        return 44 + navBar.bounds.height
    }
    
    func modeForHeader(with pageViewController: SJPageViewController) -> SJPageViewController.HeaderMode {
        return .pinnedToTop
    }
}

extension SJViewController4: SJPageViewControllerDelegate {
    func pageViewController(_ pageViewController: SJPageViewController, headerViewScrollProgressDidChange progress: CGFloat) {
        navBar.contentView.alpha = progress
    }
}
