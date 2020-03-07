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
#import <Masonry/Masonry.h>

@interface SJPageMenuBarDemoViewController ()<SJPageMenuBarDelegate>
@property (nonatomic, strong) SJPageMenuBar *pageMenuBar0;
@property (nonatomic, strong) SJPageMenuBar *pageMenuBar1;
@property (nonatomic, strong) SJPageMenuBar *pageMenuBar2;
@property (nonatomic, strong) SJPageMenuBar *pageMenuBar3;
@end

@implementation SJPageMenuBarDemoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = UIColor.whiteColor;
    
    [self _demo0];
    [self _demo1];
    [self _demo2];
    [self _demo3];
}

- (void)_demo0 {
    SJPageMenuBar *pageMenuBar = [SJPageMenuBar.alloc initWithFrame:CGRectZero];
    pageMenuBar.delegate = self;
    [self.view addSubview:pageMenuBar];
    [pageMenuBar mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.offset(0);
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
}


- (void)_demo1 {
    SJPageMenuBar *pageMenuBar = [SJPageMenuBar.alloc initWithFrame:CGRectZero];
    pageMenuBar.delegate = self;
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
}

- (void)_demo2 {
    SJPageMenuBar *pageMenuBar = [SJPageMenuBar.alloc initWithFrame:CGRectZero];
    pageMenuBar.delegate = self;
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
}


- (void)_demo3 {
    SJPageMenuBar *pageMenuBar = [SJPageMenuBar.alloc initWithFrame:CGRectZero];
    pageMenuBar.delegate = self;
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
