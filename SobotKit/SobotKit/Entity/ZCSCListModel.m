//
//  ZCServiceCategoryListModel.m
//  SobotKit
//
//  Created by lizhihui on 2019/4/2.
//  Copyright © 2019 zhichi. All rights reserved.
//

#import "ZCSCListModel.h"
#import "ZCLibCommon.h"
@implementation ZCSCListModel
-(id)initWithMyDict:(NSDictionary *)dict{
    if (self = [super init]) {
        
        _categoryId = zcLibConvertToString(dict[@"categoryId"]);
        
        _appId = zcLibConvertToString(dict[@"appId"]);
        
        _categoryName = zcLibConvertToString(dict[@"categoryName"]);
        
        _categoryDetail = zcLibConvertToString(dict[@"categoryDetail"]);
        
        _categoryUrl = zcLibConvertToString(dict[@"categoryUrl"]);
        
        _sortNo = [zcLibConvertToString(dict[@"sortNo"]) intValue];
        
        
        
        _companyId = zcLibConvertToString(dict[@"companyId"]);
        _docId = zcLibConvertToString(dict[@"docId"]);
        _questionId = zcLibConvertToString(dict[@"questionId"]);
        _questionTitle = zcLibConvertToString(dict[@"questionTitle"]);

        
        
        _answerDesc = zcLibConvertToString(dict[@"answerDesc"]);
        
    }
    return self;
}
@end
