//
//  ZCMsgRecordCell.h
//  SobotKit
//
//  Created by lizhihui on 2019/2/19.
//  Copyright © 2019 zhichi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZCRecordListModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface ZCMsgRecordCell : UITableViewCell


-(void)initWithDict:(ZCRecordListModel*)model with:(CGFloat) width;

@end

NS_ASSUME_NONNULL_END
