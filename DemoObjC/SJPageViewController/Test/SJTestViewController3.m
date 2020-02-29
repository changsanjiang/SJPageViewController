//
//  SJTestViewController3.m
//  SJPageViewController_Example
//
//  Created by BlueDancer on 2020/2/29.
//  Copyright © 2020 changsanjiang@gmail.com. All rights reserved.
//

#import "SJTestViewController3.h"
#import "SJTestViewController1.h"
#import <Masonry.h>

@interface SJTestViewController3 ()<UICollectionViewDataSource, UICollectionViewDelegate>
@property (nonatomic, strong, nullable) UICollectionView *collectionView;
@end

@implementation SJTestViewController3

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view addSubview:self.collectionView];
    [_collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.offset(0);
    }];
    // Do any additional setup after loading the view.
}

- (UICollectionView *)collectionView {
    if ( _collectionView == nil ) {
        UICollectionViewFlowLayout *layout = UICollectionViewFlowLayout.new;
        layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        layout.minimumLineSpacing = 0;
        layout.minimumInteritemSpacing = 0;
        layout.itemSize = UIScreen.mainScreen.bounds.size;
        _collectionView = [UICollectionView.alloc initWithFrame:CGRectZero collectionViewLayout:layout];
        _collectionView.backgroundColor = UIColor.clearColor;
        _collectionView.pagingEnabled = YES;
        _collectionView.showsVerticalScrollIndicator = NO;
        _collectionView.showsHorizontalScrollIndicator = NO;
        if (@available(iOS 11.0, *)) {
            _collectionView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        }
        [_collectionView registerClass:UICollectionViewCell.class forCellWithReuseIdentifier:@"1"];
        _collectionView.dataSource = self;
        _collectionView.delegate = self;
    }
    return _collectionView;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return 99;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    return [collectionView dequeueReusableCellWithReuseIdentifier:@"1" forIndexPath:indexPath];
}

- (void)collectionView:(UICollectionView *)collectionView willDisplayCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath {
    SJTestViewController1 *vc = [SJTestViewController1 new];
    vc.view.frame = cell.bounds;
    [self addChildViewController:vc];
    [cell.contentView addSubview:vc.view];
}
@end
