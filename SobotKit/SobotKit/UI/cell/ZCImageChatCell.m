//
//  ZCImageChatCell.m
//  SobotApp
//
//  Created by 张新耀 on 15/9/16.
//  Copyright (c) 2015年 com.sobot.chat. All rights reserved.
//

#import "ZCImageChatCell.h"
//#import "ZCUIXHImageViewer.h"
#import "SobotXHImageViewer.h"
#import "SobotUtils.h"
#import "ZCUIColorsDefine.h"
#import "ZCUIToastTools.h"
#import "ZCActionSheet.h"
#import "ZCPieChartView.h"
#import "ZCVideoPlayer.h"
#import "ZCToolsCore.h"
#import "ZCLibGlobalDefine.h"
#import "ZCUICore.h"
#import <AVFoundation/AVFoundation.h>
#import "ZCMLEmojiLabel.h"
#import "ZCHtmlCore.h"
@interface ZCImageChatCell()<SobotXHImageViewerDelegate,ZCActionSheetDelegate,ZCMLEmojiLabelDelegate>{
    
    UIButton *_playButton;
    NSString *_coderURLStr;
    SobotXHImageViewer *_imageViewer;
    
//    2.8.0 渐变色，时间
    UIImageView *_gradientBgView;
    UILabel *_timeLabel;
}
@property (nonatomic,strong) ZCPieChartView *pieChartView;
@property (nonatomic,strong) ZCMLEmojiLabel *suglabel;

@end

@implementation ZCImageChatCell


-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self=[super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if(self){
        _ivSingleImage = [[SobotImageView alloc] init];
        [_ivSingleImage setContentMode:UIViewContentModeScaleAspectFit];
        [_ivSingleImage.layer setMasksToBounds:YES];
        [_ivSingleImage setBackgroundColor:[UIColor whiteColor]];
        [self.contentView addSubview:_ivSingleImage];
        _ivSingleImage.hidden=YES;
        
        _playButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_playButton setImage:[ZCUITools zcuiGetBundleImage:@"zcicon_video_play"] forState:0];
        [_playButton setFrame:CGRectMake(0, 0, 30, 30)];
        [_playButton setBackgroundColor:UIColor.clearColor];
        [_playButton addTarget:self action:@selector(playVideo:) forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:_playButton];
        _playButton.hidden = YES;
        
        //设置点击事件
        UITapGestureRecognizer *tapGesturer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(imgTouchUpInside:)];
        _ivSingleImage.userInteractionEnabled=YES;
        [_ivSingleImage addGestureRecognizer:tapGesturer];
    }
    return self;
}


-(CGFloat) InitDataToView:(ZCLibMessage *)model time:(NSString *)showTime{
    CGFloat height = [super InitDataToView:model time:showTime];
    _suglabel.text = @"";
    _suglabel = nil;
    _ivSingleImage.hidden=NO;
    if(model.sendStatus != 1 && _pieChartView){
        [_pieChartView invalidateTimer];
        [_pieChartView removeFromSuperview];
        _pieChartView = nil;
    }
    
    CGSize imgSize = CGSizeMake(175, ImageHeight);
    
    
    if (model.richModel.msgType == ZCMessageTypeVideo) {
        imgSize = CGSizeMake(175, 160);
        if(self.isRight){
            [_ivSingleImage setFrame:CGRectMake(self.viewWidth-imgSize.width-15, height, imgSize.width, imgSize.height)];
        }else{
            [_ivSingleImage setFrame:CGRectMake(15, height, imgSize.width, imgSize.height)];
        }
        if (!self.isRight && ![ZCUICore getUICore].getLibConfig.isArtificial) {
            [self.ivBgView setFrame:CGRectMake(15, height, imgSize.width, imgSize.height)];
        }
    }else{
        _ivSingleImage.userInteractionEnabled = YES;// 开启交互
        if(self.isRight){
            [_ivSingleImage setFrame:CGRectMake(self.viewWidth-imgSize.width-15, height, imgSize.width, imgSize.height)];
        }else{
            [_ivSingleImage setFrame:CGRectMake(15, height, imgSize.width, imgSize.height)];
        }
        if (!self.isRight && ![ZCUICore getUICore].getLibConfig.isArtificial) {
            [self.ivBgView setFrame:CGRectMake(15, height, imgSize.width, imgSize.height)];
        }
    }
    
    
    [_ivSingleImage setBackgroundColor:self.ivBgView.backgroundColor];
    [_ivSingleImage setContentMode:UIViewContentModeScaleAspectFill];
    
    
    if (!self.isRight && sobotConvertToString([model getModelDisplaySugestionText]).length > 0) {
        // 这里查看是否有关联问题
           CGFloat h = 0;
           CGFloat lineSpace = [ZCUITools zcgetChatLineSpacing];
           // 记录实际最大宽度
           CGFloat contentWidth = _ivSingleImage.frame.size.width;
        // 判断是否是一问多答中有关联问题
        _suglabel = [ZCChatBaseCell createRichLabel];
        _suglabel.delegate = self;
        UIColor *textColor = [ZCUITools zcgetLeftChatTextColor];
        UIColor *linkColor = [ZCUITools zcgetChatLeftLinkColor];
        if([ZCChatBaseCell isRightChat:model]){
            textColor = [ZCUITools zcgetRightChatTextColor];
            linkColor = [ZCUITools zcgetChatRightlinkColor];
        }
        [_suglabel setLinkColor:linkColor];
        [_suglabel setTextColor:textColor];
        if(model.displaySugestionattr!=nil){
            [ZCImageChatCell setDisplayAttributedString:model.displaySugestionattr label:_suglabel model:model guide:YES];
        }else{
            [ZCHtmlCore filterHtml:[model getModelDisplaySugestionText] result:^(NSString * _Nonnull text1, NSMutableArray * _Nonnull arr, NSMutableArray * _Nonnull links) {
                if (text1 != nil && text1.length > 0) {
                    self->_suglabel.attributedText =    [ZCHtmlFilter setGuideHtml:text1 attrs:arr view:self->_suglabel textColor:textColor textFont:[ZCUITools zcgetKitChatFont] linkColor:linkColor];
                }else{
                    self->_suglabel.attributedText =   [[NSAttributedString alloc] initWithString:@""];
                }
            }];
        }
        
        CGSize s = [_suglabel preferredSizeWithMaxWidth:self.maxWidth -45];
        // 添加行间距
        h = h + s.height + lineSpace;
        if(contentWidth < s.width){
            contentWidth = s.width;
        }
        CGRect ivSingleImageF = self.ivSingleImage.frame;
        ivSingleImageF.origin.y = ivSingleImageF.origin.y + 10;// 顶部10个间隙
        ivSingleImageF.origin.x = ivSingleImageF.origin.x +10;// 左边加10个间隙
        self.ivSingleImage.frame = ivSingleImageF;
        // height +10是间距 和引导问题 ，左边加15间距
        CGRect f = CGRectMake(15+15, h - s.height - lineSpace + CGRectGetMaxY(self.ivSingleImage.frame) +10, s.width, s.height);
        _suglabel.frame = f;
        [self.contentView addSubview:_suglabel];
        
        CGRect ivBgViewF = self.ivBgView.frame;
        ivBgViewF.size.width = contentWidth + 15;
        ivBgViewF.size.height = ivBgViewF.size.height + s.height + 30;
        self.ivBgView.frame = ivBgViewF;
        height = height +s.height +30;
    }
    
    
    // 判断图片来源，本地或网络
    if(sobotCheckFileIsExsis(model.richModel.msg)){
        UIImage *localImage=[UIImage imageWithContentsOfFile:model.richModel.msg];
//
        //发送状态，1 开始发送，2发送失败，0，发送完成
        if(model.sendStatus == 1){
            [self pieChartView];
            if(_pieChartView){
                [_pieChartView updatePercent:model.progress*100 animation:NO];
            }
            _ivSingleImage.userInteractionEnabled = NO;
        }
        [_ivSingleImage setImage:localImage];
    }else{
        if (model.richModel.msgType == ZCMessageTypeVideo) {
            [_ivSingleImage loadWithURL:[NSURL URLWithString:sobotUrlEncodedString(model.richModel.snapshot)] placeholer:[ZCUITools zcuiGetBundleImage:@"zcicon_default_goods_1"]  showActivityIndicatorView:YES];
        }else{
            [_ivSingleImage loadWithURL:[NSURL URLWithString:sobotUrlEncodedString(model.richModel.msg)] placeholer:[ZCUITools zcuiGetBundleImage:@"zcicon_default_goods_1"]  showActivityIndicatorView:YES];
        }
    }
    if(model.richModel.msgType == ZCMessageTypeVideo && _pieChartView == nil){
        _playButton.hidden = NO;
        _playButton.center = _ivSingleImage.center;

    }else{
        _playButton.hidden = YES;
    }
    
    
    
    [self isAddBottomBgView:self.ivBgView.frame msgIsOneLine:NO];
    
    // 设置尖角
    if (!self.isRight && sobotConvertToString([model getModelDisplaySugestionText]).length > 0) {
        [self.ivLayerView setFrame:self.ivBgView.frame];
        self.ivBgView.contentMode = UIViewContentModeScaleToFill;
        // 设置尖角
        [self.ivLayerView setFrame:self.ivBgView.frame];
        CALayer *layer              = self.ivLayerView.layer;
        layer.frame                 = (CGRect){{0,0},self.ivLayerView.layer.frame.size};
        self.ivBgView.layer.mask = layer;
        [self.ivBgView setNeedsDisplay];
    }else{
        if(model.includeSensitive > 0){
            // 右边气泡背景图片
            UIImage * bgImage = [ZCUITools zcuiGetBundleImage:@"zcicon_pop_green_normal_line"];
            bgImage=[bgImage resizableImageWithCapInsets:UIEdgeInsetsMake(21, 21, 21, 21)];
            self.ivBgView.image = bgImage;
            self.ivBgView.backgroundColor = UIColorFromThemeColor(ZCBgSystemWhiteLightGrayColor);
            //设置尖角
            [self.ivLayerView setImage:bgImage];
        }
        self.ivBgView.contentMode = UIViewContentModeScaleToFill;
        [self.ivLayerView setFrame:_ivSingleImage.frame];
        [self.ivBgView setImage:nil];
        [self.ivBgView setBackgroundColor:[UIColor clearColor]];
        CALayer *layer              = self.ivLayerView.layer;
        layer.frame                 = (CGRect){{0,0},self.ivLayerView.layer.frame.size};
        _ivSingleImage.layer.mask = layer;
        [_ivSingleImage setNeedsDisplay];
    }
    
    CGFloat sh = [self setSendStatus:_ivSingleImage.frame];
    height=height + ((model.richModel.msgType == ZCMessageTypeVideo) ? 160: ImageHeight) +20  + sh;
    
    [self setFrame:CGRectMake(0, 0, self.viewWidth, height )];
    return height;
}


-(void)setProgress:(CGFloat) progress{
    if(_pieChartView){
        
        [_pieChartView updatePercent:progress*100 animation:NO];
    }
}


-(void)playVideo:(UIButton *)btn{
    if(self.delegate && [self.delegate respondsToSelector:@selector(cellItemClick:type:obj:)]){
        //        [self.delegate touchLagerImageView:xh with:YES];
        [self.delegate cellItemClick:self.tempModel type:ZCChatCellClickTypeTouchImageYES obj:nil];
    }
    UIWindow *window = [[ZCToolsCore getToolsCore] getCurWindow];
    ZCVideoPlayer *player = [[ZCVideoPlayer alloc] initWithFrame:window.bounds withShowInView:window url:[NSURL URLWithString:self.tempModel.richModel.richmoreurl] Image:_ivSingleImage.image];
    [player showControlsView];
    
}

// 点击查看大图
-(void) imgTouchUpInside:(UITapGestureRecognizer *)recognizer{
    if(self.tempModel.richModel.msgType == ZCMessageTypeVideo){
        [self playVideo:nil];
        return;
    }
    //    [SobotLog logDebug:@"查看大图：%@",self.tempModel.richModel.msg];
    UIImageView *picTempView = (UIImageView*)recognizer.view;
    
//    CALayer *calayer = _picView.layer.mask;
//    [_picView.layer.mask removeFromSuperlayer];
    
    CGRect f = [picTempView convertRect:picTempView.bounds toView:nil];
    
    UIImageView *bgView = [[UIImageView alloc] init];
    [bgView setImage:self.ivLayerView.image];
    // 设置尖角
    [bgView setFrame:f];
    CALayer *layer              = bgView.layer;
    layer.frame                 = (CGRect){{0,0},bgView.layer.frame.size};
        
    SobotImageView *newPicView = [[SobotImageView alloc] init];
    newPicView.image = picTempView.image;
    newPicView.frame = f;
    newPicView.layer.masksToBounds = NO;
//    newPicView.layer.cornerRadius = 15;
    
    newPicView.layer.mask = layer;
    CALayer *calayer = newPicView.layer.mask;
    [newPicView.layer.mask removeFromSuperlayer];
    
    
    __block SobotXHImageViewer *xh = [[SobotXHImageViewer alloc] initWithImageViewerWillDismissWithSelectedViewBlock:^(SobotXHImageViewer *imageViewer, UIImageView *selectedView) {
        
    } didDismissWithSelectedViewBlock:^(SobotXHImageViewer *imageViewer, UIImageView *selectedView) {
        selectedView.layer.mask = calayer;
        [selectedView setNeedsDisplay];
        [selectedView removeFromSuperview];
        
        // 点击大图关闭
        if(self.delegate && [self.delegate respondsToSelector:@selector(cellItemClick:type:obj:)]){
            [self.delegate cellItemClick:self.tempModel type:ZCChatCellClickTypeTouchImageNO obj:xh];
            //            [self.delegate touchLagerImageView:xh with:NO];
        }
    } didChangeToImageViewBlock:^(SobotXHImageViewer *imageViewer, UIImageView *selectedView) {
    }];
    
    NSMutableArray *photos = [[NSMutableArray alloc] init];
    [photos addObject:newPicView];
    
    xh.delegate = self;
    xh.disableTouchDismiss = NO;
    _imageViewer = xh;
    [xh showWithImageViews:photos selectedView:newPicView];
    
    // 放大图片
    if(self.delegate && [self.delegate respondsToSelector:@selector(cellItemClick:type:obj:)]){
        [self.delegate cellItemClick:self.tempModel type:ZCChatCellClickTypeTouchImageYES obj:xh];
        //            [self.delegate touchLagerImageView:xh with:NO];
    }
    
    
    // 添加长按手势，保存图片
    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(longPressAction:)];
    [xh addGestureRecognizer:longPress];
}

#pragma mark -- 保存图片到相册
- (void)longPressAction:(UILongPressGestureRecognizer*)longPress{
    //    NSLog(@"长按保存");
    if (longPress.state != UIGestureRecognizerStateBegan) {
        return;
    }
    NSString *str = [[ZCToolsCore getToolsCore] coderURLStrDetectorWith:_ivSingleImage.image];
    if (str) {
        ZCActionSheet *mysheet = [[ZCActionSheet alloc] initWithDelegate:self selectedColor:nil CancelTitle:ZCSTLocalString(@"取消") OtherTitles:ZCSTLocalString(@"保存图片"),ZCSTLocalString(@"识别二维码"), nil];
        mysheet.tag = 100;
        _coderURLStr = str;
        [mysheet show];
    }else{
        ZCActionSheet *mysheet = [[ZCActionSheet alloc] initWithDelegate:self selectedColor:nil CancelTitle:ZCSTLocalString(@"取消") OtherTitles:ZCSTLocalString(@"保存图片"), nil];
        [mysheet show];
    }
    
}

- (void)actionSheet:(ZCActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex == 1) {
        // 保存图片到相册
        UIImageWriteToSavedPhotosAlbum(_ivSingleImage.image, self, @selector(imageSavedToPhotosAlbum:didFinishSavingWithError:contextInfo:), NULL);
    }
    else if (buttonIndex == 2 && actionSheet.tag == 100){
        [_imageViewer dismissWithAnimate];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            if(self.delegate && [self.delegate respondsToSelector:@selector(cellItemLinkClick:type:obj:)]){
                [self.delegate cellItemLinkClick:@"" type:ZCChatCellClickTypeOpenURL obj:_coderURLStr];
            }
        });
    }
}

- (void)imageSavedToPhotosAlbum:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo
{
    NSString *msg = nil;
    if (error != NULL) {
        //        msg = @"保存失败";
    }else{
        msg = ZCSTLocalString(@"已保存到系统相册");
        [[ZCUIToastTools shareToast] showToast:msg duration:1.0f view:_ivSingleImage position:ZCToastPositionCenter Image:[ZCUITools zcuiGetBundleImage:@"zcicon_successful"]];
    }
    
}
#pragma mark - Getters & Setters
- (ZCPieChartView *)pieChartView{
    if (!_pieChartView) {
        _pieChartView = [[ZCPieChartView alloc]initWithFrame:_ivSingleImage.bounds];
        [_pieChartView setBackgroundColor:COLORWithAlpha(0, 0, 0, 0.6)];
        [_ivSingleImage addSubview:_pieChartView];
    }
    return _pieChartView;
}


-(void)resetCellView{
    [super resetCellView];
    [_ivSingleImage.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    if(_pieChartView){
        [_pieChartView invalidateTimer];
        _pieChartView = nil;
    }
    [_ivSingleImage setImage:nil];
}


/*
 // Only override drawRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
 - (void)drawRect:(CGRect)rect {
 // Drawing code
 }
 */

+(CGFloat)getCellHeight:(ZCLibMessage *)model time:(NSString *)showTime viewWith:(CGFloat)width{
    CGFloat height = [super getCellHeight:model time:showTime viewWith:width];
    height = height +  [ZCChatBaseCell getStatusHeight:model];
    height = height + ((model.richModel.msgType == ZCMessageTypeVideo) ? 160: ImageHeight) + 20;
    // 判断是否是一问多答中有关联问题
    if(sobotConvertToString([model getModelDisplaySugestionText]).length > 0){
        ZCMLEmojiLabel *slabel = [ZCChatBaseCell createRichLabel];
        UIColor *textColor = [ZCUITools zcgetLeftChatTextColor];
        UIColor *linkColor = [ZCUITools zcgetChatLeftLinkColor];
        if(model.displaySugestionattr!=nil){
            [ZCImageChatCell setDisplayAttributedString:model.displaySugestionattr label:slabel model:model guide:YES];
        }else{
            [ZCHtmlCore filterHtml:[model getModelDisplaySugestionText] result:^(NSString * _Nonnull text1, NSMutableArray * _Nonnull arr, NSMutableArray * _Nonnull links) {
                if (text1 != nil && text1.length > 0) {
                    slabel.attributedText =    [ZCHtmlFilter setGuideHtml:text1 attrs:arr view:slabel textColor:textColor textFont:[ZCUITools zcgetKitChatFont] linkColor:linkColor];
                }else{
                    slabel.attributedText =   [[NSAttributedString alloc] initWithString:@""];
                }
            }];
        }
        CGSize s = [slabel preferredSizeWithMaxWidth:width-70-45];
        height = height + s.height + 20;
    }
    return height;
}

#pragma mark EmojiLabel链接点击事件
// 链接点击
-(void)attributedLabel:(ZCTTTAttributedLabel *)label didSelectLinkWithURL:(NSURL *)url{
    // 此处得到model 对象对应的值
    NSString *textStr = label.text;
    if (label.text) {
        if(url.absoluteString && [url.absoluteString hasPrefix:@"sobot:"]){
            int index = [[url.absoluteString stringByReplacingOccurrencesOfString:@"sobot://" withString:@""] intValue];
            if(index > 0 && self.tempModel.richModel.suggestionArr.count>=index){
                textStr = [self.tempModel.richModel.suggestionArr objectAtIndex:index-1][@"question"];
            }
        }
    }
    [self doClickURL:url.absoluteString text:textStr];
}

// 链接点击
-(void)ZCMLEmojiLabel:(ZCMLEmojiLabel *)emojiLabel didSelectLink:(NSString *)link withType:(ZCMLEmojiLabelLinkType)type{
    [self doClickURL:link text:@""];
}

// 链接点击
-(void)doClickURL:(NSString *)url text:(NSString * )htmlText{
    if(url){
        url=[url stringByReplacingOccurrencesOfString:@"\"" withString:@""];
        // 用户引导说辞的分类的点击事件
        if([url hasPrefix:@"sobot:"]){
            if([url hasPrefix:@"sobot://showallsensitive"]){
                if(self.delegate && [self.delegate respondsToSelector:@selector(cellItemClick:type:obj:)]){
                    [self.delegate cellItemClick:self.tempModel type:ZCChatCellClickTypeShowSensitive obj:nil];
                }
                return;
            }
            int index = [[url stringByReplacingOccurrencesOfString:@"sobot://" withString:@""] intValue];
            
            if(index > 0 && self.tempModel.richModel.suggestionArr.count>=index){
                if(self.delegate && [self.delegate respondsToSelector:@selector(cellItemClick:type:obj:)]){
                    [self.delegate cellItemClick:self.tempModel type:ZCChatCellClickTypeItemChecked obj:[NSString stringWithFormat:@"%d",index-1]];
                }
                return;
            }
            
        }else if ([url hasPrefix:@"robot:"]){
            // 处理 机器人回复的 技能组点选事件
//          3.0.8 如果当前 已转人工 ， 不可点击
            if([self getZCLibConfig].isArtificial){
                return;
            }
            int index = [[url stringByReplacingOccurrencesOfString:@"robot://" withString:@""] intValue];
            if(index > 0 && self.tempModel.groupList.count>=index){
                if(self.delegate && [self.delegate respondsToSelector:@selector(cellItemClick:type:obj:)]){
                    [self.delegate cellItemClick:self.tempModel type:ZCChatCellClickTypeGroupItemChecked obj:[NSString stringWithFormat:@"%d",index-1]];
                }
            }
        }else if([url hasPrefix:@"zc_refresh_newdata"]){
            if(self.delegate && [self.delegate respondsToSelector:@selector(cellItemClick:type:obj:)]){
                [self.delegate cellItemClick:self.tempModel type:ZCChatCellClickTypeNewDataGroup obj:url];
            }
        }else{
            if(self.delegate && [self.delegate respondsToSelector:@selector(cellItemLinkClick:type:obj:)]){
                [self.delegate cellItemLinkClick:htmlText type:ZCChatCellClickTypeOpenURL obj:url];
            }
        }
    }
}


-(ZCLibConfig *) getZCLibConfig{
    //    return [ZCIMChat getZCIMChat].config;
    return [[ZCPlatformTools sharedInstance] getPlatformInfo].config;
}

#pragma mark - gesture delegate
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    
    return ![self.suglabel containslinkAtPoint:[touch locationInView:self.suglabel]];
    
//    if ([touch.view isMemberOfClass:[ZCMLEmojiLabel class]]){
//        return NO;
//    }
//    return YES;
}

@end
