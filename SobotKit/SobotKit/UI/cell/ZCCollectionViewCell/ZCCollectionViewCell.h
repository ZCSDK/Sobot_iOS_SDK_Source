//
//  ZCCollectionViewCell.h
//  SobotKit
//
//  Created by lizhihui on 2017/11/13.
//  Copyright © 2017年 zhichi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZCMultiwheelModel.h"
#import "ZCUIImageView.h"

//  用于垂直布局和水平布局时设置 item之间的边缘距离
typedef NS_ENUM(NSInteger,CollectionCellType){
    CollectionCellType_Horizontal     = 1,
    CollectionCellType_Vertical       = 2,
};

FOUNDATION_EXPORT NSString *const kZCCollectionViewCellID;

@interface ZCCollectionViewCell : UICollectionViewCell

@property (strong, nonatomic) ZCUIImageView *posterView;// 图片
@property (strong, nonatomic) UILabel *labTitle; //标题
@property (strong, nonatomic) UILabel *labDesc; // 要素内容
@property (strong, nonatomic) UILabel *labTag; // 标签 （eg 电影评分）

@property (assign, nonatomic) CollectionCellType  collectionCellType;

@property (strong, nonatomic) UIView * bottomLineView;// 底部线条

- (void)configureCellWithPostURL:(NSDictionary *)model WithIsHistory:(BOOL) isHistory;

@end
