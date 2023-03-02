//
//  ZCUIKeyboard.m
//  SobotKit
//
//  Created by zhangxy on 15/11/13.
//  Copyright © 2015年 zhichi. All rights reserved.
//

#import "ZCUIKeyboard.h"


#import "ZCLibGlobalDefine.h"
#import "ZCUIColorsDefine.h"
#import "ZCUIImageTools.h"
#import "ZCStoreConfiguration.h"
#import "ZCSobotCore.h"

#import "ZCPlatformTools.h"

#import "ZCAutoListView.h"

#import "ZCUICore.h"
#import "ZCLibCusMenu.h"
#import "ZCObjButton.h"

#define MoreViewHeight  270  //  2.8.0  270
#define EmojiViewHeight 270 //  2.8.0  270
#define MoreViewHorizontalHeight 120
#define EmojiViewHorizontalHeight 120

#import <AVFoundation/AVFoundation.h>

#import "ZCLocationController.h"
#import "ZCVideoViewController.h"
#import "ZCEdgeInsetsLabel.h"

#import "ZCToolsCore.h"
/**
 *  BottomButtonClickTag ENUM
 */
typedef NS_ENUM(NSInteger, BottomButtonClickTag) {
    /** 转人工 */
    BUTTON_CONNECT_USER   = 2,
    /** 相机相册 */
    BUTTON_ADDPHOTO       = 3,
    /** 录语音 */
    BUTTON_ADDVOICE       = 4,
    /** 转人工按钮的tag值（2中状态下的图标）*/
    BUTTON_ToKeyboard     = 5,
    /**  */
    BUTTON_RECORD         = 6,
    /** 新会话（原重新接入）*/
    BUTTON_RECONNECT_USER = 7,
    /** 满意度 */
    BUTTON_SATISFACTION   = 8,
    /** 留言 */
    BUTTON_LEAVEMESSAGE   = 9,
    /** 更多 */
    BUTTON_ADDMORE        = 10,
    /** 表情键盘 */
    BUTTON_ADDFACEVIEW    = 11,
};



@interface ZCUIKeyboard()<ZCUIRecordDelegate,UITextViewDelegate,UIActionSheetDelegate,UINavigationControllerDelegate, UIImagePickerControllerDelegate,EmojiBoardDelegate,UIGestureRecognizerDelegate,UIDocumentPickerDelegate,ZCAutoListViewDelegate>{
    CGFloat navHeight;
    
}

@property (nonatomic , strong) UIView *ppView;


/** 语音事件 */
@property (nonatomic,strong) UIButton   *zc_voiceButton;

/** 留言按钮 */
@property (nonatomic,strong) UIButton   *zc_leaveMsgButton;

/** 图片按钮 */
@property (nonatomic,strong) UIButton   *zc_addMoreButton;

///** 录音按钮 */
//@property (nonatomic,strong) UIButton   *zc_pressedButton;

/** 表情按钮 */
@property (nonatomic,strong) UIButton   *zc_faceButton;

/** 新会话按钮 */
@property (nonatomic,strong) UIButton   *zc_againAccessBtn;

/** 加载动画 */
@property (nonatomic,strong) UIActivityIndicatorView *zc_activityView;

/** 系统相册相机图片 */
@property (nonatomic,strong) UIImagePickerController *zc_imagepicker;

/** 聊天页中UITableView 用于界面键盘高度处理 */
@property (nonatomic,strong) UITableView *zc_listTable;

/** 键盘高度 */
@property (nonatomic,assign) CGFloat zc_keyBoardHeight;

/** 语音动画页面 */
@property (nonatomic,strong) ZCUIRecordView *zc_recordView;

/** emjoy布局view */
@property (nonatomic,strong) EmojiBoardView *zc_emojiView;

/** 添加留言背景View */
@property (nonatomic,strong) UIView   *zc_sessionBgView;


/** 添加相机的View */
@property (nonatomic,strong) UIScrollView *zc_moreView;
@property (nonatomic,strong) UIPageControl *facePageControl;

/** (排队中...)Label */
@property (nonatomic,strong) ZCEdgeInsetsLabel *zc_waitLabel;



/** 机器人语音按钮*/
@property (nonatomic,strong) UIButton * zc_robotVoiceBtn;

/** 机器人录音功能提示语*/
@property (nonatomic,strong) UILabel * vioceTipLabel;

/** 机器人录音功能提示语 背景*/
@property (nonatomic,strong) UIView *vioceTipBgView;

@end


@implementation ZCUIKeyboard{
    // 页面点击事件
    UITapGestureRecognizer *tapRecognizer;
    
    ZCKeyboardViewStatus curKeyBoardStatus;
    
    CGFloat startTableY;
    
    NSMutableArray * buttonArr;// 记录更多按钮的个数
}


-(id)init{
    self=[super init];
    if(self){
        
    }
    return self;
}

-(ZCLibConfig *)getZCLibConfig{
    return [[ZCUICore getUICore] getLibConfig];
}


///////////////////////////////////////////////////////
#pragma mark -- 懒加载
- (UIView*)zc_bottomView{
    if (!_zc_bottomView) {
        CGFloat BY = [self getSourceViewHeight]-BottomHeight;
        
        // 横屏时，修改底部宽度
        _zc_bottomView = [[UIView alloc] initWithFrame:CGRectMake(0, BY, [self getSourceViewWidth], BottomHeight)];
        // 在ZCChatView中坐标，适配横竖屏切换时键盘位置
//        [_zc_bottomView setAutoresizingMask:UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleTopMargin];
//        [_zc_bottomView setAutoresizingMask:UIViewAutoresizingFlexibleTopMargin];
//        [_zc_bottomView setAutoresizesSubviews:YES];
        [_zc_bottomView setBackgroundColor:[ZCUITools zcgetBackgroundBottomColor]];

        _zc_bottomView.userInteractionEnabled=YES;
        _zc_bottomView.multipleTouchEnabled = YES;
        _zc_sourceView.userInteractionEnabled = YES;
        UIView *lineView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, _zc_bottomView.frame.size.width, 0.5)];
        lineView.backgroundColor = [ZCUITools zcgetCommentButtonLineColor];
        [_zc_bottomView addSubview:lineView];
        
        [self.zc_sourceView addSubview:_zc_bottomView];
    }
    return _zc_bottomView;
}


- (UITextView *)zc_chatTextView{
    if (!_zc_chatTextView) {
        _zc_chatTextView = [[UITextView alloc] initWithFrame:CGRectMake(48, (BottomHeight-35)/2, [self getSourceViewWidth] - 48*2 - 12, 35)];
        _zc_chatTextView.layer.cornerRadius                      = 16;
        _zc_chatTextView.layer.masksToBounds                     = YES;
        if (iOS7) {
            // 关闭UITextView 非连续布局属性
            _zc_chatTextView.layoutManager.allowsNonContiguousLayout = NO;
        }
        if (iOS7) {
//            _zc_chatTextView.layer.borderWidth                       = 0.75f;
        }else{
//            _zc_chatTextView.layer.borderWidth                       = 0.5f;
        }
//        _zc_chatTextView.layer.borderWidth                       = 0.5f;
        _zc_chatTextView.font                                    = [ZCUITools zcgetListKitTitleFont];
        _zc_chatTextView.textColor                               = [ZCUITools zcgetChatTextViewColor];
        _zc_chatTextView.layer.borderColor                       = UIColorFromThemeColor(ZCBgLineColor).CGColor;
        _zc_chatTextView.returnKeyType                           = UIReturnKeySend;
        _zc_chatTextView.autoresizesSubviews                     = YES;
        _zc_chatTextView.delegate                                = self;
        _zc_chatTextView.textAlignment                           = NSTextAlignmentLeft;
        _zc_chatTextView.autoresizingMask                        = (UIViewAutoresizingFlexibleWidth);
        //    [_chatTextView setContentInset:UIEdgeInsetsMake(0, 0, 0, 0)]; FFF2F5F7
        [_zc_chatTextView setBackgroundColor:UIColorFromThemeColor(ZCBgLeftChatColor)];
        _zc_chatTextView.textContainerInset = UIEdgeInsetsMake(10, 10, 10, 10 + 30);
        [_zc_bottomView addSubview:_zc_chatTextView];
    }
    return _zc_chatTextView;
}


- (UIButton *)zc_pressedButton{
    if (!_zc_pressedButton) {
        _zc_pressedButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _zc_pressedButton.userInteractionEnabled = YES;
        _zc_pressedButton.layer.cornerRadius     = 16;
        _zc_pressedButton.layer.masksToBounds    = YES;
//        _zc_pressedButton.layer.borderWidth      = 0.75f;
        _zc_pressedButton.titleLabel.numberOfLines =  2;
        _zc_pressedButton.titleLabel.font        = [ZCUITools zcgetVoiceButtonFont];
//        _zc_pressedButton.layer.borderColor      = [ZCUITools zcgetBackgroundBottomLineColor].CGColor;
        [_zc_pressedButton setTitle:ZCSTLocalString(@"按住 说话") forState:UIControlStateNormal];
        [_zc_pressedButton setTitleColor:UIColorFromThemeColor(ZCTextMainColor) forState:UIControlStateNormal];
        [_zc_pressedButton setBackgroundImage:[ZCUIImageTools zcimageWithColor:UIColorFromThemeColor(ZCBgLeftChatColor)] forState:UIControlStateNormal];
                [_zc_pressedButton setBackgroundImage:[ZCUIImageTools zcimageWithColor:UIColorFromThemeColor(ZCTextPlaceHolderColor)] forState:UIControlStateHighlighted];
        //        [_zc_pressedButton setFrame:CGRectMake(48, (BottomHeight-35)/2, [self getSourceViewWidth]-48*3, 35)];
        [_zc_bottomView addSubview:_zc_pressedButton];
        [_zc_pressedButton setHidden:YES];
        _zc_pressedButton.autoresizesSubviews                     = YES;
        _zc_pressedButton.autoresizingMask = UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleWidth;
        [_zc_pressedButton addTarget:self action:@selector(btnTouchDown:) forControlEvents:UIControlEventTouchDown];
        [_zc_pressedButton addTarget:self action:@selector(btnTouchDownRepeat:) forControlEvents:UIControlEventTouchDownRepeat];
        [_zc_pressedButton addTarget:self action:@selector(btnTouchMoved:withEvent:) forControlEvents:UIControlEventTouchDragInside];
        [_zc_pressedButton addTarget:self action:@selector(btnTouchMoved:withEvent:) forControlEvents:UIControlEventTouchDragOutside];
        [_zc_pressedButton addTarget:self action:@selector(btnTouchMoved:withEvent:) forControlEvents:UIControlEventTouchDragEnter];
        [_zc_pressedButton addTarget:self action:@selector(btnTouchEnd:withEvent:) forControlEvents:UIControlEventTouchUpInside];
        [_zc_pressedButton addTarget:self action:@selector(btnTouchCancel:) forControlEvents:UIControlEventTouchCancel];
        [_zc_pressedButton addTarget:self action:@selector(btnTouchCancel:) forControlEvents:UIControlEventTouchUpOutside];
        
        if (![self getZCLibConfig].isArtificial ) {
            if (![ZCUICore getUICore].kitInfo.isShowTansfer && ![ZCLibClient getZCLibClient].isShowTurnBtn) {
                // 不显示转人工的按钮
                [_zc_pressedButton setFrame:CGRectMake(48, (BottomHeight-35)/2, [self getSourceViewWidth]-58, 35)];
            }else{
                [_zc_pressedButton setFrame:CGRectMake(48 *2, (BottomHeight-35)/2, [self getSourceViewWidth]-48*3-5, 35)];
            }
        }else{
            [_zc_pressedButton setFrame:CGRectMake(48, (BottomHeight-35)/2, [self getSourceViewWidth]-48*3, 35)];
        }
        
    }
    return _zc_pressedButton;
}

- (UIButton *)zc_turnButton{
    if (!_zc_turnButton) {
        _zc_turnButton = [UIButton buttonWithType:UIButtonTypeCustom];
        
        if ([[ZCLibClient getZCLibClient].libInitInfo.absolute_language hasPrefix:@"zh-"] || (sobotConvertToString([ZCLibClient getZCLibClient].libInitInfo.absolute_language).length == 0 && [sobotGetLanguagePrefix() hasPrefix:@"zh-"])) {
            [_zc_turnButton setImage:[ZCUITools zcuiGetBundleImage:@"zcicon_turnserver_word_nol"] forState:UIControlStateNormal];
            [_zc_turnButton setImage:[ZCUITools zcuiGetBundleImage:@"zcicon_turnserver_word_nol"] forState:UIControlStateHighlighted];
        }else{
            [_zc_turnButton setImage:[ZCUITools zcuiGetBundleImage:@"zcicon_turnserver_word_nol_en"] forState:UIControlStateNormal];
            [_zc_turnButton setImage:[ZCUITools zcuiGetBundleImage:@"zcicon_turnserver_word_nol_en"] forState:UIControlStateHighlighted];
        }
        
        if (sobotConvertToString([ZCUICore getUICore].kitInfo.turnBtnNolImg).length >0) {
            [_zc_turnButton setImage:[ZCUITools zcuiGetBundleImage:sobotConvertToString([ZCUICore getUICore].kitInfo.turnBtnNolImg)] forState:UIControlStateNormal];
        }
        if (sobotConvertToString([ZCUICore getUICore].kitInfo.turnBtnSelImg).length >0) {
            [_zc_turnButton setImage:[ZCUITools zcuiGetBundleImage:sobotConvertToString([ZCUICore getUICore].kitInfo.turnBtnSelImg)] forState:UIControlStateHighlighted];
        }

        [_zc_turnButton setFrame:CGRectMake(0, 0 , 48, 49)];
        [_zc_turnButton setContentVerticalAlignment:UIControlContentVerticalAlignmentCenter];
        [_zc_turnButton setBackgroundColor:[UIColor clearColor]];
        _zc_turnButton.tag                 = BUTTON_CONNECT_USER;
        [_zc_turnButton addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
        [_zc_turnButton.imageView setContentMode:UIViewContentModeScaleAspectFit];
        _zc_turnButton.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
        [_zc_bottomView addSubview:_zc_turnButton];
        _zc_turnButton.hidden = NO;
    }
    return _zc_turnButton;
}

- (UIView *)verticalLineView{
    if (!_verticalLineView) {
        _verticalLineView = [[UIView alloc]init];
        _verticalLineView.backgroundColor = [ZCUITools zcgetCommentButtonLineColor];
        [_zc_bottomView addSubview:_verticalLineView];
        _verticalLineView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
    }
    return _verticalLineView;
}

-(UIButton *)zc_addMoreButton{
    if (!_zc_addMoreButton) {
        _zc_addMoreButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_zc_addMoreButton setImage:[ZCUITools zcuiGetBundleImage:@"zcicon_add"] forState:UIControlStateNormal];
        [_zc_addMoreButton setImage:[ZCUITools zcuiGetBundleImage:@"zcicon_add_selected"] forState:UIControlStateHighlighted];
        [_zc_addMoreButton setImageEdgeInsets:UIEdgeInsetsMake(7.5, 5, 7.5, 10)];
        [_zc_addMoreButton setFrame:CGRectMake([self getSourceViewWidth]-48, 0 , 48, 49)];
        [_zc_addMoreButton.imageView setContentMode:UIViewContentModeScaleAspectFit];
        [_zc_addMoreButton setBackgroundColor:[UIColor clearColor]];
        _zc_addMoreButton.tag                 = BUTTON_ADDPHOTO;
        [_zc_addMoreButton addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
        [_zc_bottomView addSubview:_zc_addMoreButton];
        [_zc_addMoreButton setHidden:YES];
        _zc_addMoreButton.autoresizingMask = UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleLeftMargin;
    }
    return _zc_addMoreButton;
}

- (UIButton *)zc_faceButton{
    if (!_zc_faceButton) {
        _zc_faceButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_zc_faceButton setImage:[ZCUITools zcuiGetBundleImage:@"zcicon_expression_normal"] forState:UIControlStateNormal];
        [_zc_faceButton setImage:[ZCUITools zcuiGetBundleImage:@"zcicon_expression_pressed"] forState:UIControlStateHighlighted];
//        [_zc_faceButton setImageEdgeInsets:UIEdgeInsetsMake(7.5, 10, 7.5, 5)];
        [_zc_faceButton setFrame:CGRectMake([self getSourceViewWidth] -52 - 46 , -1 , 52, 52)];
        [_zc_faceButton.imageView setContentMode:UIViewContentModeScaleAspectFit];
        [_zc_faceButton setBackgroundColor:[UIColor clearColor]];
        _zc_faceButton.tag = BUTTON_ADDFACEVIEW;
        [_zc_faceButton addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
        _zc_faceButton.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleLeftMargin;
        [_zc_bottomView addSubview:_zc_faceButton];
        _zc_faceButton.hidden = YES;
    }
    return _zc_faceButton;
}

- (UIView *)zc_sessionBgView{
    if (!_zc_sessionBgView) {
        _zc_sessionBgView = [[UIView alloc]initWithFrame:CGRectMake(0, 1, [self getSourceViewWidth], ZCConnectBottomHeight)];
        _zc_sessionBgView.backgroundColor = [ZCUITools zcgetBackgroundBottomColor];
//        _zc_sessionBgView.backgroundColor = [UIColor redColor];
        [_zc_sessionBgView setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
        [_zc_bottomView addSubview:_zc_sessionBgView];
        _zc_sessionBgView.hidden = YES;
    }
    return _zc_sessionBgView;
}


- (UIActivityIndicatorView *)zc_activityView{
    if (!_zc_activityView) {
        _zc_activityView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        [_zc_sessionBgView addSubview:_zc_activityView];
        _zc_activityView.center = _zc_sessionBgView.center;
        _zc_activityView.hidden=YES;
    }
    return _zc_activityView;
}

-(ZCEdgeInsetsLabel *)zc_waitLabel{
    if (!_zc_waitLabel) {
        _zc_waitLabel = [[ZCEdgeInsetsLabel alloc]initWithFrame:CGRectMake(48, (BottomHeight-35)/2, [self getSourceViewWidth]-58-36, 34)];
        _zc_waitLabel.layer.cornerRadius = 17;
        _zc_waitLabel.layer.masksToBounds = YES;
        
        _zc_waitLabel.layer.borderColor = [ZCUITools zcgetBackgroundBottomLineColor].CGColor;
        _zc_waitLabel.font = ZCUIFont15;
        _zc_waitLabel.textAlignment                           = NSTextAlignmentCenter;
        _zc_waitLabel.autoresizingMask                        = (UIViewAutoresizingFlexibleWidth);
        [_zc_waitLabel setBackgroundColor:UIColorFromThemeColor(ZCBgLeftChatColor)];
        _zc_waitLabel.text = ZCSTLocalString(@"排队中...");
        _zc_waitLabel.textColor = [ZCUITools zcgetTimeTextColor];
        _zc_waitLabel.textAlignment = NSTextAlignmentLeft;
        _zc_waitLabel.edgeInsets = UIEdgeInsetsMake(0, 10, 0, 0);
        [_zc_bottomView addSubview:_zc_waitLabel];
        _zc_waitLabel.hidden = YES;
    }
    return _zc_waitLabel;
}

-(UIScrollView *)zc_moreView{
    if(!_zc_moreView){
        //添加背景view（布置 图片、拍摄、满意度按钮）
        CGFloat moreHeight = MoreViewHeight;
        if ([self getSourceViewHeight] < [self getSourceViewWidth]) {
            moreHeight = MoreViewHorizontalHeight;
        }
        _zc_moreView = [[UIScrollView alloc]initWithFrame:CGRectMake(0, [self getSourceViewHeight], [self getSourceViewWidth], moreHeight)];
//        [_zc_moreView setBackgroundColor:UIColorFromRGB(BgTextColor)];
        // 2.8.0 白色背景
        [_zc_moreView setBackgroundColor:UIColorFromThemeColor(ZCBgSystemWhiteLightDarkColor)];
        _zc_moreView.pagingEnabled = YES;
        _zc_moreView.showsHorizontalScrollIndicator = NO;
        _zc_moreView.showsVerticalScrollIndicator = YES;
        _zc_moreView.delegate = self;
        [_zc_moreView setAutoresizingMask:UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleBottomMargin];
        [_zc_moreView setAutoresizesSubviews:YES];
        [_zc_sourceView addSubview:_zc_moreView];
        
        
        //添加PageControl
        _facePageControl = [[UIPageControl alloc]initWithFrame:CGRectZero];
        [_facePageControl setAutoresizingMask:UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleTopMargin];
        [_facePageControl setAutoresizesSubviews:YES];
        
        [_facePageControl addTarget:self
                             action:@selector(pageChange:)
                   forControlEvents:UIControlEventValueChanged];
        _facePageControl.pageIndicatorTintColor=[UIColor lightGrayColor];
        _facePageControl.currentPageIndicatorTintColor=[UIColor darkGrayColor];
        _facePageControl.currentPage = 0;
        [_zc_sourceView addSubview:_facePageControl];
        
        _facePageControl.hidden = YES;
    }
    return _zc_moreView;
}

//停止滚动的时候
-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    
    [_facePageControl setCurrentPage:_zc_moreView.contentOffset.x / [self getSourceViewWidth]];
    // 更新页码
    [_facePageControl updateCurrentPageDisplay];
}

- (void)pageChange:(id)sender {
    
    [_zc_moreView setContentOffset:CGPointMake(_facePageControl.currentPage * [self getSourceViewWidth], 0) animated:YES];
    [_facePageControl setCurrentPage:_facePageControl.currentPage];
}


-(UIButton *)zc_voiceButton{
    if (!_zc_voiceButton) {
        _zc_voiceButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_zc_voiceButton setImage:[ZCUITools zcuiGetBundleImage:@"zcicon_voice_normal"] forState:UIControlStateNormal];
        [_zc_voiceButton setImage:[ZCUITools zcuiGetBundleImage:@"zcicon_voice_pressed"] forState:UIControlStateHighlighted];
        [_zc_voiceButton setImageEdgeInsets:UIEdgeInsetsMake(10.5, 10, 10.5, 10)];
        [_zc_voiceButton setFrame:CGRectMake(48 * 2, 0 , 48, 49)];
        [_zc_voiceButton setBackgroundColor:[UIColor clearColor]];
        _zc_voiceButton.tag                 = BUTTON_ADDVOICE;
        [_zc_voiceButton addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
        _zc_voiceButton.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
        [_zc_bottomView addSubview:_zc_voiceButton];
        _zc_voiceButton.hidden = YES;
    }
    return _zc_voiceButton;
}


-(UIView *)createVioceTipLabel{
    if (!_vioceTipLabel) {
        _vioceTipBgView = [[UIView alloc]init];
        [self.zc_sourceView addSubview:_vioceTipBgView];
        _vioceTipBgView.backgroundColor = UIColorFromThemeColorAlpha(ZCTextSubColor, 0.9);
        _vioceTipBgView.frame = CGRectMake(0, CGRectGetMaxY(self.zc_bottomView.frame) - CGRectGetHeight(self.zc_bottomView.frame) -30, CGRectGetWidth(self.zc_bottomView.frame), 30);
        [_vioceTipBgView setAutoresizingMask:UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleTopMargin];
        
        _vioceTipLabel = [[UILabel alloc]initWithFrame:CGRectMake(10, 5, CGRectGetWidth(self.vioceTipBgView.frame)-20, 20)];
//        _vioceTipLabel.backgroundColor = UIColorFromThemeColorAlpha(ZCTextSubColor, 0.9);
        [_vioceTipLabel setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
        _vioceTipLabel.textColor = UIColorFromThemeColor(ZCKeepWhiteColor);
        _vioceTipLabel.font = ZCUIFont12;
        _vioceTipLabel.textAlignment = NSTextAlignmentCenter;
        _vioceTipLabel.text = ZCSTLocalString(@"机器人咨询模式下，语音将自动转化为文字发送");
        _vioceTipLabel.numberOfLines = 0;
        [_vioceTipLabel sizeToFit];
        CGRect vf = _vioceTipLabel.frame;
        if (vf.size.height > 25) {
            vf.size.height = vf.size.height;
            vf.origin.y = 5;
            vf.size.width = CGRectGetWidth(self.zc_bottomView.frame)-12;
            _vioceTipLabel.frame = vf;
        }else{
            if (vf.size.height <20) {
                vf.size.height = 20;
            }
            vf.size.width = CGRectGetWidth(self.zc_bottomView.frame)-12;
            _vioceTipLabel.frame = vf;
        }
        [self.vioceTipBgView addSubview:_vioceTipLabel];
        _vioceTipLabel.hidden = YES;
        _vioceTipBgView.hidden = YES;
        CGRect bgF = _vioceTipBgView.frame;
        bgF.size.height = vf.size.height+10;
        bgF.origin.y = CGRectGetMaxY(self.zc_bottomView.frame) - bgF.size.height -40;
        _vioceTipBgView.frame = bgF;
        
    }
    return _vioceTipLabel;
}

///////////////////////////////////////////////////////

#pragma mark -- 图片、拍摄、满意度 按钮模块
// （图片、拍摄、满意度 按钮模块）
- (void)createMoreView{
    
    if (self.zc_moreView != nil) {
        [_zc_moreView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
        
        _facePageControl.hidden = YES;
    }
    
    NSMutableArray *titles = [NSMutableArray arrayWithCapacity:5];
    ZCLibCusMenu *menu1 = [[ZCLibCusMenu alloc] init];
    menu1.imgName = @"zcicon_bottombar_satisfaction";
    menu1.imgNamePress = @"zcicon_bottombar_satisfaction";
    menu1.title = ZCSTLocalString(@"服务评价");
    menu1.lableId = ZCKeyboardClickTypeSatisfaction;
    
    ZCLibCusMenu *menu2 = [[ZCLibCusMenu alloc] init];
    menu2.imgName = @"zcicon_bottombar_message";
    menu2.imgNamePress = @"zcicon_bottombar_message";
    menu2.title = ZCSTLocalString(@"留言");
    menu2.lableId = ZCKeyboardClickTypeLeavePage;
    
    
    ZCLibCusMenu *menu3 = [[ZCLibCusMenu alloc] init];
    menu3.imgName = @"zcicon_sendpictures";
    menu3.imgNamePress = @"zcicon_sendpicturesSelected";
    menu3.title = ZCSTLocalString(@"图片");
    menu3.lableId = ZCKeyboardClickTypeAddPhotoPicture;
    
    
    ZCLibCusMenu *menu4 = [[ZCLibCusMenu alloc] init];
    menu4.imgName = @"zcicon_takingpictures";
    menu4.imgNamePress = @"zcicon_takingpictures";
    menu4.title = ZCSTLocalString(@"拍摄");
    menu4.lableId = ZCKeyboardClickTypeAddPhotoCamera;
    
    
    ZCLibCusMenu *menu5 = [[ZCLibCusMenu alloc] init];
    menu5.imgName = @"zcicon_choose";
    menu5.imgNamePress = @"zcicon_choose";
    menu5.title = ZCSTLocalString(@"文件");
    menu5.lableId = ZCKeyboardClickTypeAddDocumentFile;
    
    
    
    if (![self getZCLibConfig].isArtificial || [ZCUICore getUICore].isAfterConnectUser) {
        if ([self getZCLibConfig].msgFlag == 0) {
            titles = [NSMutableArray arrayWithObjects:menu2,menu1, nil];
            
        }else{
            titles = [NSMutableArray arrayWithObjects:menu1, nil];
        }
    }else{
        //        titles = [NSMutableArray arrayWithObjects:menu3,menu5,menu4,menu1, nil];
        
        NSString *version= [UIDevice currentDevice].systemVersion;
        if(version.doubleValue >= 12.0) {
            // 针对 12.0 以上的iOS系统进行处理
            // 是否开启留言,并且不是留言转离线消息
           if ([self getZCLibConfig].msgFlag == 0 && [self getZCLibConfig].msgToTicketFlag != 2) {
               titles = [NSMutableArray arrayWithObjects:menu3,menu4,menu5,menu2,menu1, nil];
           }else{
               titles = [NSMutableArray arrayWithObjects:menu3,menu4,menu5,menu1, nil];
           }
            
        }else{
            // 针对 12.0 以下的iOS系统进行处理
            if ([self getZCLibConfig].msgFlag == 0 && [self getZCLibConfig].msgToTicketFlag != 2) {
                titles = [NSMutableArray arrayWithObjects:menu3,menu4,menu2,menu1, nil];
            }else{
                titles = [NSMutableArray arrayWithObjects:menu3,menu4,menu1, nil];
            }
        }
       
        
        if([ZCUICore getUICore].kitInfo.canSendLocation){
            ZCLibCusMenu *menu6 = [[ZCLibCusMenu alloc] init];
            menu6.imgName = @"zcicon_location";
            menu6.imgNamePress = @"zcicon_location";
            menu6.title = ZCSTLocalString(@"位置");
            menu6.lableId = ZCKeyboardClickTypeAddLocation;
            [titles addObject:menu6];
        }
    }
    if([ZCUICore getUICore].kitInfo.hideMenuSatisfaction){
        [titles removeObject:menu1];
    }
    // 隐藏所有留言，或人工状态隐藏留言
    if([ZCUICore getUICore].kitInfo.hideMenuLeave || ([ZCUICore getUICore].kitInfo.hideMenuManualLeave && [self getZCLibConfig].isArtificial)){
        [titles removeObject:menu2];
    }
    if([ZCUICore getUICore].kitInfo.hideMenuPicture){
        [titles removeObject:menu3];
    }
    if([ZCUICore getUICore].kitInfo.hideMenuCamera){
        [titles removeObject:menu4];
    }
    if([ZCUICore getUICore].kitInfo.hideMenuFile){
        [titles removeObject:menu5];
    }
    
    
    if([ZCUICore getUICore].kitInfo.cusMoreArray!=nil && [ZCUICore getUICore].kitInfo.cusMoreArray.count > 0 && [self getZCLibConfig].isArtificial) {
        for (ZCLibCusMenu  *item in [ZCUICore getUICore].kitInfo.cusMoreArray) {
            item.lableId = 1000;
            [titles addObject:item];
        }
    }
    if([ZCUICore getUICore].kitInfo.cusRobotMoreArray!=nil && [ZCUICore getUICore].kitInfo.cusRobotMoreArray.count > 0 && ![self getZCLibConfig].isArtificial) {
        for (ZCLibCusMenu  *item in [ZCUICore getUICore].kitInfo.cusRobotMoreArray) {
            item.lableId = 1000;
            [titles addObject:item];
        }
    }
    
    
    [self creatButtonForArray:titles];
    
    //    [_photoView addSubview:itemView];
    tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTapAnywhere:)];
    // 每次添加手势设置代理
    tapRecognizer.delegate  =self;
    _zc_sourceView.userInteractionEnabled=YES;
    UIView * lineView2 = [[UIView alloc]initWithFrame:CGRectMake(0, 0, [self getSourceViewWidth], 0.5)];
    lineView2.backgroundColor = [ZCUITools zcgetBackgroundBottomLineColor];
    [_zc_moreView addSubview:lineView2];
}

#pragma mark -- 创建满意度、留言、相册、评价等按钮
- (void)creatButtonForArray:(NSArray *)titles{
    if(titles.count == 0){
        return;
    }
    CGFloat itemH = 109;
    
    int columns         = 4;
    int allSize         = (int)titles.count;
    int rows            = (allSize % columns == 0)?(allSize / columns):(allSize / columns + 1);
    int pageSize        = rows * columns;
    int pageNum         = (allSize%pageSize==0) ? (allSize/pageSize) : (allSize/pageSize+1);
    
    
    for (int i= 0 ; i< pageNum ; i++) {
        CGFloat my = 15;
        CGFloat sx = ([self getSourceViewHeight] > [self getSourceViewWidth]) ?  25.0f*[self getSourceViewWidth]/375 : 25.0f*[self getSourceViewWidth]/667;
        CGFloat mx = 0;
        
        for(int j=0;j<pageSize;j++){
            if((i*pageSize+j)>=allSize){
                break;
            }
            
            //计算每一个表情按钮的坐标和在哪一屏
            mx = i * [self getSourceViewWidth] +  sx + (j%columns)* 60* [self getSourceViewWidth]/375 + (j%columns)*27* [self getSourceViewWidth]/375;
            if(j >= columns){
                my = (j / columns) * itemH + 8 + 15;
            }
            
            ZCLibCusMenu *item = titles[i*pageSize+j];
            UIButton * buttons = [self createItemMenuButton:item with:CGRectMake(mx, my, 60, itemH)];
//            buttons.backgroundColor = [UIColor yellowColor];
            [_zc_moreView addSubview:buttons];
        }
    }
    if (buttonArr != nil) {
        [buttonArr removeAllObjects];
    }
    buttonArr = [NSMutableArray arrayWithArray:titles];
    
    
    CGFloat moreHeight = MoreViewHeight;
    if ([self getSourceViewHeight] < [self getSourceViewWidth]) {
        moreHeight = MoreViewHorizontalHeight;
    }
    if(moreHeight < (itemH *rows + (rows-1)*52)){
        moreHeight = itemH *rows + (rows-1)*37 + 15;
    }
    _zc_moreView.contentSize = CGSizeMake(pageNum * [self getSourceViewWidth], moreHeight);// 原固定高度 190
    _facePageControl.numberOfPages = pageNum;
    if(allSize > 8){
        [_facePageControl setFrame:CGRectMake([self getSourceViewWidth]/2-50, [self getSourceViewHeight]-30, 100, 20)];
    }
    
}


-(ZCObjButton *)createItemMenuButton:(ZCLibCusMenu *) menu with:(CGRect) f{
    ZCObjButton * buttons = [ZCObjButton buttonWithType:UIButtonTypeCustom];
    //        [buttons setFrame:CGRectMake((i-1)*60+(i-1)*30, MoreViewHeight/2-itemH/2, 60, itemH)];
    [buttons setFrame:f];
    buttons.tag = menu.lableId;
    buttons.objTag = menu;
    buttons.titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
    [buttons.titleLabel setBackgroundColor:[UIColor clearColor]];
    [buttons.imageView setContentMode:UIViewContentModeScaleAspectFit];
    [buttons addTarget:self action:@selector(addResourcesAction:) forControlEvents:UIControlEventTouchUpInside];
    [buttons setImageEdgeInsets:UIEdgeInsetsMake(0, 0, 10, 0)];
    [buttons setImage:[ZCUITools zcuiGetBundleImage:menu.imgName] forState:UIControlStateNormal];
    if(sobotConvertToString(menu.imgNamePress).length > 0){
        [buttons setImage:[ZCUITools zcuiGetBundleImage:sobotConvertToString(menu.imgNamePress)] forState:UIControlStateHighlighted];
        [buttons setImage:[ZCUITools zcuiGetBundleImage:sobotConvertToString(menu.imgNamePress)] forState:UIControlStateSelected];
    }
    
    
    if(iOS7){
        UILabel *lbl = [[UILabel alloc] initWithFrame:CGRectMake(0, f.size.height- 35, 60, 21)];
        [lbl setText:menu.title];
        [lbl setFont:ZCUIFont12];
        [lbl setTextAlignment:NSTextAlignmentCenter];
        [lbl setTextColor:[ZCUITools zcgetTopViewTextColor]];
        [lbl setBackgroundColor:[UIColor clearColor]];
        [buttons addSubview:lbl];
        
        CGSize s = [sobotConvertToString(menu.title)  sizeWithAttributes:@{NSFontAttributeName:lbl.font}];
        if(s.width > 60){
            [lbl setFont:ZCUIFont8];
        }
    }else{
        CGFloat margin = (70- buttons.titleLabel.frame.size.width)/2;
        [buttons setTitleEdgeInsets:UIEdgeInsetsMake(67, -4*margin+20, 0, 0)];
        [buttons setTitle:menu.title forState:UIControlStateNormal];
        [buttons.titleLabel setFont:ZCUIFont12];
        [buttons setTitleColor:[ZCUITools zcgetTopViewTextColor] forState:UIControlStateNormal];
    }
    return buttons;
}

#pragma mark -- 表情键盘
-(void)createEmojiView{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        //添加照相机、相册视图
        CGFloat emojiViewH = EmojiViewHeight;
        if ([self getSourceViewHeight] < [self getSourceViewWidth]) {
            emojiViewH = EmojiViewHorizontalHeight;
        }
        _zc_emojiView=[[EmojiBoardView alloc] initWithBoardHeight:emojiViewH pH:[self getSourceViewHeight] pW:[self getSourceViewWidth]];
        _zc_emojiView.delegate=self;
        [_zc_sourceView addSubview:_zc_emojiView];
        
        UIView * lineView2 = [[UIView alloc]initWithFrame:CGRectMake(0, 0, [self getSourceViewWidth], 0.5)];
        lineView2.backgroundColor = [ZCUITools zcgetBackgroundBottomLineColor];
        [_zc_emojiView addSubview:lineView2];
    });
}

/**
 *  表情键盘点击
 *
 *  @param faceTag 表情
 *  @param name    表情
 *  @param itemId  第几个
 */
-(void)onEmojiItemClick:(NSString *)faceTag faceName:(NSString *)name index:(NSInteger)itemId{
//    if ([_zc_chatTextView.text isEqualToString:_zc_chatTextView.placeholder]) {
//        _zc_chatTextView.text=[NSString stringWithFormat:@"%@",name];
//    }else{
        _zc_chatTextView.text=[NSString stringWithFormat:@"%@%@",_zc_chatTextView.text,name];
//    }
    [self textChanged:_zc_chatTextView];
}

// 表情键盘执行删除
-(void)emojiAction:(EmojiBoardActionType)action{
    if(action==EmojiActionDel){
        NSString *text = _zc_chatTextView.text;
//        if ([text isEqualToString:_zc_chatTextView.placeholder]) {
//            _zc_chatTextView.text = @"";
//            [self textChanged:_zc_chatTextView];
//            return;
//        }
        NSInteger lenght=text.length;
        if(lenght>0){
            NSInteger end=-1;
            NSString *lastStr= [text substringWithRange:NSMakeRange(lenght-1, 1)];
            if([lastStr isEqualToString:@"]"]){
                NSRange range=[text rangeOfString:@"[" options:NSBackwardsSearch];
                end=range.location;
                NSString *faceStr = [text substringFromIndex:end];
                if([[[ZCUICore getUICore] allExpressionDict] objectForKey:faceStr]==nil){
                    end = lenght - 1;
                }

                text=[text substringToIndex:end];
                _zc_chatTextView.text=text;
            }else{
                [_zc_chatTextView deleteBackward];
            }
            
            
            [self textChanged:_zc_chatTextView];
        }
    }else if(action==EmojiActionSend){
        [self doSendMessage:NO];
    }
}



#pragma mark -- 更多键盘中按钮点击事件
- (void)addResourcesAction:(ZCObjButton *)btn{
    if(btn.tag == ZCKeyboardClickTypeTurnUser){
        // 执行转人工操作
        [[ZCUICore getUICore] checkUserServiceWithType:ZCTurnType_BtnClick model:nil];
    }else if(btn.tag == ZCKeyboardClickTypeSatisfaction){
        [[ZCUICore getUICore] keyboardOnClick:ZCShowStatusSatisfaction];
        // 满意度
        [[ZCUICore getUICore] keyboardOnClickSatisfacetion:NO];
    }else if(btn.tag == ZCKeyboardClickTypeAddPhotoPicture){
        // 图片
        [self getPhotoByType:1];
    }else if(btn.tag == ZCKeyboardClickTypeAddPhotoCamera){
        //  相机
        [self judgmentAuthority];
    }else if(btn.tag == ZCKeyboardClickTypeLeavePage){
        [self hideKeyboard];
        //        [self removeKeyboardObserver];
        // 去留言界面
        [self leaveMsgBtnAction:2];
    } else if(btn.tag == ZCKeyboardClickTypeAddDocumentFile){
        // 选择文件
        NSArray *arr = @[@"public.data",@"public.content",@"public.audiovisual-content",@"public.movie",@"public.audiovisual-content",@"public.video",@"public.audio",@"public.text",@"public.data",@"public.zip-archive",@"com.pkware.zip-archive",@"public.composite-content",@"public.text"];
        // 限制类型
        UIDocumentPickerViewController *docPciter = [[UIDocumentPickerViewController alloc] initWithDocumentTypes:arr inMode:UIDocumentPickerModeImport];
        // 所有类型
        //        UIDocumentPickerViewController* docPciter =  [[UIDocumentPickerViewController alloc] initWithDocumentTypes:@[@"public.data"] inMode:UIDocumentPickerModeImport];
        docPciter.delegate = self;
        if ([UIDevice currentDevice].systemVersion.floatValue >= 11.0) {
            docPciter.allowsMultipleSelection = NO;
        } else {
            // Fallback on earlier versions
        }
        

        // 处理导航栏和状态栏的透明的问题,并重写他的navc代理方法
        if (iOS7) {
            docPciter.edgesForExtendedLayout = UIRectEdgeNone;
        }
        [[self getCurrentVC] presentViewController:docPciter animated:YES completion:^{
            
        }];
        
    }else if(btn.tag == ZCKeyboardClickTypeAddLocation){
        
//        [self hideKeyboard];
        
        if([[ZCUICore getUICore] LinkClickBlock] == nil || ![ZCUICore getUICore].LinkClickBlock(@"sobot://sendlocation")){
            
#if SOBOT_OPENLOCATION
            ZCLocationController *vc = [[ZCLocationController alloc] init];
            [vc setCheckLocationBlock:^(NSDictionary * _Nonnull locations) {
                // 发送位置
                [self sendMessageOrFile:locations[@"file"] type:ZCMessageTypeLocation duration:@"" dict:locations];
            }];
            [[self getCurrentVC] presentViewController:vc animated:YES completion:^{
                
            }];
#endif
        }
        
    }else{
        ZCLibCusMenu *menu = btn.objTag;
        
        if([[ZCUICore getUICore] LinkClickBlock] == nil || ![ZCUICore getUICore].LinkClickBlock(menu.url)){
            
        }
        
    }
}

- (void)judgmentAuthority{
    AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    if(authStatus == AVAuthorizationStatusRestricted || authStatus == AVAuthorizationStatusDenied){
        dispatch_async(dispatch_get_main_queue(), ^{
            NSString *aleartMsg = @"";
            aleartMsg = ZCSTLocalString(@"请在《设置 - 隐私 - 相机》选项中，允许访问您的相机");
            [[ZCToolsCore getToolsCore] showAlert:nil message:aleartMsg cancelTitle:ZCSTLocalString(@"好的") titleArray:nil viewController:[self getCurrentVC] confirm:^(NSInteger buttonTag) {
                if(buttonTag == -1){
                    NSURL *url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
                    if ([[UIApplication sharedApplication] canOpenURL:url]) {
                       [[UIApplication sharedApplication] openURL:url];
                    }
                }
            }];
            
            
        });
    }
    //获取访问相机权限时，弹窗的点击事件获取
    [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
        if (granted) {
            
            AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeAudio];
            if(authStatus == AVAuthorizationStatusRestricted || authStatus == AVAuthorizationStatusDenied){
                dispatch_async(dispatch_get_main_queue(), ^{
                    NSString *aleartMsg = @"";
                    aleartMsg = ZCSTLocalString(@"请在《设置 - 隐私 - 麦克风》选项中，允许访问您的麦克风");

                    
                    [[ZCToolsCore getToolsCore] showAlert:nil message:aleartMsg cancelTitle:ZCSTLocalString(@"好的") titleArray:nil viewController:[self getCurrentVC] confirm:^(NSInteger buttonTag) {
                        if(buttonTag == -1){
                            NSURL *url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
                            if ([[UIApplication sharedApplication] canOpenURL:url]) {
                               [[UIApplication sharedApplication] openURL:url];
                            }
                        }
                    }];
                });
            }
            //获取访问相机权限时，弹窗的点击事件获取
            [AVCaptureDevice requestAccessForMediaType:AVMediaTypeAudio completionHandler:^(BOOL granted) {
                if (granted) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self openCamera];
                    });
                } else {
                }
            }];
        }
    }];
}


- (void)openCamera{
    __weak  ZCUIKeyboard *keyboardSelf  = self;
    ZCVideoViewController *vc = [[ZCVideoViewController alloc] init];
    vc.modalPresentationStyle = UIModalPresentationFullScreen;
    [vc setOperationResultBlock:^(id  _Nonnull item) {
        if([item isKindOfClass:[UIImage class]]){
            
            [ZCSobotCore sendImage:item withView:_zc_sourceView delegate:_ppView.window.rootViewController result:^(NSString *filePath, ZCMessageType type, NSDictionary *duration) {
                [keyboardSelf sendMessageOrFile:filePath type:ZCMessageTypePhoto duration:@""];
            }];
        }else{
            
            NSDictionary *video = (NSDictionary *)item;
            if (video == nil) {
                return ;
            }
            NSURL *videoUrl = video[@"video"];
            if (videoUrl != nil) {
                NSString *filePath = sobotConvertToString(video[@"image"]);
                NSString *videoUrlStr = videoUrl.absoluteString;
                if ([videoUrlStr hasPrefix:@"file:///"]) {
                    videoUrlStr = [videoUrlStr stringByReplacingOccurrencesOfString:@"file://" withString:@""];
                    videoUrl = [NSURL URLWithString:videoUrlStr];
                }
                [keyboardSelf sendMessageOrFile:[self URLDecodedString:videoUrl.absoluteString] type:ZCMessageTypeVideo duration:@"" dict:@{@"cover":filePath}];
            }
        }
    }];
    [[self getCurrentVC] presentViewController:vc animated:YES completion:^{
        
    }];
    
}
#pragma mark 页面点击事件 button
// 按钮事件
-(IBAction)buttonClick:(UIButton *)sender{
//    2.8.2 防止快速点击
    sender.enabled = NO;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        sender.enabled = YES;
    });
    
    [[ZCAutoListView getAutoListView] dissmiss];
    
    if(sender.tag==BUTTON_CONNECT_USER){
        // 执行转人工操作
        [[ZCUICore getUICore] checkUserServiceWithType:ZCTurnType_BtnClick model:nil];
        
        // 此处回收键盘处理UI刷新
        [self hideKeyboard];
    } else if(sender.tag==BUTTON_ADDPHOTO){
        
        [self showMoreKeyboard:BUTTON_ADDPHOTO];
        _zc_addMoreButton.tag = BUTTON_ADDMORE;
        
        // ios9 弹出层会被键盘遮挡
        [_zc_chatTextView resignFirstResponder];
    }else if(sender.tag == BUTTON_ADDFACEVIEW){
        
        [_zc_faceButton setImage:[ZCUITools zcuiGetBundleImage:@"zcicon_keyboard_normal"] forState:UIControlStateNormal];
        [_zc_faceButton setImage:[ZCUITools zcuiGetBundleImage:@"zcicon_keyboard_pressed"] forState:UIControlStateHighlighted];
        _zc_faceButton.tag = BUTTON_ToKeyboard;
        
        
        _zc_voiceButton.tag       = BUTTON_ADDVOICE;
        _zc_pressedButton.hidden = YES;
        _zc_chatTextView.hidden  = NO;
        [_zc_voiceButton setImage:[ZCUITools zcuiGetBundleImage:@"zcicon_voice_normal"] forState:UIControlStateNormal];
        [_zc_voiceButton setImage:[ZCUITools zcuiGetBundleImage:@"zcicon_voice_pressed"] forState:UIControlStateHighlighted];
        
    
        // ios9 弹出层会被键盘遮挡
        [_zc_chatTextView resignFirstResponder];
        
        
        [self showMoreKeyboard:BUTTON_ADDFACEVIEW];
    }else if(sender.tag == BUTTON_ToKeyboard){
        _zc_pressedButton.hidden = YES;
        _zc_chatTextView.hidden  = NO;
//        _zc_faceButton.hidden = NO;
        _zc_voiceButton.tag       = BUTTON_ADDVOICE;
        _zc_faceButton.tag       = BUTTON_ADDFACEVIEW;
        
        if ([self getZCLibConfig].isArtificial) {
            _zc_faceButton.hidden = NO;
        }
        
        // 切换到语音时，由于改变了_zc_bottomView的位置和大小，此处还原到以前有内容的状态
        CGRect footFrame = _zc_bottomView.frame;
        footFrame.size.height= BottomHeight +_zc_chatTextView.frame.size.height - 35;
        _zc_bottomView.frame = footFrame;
        
        [_zc_voiceButton setImage:[ZCUITools zcuiGetBundleImage:@"zcicon_voice_normal"] forState:UIControlStateNormal];
        [_zc_voiceButton setImage:[ZCUITools zcuiGetBundleImage:@"zcicon_voice_pressed"] forState:UIControlStateHighlighted];
        [_zc_faceButton setImage:[ZCUITools zcuiGetBundleImage:@"zcicon_expression_normal"] forState:UIControlStateNormal];
        [_zc_faceButton setImage:[ZCUITools zcuiGetBundleImage:@"zcicon_expression_pressed"] forState:UIControlStateHighlighted];
        [_zc_chatTextView becomeFirstResponder];
        self.vioceTipLabel.hidden = YES;
        _vioceTipBgView.hidden = YES;
        [self textChanged:_zc_chatTextView];
    }else if(sender.tag == BUTTON_ADDVOICE){
        //        2.8.2 _zc_pressedButton 高度固定
//        _zc_pressedButton.frame = _zc_chatTextView.frame;
        _zc_pressedButton.frame = CGRectMake(_zc_chatTextView.frame.origin.x, CGRectGetMaxY(_zc_chatTextView.frame) - 35, _zc_chatTextView.frame.size.width, 35);
        CGRect cf = _zc_chatTextView.frame;
        cf.size.height = 35;
        _zc_chatTextView.frame = cf;
        _zc_pressedButton.hidden = NO;
        _zc_chatTextView.hidden  = YES;
        _zc_faceButton.hidden = YES;
        // 隐藏所有键盘
        [self hideKeyboard];
        
        _zc_voiceButton.tag       = BUTTON_ToKeyboard;
        [_zc_voiceButton setImage:[ZCUITools zcuiGetBundleImage:@"zcicon_keyboard_normal"] forState:UIControlStateNormal];
        [_zc_voiceButton setImage:[ZCUITools zcuiGetBundleImage:@"zcicon_keyboard_pressed"] forState:UIControlStateHighlighted];
        
        
        _zc_faceButton.tag       = BUTTON_ADDFACEVIEW;
        [_zc_faceButton setImage:[ZCUITools zcuiGetBundleImage:@"zcicon_expression_normal"] forState:UIControlStateNormal];
        [_zc_faceButton setImage:[ZCUITools zcuiGetBundleImage:@"zcicon_expression_pressed"] forState:UIControlStateHighlighted];
        if (![self getZCLibConfig].isArtificial) {
            self.vioceTipLabel.hidden = NO;
            _vioceTipBgView.hidden = NO;
            // 当前是否是仅人工排队   2. 当前是否开启 机器人语音转文字
            if ([self getZCLibConfig].type == 2 && [ZCUICore getUICore].kitInfo.isOpenRobotVoice && curKeyBoardStatus == ZCKeyboardStatusWaiting) {
                self.zc_waitLabel.hidden = YES;
            }
        }
        
    }else if (sender.tag == BUTTON_LEAVEMESSAGE){
        // 点击底部键盘上的留言按钮不直接退出SDK
        [self hideKeyboard];
        
        [self leaveMsgBtnActionType:LeaveExitTypeISNOCOLSE];
        
    }else if (sender.tag == BUTTON_SATISFACTION){
        // 满意度
        if ([ZCUICore getUICore].delegate  && [[ZCUICore getUICore].delegate respondsToSelector:@selector(onPageStatusChanged: message: obj:)]) {
            [[ZCUICore getUICore].delegate onPageStatusChanged:ZCShowStatusSatisfaction message:@"" obj:nil];
        }
    }else if (sender.tag == BUTTON_ADDMORE){
        _zc_addMoreButton.tag = BUTTON_ADDPHOTO;
        [self hideKeyboard];
    }
}



-(ZCKeyboardViewStatus) getKeyBoardViewStatus{
    return curKeyBoardStatus;
}


-(id)initConfigView:(UIView *)unitView table:(UITableView *)listTable{
    self = [self init];
    if(self){
        _zc_sourceView      = unitView;
        _zc_listTable       = listTable;
        startTableY = listTable.frame.origin.y;
        [self zc_bottomView];
        // 顶部线条
        UIImageView *lineView=[[UIImageView alloc] initWithFrame:CGRectMake(0, 0, [self getSourceViewWidth], 0.75f)];
        lineView.backgroundColor = [ZCUITools zcgetBackgroundBottomLineColor];
        [lineView setAutoresizingMask:UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleBottomMargin];
        [_zc_bottomView addSubview:lineView];
        
        [self zc_chatTextView];
        [self zc_turnButton];
        [self zc_pressedButton];
        
        
        [self zc_voiceButton];
        
        [self zc_addMoreButton];
        
        [self zc_faceButton];
        
        /** 添加满意度的背景View */
        [self zc_sessionBgView];
        
        /** 加载动画小菊花 */
        [self zc_activityView];
        
        // 排队中
        [self zc_waitLabel];
        
        
        // 创建机器人提示语View
        [self createVioceTipLabel];
        
        [self verticalLineView];

    }
    return self;
}

-(void)setInitConfig:(ZCLibConfig *)config{
    if (config.type != 2) {
        self.zc_bottomView.hidden = NO;
    }
    if([ZCUICore getUICore].isAfterConnectUser){
        [self setKeyBoardStatus:ZCKeyboardStatusRobot];
        
        // 设置仅人工的底部输入框样式，没有更多，没有转人工
        [self setServiceModeView:1];
        return;
    }
    
    if(config.isArtificial){
        [self setKeyBoardStatus:ZCKeyboardStatusUser];
        
        return;
    }
    
    // 被拉黑，不能点击转人工,仅机器人，不是转人工，是留言 [ZCIMChat getZCIMChat].waitMessage!=nil
    if((config.isblack && config.type > 1) || [[ZCPlatformTools sharedInstance] getPlatformInfo].waitintMessage!=nil){
        if (config.type == 2) {
            if ([[ZCPlatformTools sharedInstance] getPlatformInfo].waitintMessage!=nil) {
                [self setKeyBoardStatus:ZCKeyboardStatusWaiting];
                self.zc_bottomView.hidden = NO;
            }else{
                [self setKeyBoardStatus:ZCKeyboardStatusNewSession];
            }
            
        }else{
            [self setKeyBoardStatus:ZCKeyboardStatusRobot];
        }
        return;
    }
    
    // 仅机器人模式
    if (config.type == 1) {
        
        [self setKeyBoardStatus:ZCKeyboardStatusRobot];
        [self setServiceModeView:config.type];
        
        [[ZCUICore getUICore] keyboardOnClickAddRobotHelloWolrd];
    }else if (config.type == 3) {
        // 3.智能客服-机器人优先    // && self.isShowConnectedButton == 0  isShowTurnBtn记录在会话保持的状态下是否之前显示转人工按钮（一次有效会话之内）
        
        [self setKeyBoardStatus:ZCKeyboardStatusRobot];
        [self setServiceModeView:config.type];
        
        
        // 2.9.2版本开始，如果客服发送过离线消息，直接转接到对应的客服
        // 不是仅机器人，不是黑名单用户
        if([ZCPlatformTools sharedInstance].isOfflineMsgConnect && sobotConvertToString([ZCPlatformTools sharedInstance].offlineMsgAdminId).length > 0 && !config.isblack){
            [[ZCUICore getUICore] doConnectUserService:nil connectType:ZCTurnType_OffMessageAdmin];
        }
    }else if(config.type == 2){
        [self setServiceModeView:config.type];
    }
    if(config.type==4 || config.type==2 || config.ustatus == 1 || ([ZCLibClient getZCLibClient].libInitInfo.service_mode!=1 && config.ustatus == -2)){
        // 人工优先，直接执行转人工,  ##2 仅人工   ,ustatus，说明断线后用户还在线  //仅机器人模式排队不在去执行转人工操作
        // 如果显示在线或者排队中，自动转接到人工
        if(config.ustatus == 1|| config.ustatus == -2){
            [ZCUICore getUICore].isShowForm = YES;
            [[ZCUICore getUICore] checkUserServiceWithType:ZCTurnType_InitBeConnected model:nil];
        }else{
            [[ZCUICore getUICore] checkUserServiceWithType:ZCTurnType_InitOnUserType model:nil];
        }
    }
    //
    _zc_activityView.hidden = YES;
    [_zc_activityView stopAnimating];
    
    if (_zc_turnButton.isHidden == NO && _zc_voiceButton.isHidden == NO) {
        _verticalLineView.frame = CGRectMake(CGRectGetMaxX(_zc_turnButton.frame), 12, 0.5, 26);
        _verticalLineView.hidden = NO;
    }
    
}

-(void)setServiceModeView:(int ) type{
//   如果 刘海屏向左，留出 20 的距离
    float topGap = 0;
    if (self.curScreenDirection == 2) {
        topGap = 20;
    }
    if(type == 1){
        
        _zc_chatTextView.hidden  = NO;
        _zc_turnButton.hidden  = YES;
        _zc_pressedButton.hidden = YES;
        _zc_addMoreButton.hidden   = NO;
        
        // 关闭留言，还有zc_addMoreButton其它按钮
        if ([self getZCLibConfig].msgFlag == 0) {
            // 设置textview的frame 默认值
            [_zc_chatTextView setFrame:CGRectMake(topGap + 10, (BottomHeight-35)/2, [self getSourceViewWidth]-48 - 10 - topGap, 35)];
            
            // 开启语音的功能   机器人开启语音识别
            if ([ZCUITools zcgetOpenRecord] && [ZCUICore getUICore].kitInfo.isOpenRobotVoice) {
                
                [_zc_chatTextView setFrame:CGRectMake(topGap + 48 , (BottomHeight-35)/2, [self getSourceViewWidth]-48*2 - 10 - topGap, 35)];
                _zc_chatTextView.textContainerInset =  UIEdgeInsetsMake(10, 10, 10, 10 );
                
                // 显示语音按钮
                CGRect vf = _zc_voiceButton.frame;
                vf.origin.x = 0 + topGap;
                _zc_voiceButton.frame = vf;
                
                _zc_voiceButton.hidden = NO;
            }
            
        }else{
            _zc_leaveMsgButton.hidden = YES;
            [_zc_chatTextView setFrame:CGRectMake(topGap + 10, (BottomHeight-35)/2, [self getSourceViewWidth]-58 - topGap, 35)];
            
            // 开启语音的功能   机器人开启语音识别
            if ([ZCUITools zcgetOpenRecord] && [ZCUICore getUICore].kitInfo.isOpenRobotVoice) {
                
                [_zc_chatTextView setFrame:CGRectMake(topGap + 48 , (BottomHeight-35)/2, [self getSourceViewWidth]-48*2 - 10 - topGap, 35)];
                _zc_chatTextView.textContainerInset =  UIEdgeInsetsMake(10, 10, 10, 10 );
                
                // 显示语音按钮
                CGRect vf = _zc_voiceButton.frame;
                vf.origin.x = 0 + topGap;
                _zc_voiceButton.frame = vf;
                
                _zc_voiceButton.hidden = NO;
            }
        }
        
        [self createMoreView];
        _zc_sessionBgView.hidden = YES;
        
        
    }else if(type == 2){
//           不显示转人工按钮
        // 设置textview的frame
        [_zc_chatTextView setFrame:CGRectMake(topGap + 10, (BottomHeight-35)/2, [self getSourceViewWidth]-60 - topGap, 35)];
        // 开启语音的功能   机器人开启语音识别
        if ([ZCUITools zcgetOpenRecord] && [ZCUICore getUICore].kitInfo.isOpenRobotVoice && [self getZCLibConfig].isArtificial) {
            
            [_zc_chatTextView setFrame:CGRectMake(topGap + 48 , (BottomHeight-35)/2, [self getSourceViewWidth]-48-5 - topGap, 35)];
            _zc_chatTextView.textContainerInset =  UIEdgeInsetsMake(10, 10, 10, 10 );
            // 显示语音按钮
            // 显示语音按钮
            CGRect vf = _zc_voiceButton.frame;
            vf.origin.x = 0 + topGap;
            _zc_voiceButton.frame = vf;
            
            _zc_voiceButton.hidden = NO;
        }
        
        //设置按钮显示
        _zc_turnButton.hidden    = YES;
        
        _zc_chatTextView.hidden  = NO;
        _zc_pressedButton.hidden = YES;
        _zc_addMoreButton.hidden   = NO;
        _zc_leaveMsgButton.hidden   = YES;
    }else if(type == 3){
        if (![ZCUICore getUICore].kitInfo.isShowTansfer && ![ZCLibClient getZCLibClient].isShowTurnBtn) {
//           不显示转人工按钮
            
            // 设置textview的frame
            [_zc_chatTextView setFrame:CGRectMake(topGap + 10, (BottomHeight-35)/2, [self getSourceViewWidth]-68 - topGap, 35)];
            // 开启语音的功能   机器人开启语音识别
            if ([ZCUITools zcgetOpenRecord] && [ZCUICore getUICore].kitInfo.isOpenRobotVoice) {
                
                [_zc_chatTextView setFrame:CGRectMake(topGap + 48 , (BottomHeight-35)/2, [self getSourceViewWidth]-48-5 - topGap, 35)];
                _zc_chatTextView.textContainerInset =  UIEdgeInsetsMake(10, 10, 10, 10 );
                // 显示语音按钮
                // 显示语音按钮
                CGRect vf = _zc_voiceButton.frame;
                vf.origin.x = 0 + topGap;
                _zc_voiceButton.frame = vf;
                
                _zc_voiceButton.hidden = NO;
            }
            
            //设置按钮显示
            _zc_turnButton.hidden    = YES;
            
            _zc_chatTextView.hidden  = NO;
            _zc_pressedButton.hidden = YES;
            _zc_addMoreButton.hidden   = NO;
            _zc_leaveMsgButton.hidden   = YES;
        }else{
            //           显示转人工按钮

            // 设置textview的frame
            [_zc_chatTextView setFrame:CGRectMake(topGap + 48, (BottomHeight-35)/2, [self getSourceViewWidth]-68 - topGap, 35)];
            
            // 开启语音的功能   机器人开启语音识别
            if ([ZCUITools zcgetOpenRecord] && [ZCUICore getUICore].kitInfo.isOpenRobotVoice) {
                
                [_zc_chatTextView setFrame:CGRectMake(topGap + 48+48 , (BottomHeight-35)/2, [self getSourceViewWidth]-48-5 - 48 - 48 - topGap, 35)];
                _zc_chatTextView.textContainerInset =  UIEdgeInsetsMake(10, 10, 10, 10 );
                // 显示语音按钮
                CGRect vf = _zc_voiceButton.frame;
                vf.origin.x = 48 + topGap;
                _zc_voiceButton.frame = vf;
                
                _zc_voiceButton.hidden = NO;
            }else{
                // 不开启语音的功能   机器人不开启语音识别
                [_zc_chatTextView setFrame:CGRectMake(topGap + 48 , (BottomHeight-35)/2, [self getSourceViewWidth] - 48*2 - 5 - topGap, 35)];
                _zc_chatTextView.textContainerInset =  UIEdgeInsetsMake(10, 10, 10, 10 );

                _zc_voiceButton.hidden = YES;
            }
            
            //设置按钮显示
            _zc_turnButton.hidden    = NO;
            
            _zc_chatTextView.hidden  = NO;
            _zc_pressedButton.hidden = YES;
            _zc_addMoreButton.hidden   = NO;
            _zc_leaveMsgButton.hidden   = YES;
        }
    }
}


#pragma mark -- 设置键盘样式
-(void)setKeyBoardStatus:(ZCKeyboardViewStatus)status{
    //   如果 刘海屏向左，留出 20 的距离
    float topGap = 0;
    if (self.curScreenDirection == 2) {
        topGap = 20;
    }
    // 设置键盘时设置默认状态
    _zc_faceButton.hidden     = YES;
    _zc_waitLabel.hidden      = YES;
    [_zc_activityView stopAnimating];
    _zc_addMoreButton.hidden    = YES;
    _zc_turnButton.hidden     = YES;
    _zc_pressedButton.hidden  = YES;
    _zc_chatTextView.hidden   = YES;
    _zc_sessionBgView.hidden  = YES;
    _zc_voiceButton.hidden  = YES;
    
    _verticalLineView.hidden = YES;
    
    
    curKeyBoardStatus = status;
    
    
    _zc_voiceButton.tag       = BUTTON_ADDVOICE;
    _zc_faceButton.tag       = BUTTON_ADDFACEVIEW;
    [_zc_voiceButton setImage:[ZCUITools zcuiGetBundleImage:@"zcicon_voice_normal"] forState:UIControlStateNormal];
    [_zc_voiceButton setImage:[ZCUITools zcuiGetBundleImage:@"zcicon_voice_pressed"] forState:UIControlStateHighlighted];
    [_zc_faceButton setImage:[ZCUITools zcuiGetBundleImage:@"zcicon_expression_normal"] forState:UIControlStateNormal];
    [_zc_faceButton setImage:[ZCUITools zcuiGetBundleImage:@"zcicon_expression_pressed"] forState:UIControlStateHighlighted];
    
    if(_zc_sourceView.frame.size.width == ScreenWidth){
        int direction = [[ZCToolsCore getToolsCore] getCurScreenDirection];
        CGFloat spaceX = 0;
        if(direction == 2){
            spaceX = XBottomBarHeight;
        }
        CGRect f = self.zc_bottomView.frame;
        f.origin.x = spaceX;
        self.zc_bottomView.frame = f;
    }
    
    // 如果是延迟转人工，设置键盘样式为仅机器人样式
    if([ZCUICore getUICore].isAfterConnectUser && ![self getZCLibConfig].isArtificial){
        status = ZCKeyboardStatusRobot;
    }
    
    switch (status) {
#pragma mark -- 人工 ***************************************************************************************
        case ZCKeyboardStatusUser:
            _verticalLineView.hidden = YES;
            _zc_chatTextView.hidden   = NO;
            _zc_addMoreButton.hidden  = NO;
            _vioceTipLabel.hidden = YES;
            _vioceTipBgView.hidden = YES;
            _vioceTipBgView.hidden = YES;
            // 是否显示表情按钮
            CGFloat buttonX = 48;
            if([ZCUITools allExpressionArray] && [ZCUITools allExpressionArray].count > 0){
                buttonX = 48 * 2;
                _zc_faceButton.hidden     = NO;
                _zc_chatTextView.textContainerInset = UIEdgeInsetsMake(10, 10, 10, 10 + 30);
            }
            
            CGRect tf = _zc_chatTextView.frame;
            // 是否显示语音按钮
            if([ZCUITools zcgetOpenRecord]){
                //                 设置按钮未转键盘
                _zc_voiceButton.tag = BUTTON_ADDVOICE;
                [_zc_voiceButton setImage:[ZCUITools zcuiGetBundleImage:@"zcicon_voice_normal"] forState:UIControlStateNormal];
                [_zc_voiceButton setImage:[ZCUITools zcuiGetBundleImage:@"zcicon_voice_pressed"] forState:UIControlStateHighlighted];
                _zc_voiceButton.hidden     = NO;
                tf.size.width =  [self getSourceViewWidth]-buttonX - 7 - topGap;
                tf.origin.x = 48 + topGap;
                _zc_chatTextView.frame = tf;
//                [_zc_chatTextView setFrame:CGRectMake(48, (BottomHeight-35)/2, [self getSourceViewWidth]-buttonX - 48, 35)];
                CGRect voiceF = _zc_voiceButton.frame;
                voiceF.origin.x = 0 + topGap;
                [_zc_voiceButton setFrame:voiceF];
            }else{
                _zc_voiceButton.hidden     = YES;
                
                tf.size.width  = [self getSourceViewWidth] - 48 - 15 - topGap;
                tf.origin.x = topGap + 10;
                _zc_chatTextView.frame = tf;
                
                // 仅横屏时重新设置
                if (!isPortrait) {
                    _zc_chatTextView.textContainerInset =  UIEdgeInsetsMake(10, 15, 10, 10 );
                }
//                [_zc_chatTextView setFrame:CGRectMake(10, (BottomHeight-35)/2, [self getSourceViewWidth]-buttonX, 35)];
            }
            CGRect pressF = _zc_pressedButton.frame;
            pressF.size.width  = tf.size.width;
            pressF.origin.x = tf.origin.x;
            // 重新设定 “按住 说话” 的frame
            [_zc_pressedButton setFrame:pressF];
//            _zc_faceButton.hidden = YES;
            // 从新设置更多的键盘中按钮的样式
            [self createMoreView];
            
            if ([ZCUICore getUICore].delegate && [[ZCUICore getUICore].delegate respondsToSelector:@selector(onPageStatusChanged: message: obj:)]) {
                [[ZCUICore getUICore].delegate onPageStatusChanged:ZCShowTurnRobotBtn message:@"1" obj:nil];
            }
            break;
            
        case ZCKeyboardStatusNewSession:
#pragma mark -- 新会话  ***************************************************************************************
            [self hideKeyboard];
            [_zc_chatTextView setText:@""];
            [self textChanged:_zc_chatTextView];
            // 开始新会话
            [self showStatusView];
            _zc_againAccessBtn.hidden = NO;
            _zc_sessionBgView.hidden  = NO;
            _zc_againAccessBtn.enabled = YES;// 设置新会话键盘样式时可点
            if ([ZCUICore getUICore].delegate && [[ZCUICore getUICore].delegate respondsToSelector:@selector(onPageStatusChanged: message: obj:)]) {
                [[ZCUICore getUICore].delegate onPageStatusChanged:ZCShowTurnRobotBtn message:@"1" obj:nil];
            }
            break;
        case ZCKeyboardStatusWaiting:
#pragma metk -- 排队中  ***************************************************************************************
            
            [_zc_chatTextView setText:@""];
            [self textChanged:_zc_chatTextView];
            // 排队键盘样式
            _zc_addMoreButton.hidden    = NO;
            _zc_turnButton.hidden       = NO;
            // 仅人工，不显示转人工按钮
            if([self getZCLibConfig].type == 2){
                _zc_turnButton.hidden       = YES;
                
                [_zc_chatTextView setFrame:CGRectMake(topGap + 10, (BottomHeight-35)/2, [self getSourceViewWidth]-60 - topGap, 35)];
                
                [_zc_waitLabel setFrame:CGRectMake(topGap + 10, (BottomHeight-35)/2, [self getSourceViewWidth]-60 - topGap, 35)];
                
            }
            _zc_waitLabel.hidden        = NO;
            
            if ([ZCUICore getUICore].delegate && [[ZCUICore getUICore].delegate respondsToSelector:@selector(onPageStatusChanged: message: obj:)]) {
                [[ZCUICore getUICore].delegate onPageStatusChanged:ZCShowTurnRobotBtn message:@"0" obj:nil];
            }
            break;
        case ZCKeyboardStatusRobot:
#pragma mark -- 机器人 ***************************************************************************************
            
            // 从新设置更多的键盘中按钮的样式
            [self createMoreView];
            
            // 设置textview的frame 默认值
            [_zc_chatTextView setFrame:CGRectMake(topGap + 48 * 2, (BottomHeight-35)/2, [self getSourceViewWidth]-48*3-5 - topGap, 35)];
            CGRect vf = _zc_voiceButton.frame;
            vf.origin.x = 48;
            _zc_voiceButton.frame = vf;
            _zc_voiceButton.hidden = NO;
            
//            [_zc_turnButton setImageEdgeInsets:UIEdgeInsetsMake(10.5, 15, 10.5, 5)];
            [_zc_turnButton setImageEdgeInsets:UIEdgeInsetsMake(0, 12, 0, 12)];
            _zc_chatTextView.textContainerInset = UIEdgeInsetsMake(10, 10, 10, 10 );
            // 开启语音的功能   机器人开启语音识别  TODO ![self getZCLibConfig].isOpenRobotVoice
            if (![ZCUITools zcgetOpenRecord] ||![ZCUICore getUICore].kitInfo.isOpenRobotVoice ) {
                
                [_zc_turnButton setImageEdgeInsets:UIEdgeInsetsMake(0, 12, 0, 12)];
                [_zc_chatTextView setFrame:CGRectMake(topGap + 48 , (BottomHeight-35)/2, [self getSourceViewWidth]-48*2-5 - topGap, 35)];
                // 显示语音按钮
                _zc_voiceButton.hidden = YES;
            }
            
            // 重新设定 “按住 说话” 的frame
            [_zc_pressedButton setFrame:_zc_chatTextView.frame];
            
            //设置按钮显示
//            _zc_faceButton.hidden = YES;
            _zc_turnButton.hidden     = NO;
            _zc_chatTextView.hidden   = NO;
            _zc_addMoreButton.hidden    = NO;
            
            // 这里还需要考虑 转人工排队时，设置了未知回复次数并且不显示转人工按钮的场景下，继续保持不显示转人工按钮的键盘样式
            [self setServiceModeView:3];
            
            
            if ([ZCUICore getUICore].delegate && [[ZCUICore getUICore].delegate respondsToSelector:@selector(onPageStatusChanged: message: obj:)]) {
                [[ZCUICore getUICore].delegate onPageStatusChanged:ZCShowTurnRobotBtn message:@"0" obj:nil];
            }
            
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.35 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                // 当新会话按钮出现的时候 键盘回收
                [self hideKeyboard];

                if (_zc_turnButton.isHidden == NO && _zc_voiceButton.isHidden == NO) {
                    _verticalLineView.hidden = NO;
                    _verticalLineView.frame = CGRectMake(CGRectGetMaxX(_zc_turnButton.frame), 12, 1, 26);
                    
                }
            });

            break;
    }
    // 如果是延迟转人工，设置键盘样式为仅机器人样式
    if([ZCUICore getUICore].isAfterConnectUser && ![self getZCLibConfig].isArtificial){
        if([self getZCLibConfig].type == 2){
            [self setServiceModeView:2];
        }
    }
    [self setKeyboardRTLFrame];
    
}

-(void)setKeyboardRTLFrame{
    if(sobotIsRTLLayout()){
        if(!self.zc_faceButton.isHidden){
            _zc_chatTextView.textContainerInset = UIEdgeInsetsMake(10, 10+30, 10, 10);
        }else{
            _zc_chatTextView.textContainerInset = UIEdgeInsetsMake(10, 10, 10, 10);
        }
        if(CGRectGetMaxX(self.zc_addMoreButton.frame) > ScreenWidth/2){
            [self.zc_chatTextView setTextAlignment:NSTextAlignmentRight];
            [[ZCToolsCore getToolsCore] setRTLFrame:self.zc_faceButton];
            [[ZCToolsCore getToolsCore] setRTLFrame:self.zc_waitLabel];
            [[ZCToolsCore getToolsCore] setRTLFrame:self.zc_turnButton];
            [[ZCToolsCore getToolsCore] setRTLFrame:self.zc_addMoreButton];
            [[ZCToolsCore getToolsCore] setRTLFrame:self.zc_pressedButton];
            [[ZCToolsCore getToolsCore] setRTLFrame:self.zc_activityView];
            [[ZCToolsCore getToolsCore] setRTLFrame:self.zc_chatTextView];
        }
        
        if(CGRectGetMaxX(self.zc_voiceButton.frame) < ScreenWidth/2){
            [[ZCToolsCore getToolsCore] setRTLFrame:self.zc_voiceButton];
            [[ZCToolsCore getToolsCore] setRTLFrame:self.zc_sessionBgView];
            
        }
    }
}

-(void)setZCChatNavHeight:(CGFloat)height{
    navHeight = height;
}

-(void)setTableStartY:(CGFloat ) height{
    startTableY = height;
}

-(ZCPlatformInfo *) getPlatformInfo{
    return [[ZCPlatformTools sharedInstance] getPlatformInfo];
}


#pragma mark 发送监听 UITextViewDelegate
- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    
    if ([@"\n" isEqualToString:text] == YES)
    {
        //        [textView resignFirstResponder];
        
        [self doSendMessage:NO];
        return NO;
    }
    
    //    [SobotLog logDebug:@"%@",[[UITextInputMode currentInputMode]primaryLanguage]];
    // 不输入Emoji
    if ([[[UIApplication sharedApplication]textInputMode].primaryLanguage isEqualToString:@"emoji"]) {
        return NO;
    }
    
    
    if([text length]==0){
        if(range.length<1){
            return YES;
        }else{
            
            [self textChanged:_zc_chatTextView];
        }
    }else{
        // 大于1000不让继续输入
        if([textView.text length] >= 1000){
            return NO;
        }
    }
    return YES;
}

#pragma mark textChanged
-(void)textChanged:(id) sender{
    [self textViewDidChange:_zc_chatTextView];
    
}

//
-(void)textViewDidBeginEditing:(UITextView *)textView{
    if(![textView.window isKeyWindow]){
        [textView.window makeKeyAndVisible];
    }
    //    WSLog(@"键盘开始输入=====");
    
    // 当textview开始编辑的时候 影藏 _phototView
    [UIView animateWithDuration:0.25 animations:^{
        
    } completion:^(BOOL finished) {
        CGFloat moreHeight = MoreViewHeight;
        CGFloat emojiViewHeight = EmojiViewHeight;
        if ([self getSourceViewHeight] < [self getSourceViewWidth]) {
            moreHeight = MoreViewHorizontalHeight;
            emojiViewHeight = EmojiViewHorizontalHeight;
        }
        // 恢复原始值
        _zc_moreView.frame = CGRectMake(0, [self getSourceViewHeight], [self getSourceViewWidth], moreHeight);
        _zc_emojiView.frame = CGRectMake(0, [self getSourceViewHeight], [self getSourceViewWidth], emojiViewHeight);
        
        
        [self addAutoListView];
        
    }];
    _zc_addMoreButton.tag = BUTTON_ADDPHOTO;
    _zc_faceButton.tag  = BUTTON_ADDFACEVIEW;
}

-(void)addAutoListView{
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"isEnableAutoTips"] && ![self getZCLibConfig].isArtificial) {
        __block ZCUIKeyboard *safeSelf = self;
        [ZCAutoListView getAutoListView].delegate = self;
        [[ZCAutoListView getAutoListView] showWithText:_zc_chatTextView.text  view:_zc_bottomView];
    }
}
-(void)autoViewCellItemClick:(NSString *)text{
    [self sendMessageOrFile:text type:ZCMessageTypeText duration:@""];
    [self.zc_chatTextView setText:@""];
    [self textChanged:_zc_chatTextView];
}

-(void)textViewDidChange:(UITextView *)textView{
    
    CGFloat textContentSizeHeight = _zc_chatTextView.contentSize.height;
    if (iOS7) {
        CGRect textFrame = [[_zc_chatTextView layoutManager]usedRectForTextContainer:[_zc_chatTextView textContainer]];
        textContentSizeHeight = textFrame.size.height;
        textContentSizeHeight = textContentSizeHeight + 10;
    }
    //发送完成重置
    if(_zc_chatTextView.text==nil || [@"" isEqual:_zc_chatTextView.text]){
        textContentSizeHeight=35;
        [_zc_chatTextView setContentOffset:CGPointMake(0, 0)];
    }
    
    // 判断文字过小
    if(textContentSizeHeight<35){
        textContentSizeHeight=35;
    }
    
    [self addAutoListView];
    
    // 已经最大行高了
    if (textContentSizeHeight > [self getTextMaxHeiht] && _zc_chatTextView.frame.size.height >= [self getTextMaxHeiht]) {
        [_zc_chatTextView setContentOffset:CGPointMake(0, textContentSizeHeight-_zc_chatTextView.frame.size.height)];
        return;
    }
    
    
    CGRect textFrame = _zc_chatTextView.frame;
    
    
    
    CGRect footFrame = _zc_bottomView.frame;
    footFrame.origin.y = [self getSourceViewHeight] - _zc_keyBoardHeight -(_zc_bottomView.frame.size.height - BottomHeight);
    footFrame.size.height = BottomHeight;
    CGFloat lastHeight = textFrame.size.height;
    textFrame.size.height = 35;
    
    // 计算应该改变多少行高
    if(textContentSizeHeight>35){
        float x=textContentSizeHeight-35;
        if(textContentSizeHeight>[self getTextMaxHeiht]){
            x = [self getTextMaxHeiht] - 35;
        }
        
        footFrame.size.height=footFrame.size.height+x;
        textFrame.size.height = textFrame.size.height+x;
    }
    
    // 已经更改过了
    if(lastHeight == textFrame.size.height){
        return;
    }
    
    // 此处不需要关心XBottomBarHeight，因为bottomView在ChatView上，ChatView已经处理了高度
    footFrame.origin.y       = [self getSourceViewHeight] - footFrame.size.height - _zc_keyBoardHeight + XBottomBarHeight;
    // 必须是animated YES
    [_zc_chatTextView setContentOffset:CGPointMake(0,textContentSizeHeight-textFrame.size.height) animated:YES];
    
    [UIView animateWithDuration:0.25 animations:^{
        
        _zc_bottomView.frame = footFrame;
        _zc_chatTextView.frame = textFrame;
        
        [self showTableFrameByKeyboardChanged];
        
        [[ZCUICore getUICore] keyboardOnClick:ZCShowTextHeightChanged];
        
        
    }];
}

-(int)getTextLines{
    CGSize lineSize = [_zc_chatTextView.text sizeWithFont:_zc_chatTextView.font];
    return ceil(_zc_chatTextView.contentSize.height/lineSize.height);
}

-(CGFloat) getTextMaxHeiht{
    CGSize lineSize = [_zc_chatTextView.text sizeWithFont:_zc_chatTextView.font];
    return lineSize.height*6+12;
}

-(CGFloat) getKeyboardHeight{
    return _zc_keyBoardHeight;
}

#pragma mark 手势代理 冲突的问题
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch{
    if ([NSStringFromClass([touch.view superclass]) isEqualToString:@"UIResponder"]) {
        return NO;
    }
    if ([NSStringFromClass([touch.view class]) isEqualToString:@"ZCMLEmojiLabel"]) {
        [self performSelector:@selector(hideKeyboard) withObject:nil afterDelay:0.35];
        return NO;
    }
    
    return YES;
}


-(void)removeKeyboardObserver{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillChangeFrameNotification object:nil];
}

-(CGFloat) getSourceViewHeight{
    return _zc_sourceView.frame.size.height;
}

-(CGFloat) getSourceViewWidth{
    // 横屏时，修改底部宽度
    int direction = [[ZCToolsCore getToolsCore] getCurScreenDirection];
    // iphoneX 横屏需要单独处理
    if(direction > 0){
        return _zc_sourceView.frame.size.width - XBottomBarHeight;
    }
    return _zc_sourceView.frame.size.width;
}


-(void)keyboardFrameDidChange:(NSNotification*)notice{
//    NSDictionary * userInfo = notice.userInfo;
//    NSValue * endFrameValue = [userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];
    //    CGRect endFrame = endFrameValue.CGRectValue;
    //    NSLog(@"%@",NSStringFromCGRect(endFrame));
}

#pragma mark 键盘隐藏 keyboard notification
-(void)hideKeyboard{
    _zc_addMoreButton.tag = BUTTON_ADDPHOTO;
    
    _facePageControl.hidden = YES;
    
    
    //    [_zc_listTable removeGestureRecognizer:tapRecognizer];
    [UIView animateWithDuration:0.25 animations:^{
        [_zc_chatTextView resignFirstResponder];
        
        _zc_keyBoardHeight = 0;
       
        
        CGRect pf         = _zc_moreView.frame;
        pf.origin.y       = [self getSourceViewHeight];
        _zc_moreView.frame  = pf;
        
        CGRect ff         = _zc_emojiView.frame;
        ff.origin.y       = [self getSourceViewHeight];
        _zc_emojiView.frame  = ff;
        
        CGRect bf         = _zc_bottomView.frame;
        CGFloat botttomHight = 0;
        if(curKeyBoardStatus == ZCKeyboardStatusNewSession ){
            bf.size.height = ZCConnectBottomHeight;
        }
        
        if(curKeyBoardStatus != ZCKeyboardStatusNewSession  && _zc_chatTextView.frame.size.height <= 40){
            bf.size.height = BottomHeight;
        }
        // 如果是语音模式，需要设置高度为原始高度
        if(!_zc_pressedButton.hidden && _zc_chatTextView.hidden){
                bf.size.height = BottomHeight;
        }
        bf.origin.y       = [self getSourceViewHeight]-bf.size.height- (iOS7?0:20)  - botttomHight;
        _zc_bottomView.frame = bf;
        // TODO:  暂时修改 
        CGRect tf         = _zc_listTable.frame;
        if(curKeyBoardStatus != ZCKeyboardStatusNewSession ){
            tf.origin.y = startTableY - (_zc_bottomView.frame.size.height-BottomHeight);
        }else{
            tf.origin.y = startTableY;
        }
        _zc_listTable.frame  = tf;
//        NSLog(@"startTableY === %lf  frame ===== %@    _zc_bottomView.frame.size.height === %f   BottomHeight =====%d" ,startTableY,NSStringFromCGRect(_zc_listTable.frame) ,_zc_bottomView.frame.size.height ,BottomHeight);
        if (!_vioceTipLabel.hidden) {
//            CGRect TF = _vioceTipLabel.frame;
//            TF.origin.y =  _zc_bottomView.frame.origin.y - _vioceTipLabel.frame.size.height;
//            _vioceTipLabel.frame = TF;
            
            CGRect TF = _vioceTipBgView.frame;
            TF.origin.y =  _zc_bottomView.frame.origin.y - _vioceTipBgView.frame.size.height;
            _vioceTipBgView.frame = TF;
            
        }
        
        
        [[ZCAutoListView getAutoListView] dissmiss];
        
        if ([ZCUICore getUICore].delegate && [[ZCUICore getUICore].delegate respondsToSelector:@selector(onPageStatusChanged: message: obj:)]) {
            [[ZCUICore getUICore].delegate onPageStatusChanged:ZCTurnRobotFramChange message:@"" obj:nil];
        }
    }];
    
    
    
}

- (void)handleKeyboard {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    // 横屏需要添加 keyboardFrameDidChange监听
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardFrameDidChange:) name:UIKeyboardWillChangeFrameNotification object:nil];
    tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTapAnywhere:)];
    
    tapRecognizer.delegate  =self;
    _zc_sourceView.userInteractionEnabled=YES;
}

#pragma mark -  //键盘显示
- (void)keyboardWillShow:(NSNotification *)notification {
    float animationDuration = [[[notification userInfo] valueForKey:UIKeyboardAnimationDurationUserInfoKey] floatValue];
    
    _zc_keyBoardHeight = [[[notification userInfo] objectForKey:@"UIKeyboardBoundsUserInfoKey"] CGRectValue].size.height;
    
    if(!_zc_chatTextView.isFirstResponder){
        return ;
    }
    
    // 还原表情和更多按钮样式
    if ([self getZCLibConfig].isArtificial || [ZCUICore getUICore].isAfterConnectUser) {
        _zc_voiceButton.tag       = BUTTON_ADDVOICE;
        _zc_faceButton.tag       = BUTTON_ADDFACEVIEW;
        [_zc_voiceButton setImage:[ZCUITools zcuiGetBundleImage:@"zcicon_voice_normal"] forState:UIControlStateNormal];
        [_zc_voiceButton setImage:[ZCUITools zcuiGetBundleImage:@"zcicon_voice_pressed"] forState:UIControlStateHighlighted];
        [_zc_faceButton setImage:[ZCUITools zcuiGetBundleImage:@"zcicon_expression_normal"] forState:UIControlStateNormal];
        [_zc_faceButton setImage:[ZCUITools zcuiGetBundleImage:@"zcicon_expression_pressed"] forState:UIControlStateHighlighted];
    }
    
    
    NSNumber *curve = [notification.userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey];
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:animationDuration];
    [UIView setAnimationCurve:[curve intValue]];
    [UIView setAnimationDelegate:self];
    // get a rect for the view frame
    
    {
        
        [self showTableFrameByKeyboardChanged];
        
        if ([ZCUICore getUICore].delegate && [[ZCUICore getUICore].delegate respondsToSelector:@selector(onPageStatusChanged: message: obj:)]) {
            [[ZCUICore getUICore].delegate onPageStatusChanged:ZCTurnRobotFramChange message:@"" obj:nil];
        }
    }
    // commit animations
    [UIView commitAnimations];
    
    [_zc_listTable addGestureRecognizer:tapRecognizer];
    
    // 滚动到底部，如果不需要，可以不执行
    if (_scrollTableToBottomBlock) {
//        _scrollTableToBottomBlock();
    }
    
}

-(void)showTableFrameByKeyboardChanged{
    CGFloat bh         = _zc_bottomView.frame.size.height;
    CGRect tf          = _zc_listTable.frame;
    
    CGFloat xbottomh = XBottomBarHeight;// (isLandspace?12:XBottomBarHeight);
    CGFloat x = _zc_listTable.contentSize.height - tf.size.height;
    // 根据控件的位置，判断键盘的高度，说明控件不是全屏的，不一定要上提那么多
    if(x > 0){
        tf.origin.y   = startTableY - _zc_keyBoardHeight - (bh-BottomHeight) + xbottomh;
    }else{
        // 如果剩余空间大于键盘高度，就不用移动table坐标
        if((tf.size.height - _zc_listTable.contentSize.height ) > ([self getKeyboardHeight] + (self.zc_bottomView.frame.size.height-BottomHeight))){
            tf.origin.y   = startTableY;
        }else{
            // 这里要处理一个特殊情况 使用自定义导航的时候 需要考虑 导航栏的高度
            CGFloat navh = 0;
            if ([ZCUICore getUICore].kitInfo.navcBarHidden) {
                navh = NavBarHeight;
            }
            // 移动剩余空间不够的坐标
            tf.origin.y   = startTableY - ([self getKeyboardHeight] - (tf.size.height - _zc_listTable.contentSize.height)) + XBottomBarHeight + (self.zc_bottomView.frame.size.height - BottomHeight) -navh;
        }

    }
    
    _zc_listTable.frame  = tf;
    if(x>0 && !isLandspace){
//            if([ZCUICore getUICore].kitInfo.navcBarHidden){
            [_zc_listTable setContentOffset:CGPointMake(0, x) animated:NO];
//            }
    }
    
    
    CGRect bf         = _zc_bottomView.frame;
    
    bf.origin.y       = [self getSourceViewHeight] - bh - _zc_keyBoardHeight + xbottomh;
    
    
    bf.size.height    = bh;
    _zc_bottomView.frame = bf;
    
    
    // 2.8.5版本移到此处，以前写在键盘隐藏处，不符合逻辑
    [self addAutoListView];
}

//屏幕点击事件
- (void)didTapAnywhere:(UITapGestureRecognizer *)recognizer {
    [self hideKeyboard];
}


//键盘隐藏
- (void)keyboardWillHide:(NSNotification *)notification {
    if(_zc_keyBoardHeight == 0){
        return;
    }
    
    float animationDuration = [[[notification userInfo] valueForKey:UIKeyboardAnimationDurationUserInfoKey] floatValue];
    
    [UIView beginAnimations:@"bottomBarDown" context:nil];
    [UIView setAnimationDuration:animationDuration];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
    
    [[ZCAutoListView getAutoListView] dissmiss];
    
    _zc_keyBoardHeight = 0;
   
    [UIView commitAnimations];
    
       if(!_zc_chatTextView.isFirstResponder){
           return ;
       }
    [UIView animateWithDuration:0.25 animations:^{
        if(_zc_addMoreButton.tag != BUTTON_ADDMORE && _zc_faceButton.tag != BUTTON_ToKeyboard){
            CGRect tf         = _zc_listTable.frame;
            tf.origin.y       = startTableY-(_zc_bottomView.frame.size.height-BottomHeight);
            _zc_listTable.frame  = tf;
            
            CGRect bf         = _zc_bottomView.frame;
            bf.origin.y       = CGRectGetMaxY(_zc_sourceView.frame) - bf.size.height;
            _zc_bottomView.frame = bf;
        }
        
        if ([ZCUICore getUICore].delegate && [[ZCUICore getUICore].delegate respondsToSelector:@selector(onPageStatusChanged: message: obj:)]) {
            [[ZCUICore getUICore].delegate onPageStatusChanged:ZCTurnRobotFramChange message:@"" obj:nil];
        }
    }];
    
    //    [_zc_listTable removeGestureRecognizer:tapRecognizer];
}


#pragma mark 发送图片相关
/**
 *  选择获取图片方式代理
 *
 *  @param buttonIndex 选择的index
 *  @param tag         当前的控件tag
 */
-(void)didClickOnButtonIndex:(NSInteger)buttonIndex tag:(NSInteger)tag{
    [self getPhotoByType:buttonIndex];
}

// 系统选择图片代理
-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    [self getPhotoByType:buttonIndex];
}

/**
 *  根据类型获取图片
 *
 *  @param buttonIndex 2，来源照相机，1来源相册
 */
-(void)getPhotoByType:(NSInteger) buttonIndex{
    _zc_imagepicker = nil;
    _zc_imagepicker = [[UIImagePickerController alloc]init];
    _zc_imagepicker.delegate = self;
//    _zc_imagepicker.modalPresentationStyle = UIModalPresentationFullScreen;
    if (![ZCUICore getUICore].kitInfo.imagepickerStyleUnFull) {
            _zc_imagepicker.modalPresentationStyle = UIModalPresentationFullScreen;
        }
    _zc_imagepicker.mediaTypes = [NSArray arrayWithObjects:@"public.movie", @"public.image", nil];
    _zc_imagepicker.view.backgroundColor = UIColorFromThemeColor(ZCBgSystemWhiteColor);
    [ZCSobotCore getPhotoByType:buttonIndex byUIImagePickerController:_zc_imagepicker Delegate:[self getCurrentVC]];
}
#pragma mark UIImagePickerControllerDelegate
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker{
    [picker dismissViewControllerAnimated:YES completion:^{
        
    }];
}

-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    __weak  ZCUIKeyboard *keyboardSelf  = self;
    [ZCSobotCore imagePickerController:_zc_imagepicker didFinishPickingMediaWithInfo:info WithView:_zc_sourceView Delegate:_ppView.window.rootViewController block:^(NSString *filePath, ZCMessageType type, NSDictionary *dict) {
        if(type == ZCMessageTypePhoto){
//            NSLog(@"准备上传图片 文件路径： %@",filePath);
            [keyboardSelf sendMessageOrFile:filePath type:type duration:@""];
        }else{
            [keyboardSelf converToMp4:dict];
            
        }
    }];
}

-(void) converToMp4:(NSDictionary *) dict{
    
    NSURL *videoUrl = dict[@"video"];
    NSString *filePath = dict[@"image"];
    
    AVURLAsset *avAsset = [AVURLAsset URLAssetWithURL:videoUrl options:nil];
    
    //    NSArray *compatiblePresets = [AVAssetExportSession exportPresetsCompatibleWithAsset:avAsset];
    
    [[ZCUIToastTools shareToast] showToast:ZCSTLocalString(@"视频处理中，请稍候!") duration:1.0 view:_zc_sourceView.window.rootViewController.view  position:ZCToastPositionCenter];
    
    __weak  ZCUIKeyboard *keyboardSelf  = self;
    AVAssetExportSession *exportSession = [[AVAssetExportSession alloc] initWithAsset:avAsset presetName:AVAssetExportPresetMediumQuality];
    
    //    NSDateFormatter *formater = [[NSDateFormatter alloc] init];//用时间给文件全名，以免重复
    //    [formater setDateFormat:@"yyyy-MM-dd-HH:mm:ss"];
    
    NSString * fname = [NSString stringWithFormat:@"/sobot/output-%ld.mp4",(long)[NSDate date].timeIntervalSince1970];
    sobotCheckPathAndCreate(sobotGetDocumentsFilePath(@"/sobot/"));
    NSString *resultPath=sobotGetDocumentsFilePath(fname);
    //    NSLog(@"resultPath = %@",resultPath);
    exportSession.outputURL = [NSURL fileURLWithPath:resultPath];
    exportSession.outputFileType = AVFileTypeMPEG4;
    exportSession.shouldOptimizeForNetworkUse = YES;
    [exportSession exportAsynchronouslyWithCompletionHandler:^(void)
     {
         switch (exportSession.status) {
             case AVAssetExportSessionStatusCompleted:{
                 //                 NSLog(@"AVAssetExportSessionStatusCompleted%@",[NSThread currentThread]);
                 // 主队列回调
                 dispatch_async(dispatch_get_main_queue(), ^{
                     [keyboardSelf sendMessageOrFile:[self URLDecodedString:resultPath] type:ZCMessageTypeVideo duration:@"" dict:@{@"cover":filePath}];
                 });
             }
                 break;
             case AVAssetExportSessionStatusUnknown:
                 //                 NSLog(@"AVAssetExportSessionStatusUnknown");
                 break;
                 
             case AVAssetExportSessionStatusWaiting:
                 
                 //                 NSLog(@"AVAssetExportSessionStatusWaiting");
                 
                 break;
                 
             case AVAssetExportSessionStatusExporting:
                 
                 //                 NSLog(@"AVAssetExportSessionStatusExporting");
                 
                 break;
             case AVAssetExportSessionStatusFailed:
                 
                 //                 NSLog(@"AVAssetExportSessionStatusFailed");
                 
                 break;
             case AVAssetExportSessionStatusCancelled:
                 
                 break;
         }
     }];
}



// 解决ios7调用系统的相册时出现的导航栏透明的情况
- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated{
    if ([navigationController isKindOfClass:[UIImagePickerController class]]) {
        viewController.navigationController.navigationBar.translucent = NO;
        viewController.edgesForExtendedLayout = UIRectEdgeNone;
    }
}



#pragma mark 选择文件
- (void)documentPickerWasCancelled:(UIDocumentPickerViewController *)controller{
    
}

- (void)documentPicker:(UIDocumentPickerViewController *)controller didPickDocumentAtURL:(NSURL *)url{
//    NSString *filePath = url.absoluteString;
//    [SobotLog logDebug:@"%@",filePath];
}
- (void)documentPicker:(UIDocumentPickerViewController *)controller didPickDocumentsAtURLs:(NSArray<NSURL *> *)urls{
    if(urls.count > 0){
        NSURL *url = urls[0];
        //        NSString *mate = [self mimeWithString:url];
        //
        NSString *urlStr = url.absoluteString;
        if ([urlStr hasPrefix:@"file:///"]) {
            urlStr = [urlStr stringByReplacingOccurrencesOfString:@"file://" withString:@""];
        }
        url = [NSURL URLWithString:urlStr];
        [SobotLog logHeader:SobotLogHeader info:@"%@\n%@\n",url.absoluteString,[self URLDecodedString:url.absoluteString]];
        
        //        [self hideKeyboard];
        //获取文件的大小 不能大于50M
        
        NSURL *Kurl = [NSURL URLWithString:sobotUrlEncodedString(url.absoluteString)];
        NSURLRequest *request = [NSURLRequest requestWithURL:Kurl];
        
        // 只有响应头中才有其真实属性 也就是MIME
        NSURLResponse *response = nil;
        NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:nil];
        
        NSString * size =  [NSString stringWithFormat:@"%.2f",data.length*1.0/1024];
        if ([size intValue] > 1024*50) {
            // 弹提示
            [[ZCUIToastTools shareToast] showToast:ZCSTLocalString(@"不能上传50M以上的文件") duration:2.0f view:_zc_sourceView position:ZCToastPositionCenter];
            return;
        }
        
        // 先回收键盘
        [self sendMessageOrFile:[self URLDecodedString:url.absoluteString] type:ZCMessageTypeFile duration:@""];
    }
}

- (NSString *)URLDecodedString:(NSString *) url
{
    NSString *result = [(NSString *)url stringByReplacingOccurrencesOfString:@"+" withString:@" "];
    return [result stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
}

//- (NSString *)mimeWithString:(NSURL *)url
//{
//    // 先从参入的路径的出URL
//    NSURLRequest *request = [NSURLRequest requestWithURL:url];
////    NSURL *testURL = [NSURL URLWithString:url.absoluteString relativeToURL:url.absoluteURL];
//
//    // 只有响应头中才有其真实属性 也就是MIME
//    NSURLResponse *response = nil;
//    NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:nil];
//
//    return response.MIMEType;
//} b olp;9.7070000000000iuikjjjjjjjjjjjokklo0- /


#pragma 录音相关事件触发
-(void)btnTouchDown:(id)sender{
    [SobotLog logDebug:@"按下了"];
    
    // 这里要处理 在录音前关闭上一个还没有播放完的录音消息，以免造成录音是空的没有声音的问题
    [[NSNotificationCenter defaultCenter] postNotificationName:@"ZCSDKSTOPPLAY" object:nil];
    
     AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeAudio];
    
     if(authStatus == AVAuthorizationStatusRestricted || authStatus == AVAuthorizationStatusDenied){
         
         dispatch_async(dispatch_get_main_queue(), ^{
             NSString *aleartMsg = @"";
             aleartMsg = ZCSTLocalString(@"请在《设置 - 隐私 - 麦克风》选项中，允许访问您的麦克风");
             
             [[ZCToolsCore getToolsCore] showAlert:nil message:aleartMsg cancelTitle:ZCSTLocalString(@"好的") titleArray:nil viewController:[self getCurrentVC] confirm:^(NSInteger buttonTag) {
                 if(buttonTag == -1){
                     NSURL *url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
                     if ([[UIApplication sharedApplication] canOpenURL:url]) {
                        [[UIApplication sharedApplication] openURL:url];
                     }
                 }
             }];
         });
         return;
     }
    
    
    if(_zc_recordView!=nil){
        return;
    }
    if(_zc_recordView==nil){
        _zc_recordView=[[ZCUIRecordView alloc] initRecordView:self cView:_zc_sourceView];
        [_zc_recordView showInView:_zc_sourceView];
    }
    
    [_zc_recordView didChangeState:RecordStart];
    
    [_zc_pressedButton setBackgroundColor:UIColorFromThemeColor(ZCTextPlaceHolderColor)];
    [_zc_pressedButton setTitle:ZCSTLocalString(@"松开 发送") forState:UIControlStateNormal];
    [_zc_pressedButton.layer setBorderWidth:0.0f];
    
    _zc_voiceButton.enabled=NO;
    _zc_addMoreButton.enabled=NO;
    _zc_faceButton.enabled = NO;
    
}
-(void)btnTouchDownRepeat:(id)sender{
    
    [SobotLog logDebug:@"按下了,重复了"];
}
-(void)btnTouchMoved:(UIButton *)sender withEvent:(UIEvent *)event {
    UITouch *touch = [[event allTouches] anyObject];
    CGFloat boundsExtension = 5.0f;
    CGRect outerBounds = CGRectInset(sender.bounds, -1 * boundsExtension, -1 * boundsExtension);
    BOOL touchOutside = !CGRectContainsPoint(outerBounds, [touch locationInView:sender]);
    if (touchOutside) {
        BOOL previewTouchInside = CGRectContainsPoint(outerBounds, [touch previousLocationInView:sender]);
        if (previewTouchInside) {
            // UIControlEventTouchDragExit
            
            [SobotLog logDebug:@"拖出了"];
            
            // 暂停，抬起就取消
            [_zc_recordView didChangeState:RecordPause];
//            [_zc_pressedButton setBackgroundImage:nil forState:UIControlStateNormal];
            [_zc_pressedButton setBackgroundColor:UIColorFromThemeColor(ZCTextPlaceHolderColor)];

            [_zc_pressedButton setTitle:ZCSTLocalString(@"松开手指，取消发送") forState:UIControlStateNormal];
        } else {
            // UIControlEventTouchDragOutside
            
        }
    } else {
        BOOL previewTouchOutside = !CGRectContainsPoint(outerBounds, [touch previousLocationInView:sender]);
        if (previewTouchOutside) {
            // UIControlEventTouchDragEnter
            
            [SobotLog logDebug:@"拖入"];
            
            // 接着录音
            [_zc_recordView didChangeState:RecordStart];
            
            [_zc_pressedButton setBackgroundColor:UIColorFromThemeColor(ZCTextPlaceHolderColor)];
            [_zc_pressedButton setTitle:ZCSTLocalString(@"松开 发送") forState:UIControlStateNormal];
        } else {
            // UIControlEventTouchDragInside
        }
    }
}


-(void)btnTouchCancel:(UIButton *)sender{
    
    [SobotLog logDebug:@"取消"];
    if(_zc_recordView){
        // 取消发送
        [_zc_recordView didChangeState:RecordCancel];
        
        //停止录音
        [self closeRecord:sender];
    }
    
}
-(void)btnTouchEnd:(UIButton *)sender withEvent:(UIEvent *)event{
//    NSLog(@"RecordCancel%@",event);
    UITouch *touch = [[event allTouches] anyObject];
    CGFloat boundsExtension = 5.0f;
    CGRect outerBounds = CGRectInset(sender.bounds, -1 * boundsExtension, -1 * boundsExtension);
    BOOL touchOutside = !CGRectContainsPoint(outerBounds, [touch locationInView:sender]);
    int duration = (int)_zc_recordView.currentTime;
//    NSLog(@"手势事件之后 触发的 时间时长：%d",duration);
    // 这里还要看是不是闪烁的空cell 如果是才走，如果不是 是录制完成达到上限60秒，是不能走RecordCancel的代理事件的
//    if (duration < 1 || touchOutside) {
//        // UIControlEventTouchUpOutside
//        [SobotLog logDebug:@"取消ccc"];
//        if(_zc_recordView){
//            if (duration < 1 && [[ZCUICore getUICore] getRecordModel]) { // 先显示时间过短 秒点秒松开状态下
//                [_zc_recordView didChangeState:RecordComplete];
//                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//                    // 取消发送
//                    [_zc_recordView didChangeState:RecordCancel];
//#pragma mark - 这里加延迟是为了 增加弹窗 “录音时间过短” 的显示时间， closeRecord 方法会销毁掉弹窗
//                    [self closeRecord:sender];
//                });
//            }else{
//                // 取消发送
//                if (touchOutside) {
//                    [_zc_recordView didChangeState:RecordCancel];
//                    [self closeRecord:sender];
//                }
//            }
//        }
//        // 这里处理异常情况下 录音按钮没有恢复默认状态的场景 （秒点录音按钮之后秒松开）
//        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//            _zc_voiceButton.enabled = YES;
//            _zc_addMoreButton.enabled = YES;
//            _zc_faceButton.enabled = YES;
//            [_zc_pressedButton setTitle:ZCSTLocalString(@"按住 说话") forState:UIControlStateNormal];
//        });
//    } else {
//        // UIControlEventTouchUpInside
//        [SobotLog logDebug:@"结束了"];
//
//        // 发送
//        [_zc_recordView didChangeState:RecordComplete];
//        [self closeRecord:sender];
//    }
    
    
    if (touchOutside) {
        // UIControlEventTouchUpOutside
        [SobotLog logDebug:@"取消ccc"];
        
        if(_zc_recordView){
            // 取消发送
            [_zc_recordView didChangeState:RecordCancel];
            [self closeRecord:sender];
        }
    } else {
        // UIControlEventTouchUpInside
        [SobotLog logDebug:@"结束了"];
        
        if (duration < 1 && [[ZCUICore getUICore] getRecordModel]) { // 先显示时间过短 秒点秒松开状态下
            [_zc_recordView didChangeState:RecordComplete];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                // 取消发送
                [_zc_recordView didChangeState:RecordCancel];
#pragma mark - 这里加延迟是为了 增加弹窗 “录音时间过短” 的显示时间， closeRecord 方法会销毁掉弹窗
                [self closeRecord:sender];
            });
            // 这里处理异常情况下 录音按钮没有恢复默认状态的场景 （秒点录音按钮之后秒松开）
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                _zc_voiceButton.enabled = YES;
                _zc_addMoreButton.enabled = YES;
                _zc_faceButton.enabled = YES;
                [_zc_pressedButton setTitle:ZCSTLocalString(@"按住 说话") forState:UIControlStateNormal];
            });
        }else{
            // 发送
            [_zc_recordView didChangeState:RecordComplete];
            [self closeRecord:sender];
        }
    
    }
    
}

-(void)closeRecord:(UIButton *) sender{
    //停止录音
    
    int duration = (int)_zc_recordView.currentTime;
    [_zc_recordView dismissRecordView];
    _zc_recordView = nil;

//    [_zc_pressedButton setBackgroundColor:[UIColor clearColor]];
    [_zc_pressedButton setBackgroundColor:UIColorFromThemeColor(ZCTextPlaceHolderColor)];

    [_zc_pressedButton setTitle:ZCSTLocalString(@"按住 说话") forState:UIControlStateNormal];
    // 设置_pressedButton边界宽度
//    _zc_pressedButton.layer.borderWidth = 0.75f;
    _zc_voiceButton.enabled=YES;
    _zc_addMoreButton.enabled=YES;
    _zc_faceButton.enabled = YES;
    if(duration<1){
        
        [SobotLog logDebug:@"当前的时长：%d",duration];
        // 当前记录的语音时间为 0秒，秒点击触发事件，关闭计时器
        sender.enabled = NO;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.5f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            sender.enabled = YES;
        });
    }
}


#pragma mark 录音完成，上传录音
-(void)recordComplete:(NSString *)filePath videoDuration:(CGFloat)duration{
    NSDate  *date = [NSDate dateWithTimeIntervalSince1970:duration];
    NSString *time=sobotDateTransformString(@"mm:ss", date);
    [self sendMessageOrFile:filePath type:ZCMessageTypeSound duration:time];
}


- (void)recordCompleteType:(RecordState )type videoDuration:(CGFloat)duration{
    if (type == RecordStart) {
        [[ZCUICore getUICore] sendMessage:@"" questionId:@"" type:ZCMessagetypeStartSound duration:[NSString stringWithFormat:@"%d",(int)duration]];
    }else if(type == RecordCancel){
        [[ZCUICore getUICore] sendMessage:@"" questionId:@"" type:ZCMessagetypeCancelSound duration:[NSString stringWithFormat:@"%d",(int)duration]];
    }
}



#pragma mark -- 发送文本消息
-(void)doSendMessage:(BOOL) isReSend{
    NSString *text;
//    if ([_zc_chatTextView.text isEqualToString:_zc_chatTextView.placeholder]) {
//        return;
//    }else{
        text = _zc_chatTextView.text;
//    }
    
    // 过滤Emoji表情 2.8.4版本开始，开放emoji表情
//    [text enumerateSubstringsInRange:NSMakeRange(0, text.length) options:NSStringEnumerationByComposedCharacterSequences usingBlock:^(NSString *substring, NSRange substringRange, NSRange enclosingRange, BOOL *stop) {
//        if(substring.length==2){
//            _zc_chatTextView.text=[_zc_chatTextView.text stringByReplacingOccurrencesOfString:substring withString:@""];
//        }else{
//            // 特殊Emoji，如搜狗输入法中的
//            const unichar hs = [substring characterAtIndex:0];
//            BOOL returnValue=NO;
//            // non surrogate
//            if (0x2100 <= hs && hs <= 0x27ff) {
//                returnValue = YES;
//            } else if (0x2B05 <= hs && hs <= 0x2b07) {
//                returnValue = YES;
//            } else if (0x2934 <= hs && hs <= 0x2935) {
//                returnValue = YES;
//            } else if (0x3297 <= hs && hs <= 0x3299) {
//                returnValue = YES;
//            } else if (hs == 0xa9 || hs == 0xae || hs == 0x303d || hs == 0x3030 || hs == 0x2b55 || hs == 0x2b1c || hs == 0x2b1b || hs == 0x2b50) {
//                returnValue = YES;
//            }
//
//            if(returnValue){
//                _zc_chatTextView.text=[_zc_chatTextView.text stringByReplacingOccurrencesOfString:substring withString:@""];
//            }
//        }
//    }];
    //  可能过滤了Emoji，所以重新赋值
    text=_zc_chatTextView.text;
    
    // 过滤空格
    text = sobotTrimString(text);
    if([@"" isEqual:sobotConvertToString(text)]){
        [_zc_chatTextView setText:@""];
        [self textChanged:_zc_chatTextView];
        return;
    }
    
    if(_isConnectioning){
        return;
    }
    
    // 最多发送1000字符
    if(text.length > 1000){
        text = [text substringToIndex:1000];
    }
    
    [_zc_chatTextView setText:@""];
    [self textChanged:_zc_chatTextView];
    
    
    [self sendMessageOrFile:text type:ZCMessageTypeText duration:@""];
    
}


-(void) sendMessageOrFile:(NSString *)filePath type:(ZCMessageType) type duration:(NSString *)duration dict:(NSDictionary *) dict{
    if (curKeyBoardStatus == ZCKeyboardStatusNewSession) {
        // 发送提示消息“本次会话已结束”
        [[ZCUICore getUICore] addTipsListenerMessage:ZCKeyboardClickTypeAddOverMsgTipCell];
        return;
    }
    [[ZCUICore getUICore]  sendMessage:filePath questionId:@"" type:type duration:duration dict:dict];
}

-(void) sendMessageOrFile:(NSString *)filePath type:(ZCMessageType) type duration:(NSString *)duration{
    
    [self sendMessageOrFile:filePath type:type duration:duration dict:nil];
}



#pragma mark -- 显示表情 和 更多
// 点击更多时的键盘样式
- (void)showMoreKeyboard:(BottomButtonClickTag) type{
    _facePageControl.hidden = YES;
    // 去掉表情键盘的动画
    if (type == BUTTON_ADDFACEVIEW) {
        // 横竖屏切换问题
        if (_zc_emojiView!= nil) {
            [_zc_emojiView removeFromSuperview];
        }
        
        CGFloat emojiViewH = EmojiViewHeight;
        if ([self getSourceViewHeight] < [self getSourceViewWidth]) {
            emojiViewH = EmojiViewHorizontalHeight;
        }
        _zc_emojiView=[[EmojiBoardView alloc] initWithBoardHeight:emojiViewH pH:[self getSourceViewHeight] pW:[self getSourceViewWidth]];
        _zc_emojiView.delegate=self;
        [_zc_sourceView addSubview:_zc_emojiView];
        
        UIView * lineView2 = [[UIView alloc]initWithFrame:CGRectMake(0, 0, [self getSourceViewWidth], 0.5)];
        lineView2.backgroundColor = [ZCUITools zcgetBackgroundBottomLineColor];
        [_zc_emojiView addSubview:lineView2];
    }else if(type == BUTTON_ADDPHOTO){
        [self createMoreView];
    }
    
    [UIView animateWithDuration:0.25 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        //隐藏键盘
        [_zc_chatTextView resignFirstResponder];
        CGRect pf        = _zc_moreView.frame;
        CGRect bf        = _zc_bottomView.frame;
        CGRect tf        = _zc_listTable.frame;
        CGRect ff        = _zc_emojiView.frame;
        
        int bh           = 0;
        
        //显示表情
        if(type==BUTTON_ADDFACEVIEW){
            
            
            CGFloat emojiViewH = EmojiViewHeight;
            if ([self getSourceViewHeight] < [self getSourceViewWidth]) {
                emojiViewH = EmojiViewHorizontalHeight;
            }
            bh = emojiViewH;
            
            ff.origin.x=0;
            ff.origin.y=[self getSourceViewHeight]-bh;
            ff.size.height = bh;
            _zc_emojiView.frame=ff;
            
            pf.origin.y=[self getSourceViewHeight];
            pf.size.height = bh;
            _zc_moreView.frame=pf;
        }else if(type==BUTTON_ADDPHOTO){
            
            //显示更多
            CGFloat moreHeight = MoreViewHeight;
            if ([self getSourceViewHeight] < [self getSourceViewWidth]) {
                moreHeight = MoreViewHorizontalHeight;
            }
            bh = moreHeight;
            
            ff.origin.y=[self getSourceViewHeight];
            _zc_emojiView.frame=ff;
            
            pf.origin.y=[self getSourceViewHeight]-bh;
            _zc_moreView.frame=pf;
            
            if (buttonArr.count > 8) {
                _facePageControl.hidden = NO;
            }
        }
        
        
        _zc_keyBoardHeight    = bh+XBottomBarHeight;
        
        bh         = BottomHeight + (_zc_chatTextView.frame.size.height-35);
        CGFloat x = tf.size.height-_zc_listTable.contentSize.height;
        
        
        if(x > 0){
            if(x<_zc_keyBoardHeight){
                tf.origin.y = startTableY - (_zc_keyBoardHeight - x)-(bh-BottomHeight)+XBottomBarHeight;
            }
        }else{
            tf.origin.y   = startTableY - _zc_keyBoardHeight-(bh-BottomHeight)+XBottomBarHeight;
        }
        _zc_listTable.frame  = tf;
        
        if(x<0){
            //            [_zc_listTable setContentOffset:CGPointMake(0,(_zc_chatTextView.frame.size.height-35)+ ch-h) animated:NO];
            
            [_zc_listTable setContentOffset:CGPointMake(0, -x) animated:NO];
        }
        
        bf.origin.y       = [self getSourceViewHeight] - bh - _zc_keyBoardHeight + XBottomBarHeight;// - StatusBarHeight
        bf.size.height    = bh;
        _zc_bottomView.frame = bf;
        
        if (!_vioceTipLabel.hidden) {
//            CGRect TF = _vioceTipLabel.frame;
//            TF.origin.y =  _zc_bottomView.frame.origin.y - _vioceTipLabel.frame.size.height;
//            _vioceTipLabel.frame = TF;
            
            CGRect TF = _vioceTipBgView.frame;
            TF.origin.y =  _zc_bottomView.frame.origin.y - _vioceTipBgView.frame.size.height;
            _vioceTipBgView.frame = TF;
        }
        
        
        if ([ZCUICore getUICore].delegate && [[ZCUICore getUICore].delegate respondsToSelector:@selector(onPageStatusChanged: message: obj:)]) {
            [[ZCUICore getUICore].delegate onPageStatusChanged:ZCTurnRobotFramChange message:@"" obj:nil];
        }
    } completion:^(BOOL finished) {
        // 回收键盘的手势记得要添加
        [_zc_listTable addGestureRecognizer:tapRecognizer];
    }];
}



/**
 显示 评价、新会话、留言状态View
 */
-(void)showStatusView{
    [_zc_sessionBgView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    CGFloat bh = CGRectGetHeight(_zc_sessionBgView.frame);
    CGRect bf = _zc_bottomView.frame;
    bf.origin.y       = [self getSourceViewHeight] - bh - _zc_keyBoardHeight;
    bf.size.height    = bh;
    _zc_bottomView.frame = bf;
    _zc_sessionBgView.hidden  = NO;
    // 当前页面使用自己添加的数据，不从接口方法中获取，（预留接口，后期有变动在添加）
    // 标题和tag
    NSMutableArray * titleArray = [NSMutableArray arrayWithCapacity:0];
    NSMutableArray * tagArr = [NSMutableArray arrayWithCapacity:0];
    
    
    // 开启留言
    if ([self getZCLibConfig].msgFlag == 0 && ![ZCUICore getUICore].kitInfo.hideBottomLeave) {
        if([self getZCLibConfig].isArtificial && [self getZCLibConfig].msgToTicketFlag == 2){
            // 2.8.9人工状态，留言转离线消息，不处理
        }else{
            
            [titleArray addObject:ZCSTLocalString(@"留言")];
            [tagArr addObject:[NSString stringWithFormat:@"%zd",BUTTON_LEAVEMESSAGE]];
        }
    }
    
    // 是否添加满意度的按钮，是否成功转人工成功过
    if ([self getZCLibConfig].type ==2 && ![self getZCLibConfig].isArtificial && ![ZCUICore getUICore].isSendToUser) {
        // 仅人工，没有转成功人工不能评价
    }else{
        if(![ZCUICore getUICore].kitInfo.hideBottomEvaluation){
            [titleArray  addObject:ZCSTLocalString(@"服务评价")];
            [tagArr addObject:[NSString stringWithFormat:@"%zd",BUTTON_SATISFACTION]];
        }
    }
    
    [titleArray addObject:ZCSTLocalString(@"重建会话")];
    [tagArr addObject:[NSString stringWithFormat:@"%zd",BUTTON_RECONNECT_USER]];
    
    [self creatNewAgainBtnForArray: titleArray tags: tagArr];
}


#pragma mark -- 创建新会话键盘样式
-(void)creatNewAgainBtnForArray:(NSMutableArray*)titleArr tags:(NSMutableArray *)tags{
    
    CGFloat itemH = 50;
    CGFloat itemW = 70;
    CGFloat itemY = 17;
    
    CGFloat itemX = 0;
    
    for (int i = 0; i< titleArr.count; i++) {
        int tag = [tags[i] intValue];
        
        itemX = ([self getSourceViewWidth]/titleArr.count)/2 + i*([self getSourceViewWidth]/titleArr.count) - itemW/2;
        
        ZCButton * zcbtns = [ZCButton buttonWithType:UIButtonTypeCustom];
        zcbtns.frame = CGRectMake(itemX, itemY, itemW, itemH);
        if (tag == BUTTON_SATISFACTION) {
            [zcbtns setImage:[ZCUITools zcuiGetBundleImage:@"zcicon_bottombar_satisfaction"] forState:UIControlStateNormal];
        }else if (tag == BUTTON_RECONNECT_USER){
            [zcbtns setImage:[ZCUITools zcuiGetBundleImage:@"zcicon_bottombar_conversation"] forState:UIControlStateNormal];
        }else if (tag == BUTTON_LEAVEMESSAGE){
            [zcbtns setImage:[ZCUITools zcuiGetBundleImage:@"zcicon_bottombar_message"] forState:UIControlStateNormal];

        }
        
        [zcbtns setTitle:titleArr[i] forState:UIControlStateNormal];
        zcbtns.titleLabel.font = ZCUIFont10;
        zcbtns.tag = tag;
        [zcbtns addTarget:self action:@selector(btnClickForNewAgain:) forControlEvents:UIControlEventTouchUpInside];
        [zcbtns setTitleColor:UIColorFromThemeColor(ZCTextMainColor) forState:UIControlStateNormal];
//        zcbtns.autoresizingMask = UIViewAutoresizingFlexibleRightMargin |UIViewAutoresizingFlexibleLeftMargin;
//        zcbtns.layer.cornerRadius = 4;
//        zcbtns.layer.masksToBounds = YES;
        [_zc_sessionBgView addSubview:zcbtns];
    }
    
}

#pragma mark -- 执行 评价 满意度
-(void)btnClickForNewAgain:(ZCButton *)sender{
    if (sender.tag == BUTTON_SATISFACTION) {
        // 调评价页面
        [[ZCUICore getUICore] keyboardOnClickSatisfacetion:NO];
    }else if (sender.tag == BUTTON_RECONNECT_USER){
        sender.enabled = NO;// 防止连续点击造成其他异常问题 ，在设置新会话键盘样式时在设置可点
        [_zc_activityView startAnimating];
        [[ZCUICore getUICore] setclosepamasAndClearConfig];
        //  要去初始化啊
        [[ZCUICore getUICore] initConfigData:YES IsNewChat:YES];
        [self handleKeyboard];
    }else if (sender.tag == BUTTON_LEAVEMESSAGE){
        [self hideKeyboard];
//        [self removeKeyboardObserver];
        // 点击bottom上的留言按钮 跳转到留言并提交 不直接退出SDK
        [self leaveMsgBtnAction:LeaveExitTypeISNOCOLSE];
    }

}

#pragma mark -- 留言事件

- (void)leaveMsgBtnActionType:(NSInteger) type {
    [self hideKeyboard];
    //    [self removeKeyboardObserver];
    // 点击bottom上的留言按钮 跳转到留言并提交 不直接退出SDK
    [self leaveMsgBtnAction:LeaveExitTypeISNOCOLSE];
}

- (void)leaveMsgBtnAction:(LeaveExitType ) exitType {
    // 留言
    if ([ZCUICore getUICore].delegate && [[ZCUICore getUICore].delegate respondsToSelector:@selector(onPageStatusChanged: message: obj:)]) {
        [[ZCUICore getUICore].delegate onPageStatusChanged:ZCShowStatusLeaveMsgPage message:@"" obj:[NSString stringWithFormat:@"%zd",exitType]];
    }
    [self hideKeyboard];
}


- (void)dealloc{
    [[ZCAutoListView getAutoListView] dissmiss];
    //    NSLog(@"键盘被清理掉了");
}

#pragma mark -- 获取当前屏幕显示的viewcontroller
- (UIViewController *)getCurrentVC
{
    UIViewController *rootViewController = [[ZCToolsCore getToolsCore] getCurWindow].rootViewController;
    
    UIViewController *currentVC = [self getCurrentVCFrom:rootViewController];
    
    return currentVC;
}

- (UIViewController *)getCurrentVCFrom:(UIViewController *)rootVC
{
    UIViewController *currentVC;
    if(_zc_listTable!=nil){
        // 直接使用UIView 获取当前ChatVC
        id nextResponder = [_zc_listTable nextResponder];
        while (![nextResponder isKindOfClass:[UIViewController class]]){
            nextResponder = [nextResponder nextResponder];
            if([nextResponder isKindOfClass:[UIViewController class]]){
                currentVC = nextResponder;
                break;
            }
        }
        if(currentVC){
            return currentVC;
        }
    }
    
    
    if ([rootVC isKindOfClass:[UITabBarController class]]) {
        // 根视图为UITabBarController
        
        currentVC = [self getCurrentVCFrom:[(UITabBarController *)rootVC selectedViewController]];
        
    } else if ([rootVC isKindOfClass:[UINavigationController class]]){
        // 根视图为UINavigationController
        
        currentVC = [self getCurrentVCFrom:[(UINavigationController *)rootVC visibleViewController]];
        
    } else {
        // 根视图为非导航类
        if ([rootVC presentedViewController]) {
            // 视图是被presented出来的
            rootVC = [self getCurrentVCFrom:[rootVC presentedViewController]];
        }else{
            currentVC = rootVC;
        }
    }
    
    return currentVC;
}


-(void)reloadImages{
    [self.zc_faceButton setImage:[ZCUITools zcuiGetBundleImage:@"zcicon_expression_normal"] forState:UIControlStateNormal];
    [self.zc_faceButton setImage:[ZCUITools zcuiGetBundleImage:@"zcicon_expression_pressed"] forState:UIControlStateHighlighted];
    [self.zc_addMoreButton setImage:[ZCUITools zcuiGetBundleImage:@"zcicon_add"] forState:UIControlStateNormal];
    [self.zc_addMoreButton setImage:[ZCUITools zcuiGetBundleImage:@"zcicon_add_selected"] forState:UIControlStateHighlighted];
    
    if ([[ZCLibClient getZCLibClient].libInitInfo.absolute_language hasPrefix:@"zh-"] || (sobotConvertToString([ZCLibClient getZCLibClient].libInitInfo.absolute_language).length == 0 && [sobotGetLanguagePrefix() hasPrefix:@"zh-"])) {
        [_zc_turnButton setImage:[ZCUITools zcuiGetBundleImage:@"zcicon_turnserver_word_nol"] forState:UIControlStateNormal];
        [_zc_turnButton setImage:[ZCUITools zcuiGetBundleImage:@"zcicon_turnserver_word_nol"] forState:UIControlStateHighlighted];
    }else{
        [_zc_turnButton setImage:[ZCUITools zcuiGetBundleImage:@"zcicon_turnserver_word_nol_en"] forState:UIControlStateNormal];
        [_zc_turnButton setImage:[ZCUITools zcuiGetBundleImage:@"zcicon_turnserver_word_nol_en"] forState:UIControlStateHighlighted];
    }

    [self.zc_voiceButton setImage:[ZCUITools zcuiGetBundleImage:@"zcicon_voice_normal"] forState:UIControlStateNormal];
    [self.zc_voiceButton setImage:[ZCUITools zcuiGetBundleImage:@"zcicon_voice_pressed"] forState:UIControlStateHighlighted];
}


-(void)setLaySubViewUI{
    if (curKeyBoardStatus == ZCKeyboardStatusNewSession) {
        // 新会话键盘样式 重新布局UI  在横竖屏切换的时候
        [self showStatusView];
    }
}

-(BOOL)getZC_RecordView{
    if (self.zc_recordView != nil) {
//        NSLog(@"语音记录的 wiew ******************* %@",self.zc_recordView);
        return YES;
    }
    return NO;
}
@end
