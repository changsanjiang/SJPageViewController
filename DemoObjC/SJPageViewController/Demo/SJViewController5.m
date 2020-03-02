//
//  SJViewController5.m
//  SJPageViewController_Example
//
//  Created by BlueDancer on 2020/2/11.
//  Copyright © 2020 changsanjiang@gmail.com. All rights reserved.
//

#import "SJViewController5.h"
#import <SJPageViewController/SJPageViewController.h>
#import <Masonry/Masonry.h>
#import "SJDemoTableViewController.h"
#import "SJPageMenuBar.h"
#import "SJPageMenuItemView.h"

@interface SJPageMenuItem : NSObject
- (instancetype)initWithTitle:(NSString *)title;
@property (nonatomic, copy, nullable) NSString *title;
@end

@implementation SJPageMenuItem
- (instancetype)initWithTitle:(NSString *)title {
    self = [super init];
    if ( self ) {
        _title = title;
    }
    return self;
}
@end



@interface SJViewController5 ()<SJPageViewControllerDelegate, SJPageViewControllerDataSource, SJPageMenuBarDataSource, SJPageMenuBarDelegate>
@property (nonatomic, strong) SJPageViewController *pageViewController;
@property (nonatomic, strong) SJPageMenuBar *menuBar;
@property (nonatomic, strong) NSArray<SJPageMenuItem *> *menuItems;
@end

@implementation SJViewController5

- (void)viewDidLoad {
    [super viewDidLoad];
    [self _setupViews];
    
    /// 模拟网络延迟 请求数据
    __weak typeof(self) _self = self;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        __strong typeof(_self) self = _self;
        if ( !self ) return;
        NSMutableArray<SJPageMenuItem *> *m = [NSMutableArray arrayWithCapacity:5];
        for ( int i = 0 ; i < 5 ; ++ i  ) {
            [m addObject:[SJPageMenuItem.alloc initWithTitle:[NSString stringWithFormat:@"%d", i]]];
        }
        self.menuItems = m;
        [self.pageViewController reloadPageViewController];
        [self.menuBar reloadPageMenuBar];
        [self.pageViewController setViewControllerAtIndex:4];
    });
    
}

- (void)dealloc {
#ifdef DEBUG
    NSLog(@"%d \t %s", (int)__LINE__, __func__);
#endif
}

#pragma mark -

- (void)_setupViews {
    self.view.backgroundColor = UIColor.blackColor;
    
    _pageViewController = [SJPageViewController pageViewControllerWithOptions:@{SJPageViewControllerOptionInterPageSpacingKey:@(3)}];
    _pageViewController.dataSource = self;
    _pageViewController.delegate = self;
    
    _menuBar = [SJPageMenuBar.alloc initWithFrame:CGRectZero];
    _menuBar.distribution = SJPageMenuBarDistributionFillEqually;
    _menuBar.dataSource = self;
    _menuBar.delegate = self;
    
    [self addChildViewController:_pageViewController];
    [self.view addSubview:_pageViewController.view];
    [_pageViewController.view mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.offset(0);
    }];
    
}
 
#pragma mark - Page View Controller

- (NSUInteger)numberOfViewControllersInPageViewController:(SJPageViewController *)pageViewController {
    return self.menuItems.count;
}

- (UIViewController *)pageViewController:(SJPageViewController *)pageViewController viewControllerAtIndex:(NSInteger)index {
    return SJDemoTableViewController.new;
}

- (SJPageViewControllerHeaderMode)modeForHeaderWithPageViewController:(SJPageViewController *)pageViewController {
    return SJPageViewControllerHeaderModePinnedToTop;
}

- (nullable __kindof UIView *)viewForHeaderInPageViewController:(SJPageViewController *)pageViewController {
    UIView *headerView = [UIView.alloc initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 200)];
    headerView.backgroundColor = UIColor.redColor;

    [headerView addSubview:_menuBar];
    [_menuBar mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.bottom.right.offset(0);
        make.height.offset(40);
    }];
    return headerView;
}

- (CGFloat)heightForHeaderBoundsWithPageViewController:(SJPageViewController *)pageViewController {
    return 200;
}

- (CGFloat)heightForHeaderPinToVisibleBoundsWithPageViewController:(SJPageViewController *)pageViewController {
    return 40;
}
 
- (void)pageViewController:(SJPageViewController *)pageViewController didScrollInRange:(NSRange)range distanceProgress:(CGFloat)progress {
    [_menuBar scrollInRange:range distaneProgress:progress];
} 

- (void)pageViewController:(SJPageViewController *)pageViewController headerViewVisibleRectDidChange:(CGRect)visibleRect {
    
}

#pragma mark - Page Menu Bar

- (NSInteger)numberOfItemsInPageMenuBar:(SJPageMenuBar *)menuBar {
    return self.pageViewController.numberOfViewControllers;
}

- (UIView<SJPageMenuItemView> *)pageMenuBar:(SJPageMenuBar *)menuBar viewForItemAtIndex:(NSInteger)index {
    SJPageMenuItemView *view = [SJPageMenuItemView.alloc initWithFrame:CGRectZero];
    view.text = self.menuItems[index].title;
    return view;
}

- (void)pageMenuBar:(SJPageMenuBar *)bar focusedIndexDidChange:(NSInteger)index {
    if ( [_pageViewController isViewControllerVisibleAtIndex:index] ) return;
    [_pageViewController setViewControllerAtIndex:index];
}
@end
