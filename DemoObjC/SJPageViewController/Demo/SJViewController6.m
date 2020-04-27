//
//  SJViewController6.m
//  SJPageViewController_Example
//
//  Created by BlueDancer on 2020/4/27.
//  Copyright © 2020 changsanjiang@gmail.com. All rights reserved.
//

#import "SJViewController6.h"
#import <SJPageViewController/SJPageMenuBar.h>
#import <SJPageViewController/SJPageMenuItemView.h>
#import <Masonry/Masonry.h>

@interface SJViewController6 ()
@property (nonatomic, strong, nullable) SJPageMenuBar *pageMenuBar;
@end

@implementation SJViewController6
- (void)viewDidLoad {
    [super viewDidLoad];
    _pageMenuBar = [SJPageMenuBar.alloc initWithFrame:CGRectZero];
    [self.view addSubview:_pageMenuBar];
    [_pageMenuBar mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.offset(0);
        make.left.right.offset(0);
        make.height.offset(44);
    }];
    
    [self _setItemViewsToPageMenuBar:_pageMenuBar];
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
 
- (IBAction)insert1:(id)sender {
    SJPageMenuItemView *view = [SJPageMenuItemView.alloc initWithFrame:CGRectZero];
    view.text = @"拉动手能力";
    view.font = [UIFont boldSystemFontOfSize:18];
    [_pageMenuBar insertItemAtIndex:_pageMenuBar.numberOfItems view:view animated:YES];
}
- (IBAction)insert2:(id)sender {
    SJPageMenuItemView *view = [SJPageMenuItemView.alloc initWithFrame:CGRectZero];
    view.text = @"拉动手能力";
    view.font = [UIFont boldSystemFontOfSize:18];
    [_pageMenuBar insertItemAtIndex:arc4random() % _pageMenuBar.numberOfItems + 1 view:view animated:YES];
}

- (IBAction)insert3:(id)sender {
    SJPageMenuItemView *view = [SJPageMenuItemView.alloc initWithFrame:CGRectZero];
    view.text = @"拉动手能力";
    view.font = [UIFont boldSystemFontOfSize:18];
    [_pageMenuBar insertItemAtIndex:arc4random() % _pageMenuBar.numberOfItems + 1 view:view animated:NO];
}

- (IBAction)move1:(id)sender {
    [_pageMenuBar moveItemAtIndex:arc4random() % _pageMenuBar.numberOfItems toIndex:arc4random() % _pageMenuBar.numberOfItems animated:YES];
}

- (IBAction)move2:(id)sender {
    [_pageMenuBar moveItemAtIndex:arc4random() % _pageMenuBar.numberOfItems toIndex:arc4random() % _pageMenuBar.numberOfItems animated:NO];
}
  
- (IBAction)reload:(id)sender {
    NSInteger index = arc4random() % _pageMenuBar.numberOfItems;
    SJPageMenuItemView *view = [_pageMenuBar viewForItemAtIndex:index];
    view.text = @[@"是考虑发的是", @"水电"][arc4random() % 2];
    
    [_pageMenuBar reloadItemAtIndex:index animated:YES];
}

- (IBAction)reload2:(id)sender {
    NSInteger index = arc4random() % _pageMenuBar.numberOfItems;
    SJPageMenuItemView *view = [_pageMenuBar viewForItemAtIndex:index];
    view.text = @[@"是考虑发的是", @"水电"][arc4random() % 2];
    
    [_pageMenuBar reloadItemAtIndex:index animated:NO];
}

- (IBAction)delete:(id)sender {
    [_pageMenuBar deleteItemAtIndex:arc4random() % _pageMenuBar.numberOfItems animated:YES];
}

- (IBAction)delete1:(id)sender {
    [_pageMenuBar deleteItemAtIndex:arc4random() % _pageMenuBar.numberOfItems animated:NO];
}

@end
