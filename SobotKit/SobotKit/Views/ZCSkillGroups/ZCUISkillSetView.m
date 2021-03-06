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
        
        [self createSubviews];
    }
    return self;
}


- (void)createSubviews{
    CGFloat bw=viewWidth;
    
    
    self.backGroundView = [[UIView alloc] initWithFrame:CGRectMake((viewWidth - bw) / 2.0, viewHeight, bw, 0)];
    self.backGroundView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleTopMargin;
    self.backGroundView.autoresizesSubviews = YES;
    self.backGroundView.backgroundColor = UIColorFromThemeColor(ZCBgSystemWhiteLightDarkColor);
    
//    [self.backGroundView.layer setCornerRadius:5.0f];
    self.backGroundView.layer.masksToBounds = YES;
    [self addSubview:self.backGroundView];
    
    
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, bw, 60)];
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
    
    self.scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 60, bw, 0)];
    self.scrollView.showsVerticalScrollIndicator=YES;
    self.scrollView.bounces = NO;
    self.scrollView.backgroundColor = UIColor.clearColor;
    self.scrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    
    [self.backGroundView addSubview:self.scrollView];
    
    CGFloat x= 15;
    CGFloat y= 20;
    
    CGFloat itemH = 35;
    CGFloat itemW = (bw - 30 - 10)/2.0f;
    
    int index = listArray.count%2==0?round(listArray.count/2):round(listArray.count/2)+1;
    
    for (int i=0; i<listArray.count; i++) {
        UIButton *itemView = [self addItemView:listArray[i] withX:x withY:y withW:itemW withH:itemH];
        itemView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin |UIViewAutoresizingFlexibleWidth;
        [itemView setBackgroundColor:UIColorFromThemeColor(ZCBgSystemWhiteLightDarkColor)];
        itemView.userInteractionEnabled = YES;
        itemView.tag = i;
        [itemView addTarget:self action:@selector(itemClick:) forControlEvents:UIControlEventTouchUpInside];
        if(i%2==1){
            x = 15;
            y = y + itemH + 20;
        }else if(i%2==0){
            x = itemW + 15 + 10;
        }
        [self.scrollView addSubview:itemView];
    }
    CGFloat h = index*(itemH) + (index + 1) * 20;
    if(h > viewHeight*0.6){
        h = viewHeight*0.6;
    }
    [self.scrollView setFrame:CGRectMake(0, 60, bw, h)];
    [self.scrollView setContentSize:CGSizeMake(bw, index*itemH + (index+1)*20)];
    
    
    
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
    itemView.layer.cornerRadius = 17.0f;
    itemView.layer.masksToBounds = YES;
    
    [itemView setBackgroundImage:[ZCUIImageTools zcimageWithColor:UIColorFromThemeColor(ZCBgLeftChatColor)] forState:UIControlStateNormal];
    [itemView setBackgroundImage:[ZCUIImageTools zcimageWithColor:[ZCUITools zcgetCommentButtonLineColor]] forState:UIControlStateSelected];
    [itemView setBackgroundImage:[ZCUIImageTools zcimageWithColor:[ZCUITools zcgetCommentButtonLineColor]] forState:UIControlStateHighlighted];
    
    UILabel *_itemName = [[UILabel alloc] initWithFrame:CGRectZero];
    [_itemName setBackgroundColor:[UIColor clearColor]];
    [_itemName setTextAlignment:NSTextAlignmentCenter];
    [_itemName setTextColor:[ZCUITools zcgetRightChatColor]];
//    [_itemName setTextColor:UIColorFromThemeColor(ZCTextMainColor)];
    [_itemName setText:model.groupName];
    [_itemName setFont:ZCUIFont14];
    [itemView addSubview:_itemName];
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
