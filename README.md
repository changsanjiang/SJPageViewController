# SJPageViewController

[![CI Status](https://img.shields.io/travis/changsanjiang@gmail.com/SJPageViewController.svg?style=flat)](https://travis-ci.org/changsanjiang@gmail.com/SJPageViewController)
[![Version](https://img.shields.io/cocoapods/v/SJPageViewController.svg?style=flat)](https://cocoapods.org/pods/SJPageViewController)
[![License](https://img.shields.io/cocoapods/l/SJPageViewController.svg?style=flat)](https://cocoapods.org/pods/SJPageViewController)
[![Platform](https://img.shields.io/cocoapods/p/SJPageViewController.svg?style=flat)](https://cocoapods.org/pods/SJPageViewController)

## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Installation

SJPageViewController is available through [CocoaPods](https://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'SJPageViewController/ObjC'
# or  
pod 'SJPageViewController/Swift'
```

## Author

changsanjiang@gmail.com, changsanjiang@gmail.com

## License

SJPageViewController is available under the MIT license. See the LICENSE file for more info.


___

# SJPageViewController


## 顶部下拉时, headerView 跟随移动

![tracking.gif](https://upload-images.jianshu.io/upload_images/2318691-dae7ac82261576a5.gif?imageMogr2/auto-orient/strip)

## 顶部下拉时, headerView 固定在顶部

![pinnedToTop.gif](https://upload-images.jianshu.io/upload_images/2318691-aff58d85caa69fb3.gif?imageMogr2/auto-orient/strip)

## 顶部下拉时, headerView 同比放大

![sacleAspectFill.gif](https://upload-images.jianshu.io/upload_images/2318691-b021b5c1a6099bc6.gif?imageMogr2/auto-orient/strip)

## 普通模式

![normal.gif](https://upload-images.jianshu.io/upload_images/2318691-bafc820aa9f27985.gif?imageMogr2/auto-orient/strip)

## 自定义导航栏控制透明度

![alpha.gif](https://upload-images.jianshu.io/upload_images/2318691-16066ab069b338f1.gif?imageMogr2/auto-orient/strip)

## 快速开始

1. 导入头文件:
```Objective-C
#import <SJPageViewController/SJPageViewController.h>
```

2. 添加 `pageViewController` 属性

```Objective-C
@interface SJViewController ()<SJPageViewControllerDelegate, SJPageViewControllerDataSource>
@property (nonatomic, strong) SJPageViewController *pageViewController;
@end
```

3. 创建 `pageViewController` 对象:

```Objective-C
    # 参数 options 可以传入设置 nil, 当前传入参表示为设置页面之间的间隔为3
    _pageViewController = [SJPageViewController pageViewControllerWithOptions:@{SJPageViewControllerOptionInterPageSpacingKey:@(3)}];
    _pageViewController.dataSource = self;
    _pageViewController.delegate = self;
    _pageViewController.view.frame = self.view.bounds;
    [self addChildViewController:_pageViewController];
    [self.view addSubview:_pageViewController.view]; 
```

4. 实现 `SJPageViewControllerDataSource` 数据源方法:

```Objective-C
# 返回控制器的数量
- (NSUInteger)numberOfViewControllersInPageViewController:(SJPageViewController *)pageViewController {
    return 3;
}

# 返回`index`对应的控制器
- (UIViewController *)pageViewController:(SJPageViewController *)pageViewController viewControllerAtIndex:(NSInteger)index {
    return SJDemoTableViewController.new;
}
```

以上步骤, 即创建了一个简单的`pageViewController`, 下面为如何配置`HeaderView`

# 配置 HeaderView 

5.1 设置 `HeaderView`

```Objective-C
- (nullable __kindof UIView *)viewForHeaderInPageViewController:(SJPageViewController *)pageViewController {
    UIView *headerView = [UIView.alloc initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 375)];
    headerView.backgroundColor = UIColor.purpleColor;
    return headerView;
}

```

5.2 设置`HeaderMode`

```Objective-C
- (SJPageViewControllerHeaderMode)modeForHeaderWithPageViewController:(SJPageViewController *)pageViewController {
///
/// SJPageViewControllerHeaderModeTracking
///     - 顶部下拉时, headerView 跟随移动
///
/// SJPageViewControllerHeaderModePinnedToTop
///     - 顶部下拉时, headerView 固定在顶部
///
/// SJPageViewControllerHeaderModeAspectFill
///     - 顶部下拉时, headerView 同比放大
///
    return SJPageViewControllerHeaderModePinnedToTop;
}
```

5.3 设置`HeaderView`上拉时固定在顶部悬浮的高度(示例图中的绿色区域)

```
///
/// 在顶部悬浮保留的高度
///
- (CGFloat)heightForHeaderPinToVisibleBoundsWithPageViewController:(SJPageViewController *)pageViewController {
    return 44;
}
```

____


# SJPageMenuBar

## 几个样式

![Mar-04-2020 23-13-16.gif](https://upload-images.jianshu.io/upload_images/2318691-e00ff572d5c548d2.gif?imageMogr2/auto-orient/strip)

![image.png](https://upload-images.jianshu.io/upload_images/2318691-1d1737955b14e15b.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

## 快速开始

1. 导入头文件:
```Objective-C
#import <SJPageViewController/SJPageMenuBar.h>
#import <SJPageViewController/SJPageMenuItemView.h>
```

2. 添加 `pageMenuBar` 属性

```Objective-C
@interface SJViewController ()<SJPageMenuBarDataSource, SJPageMenuBarDelegate>
@property (nonatomic, strong) SJPageMenuBar *pageMenuBar;
@end
```

3. 创建 `pageMenuBar` 对象:

```Objective-C
    SJPageMenuBar *pageMenuBar = [SJPageMenuBar.alloc initWithFrame:CGRectZero];
    pageMenuBar.dataSource = self;
    pageMenuBar.delegate = self;
    [self.view addSubview:pageMenuBar];
    [pageMenuBar mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.offset(0);
        make.left.right.offset(0);
        make.height.offset(60);
    }];
    _pageMenuBar = pageMenuBar;
    
    // 内容
    pageMenuBar.contentInsets = UIEdgeInsetsMake(0, 12, 0, 12);

    // 分布模式. 这里设置为等间隔分布
    pageMenuBar.distribution = SJPageMenuBarDistributionEqualSpacing;
    pageMenuBar.minimumZoomScale = 0.8;
    pageMenuBar.maximumZoomScale = 1.0;
    
    // 显示底部线
    pageMenuBar.showsScrollIndicator = YES;
    // 线宽的布局模式, 这里设置为指定宽度
    pageMenuBar.scrollIndicatorLayoutMode = SJPageMenuBarScrollIndicatorLayoutModeSpecifiedWidth;
    // 指定宽度为`12`, 高度为`2`
    pageMenuBar.scrollIndicatorSize = CGSizeMake(12, 2);
```

4. 添加`item`:

```Objective-C
    var views = [SJPageMenuItemView]()
    for index in 0...5 {
        let itemView = SJPageMenuItemView.init(frame: .zero)
        itemView.text = "标题"
    }
    self.pageMenuBar.itemViews = views
```
