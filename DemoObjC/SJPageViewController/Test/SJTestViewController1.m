//
//  SJTestViewController1.m
//  SJPageViewController_Example
//
//  Created by BlueDancer on 2020/2/29.
//  Copyright © 2020 changsanjiang@gmail.com. All rights reserved.
//

#import "SJTestViewController1.h"
#import <MJRefresh/MJRefresh.h>

static NSString * const kCellId = @"1";

@interface SJTestViewController1 ()<UITableViewDelegate, UITableViewDataSource>
@property (nonatomic) NSInteger numberOfRows;
@end

@implementation SJTestViewController1
- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.tableView registerClass:UITableViewCell.class forCellReuseIdentifier:kCellId];
    self.tableView.estimatedRowHeight = 0;
    self.tableView.estimatedSectionHeaderHeight = 0;
    self.tableView.estimatedSectionFooterHeight = 0;
    self.tableView.rowHeight = 44;
    self.tableView.sectionFooterHeight = 44;
    self.tableView.tableFooterView = UIView.new;

    __weak typeof(self) _self = self;
    self.tableView.mj_header = [MJRefreshStateHeader headerWithRefreshingBlock:^{
        __strong typeof(_self) self = _self;
        if ( !self ) return;
        self.numberOfRows = arc4random() % 9 + 10;
        [self.tableView reloadData];
        [self.tableView.mj_header endRefreshing];
    }];
    
    self.tableView.mj_header.refreshingBlock();
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 99;
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

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return section == 0 ? 0.001 : 44;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return section == 0 ? nil : [NSString stringWithFormat:@"Header-%ld", (long)section];
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section {
    return [NSString stringWithFormat:@"Footer-%ld", (long)section];
}


-(void)scrollViewDidScroll:(UIScrollView *)scrollView {
//    CGFloat sectionHeaderHeight = 44;
//    CGFloat height = 0;
//    if (scrollView.contentOffset.y <= sectionHeaderHeight && scrollView.contentOffset.y >= 0) {
//        scrollView.contentInset = UIEdgeInsetsMake(0, 0, 0, 0);
//    }
//    else if (scrollView.contentOffset.y >= sectionHeaderHeight) {
//        scrollView.contentInset = UIEdgeInsetsMake(sectionHeaderHeight+height, 0, 0, 0);
//    }
//
//    scrollView.contentInset = UIEdgeInsetsMake(-scrollView.contentOffset.y, 0, 0, 0);
}
@end
