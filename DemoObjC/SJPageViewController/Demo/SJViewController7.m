//
//  SJViewController7.m
//  SJPageViewController_Example
//
//  Created by BlueDancer on 2020/4/27.
//  Copyright © 2020 changsanjiang@gmail.com. All rights reserved.
//

#import "SJViewController7.h"
#import <SJPageViewController/SJPageMenuBar.h>
#import <Masonry/Masonry.h>
#import <SJVideoPlayer/SJVideoPlayerSettings.h>

@interface SJCustomPageMenuItemView : UIView<SJPageMenuItemView>
@property (nonatomic, getter=isFocusedMenuItem) BOOL focusedMenuItem;
@property (nonatomic, strong, null_resettable) UIColor *tintColor;
@property (nonatomic) CGFloat transitionProgress;
- (CGSize)sizeThatFits:(CGSize)size;
- (void)sizeToFit;

@property (nonatomic, strong, null_resettable) UIFont *font;
@property (nonatomic, copy, nullable) NSString *text;

- (BOOL)deleteButtonFrameContainsPoint:(CGPoint)point;
@end


@interface SJViewController7 ()
@property (nonatomic, strong, nullable) SJPageMenuBar *pageMenuBar;

@end

@implementation SJViewController7

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = UIColor.whiteColor;
    
    _pageMenuBar = [SJPageMenuBar.alloc initWithFrame:CGRectZero];
    _pageMenuBar.showsScrollIndicator = NO;
    _pageMenuBar.contentInsets = UIEdgeInsetsMake(0, 12, 0, 12);
    _pageMenuBar.itemTintColor = UIColor.whiteColor;
    _pageMenuBar.focusedItemTintColor = UIColor.whiteColor;
    
    [self.view addSubview:_pageMenuBar];
    [_pageMenuBar mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.offset(0);
        make.left.right.offset(0);
        make.height.offset(44);
    }];
    
    NSMutableArray<SJCustomPageMenuItemView *> *m = [NSMutableArray arrayWithCapacity:5];
    for ( int i = 0 ; i < 5 ; ++ i  ) {
        SJCustomPageMenuItemView *view = [SJCustomPageMenuItemView.alloc initWithFrame:CGRectZero];
        view.text = @[@"从前从前", @"有从前", @"99从前", @"座从前", @"灵剑山从前"][i];
        [m addObject:view];
    }
    _pageMenuBar.itemViews = m;
    
    
    _pageMenuBar.gestureHandler.singleTapHandler = ^(SJPageMenuBar * _Nonnull bar, CGPoint location) {
        [bar.itemViews enumerateObjectsUsingBlock:^(SJCustomPageMenuItemView *view, NSUInteger idx, BOOL * _Nonnull stop) {
            if ( CGRectContainsPoint(view.frame, location) ) {
                CGPoint point = [bar convertPoint:location toView:view];
                // 点击了删除按钮
                if ( [view deleteButtonFrameContainsPoint:point] ) {
                    [bar deleteItemAtIndex:idx animated:YES];
                }
    
                *stop = YES;
            }
        }];
    };
}
 

@end

#pragma mark -

@interface SJCustomPageMenuItemView ()
@property (nonatomic, strong, readonly) UILabel *label;
@property (nonatomic, strong, readonly) UIImageView *deleteImageView;
@end

@implementation SJCustomPageMenuItemView
@synthesize focusedMenuItem = _focusedMenuItem;
@synthesize transitionProgress = _transitionProgress;
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if ( self ) {
        self.backgroundColor = UIColor.lightGrayColor;
        
        _label = [UILabel.alloc initWithFrame:CGRectZero];
        _label.font = [UIFont systemFontOfSize:14];
        _label.textAlignment = NSTextAlignmentCenter;
        _label.textColor = UIColor.whiteColor;
        [self addSubview:_label];
        
        _deleteImageView = [UIImageView.alloc initWithImage:SJVideoPlayerSettings.commonSettings.floatSmallViewCloseImage];
        _deleteImageView.bounds = CGRectMake(0, 0, _deleteImageView.image.size.width, _deleteImageView.image.size.height);
        [self addSubview:_deleteImageView];
    }
    return self;
}

- (BOOL)deleteButtonFrameContainsPoint:(CGPoint)point {
    CGRect frame = _deleteImageView.frame;
    frame.origin.x -= 8;
    frame.origin.y -= 8;
    frame.size.width += 16;
    frame.size.height += 16;
    return CGRectContainsPoint(frame, point);
}

#pragma mark -

- (void)setFont:(nullable UIFont *)font {
    _label.font = font;
}

- (UIFont *)font {
    return _label.font;
}

- (void)setText:(nullable NSString *)text {
    _label.text = text;
}
- (nullable NSString *)text {
    return _label.text;
}

- (void)setAttributedText:(nullable NSAttributedString *)attributedText {
    _label.attributedText = attributedText;
}
- (nullable NSAttributedString *)attributedText {
    return _label.attributedText;
}

- (void)setTintColor:(nullable UIColor *)tintColor {
    [_label setTextColor:tintColor];
}
- (UIColor *)tintColor {
    return _label.textColor;
}

#pragma mark -

- (void)setBounds:(CGRect)bounds {
    [super setBounds:bounds];
    CGPoint center = CGPointMake(bounds.size.width * 0.5, bounds.size.height * 0.5);
    _label.center = center;
    _label.bounds = bounds;
    
    CGRect frame = _deleteImageView.bounds;
    frame.origin.x = bounds.size.width - frame.size.width;
    frame.origin.y = 0;
    _deleteImageView.frame = frame;
}

- (CGSize)sizeThatFits:(CGSize)size {
    return [_label sizeThatFits:size];
}

- (void)sizeToFit {
    CGSize size = [self sizeThatFits:CGSizeMake(CGFLOAT_MAX, CGFLOAT_MAX)];
    size.width += 44;
    size.height += 16;
    
    CGRect bounds = self.bounds;
    bounds.size = size;
    self.bounds = bounds;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.layer.cornerRadius = self.bounds.size.height * 0.5;
}
@end
