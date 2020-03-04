//
//  ViewController.swift
//  SJPageViewControllerswift
//
//  Created by changsanjiang@gmail.com on 02/08/2020.
//  Copyright (c) 2020 changsanjiang@gmail.com. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    private var kCellId = "cell";
    private lazy var tableView: UITableView = {
        let tableView = UITableView.init(frame: .zero, style: .grouped)
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: kCellId)
        tableView.estimatedRowHeight = 0
        tableView.estimatedSectionFooterHeight = 0
        tableView.estimatedSectionHeaderHeight = 0
        tableView.rowHeight = 44
        tableView.dataSource = self
        tableView.delegate = self
        return tableView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
        tableView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        tableView.frame = self.view.bounds
        self.view.addSubview(tableView)
    }
}

extension ViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return tableView.dequeueReusableCell(withIdentifier: kCellId, for: indexPath)
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        switch indexPath.row {
        case 0:
            cell.textLabel?.text = "普通左右滑动, 无header样式"
        case 1:
            cell.textLabel?.text = "顶部下拉时, headerView 跟随移动"
        case 2:
            cell.textLabel?.text = "顶部下拉时, headerView 固定在顶部"
        case 3:
            cell.textLabel?.text = "顶部下拉时, headerView 同比放大"
        case 4:
            cell.textLabel?.text = "自定义导航栏"
        default:
            break
        }
    }
}

extension ViewController: UITableViewDelegate {
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.row {
        case 0:
            self.navigationController?.pushViewController(SJViewController0.init(), animated: true)
        case 1:
            self.navigationController?.pushViewController(SJViewController1.init(), animated: true)
        case 2:
            self.navigationController?.pushViewController(SJViewController2.init(), animated: true)
        case 3:
            self.navigationController?.pushViewController(SJViewController3.init(), animated: true)
        case 4:
            self.navigationController?.pushViewController(SJViewController4.init(), animated: true)
        default:
            break
        }
    }
}

/*
 
 1. 管理员消息推送
 2. 聊天区改造
    - VIP标志新增课程及管理员
    - 新消息数量提示
    - 去购买提示
    - `谁谁谁来了`移动到最底部
 3. 带货推荐商品显示和隐藏
 4. 榜单固定. 管理员控制者显示和隐藏
 5. 下线和结束直播后的提示页
 
 */
