//
//  SJViewController3.m
//  SJPageViewController_Example
//
//  Created by BlueDancer on 2020/2/8.
//  Copyright © 2020 changsanjiang@gmail.com. All rights reserved.
//

#import "SJViewController3.h"
#import <SJPageViewController/SJScrollToolbar.h>
#import <SJPageViewController/SJPageViewController.h>
#import <Masonry/Masonry.h>
#import "SJDemoTableViewController1.h"

@interface SJViewController3 ()<SJPageViewControllerDelegate, SJPageViewControllerDataSource, SJScrollToolbarDelegate>
@property (nonatomic, strong) SJPageViewController *pageViewController;
@property (nonatomic, strong) SJScrollToolbar *toolbar;
@end

@implementation SJViewController3

- (void)viewDidLoad {
    [super viewDidLoad];
    [self _setupViews];
}

- (void)dealloc {
#ifdef DEBUG
    NSLog(@"%d \t %s", (int)__LINE__, __func__);
#endif
}

- (void)scrollToolbar:(id<SJScrollToolbar>)bar focusedIndexDidChange:(NSInteger)index {
    if ( ![self.pageViewController isViewControllerVisibleAtIndex:index] ) {
        [self.pageViewController setViewControllerAtIndex:index];
    }
}

- (void)pageViewController:(SJPageViewController *)pageViewController didScrollInRange:(NSRange)range distanceProgress:(CGFloat)progress {
    [self.toolbar scrollInRange:range distanceProgress:progress];
}

#pragma mark -

- (void)_setupViews {
    self.view.backgroundColor = UIColor.lightGrayColor;
    
    _pageViewController = [SJPageViewController pageViewControllerWithOptions:@{SJPageViewControllerOptionInterPageSpacingKey:@(3)}];
    _pageViewController.dataSource = self;
    _pageViewController.delegate = self;
    [self addChildViewController:_pageViewController];
    [self.view addSubview:_pageViewController.view];
    [_pageViewController.view mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.offset(0);
    }];
    
    [self.toolbar resetItems:@[
        [SJScrollToolbarItem.alloc initWithTitle:@"推荐"],
        [SJScrollToolbarItem.alloc initWithTitle:@"热门"],
        [SJScrollToolbarItem.alloc initWithTitle:@"最新"],
        [SJScrollToolbarItem.alloc initWithTitle:@"Hello"],
    ] scrollToItemAtIndex:0 animated:NO];
}

@synthesize toolbar = _toolbar;
- (SJScrollToolbar *)toolbar {
    if ( _toolbar == nil ) {
        SJScrollToolbarConfiguration *config = SJScrollToolbarConfiguration.configuration;
        config.distribution = SJScrollToolbarDistributionFillEqually;
        config.alignment = SJScrollToolbarAlignmentCenter;
        config.focusedItemTintColor = [UIColor redColor];
        config.itemTintColor = UIColor.blackColor;
        config.lineTintColor = UIColor.redColor;
        config.barHeight = 49;
        config.lineBottomMargin = 3;
        _toolbar = [SJScrollToolbar.alloc initWithConfiguration:config frame:CGRectZero];
        _toolbar.delegate = self;
    }
    return _toolbar;
}

- (NSUInteger)numberOfViewControllersInPageViewController:(SJPageViewController *)pageViewController {
    return self.toolbar.items.count;
}

- (UIViewController *)pageViewController:(SJPageViewController *)pageViewController viewControllerAtIndex:(NSInteger)index {
    return SJDemoTableViewController1.new;
}

///
/// 顶部下拉时, headerView 固定在顶部
///
- (SJPageViewControllerHeaderMode)modeForHeaderWithPageViewController:(SJPageViewController *)pageViewController {
    return SJPageViewControllerHeaderModePinnedToTop;
}

///
/// 头部视图
///
- (nullable __kindof UIView *)viewForHeaderInPageViewController:(SJPageViewController *)pageViewController {
    UIView *headerView = [UIView.alloc initWithFrame:CGRectZero];
    headerView.backgroundColor = UIColor.redColor;
    [headerView addSubview:self.toolbar];
    
    headerView.layer.shadowColor = UIColor.grayColor.CGColor;
    headerView.layer.shadowOpacity = 1;
    
    [_toolbar mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.bottom.right.offset(0);
    }];
    return headerView;
}

///
/// 头部视图的高度
///
- (CGFloat)heightForHeaderBoundsWithPageViewController:(SJPageViewController *)pageViewController {
    return 200;
}

///
/// 在顶部悬浮保留的高度
///
- (CGFloat)heightForHeaderPinToVisibleBoundsWithPageViewController:(SJPageViewController *)pageViewController {
    return self.toolbar.configuration.barHeight;
}

@end
