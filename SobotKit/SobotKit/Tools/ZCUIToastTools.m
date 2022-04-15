//
//  ZCUIToastTools.m
//  SobotKitLit
//
//  Created by zhangxy on 15/11/18.
//  Copyright © 2015年 zhichi. All rights reserved.
//

#import "ZCUIToastTools.h"
#import "ZCLibGlobalDefine.h"
#import "ZCUIColorsDefine.h"

@interface ZCUIToastTools(){
    
}

@end

@implementation ZCUIToastTools{
    UIView  *_toastView;
    UILabel *_textLabel;
    UIImageView *_imageView;
    UIActivityIndicatorView  *activityView;
}

static ZCUIToastTools *_instance=nil;
+(id)shareToast{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if(_instance==nil){
            _instance=[[ZCUIToastTools alloc] init];
   
        }
    });
    return _instance;
}

-(id)init{
    self=[super init];
    if(self){
        _toastView=[[UIView alloc] init];
        [_toastView setBackgroundColor:[UIColorFromRGB(ZCToastBgColor) colorWithAlphaComponent:0.9]];
        _toastView.layer.cornerRadius = 6;
        _toastView.layer.masksToBounds=YES;
//        [_toastView setBackgroundColor:[UIColor blackColor] colorWithAlphaComponent:0.5]];
        _textLabel=[[UILabel alloc] init];
        [_textLabel setFont:ZCUIFont14];
        [_textLabel setTextColor:[UIColor whiteColor]];
        _textLabel.numberOfLines=0;
        _textLabel.backgroundColor = [UIColor clearColor];
        [_toastView addSubview:_textLabel];
        
        
        
    }
    return self;
}


-(void)showToast:(NSString *) text duration:(CGFloat) duration view:(UIView *) byView position:(ZCToastPosition)position{
    [self dismisProgress];
    if(sobotConvertToString(text).length == 0){
        return;
    }
    [byView addSubview:_toastView];
    _toastView.layer.cornerRadius = 6.0f;
    _toastView.layer.masksToBounds = NO;
    
    [_textLabel setText:text];
    [_textLabel setFrame:CGRectMake(0, 0, byView.frame.size.width-60, 0)];
    [_textLabel sizeToFit];
    _textLabel.textAlignment = NSTextAlignmentCenter;
    CGRect f = _textLabel.frame;
    CGFloat w = f.size.width+20;
    if(w<100){
        w=100;
        f.size.width = w;
    }
    CGRect vf = CGRectMake(0, 0, f.size.width+30, f.size.height+30);
    [_toastView setFrame:vf];
    
    f.origin.x= 15;
    f.origin.y=f.origin.y+15;
    [_textLabel setFrame:f];
    
    if(position==ZCToastPositionTop){
        _toastView.center=CGPointMake(byView.center.x, 60);
    }else if(position==ZCToastPositionCenter){
        // 2.8.0  UI觉得中间的有点偏高 ，往下调点
        CGPoint p = byView.center;
        p.y = CGRectGetMaxY(byView.frame)/2 - NavBarHeight + 30;
        _toastView.center=p;
    }else{
        _toastView.center=CGPointMake(byView.center.x, byView.frame.size.height-XBottomBarHeight - _toastView.frame.size.height - 20);
    }
    if(duration>0){
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(duration * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [_toastView removeFromSuperview];
        });
    }
    
}


-(void)showToast:(NSString *) text duration:(CGFloat) duration view:(UIView *) byView position:(ZCToastPosition) position Image:(UIImage*)image{
    [self dismisProgress];
    
    [byView addSubview:_toastView];
    _toastView.layer.cornerRadius = 6.0f;
    _toastView.layer.masksToBounds = YES;
    
    _toastView.frame = CGRectMake((byView.frame.size.width - 140)/2, 0, 140, 135);

    
    _imageView = [[UIImageView alloc]init];
    _imageView.image = image;
    _imageView.frame = CGRectMake((_toastView.frame.size.width - 40)/2, 30, 40, 30);
    [_toastView addSubview:_imageView];
    
    [_textLabel setText:text];
    [_textLabel setFrame:CGRectMake(0, 90, byView.frame.size.width, 20)];
    _textLabel.font = ZCUIFont14;
    _textLabel.textAlignment = NSTextAlignmentCenter;
    

    [_textLabel sizeToFit];
    CGRect f = _textLabel.frame;
    CGFloat w = f.size.width+20;
    if(w<=140){
        w=140;
    }
    CGRect vf = CGRectMake(0, 0, w, f.size.height+94+25);
    _toastView.frame = vf;
    _imageView.frame = CGRectMake((_toastView.frame.size.width - 40)/2, 30, 40, 30);
    f.size.width = w;
    f.origin.y=f.origin.y+ 12;
    [_textLabel setFrame:f];
    
    
    if(position==ZCToastPositionTop){
        _toastView.center=CGPointMake(byView.center.x, 60);
    }else if(position==ZCToastPositionCenter){
        CGPoint p = byView.center;
        p.y = CGRectGetMaxY(byView.frame)/2 - NavBarHeight;
        _toastView.center=p;
    }else{
        _toastView.center=CGPointMake(byView.center.x, byView.frame.size.height-60);
    }
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(duration * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [_toastView removeFromSuperview];
    });

}


-(void)showProgress:(NSString *) status with:(UIView *) byView{
    [self dismisProgress];
    
    [byView addSubview:_toastView];
    _toastView.layer.cornerRadius = 6.0f;
    _toastView.layer.masksToBounds = YES;
    
    CGFloat w = 130;
    CGFloat h = 70;
    if(![@"" isEqual:sobotConvertToString(status)]){
        [_textLabel setText:status];
        [_textLabel setTextAlignment:NSTextAlignmentCenter];
        [_textLabel setFrame:CGRectMake(0, h-10, w, 0)];
        [_textLabel sizeToFit];
        CGRect f = _textLabel.frame;
        f.size.width = w;
        [_textLabel setFrame:f];
        h = f.size.height + h + 10;
        
    }
    
    
    activityView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    activityView.center = CGPointMake(w/2, 35);
    [_toastView addSubview:activityView];
    [activityView startAnimating];
    
    
    CGRect vf = CGRectMake(0, 0, w,h);
    
    [_toastView setFrame:vf];

    CGPoint p = byView.center;
    p.y = CGRectGetMaxY(byView.frame)/2 - NavBarHeight;
    _toastView.center=p;
}

-(void)dismisProgress{
    if (_textLabel) {
        _textLabel.text =@"";
    }

    if(activityView){
        [activityView stopAnimating];
        [activityView removeFromSuperview];
        activityView = nil;
    }
    
    if(_toastView){
        [_toastView removeFromSuperview];
    }
    
    if (_imageView) {
        [_imageView removeFromSuperview];
        _imageView = nil;
    }
}


-(void)cleanInstance{
    if(_textLabel){
        [_textLabel removeFromSuperview];
        _textLabel=nil;
    }
    if(_toastView){
        [_toastView removeFromSuperview];
        _toastView=nil;
    }
    
    if(activityView){
        [activityView stopAnimating];
        [activityView removeFromSuperview];
        activityView = nil;
    }
    
    if (_imageView) {
        [_imageView removeFromSuperview];
        _imageView = nil;
    }
    _instance = nil;
}


@end
