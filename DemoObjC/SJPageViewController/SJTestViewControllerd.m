//
//  SJTestViewControllerd.m
//  SJPageViewController_Example
//
//  Created by BlueDancer on 2020/3/6.
//  Copyright © 2020 changsanjiang@gmail.com. All rights reserved.
//

#import "SJTestViewControllerd.h"

@interface SJTestViewControllerd ()
@property (weak, nonatomic) IBOutlet UILabel *label;

@end

@implementation SJTestViewControllerd

- (void)viewDidLoad {
    [super viewDidLoad];
    _label.textAlignment = NSTextAlignmentCenter;
    // Do any additional setup after loading the view.
}
- (IBAction)test:(id)sender {
    CGRect bounds = _label.bounds;
    bounds.size.width = 100;
    
    CGPoint center = _label.center;
    center.x = 100;
    
    [UIView animateWithDuration:5 animations:^{    
        self.label.bounds = bounds;
        self.label.center = center;
    }];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
