//
//  ZCServiceListCell.h
//  SobotKit
//
//  Created by lizhihui on 2019/3/28.
//  Copyright © 2019 zhichi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZCSCListModel.h"
NS_ASSUME_NONNULL_BEGIN

@interface ZCServiceListCell : UITableViewCell

-(void)initWithModel:(ZCSCListModel *)model width:(CGFloat) tableWidth;

@end

NS_ASSUME_NONNULL_END
