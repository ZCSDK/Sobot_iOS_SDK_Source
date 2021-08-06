//
//  ZCUISkillSetView.m
//  MyTextViews
//
//  Created by zhangxy on 16/1/21.
//  Copyright © 2016年 zxy. All rights reserved.
//

#import "ZCUISkillSetView.h"
#import "ZCLibGlobalDefine.h"
#import "ZCUIColorsDefine.h"
#import "ZCLibConfig.h"

#import "ZCUIImageTools.h"

#import "ZCIMChat.h"
#import "ZCPlatformTools.h"
#import "ZCUIKeyboard.h"
#import "ZCToolsCore.h"
#import "ZCUIImageView.h"

@interface ZCUISkillSetView()

@property(nonatomic,strong) UIView *backGroundView;
@property(nonatomic,strong) UIScrollView *scrollView;

@end

@implementation ZCUISkillSetView{
    void(^SkillSetClickBlock)(ZCLibSkillSet *itemModel);
    void(^CloseBlock)();
    void(^ToRobotBlock)();
    
    CGFloat viewWidth;
    CGFloat viewHeight;
    NSMutableArray *listArray;
    
//    ZCUIChatKeyboard *_keyboardView;
    ZCUIKeyboard *_keyboardView;
}


- (ZCUISkillSetView *)initActionSheet:(NSMutableArray *)array withView:(UIView *)view{
    self=[super init];
    if(self){
        
        viewWidth = view.frame.size.width;
        viewHeight = ScreenHeight;
        
        listArray = array;
        
        if(!listArray){
            listArray = [[NSMutableArray alloc] init];
        }
        
        //初始化背景视图，添加手势
        self.frame = CGRectMake(0, 0, viewWidth, viewHeight);
        self.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
        self.autoresizesSubviews = YES;
        self.backgroundColor = UIColorFromRGBAlpha(TextBlackColor, 0.6);
        self.userInteractionEnabled = YES;
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(shareViewDismiss:)];
        [self addGestureRecognizer:tapGesture];
        if(!zcLibIs_null(listArray) && listArray.count > 0){
            [self createSubviews];
        }
    }
    return self;
}


- (void)createSubviews{
    CGFloat bw=viewWidth;
    int direction = [[ZCToolsCore getToolsCore] getCurScreenDirection];
    CGFloat bx = 0;
    if(direction>0){
        bw = bw - XBottomBarHeight;
        if(direction == 2){
            bx = XBottomBarHeight;
        }
    }
    
    self.backGroundView = [[UIView alloc] initWithFrame:CGRectMake(0, viewHeight, viewWidth, 0)];
    self.backGroundView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleTopMargin;
    self.backGroundView.autoresizesSubviews = YES;
    self.backGroundView.backgroundColor = UIColorFromThemeColor(ZCBgSystemWhiteLightDarkColor);
    
//    [self.backGroundView.layer setCornerRadius:5.0f];
    self.backGroundView.layer.masksToBounds = YES;
    [self addSubview:self.backGroundView];
    
    
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(bx+40, 0, bw-80, 60)];
    [titleLabel setText:ZCSTLocalString(@"请选择要咨询的内容")];
    [titleLabel setTextAlignment:NSTextAlignmentCenter];
    [titleLabel setBackgroundColor:UIColorFromThemeColor(ZCBgSystemWhiteLightDarkColor)];
    [titleLabel setTextColor:UIColorFromThemeColor(ZCTextMainColor)];
    [titleLabel setFont:ZCUIFontBold17];
    titleLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    [self.backGroundView addSubview:titleLabel];
    
    UIButton *cannelButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [cannelButton setFrame:CGRectMake(bw - 54, 8, 44,44)];
    [cannelButton setBackgroundColor:UIColor.clearColor];
    cannelButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleBottomMargin;
    [cannelButton setImage:[ZCUITools zcuiGetBundleImage:@"zcicon_sf_close"] forState:UIControlStateNormal];
    [cannelButton addTarget:self action:@selector(tappedCancel) forControlEvents:UIControlEventTouchUpInside];
   [self.backGroundView addSubview:cannelButton];
    
    // 线条
     UIView *lineView = [[UIView alloc]initWithFrame:CGRectMake(0, 60, viewWidth, 0.5)];
    lineView.backgroundColor = [ZCUITools zcgetCommentButtonLineColor];
    lineView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
     [self.backGroundView addSubview:lineView];
    
    self.scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(bx, 60, bw, 0)];
    self.scrollView.showsVerticalScrollIndicator=YES;
    self.scrollView.bounces = NO;
    self.scrollView.backgroundColor = UIColor.clearColor;
    self.scrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    
    [self.backGroundView addSubview:self.scrollView];
    
    CGFloat startX= 15;
    CGFloat y= 20;
    
    CGFloat itemH = 35;
    CGFloat spaceW = 10;
    CGFloat spaceH = 20;
    int column = 2;
    
    //groupStyle:无值 或 0 文本样式， 1 图文样式        2 图文+描述样式
    ZCLibSkillSet *firstModel = [listArray firstObject];
    int style = firstModel.groupStyle;
    if(zcLibConvertToString(firstModel.groupGuideDoc).length>0){
        [titleLabel setText:zcLibConvertToString(firstModel.groupGuideDoc)];
    }
    if(style == 1){
        startX = 30;
        itemH = 87;
        column = 4;
    }
    else if(style == 2){
        startX = 20;
        itemH = 40;
        column = 1;
    }
    CGFloat itemW = (bw - startX*2 - spaceW*(column - 1))/column;
    CGFloat x = startX;
    int rows = listArray.count%column==0?round(listArray.count/column):round(listArray.count/column)+1;
    for (int i=0; i<listArray.count; i++) {
        UIButton *itemView = [self addItemView:listArray[i] withX:x withY:y withW:itemW withH:itemH];
        itemView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin |UIViewAutoresizingFlexibleWidth;
        [itemView setBackgroundColor:UIColorFromThemeColor(ZCBgSystemWhiteLightDarkColor)];
        itemView.userInteractionEnabled = YES;
        itemView.tag = i;
        [itemView addTarget:self action:@selector(itemClick:) forControlEvents:UIControlEventTouchUpInside];
        if((i+1)%column==0 || column == 1){
            x = startX;
            y = y + itemH + spaceH;
        }else{
            x = x + itemW + spaceW;
        }
        [self.scrollView addSubview:itemView];
    }
    CGFloat h = rows*(itemH) + (rows + 1) * spaceH;
    if(h > viewHeight*0.6){
        h = viewHeight*0.6;
    }
    [self.scrollView setFrame:CGRectMake(bx, 60, bw, h)];
    [self.scrollView setContentSize:CGSizeMake(bw, rows*itemH + (rows+1)*spaceH)];
    
    
    
    [ZCUITools addTopBorderWithColor:[ZCUITools zcgetCommentButtonLineColor] andWidth:1.0f withView:cannelButton];
    
    
    [UIView animateWithDuration:0.25f animations:^{
        [self.backGroundView setFrame:CGRectMake(self.backGroundView.frame.origin.x, viewHeight - h - 60 - 30 ,self.backGroundView.frame.size.width, h + 60 + 30)];
    } completion:^(BOOL finished) {
        
    }];
    
    // 注册通知
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(gotoRobotChat:) name:@"closeSkillView" object:nil];
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(gotoRobotChatAndLeavemeg:) name:@"gotoRobotChatAndLeavemeg" object:nil];
    
}
-(void)addBorderWithColor:(UIColor *)color isBottom:(BOOL) isBottom with:(UIView *) view{
    CGFloat borderWidth = 0.75f;
    CALayer *border = [CALayer layer];
    border.backgroundColor = color.CGColor;
    if(isBottom){
        border.frame = CGRectMake(0, view.frame.size.height - borderWidth, self.frame.size.width, borderWidth);
    }else{
        border.frame = CGRectMake(view.frame.size.width - borderWidth,0, borderWidth, self.frame.size.height);
    }
    border.name=@"border";
    [view.layer addSublayer:border];
}

-(void)addBorderWithColor:(UIColor *)color with:(UIView *) view{
    CGFloat borderWidth = 0.75f;
    CALayer *border = [CALayer layer];
    border.backgroundColor = color.CGColor;
    border.frame = CGRectMake(0, 0, self.frame.size.width, borderWidth);
    border.name=@"border";
    [view.layer addSublayer:border];
}


-(UIButton *)addItemView:(ZCLibSkillSet *) model withX:(CGFloat )x withY:(CGFloat) y withW:(CGFloat) w withH:(CGFloat) h{
    UIButton *itemView = [[UIButton alloc] initWithFrame:CGRectMake(x, y, w,h)];
    [itemView setFrame:CGRectMake(x, y, w, h)];
    
    
    UILabel *_itemName = [[UILabel alloc] initWithFrame:CGRectZero];
    [_itemName setBackgroundColor:[UIColor clearColor]];
//    [_itemName setTextColor:UIColorFromThemeColor(ZCTextMainColor)];
    [_itemName setText:model.groupName];
    [_itemName setFont:ZCUIFont14];
    [itemView addSubview:_itemName];
    
    if(model.groupStyle <=0){
        itemView.layer.cornerRadius = 17.0f;
        itemView.layer.masksToBounds = YES;
        [itemView setBackgroundImage:[ZCUIImageTools zcimageWithColor:UIColorFromThemeColor(ZCBgLeftChatColor)] forState:UIControlStateNormal];
        [itemView setBackgroundImage:[ZCUIImageTools zcimageWithColor:[ZCUITools zcgetCommentButtonLineColor]] forState:UIControlStateSelected];
        [itemView setBackgroundImage:[ZCUIImageTools zcimageWithColor:[ZCUITools zcgetCommentButtonLineColor]] forState:UIControlStateHighlighted];
        
        [_itemName setTextAlignment:NSTextAlignmentCenter];
        [_itemName setTextColor:[ZCUITools zcgetRightChatColor]];
        
        if(!model.isOnline){
            [_itemName setFont:ZCUIFont12];

            [_itemName setFrame:CGRectMake(0, 5 , itemView.frame.size.width, 13)];

            UILabel *_itemStatus = [[UILabel alloc] initWithFrame:CGRectMake(0,5+13, itemView.frame.size.width, 16)];
            [_itemStatus setBackgroundColor:[UIColor clearColor]];
            [_itemStatus setTextAlignment:NSTextAlignmentCenter];
            [_itemStatus setFont:ZCUIFont10];

            // [ZCIMChat getZCIMChat].libConfig.msgFlag == 0
            if ([[ZCPlatformTools sharedInstance] getPlatformInfo].config.msgFlag == 0) {
    //            [_itemStatus setText:ZCSTLocalString(@"暂无客服在线，可留言")];
                [_itemName setTextColor:UIColorFromThemeColor(ZCTextSubColor)];
                NSString *string = [NSString stringWithFormat:@"%@，%@%@",ZCSTLocalString(@"暂无客服在线"),ZCSTLocalString(@"您可以"),ZCSTLocalString(@"留言")];
                NSMutableAttributedString *attribut = [[NSMutableAttributedString alloc]initWithString:string];
                NSMutableDictionary *dic = [NSMutableDictionary dictionary];
                dic[NSForegroundColorAttributeName] = UIColorFromThemeColor(ZCTextPlaceHolderColor);
                [attribut addAttributes:dic range:NSMakeRange(0,string.length - 2)];
                
                NSMutableDictionary *dic_1 = [NSMutableDictionary dictionary];
                dic_1[NSForegroundColorAttributeName] = [ZCUITools zcgetRightChatColor];
                [attribut addAttributes:dic_1 range:NSMakeRange(string.length - 2,2)];
                
                _itemStatus.attributedText = attribut;
                itemView.enabled = YES;
                
            }else{
                [_itemName setTextColor:UIColorFromThemeColor(ZCTextSubColor)];
                [_itemStatus setText:ZCSTLocalString(@"暂无客服在线")];
                
                [_itemStatus setTextColor:UIColorFromThemeColor(ZCTextPlaceHolderColor)];
                itemView.enabled = NO;
            }

            [itemView addSubview:_itemStatus];
        }else{
             [_itemName setTextColor:[ZCUITools zcgetRightChatColor]];
            [_itemName setFrame:CGRectMake(0, 0 , itemView.frame.size.width, h)];
            itemView.enabled = YES;
            
        }
    }else{
        [itemView setBackgroundColor:UIColor.clearColor];
        
        [_itemName setTextColor:UIColorFromThemeColor(ZCTextMainColor)];
        ZCUIImageView *imgView = [ZCUIImageView imageViewWithURL:[NSURL URLWithString:zcLibConvertToString(model.groupPic)] autoLoading:YES];
        [itemView addSubview:imgView];
        
        if(model.groupStyle == 1){
            [imgView setFrame:CGRectMake(w/2-25, 0, 50, 50)];
            _itemName.numberOfLines = 0;
            _itemName.textAlignment = NSTextAlignmentCenter;
            [_itemName setFrame:CGRectMake(0, 55, w, 36)];
            
            // 文字置顶显示
            [_itemName sizeToFit];
            CGRect f = _itemName.frame;
            f.size.width = w;
            _itemName.frame = f;
        }else{
            [imgView setFrame:CGRectMake(0, 0, 40, 40)];
            imgView.layer.cornerRadius = 20.0f;
            imgView.layer.masksToBounds = YES;
            [_itemName setFrame:CGRectMake(48, 0, w-48, 20)];
            _itemName.numberOfLines = 1;
            _itemName.textAlignment = NSTextAlignmentLeft;
            
            
            UILabel *_itemStatus = [[UILabel alloc] initWithFrame:CGRectMake(48,21, w-48, 18)];
            [_itemStatus setBackgroundColor:[UIColor clearColor]];
            [_itemStatus setTextAlignment:NSTextAlignmentLeft];
            [_itemStatus setFont:ZCUIFont12];
            _itemStatus.numberOfLines = 1;
            [_itemStatus setTextColor:UIColorFromThemeColor(ZCTextSubColor)];
            [_itemStatus setText:zcLibConvertToString(model.desc)];
            [itemView addSubview:_itemStatus];
        }
        
    }
    
    return itemView;
}


- (void)itemClick:(UIButton *) view{
    ZCLibSkillSet *model =  listArray[view.tag];
    [ZCLogUtils logHeader:LogHeader info:@"%@",model.groupName];
    
    if(SkillSetClickBlock){
        SkillSetClickBlock(model);
    }
}

-(void)setItemClickBlock:(void (^)(ZCLibSkillSet *))block{
    SkillSetClickBlock = block;
}

-(void)setCloseBlock:(void (^)())closeBlock{
    CloseBlock = closeBlock;
}

- (void)closeSkillToRobotBlock:(void(^)()) toRobotBlock{
    ToRobotBlock = toRobotBlock;
}

- (void)gotoRobotChat:(NSNotification*)notification{

    [self tappedCancel];
}

/**
 *  显示弹出层
 *
 *  @param view
 */
- (void)showInView:(UIView *)view{
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
    
    
    [UIView animateWithDuration:0.25f animations:^{
        [self.backGroundView setFrame:CGRectMake(_backGroundView.frame.origin.x,viewHeight ,self.backGroundView.frame.size.width,self.backGroundView.frame.size.height)];
        self.alpha = 0;
    } completion:^(BOOL finished) {
        if (finished) {
            if(CloseBlock && isClose){
                CloseBlock();
            }
            [self removeFromSuperview];
        }
    }];
    // 点击取消的时候设置键盘样式 关闭加载动画
    [_keyboardView setKeyBoardStatus:ZCKeyboardStatusRobot];
//    [_keyboardView.zc_activityView stopAnimating];
}

- (void)gotoRobotChatAndLeavemeg:(NSNotification*)notifiation{
    [UIView animateWithDuration:0.25f animations:^{
        [self.backGroundView setFrame:CGRectMake(_backGroundView.frame.origin.x,viewHeight ,self.backGroundView.frame.size.width,self.backGroundView.frame.size.height)];
        self.alpha = 0;
    } completion:^(BOOL finished) {
        if (ToRobotBlock) {
            ToRobotBlock();
        }
            [self removeFromSuperview];
        
    }];
    // 点击取消的时候设置键盘样式 关闭加载动画
    [_keyboardView setKeyBoardStatus:ZCKeyboardStatusRobot];
//    [_keyboardView.zc_activityView stopAnimating];
}
@end
