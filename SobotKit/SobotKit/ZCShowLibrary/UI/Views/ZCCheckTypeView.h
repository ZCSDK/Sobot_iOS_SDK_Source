//
//  ZCCheckTypeView.h
//  SobotKit
//
//  Created by 张新耀 on 2019/9/4.
//  Copyright © 2019 zhichi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZCLibTicketTypeModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface ZCCheckTypeView : UIView
@property(nonatomic,strong)NSMutableArray   *listArray;

@property(nonatomic,weak) NSString *pageTitle;

@property(nonatomic,weak) UIView *parentView;

@property(nonatomic,strong) NSString *typeId;

@property (nonatomic, strong)  void(^orderTypeCheckBlock) (ZCLibTicketTypeModel *model);

@property (nonatomic, strong)  void(^ChangePageBlock) (int type,CGFloat height);


@end

NS_ASSUME_NONNULL_END
