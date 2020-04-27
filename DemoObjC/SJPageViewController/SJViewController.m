//
//  SJViewController.m
//  SJPageViewController
//
//  Created by changsanjiang@gmail.com on 02/08/2020.
//  Copyright (c) 2020 changsanjiang@gmail.com. All rights reserved.
//

#import "SJViewController.h"
#import <Masonry/Masonry.h>
#import "SJViewController00.h"
#import "SJViewController0.h"
#import "SJViewController1.h"
#import "SJViewController2.h"
#import "SJViewController4.h"
#import "SJViewController5.h"
#import "SJPageMenuBarDemoViewController.h"
#import "SJViewController6.h"
#import "SJViewController7.h"

static NSString * const kCellId = @"1";

@interface SJViewController ()<UITableViewDelegate, UITableViewDataSource>
@property (nonatomic, strong, nullable) UITableView *tableView;
@end

@implementation SJViewController
- (void)viewDidLoad {
    [super viewDidLoad];
	
    _tableView = [UITableView.alloc initWithFrame:CGRectZero style:UITableViewStyleGrouped];
    [_tableView registerClass:UITableViewCell.class forCellReuseIdentifier:kCellId];
    _tableView.estimatedRowHeight = 0;
    _tableView.estimatedSectionHeaderHeight = 0;
    _tableView.estimatedSectionFooterHeight = 0;
    _tableView.rowHeight = 44;
    _tableView.dataSource = self;
    _tableView.delegate = self;
    
    [self.view addSubview:_tableView];
    [_tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.offset(0);
    }];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if ( section == 0 )
        return 1;
    else if ( section == 1 )
        return 5;
    return 3;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [tableView dequeueReusableCellWithIdentifier:kCellId forIndexPath:indexPath];
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if ( indexPath.section == 0 ) {
        cell.textLabel.text = [NSString stringWithFormat:@"Demo 应用"];
    }
    else if ( indexPath.section == 1 ) {
        switch ( indexPath.row ) {
            case 0: {
                cell.textLabel.text = [NSString stringWithFormat:@"普通左右滑动, 无header样式"];
            }
                break;
            case 1: {
                cell.textLabel.text = [NSString stringWithFormat:@"顶部下拉时, headerView 跟随移动"];
            }
                break;
            case 2: {
                cell.textLabel.text = [NSString stringWithFormat:@"顶部下拉时, headerView 固定在顶部"];
            }
                break;
            case 3: {
                cell.textLabel.text = [NSString stringWithFormat:@"顶部下拉时, headerView 同比放大"];
            }
                break;
            case 4: {
                cell.textLabel.text = [NSString stringWithFormat:@"自定义导航栏"];
            }
                break;
        }
    }
    else {
        switch ( indexPath.row ) {
            case 0:
                cell.textLabel.text = [NSString stringWithFormat:@"PageMenuBar Demo1"];
                break;
            case 1:
                cell.textLabel.text = [NSString stringWithFormat:@"PageMenuBar Demo2"];
                break;
            case 2:
                cell.textLabel.text = [NSString stringWithFormat:@"PageMenuBar Demo3"];
                break;
        }
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if ( indexPath.section == 0 ) {
        [self.navigationController pushViewController:SJViewController5.new animated:YES];
    }
    else if ( indexPath.section == 1 ) {
        switch ( indexPath.row ) {
            case 0: {
                [self.navigationController pushViewController:SJViewController00.new animated:YES];
            }
                break;
            case 1: {
                [self.navigationController pushViewController:SJViewController0.new animated:YES];
            }
                break;
            case 2: {
                [self.navigationController pushViewController:SJViewController1.new animated:YES];
            }
                break;
            case 3: {
                [self.navigationController pushViewController:SJViewController2.new animated:YES];
            }
                break;
            case 4: {
                [self.navigationController pushViewController:SJViewController4.new animated:YES];
            }
                break;
            case 5: {
                [self.navigationController pushViewController:SJViewController5.new animated:YES];
            }
                break;
        }
    }
    else {
        switch ( indexPath.row ) {
            case 0: {
                [self.navigationController pushViewController:SJPageMenuBarDemoViewController.new animated:YES];
            }
                break;
            case 1: {
                [self.navigationController pushViewController:SJViewController6.new animated:YES];
            }
                break;
            case 2: {
                [self.navigationController pushViewController:SJViewController7.new animated:YES];
            }
                break;
        }
    }
}

@end
