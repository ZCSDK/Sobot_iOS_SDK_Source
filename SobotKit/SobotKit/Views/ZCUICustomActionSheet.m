//
//  CustomActionSheet.m
//  SobotSDK
//
//  Created by 张新耀 on 15/8/5.
//  Copyright (c) 2015年 sobot. All rights reserved.
//

#import "ZCUICustomActionSheet.h"
#import "ZCUIRatingView.h"
#import "ZCUIPlaceHolderTextView.h"

#import "ZCLibGlobalDefine.h"
#import "ZCUIColorsDefine.h"
#import "ZCUIImageTools.h"
#import "ZCStoreConfiguration.h"
#import "ZCUIToastTools.h"


#import "ZCSatisfactionButton.h"
#import "ZCItemView.h"
#import "ZCUICore.h"
#import "ZCToolsCore.h"

#define BorderWith     0.75f //(1.0 / [UIScreen mainScreen].scale) / 2

#define INPUT_MAXCOUNT 200

#define ZCkScreenWidth         [UIScreen mainScreen].bounds.size.width


@interface ZCUICustomActionSheet()<RatingViewDelegate,UIGestureRecognizerDelegate,UITextViewDelegate>

//@property (nonatomic, weak) ZCUICustomActionSheet       *actionSheet;
@property (nonatomic, strong) UIView                  *sheetView;// 背景View(白色View)
@property(nonatomic,strong)ZCItemView *item;

@property(nonatomic,weak)   UILabel *messageLabel;
@property(nonatomic,weak)   UILabel *quesLabel;

@property(nonatomic,assign)BOOL isChangePostion;// 是否去刷新星评
@property(nonatomic,weak) UIView * problemView;// 记录已解决 未解决 的坐标

@property(nonatomic,strong) UIScrollView *backGroundView;// 内容视图view（中间滑动部分）
@property(nonatomic,strong) UIView *itemView;// 标签view
@property(nonatomic,strong) ZCUIRatingView *ratingView;// 星评View
@property(nonatomic,strong) ZCUIPlaceHolderTextView *textView;
@property(nonatomic,strong) UIButton *commitBtn;
@property(nonatomic,strong) UIView * topView;// 顶部View
@property(nonatomic,strong) UILabel * stLable;//


//@property(nonatomic,strong) UIView * textBgView;// 输入框背景

@end


@implementation ZCUICustomActionSheet{
    
    BOOL isKeyBoardShow;
    BOOL touchRating;
    
    SatisfactionType currentServerType;
    
    ZCLibConfig *_config;
    BOOL isresolve;
    BOOL isDidClose;
    
    // 默认显示 0五星   1  0星
    int defaultStar;
    int scoreFlag;// 0:5星,1:10分
    CGFloat viewWidth;
    CGFloat viewHeight;
    
    BOOL  _isBack;// 返回
    
    //1 主动评价 2 0邀请评价
    int _invitationType ;
    
    BOOL  _isBcakClose;// 评价完人工后结束会话
    
    NSString *_name ;  //客服或者机器人的昵称
    
    BOOL  isShowIsOrNoSolveProblemView;// 人工评价时，是否显示是否已解决页面
    
    NSMutableArray * _listArray;
    
    UILabel * _tiplab;// 星级评价标签
    
    BOOL  _isMustAdd; // 标签是否是必选
    
    BOOL  _isInputMust;// 评价框是否必填
    
    int  ratingCount; // 邀请评价记录几星
    int  isResolveCount;// 邀请评价记录 是否已解决
    
    BOOL _isAddServerSatifaction;// 满意度cell刷新
    
    CGFloat ZCMaxHeight;
    
}
- (ZCUICustomActionSheet*)initActionSheet:(SatisfactionType)type Name:(NSString *)name Cofig:(ZCLibConfig *)config cView:(UIView *)view  IsBack:(BOOL)isBack isInvitation:(int) invitationType  WithUid:(NSString *)uid  IsCloseAfterEvaluation:(BOOL) isCloseAfterEvaluation  Rating:(int)rating IsResolved:(int)isResolve IsAddServerSatifaction:(BOOL) isAddServerSatifaction txtFlag:(int)txtFlag ticketld:(NSString*)ticketld ticketScoreInfooList:(NSArray*)ticketScoreInfooList{
    
    self = [super init];
    if (self) {
        
        viewWidth = view.frame.size.width;
        //        viewHeight = view.frame.size.height;
        viewHeight = ScreenHeight;
        ZCMaxHeight =   ((ScreenHeight>800) ? (ScreenHeight-420 - 59):(ScreenHeight-340 - 59));
        if(ZCMaxHeight < 160){
            ZCMaxHeight = 160;
        }
        _config = config;
        // 初始化的背景视图，添加手势  添加高斯模糊
        self.frame = CGRectMake(0, 0, viewWidth, viewHeight);
        self.autoresizingMask = UIViewAutoresizingFlexibleWidth| UIViewAutoresizingFlexibleHeight;
        self.autoresizesSubviews = YES;
        //        self.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.4];
        self.backgroundColor = COLORWithAlpha(0, 0, 0, 0.4);
        self.userInteractionEnabled = YES;
        UITapGestureRecognizer * tapGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(shareViewDismiss:)];
        tapGesture.delegate = self;
        [self addGestureRecognizer:tapGesture];
        _name = name;
        _isBack = isBack;
        _invitationType = invitationType;
        currentServerType = type;
        _isBcakClose = isCloseAfterEvaluation;
        _isMustAdd = NO;
        _isInputMust = NO;
        
        ratingCount = rating;
        isResolveCount = isResolve;
        _isAddServerSatifaction = isAddServerSatifaction;
        
        _textFlag = txtFlag;
        _ticketld = ticketld;
        _ticketScoreInfooList = ticketScoreInfooList;
        
        if (currentServerType == 3 || currentServerType == 4 || currentServerType == 5 || currentServerType == 6) {
            // 加载人工客服的标签。根据接口的数据进行UI布局
            [self loadDataWithUid:uid];
        }else{
            // 机器人的模式为固定格式
            [self setupType:type];
        }
    }
    return self;
}


//  2.3.0 版本替换初始化方法
- (ZCUICustomActionSheet*)initActionSheet:(SatisfactionType)type Name:(NSString *)name Cofig:(ZCLibConfig *)config cView:(UIView *)view  IsBack:(BOOL)isBack isInvitation:(int) invitationType  WithUid:(NSString *)uid IsCloseAfterEvaluation:(BOOL) isCloseAfterEvaluation Rating:(int)rating IsResolved:(int)isResolve IsAddServerSatifaction:(BOOL) isAddServerSatifaction{
    
    return  [self initActionSheet:type Name:name Cofig:config cView:view IsBack:isBack isInvitation:invitationType WithUid:uid IsCloseAfterEvaluation:isCloseAfterEvaluation Rating:rating IsResolved:isResolve IsAddServerSatifaction:isAddServerSatifaction txtFlag:1 ticketld:@"" ticketScoreInfooList:nil];
    
}




- (void)setDisplay{
    [self setupType:currentServerType];
}



- (void)loadDataWithUid:(NSString *)uid{
    
    if (currentServerType == 6) {
        [self setDisplay];
    }else{
        NSDictionary *dict = [ZCUICore getUICore].satisfactionDict;
        if(dict!=nil && dict.count > 0){
            [self refreshSatisfaction];
        }else{
            
            [[ZCUICore getUICore] loadSatisfactionDictlock:^(int code) {
                [self refreshSatisfaction];
            }];
        }
    }
    
}

-(void)refreshSatisfaction{
    NSDictionary *dict = [ZCUICore getUICore].satisfactionDict;
    if(dict && dict.count > 0){
        NSArray * arr = dict[@"data"];
        
        if (arr != nil && arr.count >0 && [arr isKindOfClass:[NSArray class]]) {
            NSMutableArray * satisfactionArr = [NSMutableArray arrayWithCapacity:0];
            for (NSDictionary * item in arr) {
                ZCLibSatisfaction * satisfaction = [[ZCLibSatisfaction alloc]initWithMyDict:item];
                
                
                [satisfactionArr addObject:satisfaction];
            }
            
            if (_listArray == nil) {
                _listArray = [NSMutableArray arrayWithCapacity:0];
            }else{
                [_listArray removeAllObjects];
            }
            _listArray = satisfactionArr;
            
            ZCLibSatisfaction * model = _listArray[0];// 0五星   1  0星
            defaultStar = model.defaultStar;
            scoreFlag = model.scoreFlag;
            
            if ([model.isQuestionFlag  intValue] == 1) {
                isShowIsOrNoSolveProblemView = YES;
            }else{
                isShowIsOrNoSolveProblemView = NO;
            }
            
            self.isOpenProblemSolving = isShowIsOrNoSolveProblemView;
        }
    }
    
    // 加载成功的布局
    [self setDisplay];
}


-(void)setupType:(SatisfactionType)type{
    
    _sheetView = [[UIView alloc]initWithFrame:CGRectMake(0, viewHeight, viewWidth, 0)];
    _sheetView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleTopMargin;
    _sheetView.backgroundColor = UIColorFromThemeColor(ZCBgSystemWhiteLightDarkColor);
    
    [self addSubview:_sheetView];
    // topView
    _topView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, viewWidth, 60)];
    _topView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    _topView.backgroundColor = UIColorFromThemeColor(ZCBgSystemWhiteLightDarkColor);
    [self.sheetView addSubview:_topView];
    
    // 顶部标题栏部分  关闭按钮  标题  暂不评价 评价后结束会话
    // 左上角关闭按钮
    UIButton * closeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    closeBtn.frame = CGRectMake(viewWidth - 54, 8, 44, 44);
    [closeBtn setImage:[ZCUITools zcuiGetBundleImage:@"zcicon_sf_close"] forState:UIControlStateNormal];
    [closeBtn setImage:[ZCUITools zcuiGetBundleImage:@"zcicon_sf_close"] forState:UIControlStateSelected];
    [closeBtn setImage:[ZCUITools zcuiGetBundleImage:@"zcicon_sf_close"] forState:UIControlStateHighlighted];
    [closeBtn addTarget:self action:@selector(zcDismissView:) forControlEvents:UIControlEventTouchUpInside];
    closeBtn.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
    [_topView addSubview:closeBtn];
    
    // 2.8.6 达令家需要关闭是也显示暂不评价
    if((type == RobotSatisfcationBackType || type == ServerSatisfcationBackType)
       && [ZCUICore getUICore].kitInfo.canBackWithNotEvaluation){
        
        UIButton * canReturnBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        canReturnBtn.frame = CGRectMake(10, 8, 94, 44);
        [canReturnBtn setTitle:ZCSTLocalString(@"暂不评价") forState:0];
        [canReturnBtn.titleLabel setFont:ZCUIFont14];
        [canReturnBtn setTitleColor:[ZCUITools zcgetSatisfactionTextSelectedColor] forState:0];
        [canReturnBtn addTarget:self action:@selector(itemMenuClick:) forControlEvents:UIControlEventTouchUpInside];
        [canReturnBtn setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
        canReturnBtn.tag = RobotChangeTag3;
        [_topView addSubview:canReturnBtn];
    }
    
    
    // 标题
    UILabel * titlelab = [[UILabel alloc]init];
    titlelab.textColor     = UIColorFromThemeColor(ZCTextMainColor);
    titlelab.textAlignment = NSTextAlignmentCenter;
    titlelab.numberOfLines = 0;
    titlelab.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    titlelab.font          = ZCUIFontBold17;
    
    
    if (_isBcakClose && (currentServerType == 4 || currentServerType == 3 || currentServerType == 5)) {// 人工客服返回评价后结束会话
        titlelab.frame = CGRectMake(ScreenWidth/2 - (viewWidth-100)/2, 10, viewWidth -100, 18);
        titlelab.text = ZCSTLocalString(@"服务评价");
        if (currentServerType == 1) {
            titlelab.text = ZCSTLocalString(@"机器人客服评价");
        }
        
        // 显示提交后会话将结束
        UILabel *tiplab = [[UILabel alloc]initWithFrame:CGRectMake(ScreenWidth/2 - (viewWidth-100)/2, CGRectGetMaxY(titlelab.frame)+6, viewWidth -100, 12)];
        tiplab.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        tiplab.font = ZCUIFont12;
        tiplab.textAlignment = NSTextAlignmentCenter;
        tiplab.numberOfLines = 0;
        tiplab.textColor = [ZCUITools zcgetSatisfactionColor];
        tiplab.text = ZCSTLocalString(@"提交评价后会话将结束");
        [_topView addSubview:tiplab];
    }else{
        titlelab.frame = CGRectMake(ScreenWidth/2 - (viewWidth-100)/2, 20, viewWidth -100, 20);
        titlelab.font = ZCUIFontBold17;
        // 标题只有一行
        if(currentServerType == RobotSatisfcationNolType){
            titlelab.text = ZCSTLocalString(@"机器人客服评价");
        }else{
            titlelab.text = ZCSTLocalString(@"服务评价");
        }
        
    }
    
    [_topView addSubview:titlelab];
    
    // 线条
    UIView *lineView = [[UIView alloc]initWithFrame:CGRectMake(0, 59, viewWidth, 0.5)];
    lineView.backgroundColor = [ZCUITools zcgetCommentButtonLineColor];
    lineView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    [_topView addSubview:lineView];
    
    
    if (type >2) {
        self.isOpenProblemSolving = isShowIsOrNoSolveProblemView;
    }else{
        self.isOpenProblemSolving = YES;
    }
    
    if (type == ServerSatisfcationOrderType) { // 工单详情页面的评价触发
        self.isOpenProblemSolving = NO;
    }
    
    // 背景view UIScrollView  中间部分
    self.backGroundView = [[UIScrollView alloc]initWithFrame:CGRectMake(0, CGRectGetMaxY(_topView.frame), viewWidth, 0)];
    self.backGroundView.autoresizesSubviews = YES;
    self.backGroundView.backgroundColor = UIColorFromThemeColor(ZCBgSystemWhiteLightDarkColor);
    self.backGroundView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    [self.sheetView addSubview:self.backGroundView];
    
    UIView *problemView ;// 记录位置
    if (self.isOpenProblemSolving) {
        // label
        UILabel * nicklab = [[UILabel alloc]initWithFrame:CGRectMake(0, 30, viewWidth, 21)];
        nicklab.font = ZCUIFont15;
        nicklab.numberOfLines = 0;
        nicklab.textColor = UIColorFromThemeColor(ZCTextMainColor);
        nicklab.text = [NSString stringWithFormat:@"%@ %@",_name,ZCSTLocalString(@"是否解决了您的问题？")];
        nicklab.textAlignment = NSTextAlignmentCenter;
        nicklab.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        [self.backGroundView addSubview:nicklab];
        
        // 已解决 未解决
        for (int i=0; i<2; i++) {
            UIButton *btn=[UIButton buttonWithType:UIButtonTypeCustom];
            //            btn.titleEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 5);
            btn.imageEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 7);
            if(i==0){
                
                [btn setFrame:CGRectMake(viewWidth/2 - 15 - 97, CGRectGetMaxY(nicklab.frame)+20, 97, 36)];
                btn.tag=RobotChangeTag1;
                
                [btn setImage:[ZCUITools zcuiGetBundleImage:ZCSTLocalString(@"zcicon_useful_nol")] forState:UIControlStateNormal];
                [btn setImage:[ZCUITools zcuiGetBundleImage:ZCSTLocalString(@"zcicon_useful_sel")] forState:UIControlStateSelected];
                [btn setImage:[ZCUITools zcuiGetBundleImage:ZCSTLocalString(@"zcicon_useful_sel")] forState:UIControlStateHighlighted];
                btn.selected=NO;
                [btn setTitle:ZCSTLocalString(@"已解决") forState:UIControlStateNormal];
            }else{
                [btn setFrame:CGRectMake(viewWidth/2 + 15, CGRectGetMaxY(nicklab.frame)+20,97, 36)];
                btn.tag=RobotChangeTag2;
                [btn setImage:[ZCUITools zcuiGetBundleImage:ZCSTLocalString(@"zcicon_useless_nol")] forState:UIControlStateNormal];
                [btn setImage:[ZCUITools zcuiGetBundleImage:ZCSTLocalString(@"zcicon_useless_sel")] forState:UIControlStateSelected];
                [btn setImage:[ZCUITools zcuiGetBundleImage:ZCSTLocalString(@"zcicon_useless_sel")] forState:UIControlStateHighlighted];
                [btn setTitle:ZCSTLocalString(@"未解决") forState:UIControlStateNormal];
                btn.selected=NO;
            }
            if(isRTLLayout()){
                [btn setImageEdgeInsets:UIEdgeInsetsMake(0, 3, 0, 3)];
            }
            [btn.titleLabel setFont:[ZCUITools zcgetListKitTitleFont]];
            [btn setTitleColor:[ZCUITools zcgetNoSatisfactionTextColor] forState:UIControlStateNormal];
            [btn setTitleColor:[ZCUITools zcgetSatisfactionTextSelectedColor] forState:UIControlStateHighlighted];
            [btn setTitleColor:[ZCUITools zcgetSatisfactionTextSelectedColor]  forState:UIControlStateSelected];
            [btn addTarget:self action:@selector(robotServerButton:) forControlEvents:UIControlEventTouchUpInside];
            [btn setContentHorizontalAlignment:UIControlContentHorizontalAlignmentCenter];
            //            [btn setBackgroundColor:UIColor.whiteColor];
            //            [btn setBackgroundColor:[UIColor whiteColor] forState:UIControlStateNormal];
            
            [btn setBackgroundColor:[ZCUITools zcgetSatisfactionBgSelectedColor]];
            btn.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin;
            btn.layer.cornerRadius = 18.0f;
            if([ZCUITools getZCThemeStyle] != ZCThemeStyle_Dark){
                btn.layer.shadowOpacity= 1;
                btn.layer.shadowColor = UIColorFromThemeColorAlpha(ZCTextMainColor, 0.15).CGColor;
                btn.layer.shadowOffset = CGSizeZero;//投影偏移
                btn.layer.shadowRadius = 2;
            }
            btn.titleLabel.font = ZCUIFont14;
            
            if ((currentServerType == 3 || currentServerType == 4 || currentServerType == 5) && _invitationType == 0 && isResolveCount == 1) {
                if (btn.tag ==  RobotChangeTag2) {
                    btn.selected = YES;
                    isresolve = YES;
                    //                    btn.layer.borderColor = [UIColor clearColor].CGColor;
                }
            }else{
                if (btn.tag == RobotChangeTag1) {
                    btn.selected = YES;
                    isresolve=NO;
                    //                    btn.layer.borderColor = [UIColor clearColor].CGColor;
                }
            }
            
            [self.backGroundView addSubview:btn];
            problemView = btn;
            self.problemView = problemView;
        }
        
    }
    
#pragma mark -- 星星
    //    UILabel *message ; // 请您对【客服】进行评价
    if (type >2) {
        UILabel * nickLab = [[UILabel alloc]init];
        nickLab.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        
        UIView *lineView = [[UIView alloc]init];
        lineView.backgroundColor = [ZCUITools zcgetCommentButtonLineColor];
        lineView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        
        if ( !self.isOpenProblemSolving) {
            // 不显示已解决 未解决
            //            nickLab.frame = CGRectMake(0, 30, viewWidth, 21);
            
            nickLab.frame = CGRectMake(0, 0, viewWidth, 21);
            lineView.hidden = YES;
        }else if (self.isOpenProblemSolving){
            // 显示已解决 未解决
            //            nickLab.frame = CGRectMake(10, CGRectGetMaxY(self.problemView.frame) +30, viewWidth-20, 21);
            
            // 如果显示已解决、未解决，添加一条线
            nickLab.frame = CGRectMake(20, CGRectGetMaxY(self.problemView.frame) +30, viewWidth-40, 0.5);
            //            [nickLab setBackgroundColor:UIColorFromRGB(lineGrayColor)];
            //            nickLab.backgroundColor = [UIColor redColor];
            lineView.hidden = NO;
            lineView.frame = nickLab.bounds;
            [nickLab addSubview:lineView];
        }
        
        // 2.8.0去掉这句话
        //        nickLab.textAlignment = NSTextAlignmentCenter;
        //        nickLab.numberOfLines = 0;
        //        nickLab.text = [NSString stringWithFormat:ZCSTLocalString(@"请您对 [%@] 进行评价"),_name];
        //        nickLab.textColor = UIColorFromRGB(SatisfactionTextTitleColor);
        //        nickLab.font = [ZCUITools zcgetVoiceButtonFont];
        if (type != 6) {
            [self.backGroundView addSubview:nickLab];
        }
        float ratingView_margin_top = 0;
        if (isPortrait) {
            ratingView_margin_top = 20;
        }else{
            ratingView_margin_top = 10;
        }
        CGFloat ratingWidth = (scoreFlag==0)?250:280;
        _ratingView=[[ZCUIRatingView alloc] initWithFrame:CGRectMake(viewWidth/2 - ratingWidth/2,  CGRectGetMaxY(nickLab.frame)+ratingView_margin_top, ratingWidth, 40 )];
        [_ratingView setImagesDeselected:@"zcicon_star_unsatisfied" partlySelected:@"zcicon_star_satisfied" fullSelected:@"zcicon_star_satisfied" count:(scoreFlag==0)?5:10 andDelegate:self];
        self.ratingView.userInteractionEnabled = YES;
        self.ratingView.autoresizingMask = UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleLeftMargin;
        self.sheetView.userInteractionEnabled = YES;
        self.userInteractionEnabled = YES;
        self.isChangePostion =NO;
    
        if (_invitationType == 0) {
            // 默认0星应该选择1
            if(ratingCount == 0){
                ratingCount = 1;
            }
            [_ratingView displayRating:(float)ratingCount];
        }else{
            [_ratingView displayRating:defaultStar];
        }
        
        [self.backGroundView addSubview:_ratingView];
        
        // 满意度tipmsg
        _tiplab = [[UILabel alloc]initWithFrame:CGRectMake(0, CGRectGetMaxY(_ratingView.frame) + 12, viewWidth, 20)];
        _tiplab.textAlignment = NSTextAlignmentCenter;
        _tiplab.textColor  =  [ZCUITools zcgetScoreExplainTextColor];
        _tiplab.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        
        
        if (type == 6) {
            //            _tiplab.text = @"非常满意，完美";
            // 先处理排序
            if (_ticketScoreInfooList.count && _ticketScoreInfooList != nil && ![ZCUICore getUICore].kitInfo.hideManualEvaluationLabels) {
                NSComparator cmptr = ^(ZCLibSatisfaction *obj1, ZCLibSatisfaction *obj2){
                    if (obj1.score  > obj2.score) {
                        return (NSComparisonResult)NSOrderedDescending;
                    }
                    
                    if (obj1.score  < obj2.score ) {
                        return (NSComparisonResult)NSOrderedAscending;
                    }
                    return (NSComparisonResult)NSOrderedSame;
                };
                NSArray *sorArray = [_ticketScoreInfooList sortedArrayUsingComparator:cmptr];
                int index = (int)_ratingView.rating -1;
                if(index < 0){
                    index = 0;
                }
                ZCLibSatisfaction *item = sorArray[index];
                _tiplab.text =  item.scoreExplain;
            }
            
            if([ZCUICore getUICore].kitInfo.hideManualEvaluationLabels){
                _tiplab = [[UILabel alloc]initWithFrame:CGRectMake(0, CGRectGetMaxY(_ratingView.frame) + 12, viewWidth, 0)];
            }
        }else{
            if (_listArray.count && _listArray != nil && _ratingView.rating > 0) {
                //            _tiplab.text = @"非常满意";
                ZCLibSatisfaction *item = _listArray[(int)_ratingView.rating -1];
                _tiplab.text = item.scoreExplain;
            }
        }
        
        _tiplab.font = ZCUIFont12;
        [self.backGroundView addSubview:_tiplab];
        self.messageLabel = _tiplab;
        
        // 解决显示延迟问题
        [self createItemViews];
    }
    
    
#pragma mark -- 2.7.4版本新增 留言详情页评价 先计算是否添加 评价输入框，不在时时点击添加
    if (type == 6 && self.textFlag) {
        // 评价输入框
        _textView=[[ZCUIPlaceHolderTextView alloc] initWithFrame:CGRectMake(20, CGRectGetMaxY(self.messageLabel.frame)+20, viewWidth - 40 , 74)];
        [_textView setContentInset:UIEdgeInsetsMake( 7, 12, 15, 15)];
        //        _textView.layer.borderWidth   = BorderWith;
        //        _textView.layer.borderColor   = [UIColor colorWithWhite:0.3 alpha:1].CGColor; F2F5F7
        _textView.layer.cornerRadius  = 3.0f;
        _textView.layer.masksToBounds = YES;
        _textView.backgroundColor     = [ZCUITools zcgetLeftChatColor];
        _textView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        _textView.placeholder         = [NSString stringWithFormat:@"%@ (%@)",ZCSTLocalString(@"欢迎给我们的服务提建议~"),ZCSTLocalString(@"选填")];
        _textView.placeholderColor    = UIColorFromThemeColor(ZCTextPlaceHolderColor);
        _textView.placeholderLinkColor = UIColorFromThemeColor(ZCTextPlaceHolderColor);
        [_textView.placeHolderLabel setLinkColor:UIColorFromThemeColor(ZCTextPlaceHolderColor)];
        _textView.placeholederFont    = ZCUIFont14;
        _textView.font                = ZCUIFont14;
        _textView.delegate            = self;
        _textView.textColor       = [ZCUITools zcgetLeftChatTextColor];
        [self.backGroundView addSubview:_textView];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyBoardWillShow:) name:UIKeyboardWillShowNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyBoardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    }
    
    
#pragma mark -- 计算首次 显示的内容大小 计算提交按钮的位置
    //    CGFloat commitBtY = type>2 ? ((type ==6 && self.textFlag)?CGRectGetMaxY(self.textView.frame)+10 :CGRectGetMaxY(self.messageLabel.frame)+10) : CGRectGetMaxY(self.problemView.frame)+10;
    CGFloat commitBtY = CGRectGetMaxY(self.problemView.frame)+20;
    if(type > 2){
        commitBtY = CGRectGetMaxY(self.textView.frame)+20;
    }
    
    CGFloat maxHeight = ZCMaxHeight;
    // 滑块的高度
    CGRect bggroundFrame = self.backGroundView.frame;
    bggroundFrame.size.height = commitBtY;
    if (bggroundFrame.size.height > ZCMaxHeight) {
        bggroundFrame.size.height = maxHeight;
    }
    
    self.backGroundView.frame = bggroundFrame;
    self.backGroundView.contentSize = CGSizeMake(viewWidth , commitBtY);
    
    // 提交评价
    _commitBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    _commitBtn.frame = CGRectMake(20 , CGRectGetMaxY(self.backGroundView.frame) + 30, viewWidth-40, 44);
    [_commitBtn setTitle:ZCSTLocalString(@"提交") forState:UIControlStateNormal];
    _commitBtn.titleLabel.font = ZCUIFontBold17;
    [_commitBtn setTitleColor:[ZCUITools zcgetSubmitEvaluationButtonColor] forState:UIControlStateNormal];
    [_commitBtn setBackgroundColor:[ZCUITools zcgetCommentCommitButtonColor]];
    [_commitBtn addTarget:self action:@selector(sendComment:) forControlEvents:UIControlEventTouchUpInside];
    _commitBtn.layer.cornerRadius = 22.0f;
    _commitBtn.layer.masksToBounds = YES;
    _commitBtn.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    
    //获取高度
    CGRect sheetFrame = self.sheetView.frame;
    sheetFrame.size.height  = CGRectGetMaxY(self.backGroundView.frame) + _commitBtn.frame.size.height + 30 + XBottomBarHeight + 20;
    // 0 星评价时，不显示提交按钮,并且是5星的时候，不显示提交按钮
    if(type!=6 && _ratingView!=nil && _ratingView.rating < 1 && !_ratingView.hidden && scoreFlag == 0){
        _commitBtn.frame = CGRectMake(20 , CGRectGetMaxY(self.backGroundView.frame) + 10, viewWidth-40, 0);
        sheetFrame.size.height  = CGRectGetMaxY(self.backGroundView.frame) + XBottomBarHeight;
    }
    [self.sheetView addSubview:_commitBtn];
    
    
    sheetFrame.origin.y = viewHeight - sheetFrame.size.height;
    [UIView animateWithDuration:0.3 animations:^{
        [self sheetViewSetFrameWithNewF:sheetFrame];
    }];
    
}

#pragma mark -- 点击 已解决 未解决 事件
-(IBAction)robotServerButton:(UIButton *)sender{
    [sender setSelected:YES];
    //    sender.layer.borderColor = [UIColor clearColor].CGColor;
    if (sender.tag == RobotChangeTag1) {
        isresolve=NO;
        UIButton *btn=(UIButton *)[self.backGroundView viewWithTag:RobotChangeTag2];
        [btn setSelected:NO];
        btn.layer.borderColor = UIColorFromThemeColor(ZCBgLineColor).CGColor;
        if (currentServerType <3) {
            // 机器人模式触发
            [self showMenuItem:NO];// 收起
        }
        
        
    }else if(sender.tag == RobotChangeTag2){
        isresolve=YES;
        UIButton *btn=(UIButton *)[self.backGroundView viewWithTag:RobotChangeTag1];
        [btn setSelected:NO];
        btn.layer.borderColor = UIColorFromThemeColor(ZCBgLineColor).CGColor;
        if (currentServerType == RobotSatisfcationBackType || currentServerType == RobotSatisfcationNolType) {
            [self showMenuItem:YES];// 展开
        }
    }
    
    //    if (sender.selected) {
    //        sender.layer.backgroundColor = [UIColor clearColor].CGColor;
    //    }else{
    //        sender.layer.borderColor = UIColorFromRGB(LineCommentLineColor).CGColor;
    //    }
    
}

-(void)createItemViews{
    // 显示标签
    if(self.item){
        [self.item removeFromSuperview];
        [self.textView removeFromSuperview];
        [self.stLable removeFromSuperview];
        //        [self.textBgView removeFromSuperview];
    }
    
    CGFloat itemY = currentServerType >2 ? CGRectGetMaxY(self.messageLabel.frame)+20 : CGRectGetMaxY(self.problemView.frame)+20;
    
    //  去掉人工评价5星标签提醒
    if(currentServerType > 2 && [ZCUICore getUICore].kitInfo.hideManualEvaluationLabels){
        // 隐藏星星提示语
        self.messageLabel.text = @"";
        itemY = itemY - 20;
    }
    
    // 2.8.0隐藏掉
    // 是否有以下情况label 以及Btn
    UILabel *stLable=[[UILabel alloc] initWithFrame:CGRectMake(0, itemY - 20, viewWidth, 0)];
    stLable.textColor = UIColorFromThemeColor(ZCTextSubColor);
    stLable.font = ZCUIFont15;
    stLable.textAlignment = NSTextAlignmentCenter;
    self.stLable = stLable;
    
    self.item = [[ZCItemView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(stLable.frame)+ 20, viewWidth, 0)];
    self.item.backgroundColor = [UIColor clearColor];
    
    
    if (currentServerType == 1 || currentServerType == 2) {
        self.item.frame = CGRectMake(0, CGRectGetMaxY(stLable.frame)+ 15 + 15, viewWidth, 0);
        
    }else{
        if (scoreFlag) {
            if (currentServerType >2 &&(_listArray.count > 0 && _listArray != nil) && (_ratingView.rating>0 && _ratingView.rating<= 11) && _listArray.count >= _ratingView.rating) {
                
                ZCLibSatisfaction * model = _listArray[(int)_ratingView.rating - 1];
                
                // 设置是否必填标记
                _isMustAdd = [model.isTagMust boolValue];
                _isInputMust = [model.isInputMust boolValue];
                
                if (![@"" isEqual: zcLibConvertToString(model.labelName)]) {
                    self.item.frame = CGRectMake(0, CGRectGetMaxY(stLable.frame)+ 15, viewWidth, 0);
                }
            }
        } else {
            if (currentServerType >2 &&(_listArray.count > 0 && _listArray != nil) && (_ratingView.rating>0 && _ratingView.rating<= 5) && _listArray.count >= _ratingView.rating) {
                
                ZCLibSatisfaction * model = _listArray[(int)_ratingView.rating - 1];
                
                // 设置是否必填标记
                _isMustAdd = [model.isTagMust boolValue];
                _isInputMust = [model.isInputMust boolValue];
                
                if (![@"" isEqual: zcLibConvertToString(model.labelName)]) {
                    self.item.frame = CGRectMake(0, CGRectGetMaxY(stLable.frame)+ 15, viewWidth, 0);
                }
            }
        }
        
    }
    
    // 数据源
    NSArray *items= @[];
    
    if(currentServerType== 1 || currentServerType == 2){
        // 隐藏机器人评价标签
        if(![ZCUICore getUICore].kitInfo.hideRototEvaluationLabels){
            items = [_config.robotCommentTitle componentsSeparatedByString:@","];
        }
    }
    
    // 人工评价时便利
    if(currentServerType== 3 || currentServerType == 4 || currentServerType == 5){
        items = @[];// 调用接口不成功的时候用
        
        // 2.8.9 根据配置隐藏人工评价标签
        if (_listArray.count >0 && _listArray !=nil && ![ZCUICore getUICore].kitInfo.hideManualEvaluationLabels){
            
            
            // 接口返回的数据
            if (_ratingView.rating>0 && _listArray.count >= _ratingView.rating) {
                ZCLibSatisfaction * model = _listArray[(int)_ratingView.rating -1];
                
                
                if (![@"" isEqual: zcLibConvertToString(model.labelName)]) {
                    items = [model.labelName componentsSeparatedByString:@"," ];
                    
                    if(zcLibConvertToString(model.tagTips).length > 0){
                        [stLable setText:model.tagTips];
                        CGRect f = stLable.frame;
                        f.size.height = 30;
                        stLable.frame = f;
                        stLable.hidden = NO;
                        [self.backGroundView addSubview:_stLable];
                        
                        self.item.frame = CGRectMake(0, CGRectGetMaxY(stLable.frame)+ 20, viewWidth, 0);
                    }
                }
                
            }
        }
    }
    
    //邀请评价时，可能已经默认选择了标签，此处给默认值
    if(currentServerType == 5 && zcLibConvertToString([ZCUICore getUICore].inviteSatisfactionCheckLabels).length > 0){
        [self.item InitDataWithArray:items withCheckLabels:zcLibConvertToString([ZCUICore getUICore].inviteSatisfactionCheckLabels)];
    }else{
        
        [self.item InitDataWithArray:items];
    }
    CGRect itemF = self.item.frame ;
    itemF.size.height =[self.item getHeightWithArray:items];
    self.item.frame = itemF;
    [self.backGroundView addSubview:self.item];
    
    
    // 评价输入框
    _textView = [[ZCUIPlaceHolderTextView alloc] initWithFrame:CGRectMake(20, CGRectGetMaxY(self.item.frame) + 10, viewWidth - 40 , 74)];
    [_textView setContentInset:UIEdgeInsetsMake( 7, 12, 15, 15)];
    if (currentServerType == 1 || currentServerType == 2) {
        _textView.frame = CGRectMake(25, CGRectGetMaxY(self.item.frame) + 20, viewWidth - 50 , 74);
        
    }else{
        if (scoreFlag) {
            if (currentServerType >2 && (_listArray.count > 0 && _listArray != nil) && (_ratingView.rating>0 && _ratingView.rating<= 11) && _listArray.count >= _ratingView.rating) {
                
                ZCLibSatisfaction * model = _listArray[(int)_ratingView.rating -1];
                if (![@"" isEqual: zcLibConvertToString(model.labelName)]) {
                    _textView.frame = CGRectMake(25, CGRectGetMaxY(self.item.frame) + 20, viewWidth - 50 , 74);
                    
                }
            }
        } else {
            if (currentServerType >2 && (_listArray.count > 0 && _listArray != nil) && (_ratingView.rating>0 && _ratingView.rating<= 5) && _listArray.count >= _ratingView.rating) {
                
                ZCLibSatisfaction * model = _listArray[(int)_ratingView.rating -1];
                if (![@"" isEqual: zcLibConvertToString(model.labelName)]) {
                    _textView.frame = CGRectMake(25, CGRectGetMaxY(self.item.frame) + 20, viewWidth - 50 , 74);
                    
                }
            }
        }
        
    }
    
    _textView.backgroundColor = [UIColor clearColor];
    _textView.placeholder         = ZCSTLocalString(@"欢迎给我们的服务提建议~");
    _textView.placeholderColor    = UIColorFromThemeColor(ZCTextPlaceHolderColor);
    _textView.placeholderLinkColor = UIColorFromThemeColor(ZCTextPlaceHolderColor);
    _textView.placeholederFont    = ZCUIFont14;
    _textView.font                = ZCUIFont14;
    _textView.delegate            = self;
    _textView.textColor  = [ZCUITools zcgetLeftChatTextColor];
    _textView.backgroundColor =  [ZCUITools zcgetLeftChatColor];
    [_textView setContentInset:UIEdgeInsetsMake(0,5, 0, 5)];
    
    if (_listArray != nil && _listArray.count >0) {
        if (_ratingView.rating >0) {
            ZCLibSatisfaction * model = _listArray[(int)_ratingView.rating -1];
            if (![@"" isEqual:zcLibConvertToString(model.inputLanguage)]) {
                if (_isInputMust) {
                    NSString *needStr = ZCSTLocalString(@"必填");
                    _textView.placeholder = [NSString stringWithFormat:@"(%@)%@",needStr,model.inputLanguage];
                }else{
                    _textView.placeholder = model.inputLanguage;
                }
                
            }
        }
        
        // 2.9.0 5星评价也显示输入框
        //        if(_ratingView.rating == 5){
        //            CGRect f = _textView.frame;
        //            f.size.height = 0;
        //            f.origin.y = f.origin.y - 20;
        //            _textView.frame = f;
        //            _textView.hidden = YES;
        //        }
    }
    
    [self.backGroundView addSubview:_textView];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyBoardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyBoardWillHide:) name:UIKeyboardWillHideNotification object:nil];
}

#pragma 显示存在问题
-(void)showMenuItem:(BOOL) isShow{
    if (isShow) {
        [self createItemViews];
        
        CGRect bgF = self.backGroundView.frame;
        bgF.size.height = CGRectGetMaxY(_textView.frame) + 20;
        self.backGroundView.contentSize = CGSizeMake(viewWidth, bgF.size.height);
        if (bgF.size.height > ZCMaxHeight) {
            bgF.size.height = ZCMaxHeight;
        }
        
        self.backGroundView.frame = bgF;
        
        // 由于是相对坐标 所以需要重新计算
        CGRect commitFrame = self.commitBtn.frame;
        commitFrame.origin.y = CGRectGetMaxY(self.backGroundView.frame);
        self.commitBtn.frame = commitFrame;
        
        CGRect sheetFrame = self.sheetView.frame;
        sheetFrame.size.height  = CGRectGetMaxY(self.backGroundView.frame) + _commitBtn.frame.size.height + 20 + XBottomBarHeight;
        sheetFrame.origin.y = viewHeight - sheetFrame.size.height;
        [UIView animateWithDuration:0.3 animations:^{
            [self sheetViewSetFrameWithNewF:sheetFrame];//self.sheetView.frame = newSheetViewF;
        }];
        
    }else{
        
        // 不显示  标签
        [self.item removeFromSuperview];
        [self.textView removeFromSuperview];
        [self.stLable removeFromSuperview];
        
        CGFloat itemY = currentServerType >2 ? CGRectGetMaxY(self.messageLabel.frame)+20 : CGRectGetMaxY(self.problemView.frame)+20;
        CGRect bgViewframe = self.backGroundView.frame;
        bgViewframe.size.height = itemY;
        if (bgViewframe.size.height > ZCMaxHeight) {
            bgViewframe.size.height = ZCMaxHeight;
        }
        self.backGroundView.frame = bgViewframe;
        self.backGroundView.contentSize = CGSizeMake(bgViewframe.size.width, bgViewframe.size.height);
        CGRect commitF = self.commitBtn.frame;
        commitF.origin.y = CGRectGetMaxY(self.backGroundView.frame) + 30;
        self.commitBtn.frame = commitF;
        
        CGRect sheetFrame = self.sheetView.frame;
        sheetFrame.size.height  = CGRectGetMaxY(self.backGroundView.frame)+ 30 + _commitBtn.frame.size.height + 20 + XBottomBarHeight;
        
        sheetFrame.origin.y = viewHeight - sheetFrame.size.height;
        [UIView animateWithDuration:0.3 animations:^{
            [self sheetViewSetFrameWithNewF:sheetFrame];//self.sheetView.frame = newSheetViewF;
            if(isKeyBoardShow){
                [_textView resignFirstResponder];
            }
        }];
        [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
        [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
        
    }
    
}




#pragma mark 打分改变代理
-(void)ratingChangedWithTap:(float)newRating{
    
}

-(void)ratingChanged:(float)newRating{
    touchRating=YES;
    if(_commitBtn.frame.size.height == 0){
        _commitBtn.frame = CGRectMake(20 , CGRectGetMaxY(self.backGroundView.frame) + 30, viewWidth-40, 44);
    }
    // 留言评价单独处理
    if (currentServerType == 6) {
        // 修改星评描述
        if (scoreFlag) {
            if (_ratingView.rating > 0 && _ratingView.rating<=11) {
                //            _tiplab.text = [NSString stringWithFormat:@"%d星",_ratingView.rating];
                if (_ticketScoreInfooList.count && _ticketScoreInfooList != nil) {
                    NSComparator cmptr = ^(ZCLibSatisfaction *obj1, ZCLibSatisfaction *obj2){
                        if (obj1.score  > obj2.score ) {
                            return (NSComparisonResult)NSOrderedDescending;
                        }
                        
                        if (obj1.score < obj2.score) {
                            return (NSComparisonResult)NSOrderedAscending;
                        }
                        return (NSComparisonResult)NSOrderedSame;
                    };
                    NSArray *sorArray = [_ticketScoreInfooList sortedArrayUsingComparator:cmptr];
                    
                    ZCLibSatisfaction *item = sorArray[(int)_ratingView.rating -1];
                    _tiplab.text = item.scoreExplain;
                }
            }
            return;
        } else {
            if (_ratingView.rating > 0 && _ratingView.rating<=5) {
                //            _tiplab.text = [NSString stringWithFormat:@"%d星",_ratingView.rating];
                if (_ticketScoreInfooList.count && _ticketScoreInfooList != nil) {
                    NSComparator cmptr = ^(ZCLibSatisfaction *obj1, ZCLibSatisfaction *obj2){
                        if (obj1.score  > obj2.score ) {
                            return (NSComparisonResult)NSOrderedDescending;
                        }
                        
                        if (obj1.score < obj2.score) {
                            return (NSComparisonResult)NSOrderedAscending;
                        }
                        return (NSComparisonResult)NSOrderedSame;
                    };
                    NSArray *sorArray = [_ticketScoreInfooList sortedArrayUsingComparator:cmptr];
                    
                    ZCLibSatisfaction *item = sorArray[(int)_ratingView.rating -1];
                    _tiplab.text = item.scoreExplain;
                }
            }
            return;
        }
        
    }
    
    if (self.isChangePostion) {
        // 星评提示语
        if (_listArray != nil && _listArray.count > 0) {
            if (_ratingView.rating>0 && _ratingView.rating <= _listArray.count) {
                // 小心数组越界了。。
                ZCLibSatisfaction *item = _listArray[(int)_ratingView.rating -1];
                _tiplab.text = item.scoreExplain;
            }
        }
        
        //        if (newRating >0 && newRating <5) {
        [self showMenuItem:YES];
        //        }else{
        //            [self showMenuItem:NO];
        //        }
    }
    
    self.isChangePostion = YES;
}



#pragma mark --  关闭页面 不做评价  左上角关闭
- (void)zcDismissView:(UIButton*)sender{
    // 返回时开启满意度评价，点击X提醒不关闭,2.8.6去掉此逻辑
    //    if(_isBack && (currentServerType == RobotSatisfcationBackType || currentServerType == ServerSatisfcationBackType)
    //    && [ZCUICore getUICore].kitInfo.isOpenEvaluation){
    //        // 提示
    //        [[ZCUIToastTools shareToast] showToast:ZCSTLocalString(@"请您对本次服务进行评价~") duration:1.0f view:self position:ZCToastPositionCenter];
    //
    //        return;
    //    }
    [self tappedCancel];
}


// 显示弹出层
- (void)showInView:(UIView *)view{
    //    [view addSubview:self];
    [[[ZCToolsCore getToolsCore] getCurWindow] addSubview:self];
    self.sheetView.hidden = NO;
    CGRect newSheetViewF = self.sheetView.frame;
    newSheetViewF.origin.y = viewHeight - self.sheetView.frame.size.height;
    
    [UIView animateWithDuration:0.3 animations:^{
        
        self.sheetView.frame = newSheetViewF;
        
    }];
    
}

// 隐藏弹出层
- (void)shareViewDismiss:(UITapGestureRecognizer *) gestap{
    
    // 触摸的评分
    if(touchRating){
        touchRating=NO;
        return;
    }
    
    if(isKeyBoardShow){
        isKeyBoardShow=NO;
        [_textView resignFirstResponder];
        return;
    }
    
    CGPoint point = [gestap locationInView:self];
    CGRect f=self.sheetView.frame;
    if(point.x<f.origin.x || point.x>(f.origin.x+f.size.width) ||
       point.y<f.origin.y || point.y>(f.origin.y+f.size.height)){
        [self tappedCancel];
    }
    
}

// 页面消失
- (void)tappedCancel{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    [UIView animateWithDuration:0.1f animations:^{
        [self.backGroundView setFrame:CGRectMake(_backGroundView.frame.origin.x,viewHeight ,self.backGroundView.frame.size.width,self.backGroundView.frame.size.height)];
        self.alpha = 0;
    } completion:^(BOOL finished) {
        if (finished) {
            [self removeFromSuperview];
        }
    }];
    
    // 记录页面消失
    if (_delegate && [_delegate respondsToSelector:@selector(dimissCustomActionSheetPage)]) {
        [_delegate dimissCustomActionSheetPage];
    }
    
}

-(void)keyBoardWillShow:(NSNotification *) notification{
    isKeyBoardShow = YES;
    float animationDuration = [[[notification userInfo] valueForKey:UIKeyboardAnimationDurationUserInfoKey] floatValue];
    CGFloat keyboardHeight = [[[notification userInfo] objectForKey:@"UIKeyboardBoundsUserInfoKey"] CGRectValue].size.height;
    NSNumber *curve = [notification.userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey];
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:animationDuration];
    [UIView setAnimationCurve:[curve intValue]];
    [UIView setAnimationDelegate:self];
    {
        CGRect  sheetViewFrame = self.sheetView.frame;
        sheetViewFrame.origin.y = viewHeight - keyboardHeight - self.sheetView.frame.size.height + XBottomBarHeight+20;
        [self sheetViewSetFrameWithNewF:sheetViewFrame];//self.sheetView.frame = sheetViewFrame;
    }
    
    // commit animations
    [UIView commitAnimations];
}

//键盘隐藏
- (void)keyBoardWillHide:(NSNotification *)notification {
    // 以前5星好评，没有输入框
    //    if(_ratingView!=nil && (_ratingView.rating>=5 && currentServerType != ServerSatisfcationOrderType)){
    //        return;
    //    }
    
    float animationDuration = [[[notification userInfo] valueForKey:UIKeyboardAnimationDurationUserInfoKey] floatValue];
    [UIView beginAnimations:@"bottomBarDown" context:nil];
    [UIView setAnimationDuration:animationDuration];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
    [UIView commitAnimations];
    [UIView animateWithDuration:0.25 animations:^{
        CGRect sheetFrame = self.sheetView.frame;
        sheetFrame.origin.y = viewHeight - self.sheetView.frame.size.height;
        [self sheetViewSetFrameWithNewF:sheetFrame];//self.sheetView.frame = sheetFrame;
    }];
}

#pragma mark 评价标签 点击事件
-(IBAction)itemButtonClick:(UIButton *)sender{
    sender.selected=!sender.selected;
    
    if(sender.selected){
        [sender.layer setBorderWidth:0];
    }else{
        [sender.layer setBorderWidth:BorderWith];
    }
}


#pragma mark 暂不评价 跳过、取消
-(IBAction)itemMenuClick:(UIButton *)sender{
    if(sender.tag == RobotChangeTag3){
        [self closePage];
    }
    [self tappedCancel];
}


#pragma mark -- 提交评价
-(void)sendComment:(UIButton *) btn{
#pragma mark --- 工单留言页面的触发的评价
    if (currentServerType == 6) {
        
        NSString * textStr = @"";
        if (_textView.text!=nil && _textView.text.length > 0) {
            textStr = _textView.text;
        }
        NSString * source = [NSString stringWithFormat:@"%.0f",_ratingView.rating];
        
        __weak ZCUICustomActionSheet * saveSelf = self;
        btn.enabled = false;
        [[[ZCUICore getUICore] getAPIServer] postAddTicketSatisfactionWith:zcLibConvertToString(self.ticketld) Uid:zcLibConvertToString(_config.uid) CompanyId:zcLibConvertToString(_config.companyID) Score:source Remark:textStr start:^{
            
        } success:^(NSDictionary *dict, ZCNetWorkCode sendCode) {
            @try{
                if (dict && [dict[@"data"][@"retCode"] isEqualToString:@"000000"]) {
                    // 刷新工单详情页面数据
                    //                    [[NSNotificationCenter defaultCenter] postNotificationName:@"actionSheetClick:" object:nil];
                    //                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.25 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    if (saveSelf.delegate && [saveSelf.delegate respondsToSelector:@selector(actionSheetClick:)]) {
                        [saveSelf.delegate actionSheetClick:6];
                    }
                    //                    });
                    if (saveSelf.delegate && [saveSelf.delegate respondsToSelector:@selector(actionSheetClickWithDic:)]) {
                        [saveSelf.delegate actionSheetClickWithDic:dict];
                    }
                    
                    
                }
                btn.enabled = false;
                // 隐藏弹出层
                [saveSelf tappedCancel];
            } @catch (NSException *exception) {
                
            } @finally {
                
            }
            
        } failed:^(NSString *errorMessage, ZCNetWorkCode errorCode) {
            NSLog(@"%@",errorMessage);
            btn.enabled = false;
        }];
        
        return;
    }
    
#pragma mark --- 普通评价提交的逻辑
    
    
    //  此处要做是否评价过人工或者是机器人的区分
    if ([ZCUICore getUICore].isOffline || [[ZCPlatformTools sharedInstance] getPlatformInfo].config.isArtificial) {
        // 评价过客服了，下次不能再评价人工了
        [ZCUICore getUICore].isEvaluationService = YES;
    }else{
        // 评价过机器人了，下次不能再评价了
        [ZCUICore getUICore].isEvaluationRobot = YES;
    }
    NSString *comment=_item!=nil ? [_item getSeletedTitle] : @"";
    
    if (currentServerType == 3 || currentServerType == 4 || currentServerType == 5) {
        // 只在人工是做评定
        if ([@"" isEqualToString:comment] && _isMustAdd) {
            // 提示
            [[ZCUIToastTools shareToast] showToast:ZCSTLocalString(@"标签为必选") duration:1.0f view:self position:ZCToastPositionCenter];
            
            return;
        }
        // 如果是必传 去除两端的 空格+换行  是否为空
        if (_isInputMust && [@"" isEqualToString:[zcLibConvertToString(_textView.text) stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]]) {
            
            [[ZCUIToastTools shareToast] showToast:ZCSTLocalString(@"建议为必填") duration:1.0f view:self position:ZCToastPositionCenter];
            return;
        }
    }
    
    NSMutableDictionary *dict=[[NSMutableDictionary alloc] init];
    
    [dict setObject:comment forKey:@"problem"];
    
    if(_config){
        [dict setObject:zcLibConvertToString(_config.cid)  forKey:@"cid"];
        [dict setObject:zcLibConvertToString(_config.uid)  forKey:@"userId"];
    }
    if (currentServerType >2) {
        [dict setObject:[NSString stringWithFormat:@"%d",1] forKey:@"type"];
    }else{
        [dict setObject:[NSString stringWithFormat:@"%d",0] forKey:@"type"];
    }
    // 0:5星,1:10分
    if (scoreFlag) {
        [dict setObject:[NSString stringWithFormat:@"%.0f",_ratingView.rating - 1] forKey:@"source"];
    } else {
        [dict setObject:[NSString stringWithFormat:@"%.0f",_ratingView.rating] forKey:@"source"];
    }
    [dict setObject:[NSString stringWithFormat:@"%d",scoreFlag] forKey:@"scoreFlag"];
    
    
    
    //    if (_ratingView.rating == 5) {
    //        _textView.text = @"";// 5星 置空之前的建议
    //    }
    NSString * textStr = @"";
    if (_textView.text!=nil ) {
        textStr = _textView.text;
    }
    // 去除两端的 空格+换行
    textStr = [zcLibConvertToString(_textView.text) stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    [dict setObject:textStr forKey:@"suggest"];
    
    NSString * solved = @"-1";   // -1 未开启 0 已解决 1未解决
    if (_isOpenProblemSolving && currentServerType>2) {// 开启已解决 未解决  人工
        if (!isresolve) {
            solved = @"0";
        }else{
            solved = @"1";
        }
    }else if(currentServerType <3){
        if (!isresolve) {
            solved = @"0";
        }else{
            solved = @"1";
        }
    }
    [dict setObject:solved forKey:@"isresolve"];
    //    [dict setObject:[NSString stringWithFormat:@"%d",isresolve] forKey:@"isresolve"];
    // commentType  评价类型 主动评价 1 邀请评价0
    [dict setObject:[NSString stringWithFormat:@"%d",_invitationType] forKey:@"commentType"];
        
    btn.enabled = false;
    [[[ZCUICore getUICore] getAPIServer] doComment:dict result:^(ZCNetWorkCode code, int status, NSString *msg) {
        
    }];
    
    if(isKeyBoardShow){
        isKeyBoardShow=NO;
        [_textView resignFirstResponder];
    }
    
    
    btn.enabled = true;
    // 隐藏弹出层
    [self tappedCancel];
    // 客服主动邀请评价相关
    if(!_isBack){
        if (_invitationType == 0 || (!_isBcakClose  && currentServerType>2)) {
            int resolve = 0;
            if (isresolve) {
                resolve = 2;
            }else{
                resolve = 1;
            }
            
            if (_delegate && [_delegate respondsToSelector:@selector(thankFeedBack:rating:IsResolve:)]) {
                [self.delegate thankFeedBack:_invitationType rating:_ratingView.rating IsResolve:resolve];
                return;
            }
        }
    }
    
    [ZCUICore getUICore].unknownWordsCount = 0;
    
    // 2.7.0 评价逻辑整理  客服 主动邀请评价 用户 主动评价 返回触发评价 是否开启评价完人工结束会话开关
    if (currentServerType == RobotSatisfcationBackType ) {
        [self closePage:0];
    }else if (currentServerType == RobotSatisfcationNolType){
        /** 机器人评价（点击底部评价按钮） */
        [self closePage:2];
    }else if (currentServerType == ServerSatisfcationBackType){
        /** 人工客服评价 返回关闭*/
        if (_isBcakClose) {
            [self closePage:5];
        }else{
            [self closePage:0];
        }
        /** 人工客服评价 （点击底部评价按钮）*/
    }else if (currentServerType == ServerSatisfcationNolType){// 4
        if (_isBcakClose) {
            [self closePage:1];
        }else{
            [self closePage:2];
        }
    }else{
        [self closePage:2];
    }
}


-(void)closePage{
    // 跳过，直接退出
    [self closePage:4];
}

/**
 *  反馈成功，做页面提醒
 *
 *  @param isComment
 *  0  清理数据 并返回   1 评价完成后 结束会话 弹新会话键盘样式  2 弹感谢反馈  3 评价完成后 结束会话 弹新会话键盘样式  4 直接返回
 *
 */
-(void)closePage:(int) isComment{
    // 跳过，直接退出
    if(self.delegate && [self.delegate respondsToSelector:@selector(actionSheetClick:)]){
        [self.delegate actionSheetClick:isComment];
    }
    self.delegate = nil;
}

#pragma mark -- 代理事件限制200个字符的长度
- (void)textViewDidChange:(UITextView *)textView{
    UITextRange *selectedRange = [textView markedTextRange];
    //获取高亮部分
    UITextPosition *pos = [textView positionFromPosition:selectedRange.start offset:0];
    //如果在变化中是高亮部分在变，就不要计算字符了
    if (selectedRange && pos) {
        return;
    }
    
    if (textView.text.length>INPUT_MAXCOUNT) {
        textView.text = [textView.text substringToIndex:INPUT_MAXCOUNT];
    }
    
}


#pragma mark -- 手势冲突的代理
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    
    if ([touch.view isKindOfClass:[UIButton class]]  || [touch.view isKindOfClass:[ZCUIRatingView class]]  || [touch.view isMemberOfClass:[UIImageView class]]){
        return NO;
    }
    return YES;
}


- (void)sheetViewSetFrameWithNewF:(CGRect)newFrame{
    //    if (ZC_iPhoneX) {
    //        newFrame.origin.y = newFrame.origin.y - 34;
    //    }
    self.sheetView.frame = newFrame;
}

@end
