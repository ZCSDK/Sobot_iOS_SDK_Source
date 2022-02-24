//
//  ZCWsTemplateModel.m
//  SobotKit
//
//  Created by lizhihui on 2019/3/4.
//  Copyright © 2019 zhichi. All rights reserved.
//

#import "ZCWsTemplateModel.h"
#import "SobotUtils.h"
@implementation ZCWsTemplateModel

-(id)initWithMyDict:(NSDictionary *)dict{
    self=[super init];
    if(self){
        @try {
            
            _templateId = sobotConvertToString(dict[@"templateId"]);
            _templateName = sobotConvertToString(dict[@"templateName"]);
            
        }
        @catch (NSException *exception) {
            
        }
        @finally {
            
        }
    }
    return self;
}


@end
