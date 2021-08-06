//
//  ZCLibSkillSet.h
//  SobotLib
//
//  Created by zhangxy on 16/1/21.
//  Copyright © 2016年 zhichi. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ZCLibSkillSet : NSObject

@property (nonatomic,strong) NSString *groupId;
@property (nonatomic,strong) NSString *channelType;
@property (nonatomic,strong) NSString *groupName;
@property (nonatomic,strong) NSString *companyId;
@property (nonatomic,strong) NSString *recGroupName;

@property (nonatomic,assign) BOOL      isOnline;

// 无值 或 0 文本样式， 1 图文样式        2 图文+描述样式
@property (nonatomic,assign) int      groupStyle;
// 引导语
@property (nonatomic,strong) NSString *groupGuideDoc;
// 图片
@property (nonatomic,strong) NSString *groupPic;
// 描述
@property (nonatomic,strong) NSString *desc;



-(id)initWithMyDict:(NSDictionary *)dict;

@end
