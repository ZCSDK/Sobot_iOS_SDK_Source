//
//  ZCServiceDetailVC.h
//  SobotKit
//
//  Created by lizhihui on 2019/4/2.
//  Copyright © 2019 zhichi. All rights reserved.
//

#import <SobotKit/SobotKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface ZCServiceDetailVC : ZCUIBaseController

@property (nonatomic,copy) NSString * docId;

@property (nonatomic,copy) NSString * appId;

@property (nonatomic,copy) NSString * questionTitle;

@property(nonatomic,strong) void (^OpenZCSDKTypeBlock)(ZCUIBaseController *object);

@property (nonatomic,strong) ZCKitInfo * kitInfo;

@end

NS_ASSUME_NONNULL_END
