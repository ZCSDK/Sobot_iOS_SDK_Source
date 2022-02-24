//
//  ZCLeaveMsgVC.m
//  SobotKit
//
//  Created by lizhihui on 2019/4/3.
//  Copyright © 2019 zhichi. All rights reserved.
//

#import "ZCLeaveMsgVC.h"
#import "ZCUICore.h"
#import "ZCLibGlobalDefine.h"
#import "ZCUIColorsDefine.h"
#import "ZCUIPlaceHolderTextView.h"
#import "ZCLibServer.h"
#import "ZCUIImageTools.h"
#import "ZCMLEmojiLabel.h"
#import "ZCUIWebController.h"
#import "ZCHtmlCore.h"
#import "ZCHtmlFilter.h"

#import "ZCToolsCore.h"

#import "ZCPlatformTools.h"

@interface ZCLeaveMsgVC ()<ZCMLEmojiLabelDelegate,UITextFieldDelegate,UITextViewDelegate>{
    // 屏幕宽高
//    CGFloat                     viewWidth;
//    CGFloat                     viewHeigth;
    NSString * callURL;
    CGPoint        contentoffset;// 记录list的偏移量
    
    UILabel  * detailLab ;  // 问题描述
   
}

@property (nonatomic,strong) ZCUIPlaceHolderTextView * textView;

@property (nonatomic,strong) ZCMLEmojiLabel * tipLab;

@property (nonatomic,strong) UIScrollView * scrollView;

@end

@implementation ZCLeaveMsgVC

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}


- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    if ([ZCUICore getUICore].kitInfo.navcBarHidden) {
        self.navigationController.navigationBarHidden = YES;
    }
}


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    //    [self.navigationController setNavigationBarHidden:YES];
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    if ([ZCUICore getUICore].kitInfo.navcBarHidden) {
        self.navigationController.navigationBarHidden = YES;
    }
    
    
    [self setHeaderConfig];
    
    self.view.backgroundColor = [ZCUITools zcgetLightGrayDarkBackgroundColor];
    
    [self layoutSubViewsUI];
    
    
    UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapAction:)];
    [self.view addGestureRecognizer:tap];
    
    
    if([ZCPlatformTools checkLeaveMessageModule]){
        [[ZCToolsCore getToolsCore] showAlert:ZCSTLocalString(@"由于服务到期，该功能已关闭。") message:nil cancelTitle:ZCSTLocalString(@"确定") titleArray:nil viewController:self confirm:^(NSInteger buttonTag) {
            if (self.navigationController) {
                [self.navigationController popViewControllerAnimated:NO];
            }else{
                [self dismissViewControllerAnimated:NO completion:nil];
            }
        }];
    }
}

// 设置页面头部导航相关View
-(void)setHeaderConfig{
    if(!self.navigationController.navigationBarHidden){
        if (self.navigationController.navigationBar.translucent) {
         self.navigationController.navigationBar.translucent = NO;
        }
        [self setNavigationBarStyle];
        self.title = ZCSTLocalString(@"留言消息");
        [self.navigationController.navigationBar setTitleTextAttributes:@{NSFontAttributeName:[ZCUITools zcgetTitleFont],NSForegroundColorAttributeName:[ZCUITools zcgetTopViewTextColor]}];

        //    2.8.0 增加导航栏下面 细线
        UIView *lineView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 0.5)];
        lineView.backgroundColor = [ZCUITools zcgetCommentButtonLineColor];
        [self.view addSubview:lineView];
    }else{
        [self createTitleView];
        self.titleLabel.text = ZCSTLocalString(@"留言消息");
        self.moreButton.hidden = YES;
        //back
        [self.backButton addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
    }
}

-(void)tapAction:(UITapGestureRecognizer *)sender{
    [self hideKeyboard];
}


-(void)buttonClick:(UIButton*)sender{
    if (sender.tag == BUTTON_BACK) {
        if (self.navigationController) {
            [self.navigationController popViewControllerAnimated:NO];
        }else{
            [self dismissViewControllerAnimated:NO completion:nil];
        }
    }else if (sender.tag == BUTTON_MORE){
        if (_textView.text.length <=0) {
            [[ZCUIToastTools shareToast] showToast:ZCSTLocalString(@"请填写问题描述") duration:2 view:[UIApplication sharedApplication].keyWindow position:ZCToastPositionCenter];
            return;
        }
        __weak ZCLeaveMsgVC * saveSelf = self;
        [[ZCLibServer getLibServer] getLeaveMsgWith:[[ZCUICore getUICore] getLibConfig].uid Content:_textView.text groupId:self.groupId start:^{
            
        } success:^(NSDictionary *dict, ZCNetWorkCode sendCode) {
            if (dict) {
                if(!sobotIsNull(dict[@"data"])){
                    int status = [dict[@"data"][@"status"] intValue];
                    if(status == 0){
                        [[ZCUIToastTools shareToast] showToast:sobotConvertToString(dict[@"data"][@"msg"]) duration:1.0f view:saveSelf.view position:ZCToastPositionCenter];
                        return;
                    }
                }
                // 返回，发送留言消息
                if (saveSelf.passMsgBlock) {
                    saveSelf.passMsgBlock(saveSelf.textView.text);
                }
                if (saveSelf.navigationController) {
                    [saveSelf.navigationController popViewControllerAnimated:NO];
                }else{
                    [saveSelf dismissViewControllerAnimated:NO completion:nil];
                }
            }
        } failed:^(NSString *errorMessage, ZCNetWorkCode errorCode) {
            [[ZCUIToastTools shareToast] showToast:sobotConvertToString(errorMessage) duration:1.0f view:saveSelf.view position:ZCToastPositionCenter];
            NSLog(@"%@",errorMessage);
        }];
    }
}

-(void)layoutSubViewsUI{
    [self.view.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    CGFloat y = 0;
    if (self.navigationController.navigationBarHidden) {
        y = NavBarHeight;
    }
    _scrollView = [[UIScrollView alloc]initWithFrame:CGRectMake(0, y, [self getCurViewWidth], [self getCurViewHeight] -NavBarHeight)];
    _scrollView.scrollEnabled = YES;
    _scrollView.pagingEnabled = NO;
    _scrollView.showsVerticalScrollIndicator = NO;
    _scrollView.showsHorizontalScrollIndicator = NO;
    _scrollView.bounces = NO;
    _scrollView.backgroundColor = [UIColor clearColor];
//    _scrollView.backgroundColor = UIColorFromThemeColor(ZCBgLightGrayDarkColor);
    [self.view addSubview:_scrollView];
    
    CGFloat Y = 0;
    if (self.navigationController.navigationBarHidden) {
        Y = NavBarHeight;
    }
    
    _tipLab = [[ZCMLEmojiLabel alloc]initWithFrame:CGRectMake(0, 0, [self getCurViewWidth], 0)];
    _tipLab.font = ZCUIFont14;
    _tipLab.numberOfLines = 0;
    _tipLab.backgroundColor = [UIColor clearColor];
    [_tipLab setTextAlignment:NSTextAlignmentLeft];
    [_tipLab setTextColor:UIColorFromThemeColor(ZCTextSubColor)];
    _tipLab.numberOfLines = 0;
    _tipLab.isNeedAtAndPoundSign = NO;
    _tipLab.disableEmoji = NO;
    
    _tipLab.lineSpacing = 3.0f;
    [_tipLab setLinkColor:[ZCUITools zcgetChatLeftLinkColor]];
    _tipLab.delegate = self;
    NSString *text = @"";
    if (_msgTxt !=nil && _msgTxt.length > 0) {
        text = sobotConvertToString(_msgTxt);
    }
//    NSString *text = _msgTxt;//[self getCurConfig].msgTxt;
     if(sobotConvertToString([ZCUICore getUICore].kitInfo.leaveMsgGuideContent).length > 0){
        text = ZCSTLocalString(sobotConvertToString([ZCUICore getUICore].kitInfo.leaveMsgGuideContent));
    }
    text = [ZCHtmlCore filterHTMLTag:text];
    
    [ZCHtmlCore filterHtml:text result:^(NSString * _Nonnull text1, NSMutableArray * _Nonnull arr, NSMutableArray * _Nonnull links) {
    
        if (text1.length > 0 && text1 != nil) {
            _tipLab.attributedText =   [ZCHtmlFilter setHtml:text1 attrs:arr view:_tipLab textColor:UIColorFromThemeColor(ZCTextSubColor) textFont:ZCUIFont14 linkColor:[ZCUITools zcgetChatLeftLinkColor]];
        }else{
            _tipLab.attributedText =   [[NSAttributedString alloc] initWithString:@""];
        }
        
    }];
    
    CGSize  labSize  =  [_tipLab preferredSizeWithMaxWidth:ScreenWidth-30];
    _tipLab.frame = CGRectMake(15, 12, labSize.width, labSize.height);
    [_scrollView addSubview:_tipLab];
    
    
   
    UIView * wbgView = [[UIView alloc]initWithFrame:CGRectMake(0, CGRectGetMaxY(_tipLab.frame) +ZCNumber(12),ScreenWidth , 30 + 154 + 20)];
    wbgView.backgroundColor = UIColorFromThemeColor(ZCBgSystemWhiteLightGrayColor);
    [_scrollView addSubview:wbgView];
    
    _textView = [[ZCUIPlaceHolderTextView alloc]initWithFrame:CGRectMake(20, CGRectGetMaxY(_tipLab.frame) +ZCNumber(40), [self getCurViewWidth]-40, ZCNumber(154))];
    _textView.type = 1;
    _textView.placeholder = @"";
    [_textView setPlaceholderColor:UIColorFromThemeColor(ZCTextPlaceHolderColor)];
    [_textView setFont:ZCUIFont14];
    [_textView setTextColor:UIColorFromThemeColor(ZCTextMainColor)];
    _textView.delegate = self;
    _textView.placeholederFont = ZCUIFont14;
    _textView.layer.cornerRadius = 4.0f;
    _textView.layer.masksToBounds = YES;
    [_textView setBackgroundColor:[ZCUITools zcgetLeftChatColor]];
    [_textView setContentInset:UIEdgeInsetsMake( 7, 12, 15, 15)];
    NSString * tmp =   sobotConvertToString(self.msgTmp);
    tmp = [ZCHtmlCore filterHTMLTag:tmp];
    while ([tmp hasPrefix:@"\n"]) {
        tmp=[tmp substringWithRange:NSMakeRange(1, tmp.length-1)];
    }
    
    if(sobotConvertToString([ZCUICore getUICore].kitInfo.leaveContentPlaceholder).length > 0){
        tmp = ZCSTLocalString(sobotConvertToString([ZCUICore getUICore].kitInfo.leaveContentPlaceholder));
    }
    
    [ZCHtmlCore filterHtml:tmp result:^(NSString * _Nonnull text1, NSMutableArray * _Nonnull arr, NSMutableArray * _Nonnull links) {
        _textView.placeholder = text1;
        _textView.placeholderLinkColor = UIColorFromThemeColor(ZCTextPlaceHolderColor);
    }];
    [_scrollView addSubview:_textView];
    
    
    //    2.8.0 增加导航栏下面 细线
    UIView *lineView1 = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 0.5)];
    lineView1.backgroundColor = UIColorFromThemeColor(ZCBgLineColor);
    [wbgView addSubview:lineView1];
    
    
    //    2.8.0 增加导航栏下面 细线
    UIView *lineView2 = [[UIView alloc]initWithFrame:CGRectMake(0, wbgView.frame.size.height , self.view.frame.size.width, 0.5)];
    lineView2.backgroundColor = UIColorFromThemeColor(ZCBgLineColor);
    [wbgView addSubview:lineView2];
    
    
    
    int th = CGRectGetMaxY(wbgView.frame);
    if(sobotConvertToString(_leaveExplain).length > 0){
        UILabel *label=[[UILabel alloc] initWithFrame:CGRectMake(15, th + 10, [self getCurViewWidth]-30, 0)];
        label.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        [label setFont:ZCUIFont14];
        [label setText:sobotConvertToString(_leaveExplain)];
        //    [label setText:_listArray[section][@"sectionName"]];
        [label setBackgroundColor:[UIColor clearColor]];
        [label setTextAlignment:NSTextAlignmentLeft];
        [label setTextColor:UIColorFromThemeColor(ZCTextSubColor)];
        label.numberOfLines = 0;
        [label sizeToFit];
        [_scrollView addSubview:label];
        th = CGRectGetMaxY(label.frame);
    }
    
    // 区尾添加提交按钮 2.7.1改版
    UIButton * commitBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [commitBtn setTitle:ZCSTLocalString(@"提交") forState:UIControlStateNormal];
    [commitBtn setTitle:ZCSTLocalString(@"提交") forState:UIControlStateSelected];
    
    [commitBtn setTitleColor:[ZCUITools zcgetLeaveSubmitTextColor] forState:UIControlStateNormal];
    [commitBtn setTitleColor:[ZCUITools zcgetLeaveSubmitTextColor] forState:UIControlStateHighlighted];
    [commitBtn setBackgroundColor:[ZCUITools zcgetLeaveSubmitImgColor]];
    commitBtn.frame = CGRectMake(ZCNumber(15), th + ZCNumber(20), ScreenWidth- ZCNumber(30), ZCNumber(44));
    commitBtn.tag = BUTTON_MORE;
    [commitBtn addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
    commitBtn.layer.masksToBounds = YES;
    commitBtn.layer.cornerRadius = 22.f;
    commitBtn.titleLabel.font = ZCUIFont17;
    [_scrollView addSubview:commitBtn];
        
}


#pragma mark -- 键盘滑动的高度

- (void) hideKeyboard {
    [_textView resignFirstResponder];
    [self allHideKeyBoard];
    if(contentoffset.x != 0 || contentoffset.y != 0){
        // 隐藏键盘，还原偏移量
        [_scrollView setContentOffset:contentoffset];
    }
}


- (void)allHideKeyBoard
{
    for (UIWindow* window in [UIApplication sharedApplication].windows)
    {
        for (UIView* view in window.subviews)
        {
            [self dismissAllKeyBoardInView:view];
        }
    }
}

-(BOOL) dismissAllKeyBoardInView:(UIView *)view
{
    if([view isFirstResponder])
    {
        [view resignFirstResponder];
        return YES;
    }
    for(UIView *subView in view.subviews)
    {
        if([self dismissAllKeyBoardInView:subView])
        {
            return YES;
        }
    }
    return NO;
}

#pragma mark EmojiLabel链接点击事件
// 链接点击
-(void)attributedLabel:(ZCTTTAttributedLabel *)label didSelectLinkWithURL:(NSURL *)url{
    // 此处得到model 对象对应的值
    //    NSLog(@"url:%@  url.absoluteString:%@",url,url.absoluteString);
    [self doClickURL:url.absoluteString text:@""];
}


// 链接点击
-(void)ZCMLEmojiLabel:(ZCMLEmojiLabel *)emojiLabel didSelectLink:(NSString *)link withType:(ZCMLEmojiLabelLinkType)type{
    [self doClickURL:link text:@""];
}


// 链接点击
-(void)doClickURL:(NSString *)url text:(NSString * )htmlText{
    if(url){
        url=[url stringByReplacingOccurrencesOfString:@"\"" withString:@""];
    
            if([url hasPrefix:@"tel:"] || sobotValidateMobileWithRegex(url, [ZCUITools zcgetTelRegular])){
                callURL=url;
                
  
                [[ZCToolsCore getToolsCore] showAlert:nil message:[url stringByReplacingOccurrencesOfString:@"tel:" withString:@""] cancelTitle:ZCSTLocalString(@"取消") viewController:self confirm:^(NSInteger buttonTag) {
                    if(buttonTag>=0){
                        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:callURL]];
                    }
                    
                } buttonTitles:ZCSTLocalString(@"呼叫"), nil];
                
                
            }else if([url hasPrefix:@"mailto:"] || sobotValidateEmail(url)){
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:url]];
            }
            
            else{
                if (![url hasPrefix:@"https"] && ![url hasPrefix:@"http"]) {
                    url = [@"http://" stringByAppendingString:url];
                }
                ZCUIWebController *webPage=[[ZCUIWebController alloc] initWithURL:sobotUrlEncodedString(url)];
                if(self.navigationController != nil ){
                    [self.navigationController pushViewController:webPage animated:YES];
                }else{
                    UINavigationController *nav=[[UINavigationController alloc] initWithRootViewController:webPage];
                    nav.navigationBarHidden=YES;
                    nav.modalPresentationStyle = UIModalPresentationOverFullScreen;
                    [self presentViewController:nav animated:YES completion:^{
                        
                    }];
                }
            }
        }
    
    
}



-(BOOL)openQQ:(NSString *)qq{
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"mqq://im/chat?chat_type=wpa&uin=%@&version=1&src_type=web",qq]];
    if([[UIApplication sharedApplication] canOpenURL:url]){
        [[UIApplication sharedApplication] openURL:url];
        return NO;
    }
    else{
        
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://wpa.qq.com/msgrd?v=3&uin=%@&site=qq&menu=yes",qq]]];
        return YES;
    }
}


-(void)viewDidLayoutSubviews{
    [super viewDidLayoutSubviews];
    [self layoutSubViewsUI];
    [self setHeaderConfig];
}


@end
