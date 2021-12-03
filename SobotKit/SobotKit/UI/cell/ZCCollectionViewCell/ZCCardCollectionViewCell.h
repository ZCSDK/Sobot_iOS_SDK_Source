//
//  ZCCardCollectionViewCell.h
//  SobotKit
//
//  Created by xuhan on 2019/9/4.
//  Copyright © 2019 zhichi. All rights reserved.
//

#import <UIKit/UIKit.h>
//#import "ZCUIImageView.h"
#import "SobotImageView.h"

NS_ASSUME_NONNULL_BEGIN
FOUNDATION_EXPORT NSString *const kZCCardCollectionViewCellID;
typedef NS_ENUM(NSInteger,ZCMultitemHorizontaRollCellType){
    ZCMultitemHorizontaRollCellType_text     = 1,
    ZCMultitemHorizontaRollCellType_address  = 2,
    ZCMultitemHorizontaRollCellType_card  = 3,
    
    
};
@interface ZCCardCollectionViewCell : UICollectionViewCell

@property (nonatomic,strong)  NSIndexPath *indexPath;

@property (strong, nonatomic) UIView *bgView; //背景
@property (strong, nonatomic) SobotImageView *posterView;// 图片
@property (strong, nonatomic) UILabel *labTitle; //标题
@property (strong, nonatomic) UILabel *labDesc; // 要素内容
@property (strong, nonatomic) UILabel *labTag; // 标签 （eg 电影评分）
@property (strong, nonatomic) UILabel *labLabel; // 


- (void)configureCellWithPostURL:(NSDictionary *)model WithIsHistory:(BOOL) isHistory withType:(ZCMultitemHorizontaRollCellType )cellType linkStyle:(BOOL) showLinkStyle;

@end

NS_ASSUME_NONNULL_END
