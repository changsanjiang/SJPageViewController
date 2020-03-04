//
//  SJPageMenuBar.m
//  SJPageViewController_Example
//
//  Created by BlueDancer on 2020/2/10.
//  Copyright © 2020 changsanjiang@gmail.com. All rights reserved.
//

#import "SJPageMenuBar.h"
#import "SJPageMenuBarScrollIndicator.h"
#import "SJPageMenuItemView.h"
#import <objc/message.h>

NS_ASSUME_NONNULL_BEGIN
@interface UIView (SJPageMenuBarExtended)
@property (nonatomic) CGFloat sj_pageZoomScale;
@end

@implementation UIView (SJPageMenuBarExtended)
- (void)setSj_pageZoomScale:(CGFloat)sj_pageZoomScale {
    objc_setAssociatedObject(self, @selector(sj_pageZoomScale), @(sj_pageZoomScale), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
- (CGFloat)sj_pageZoomScale {
    return [objc_getAssociatedObject(self, _cmd) doubleValue];
}
@end


@interface SJPageMenuBar ()
/// cache 仅在`viewForItemAtIndex:`使用
@property (nonatomic, strong, readonly) NSMutableDictionary<NSNumber *, UIView<SJPageMenuItemView> *> *cache;
@property (nonatomic, strong, readonly) NSMutableArray<UIView<SJPageMenuItemView> *> *menuItemViews;
@property (nonatomic, strong, readonly) SJPageMenuBarScrollIndicator *scrollIndicator;
@property (nonatomic, strong, readonly) UIScrollView *scrollView;
@property (nonatomic) NSInteger focusedIndex;
@property (nonatomic) CGRect previousBounds;
@end

@implementation SJPageMenuBar
@synthesize focusedIndex = _focusedIndex;
@synthesize itemTintColor = _itemTintColor;
@synthesize focusedItemTintColor = _focusedItemTintColor;
@synthesize scrollIndicatorTintColor = _scrollIndicatorTintColor;
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if ( self ) {
        _distribution = SJPageMenuBarDistributionEqualSpacing;
        _itemSpacing = 16;
        _minimumZoomScale = 1.0;
        _maximumZoomScale = 1.0;
        _scrollIndicatorSize = CGSizeMake(12, 2);
        _scrollIndicatorBottomInset = 3.0;
        _cache = NSMutableDictionary.dictionary;
        if ( @available(iOS 13.0, *) ) {
            self.backgroundColor = UIColor.systemGroupedBackgroundColor;
        }
        else {
            self.backgroundColor = UIColor.groupTableViewBackgroundColor;
        }
        [self _setupViews];
    }
    return self;
}

- (NSInteger)numberOfItems {
    return [self.dataSource numberOfItemsInPageMenuBar:self];
}

- (void)reloadPageMenuBar {
    if ( self.bounds.size.height == 0 || self.bounds.size.width == 0 ) return;
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(_reloadPageMenuBar) object:nil];
    [self performSelector:@selector(_reloadPageMenuBar) withObject:nil afterDelay:0 inModes:@[NSRunLoopCommonModes]];
}

- (void)reloadItemAtIndex:(NSInteger)index animated:(BOOL)animated {
    if ( [self _isSafeIndex:index] ) {
        if ( self.menuItemViews.count < index ) {
            [self reloadPageMenuBar];
            return;
        }
        
        NSNumber *idx = @(index);
        __auto_type oldView = self.cache[idx];
        self.cache[idx] = nil;
        __auto_type newView = [self viewForItemAtIndex:index];
        newView.center = oldView.center;
        [self.scrollView addSubview:newView];
        [self.menuItemViews replaceObjectAtIndex:index withObject:newView];
        
        CGFloat oldViewAlpha = oldView.alpha;
        CGFloat newViewAlpha = newView.alpha;
        newView.alpha = 0.001;
        [UIView animateWithDuration:animated ? 0.25 : 0.0 animations:^{
            oldView.alpha = 0.001;
            newView.alpha = newViewAlpha;
            [self _remakeConstraintsWithBeginIndex:index];
        } completion:^(BOOL finished) {
            oldView.alpha = oldViewAlpha;
            [oldView removeFromSuperview];
        }];
    }
}

- (void)scrollToItemAtIndex:(NSInteger)toIdx animated:(BOOL)animated {
     if ( [self _isSafeIndex:toIdx] && _focusedIndex != toIdx ) {
         NSInteger previousIdx = self.focusedIndex;
         self.focusedIndex = toIdx;
         if ( self.bounds.size.height == 0 || self.bounds.size.width == 0 ) return;
         [UIView animateWithDuration:animated ? 0.25 : 0.0 animations:^{
             [self _remakeConstraintsForMenuItemViewWithBeginIndex:previousIdx < toIdx ? previousIdx : toIdx];
             [self _remakeConstraintsForScrollIndicator];
             [self _setContentOffsetForScrollViewToIndex:toIdx];
         }];
     }
}

- (void)scrollInRange:(NSRange)range distaneProgress:(CGFloat)progress {
    if ( [self _isSafeIndex:range.location] && [self _isSafeIndex:NSMaxRange(range)] ) {
        [self _scrollInRange:range distaneProgress:progress];
    }
}

- (nullable __kindof UIView<SJPageMenuItemView> *)viewForItemAtIndex:(NSInteger)index {
    if ( index >= 0 && index < self.numberOfItems ) {
        NSNumber *idx = @(index);
        if ( self.cache[idx] == nil ) {
           __auto_type view = [self.dataSource pageMenuBar:self viewForItemAtIndex:index];
            NSAssert(view != nil, @"The menuItemView can't be nil!");
            view.tintColor = self.itemTintColor;
            [view sizeToFit];
            self.cache[idx] = view;
        }
        return self.cache[idx];
    }
    return nil;
}

#pragma mark -

- (void)setDistribution:(SJPageMenuBarDistribution)distribution {
    if ( distribution != _distribution ) {
        _distribution = distribution;
        [self _remakeConstraints];
    }
}

- (void)setDataSource:(nullable id<SJPageMenuBarDataSource>)dataSource {
    if ( _dataSource != dataSource ) {
        _dataSource = dataSource;
        [self reloadPageMenuBar];
    }
}

- (void)setItemSpacing:(CGFloat)itemSpacing {
    if ( _itemSpacing != itemSpacing ) {
        _itemSpacing = itemSpacing;
        [self _remakeConstraints];
    }
}

- (void)setContentInsets:(UIEdgeInsets)contentInsets {
    if ( !UIEdgeInsetsEqualToEdgeInsets(contentInsets, _contentInsets) ) {
        _contentInsets = contentInsets;
        _scrollView.contentInset = contentInsets;
        [self _remakeConstraints];
    }
}

- (void)setMinimumZoomScale:(CGFloat)minimumZoomScale {
    if ( _minimumZoomScale != minimumZoomScale ) {
        _minimumZoomScale = minimumZoomScale;
        [self _remakeConstraints];
    }
}

- (void)setMaximumZoomScale:(CGFloat)maximumZoomScale {
    if ( _maximumZoomScale != maximumZoomScale ) {
        _maximumZoomScale = maximumZoomScale;
        [self _remakeConstraints];
    }
}

- (void)setShowsScrollIndicator:(BOOL)showsScrollIndicator {
    _scrollIndicator.hidden = !showsScrollIndicator;
}

- (void)setFocusedIndex:(NSInteger)focusedIndex {
    _focusedIndex = focusedIndex;
    if ( [self.delegate respondsToSelector:@selector(pageMenuBar:focusedIndexDidChange:)] ) {
        [self.delegate pageMenuBar:self focusedIndexDidChange:focusedIndex];
    }
}

- (void)setItemTintColor:(nullable UIColor *)itemTintColor {
    _itemTintColor = itemTintColor;
    [self _resetTintColorForMenuItemViews];
}

- (void)setFocusedItemTintColor:(nullable UIColor *)focusedItemTintColor {
    _focusedItemTintColor = focusedItemTintColor;
    [self _resetTintColorForMenuItemViews];
}

- (void)setScrollIndicatorSize:(CGSize)scrollIndicatorSize {
    if ( !CGSizeEqualToSize(scrollIndicatorSize, _scrollIndicatorSize) ) {
        _scrollIndicatorSize = scrollIndicatorSize;
        [self _remakeConstraintsForScrollIndicator];
    }
}

- (void)setScrollIndicatorBottomInset:(CGFloat)scrollIndicatorBottomInset {
    if ( scrollIndicatorBottomInset != _scrollIndicatorBottomInset ) {
        _scrollIndicatorBottomInset = scrollIndicatorBottomInset;
        [self _remakeConstraintsForScrollIndicator];
    }
}

- (void)setScrollIndicatorTintColor:(nullable UIColor *)scrollIndicatorTintColor {
    _scrollIndicatorTintColor = scrollIndicatorTintColor;
    _scrollIndicator.backgroundColor = self.scrollIndicatorTintColor;
}

- (void)setScrollIndicatorLayoutMode:(SJPageMenuBarScrollIndicatorLayoutMode)scrollIndicatorLayoutMode {
    _scrollIndicatorLayoutMode = scrollIndicatorLayoutMode;
    [self _remakeConstraintsForScrollIndicator];
}

- (void)setCenterlineOffset:(CGFloat)centerlineOffset {
    if ( centerlineOffset != _centerlineOffset ) {
        _centerlineOffset = centerlineOffset;
        [self _remakeConstraints];
    }
}

#pragma mark -

- (NSInteger)focusedIndex {
    return self.numberOfItems != 0 ? _focusedIndex : NSNotFound;
}
 
- (UIColor *)itemTintColor {
    if ( _itemTintColor == nil ) {
        _itemTintColor = UIColor.systemGrayColor;
    }
    return _itemTintColor;
}

- (UIColor *)focusedItemTintColor {
    if ( _focusedItemTintColor == nil ) {
        _focusedItemTintColor = UIColor.systemBlueColor;
    }
    return _focusedItemTintColor;
}

- (BOOL)showsScrollIndicator {
    return !_scrollIndicator.isHidden;
}

- (UIColor *)scrollIndicatorTintColor {
    if ( _scrollIndicatorTintColor == nil ) {
        _scrollIndicatorTintColor = UIColor.systemBlueColor;
    }
    return _scrollIndicatorTintColor;
}

#pragma mark -
 
- (void)_setupViews {
    [self addSubview:self.scrollView];
    [self.scrollView addSubview:self.scrollIndicator];
    
    UITapGestureRecognizer *tap = [UITapGestureRecognizer.alloc initWithTarget:self action:@selector(_handleTap:)];
    [self.scrollView addGestureRecognizer:tap];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    CGRect bounds = self.bounds;
    if ( !CGRectEqualToRect(self.previousBounds, bounds) ) {
        self.previousBounds = bounds;
        _scrollView.frame = bounds;
        self.menuItemViews.count == 0 ? [self reloadPageMenuBar] : [self _remakeConstraints];
    }
}

@synthesize menuItemViews = _menuItemViews;
- (NSMutableArray<UIView<SJPageMenuItemView> *> *)menuItemViews {
    if ( _menuItemViews == nil ) {
        _menuItemViews = NSMutableArray.new;
    }
    return _menuItemViews;
}

@synthesize scrollIndicator = _scrollIndicator;
- (UIView *)scrollIndicator {
    if ( _scrollIndicator == nil ) {
        _scrollIndicator = [SJPageMenuBarScrollIndicator.alloc initWithFrame:CGRectZero];
        _scrollIndicator.backgroundColor = self.scrollIndicatorTintColor;
    }
    return _scrollIndicator;
}

@synthesize scrollView = _scrollView;
- (UIScrollView *)scrollView {
    if ( _scrollView == nil ) {
        _scrollView = [UIScrollView.alloc initWithFrame:CGRectZero];
        if (@available(iOS 11.0, *)) {
            _scrollView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        }
        _scrollView.showsVerticalScrollIndicator = NO;
        _scrollView.showsHorizontalScrollIndicator = NO;
    }
    return _scrollView;
}

#pragma mark -

- (BOOL)_isSafeIndex:(NSInteger)index {
    return (index >= 0 && index < self.numberOfItems);
}

- (void)_reloadPageMenuBar {
    [self.menuItemViews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    [self.menuItemViews removeAllObjects];
    
    if ( self.numberOfItems != 0 ) {
        for ( NSInteger index = 0 ; index < self.numberOfItems ; ++ index ) {
            __auto_type menuItemView = [self viewForItemAtIndex:index];
            [self.menuItemViews addObject:menuItemView];
            [self.scrollView addSubview:menuItemView];
        }
    }
    [self _remakeConstraints];
}

- (void)_remakeConstraints {
    [self _remakeConstraintsWithBeginIndex:0];
}

- (void)_remakeConstraintsWithBeginIndex:(NSInteger)index {
    if ( [self _isSafeIndex:index] ) {
        [self _remakeConstraintsForMenuItemViewWithBeginIndex:index];
        [self _remakeConstraintsForScrollIndicator];
    }
}

- (void)_remakeConstraintsForMenuItemViewWithBeginIndex:(NSInteger)safeIndex {
    [self _remakeConstraintsForMenuItemViewWithBeginIndex:safeIndex zoomScale:^CGFloat(NSInteger index) {
        return self.focusedIndex == index ? self.maximumZoomScale : self.minimumZoomScale;
    } tintColor:^UIColor * _Nonnull(NSInteger index) {
        return self.focusedIndex == index ? self.focusedItemTintColor : self.itemTintColor;
    } centerlineOffset:^CGFloat(NSInteger index) {
        return self.focusedIndex == index ? 0 : self.centerlineOffset;;
    }];
}

- (void)_remakeConstraintsForScrollIndicator {
    if ( self.bounds.size.height == 0 || self.bounds.size.width == 0 ) return;
    if ( self.menuItemViews.count <= _focusedIndex ) return;
    CGSize size = [self _sizeForScrollIndicatorAtIndex:_focusedIndex];
    CGRect frame = (CGRect){0, 0, size};
    frame.origin.y = self.bounds.size.height - _scrollIndicatorBottomInset - _scrollIndicatorSize.height;
    frame.origin.x = self.menuItemViews[_focusedIndex].center.x - frame.size.width * 0.5;
    _scrollIndicator.frame = frame;
}

- (void)_scrollInRange:(NSRange)range distaneProgress:(CGFloat)progress {
    NSInteger left = range.location;
    NSInteger right = NSMaxRange(range);
    
    if      ( left == right || progress <= 0 ) {
        [self scrollToItemAtIndex:left animated:YES];
    }
    else if ( progress >= 1 ) {
        [self scrollToItemAtIndex:right animated:YES];
    }
    else {
        CGFloat maximumZoomScale = _maximumZoomScale;
        CGFloat minimumZoomScale = _minimumZoomScale;
        [self _remakeConstraintsForMenuItemViewWithBeginIndex:left zoomScale:^CGFloat(NSInteger index) {
            CGFloat zoomScaleLength = maximumZoomScale - minimumZoomScale;
            // zoomScale
            if      ( index == left )
                return maximumZoomScale - zoomScaleLength * progress;
            else if ( index == right )
                return minimumZoomScale + zoomScaleLength * progress;
            return minimumZoomScale;
        } tintColor:^UIColor * _Nonnull(NSInteger index) {
            // tintColor
            if      ( index == left )
                return [self _gradientColorWithProgress:1 - progress];
            else if ( index == right )
                return [self _gradientColorWithProgress:progress];
            return self.itemTintColor;
        } centerlineOffset:^CGFloat(NSInteger index) {
            if      ( index == left )
                return self.centerlineOffset * progress;
            else if ( index == right )
                return (1 - progress) * self.centerlineOffset;
            return self.centerlineOffset;
        }];
        
        __auto_type leftView = self.menuItemViews[left];
        __auto_type rightView = self.menuItemViews[right];
        CGFloat distance = CGRectGetMidX(rightView.frame) - CGRectGetMidX(leftView.frame);
        CGFloat currScrollIndicatorWidth = 0;
        CGSize leftSize = [self _sizeForScrollIndicatorAtIndex:left];
        CGSize rightSize = [self _sizeForScrollIndicatorAtIndex:right];
        // A + (B - A) = B
        // 小于 0.5 开始变长
        if ( progress < 0.5 ) {
            currScrollIndicatorWidth = distance * progress + leftSize.width + (rightSize.width - leftSize.width) * progress;
        }
        // 超过 0.5 开始缩小
        else {
            currScrollIndicatorWidth = distance * (1 - progress) + leftSize.width + (rightSize.width - leftSize.width) * progress;
        }
        CGFloat maxOffset = rightView.center.x - leftView.center.x;
        CGFloat currOffset = leftView.center.x + maxOffset * progress - currScrollIndicatorWidth * 0.5;
        CGRect frame = _scrollIndicator.frame;
        frame.size.width = currScrollIndicatorWidth;
        frame.origin.x = currOffset;
        _scrollIndicator.frame = frame;
    }
}

- (void)_remakeConstraintsForMenuItemViewWithBeginIndex:(NSInteger)safeIndex zoomScale:(CGFloat(^)(NSInteger index))zoomScaleBlock tintColor:(UIColor *(^)(NSInteger index))tintColorBlock centerlineOffset:(CGFloat(^)(NSInteger index))centerlineOffsetBlock {
    if ( self.bounds.size.height == 0 || self.bounds.size.width == 0 ) return;
    CGFloat contentLayoutHeight = self.bounds.size.height - self.contentInsets.top - self.contentInsets.bottom;
    CGFloat contentLayoutWidth = self.bounds.size.width - _contentInsets.left - _contentInsets.right;
    CGFloat itemWidth = contentLayoutWidth / self.numberOfItems;
    if ( _distribution == SJPageMenuBarDistributionFillEqually ) {
        NSInteger maxs = 1;
        NSInteger mins = (self.numberOfItems - maxs);
        itemWidth = contentLayoutWidth / (maxs * _maximumZoomScale + mins * _minimumZoomScale);
    }
    CGFloat itemSpacing = _distribution == SJPageMenuBarDistributionEqualSpacing ? _itemSpacing : 0;
    UIView<SJPageMenuItemView> *prev = safeIndex == 0 ? nil : _menuItemViews[safeIndex - 1];
    for (NSInteger index = safeIndex ; index < self.menuItemViews.count ; ++ index ) {
        __auto_type curr = self.menuItemViews[index];
        // zoomScale
        CGFloat zoomScale = zoomScaleBlock(index);
        [self _setZoomScale:zoomScale forMenuItemViewAtIndex:index];
        
        // tintColor
        UIColor *tintColor = tintColorBlock(index);
        curr.tintColor = tintColor;

        // bounds
        CGRect bounds = curr.bounds;
        switch ( _distribution ) {
            case SJPageMenuBarDistributionEqualSpacing:
                break;
            case SJPageMenuBarDistributionFillEqually:
                bounds.size.width = itemWidth;
                break;
        }
        curr.bounds = bounds;
        
        // center
        CGPoint center = CGPointZero;
        // center.x
        center.x = bounds.size.width * 0.5 * zoomScale;
        if ( prev != nil ) {
            CGFloat prez = prev.sj_pageZoomScale;
            center.x += prev.center.x + prev.bounds.size.width * 0.5 * prez + itemSpacing ;
        }
        // center.y
        center.y = contentLayoutHeight * 0.5 + centerlineOffsetBlock(index);

        curr.center = center;
        prev = curr;
    }
    
    [self.scrollView setContentSize:CGSizeMake(CGRectGetMaxX(self.menuItemViews.lastObject.frame), self.bounds.size.height)];
}

- (void)_setContentOffsetForScrollViewToIndex:(NSInteger)safeIndex {
    __auto_type toView = [self viewForItemAtIndex:safeIndex];
    CGFloat half = self.bounds.size.width * 0.5;
    CGFloat offset = toView.center.x - half;
    
    CGFloat minOffset = 0;
    CGFloat maxOffset = _scrollView.contentSize.width - self.bounds.size.width + _contentInsets.left;
    if ( maxOffset < 0 ) {
        maxOffset = -_contentInsets.left;
    }
    
    if ( offset <= minOffset ) {
        offset = -_contentInsets.left;
    }
    else if ( offset >= maxOffset ) {
        offset = maxOffset;
    } 
    [self.scrollView setContentOffset:CGPointMake(offset, 0) animated:NO];
}

struct color {
    CGFloat red;
    CGFloat green;
    CGFloat blue;
    CGFloat alpah;
};

// progress [0,1],  0 为 itemTintColor, 1 为 focusedTintColor, 相互转换
- (UIColor *)_gradientColorWithProgress:(CGFloat)progress {
    if ( [self.focusedItemTintColor isEqual:self.itemTintColor] ) return self.itemTintColor;
    
    struct color tintColor, focusedTintColor;
    [self.itemTintColor getRed:&tintColor.red green:&tintColor.green blue:&tintColor.blue alpha:&tintColor.alpah];
    [self.focusedItemTintColor getRed:&focusedTintColor.red green:&focusedTintColor.green blue:&focusedTintColor.blue alpha:&focusedTintColor.alpah];
    
    return [UIColor colorWithRed:tintColor.red + (focusedTintColor.red - tintColor.red) * progress
                            green:tintColor.green + (focusedTintColor.green - tintColor.green) * progress
                            blue:tintColor.blue + (focusedTintColor.blue - tintColor.blue) * progress
                           alpha:tintColor.alpah + (focusedTintColor.alpah - tintColor.alpah) * progress];
}

- (void)_setZoomScale:(CGFloat)zoomScale forMenuItemViewAtIndex:(NSInteger)safeIndex {
    if ( _minimumZoomScale >= _maximumZoomScale ) zoomScale = _maximumZoomScale;
    __auto_type view = self.menuItemViews[safeIndex];
    view.transform = CGAffineTransformMakeScale(zoomScale, zoomScale);
    view.sj_pageZoomScale = zoomScale;
}

- (void)_resetTintColorForMenuItemViews {
    [self.menuItemViews enumerateObjectsUsingBlock:^(UIView<SJPageMenuItemView> * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        obj.tintColor = idx == self.focusedIndex ? self.focusedItemTintColor : self.itemTintColor;
    }];
}

- (void)_handleTap:(UITapGestureRecognizer *)tap {
    CGPoint location = [tap locationInView:tap.view];
    [self.menuItemViews enumerateObjectsUsingBlock:^(UIView<SJPageMenuItemView> * _Nonnull view, NSUInteger idx, BOOL * _Nonnull stop) {
        if ( CGRectContainsPoint(view.frame, CGPointMake(location.x, view.frame.origin.y)) ) {
            [self scrollToItemAtIndex:idx animated:YES];
            *stop = YES;
        }
    }];
}

- (CGSize)_sizeForScrollIndicatorAtIndex:(NSInteger)index {
    CGSize size = CGSizeZero;
    switch ( _scrollIndicatorLayoutMode ) {
        case SJPageMenuBarScrollIndicatorLayoutModeSpecifiedWidth:
            size = _scrollIndicatorSize;
            break;
        case SJPageMenuBarScrollIndicatorLayoutModeEqualItemViewContentWidth: {
            size = [self.menuItemViews[index] sizeThatFits:CGSizeMake(CGFLOAT_MAX, CGFLOAT_MAX)];
            size.height = _scrollIndicatorSize.height;
        }
            break;
        case SJPageMenuBarScrollIndicatorLayoutModeEqualItemViewLayoutWidth:
            size = CGSizeMake(self.menuItemViews[index].bounds.size.width, _scrollIndicatorSize.height);
            break;
    }
    return size;
}
@end
NS_ASSUME_NONNULL_END
