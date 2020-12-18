//
//  ZCQuickEntryView.h
//  SobotKit
//
//  Created by lizhihui on 2018/5/25.
//  Copyright © 2018年 zhichi. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "ZCLibCusMenu.h"
typedef void(^ZCQuickEntryClickBlock)(ZCLibCusMenu * itemModel);
@interface ZCQuickEntryView : UIView

-(ZCQuickEntryView *)initCustomViewWith:(NSMutableArray *)array WithView:(UIView *)view;

- (void)showInView:(UIView *)view;

- (void)tappedCancel:(BOOL) isClose;

@property (nonatomic,copy) ZCQuickEntryClickBlock quickClickBlock;

@end
