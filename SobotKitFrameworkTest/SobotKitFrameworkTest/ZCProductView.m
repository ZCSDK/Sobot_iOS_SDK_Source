//
//  ZCProductView.m
//  SobotKitFrameworkTest
//
//  Created by lizhihui on 2017/12/8.
//  Copyright © 2017年 zhichi. All rights reserved.
//

#import "ZCProductView.h"

#import "EntityConvertUtils.h"

@implementation ZCProductView

-(instancetype)initWithFrame:(CGRect)frame WithDict:(NSDictionary *)dict WithSuperView:(UIView*)superView{
    
    if (self = [super initWithFrame:frame]) {
        UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(buttonClick:)];
        [self addGestureRecognizer:tap];
        self.frame = frame;
        self.backgroundColor = [UIColor whiteColor];
        self.imgView = [[UIImageView alloc]initWithFrame:CGRectMake(ZCNumber(20), ZCNumber(20), ZCNumber(100), ZCNumber(100))];
        self.imgView.backgroundColor = [UIColor clearColor];
        self.imgView.image = [UIImage imageNamed:dict[@"Img"]];
        self.imgView.contentMode = UIViewContentModeScaleAspectFit;
        self.imgView.tag = [dict[@"tag"] intValue];
        self.imgView.userInteractionEnabled = YES;
        [self addSubview: self.imgView];
        
        
        self.titleLab = [[UILabel alloc]initWithFrame:CGRectMake(CGRectGetMaxX(self.imgView.frame) + ZCNumber(20), ZCNumber(37), 120, 20)];
        self.titleLab.font = [UIFont fontWithName:@"Arial Rounded MT Bold" size:14];
        self.titleLab.textColor = [UIColor blackColor];
        self.titleLab.text = dict[@"title"];
        self.titleLab.tag = [dict[@"tag"] intValue];
        self.titleLab.userInteractionEnabled = YES;
        [self addSubview:self.titleLab];
        
        self.detailLab = [[UILabel alloc]initWithFrame:CGRectMake(CGRectGetMaxX(self.imgView.frame) + ZCNumber(20), CGRectGetMaxY(self.titleLab.frame) + ZCNumber(9), ZCNumber(CGRectGetWidth(self.frame) - 160), 40)];
        
        self.detailLab.textAlignment = NSTextAlignmentLeft;
        self.detailLab.font = [UIFont systemFontOfSize:14];
        self.detailLab.textColor = UIColorFromRGB(0x8B98AD);
        self.detailLab.text = dict[@"detail"];
        self.detailLab.tag = [dict[@"tag"] intValue];
        self.detailLab.numberOfLines = 2;
        self.detailLab.userInteractionEnabled = YES;
        [self addSubview:self.detailLab];
        
        // 设置背景的渐变
        self.layer.shadowColor = UIColorFromRGB(0xEFF3FA).CGColor;
        self.layer.shadowOpacity = 0.4;
        self.layer.shadowRadius = 0.5f;
        self.layer.shadowOffset = CGSizeMake(0.0f, 0.5f);
        self.tag = [dict[@"tag"] intValue];
        
        // 添加点击事件
        self.userInteractionEnabled = YES;
        
        [self.imgView addGestureRecognizer:tap];
        [self.titleLab addGestureRecognizer:tap];
        [self.detailLab addGestureRecognizer:tap];
        [self addGestureRecognizer:tap];
        
        [superView addSubview:self];
        
    }
    return self;
    
}

-(void)buttonClick:(UITapGestureRecognizer *)sender{
    NSInteger tag = sender.view.tag;
    if (self.delegate && [self.delegate respondsToSelector:@selector(buttonClickPassWord:)]) {
        [self.delegate buttonClickPassWord:(int)tag];
    }
}

@end
