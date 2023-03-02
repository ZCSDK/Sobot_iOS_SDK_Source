//
//  ZCQuickLeaveView.m
//  SobotKit
//
//  Created by zhangxy on 2022/4/20.
//  Copyright © 2022 zhichi. All rights reserved.
//

#import "ZCQuickLeaveView.h"


#import "ZCLibGlobalDefine.h"
#import "ZCUIColorsDefine.h"
#import "ZCPlatformTools.h"
#import "ZCUIKeyboard.h"
#import "ZCUIImageTools.h"
#import "ZCToolsCore.h"
#import "ZCLeaveEditView.h"

@interface ZCQuickLeaveView(){
    CGFloat viewWidth;
    CGFloat viewHeight;
    
    ZCUIKeyboard *_keyboardView;
}
@property (nonatomic,strong) UIView * backGroundView;
@property (nonatomic,strong) ZCLeaveEditView * leaveEditView;
@property (nonatomic,strong) UIViewController * controller;

@end


@implementation ZCQuickLeaveView


-(ZCQuickLeaveView *)initActionSheet:(UIView *)view withController:(UIViewController *)exController{
    self = [super init];
    if (self) {
        viewWidth = view.frame.size.width;
        viewHeight = ScreenHeight;
        _controller = exController;
        
        self.frame = CGRectMake(0, 0, viewWidth, viewHeight);
        self.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
        self.autoresizesSubviews = YES;
        self.backgroundColor = UIColorFromRGBAlpha(TextBlackColor, 0.6);
        self.userInteractionEnabled = YES;
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(shareViewDismiss:)];
        [self addGestureRecognizer:tapGesture];
        
        [self createSubviews];
    }
    return self;
}

- (void)createSubviews{
    CGFloat bw=viewWidth;
    
    
    self.backGroundView = [[UIView alloc] initWithFrame:CGRectMake((viewWidth - bw) / 2.0, viewHeight, bw, 0)];
    self.backGroundView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleWidth;
    self.backGroundView.backgroundColor = UIColorFromThemeColor(ZCBgSystemWhiteLightDarkColor);
    //    [self.backGroundView.layer setCornerRadius:5.0f];
    self.backGroundView.layer.masksToBounds = YES;
    [self addSubview:self.backGroundView];
    
    
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, bw, 60)];
    [titleLabel setText:ZCSTLocalString(@"填写信息")];
    titleLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    [titleLabel setTextAlignment:NSTextAlignmentCenter];
    self.backGroundView.backgroundColor = UIColorFromThemeColor(ZCBgSystemWhiteLightDarkColor);
    [titleLabel setTextColor:UIColorFromThemeColor(ZCTextMainColor)];
    [titleLabel setFont:ZCUIFontBold17];
    [self.backGroundView addSubview:titleLabel];
    

    // 线条
     UIView *topline = [[UIView alloc]initWithFrame:CGRectMake(0, 60, viewWidth, 0.5)];
     topline.backgroundColor = [ZCUITools zcgetCommentButtonLineColor];
     topline.autoresizingMask = UIViewAutoresizingFlexibleWidth;
     [self.backGroundView addSubview:topline];
    
    
    // 左上角的删除按钮
    UIButton *cannelButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [cannelButton setFrame:CGRectMake(viewWidth - 40, (60 - 30)/2, 30,30)];
    cannelButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
    [cannelButton setImage:[ZCUITools zcuiGetBundleImage:@"zcicon_sf_close"] forState:UIControlStateNormal];
    cannelButton.imageView.contentMode = UIViewContentModeScaleAspectFit;
    [cannelButton addTarget:self action:@selector(tappedCancel) forControlEvents:UIControlEventTouchUpInside];
    [self.backGroundView addSubview:cannelButton];
    
    
    self.leaveEditView = [[ZCLeaveEditView alloc] initWithFrame:CGRectMake(0, 61, bw, viewHeight- 200 - 60) withController:_controller];
    [self.backGroundView addSubview:_leaveEditView];
    
    
    [UIView animateWithDuration:0.25f animations:^{
        [self.backGroundView setFrame:CGRectMake(self.backGroundView.frame.origin.x, viewHeight - CGRectGetMaxY(self.leaveEditView.frame) - XBottomBarHeight - 20,self.backGroundView.frame.size.width, CGRectGetMaxY(self.leaveEditView.frame)+XBottomBarHeight + 20)];
    } completion:^(BOOL finished) {
        
    }];
}



- (void)showEditView{
    
    _leaveEditView.ticketTitleShowFlag = _ticketTitleShowFlag;
    _leaveEditView.tickeTypeFlag = _tickeTypeFlag;
    _leaveEditView.typeArr = _typeArr;
    _leaveEditView.ticketTypeId = _ticketTypeId;
    _leaveEditView.msgTmp = _msgTmp;
    _leaveEditView.msgTxt = _msgTxt;
    _leaveEditView.templateldIdDic = _templateldIdDic;
    _leaveEditView.emailFlag = _emailFlag;
    _leaveEditView.emailShowFlag = _emailShowFlag;
    _leaveEditView.telFlag = _telFlag;
    _leaveEditView.telShowFlag = _telShowFlag;
    _leaveEditView.enclosureFlag = _enclosureFlag;
    _leaveEditView.enclosureShowFlag = _enclosureShowFlag;
    _leaveEditView.coustomArr = _coustomArr;
    _leaveEditView.fromSheetView = YES;
    _leaveEditView.ticketFrom = @"21";
    __block ZCQuickLeaveView *safeSelf = self;
    [_leaveEditView setPageChangedBlock:^(id  _Nonnull object, int code) {
        //code==1 添加成功,code == 2点击完成，跳转页面
        if(code == 1){
            [safeSelf tappedCancel];
        }
        
        if(code == 3001 || code == 3002){
            [safeSelf tappedCancel];
        }
        
        if(safeSelf.resultBlock){
            safeSelf.resultBlock(code,safeSelf.leaveEditView.uploadMessage);
        }
    }];
    
    [_leaveEditView loadCustomFields];
    
    [[[ZCToolsCore getToolsCore] getCurWindow] addSubview:self];
}


// 隐藏弹出层
- (void)shareViewDismiss:(UITapGestureRecognizer *) gestap{
    CGPoint point = [gestap locationInView:self];
    CGRect f=self.backGroundView.frame;
    
    if(point.x<f.origin.x || point.x>(f.origin.x+f.size.width) ||
       point.y<f.origin.y || point.y>(f.origin.y+f.size.height)){
        [self tappedCancel:YES];
    }
}

- (void)tappedCancel{
    [self tappedCancel:YES];
}

/**
 *  关闭弹出层
 */
- (void)tappedCancel:(BOOL) isClose{
    // 移除通知
    [[NSNotificationCenter defaultCenter]removeObserver:self];
    
//    [UIView animateWithDuration:0 animations:^{
        [self.backGroundView setFrame:CGRectMake(_backGroundView.frame.origin.x,viewHeight ,self.backGroundView.frame.size.width,self.backGroundView.frame.size.height)];
//        self.alpha = 0;
//    } completion:^(BOOL finished) {
//        if (finished) {
            [self removeFromSuperview];
//        }
//    }];
    
//    if (_msgSetClickBlock) {
//        _msgSetClickBlock(nil);
//    }
    // 点击取消的时候设置键盘样式 关闭加载动画
//    [_keyboardView setKeyBoardStatus:ZCKeyboardStatusRobot];
}


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
