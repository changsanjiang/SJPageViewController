//
//  SJTestViewController2.m
//  SJPageViewController_Example
//
//  Created by BlueDancer on 2020/2/29.
//  Copyright © 2020 changsanjiang@gmail.com. All rights reserved.
//

#import "SJTestViewController2.h"
#import "SJTestViewController1.h"
#import <Masonry.h>

@interface SJTestViewController2 ()<UIPageViewControllerDataSource>
@property (nonatomic, strong, nullable) UIPageViewController *pageViewController;
@end

@implementation SJTestViewController2

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = UIColor.whiteColor;
    [self addChildViewController:self.pageViewController];
    [self.view addSubview:self.pageViewController.view];
    [self.pageViewController.view mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.offset(0);
    }];
    // Do any additional setup after loading the view.
}

@synthesize pageViewController = _pageViewController;
- (UIPageViewController *)pageViewController {
    if ( _pageViewController == nil ) {
        _pageViewController = [UIPageViewController.alloc initWithTransitionStyle:UIPageViewControllerTransitionStyleScroll navigationOrientation:UIPageViewControllerNavigationOrientationHorizontal options:nil];
        _pageViewController.dataSource = self;
        [_pageViewController setViewControllers:@[SJTestViewController1.new] direction:kNilOptions animated:NO completion:nil];
    }
    return _pageViewController;
}

- (nullable UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController {
    return SJTestViewController1.new;
}
- (nullable UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController {
    return SJTestViewController1.new;
}
@end
