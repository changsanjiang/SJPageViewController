//
//  SJPageMenuItemView.m
//  SJPageViewController_Example
//
//  Created by BlueDancer on 2020/2/11.
//  Copyright © 2020 changsanjiang@gmail.com. All rights reserved.
//

#import "SJPageMenuItemView.h"

NS_ASSUME_NONNULL_BEGIN
@interface SJPageMenuItemView ()

@end

@implementation SJPageMenuItemView
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if ( self ) {
        self.tintColor = UIColor.whiteColor;
        self.font = [UIFont boldSystemFontOfSize:20];
        self.textAlignment = NSTextAlignmentCenter;
    }
    return self;
}

#pragma mark -

- (void)setTintColor:(nullable UIColor *)tintColor {
    [self setTextColor:tintColor];
}

- (UIColor *)tintColor {
    return self.textColor;
}
@end
NS_ASSUME_NONNULL_END
