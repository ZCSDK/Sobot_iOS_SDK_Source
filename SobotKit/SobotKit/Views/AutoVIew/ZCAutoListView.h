//
//  ZCAutoListView.h
//  SobotKit
//
//  Created by zhangxy on 2018/1/22.
//  Copyright © 2018年 zhichi. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ZCAutoListViewDelegate <NSObject>

@optional
-(void)autoViewCellItemClick:(NSString *)resultString;

@end

@interface ZCAutoListView : UIView

//控制网络回调延迟后的显示时机
@property (nonatomic,assign)BOOL isAllowShow;

+(ZCAutoListView *) getAutoListView;

@property(nonatomic,strong) UIView *bottomView;

@property(nonatomic,weak) id<ZCAutoListViewDelegate> delegate;

-(void)showWithText:(NSString *) searchText view:(UIView *) bottomView;

-(void)dissmiss;

@end
