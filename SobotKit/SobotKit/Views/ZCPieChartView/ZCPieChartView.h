//
//  HKPieChartView.h
//  PieChart
//
//  Created by hukaiyin on 16/6/20.
//  Copyright © 2016年 HKY. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ZCPieChartView : UIView

@property (nonatomic, assign) CGFloat lineWidth;
@property (nonatomic, assign) UIColor *trackColor;
@property (nonatomic, assign) UIColor *progressColor;

- (void)updatePercent:(CGFloat)percent animation:(BOOL)animationed;

- (void)invalidateTimer;
@end
