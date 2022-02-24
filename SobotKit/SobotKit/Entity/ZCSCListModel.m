//
//  ZCServiceCategoryListModel.m
//  SobotKit
//
//  Created by lizhihui on 2019/4/2.
//  Copyright © 2019 zhichi. All rights reserved.
//

#import "ZCSCListModel.h"
#import "SobotUtils.h"
@implementation ZCSCListModel
-(id)initWithMyDict:(NSDictionary *)dict{
    if (self = [super init]) {
        
        _categoryId = sobotConvertToString(dict[@"categoryId"]);
        
        _appId = sobotConvertToString(dict[@"appId"]);
        
        _categoryName = sobotConvertToString(dict[@"categoryName"]);
        
        _categoryDetail = sobotConvertToString(dict[@"categoryDetail"]);
        
        _categoryUrl = sobotConvertToString(dict[@"categoryUrl"]);
        
        _sortNo = [sobotConvertToString(dict[@"sortNo"]) intValue];
        
        
        
        _companyId = sobotConvertToString(dict[@"companyId"]);
        _docId = sobotConvertToString(dict[@"docId"]);
        _questionId = sobotConvertToString(dict[@"questionId"]);
        _questionTitle = sobotConvertToString(dict[@"questionTitle"]);

        
        
        _answerDesc = sobotConvertToString(dict[@"answerDesc"]);
        
    }
    return self;
}
@end
