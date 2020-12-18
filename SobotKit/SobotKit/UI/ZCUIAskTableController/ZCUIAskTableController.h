//
//  ZCUIAskTableController.h
//  SobotKit
//
//  Created by lizhihui on 2018/1/2.
//  Copyright © 2018年 zhichi. All rights reserved.
//

#import <SobotKit/SobotKit.h>

typedef void(^TrunServerBlock)(BOOL isback);


/**
 *
 *  询前表单页面
 *
 **/
@interface ZCUIAskTableController : ZCUIBaseController

@property (nonatomic,assign) BOOL             isNavOpen;
@property (nonatomic,copy) TrunServerBlock   trunServerBlock;

@property (nonatomic,strong) NSMutableDictionary * dict;

@property (nonatomic,assign) BOOL isclearskillId;// 点击返回清理掉 记录的技能组ID

@end
