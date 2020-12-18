//
//  ZCProgressView.m
//  SobotKit
//
//  Created by zhangxy on 2018/11/12.
//  Copyright © 2018年 zhichi. All rights reserved.
//

#import "ZCProgressView.h"

@interface ZCProgressView(){
    
    CGFloat beginAngle;
    CGFloat finishAngle;
}

@end

@implementation ZCProgressView

- (instancetype)init
{
    self = [super init];
    if (self) {
        // 顶部，右转，1.5pi，0pi，0.5pi,1pi,1.5pi
        // 顶部为 -0.5pi
        beginAngle =  0 - M_PI * 0.5;// 起点
        finishAngle = M_PI * 1.5;
    }
    return self;
}

-(void)setProgress:(CGFloat)progress{
    _progress = progress;
    finishAngle = M_PI * 1.5;
    beginAngle = M_PI*2 * _progress - M_PI * 0.5;
    [self setNeedsDisplay];
}


- (void)drawRect:(CGRect)rect{
    if(_faceImage){
        [_faceImage drawInRect:rect];
    }
    
    [UIColor.grayColor set];// 设置线条颜色
    
    CGPoint centerPoint = CGPointMake(rect.size.width/2, rect.size.height/2);
    CGFloat r = MAX(centerPoint.x,centerPoint.y);
    
    UIBezierPath *aPath = [UIBezierPath bezierPathWithArcCenter:centerPoint  radius:r*2 startAngle:beginAngle endAngle:finishAngle clockwise:true];
    [aPath addLineToPoint:centerPoint];
    [aPath closePath];
    aPath.lineWidth = 5.0; // 线条宽度
    //        aPath.fill() // Draws line 根据坐标点连线，填充
    [aPath fillWithBlendMode:kCGBlendModeNormal alpha:0.5];
    
    beginAngle += M_PI/20; // 更新终点
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
