//
//  ZCCardCollectionViewFlowLayout.h
//  SobotKit
//
//  Created by xuhan on 2019/9/5.
//  Copyright © 2019 zhichi. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
@protocol ZCCardCollectionViewFlowLayoutDelegate <UICollectionViewDelegateFlowLayout>

- (void)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout cellCenteredAtIndexPath:(NSIndexPath *)indexPath page:(int)page;

@end
@interface ZCCardCollectionViewFlowLayout : UICollectionViewFlowLayout
@property (nonatomic, weak) id<ZCCardCollectionViewFlowLayoutDelegate> delegate;
@end

NS_ASSUME_NONNULL_END
