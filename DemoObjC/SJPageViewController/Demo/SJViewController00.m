//
//  SJViewController00.m
//  SJPageViewController_Example
//
//  Created by BlueDancer on 2020/2/8.
//  Copyright © 2020 changsanjiang@gmail.com. All rights reserved.
//

#import "SJViewController00.h"
#import <SJPageViewController/SJPageViewController.h>
#import <Masonry/Masonry.h>
#import "SJDemoTableViewController.h"

@interface SJViewController00 ()<SJPageViewControllerDelegate, SJPageViewControllerDataSource>
@property (nonatomic, strong) SJPageViewController *pageViewController;
@end

@implementation SJViewController00

- (void)viewDidLoad {
    [super viewDidLoad];
    [self _setupViews];
}

- (void)dealloc {
#ifdef DEBUG
    NSLog(@"%d \t %s", (int)__LINE__, __func__);
#endif
}

#pragma mark -

- (void)_setupViews {
    self.title = @"左右滑动切换vc";
    self.view.backgroundColor = UIColor.blackColor;
    
    _pageViewController = [SJPageViewController pageViewControllerWithOptions:@{SJPageViewControllerOptionInterPageSpacingKey:@(3)}];
    _pageViewController.dataSource = self;
    _pageViewController.delegate = self;
    [self addChildViewController:_pageViewController];
    [self.view addSubview:_pageViewController.view];
    _pageViewController.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    _pageViewController.view.frame = self.view.bounds;
    [_pageViewController.view mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.offset(0);
    }];
}

- (NSUInteger)numberOfViewControllersInPageViewController:(SJPageViewController *)pageViewController {
    return 3;
}

- (UIViewController *)pageViewController:(SJPageViewController *)pageViewController viewControllerAtIndex:(NSInteger)index {
    return SJDemoTableViewController.new;
}
@end
