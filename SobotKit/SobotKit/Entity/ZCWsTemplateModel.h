//
//  ZCWsTemplateModel.h
//  SobotKit
//
//  Created by lizhihui on 2019/3/4.
//  Copyright © 2019 zhichi. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface ZCWsTemplateModel : NSObject

@property (nonatomic,copy) NSString * templateName; // 留言模板name

@property (nonatomic,copy) NSString * templateId;// 模板id


-(id)initWithMyDict:(NSDictionary *)dict;


@end

NS_ASSUME_NONNULL_END
