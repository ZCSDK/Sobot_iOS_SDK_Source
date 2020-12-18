//
//  ZCOrderGoodsModel.m
//  SobotKit
//
//  Created by 张新耀 on 2019/9/29.
//  Copyright © 2019 zhichi. All rights reserved.
//

#import "ZCOrderGoodsModel.h"
#import "ZCLibGlobalDefine.h"

@implementation ZCOrderGoodsModel

+(NSString *)getOrderStatusMsg:(int)status{
    NSString *str = ZCSTLocalString(@"其它");
    switch (status) {
        case 1:
        str = ZCSTLocalString(@"待付款");
        break;
      case 2:
        str = ZCSTLocalString(@"待发货");
        break;
        case 3:
        str = ZCSTLocalString(@"运输中");
        break;
        case 4:
        str = ZCSTLocalString(@"派送中");
        break;
        case 5:
        str = ZCSTLocalString(@"已完成");
        break;
        case 6:
        str = ZCSTLocalString(@"待评价");
            break;
        case 7:
        str = ZCSTLocalString(@"已取消");
            break;
        default:
            break;
    }
    return str;
}

@end
