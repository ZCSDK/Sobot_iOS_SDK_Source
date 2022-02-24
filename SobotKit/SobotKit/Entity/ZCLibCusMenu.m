//
//  ZCLibCusMenu.m
//  SobotKit
//
//  Created by lizhihui on 2018/5/25.
//  Copyright © 2018年 zhichi. All rights reserved.
//

#import "ZCLibCusMenu.h"
#import "SobotUtils.h"
@implementation ZCLibCusMenu

-(id)initWithMyDict:(NSDictionary *)dict{
    self=[super init];
    if(self){
        @try {
            _title      = sobotConvertToString(dict[@"lableName"]);
            _url  = sobotConvertToString(dict[@"lableLink"]);
            _lableId = [sobotConvertToString(dict[@"lableId"]) integerValue];
            _imgName = sobotConvertToString(dict[@"imgName"]);
            _imgNamePress = sobotConvertToString(dict[@"imgNamePress"]);
        }
        @catch (NSException *exception) {
            
        }
        @finally {
            
        }
    }
    return self;
}

@end
