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

#import <SJVideoPlayer/SJVideoPlayer.h>
#import <SJUIKit/NSAttributedString+SJMake.h>
 
@interface SJViewController5 ()<SJPageViewControllerDelegate, SJPageViewControllerDataSource, SJPageMenuBarDelegate>
@property (nonatomic, strong) SJPageViewController *pageViewController;
@property (nonatomic, strong) SJPageMenuBar *menuBar;
@property (nonatomic, strong) SJVideoPlayer *player;
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
        NSMutableArray<SJPageMenuItemView *> *m = [NSMutableArray arrayWithCapacity:5];
        for ( int i = 0 ; i < 99 ; ++ i  ) {
            SJPageMenuItemView *view = [SJPageMenuItemView.alloc initWithFrame:CGRectZero];
            view.text = @[@"从前", @"有", @"99", @"座", @"灵剑山AAAAAAAAAA"][i % 5];
            view.font = [UIFont boldSystemFontOfSize:18];
            [m addObject:view];
        }
        self.menuBar.itemViews = m;
        [self.pageViewController reloadPageViewController];
        [self.menuBar scrollToItemAtIndex:4 animated:NO];
    });
}

- (BOOL)shouldAutorotate {
    return NO;
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
    _menuBar.contentInsets = UIEdgeInsetsMake(0, 12, 0, 12);
    _menuBar.scrollIndicatorLayoutMode = SJPageMenuBarScrollIndicatorLayoutModeEqualItemViewContentWidth;
    _menuBar.delegate = self;
    
    [self addChildViewController:_pageViewController];
    [self.view addSubview:_pageViewController.view];
    [_pageViewController.view mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.offset(0);
    }];
    
}
 
#pragma mark - Page View Controller

- (NSUInteger)numberOfViewControllersInPageViewController:(SJPageViewController *)pageViewController {
    return self.menuBar.numberOfItems;
}

- (UIViewController *)pageViewController:(SJPageViewController *)pageViewController viewControllerAtIndex:(NSInteger)index {
    return SJDemoTableViewController.new;
}

- (SJPageViewControllerHeaderMode)modeForHeaderWithPageViewController:(SJPageViewController *)pageViewController {
    return SJPageViewControllerHeaderModePinnedToTop;
}

// 添加`player.view`和`menuBar`到 headerView 中
- (nullable __kindof UIView *)viewForHeaderInPageViewController:(SJPageViewController *)pageViewController {
    UIView *headerView = [UIView.alloc initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 210 + 40)];
    headerView.backgroundColor = UIColor.redColor;
    
    if ( _player == nil ) {
        _player = SJVideoPlayer.player;
        _player.URLAsset = [SJVideoPlayerURLAsset.alloc initWithURL:[NSURL URLWithString:@"https://dh2.v.netease.com/2017/cg/fxtpty.mp4"] startPosition:10];
        __weak typeof(self) _self = self;
        _player.playbackObserver.timeControlStatusDidChangeExeBlock = ^(__kindof SJBaseVideoPlayer * _Nonnull player) {
            __strong typeof(_self) self = _self;
            if ( !self ) return;
            
            [player.prompt show:[NSAttributedString sj_UIKitText:^(id<SJUIKitTextMakerProtocol>  _Nonnull make) {
                make.append(player.isPaused ? @"已暂停" : @"正在播放中");
                make.textColor(UIColor.whiteColor);
            }] duration:-1];
            
            // 播放器处于播放中时, 纠正`headerView`的位置
            if ( player.isPlaying ) {
                SJDemoTableViewController *tableViewController = self.pageViewController.focusedViewController;
                UIView *headerView = self.pageViewController.headerView;
                UITableView *tableView = tableViewController.tableView;
                CGPoint offset = tableView.contentOffset;
                CGRect rect = [headerView convertRect:headerView.bounds toView:tableView.superview];
                offset.y += rect.origin.y;
                // 加个动画, 顺畅一些
                [UIView animateWithDuration:0.4 animations:^{
                    CGRect frame = headerView.frame;
                    frame.origin.y -= rect.origin.y;
                    headerView.frame = frame;
                    [tableViewController.tableView setContentOffset:offset animated:NO];
                }];
            }
        };
    }
    
    [headerView addSubview:_player.view];
    [headerView addSubview:_menuBar];
    
    [_player.view mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.offset(0);
        make.bottom.equalTo(self.menuBar.mas_top);
    }];
    [_menuBar mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.bottom.right.offset(0);
        make.height.offset(40);
    }];
    return headerView;
}

// 钉在顶部的高度
//  - 播放器处于暂停时, 只钉住40的高度, 保留`menuBar`. 处于播放器中时, 保留整个`headerView`的高度
- (CGFloat)heightForHeaderPinToVisibleBoundsWithPageViewController:(SJPageViewController *)pageViewController {
    return _player.isPaused ? 40 : 210 + 40;
}
 
- (void)pageViewController:(SJPageViewController *)pageViewController didScrollInRange:(NSRange)range distanceProgress:(CGFloat)progress {
    [_menuBar scrollInRange:range distanceProgress:progress];
}

#pragma mark - Page Menu Bar

- (void)pageMenuBar:(SJPageMenuBar *)bar focusedIndexDidChange:(NSUInteger)index {
    if ( [_pageViewController isViewControllerVisibleAtIndex:index] ) return;
    [_pageViewController setViewControllerAtIndex:index];
}
@end
