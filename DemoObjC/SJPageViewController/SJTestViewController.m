//
//  SJTestViewController.m
//  SJPageViewController_Example
//
//  Created by BlueDancer on 2020/2/11.
//  Copyright © 2020 changsanjiang@gmail.com. All rights reserved.
//

#import "SJTestViewController.h"

@interface SJTestViewController ()
@property (weak, nonatomic) IBOutlet UILabel *label;

@property (weak, nonatomic) IBOutlet UILabel *label2;
@end

@implementation SJTestViewController

- (void)viewDidLoad {
    [super viewDidLoad]; 
    
    // Do any additional setup after loading the view.
}
- (IBAction)change:(UISlider *)sender {
    _label.font = [UIFont systemFontOfSize:(30 - 18) * sender.value + 18];
}
- (IBAction)clicked:(id)sender {
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
