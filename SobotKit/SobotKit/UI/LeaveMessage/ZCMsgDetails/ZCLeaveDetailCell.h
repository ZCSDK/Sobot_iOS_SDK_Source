//
//  ZCLeaveDetailCell.h
//  SobotKit
//
//  Created by 张新耀 on 2019/9/30.
//  Copyright © 2019 zhichi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZCRecordListModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface ZCLeaveDetailCell : UITableViewCell

-(void)initWithData:(ZCRecordListModel *)model IndexPath:(NSUInteger)row count:(int) count btnClick:(void (^)(ZCRecordListModel *model ))btnClickBlock;

-(void)setShowDetailClickCallback:(void (^)(ZCRecordListModel *model ,NSString *urlStr))detailClickBlock;


@end

NS_ASSUME_NONNULL_END
