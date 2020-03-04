//
//  SJViewController0.m
//  SJPageViewController_Example
//
//  Created by BlueDancer on 2020/2/8.
//  Copyright © 2020 changsanjiang@gmail.com. All rights reserved.
//

#import "SJViewController4.h"
#import <SJPageViewController/SJPageViewController.h>
#import <Masonry/Masonry.h>
#import "SJDemoTableViewController.h"


@interface SJNavigationBar : UIView
@property (nonatomic, strong, readonly) UIView *contentView;
@property (nonatomic, strong, readonly) UIButton *backButton;
@end

@implementation SJNavigationBar
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if ( self ) {
        _contentView = [UIView.alloc initWithFrame:CGRectZero];
        _contentView.backgroundColor = UIColor.orangeColor;
        _contentView.layer.borderWidth = 0.5;
        _contentView.layer.borderColor = UIColor.blackColor.CGColor;
        [self addSubview:_contentView];
        
        _backButton = [UIButton buttonWithType:UIButtonTypeSystem];
        [_backButton setTitle:@"  <--返回按钮" forState:UIControlStateNormal];
        [self addSubview:_backButton];
        
        [_contentView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.offset(0);
        }];
        
        [_backButton mas_makeConstraints:^(MASConstraintMaker *make) {
            if (@available(iOS 11.0, *)) {
                make.top.equalTo(self.mas_safeAreaLayoutGuideTop);
            } else {
                make.top.offset(20);
            }
            make.left.bottom.offset(0);
            make.height.offset(44);
        }];
    }
    return self;
}
@end

@interface SJViewController4 ()<SJPageViewControllerDelegate, SJPageViewControllerDataSource>
@property (nonatomic, strong) SJNavigationBar *navBar;
@property (nonatomic, strong) SJPageViewController *pageViewController;
@end

@implementation SJViewController4

- (void)viewDidLoad {
    [super viewDidLoad];
    [self _setupViews];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:YES];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}

- (void)dealloc {
#ifdef DEBUG
    NSLog(@"%d \t %s", (int)__LINE__, __func__);
#endif
}

- (void)backButtonWasTapped {
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark -

- (void)_setupViews {
    self.view.backgroundColor = UIColor.blackColor;
    
    _navBar = [SJNavigationBar.alloc initWithFrame:CGRectZero];
    _navBar.contentView.alpha = 0;
    [_navBar.backButton addTarget:self action:@selector(backButtonWasTapped) forControlEvents:UIControlEventTouchUpInside];
    
    _pageViewController = [SJPageViewController pageViewControllerWithOptions:@{SJPageViewControllerOptionInterPageSpacingKey:@(3)}];
    _pageViewController.dataSource = self;
    _pageViewController.delegate = self;
    [self addChildViewController:_pageViewController];
    [self.view addSubview:_pageViewController.view];
    [self.view addSubview:_navBar];
    
    [_navBar mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.offset(0);
    }];
    
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
    UIView *headerView = [UIView.alloc initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 375)];
    headerView.backgroundColor = UIColor.purpleColor;
    
    UILabel *channelView = [UILabel.alloc initWithFrame:CGRectZero];
    channelView.text = @"左右滑动切换vc";
    channelView.backgroundColor = UIColor.greenColor;
    [headerView addSubview:channelView];
    [channelView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.bottom.right.offset(0);
        make.height.offset(44);
    }];
    
    return headerView;
}
 
///
/// 在顶部悬浮保留的高度
///
- (CGFloat)heightForHeaderPinToVisibleBoundsWithPageViewController:(SJPageViewController *)pageViewController {
    return 44 + _navBar.bounds.size.height;
}

#pragma mark -

///
/// HeaderView 可见范围发生改变的回调
///
- (void)pageViewController:(SJPageViewController *)pageViewController headerViewVisibleRectDidChange:(CGRect)visibleRect {
    /// headerView的高度
    CGFloat headerViewHeight = pageViewController.heightForHeaderBounds;
    /// 在顶部固定时的高度
    CGFloat pinnedHeight = pageViewController.heightForHeaderPinToVisibleBounds;
    /// 设置导航栏透明度
    CGFloat alpha = 1 - (visibleRect.size.height - pinnedHeight) / (headerViewHeight - pinnedHeight);
    _navBar.contentView.alpha = alpha;
}
@end
