//
//  ZCTextChatCell.m
//  SobotApp
//
//  Created by 张新耀 on 15/9/15.
//  Copyright (c) 2015年 com.sobot.chat. All rights reserved.
//

#import "ZCChatAllRichCell.h"
#import "SobotXHImageViewer.h"
#import "ZCLibGlobalDefine.h"
#import "ZCActionSheet.h"
#import "ZCUIToastTools.h"
#import "ZCUIColorsDefine.h"
#import "ZCPlatformTools.h"
#import "ZCIMChat.h"
#import "ZCHtmlCore.h"
#import "ZCLocalStore.h"
#import "ZCToolsCore.h"
#import "SobotImageView.h"
#import "ZCUICore.h"
#import "ZCVideoPlayer.h"
#import "ZCObjButton.h"

#define MidImageHeight 110
@interface ZCChatAllRichCell()<ZCMLEmojiLabelDelegate,SobotXHImageViewerDelegate,ZCActionSheetDelegate>{
    NSString    *callURL;
    NSString *_coderURLStr;
    SobotXHImageViewer *_imageViewer;
}

@property(nonatomic,strong) ZCMLEmojiLabel *lblTextMsg;
@property(nonatomic,strong) UIView *richContentView;
@property(nonatomic,strong) UIMenuController *menuController;

@end


@implementation ZCChatAllRichCell

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self=[super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if(self){
        UITapGestureRecognizer *tapG = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tap)];
        tapG.delegate = self;
        [self.ivBgView addGestureRecognizer:tapG];
        
        self.userInteractionEnabled = YES;
        
        _richContentView = [[UIView alloc] init];
        _richContentView.userInteractionEnabled = YES;
        _richContentView.backgroundColor = UIColor.clearColor;
        [self.contentView addSubview:_richContentView];
        
        _lblTextMsg = [ZCChatBaseCell createRichLabel];
        _lblTextMsg.userInteractionEnabled = YES;
        UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(doLongPress:)];
        [_lblTextMsg addGestureRecognizer:longPress];
    }
    return self;
}


- (void)tap
{
    //    NSLog(@"tapped");
}

#pragma mark - gesture delegate
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    return ![self.lblTextMsg containslinkAtPoint:[touch locationInView:self.lblTextMsg]];
}



#pragma mark -- 长按复制
- (void)doLongPress:(UIGestureRecognizer *)recognizer{
    if (recognizer.state != UIGestureRecognizerStateBegan) {
        return;
    }
    
    [self didChangeBgColorWithsIsSelect:YES];
    
    
    [self becomeFirstResponder];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(menuControllerWillHideWithClick) name:UIMenuControllerDidHideMenuNotification object:nil];
    
    _menuController = [UIMenuController sharedMenuController];
    UIMenuItem *copyItem = [[UIMenuItem alloc]initWithTitle:ZCSTLocalString(@"复制") action:@selector(doCopy)];
    [_menuController setMenuItems:@[copyItem]];
    [_menuController setArrowDirection:(UIMenuControllerArrowDefault)];
    // 设置frame cell的位置
    CGRect tf     = _lblTextMsg.superview.frame;
    CGRect rect = CGRectMake(tf.origin.x, tf.origin.y, tf.size.width, 1);
    
    [_menuController setTargetRect:rect inView:self];
    
    [_menuController setMenuVisible:YES animated:YES];
}

- (void)willHideEditMenu:(id)sender{
    [self didChangeBgColorWithsIsSelect:NO];
}

-(void)menuControllerWillHideWithClick{
    [self didChangeBgColorWithsIsSelect:NO];
}

- (void)didChangeBgColorWithsIsSelect:(BOOL)isSelected{
    
    if (isSelected) {
        if (self.isRight) {
            [self.ivBgView setBackgroundColor:[ZCUITools zcgetRightChatSelectdeColor]];
        }else{
            [self.ivBgView setBackgroundColor:[ZCUITools zcgetLeftChatSelectedColor]];
        }
    }else{
        if (self.isRight) {
            // 右边气泡绿色
            [self.ivBgView setBackgroundColor:[ZCUITools zcgetRightChatColor]];
        }else{
            // 左边的气泡颜色
            [self.ivBgView setBackgroundColor:[ZCUITools zcgetLeftChatColor]];
        }
        if(_menuController){
            [_menuController setTargetRect:CGRectMake(0, 0, 0, 0) inView:self];
        }
    }
    [self.ivBgView setNeedsDisplay];
    
}

//复制
-(void)doCopy{
    UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
    [pasteboard setString:self.tempModel.richModel.msg];
    if (self.delegate && [self.delegate respondsToSelector:@selector(cellItemClick:type:obj:)]) {
        [self.delegate cellItemClick:nil type:ZCChatCellClickTypeShowToast obj:nil];
    }
    [self didChangeBgColorWithsIsSelect:NO];
}


#pragma mark - UIMenuController 必须实现的两个方法
- (BOOL)canBecomeFirstResponder{
    return YES;
}

/*
 *  根据action,判断UIMenuController是否显示对应aciton的title
 */
- (BOOL)canPerformAction:(SEL)action withSender:(id)sender{
    if (action == @selector(doCopy) ) {
        return YES;
    }
    return NO;
}


/*
 // Only override drawRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
 - (void)drawRect:(CGRect)rect {
 // Drawing code
 }
 */

-(CGFloat) InitDataToView:(ZCLibMessage *)model time:(NSString *)showTime{
    
    CGFloat bgY=[super InitDataToView:model time:showTime];
    
    CGFloat maxWidth = self.viewWidth - 100;
    
    
    // 有留言小图标
    if (model.leaveMsgFlag == 1) {
        maxWidth = maxWidth - 20;
    }
    
    CGFloat rw = maxWidth;
    if ([ZCChatBaseCell getStatusHeight:model] >0) {
        // 显示顶踩 固定最大宽度
        rw = maxWidth;
    }
    
    _lblTextMsg.text = @"";
    
    [self.ivBgView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    [self.richContentView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    for(UIView *v in self.richContentView.subviews){
        [v removeFromSuperview];
    }
    
    // 内容上下边距12
    CGRect richFrame = CGRectMake(0, bgY + 12, rw, 0);
    _richContentView.frame = richFrame;
    CGSize s = [ZCChatAllRichCell addRichView:model width:rw with:self.richContentView msgLabel:_lblTextMsg];
    for (UIView *view in self.richContentView.subviews) {
        if([view isKindOfClass:[ZCMLEmojiLabel class]]){
            ((ZCMLEmojiLabel *)view).delegate = self;
        }else if([view isKindOfClass:[SobotImageView class]]){
            UIGestureRecognizer *tap=[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(imgTouchUpInside:)];
            [view addGestureRecognizer:tap];
            view.userInteractionEnabled = YES;
        }else if([view isKindOfClass:[ZCObjButton class]]){
            [((ZCObjButton *)view) addTarget:self action:@selector(playVideo:) forControlEvents:UIControlEventTouchUpInside];
        }else if([view isKindOfClass:[UIButton class]]){
            [((UIButton *)view) addTarget:self action:@selector(authSensitive:) forControlEvents:UIControlEventTouchUpInside];
        }
    }
    richFrame = self.richContentView.frame;
    
    CGFloat height = s.height;
    if(s.height < 21){
        height = 21;
    }
    // 上下边距12，合起来 24
    height = height + 24;
    rw = s.width + 30;
    
    CGFloat msgX = 0;
    BOOL msgTextisOneOrTwoLine = NO;
    // 0,自己，1机器人，2客服
    if(self.isRight){
        int rx = self.viewWidth- rw - 15;
        msgX = rx + 15;
        
        richFrame.origin.x = msgX;
        self.richContentView.frame = richFrame;
        [self.ivBgView setFrame:CGRectMake(rx , bgY, rw , height)];
        
    }else{
        float x = 15;
        msgX = x + 15;
        
        //2.8.0 有顶 踩
        if (model.senderType == 1 && (model.commentType == 1 || model.commentType == 2||model.commentType == 3|| model.commentType == 4)) {
            // 如果>25就可以直接追加在后面，小于25在底部
            if(height < (32*2 + 3)){
                msgTextisOneOrTwoLine = YES;
//                height = 66; // 这里先不设置 height的高度
            }
        }
        if (msgTextisOneOrTwoLine) {   // 要显示顶踩 但是高度不够66时 整体内容 居中显示
            [self.ivBgView setFrame:CGRectMake(x, bgY + (66 - richFrame.size.height )/2  , rw, height)];
            richFrame.origin.y = bgY + (66 - richFrame.size.height)/2 + 12;
        }else{
            [self.ivBgView setFrame:CGRectMake(x, bgY, rw , height)];
        }
        
        richFrame.origin.x = msgX;
        self.richContentView.frame = richFrame;
    }
    
    
    
    CGFloat sh = [self setSendStatus:self.ivBgView.frame];
    
    //    NSLog(@"msgF..%f,%f,%f,%f",self.ivBgView.frame.origin.x,self.ivBgView.frame.origin.y,self.ivBgView.frame.size.width,self.ivBgView.frame.size.height);
    
    //    NSLog(@"self.contentView... %f",ScreenWidth);
    [self isAddBottomBgView:self.ivBgView.frame msgIsOneLine:msgTextisOneOrTwoLine];
    
    if(model.includeSensitive > 0){
        // 右边气泡背景图片
        UIImage * bgImage = [ZCUITools zcuiGetBundleImage:@"zcicon_pop_green_normal_line"];
        bgImage=[bgImage resizableImageWithCapInsets:UIEdgeInsetsMake(21, 21, 21, 21)];

        self.ivBgView.image = bgImage;
        self.ivBgView.backgroundColor = UIColorFromThemeColor(ZCBgSystemWhiteLightGrayColor);
        //设置尖角
        [self.ivLayerView setImage:bgImage];
    }
//    if([ZCUITools getZCThemeStyle] == ZCThemeStyle_Dark){
//        self.ivBgView.backgroundColor = UIColorFromThemeColor(ZCBgSystemWhiteLightGrayColor);
//    }

    self.ivBgView.contentMode = UIViewContentModeScaleToFill;

    
    // 设置尖角
    [self.ivLayerView setFrame:self.ivBgView.frame];
    CALayer *layer              = self.ivLayerView.layer;
    layer.frame                 = (CGRect){{0,0},self.ivLayerView.layer.frame.size};
    self.ivBgView.layer.mask = layer;
    [self.ivBgView setNeedsDisplay];
    
    // 在画完边界view 之后在设置 实际高度位置
    if (!self.isRight) {
        if (model.senderType == 1 && (model.commentType == 1 || model.commentType == 2||model.commentType == 3|| model.commentType == 4)) {
            // 如果>25就可以直接追加在后面，小于25在底部
            if(height < (32*2 + 3)){
                msgTextisOneOrTwoLine = YES;
                height = 66;
            }
        }
    }
    
    [self setFrame:CGRectMake(0, 0, self.viewWidth, height+bgY + sh + 10)];
    return height+bgY + 10 + sh;
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
            
            if(index > 0 && self.tempModel.richModel.multiModel.interfaceRetList.count>=index){
                
                // 单独处理对象
                NSDictionary * dict = @{@"requestText": self.tempModel.richModel.multiModel.interfaceRetList[index-1][@"title"],
                                        @"question":[self getQuestion:self.tempModel.richModel.multiModel.interfaceRetList[index-1]],
                                        @"questionFlag":@"2",
                                        @"title":self.tempModel.richModel.multiModel.interfaceRetList[index-1][@"title"],
                                        @"ishotguide":@"0"
                                        };
                if ([self getZCLibConfig].isArtificial) {
                    dict = @{@"title":self.tempModel.richModel.multiModel.interfaceRetList[index-1][@"title"],@"ishotguide":@"0"};
                }
                
                if(self.delegate && [self.delegate respondsToSelector:@selector(cellItemClick:type:obj:)]){
                    [self.delegate cellItemClick:self.tempModel type:ZCChatCellClickTypeItemGuide obj: dict];
                }
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


-(void)playVideo:(ZCObjButton *)btn{
    if(self.delegate && [self.delegate respondsToSelector:@selector(cellItemClick:type:obj:)]){
        //        [self.delegate touchLagerImageView:xh with:YES];
        [self.delegate cellItemClick:self.tempModel type:ZCChatCellClickTypeTouchImageYES obj:nil];
    }
    
    NSDictionary *item =  btn.objTag;
    NSString *msg = sobotConvertToString(item[@"msg"]);
    
    UIWindow *window = [[ZCToolsCore getToolsCore] getCurWindow];
    ZCVideoPlayer *player = [[ZCVideoPlayer alloc] initWithFrame:window.bounds withShowInView:window url:[NSURL URLWithString:msg] Image:nil];
    [player showControlsView];
}


// 点击查看大图
-(void) imgTouchUpInside:(UITapGestureRecognizer *)recognizer{
    UIImageView *picTempView=(UIImageView*)recognizer.view;
    // 当前显示的为视频，不支持查看封面大图
    if(picTempView.tag == 101){
        return;
    }
    
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
    
    
    __weak ZCChatAllRichCell *weakSelf = self;
    SobotXHImageViewer *xh=[[SobotXHImageViewer alloc] initWithImageViewerWillDismissWithSelectedViewBlock:^(SobotXHImageViewer *imageViewer, UIImageView *selectedView) {
        
    } didDismissWithSelectedViewBlock:^(SobotXHImageViewer *imageViewer, UIImageView *selectedView) {
        selectedView.layer.mask = calayer;
        [selectedView setNeedsDisplay];
        [selectedView removeFromSuperview];
        
        if(weakSelf.delegate && [weakSelf.delegate respondsToSelector:@selector(cellItemClick:type:obj:)]){
            [weakSelf.delegate cellItemClick:weakSelf.tempModel type:ZCChatCellClickTypeTouchImageNO obj:self];
            //                        [self.delegate touchLagerImageView:xh with:NO];
        }
    } didChangeToImageViewBlock:^(SobotXHImageViewer *imageViewer, UIImageView *selectedView) {
        
    }];
    
    NSMutableArray *photos = [[NSMutableArray alloc] init];
    [photos addObject:newPicView];
    
    xh.delegate = self;
    xh.disableTouchDismiss = NO;
    _imageViewer = xh;
    
    [xh showWithImageViews:photos selectedView:newPicView];
    
    if(self.delegate && [self.delegate respondsToSelector:@selector(cellItemClick:type:obj:)]){
        //        [self.delegate touchLagerImageView:xh with:YES];
        [self.delegate cellItemClick:self.tempModel type:ZCChatCellClickTypeTouchImageYES obj:xh];
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
//    _tempImageView = (ZCUIXHImageViewer *)longPress.view;
    NSString *str = [[ZCToolsCore getToolsCore] coderURLStrDetectorWith:_imageViewer.currentImage];
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
        UIImageWriteToSavedPhotosAlbum(_imageViewer.currentImage, self, @selector(imageSavedToPhotosAlbum:didFinishSavingWithError:contextInfo:), nil);
    }
    else if (buttonIndex == 2){
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
        [[ZCUIToastTools shareToast] showToast:msg duration:1.0f view:_imageViewer position:ZCToastPositionCenter Image:[ZCUITools zcuiGetBundleImage:@"zcicon_successful"]];
    }
    
}


-(void)resetCellView{
    [super resetCellView];
    
    _lblTextMsg.text = @"";
    //    _sugguestLabel = nil;
//    [_tempImageView setHidden:YES];
}



+(CGFloat)getCellHeight:(ZCLibMessage *)model time:(NSString *)showTime viewWith:(CGFloat )viewWidth{
    
    CGFloat cellheith = [super getCellHeight:model time:showTime viewWith:viewWidth];
    CGFloat maxWidth = viewWidth - 100;
    
    
    if (model.leaveMsgFlag == 1) {
        maxWidth = maxWidth - 20;
    }
    
    
    CGSize s = [ZCChatAllRichCell addRichView:model width:maxWidth with:nil msgLabel:nil];
    
    
    CGFloat height = s.height;
    if(s.height < 21){
        height = 21;
    }
    height = height + 20;
    
    //2.8.0 有顶 踩
    if (model.senderType == 1 && (model.commentType == 1 || model.commentType == 2||model.commentType == 3|| model.commentType == 4)) {
        if (s.height <= 25) {
            height = height + 45;
        }
    }
    
    cellheith = cellheith +  [ZCChatBaseCell getStatusHeight:model];;
    cellheith = cellheith + height;
    
    return cellheith + 10;
}



-(NSString *)getQuestion:(NSDictionary *)model{
    if(model){
        NSMutableDictionary *recDict = [NSMutableDictionary dictionaryWithDictionary:model];
        [recDict removeObjectForKey:@"title"];
        return [ZCLocalStore DataTOjsonString:recDict];
    }
    return @"";
}

-(ZCLibConfig *) getZCLibConfig{
    //    return [ZCIMChat getZCIMChat].config;
    return [[ZCPlatformTools sharedInstance] getPlatformInfo].config;
}



+(CGSize )addRichView:(ZCLibMessage *) model width:(CGFloat ) maxWidth with:(UIView *) superView msgLabel:(ZCMLEmojiLabel *) richLabel{
    CGFloat h = 0;
    CGFloat lineSpace = [ZCUITools zcgetChatLineSpacing];
    CGFloat imgHeight = MidImageHeight;
    
    // 自己发送的消息，当前认定为敏感信息
    if(model.includeSensitive > 0 && model.senderType == 0){
        return [self getAuthSensitiveView:model  width:maxWidth with:superView msgLabel:richLabel];
    }
    
    // 记录实际最大宽度
    CGFloat contentWidth = 0;
    if(model==nil || model.richModel.richMsgList==nil || [model.richModel.richMsgList isKindOfClass:[NSNull class]] || model.richModel.richMsgList.count == 0){
        #pragma mark 标题+内容
        NSString *text = @"";
        if (model.richModel.multiModel.templateIdType == 4 && model.displayMsgAttr==nil) {
            text = sobotConvertToString([model getModelDisplayText:YES]);
        }else{
            text = sobotConvertToString([model getModelDisplayText]);
        }
        // 3.0.9兼容旧版本机器人语音显示空白问题
        if(sobotConvertToString(text).length == 0 && sobotConvertToString(model.richModel.msgtranslation).length > 0){
            text = sobotConvertToString(model.richModel.msgtranslation);
            
        }
        if(text.length > 0){
            ZCMLEmojiLabel *label = nil;
            if(richLabel){
                label = richLabel;
            }else{
                label = [ZCChatBaseCell createRichLabel];
            }
            
            if([ZCChatBaseCell isRightChat:model]){
                [label setTextColor:[ZCUITools zcgetRightChatTextColor]];
                [label setLinkColor:[ZCUITools zcgetChatRightlinkColor]];
            }else{
                [label setTextColor:[ZCUITools zcgetLeftChatTextColor]];
                [label setLinkColor:[ZCUITools zcgetChatLeftLinkColor]];
            }
            
            if(model.displayMsgAttr == nil || model.displayMsgAttr.length == 0){
                [label setText:text];
            }else{
                [self setDisplayAttributedString:model.displayMsgAttr label:label model:model guide:NO];
            }
            CGSize s = [label preferredSizeWithMaxWidth:maxWidth];
            h = h + s.height + lineSpace;
            if(contentWidth < s.width){
                contentWidth = s.width;
            }
            
            if(superView){
                CGRect f = CGRectMake(0, h - s.height - lineSpace, s.width, s.height);
                label.frame = f;
                [superView addSubview:label];
            }
        }
    }else{
        // {type:0,1,2,3,msg:}
        // 富文本数组:0：文本，1：图片，2：音频，3：视频，4：文件
        if([[ZCLibClient sobotGetAppChannel] isEqual:@"ZhiChiSobotUni"]){
            NSString *msg = [self getUniDisplayString:model.richModel.richMsgList];
            ZCMLEmojiLabel *label = nil;
            if(richLabel){
                label = richLabel;
            }else{
                label = [ZCChatBaseCell createRichLabel];
            }
            if([ZCChatBaseCell isRightChat:model]){
                [label setTextColor:[ZCUITools zcgetRightChatTextColor]];
                [label setLinkColor:[ZCUITools zcgetChatRightlinkColor]];
            }else{
                [label setTextColor:[ZCUITools zcgetLeftChatTextColor]];
                [label setLinkColor:[ZCUITools zcgetChatLeftLinkColor]];
            }
//            if(sobotConvertToString(item[@"name"]).length > 0 && sobotIsUrl(msg)){
//                [label setText:sobotConvertToString(item[@"name"])];
//                [label addLinkToURL:[NSURL URLWithString:sobotConvertToString(msg)] withRange:NSMakeRange(0, sobotConvertToString(item[@"name"]).length)];
//            }else{
                [label setText:msg];
//            }
            
            CGSize s = [label preferredSizeWithMaxWidth:maxWidth];
            h = h + s.height + lineSpace;
            if(contentWidth < s.width){
                contentWidth = s.width;
            }
            
            if(superView){
                
                
                CGRect f = CGRectMake(0, h - s.height - lineSpace, s.width, s.height);
                label.frame = f;
                [superView addSubview:label];
            }
        }else{
            for (int i=0;i<model.richModel.richMsgList.count;i++) {
                NSDictionary *item =  model.richModel.richMsgList[i];
                int type = [item[@"type"] intValue];
                
                NSString *msg = sobotConvertToString(item[@"msg"]);
                if([@"<br>" isEqual:msg] || [@"<br/>" isEqual:msg]){
                    continue;
                }
    //            while ([msg hasPrefix:@"\n"]){
    //                msg = [msg substringFromIndex:1];
    //            }
                
                if(type == 0 || type == 2 || type == 4){
                    ZCMLEmojiLabel *label = nil;
                    if(model.richModel.richMsgList.count == 1 && richLabel){
                        label = richLabel;
                    }else{
                        label = [ZCChatBaseCell createRichLabel];
                    }
                    UIColor *textColor = [ZCUITools zcgetLeftChatTextColor];
                    UIColor *linkColor = [ZCUITools zcgetChatLeftLinkColor];
                    if([ZCChatBaseCell isRightChat:model]){
                        textColor = [ZCUITools zcgetRightChatTextColor];
                        linkColor = [ZCUITools zcgetChatRightlinkColor];
                    }
                    [label setTextColor:textColor];
                    [label setLinkColor:linkColor];
                    
                    
                    // 2：音频，3：视频，4：文件
                    if(type == 2|| type == 3 || type == 4){
                        if(!sobotIsUrl(msg,@"")){
                            continue;
                        }
                    }
                    if(sobotConvertToString(item[@"name"]).length > 0 && sobotIsUrl(msg,[ZCUITools zcgetUrlRegular])){
                        [label setText:[ZCHtmlCore filterHTMLTag:sobotConvertToString(item[@"name"])]];
                        [label addLinkToURL:[NSURL URLWithString:sobotConvertToString(msg)] withRange:NSMakeRange(0, [ZCHtmlCore filterHTMLTag:sobotConvertToString(item[@"name"])].length)];
                    }else{
                        NSMutableAttributedString *attr = item[@"attr"];
                        if(attr){
                            [self setDisplayAttributedString:attr label:label model:model guide:NO];
                        }else{
                            // 最后一行过滤所有换行，不是最后一行过滤一个换行
                            if(i == (model.richModel.richMsgList.count-1)){
                                while ([msg hasSuffix:@"\n"]){
                                    msg = [msg substringToIndex:msg.length - 1];
                                }
                            }else{
                //                if ([msg hasSuffix:@"\n"]){
                //                    msg = [msg substringToIndex:msg.length - 1];
                //                }
                            }
                            msg = [ZCUITools removeAllHTMLTag:msg];
                            
                            [label setText:msg];
                        }
                    }
                    
                    CGSize s = [label preferredSizeWithMaxWidth:maxWidth];
                    h = h + s.height + lineSpace;
                    if(contentWidth < s.width){
                        contentWidth = s.width;
                    }
                    
                    if(superView){
                        
                        
                        CGRect f = CGRectMake(0, h - s.height - lineSpace, s.width, s.height);
                        label.frame = f;
                        [superView addSubview:label];
                    }
                }
                if(type == 1 || type == 3){
                    if(!sobotIsUrl(msg,[ZCUITools zcgetUrlRegular])){
                        continue;
                    }
                    h = h + imgHeight + lineSpace;
                    if(contentWidth < maxWidth){
                        contentWidth = maxWidth;
                    }
                    if(superView){
                        SobotImageView *imgView = [[SobotImageView alloc] initWithFrame:CGRectMake(0, h -imgHeight - lineSpace, maxWidth, imgHeight)];
                        [imgView setContentMode:UIViewContentModeScaleAspectFill];
                        [imgView.layer setCornerRadius:4.0f];
                        [imgView.layer setMasksToBounds:YES];
                        [imgView loadWithURL:[NSURL URLWithString:msg] placeholer:[ZCUITools zcuiGetBundleImage:@"zcicon_default_goods_1"]];
                        [superView addSubview:imgView];
                        
                        if(type == 3){
                            [imgView loadWithURL:[NSURL URLWithString:@"https://img.sobot.com/chat/common/res/83f5636f-51b7-48d6-9d63-40eba0963bda.png"] placeholer:[ZCUITools zcuiGetBundleImage:@"zcicon_default_goods_1"]];
                            // 设置一个特殊的tag，不支持点击查看大图
                            imgView.tag = 101;
                            ZCObjButton *_playButton = [ZCObjButton buttonWithType:UIButtonTypeCustom];
                            _playButton.objTag = item;
                            [_playButton setImage:[ZCUITools zcuiGetBundleImage:@"zcicon_video_play"] forState:0];
                            [_playButton setFrame:CGRectMake(0, 0, 30, 30)];
                            [_playButton setBackgroundColor:UIColor.clearColor];
                            [superView addSubview:_playButton];
                            _playButton.center = imgView.center;
                        }
                    }
                }
            }
        }
        
    }
    
    if(sobotConvertToString([model getModelDisplaySugestionText]).length > 0){
//    if(model.displaySugestionattr){
        ZCMLEmojiLabel *label = [ZCChatBaseCell createRichLabel];
        
        UIColor *textColor = [ZCUITools zcgetLeftChatTextColor];
        UIColor *linkColor = [ZCUITools zcgetChatLeftLinkColor];
        if([ZCChatBaseCell isRightChat:model]){
            textColor = [ZCUITools zcgetRightChatTextColor];
            linkColor = [ZCUITools zcgetChatRightlinkColor];
        }
        [label setLinkColor:linkColor];
        [label setTextColor:textColor];
        if(model.displaySugestionattr!=nil){
            [self setDisplayAttributedString:model.displaySugestionattr label:label model:model guide:YES];
        }else{
            [ZCHtmlCore filterHtml:[model getModelDisplaySugestionText] result:^(NSString * _Nonnull text1, NSMutableArray * _Nonnull arr, NSMutableArray * _Nonnull links) {
                if (text1 != nil && text1.length > 0) {
                    label.attributedText =    [ZCHtmlFilter setGuideHtml:text1 attrs:arr view:label textColor:textColor textFont:[ZCUITools zcgetKitChatFont] linkColor:linkColor];
                }else{
                    label.attributedText =   [[NSAttributedString alloc] initWithString:@""];
                }
            }];
        }
        
        
        CGSize s = [label preferredSizeWithMaxWidth:maxWidth];
        // 添加行间距
        h = h + s.height + lineSpace;
        if(contentWidth < s.width){
            contentWidth = s.width;
        }
        
        if(superView){
            CGRect f = CGRectMake(0, h - s.height - lineSpace, s.width, s.height);
            label.frame = f;
            [superView addSubview:label];
        }
        
        
        if([model.richModel.richmoreurl isEqual:@"zc_refresh_newdata"]){
            
            if(superView){
                // 有换一组的时候，需要最大宽度
                contentWidth = maxWidth;
                
                // 添加线条
                UIView *_lineView  = [[UIView alloc] init];
                CGRect lineF = CGRectMake(0, h + 12 - lineSpace, contentWidth , 1);
                [_lineView setFrame:lineF];
                _lineView.backgroundColor = [ZCUITools zcgetLineRichColor];
                [superView addSubview:_lineView];
                
                NSString *linkText = ZCSTLocalString(@"换一组");
                ZCMLEmojiLabel *refreshLabel = [ZCChatBaseCell createRichLabel];
                if([ZCChatBaseCell isRightChat:model]){
                    [refreshLabel setTextColor:[ZCUITools zcgetRightChatTextColor]];
                    [refreshLabel setLinkColor:[ZCUITools zcgetChatRightlinkColor]];
                }else{
                    [refreshLabel setTextColor:[ZCUITools zcgetLeftChatTextColor]];
                    [refreshLabel setLinkColor:[ZCUITools zcgetChatLeftLinkColor]];
                }
                [refreshLabel setText:linkText];
                
                [refreshLabel setTextAlignment:NSTextAlignmentCenter];
                [refreshLabel setFont:ZCUIFontBold12];
                [superView addSubview:refreshLabel];
                
                
                UIImageView *img = [[UIImageView alloc] initWithImage:[ZCUITools zcuiGetBundleImage:@"zcicon_refreshbar_new"] ];
                
                [img setFrame:CGRectMake(contentWidth/2 - 38, 10, 10, 10)];
                [refreshLabel addSubview:img];
                
                [refreshLabel addLinkToURL:[NSURL URLWithString:model.richModel.richmoreurl] withRange:NSMakeRange(0, linkText.length)];
        //        CGSize size = [[self lookMoreLabel]preferredSizeWithMaxWidth:maxWidth];
                refreshLabel.frame = CGRectMake(0, CGRectGetMaxY(lineF) + 5, contentWidth, 30);
            }
            h = h + 12 + 30 + 10;
        }
    }
    
    
    
    if(superView){
        CGRect f = superView.frame;
        f.size.width = contentWidth;
        f.size.height = h - lineSpace;
        [superView setFrame:f];
    }
    return CGSizeMake(contentWidth, h - lineSpace);
}


+(NSString *)getUniDisplayString:(NSArray *) arr{
    NSString *text = @"";
    for (int i=0;i<arr.count;i++) {
        NSDictionary *item =  arr[i];
//        int type = [item[@"type"] intValue];
        
        NSString *msg = sobotConvertToString(item[@"msg"]);
        msg = [ZCHtmlCore filterHTMLTag:msg];
        msg = [ZCUITools removeAllHTMLTag:msg];
        
        text = [NSString stringWithFormat:@"%@%@",text,msg];
    }
    while ([text hasPrefix:@"\n"]){
        text = [text substringFromIndex:1];
    }
    
    if ([text hasSuffix:@"\n"]){
        text = [text substringToIndex:text.length - 1];
    }
    return text;
}



/// 仅支持文本
/// @param message  当前消息体
/// @param maxWidth  最大宽度
/// @param superView  要添加的父类
/// @param richLabel  要展示的label
+(CGSize ) getAuthSensitiveView:(ZCLibMessage *) message width:(CGFloat ) maxWidth with:(UIView *) superView msgLabel:(ZCMLEmojiLabel *) richLabel{
    CGFloat h = 10;
    CGFloat lineSpace = [ZCUITools zcgetChatLineSpacing];
    NSString *text = sobotConvertToString([message getModelDisplayText]);
//    text = @"阿伺服电机暗室逢灯时代峰峻卡算法发生客户水电费看哈世纪东方哈开个会电饭锅SDK啊就是导航饭卡是否打开拉黑速度快发货撒地方哈弗卡的很国风大赏咖啡馆哈第三方是否打开哈士大夫哈里斯的国风大赏时代峰峻奥克斯的附近啊是的发伺服电机是打发时间大法师打发";
    CGFloat contentWidth = maxWidth - 20;
    if(!richLabel){
        richLabel = [ZCChatBaseCell createRichLabel];
    }
    [richLabel setTextColor:UIColorFromThemeColor(ZCTextSubColor)];
    [richLabel setText:text];
    CGSize s = [richLabel preferredSizeWithMaxWidth:contentWidth - 20];
    BOOL isShowExport = NO;
    if(s.height > 60 && !message.showAllMessage){
        isShowExport = YES;
        s.height = 60;
    }
    h = h + s.height + 10 + lineSpace;
    if(contentWidth < s.width){
        contentWidth = s.width;
    }
    
//    NSString *warningTips = [ZCUITools removeAllHTMLTag:sobotConvertToString(message.sentisiveExplain)];
    NSString *warningTips = sobotConvertToString(message.sentisiveExplain);
    if(superView){
        UIImageView *ivBg = [[UIImageView alloc] initWithFrame:CGRectMake(0, 10, contentWidth, s.height + 20)];
        if(isShowExport){
            ivBg.frame = CGRectMake(0, 10, contentWidth , h + 26);
        }
        ivBg.layer.cornerRadius = 2.0f;
        ivBg.layer.masksToBounds = YES;
        ivBg.backgroundColor = UIColorFromThemeColor(ZCBgLightGrayDarkColor);
        [superView addSubview:ivBg];
        
        CGRect f = CGRectMake(10, h - s.height, s.width, s.height);
        richLabel.frame = f;
        [superView addSubview:richLabel];
        
        // 显示展示更多
        if(isShowExport){
            ZCMLEmojiLabel *tipLabel = [ZCChatBaseCell createRichLabel];
            tipLabel.frame = CGRectMake(0, h - 20, contentWidth, 56);
            tipLabel.textAlignment = NSTextAlignmentCenter;
            [tipLabel setLinkColor:UIColorFromThemeColor(ZCThemeColor)];
            [tipLabel setText:ZCSTLocalString(@"展开消息")];
            [tipLabel addLinkToURL:[NSURL URLWithString:@"sobot://showallsensitive"] withRange:NSMakeRange(0, ZCSTLocalString(@"展开消息").length)];
//            [tipLabel preferredSizeWithMaxWidth:contentWidth];
            [self viewBeizerRect:tipLabel.bounds view:tipLabel corner:UIRectCornerBottomLeft|UIRectCornerBottomRight cornerRadii:CGSizeMake(2, 2)];

            UIImageView *ivBg = [[UIImageView alloc] initWithFrame:tipLabel.frame];
            [self viewBeizerRect:ivBg.bounds view:ivBg corner:UIRectCornerBottomLeft|UIRectCornerBottomRight cornerRadii:CGSizeMake(2, 2)];

            CAGradientLayer *gradientLayer = [CAGradientLayer layer];
            gradientLayer.frame = tipLabel.bounds;
            // 设置渐变颜色数组
             gradientLayer.colors = @[(__bridge id)UIColorFromThemeColorAlpha(ZCBgChatLightGrayColor,0.5).CGColor,(__bridge id)UIColorFromThemeColorAlpha(ZCBgChatLightGrayColor,0.75).CGColor,(__bridge id)UIColorFromThemeColor(ZCBgChatLightGrayColor).CGColor];
            // 渐变颜色的区间分布
             gradientLayer.locations = @[@0.25,@0.5,@1];
            // 起始位置
             gradientLayer.startPoint = CGPointMake(0, 0);
            // 结束位置
             gradientLayer.endPoint = CGPointMake(0, 1);
            [ivBg.layer addSublayer:gradientLayer];
            [superView addSubview:ivBg];
            
            [superView addSubview:tipLabel];
            h = h + 26;
        }
        // 添加灰色气泡上下20间隔
        h = h + 20;
        
        ZCMLEmojiLabel *tipLabel = [ZCChatBaseCell createRichLabel];
        [tipLabel setTextColor:UIColorFromThemeColor(ZCTextMainColor)];
        [tipLabel setText:warningTips];
        CGSize s1 = [tipLabel preferredSizeWithMaxWidth:contentWidth];
        h = h + s1.height + lineSpace;
        CGRect f1 = CGRectMake(0, h - s1.height - lineSpace, s1.width, s1.height);
        tipLabel.frame = f1;
        [superView addSubview:tipLabel];
        
        // 按钮
        if(message.includeSensitive == 2){
            ZCMLEmojiLabel *tipLabel2 = [ZCChatBaseCell createRichLabel];
            [tipLabel2 setTextColor:UIColorFromThemeColor(ZCTextWarnRedColor)];
            [tipLabel2 setText:ZCSTLocalString(@"您已拒绝发送此消息")];
            tipLabel2.textAlignment = NSTextAlignmentLeft;
            CGSize s2 = [tipLabel2 preferredSizeWithMaxWidth:contentWidth];
            if(s2.width > (contentWidth - 120)){
                s2.width = contentWidth - 120;
            }
            CGRect f2 = CGRectMake(0, h - lineSpace, s2.width, 30);
            tipLabel2.frame = f2;
            [superView addSubview:tipLabel2];
        }else{
            UIButton *btn1 = [self createAuthButton:ZCSTLocalString(@"拒绝") type:1];
            btn1.frame = CGRectMake(contentWidth - 120 - 60, h, 60, 30);
            [superView addSubview:btn1];
        }
        UIButton *btn2 = [self createAuthButton:ZCSTLocalString(@"继续发送") type:2];
        btn2.frame = CGRectMake(contentWidth - 90, h, 90, 30);
        [superView addSubview:btn2];
        h = h + 30 + lineSpace;
        
        CGRect sf = superView.frame;
        sf.size.width = contentWidth;
        sf.size.height = h - lineSpace;
        [superView setFrame:sf];
    }else{
        // 显示展示更多
        if(isShowExport){
            h = h + 26;
        }
        h = h+20;
        ZCMLEmojiLabel *tipLabel = [ZCChatBaseCell createRichLabel];
        [tipLabel setText:warningTips];
        CGSize s1 = [tipLabel preferredSizeWithMaxWidth:contentWidth];
        h = h + s1.height + lineSpace;
        
        h = h + 30 + lineSpace;
    }
    return CGSizeMake(contentWidth, h - lineSpace);
}


/// 设置圆角
/// @param rect
/// @param view
/// @param corner
/// @param radii
+(void)viewBeizerRect:(CGRect)rect view:(UIView *)view corner:(UIRectCorner)corner cornerRadii:(CGSize)radii{
    UIBezierPath *maskPath= [UIBezierPath bezierPathWithRoundedRect:rect byRoundingCorners:corner cornerRadii:radii];
    CAShapeLayer *maskLayer = [CAShapeLayer layer];
    maskLayer.frame =view.bounds;
    maskLayer.path = maskPath.CGPath;
    view.layer.mask = maskLayer;
}

+(UIButton *)createAuthButton:(NSString *)title type:(NSInteger )type{
    UIButton *_btnTurnUser =[UIButton buttonWithType:UIButtonTypeCustom];
    [_btnTurnUser setTitle:title forState:UIControlStateNormal];
    
    _btnTurnUser.layer.cornerRadius = 15.0f;
    _btnTurnUser.layer.borderWidth = 0.75f;
    _btnTurnUser.layer.masksToBounds = YES;
    [_btnTurnUser.titleLabel setFont:ZCUIFont14];
    _btnTurnUser.tag = type;
    if(type == 1){
        [_btnTurnUser setBackgroundColor:UIColorFromThemeColor(ZCBgSystemWhiteLightGrayColor)];
        _btnTurnUser.layer.borderColor = UIColorFromThemeColor(ZCBgLineColor).CGColor;
        [_btnTurnUser setTitleColor:UIColorFromThemeColor(ZCTextMainColor) forState:UIControlStateNormal];
    }else{
        [_btnTurnUser setBackgroundColor:UIColorFromThemeColor(ZCThemeColor)];
        _btnTurnUser.layer.borderColor = UIColorFromThemeColor(ZCThemeColor).CGColor;
        [_btnTurnUser setTitleColor:UIColorFromThemeColor(ZCTextSystemWhiteColor) forState:UIControlStateNormal];
        
    }
    return _btnTurnUser;
}

-(void)authSensitive:(UIButton *) button{
    if(button.tag == 1){
        // 拒绝
        if(self.delegate && [self.delegate respondsToSelector:@selector(cellItemClick:type:obj:)]){
            [self.delegate cellItemClick:self.tempModel type:ZCChatCellClickTypeRefuseSend obj:nil];
        }
    }else{
        // 继续发送
        if(self.delegate && [self.delegate respondsToSelector:@selector(cellItemClick:type:obj:)]){
            [self.delegate cellItemClick:self.tempModel type:ZCChatCellClickTypeAgreeSend obj:nil];
        }
    }
}
@end
