//
//  SJDemoTableViewController.m
//  SJPageViewController_Example
//
//  Created by BlueDancer on 2020/2/8.
//  Copyright © 2020 changsanjiang@gmail.com. All rights reserved.
//

#import "SJDemoTableViewController.h"
#import <MJRefresh/MJRefresh.h>

static NSString * const kCellId = @"1";

@interface UITableView (Test)

@end

@implementation UITableView (Test)
+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        LWZExchangeImplementations(UITableView.class, @selector(setContentInset:), @selector(sj_setContentInset:));
    });
}

- (void)sj_setContentInset:(UIEdgeInsets)contentInset {
    NSLog(@"%@", NSStringFromUIEdgeInsets(contentInset));
    [self sj_setContentInset:contentInset];
}

void
LWZExchangeImplementations(Class cls, SEL originalSelector, SEL swizzledSelector) {
    ///
    /// class_getInstanceMethod 此函数会在该类以及超类中搜索实现
    ///
    Method originalMethod = class_getInstanceMethod(cls, originalSelector);
    Method swizzledMethod = class_getInstanceMethod(cls, swizzledSelector);
    ///
    /// class_addMethod
    /// 将添加超类实现的重写，但不会替换该类中的现有实现。要更改现有实现，请使用方法setImplementation。
    ///
    ///     为原始sel添加一个实现(子类未实现该方法时, 则添加成功将返回 true)
    ///     当调用原始方法时, 则执行swizzled方法, 在swizzled方法中, 通常还会以调用与自己同名的方法来回调原始实现.
    ///
    if ( class_addMethod(cls, originalSelector, method_getImplementation(swizzledMethod), method_getTypeEncoding(swizzledMethod)) ) {
        class_replaceMethod(cls, swizzledSelector, method_getImplementation(originalMethod), method_getTypeEncoding(originalMethod));
    }
    else {
        method_exchangeImplementations(originalMethod, swizzledMethod);
    }
}
@end


@interface SJDemoTableViewController ()<UITableViewDelegate, UITableViewDataSource>
@property (nonatomic) NSInteger numberOfRows;
@end

@implementation SJDemoTableViewController
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

- (void)scrollViewDidScroll:(UIScrollView *)childScrollView {
//    CGFloat _heightForHeaderBounds = 200;
//    CGFloat _heightForHeaderPinToVisibleBounds = 40;
//    CGFloat topInset = _heightForHeaderBounds;
//    CGFloat offset = childScrollView.contentOffset.y;
//    topInset = childScrollView.contentInset.top;
//    if ( offset <= -_heightForHeaderBounds ) {
//        topInset = _heightForHeaderBounds;
//    }
//    else if ( offset < -_heightForHeaderPinToVisibleBounds ) {
//        topInset = -offset;
//    }
//    else {
//        topInset = _heightForHeaderPinToVisibleBounds;
//    }
//
//    if ( childScrollView.contentInset.top != topInset ) {
//        UIEdgeInsets inset = childScrollView.contentInset;
//        inset.top = topInset;
//        inset.bottom = 0;
//        childScrollView.contentInset = inset;
//    }
    
//    childScrollView.contentInset = UIEdgeInsetsMake(-childScrollView.contentOffset.y, 0, 0, 0);

}

@end
