//
//  ZCGuideData.h
//  SobotKitFrameworkTest
//
//  Created by zhangxy on 2020/7/16.
//  Copyright © 2020 zhichi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <SobotKit/SobotKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger,ZCConfigFrom) {
    ZCConfigFromClient = 0,
    ZCConfigFromLibInit,
    ZCConfigFromKit,
    ZCConfigFromFunction,
};

typedef NS_ENUM(NSInteger,ZCSectionIndex) {
    ZCSectionIndex31 = 0,
    ZCSectionIndex331,
    ZCSectionIndex332,
    ZCSectionIndex341,
    ZCSectionIndex342,
    ZCSectionIndex343,
    ZCSectionIndex351,
    ZCSectionIndex353,
    ZCSectionIndex36,
    ZCSectionIndex41,
    ZCSectionIndex42,
    ZCSectionIndex43,
    ZCSectionIndex44,
    ZCSectionIndex45,
    ZCSectionIndex451,
    ZCSectionIndex46,
    ZCSectionIndex47,
    ZCSectionIndex51,
    ZCSectionIndex52
};

typedef NS_ENUM(NSInteger,ZCConfigIndex) {
    ZCConfigIndex31 = 0,
    ZCConfigIndex32,
    ZCConfigIndex321,
    ZCConfigIndex322,
    ZCConfigIndex411,
    ZCConfigIndex412,
    ZCConfigIndex413,
    ZCConfigIndex414,
    ZCConfigIndex42,
    ZCConfigIndex43,
    ZCConfigIndex44,
    ZCConfigIndex45,
    ZCConfigIndex451,
};




@interface ZCGuideData : NSObject

// 设置数据
@property(nonatomic,strong)ZCLibInitInfo *libInitInfo;
@property(nonatomic,strong)ZCKitInfo *kitInfo;
@property(nonatomic,strong)NSString *apiHost;

+(ZCGuideData *)getZCGuideData;

-(NSArray *)getSectionArray;
-(NSArray *)getSectionListArray:(NSInteger )section;

-(NSArray *)getConfigItems:(NSString *) code;

-(NSArray *) getCodeStype:(NSString *)code;


-(void)showAlertTips:(NSString *)message vc:(UIViewController *) vc;
-(void)showAlertTips:(NSString *)message vc:(UIViewController *) vc blcok:(void (^)(int code)) alerClick;

@end

NS_ASSUME_NONNULL_END
