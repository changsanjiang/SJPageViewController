//
//  SJPageMenuBarDemoViewController.m
//  SJPageViewController_Example
//
//  Created by BlueDancer on 2020/3/4.
//  Copyright © 2020 changsanjiang@gmail.com. All rights reserved.
//

#import "SJPageMenuBarDemoViewController.h"
#import <SJPageViewController/SJPageMenuBar.h>
#import <SJPageViewController/SJPageMenuItemView.h>
#import <SJPageViewController/SJPageViewController.h>
#import <Masonry/Masonry.h>

@interface SJPageMenuItemImageView : UIImageView<SJPageMenuItemView>
@property (nonatomic, getter=isFocusedMenuItem) BOOL focusedMenuItem;
@end

@implementation SJPageMenuItemImageView
@synthesize transitionProgress = _transitionProgress;
@end

@interface SJPageMenuBarDemoViewController ()<SJPageMenuBarDelegate, SJPageViewControllerDelegate, SJPageViewControllerDataSource>
@property (nonatomic, strong, readonly) SJPageViewController *pageViewController;
@property (nonatomic, strong) SJPageMenuBar *pageMenuBar0;
@property (nonatomic, strong) SJPageMenuBar *pageMenuBar1;
@property (nonatomic, strong) SJPageMenuBar *pageMenuBar2;
@property (nonatomic, strong) SJPageMenuBar *pageMenuBar3;
@property (nonatomic, strong) SJPageMenuBar *pageMenuBar4;
@property (nonatomic, strong) SJPageMenuBar *pageMenuBar5;
@end

@implementation SJPageMenuBarDemoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = UIColor.whiteColor;
    
    [self addChildViewController:self.pageViewController];
    [self.view addSubview:self.pageViewController.view];
    [self.pageViewController.view mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.offset(0);
    }];
    
    
    [self _demo0];
    [self _demo1];
    [self _demo2];
    [self _demo3];
    [self _demo4];
    [self _demo5];
}

#pragma mark -

@synthesize pageViewController = _pageViewController;
- (SJPageViewController *)pageViewController {
    if ( _pageViewController == nil ) {
        _pageViewController = [SJPageViewController.alloc initWithOptions:nil];
        _pageViewController.dataSource = self;
        _pageViewController.delegate = self;
    }
    return _pageViewController;
}

- (NSUInteger)numberOfViewControllersInPageViewController:(SJPageViewController *)pageViewController {
    return 5;
}

- (__kindof UIViewController *)pageViewController:(SJPageViewController *)pageViewController  viewControllerAtIndex:(NSInteger)index {
    UIViewController *vc = UIViewController.new;
    vc.view.backgroundColor = [UIColor colorWithRed:arc4random() % 256 / 255.0
                                              green:arc4random() % 256 / 255.0
                                               blue:arc4random() % 256 / 255.0
                                              alpha:1];
    return vc;
}

- (void)pageViewController:(SJPageViewController *)pageViewController didScrollInRange:(NSRange)range distanceProgress:(CGFloat)progress {
    for ( SJPageMenuBar *pageMenuBar in @[_pageMenuBar0, _pageMenuBar1, _pageMenuBar2, _pageMenuBar3, _pageMenuBar4, _pageMenuBar5] ) {
        [pageMenuBar scrollInRange:range distanceProgress:progress];
    }
}
 
- (void)pageMenuBar:(SJPageMenuBar *)bar focusedIndexDidChange:(NSUInteger)index {
    if ( ![self.pageViewController isViewControllerVisibleAtIndex:index] ) {
        [self.pageViewController setViewControllerAtIndex:index];
    }
}

#pragma mark -

- (void)_demo0 {
    SJPageMenuBar *pageMenuBar = [SJPageMenuBar.alloc initWithFrame:CGRectZero];
    [self.view addSubview:pageMenuBar];
    [pageMenuBar mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.view).multipliedBy(0.5);
        make.left.right.offset(0);
        make.height.offset(60);
    }];
    _pageMenuBar0 = pageMenuBar;
    
    // 内容
    pageMenuBar.contentInsets = UIEdgeInsetsMake(0, 12, 0, 12);

    // 分布模式. 这里设置为等间隔分布
    pageMenuBar.distribution = SJPageMenuBarDistributionEqualSpacing;
    pageMenuBar.minimumZoomScale = 0.8;
    pageMenuBar.maximumZoomScale = 1.0;
    
    // 显示线
    pageMenuBar.showsScrollIndicator = YES;
    // 线宽的布局模式, 这里设置为指定宽度
    pageMenuBar.scrollIndicatorLayoutMode = SJPageMenuBarScrollIndicatorLayoutModeSpecifiedWidth;
    // 指定宽度为`12`, 高度为`2`
    pageMenuBar.scrollIndicatorSize = CGSizeMake(12, 2);
    
    [self _setItemViewsToPageMenuBar:pageMenuBar];
    
    pageMenuBar.delegate = self;
}


- (void)_demo1 {
    SJPageMenuBar *pageMenuBar = [SJPageMenuBar.alloc initWithFrame:CGRectZero];
    [self.view addSubview:pageMenuBar];
    [pageMenuBar mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.pageMenuBar0.mas_bottom).offset(12);
        make.left.right.offset(0);
        make.height.offset(60);
    }];
    _pageMenuBar1 = pageMenuBar;

    // 分布模式. 这里设置为等宽分布
    pageMenuBar.distribution = SJPageMenuBarDistributionFillEqually;
    pageMenuBar.minimumZoomScale = 0.8;
    pageMenuBar.maximumZoomScale = 1.0;
    
    // 显示线
    pageMenuBar.showsScrollIndicator = YES;
    // 线宽的布局模式, 这里设置为根据item内容宽度布局
    pageMenuBar.scrollIndicatorLayoutMode = SJPageMenuBarScrollIndicatorLayoutModeEqualItemViewContentWidth;
    
    [self _setItemViewsToPageMenuBar:pageMenuBar];
    
    pageMenuBar.delegate = self;
}

- (void)_demo2 {
    SJPageMenuBar *pageMenuBar = [SJPageMenuBar.alloc initWithFrame:CGRectZero];
    [self.view addSubview:pageMenuBar];
    [pageMenuBar mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.pageMenuBar1.mas_bottom).offset(12);
        make.left.right.offset(0);
        make.height.offset(60);
    }];
    _pageMenuBar2 = pageMenuBar;

    // 分布模式. 这里设置为等宽分布
    pageMenuBar.distribution = SJPageMenuBarDistributionFillEqually;
    pageMenuBar.minimumZoomScale = 0.8;
    pageMenuBar.maximumZoomScale = 1.0;
    
    // 显示线
    pageMenuBar.showsScrollIndicator = YES;
    // 线宽的布局模式, 这里设置为根据item的布局宽度来布局
    pageMenuBar.scrollIndicatorLayoutMode = SJPageMenuBarScrollIndicatorLayoutModeEqualItemViewLayoutWidth;
    
    [self _setItemViewsToPageMenuBar:pageMenuBar];
    
    pageMenuBar.delegate = self;
}


- (void)_demo3 {
    SJPageMenuBar *pageMenuBar = [SJPageMenuBar.alloc initWithFrame:CGRectZero];
    [self.view addSubview:pageMenuBar];
    [pageMenuBar mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.pageMenuBar2.mas_bottom).offset(12);
        make.left.right.offset(0);
        make.height.offset(60);
    }];
    _pageMenuBar3 = pageMenuBar;

    pageMenuBar.contentInsets = UIEdgeInsetsMake(0, 12, 0, 12);
    
    // 分布模式. 这里设置为等宽分布
    pageMenuBar.distribution = SJPageMenuBarDistributionEqualSpacing;
    pageMenuBar.minimumZoomScale = 0.8;
    pageMenuBar.maximumZoomScale = 1.0;
    
    // 设置字体底部对齐
    pageMenuBar.centerlineOffset = ABS([UIFont boldSystemFontOfSize:25].descender) * 0.4;
    
    // 显示线
    pageMenuBar.showsScrollIndicator = YES;
    // 线宽的布局模式, 这里设置为根据item的布局宽度来布局
    pageMenuBar.scrollIndicatorLayoutMode = SJPageMenuBarScrollIndicatorLayoutModeEqualItemViewLayoutWidth;
    
    [self _setItemViewsToPageMenuBar:pageMenuBar];
    
    pageMenuBar.delegate = self;
}

- (void)_demo4 {
    SJPageMenuBar *pageMenuBar = [SJPageMenuBar.alloc initWithFrame:CGRectZero];
    [self.view addSubview:pageMenuBar];
    [pageMenuBar mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.pageMenuBar3.mas_bottom).offset(12);
        make.left.right.offset(0);
        make.height.offset(60);
    }];
    _pageMenuBar4 = pageMenuBar;

    pageMenuBar.contentInsets = UIEdgeInsetsMake(0, 12, 0, 12);
    
    // 分布模式. 这里设置为等宽分布
    pageMenuBar.distribution = SJPageMenuBarDistributionEqualSpacing;
    pageMenuBar.minimumZoomScale = 0.8;
    pageMenuBar.maximumZoomScale = 1.0;
    
    // 设置字体底部对齐
    pageMenuBar.centerlineOffset = ABS([UIFont boldSystemFontOfSize:25].descender) * 0.4;
    
    // 显示线
    pageMenuBar.showsScrollIndicator = YES;
    // 线宽的布局模式, 这里设置为根据item的布局宽度来布局
    pageMenuBar.scrollIndicatorLayoutMode = SJPageMenuBarScrollIndicatorLayoutModeEqualItemViewLayoutWidth;
    
    
    NSMutableArray<UIView<SJPageMenuItemView> *> *m = [NSMutableArray arrayWithCapacity:5];
    for ( int i = 0 ; i < 3 ; ++ i  ) {
        SJPageMenuItemView *view = [SJPageMenuItemView.alloc initWithFrame:CGRectZero];
        view.text = @[@"从前", @"有", @"99", @"座", @"灵剑山"][i];
        view.font = [UIFont boldSystemFontOfSize:18];
        [m addObject:view];
    }
    {
        SJPageMenuItemImageView *view = [SJPageMenuItemImageView.alloc initWithImage:[UIImage imageNamed:@"1"]];
        [m insertObject:view atIndex:1];
    }
    {
        SJPageMenuItemImageView *view = [SJPageMenuItemImageView.alloc initWithImage:[UIImage imageNamed:@"2"]];
        [m insertObject:view atIndex:3];
    }
    pageMenuBar.itemViews = m;
    
    pageMenuBar.delegate = self;
}

- (void)_demo5 {
    SJPageMenuBar *pageMenuBar = [SJPageMenuBar.alloc initWithFrame:CGRectZero];
    [self.view addSubview:pageMenuBar];
    [pageMenuBar mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.pageMenuBar4.mas_bottom).offset(12);
        make.left.right.offset(0);
        make.height.offset(40);
    }];
    _pageMenuBar5 = pageMenuBar;

    pageMenuBar.contentInsets = UIEdgeInsetsMake(0, 40, 0, 40);
    
    pageMenuBar.focusedItemTintColor = UIColor.greenColor;
    pageMenuBar.itemTintColor = UIColor.blackColor;
    
    // 分布模式. 这里设置为等宽分布
    pageMenuBar.distribution = SJPageMenuBarDistributionEqualSpacing;
    pageMenuBar.itemSpacing = 40;
    pageMenuBar.minimumZoomScale = 1.0;
    pageMenuBar.maximumZoomScale = 1.0;
    
    // 显示线
    pageMenuBar.showsScrollIndicator = YES;
    pageMenuBar.scrollIndicatorLayoutMode = SJPageMenuBarScrollIndicatorLayoutModeEqualItemViewContentWidth;
    pageMenuBar.scrollIndicatorSize = CGSizeMake(0, 40 - pageMenuBar.scrollIndicatorBottomInset * 2);
    pageMenuBar.scrollIndicatorExpansionSize = CGSizeMake(40, 0);// 在原有线宽的基础上水平方向扩长40
    pageMenuBar.scrollIndicatorTintColor = UIColor.redColor;
    
    [self _setItemViewsToPageMenuBar:pageMenuBar];
    
    pageMenuBar.delegate = self;
}

- (void)_setItemViewsToPageMenuBar:(SJPageMenuBar *)menuBar {
    NSMutableArray<SJPageMenuItemView *> *m = [NSMutableArray arrayWithCapacity:5];
    for ( int i = 0 ; i < 5 ; ++ i  ) {
        SJPageMenuItemView *view = [SJPageMenuItemView.alloc initWithFrame:CGRectZero];
        view.text = @[@"从前", @"有", @"99", @"座", @"灵剑山"][i];
        view.font = [UIFont boldSystemFontOfSize:18];
        [m addObject:view];
    }
    menuBar.itemViews = m;
}
@end
