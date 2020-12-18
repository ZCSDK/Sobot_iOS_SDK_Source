//
//  ZCPageSheetView.h
//  SobotKit
//
//  Created by 张新耀 on 2019/9/4.
//  Copyright © 2019 zhichi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZCToolsCore.h"

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger,ZCPageSheetType) {
    ZCPageSheetTypeDefault = 0,
    ZCPageSheetTypeShort   = 1,
    ZCPageSheetTypeLong    = 2
};

@interface ZCPageSheetView : UIView

-(instancetype)initWithTitle:(NSString *) title  superView:(UIView *) view showView:(UIView *) contentView type:(ZCPageSheetType) type;


-(void)showSheet:(CGFloat) height animation:(BOOL) animation block:(void(^)())ShowBlock;

-(void)dissmisPageSheet;

@end

NS_ASSUME_NONNULL_END
