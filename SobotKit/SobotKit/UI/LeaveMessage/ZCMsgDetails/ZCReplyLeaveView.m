//
//  ZCReplyLeaveView.m
//  SobotKit
//
//  Created by xuhan on 2019/12/4.
//  Copyright © 2019 zhichi. All rights reserved.
//

#import "ZCReplyLeaveView.h"
#import "ZCLibGlobalDefine.h"
#import "ZCUIColorsDefine.h"
#import "ZCUIPlaceHolderTextView.h"
#import "ZCUIImageView.h"
#import "ZCActionSheet.h"
#import "ZCSobotCore.h"

#import "ZCUICore.h"
#import "ZCLibServer.h"
#import "ZCPlatformTools.h"
#import "ZCToolsCore.h"

@interface ZCReplyLeaveView()<UITextViewDelegate,ZCActionSheetDelegate>{
    UIButton *delButton;
    UIButton *submitButton;
}

@property (nonatomic, strong) UIView *backGroundView;
//@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, assign) float viewWidth;
@property (nonatomic, assign) float viewHeight;

@property (nonatomic, strong) UIScrollView *fileScrollView; // 放图片
@property (nonatomic, strong) ZCUIImageView * imageView;

@property (nonatomic, strong) UIImagePickerController *zc_imagepicker;


@end

@implementation ZCReplyLeaveView

#pragma mark - init

-(ZCReplyLeaveView *)initActionSheetWithView:(UIView *)view{
    self = [super init];
       if (self) {
           self.viewWidth = view.frame.size.width;
           self.viewHeight = ScreenHeight;
           
           self.frame = CGRectMake(0, 0, self.viewWidth, self.viewHeight);
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

#pragma mark - 布局

- (void)createSubviews {
    
    self.backGroundView = [[UIView alloc] init];
    self.backGroundView.frame = CGRectMake(0, self.viewHeight, self.viewWidth, 0);

    self.backGroundView.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin|UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin;
    self.backGroundView.autoresizesSubviews = YES;
    self.backGroundView.backgroundColor = UIColorFromThemeColor(ZCBgSystemWhiteLightDarkColor);
    //    [self.backGroundView.layer setCornerRadius:5.0f];
    self.backGroundView.layer.masksToBounds = YES;
    
    [self addSubview:self.backGroundView];
    
    float titleLabel_height = 60;
    float topline_height = 0.5;
    CGSize cannelButtonSize = CGSizeMake(30, 30);
    float cannelButton_margin_left = 10;
    float textDesc_margin = 20;
    
    float topline_1_margin_bottom;
    
    float textDesc_height;
    if (self.viewHeight > self.viewWidth) {
        textDesc_height = 104;
        topline_1_margin_bottom = 40;
    }else {
        textDesc_height = 40;
        topline_1_margin_bottom = 10;
    }
    
    
    
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.viewWidth, titleLabel_height)];
    [titleLabel setText:ZCSTLocalString(@"回复")];
    [titleLabel setTextAlignment:NSTextAlignmentCenter];
    [titleLabel setBackgroundColor:UIColorFromThemeColor(ZCBgSystemWhiteLightDarkColor)];
    [titleLabel setTextColor:UIColorFromThemeColor(ZCTextMainColor)];
    [titleLabel setFont:ZCUIFontBold17];
    [self.backGroundView addSubview:titleLabel];
    

    // 线条
     UIView *topline = [[UIView alloc]initWithFrame:CGRectMake(0, titleLabel_height, self.viewWidth, topline_height)];
     topline.backgroundColor = [ZCUITools zcgetBackgroundBottomLineColor];
     [self.backGroundView addSubview:topline];
    
    
    // 右上角的删除按钮
    UIButton *cannelButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [cannelButton setFrame:CGRectMake(self.viewWidth - cannelButtonSize.width - cannelButton_margin_left, (titleLabel_height - cannelButtonSize.height)/2, cannelButtonSize.height,cannelButtonSize.width)];
    [cannelButton setImage:[ZCUITools zcuiGetBundleImage:@"zcicon_sf_close"] forState:UIControlStateNormal];
    cannelButton.imageView.contentMode = UIViewContentModeScaleAspectFit;
    [cannelButton addTarget:self action:@selector(tappedCancel) forControlEvents:UIControlEventTouchUpInside];
    [self.backGroundView addSubview:cannelButton];
    
//   输入框
    
    self.textDesc = [[ZCUIPlaceHolderTextView alloc]init];
    self.textDesc.frame = CGRectMake(textDesc_margin, CGRectGetMaxY(titleLabel.frame) + topline_height + textDesc_margin, self.viewWidth - textDesc_margin*2, textDesc_height);
    self.textDesc.placeholder = ZCSTLocalString(@"请输入您的回复内容");
    [self.textDesc setPlaceholderColor:UIColorFromThemeColor(ZCTextPlaceHolderColor)];
    [self.textDesc setFont:ZCUIFont14];
    [self.textDesc setTextColor:UIColorFromThemeColor(ZCTextMainColor)];
    self.textDesc.delegate = self;
    self.textDesc.placeholederFont = ZCUIFont14;
    self.textDesc.layer.cornerRadius = 4.0f;
    self.textDesc.layer.masksToBounds = YES;
    [self.textDesc setBackgroundColor:[ZCUITools zcgetLeftChatColor]];
    self.textDesc.textContainerInset = UIEdgeInsetsMake(10, 10, 0, 10);
    [self.backGroundView addSubview:self.textDesc];
    
    if(isRTLLayout()){
        [self.textDesc setTextAlignment:NSTextAlignmentRight];
    }
    
//    选择照片
//    UIView *view = [[UIView alloc]init];
//    view.frame = CGRectMake(20, CGRectGetMaxY(self.textDesc.frame) + 10, 75, 60);
//    view.backgroundColor = [UIColor grayColor];
//    [self.backGroundView addSubview:view];
    
    self.fileScrollView = [[UIScrollView alloc]init];
    self.fileScrollView.frame = CGRectMake(20, CGRectGetMaxY(self.textDesc.frame) + 20, ScreenWidth - topline_1_margin_bottom, 70);
    self.fileScrollView.scrollEnabled = YES;
    self.fileScrollView.userInteractionEnabled = YES;
    self.fileScrollView.pagingEnabled = NO;
    self.fileScrollView.backgroundColor = [UIColor clearColor];
    [self.backGroundView addSubview:self.fileScrollView];
    
    [self reloadScrollView];
    
//   线条
    UIView *topline_1 = [[UIView alloc]initWithFrame:CGRectMake(0, CGRectGetMaxY(self.fileScrollView.frame) + 40, self.viewWidth, topline_height)];
    topline_1.backgroundColor =[ZCUITools zcgetCommentButtonLineColor];
    [self.backGroundView addSubview:topline_1];
    
    
//    提交按钮
    submitButton = [[UIButton alloc]init];
    submitButton.frame = CGRectMake(20, CGRectGetMaxY(topline_1.frame) + 10, self.viewWidth - 40, 44);
    submitButton.backgroundColor = [ZCUITools zcgetLeaveSubmitImgColor];
    submitButton.layer.cornerRadius = 22;
    [submitButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [submitButton setTitle:ZCSTLocalString(@"提交") forState:UIControlStateNormal];
    [submitButton addTarget:self action:@selector(submitButtonClick) forControlEvents:UIControlEventTouchUpInside];
    submitButton.titleLabel.font = [UIFont boldSystemFontOfSize:17];
    
    [self.backGroundView addSubview:submitButton];

    
    
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyBoardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyBoardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    
//    self.userInteractionEnabled = YES;
    UITapGestureRecognizer * tapGesture_1 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGestureClick_1)];
    [self.backGroundView addGestureRecognizer:tapGesture_1];
    
    
//    self.userInteractionEnabled = YES;
    UITapGestureRecognizer * tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGestureClick)];
    [self.backGroundView addGestureRecognizer:tapGesture];

}

- (void)tapGestureClick_1{
    
    [self tappedCancel:YES];
    
}

- (void)tapGestureClick{
    
    [[[UIApplication sharedApplication] keyWindow] endEditing:YES];
}

#pragma mark - 显示

- (void)showInView:(UIView *)view{
    
    [view addSubview:self];
    
    [UIView animateWithDuration:0.25f animations:^{
        float bottomHeight = 0.0;
        if (![ZCUICore getUICore].kitInfo.navcBarHidden) {
            bottomHeight = 44 + 30;
        }
        float x = 0;
        float h = CGRectGetMaxY(submitButton.frame) + XBottomBarHeight + bottomHeight;
        float y = self.viewHeight - h;
        float w = self.backGroundView.frame.size.width;
        self.backGroundView.frame = CGRectMake(x,y,w,h);
        
    } completion:^(BOOL finished) {
        
    }];
}

#pragma mark - 点击
- (void)submitButtonClick{
    
//    判断输入框是否为空 请填写回复内容
    if(self.textDesc.text.length == 0 || zcLibTrimString(self.textDesc.text).length == 0){
    
        [[ZCUIToastTools shareToast] showToast:ZCSTLocalString(@"回复内容不能为空") duration:1.0 view:self position:ZCToastPositionCenter];
        
        return;
    }
    
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    [dic setValue:zcLibConvertToString(self.textDesc.text) forKey:@"replyContent"];
    [dic setObject:zcLibConvertToString(self.ticketId) forKey:@"ticketId"];
    [dic setObject:zcLibConvertToString([self getCurConfig].companyID) forKey:@"companyId"];
    if(_imageArr.count>0){
        NSString *fileStr = @"";
        for (NSDictionary *model in _imageArr) {
            fileStr = [fileStr stringByAppendingFormat:@"%@;",zcLibConvertToString(model[@"fileUrl"])];
        }
        
        fileStr = [fileStr substringToIndex:fileStr.length-1];
        [dic setObject:zcLibConvertToString(fileStr) forKey:@"fileStr"];
    }
    
    __block ZCReplyLeaveView *saveSelf = self;
      [[ZCLibServer getLibServer] replyLeaveMessage:[[ZCPlatformTools sharedInstance] getPlatformInfo].config replayParam:dic start:^{
          
      } success:^(NSDictionary *dict, NSMutableArray *itemArray, ZCNetWorkCode sendCode) {
//          _isSend = NO;
          // 回复成功
//          [[ZCUIToastTools shareToast] showToast:ZCSTLocalString(@"客服已经成功收到您的问题，请耐心等待") duration:1.0f view:saveSelf position:ZCToastPositionCenter];
          [self tappedCancel:YES];
          
          
          if ([self.delegate respondsToSelector:@selector(replySuccess)]) {
              [self.delegate replySuccess];
          }
          
          
      } failed:^(NSString *errorMessage, ZCNetWorkCode errorCode) {
//          _isSend = NO;
          
          [[ZCUIToastTools shareToast] showToast:ZCSTLocalString(@"提交失败") duration:1.0f view:saveSelf position:ZCToastPositionCenter];
      }];
    
    
}

#pragma mark - 键盘收起
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    
    return [textField resignFirstResponder];
}


#pragma mark - tools
-(ZCLibConfig *)getCurConfig{
    return [[ZCPlatformTools sharedInstance] getPlatformInfo].config;
}

#pragma mark - 隐藏

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
    
    if ([self.delegate respondsToSelector:@selector(closeWithReplyStr:)]) {
        [self.delegate closeWithReplyStr:self.textDesc.text];
    }
    
    [self tappedCancel:YES];
}

/**
 *  关闭弹出层
 */
- (void)tappedCancel:(BOOL) isClose{
    // 移除通知
    [[NSNotificationCenter defaultCenter]removeObserver:self];
    
//    [UIView animateWithDuration:0 animations:^{
        [self.backGroundView setFrame:CGRectMake(_backGroundView.frame.origin.x,self.viewHeight ,self.backGroundView.frame.size.width,self.backGroundView.frame.size.height)];
//        self.alpha = 0;
//    } completion:^(BOOL finished) {
//        if (finished) {
            [self removeFromSuperview];
//        }

}

#pragma mark - 键盘事件

-(void)keyBoardWillShow:(NSNotification *) notification{
//    isKeyBoardShow = YES;
    
    float animationDuration = [[[notification userInfo] valueForKey:UIKeyboardAnimationDurationUserInfoKey] floatValue];
    CGFloat keyboardHeight = [[[notification userInfo] objectForKey:@"UIKeyboardBoundsUserInfoKey"] CGRectValue].size.height;
    NSNumber *curve = [notification.userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey];
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:animationDuration];
    [UIView setAnimationCurve:[curve intValue]];
    [UIView setAnimationDelegate:self];
    {
        CGRect  sheetViewFrame = self.backGroundView.frame;
        float h = XBottomBarHeight;
        sheetViewFrame.origin.y = self.viewHeight - keyboardHeight - self.backGroundView.frame.size.height + h;
        self.backGroundView.frame = sheetViewFrame;
    }
    
    // commit animations
    [UIView commitAnimations];
}

//键盘隐藏
- (void)keyBoardWillHide:(NSNotification *)notification {
  
    
    float animationDuration = [[[notification userInfo] valueForKey:UIKeyboardAnimationDurationUserInfoKey] floatValue];
    [UIView beginAnimations:@"bottomBarDown" context:nil];
    [UIView setAnimationDuration:animationDuration];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
    [UIView commitAnimations];
    [UIView animateWithDuration:0.25 animations:^{
        CGRect sheetFrame = self.backGroundView.frame;
        sheetFrame.origin.y = self.viewHeight - self.backGroundView.frame.size.height;
        
        self.backGroundView.frame = sheetFrame;
    }];
}

#pragma mark - 手势冲突的代理

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    
    if ([touch.view isKindOfClass:[UIButton class]]  ||  [touch.view isMemberOfClass:[UIImageView class]]){
        return NO;
    }
    return YES;
}

#pragma mark - 增加 图片附件
- (void)reloadScrollView{
    
    // 先移除，后添加
    [[self.fileScrollView subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    // 加一是为了有个添加button
    NSUInteger assetCount = self.imageArr.count +1 ;
    
    CGFloat width = (self.fileScrollView.frame.size.width - 5*3)/4;
    CGFloat heigth = 60;
    NSUInteger countX = 0;
    CGFloat x = 0;
    if(isRTLLayout()){
       countX = (assetCount < 4) ? 4 : assetCount;
    }
    for (NSInteger i = 0; i < assetCount; i++) {
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.imageView.contentMode = UIViewContentModeScaleAspectFill;
        x=(width + 5)*i;
        if(isRTLLayout()){
            x = (width + 5)* (countX - i - 1);
        }
        btn.frame = CGRectMake(x,0, width, heigth);
        btn.layer.cornerRadius = 2;
        btn.layer.masksToBounds = YES;
        
        self.imageView.frame = btn.frame;
        
        // UIButton
        if (i == self.imageArr.count){
            // 最后一个Button
            [btn setImage: [ZCUITools zcuiGetBundleImage:@"zcicon_add_photo"]  forState:UIControlStateNormal];
            // 添加图片的点击事件
            [btn addTarget:self action:@selector(photoSelecte) forControlEvents:UIControlEventTouchUpInside];
            if (assetCount == 11) {
                btn.frame = CGRectZero;
                assetCount = 10;
            }
            [btn.imageView setContentMode:UIViewContentModeScaleAspectFit];
        }else{
            [btn.imageView setContentMode:UIViewContentModeScaleAspectFill];
            // 就从本地取
//            ZCUploadImageModel *model = [_imageArr objectAtIndex:i];
            if(zcLibCheckFileIsExsis([_imagePathArr objectAtIndex:i])){
                UIImage *localImage=[UIImage imageWithContentsOfFile:[_imagePathArr objectAtIndex:i]];
                [btn setImage:localImage forState:UIControlStateNormal];
            }
            
            NSDictionary *imgDic = [_imageArr objectAtIndex:i];
            NSString *imgFileStr =  zcLibConvertToString(imgDic[@"cover"]);
            if (imgFileStr.length>0) {
                UIImage *localImage=[UIImage imageWithContentsOfFile:imgFileStr];
                [btn setImage:localImage forState:UIControlStateNormal];
            }
            
            
            btn.tag = 100+i;
            // 点击放大图片，进入图片
            [btn addTarget:self action:@selector(tapBrowser:) forControlEvents:UIControlEventTouchUpInside];
                btn.layer.borderColor = UIColorFromThemeColor(ZCBgLineColor).CGColor;
            
            
        }
//
        
        
        [self.fileScrollView addSubview:btn];
        
        if (i != self.imageArr.count){
            UIButton *btnDel = [UIButton buttonWithType:UIButtonTypeCustom];
            btnDel.imageView.contentMode = UIViewContentModeScaleAspectFit;
            x = (width + 5)*i + width - 24;
            if(isRTLLayout()){
                x = (width + 5)* (countX - i - 1) + width - 24;
            }
            
            btnDel.frame = CGRectMake(x,4, 20, 20);
            [btnDel setImage:[ZCUITools zcuiGetBundleImage:@"zcicon_close_down"] forState:0];
            btnDel.tag = 100 + i;
            // 点击放大图片，进入图片
            [btnDel addTarget:self action:@selector(tapDelFiles:) forControlEvents:UIControlEventTouchUpInside];
            [self.fileScrollView addSubview:btnDel];
        }
    }
    
    
    if(assetCount >= 4){
        self.fileScrollView.scrollEnabled = YES;
    }else{
        self.fileScrollView.scrollEnabled = NO;
    }
    // 设置contentSize
    self.fileScrollView.contentSize = CGSizeMake((width+5)*assetCount, CGRectGetMaxY([[self.fileScrollView.subviews lastObject] frame]));
    if(assetCount > 4){
        if(isRTLLayout()){
            [self.fileScrollView setContentOffset:CGPointMake(0, 0)];
        }else{
            [self.fileScrollView setContentOffset:CGPointMake(self.fileScrollView.contentSize.width - self.fileScrollView.frame.size.width, 0)];
        }
    }
}

#pragma mark - 选择图片相关

// 添加图片
- (void)photoSelecte{

    ZCActionSheet *mysheet = [[ZCActionSheet alloc] initWithDelegate:self selectedColor:nil CancelTitle:ZCSTLocalString(@"取消") OtherTitles:ZCSTLocalString(@"拍摄"), ZCSTLocalString(@"从相册选择"),nil];
    [mysheet show];
    
    [_textDesc resignFirstResponder];
}


//预览图片
- (void)tapBrowser:(UIButton *)btn{
    
    if([self.delegate respondsToSelector:@selector(replyLeaveViewPreviewImg:)]){
        [self.delegate replyLeaveViewPreviewImg:btn];
    }
    
    [_textDesc resignFirstResponder];
}


//
- (void)tapDelFiles:(UIButton *)btn{
    delButton = btn;
    [_textDesc resignFirstResponder];
    
    NSString *tip = ZCSTLocalString(@"要删除这张图片吗？");
    NSInteger currentInt = btn.tag - 100;
    if(currentInt < _imagePathArr.count){
        NSString *file  = _imagePathArr[currentInt];
        if([file hasSuffix:@".mp4"]){
            tip = ZCSTLocalString(@"要删除这个视频吗?");
        }
    }
    ZCActionSheet *mysheet = [[ZCActionSheet alloc] initWithDelegate:self selectedColor:UIColorFromRGB(TextCleanMessageColor) showTitle:tip CancelTitle:ZCSTLocalString(@"取消") OtherTitles:ZCSTLocalString(@"删除"), nil];
    mysheet.tag = 3;
    mysheet.selectIndex = 2;
    [mysheet show];
}

- (void)actionSheet:(ZCActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    if(actionSheet.tag == 3){
        if(buttonIndex == 2){
            if ([self.delegate respondsToSelector:@selector(replyLeaveViewDeleteImg:)]) {
               [self.delegate replyLeaveViewDeleteImg:delButton.tag];
           }
        }
    }else{
    //  拍摄，从相册选图片 换一下
        if (buttonIndex == 1) {
            buttonIndex = 2;
        }else if (buttonIndex == 2){
            buttonIndex = 1;
        }
        
        if ([self.delegate respondsToSelector:@selector(replyLeaveViewPickImg:)]) {
            [self.delegate replyLeaveViewPickImg:buttonIndex];
        }
    }
}





@end
