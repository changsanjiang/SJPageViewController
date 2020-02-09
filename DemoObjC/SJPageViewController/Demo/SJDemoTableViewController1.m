//
//  SJDemoTableViewController.m
//  SJPageViewController_Example
//
//  Created by BlueDancer on 2020/2/8.
//  Copyright © 2020 changsanjiang@gmail.com. All rights reserved.
//

#import "SJDemoTableViewController1.h"
#import <Masonry/Masonry.h>
#import <MJRefresh/MJRefresh.h>

static NSString * const kCellId = @"1";

@interface SJDemoTableViewController1 ()<UITableViewDelegate, UITableViewDataSource>
@property (nonatomic) NSInteger numberOfRows;
@end

@implementation SJDemoTableViewController1
- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.tableView registerClass:UITableViewCell.class forCellReuseIdentifier:kCellId];
    self.tableView.estimatedRowHeight = 0;
    self.tableView.estimatedSectionHeaderHeight = 0;
    self.tableView.estimatedSectionFooterHeight = 0;
    self.tableView.rowHeight = 44;
    self.tableView.tableFooterView = UIView.new;
    
    __weak typeof(self) _self = self;
    self.tableView.mj_header = [MJRefreshStateHeader headerWithRefreshingBlock:^{
        __strong typeof(_self) self = _self;
        if ( !self ) return;
        self.numberOfRows = arc4random() % 9 + 99;
        [self.tableView reloadData];
        [self.tableView.mj_header endRefreshing];
    }];
    
    
    self.tableView.mj_header.refreshingBlock();
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.numberOfRows;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [tableView dequeueReusableCellWithIdentifier:kCellId forIndexPath:indexPath];
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    cell.textLabel.text = [NSString stringWithFormat:@"%ld", (long)indexPath.row];
}

@end
