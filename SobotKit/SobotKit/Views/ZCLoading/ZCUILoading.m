//
//  ZCUILoading.m
//  SobotKit
//
//  Created by lizhihui on 15/11/11.
//  Copyright © 2015年 zhichi. All rights reserved.
//

#import "ZCUILoading.h"
//#import "ZCUIWavesView.h"
#import "ZCLibGlobalDefine.h"
#import "ZCUIColorsDefine.h"
@interface ZCUILoading()
{
    UIActivityIndicatorView *activityView;
}
@property(strong,nonatomic) void(^refreshBlock)(UIButton *v);
@end


@implementation ZCUILoading
static  ZCUILoading *_zcuiLoading = nil;
// 单例
+ (ZCUILoading*)shareZCUILoading{
    static  dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if(_zcuiLoading==nil){
            _zcuiLoading = [[self alloc] init];
        }
    });
    return _zcuiLoading;
}



#pragma mark -- show
- (void)showAddToSuperView:(UIView*)SuperView style:(BOOL) isLargeWhite{
    if(_zcuiLoading){
        for (UIView *v in _zcuiLoading.subviews) {
            [v removeFromSuperview];
        }
    }
    
    _zcuiLoading.frame = CGRectMake(0, 0, SuperView.frame.size.width,SuperView.frame.size.height);
    [_zcuiLoading setBackgroundColor:[UIColor clearColor]];
    [_zcuiLoading setAutoresizesSubviews:YES];
    [_zcuiLoading setAutoresizingMask:UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight];
    if(isLargeWhite){
        activityView=[[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    }else{
        activityView=[[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    }
    
    [activityView setFrame:CGRectMake(0, 0, 40, 40)];
    [activityView setBackgroundColor:[UIColor clearColor]];
    [activityView setAutoresizingMask:UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleBottomMargin|UIViewAutoresizingFlexibleTopMargin];
    [activityView startAnimating];
    [_zcuiLoading addSubview:activityView];
    [activityView setCenter:CGPointMake(_zcuiLoading.bounds.size.width/2, _zcuiLoading.bounds.size.height/2)];
    
    // 将ZCUILoading添加到传进来的父视图SuperView
    [SuperView addSubview:self];
    
}

#pragma mark -- dismiss

// 消失
- (void)dismiss{
    if(activityView){
        [activityView stopAnimating];
        [activityView removeFromSuperview];
    }
    for (UIView *v in _zcuiLoading.subviews) {
        [v removeFromSuperview];
    }
    // 移除所有子视图
    [self removeFromSuperview];
}



#pragma mark -- 加载失败的占位页面
- (void)createPlaceholderView:(NSString *)title image:(UIImage *)image withView:(UIView *)SuperView action:(void (^)(UIButton *button)) clickblock{
    if(_zcuiLoading){
        for (UIView *v in _zcuiLoading.subviews) {
            [v removeFromSuperview];
        }
    }
    
    _zcuiLoading.frame = CGRectMake(0, 0, SuperView.frame.size.width,SuperView.frame.size.height);
    [_zcuiLoading setBackgroundColor:[ZCUITools zcgetBackgroundColor]];
    [_zcuiLoading setAutoresizesSubviews:YES];
    [_zcuiLoading setAutoresizingMask:UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight];
    
    
    UIImageView *icon = [[UIImageView alloc]initWithImage:[ZCUITools zcuiGetBundleImage:@"zcicon_networkfail"]];
    if(image){
        [icon setImage:image];
    }
    [icon setContentMode:UIViewContentModeCenter];
    [icon setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
    icon.frame = CGRectMake(self.frame.size.width/2 - 55/2, CGRectGetMaxY(SuperView.bounds)/2-200, 55, 76);
    [self addSubview:icon];
    
    CGFloat y= CGRectGetMaxY(icon.frame) + 10;


    if(title){
        UILabel *lblTitle=[[UILabel alloc] initWithFrame:CGRectMake(0, y, self.frame.size.width, 44)];
        [lblTitle setText:title];
        [lblTitle setFont:ZCUIFont14];
        [lblTitle setTextAlignment:NSTextAlignmentCenter];
        [lblTitle setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
        [lblTitle setAutoresizesSubviews:YES];
        lblTitle.textColor = UIColorFromThemeColor(ZCTextSubColor);
        [lblTitle setBackgroundColor:[UIColor clearColor]];
        lblTitle.userInteractionEnabled = YES;
        [self addSubview:lblTitle];
        y = y+25;
        
        if(clickblock){
            _refreshBlock = clickblock;
            UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
            [btn setTitle:ZCSTLocalString(@"重新加载") forState:0];
            [btn setTitleColor:UIColorFromThemeColor(ZCTextLinkBlueColor) forState:0];
            [btn setFrame:CGRectMake(0, y, self.frame.size.width, 44)];
            [btn.titleLabel setFont:ZCUIFont16];
            [btn setContentHorizontalAlignment:UIControlContentHorizontalAlignmentCenter];
            [btn addTarget:self action:@selector(refresh:) forControlEvents:UIControlEventTouchUpInside];
            [self addSubview:btn];
            
        }
//        UITapGestureRecognizer *gestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(refresh)];
//        gestureRecognizer.numberOfTapsRequired = 1;
//        gestureRecognizer.cancelsTouchesInView = NO;
//        [lblTitle addGestureRecognizer:gestureRecognizer];
    }
    
}


-(void)refresh:(UIButton *) btn{
//    NSLog(@"点击了");
    if(_refreshBlock){
        _refreshBlock(btn);
    }
}

@end
