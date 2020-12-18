//
//  ZCWsTemplateModel.m
//  SobotKit
//
//  Created by lizhihui on 2019/3/4.
//  Copyright © 2019 zhichi. All rights reserved.
//

#import "ZCWsTemplateModel.h"
#import "ZCLibCommon.h"
@implementation ZCWsTemplateModel

-(id)initWithMyDict:(NSDictionary *)dict{
    self=[super init];
    if(self){
        @try {
            
            _templateId = zcLibConvertToString(dict[@"templateId"]);
            _templateName = zcLibConvertToString(dict[@"templateName"]);
            
        }
        @catch (NSException *exception) {
            
        }
        @finally {
            
        }
    }
    return self;
}


@end
