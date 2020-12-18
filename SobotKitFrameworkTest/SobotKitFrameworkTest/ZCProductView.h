//
//  ZCProductView.h
//  SobotKitFrameworkTest
//
//  Created by lizhihui on 2017/12/8.
//  Copyright © 2017年 zhichi. All rights reserved.
//

#import <UIKit/UIKit.h>


@protocol ZCProductViewDelegate <NSObject>;

-(void)buttonClickPassWord:(int)tag;

@end




@interface ZCProductView : UIView

@property (nonatomic,strong) UIImageView * imgView;

@property (nonatomic,strong) UILabel * titleLab;

@property (nonatomic,strong) UILabel * detailLab;

@property (nonatomic,strong) UIView * bottomView;

@property (nonatomic,strong) UIButton * btn;

@property (nonatomic,assign) id<ZCProductViewDelegate>delegate;

-(instancetype)initWithFrame:(CGRect)frame WithDict:(NSDictionary *)dict WithSuperView:(UIView*)superView;


@end
