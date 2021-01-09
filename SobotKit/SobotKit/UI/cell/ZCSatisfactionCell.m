//
//  ZCSatisfactionCell.m
//  SobotKit
//
//  Created by lizhihui on 16/1/21.
//  Copyright © 2016年 zhichi. All rights reserved.
//

#import "ZCSatisfactionCell.h"
#import "ZCLibGlobalDefine.h"
#import "ZCUIColorsDefine.h"

#import "ZCUIRatingView.h"
#import "ZCSatisfactionButton.h"

#import "ZCStoreConfiguration.h"
#import "ZCLibServer.h"
#import "ZCIMChat.h"
#import "ZCUICore.h"
#import "ZCLibSatisfaction.h"
#import "ZCItemView.h"


@interface ZCSatisfactionCell ()<RatingViewDelegate>{
    // 0五星   1是0星
    int defaultStartType;
    
}
typedef NS_ENUM(NSInteger,ZCSatisfactionCellType){
    ZCSatisfactionCellType_onlyStar     = 1,
    ZCSatisfactionCellType_hasResolved  = 2,
    ZCSatisfactionCellType_notResolve  = 3,
    ZCSatisfactionCellType_notSelected  = 4,
    
};
@property (nonatomic,strong) ZCUIRatingView * ratingView;

@property (nonatomic,strong) UILabel * titleLab;

@property (nonatomic,strong) UILabel * resolvelab;

@property (nonatomic,strong) UIButton * resolveBtn;// 已解决

//@property (nonatomic,strong) UILabel * satisfactionlab;

@property (nonatomic,strong) UILabel * tiplab;

@property (nonatomic,strong) UIView * bglayerView;

@property (nonatomic,strong) UIView * bgView;

@property (nonatomic,strong) UIView * lineView;


//@property (nonatomic,strong) UIView * selctedView;

@property (nonatomic,strong) UITapGestureRecognizer * tap ;

@property (nonatomic,strong) UIButton * isresolveBtn;// 未解决

@property (nonatomic,strong) ZCSatisfactionButton * correctBtn;// 对勾

@property (nonatomic,assign) BOOL  isShowAction;

@property (nonatomic,strong) ZCLibMessage * model;

@property (nonatomic,assign) int rating;

@property (nonatomic,assign) int isResolved;// 0 已解决 1 未解决  2.没有选择

@property (nonatomic,strong) UIView *topview;//萌层

@property (nonatomic,strong) UIButton *submitBtn;// 提交按钮


@property (nonatomic,strong) ZCItemView *satisfactionView;//五星是选项
@property (nonatomic,strong) ZCLibSatisfaction * satisfaction;//五星是选项

@end


@implementation ZCSatisfactionCell
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        //
        //        //设置点击事件
        //        UITapGestureRecognizer *tapGesturer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(satisfactionAction:)];
        //        self.userInteractionEnabled=YES;
        //        [self addGestureRecognizer:tapGesturer];
        
        _bgView = [[UIView alloc]init];
        _bgView.layer.cornerRadius = 10;
        _bgView.layer.masksToBounds = YES;
//        _bgView.backgroundColor = [ZCUITools zcgetLeftChatColor];
        [self.contentView addSubview:_bgView];
        
        _titleLab = [[UILabel alloc]init];
        _titleLab.numberOfLines = 1;
        _titleLab.font = ZCUIFont14;
        //        515A7C
        _titleLab.textColor = UIColorFromThemeColor(ZCTextMainColor);
        [self.contentView addSubview:_titleLab];
        
        _bglayerView = [[UIView alloc]init];
        _bglayerView.backgroundColor = UIColorFromThemeColor(ZCBgSystemWhiteThirdGrayColor);
        
        if([ZCUITools getZCThemeStyle] != ZCThemeStyle_Dark){
            _bglayerView.layer.shadowOpacity= 1;
            _bglayerView.layer.shadowColor = UIColorFromThemeColorAlpha(ZCTextMainColor, 0.15).CGColor;
            _bglayerView.layer.shadowOffset = CGSizeZero;//投影偏移
            _bglayerView.layer.shadowRadius = 2;
        }
        [self.contentView addSubview:_bglayerView];
        
        
        _lineView = [[UIView alloc]init];
        _lineView.backgroundColor = UIColorFromThemeColor(ZCBgLineColor);
        //        _lineView
        [self.contentView addSubview:_lineView];
        
        
        
        // 是否解决问题lab
        _resolvelab = [[UILabel alloc]init];
        [_resolvelab setBackgroundColor:[UIColor clearColor]];
        [_resolvelab setTextAlignment:NSTextAlignmentCenter];
        [_resolvelab setFont:ZCUIFont14];
        [_resolvelab setTextColor:UIColorFromThemeColor(ZCTextMainColor)];
        _resolvelab.numberOfLines=0;
        [self.contentView addSubview:_resolvelab];
        
        _satisfactionView = [[ZCItemView alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
        _satisfactionView.backgroundColor = [UIColor clearColor];
        [self.contentView addSubview:_satisfactionView];
        
        
        _tiplab = [[UILabel alloc]init];
        [_tiplab setBackgroundColor:[UIColor clearColor]];
        [_tiplab setTextAlignment:NSTextAlignmentCenter];
        [_tiplab setFont:[ZCUITools zcgetCustomListKitDetailFont]];
//        [_tiplab setTextColor:UIColorFromRGB(0xF0AC0E)];
        [_tiplab setTextColor:UIColorFromThemeColor(ZCTextLinkYellowColor)];
        _tiplab.numberOfLines=0;
        [self.contentView addSubview:_tiplab];
        
        
        // 对勾
        _correctBtn = [ZCSatisfactionButton buttonWithType:UIButtonTypeCustom];
        [_correctBtn setImage:[ZCUITools zcuiGetBundleImage:ZCSTLocalString(@"zcicon_satisfaction_correct")] forState:UIControlStateNormal];
        [_correctBtn setImage:[ZCUITools zcuiGetBundleImage:ZCSTLocalString(@"zcicon_satisfaction_correct")] forState:UIControlStateSelected];
        [_correctBtn setImage:[ZCUITools zcuiGetBundleImage:ZCSTLocalString(@"zcicon_satisfaction_correct")] forState:UIControlStateHighlighted];
        [_correctBtn setTitle:@" " forState:UIControlStateNormal];
        
        
        _resolveBtn = [[UIButton alloc]init];

        [_resolveBtn setImage:[ZCUITools zcuiGetBundleImage:ZCSTLocalString(@"zcicon_useful_nol")] forState:UIControlStateNormal];
        [_resolveBtn setImage:[ZCUITools zcuiGetBundleImage:ZCSTLocalString(@"zcicon_useful_sel")] forState:UIControlStateSelected];
        [_resolveBtn setImage:[ZCUITools zcuiGetBundleImage:ZCSTLocalString(@"zcicon_useful_sel")] forState:UIControlStateHighlighted];
        [_resolveBtn setTitle:ZCSTLocalString(@"已解决") forState:UIControlStateNormal];
        _resolveBtn.titleLabel.font = ZCUIFont14;
        _resolveBtn.layer.cornerRadius = 18;
        _resolveBtn.tag = 101;
        [_resolveBtn setTitleColor:[ZCUITools zcgetNoSatisfactionTextColor] forState:UIControlStateNormal];
        [_resolveBtn setTitleColor:[ZCUITools zcgetSatisfactionTextSelectedColor] forState:UIControlStateHighlighted];
        [_resolveBtn setTitleColor:[ZCUITools zcgetSatisfactionTextSelectedColor]  forState:UIControlStateSelected];
        [_resolveBtn setBackgroundColor:[ZCUITools zcgetSatisfactionBgSelectedColor]];
        if([ZCUITools getZCThemeStyle] != ZCThemeStyle_Dark){
            _resolveBtn.layer.shadowOpacity= 1;
            _resolveBtn.layer.shadowColor = UIColorFromThemeColorAlpha(ZCTextMainColor, 0.15).CGColor;
            _resolveBtn.layer.shadowOffset = CGSizeZero;//投影偏移
            _resolveBtn.layer.shadowRadius = 2;
        }
        [_resolveBtn setImageEdgeInsets:UIEdgeInsetsMake(0, -10, 0, 0)];
//        [_resolveBtn setTitleEdgeInsets:UIEdgeInsetsMake(0, 0, 0, 10)];
        [_resolveBtn addTarget:self action:@selector(robotServerButton:) forControlEvents:UIControlEventTouchUpInside];
        
        [self.contentView addSubview:_resolveBtn];
        //        _resolveBtn.backgroundColor = [UIColor blueColor];
        
        _isresolveBtn = [[UIButton alloc]init];

        [_isresolveBtn setImage:[ZCUITools zcuiGetBundleImage:ZCSTLocalString(@"zcicon_useless_nol")] forState:UIControlStateNormal];
        [_isresolveBtn setImage:[ZCUITools zcuiGetBundleImage:ZCSTLocalString(@"zcicon_useless_sel")] forState:UIControlStateSelected];
        [_isresolveBtn setImage:[ZCUITools zcuiGetBundleImage:ZCSTLocalString(@"zcicon_useless_sel")] forState:UIControlStateHighlighted];
        _isresolveBtn.titleLabel.font = ZCUIFont14;
        
        _isresolveBtn.layer.cornerRadius = 18;
        _isresolveBtn.tag = 102;
        [_isresolveBtn setTitleColor:[ZCUITools zcgetNoSatisfactionTextColor] forState:UIControlStateNormal];
        [_isresolveBtn setTitleColor:[ZCUITools zcgetSatisfactionTextSelectedColor] forState:UIControlStateHighlighted];
        [_isresolveBtn setTitleColor:[ZCUITools zcgetSatisfactionTextSelectedColor]  forState:UIControlStateSelected];
        [_isresolveBtn setBackgroundColor:[ZCUITools zcgetSatisfactionBgSelectedColor]];
        if([ZCUITools getZCThemeStyle] != ZCThemeStyle_Dark){
            _isresolveBtn.layer.shadowOpacity= 1;
            _isresolveBtn.layer.shadowColor = UIColorFromThemeColorAlpha(ZCTextMainColor, 0.15).CGColor;
            _isresolveBtn.layer.shadowOffset = CGSizeZero;//投影偏移
            _isresolveBtn.layer.shadowRadius = 2;
        }
        [_isresolveBtn setImageEdgeInsets:UIEdgeInsetsMake(0, -10, 0, 0)];
        [_isresolveBtn setTitle:ZCSTLocalString(@"未解决") forState:UIControlStateNormal];
        [_isresolveBtn addTarget:self action:@selector(robotServerButton:) forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:_isresolveBtn];
        //        _isresolveBtn.backgroundColor = [UIColor redColor];
        
        _submitBtn = [[UIButton alloc]init];
        _submitBtn.layer.cornerRadius = 18;
        _submitBtn.layer.masksToBounds = YES;
        _submitBtn.backgroundColor = [ZCUITools zcgetRightChatColor];
        [_submitBtn setTitle:ZCSTLocalString(@"提交") forState:UIControlStateNormal];
        _submitBtn.titleLabel.font = ZCUIFont14;
        [_submitBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_submitBtn addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:_submitBtn];
    }
    return self;
}

- (CGFloat)InitDataToView:(ZCLibMessage *)model time:(NSString *)showTime{
    [self resetCellView];
    if(_ratingView!=nil){
        [_ratingView removeFromSuperview];
    }
    
    self.isResolved = 2;
    
    //    CGFloat cellHeight = [super InitDataToView:model time:showTime];
    
    
    _bglayerView.frame = CGRectMake(30, 10, self.viewWidth - 60, 0);
//    _selctedView.frame = CGRectMake(0, 0, _bglayerView.frame.size.width, 0);
//    _selctedView.backgroundColor = [UIColor whiteColor];
    
    if (_resolveBtn !=nil) {
        _resolveBtn.selected = NO;
    }
    
    if (_isresolveBtn!=nil) {
        //        [_isresolveBtn removeFromSuperview];
        _isresolveBtn.selected = NO;
    }
    
    
    
    if (_resolvelab != nil) {
        _resolvelab.text = @"";
    }
    
    
    ZCSatisfactionCellType cellType = ZCSatisfactionCellType_notSelected;
    
    // 开启已解决未解决  1开启 0关闭，并且没有评价过
    if ([model.isQuestionFlag intValue] > 0 ) {
        if(model.satisfactionCommtType == 0){
            cellType = ZCSatisfactionCellType_notResolve;
        }
    }else{
        cellType = ZCSatisfactionCellType_onlyStar;
    }
    
    
            
    _titleLab.text = [NSString stringWithFormat:@"%@%@",model.senderName,ZCSTLocalString(@"邀请您对本次服务进行评价")];
    
    _titleLab.frame = CGRectMake(30, 20, self.viewWidth - 60, 20);
    
    _bglayerView.frame = CGRectMake(30, CGRectGetMaxY(_titleLab.frame) + 10, self.viewWidth - 60, 177);
    
    
    CGFloat bgViewHeight = 237;
    CGFloat iy = CGRectGetMaxY(_titleLab.frame) + 40;
    if(cellType != ZCSatisfactionCellType_onlyStar){
        bgViewHeight = 373 + 10;
        _bglayerView.frame = CGRectMake(30, CGRectGetMaxY(_titleLab.frame) + 10, self.viewWidth - 60, 313 + 10);
        _resolvelab.frame = CGRectMake(30, _bglayerView.frame.origin.y + 30,self.viewWidth - 60,20);
        _resolvelab.text = [NSString stringWithFormat:@"%@ %@",model.senderName,ZCSTLocalString(@"是否解决了您的问题？")];
        _resolvelab.textColor = UIColorFromThemeColor(ZCTextMainColor);
        CGSize btnSize = CGSizeMake(97, 36);
        float btnGap = 30;
        
        _resolveBtn.frame = CGRectMake((self.viewWidth - btnSize.width*2 - btnGap)/2, CGRectGetMaxY(_resolvelab.frame) + 20, btnSize.width, btnSize.height);
        _resolveBtn.selected = YES;
    
        
        // 设置1会默认未解决，不应该设置，2.8.5修改，已解决应该是0
        _isResolved = 0;
        
        _isresolveBtn.frame = CGRectMake(CGRectGetMaxX(_resolveBtn.frame) + btnGap ,CGRectGetMaxY(_resolvelab.frame) + 20, btnSize.width, btnSize.height);
        
        _lineView.frame = CGRectMake(45, CGRectGetMaxY(_isresolveBtn.frame) + 30, self.viewWidth - 45*2, 0.5);
        
        iy = CGRectGetMaxY(_lineView.frame) + 30;
    }
    _ratingView =[[ZCUIRatingView alloc]initWithFrame: CGRectMake((_bglayerView.frame.size.width-180)/2, iy,  180, 29 )];
    CGPoint bglayerCenter = _bglayerView.center;
    _ratingView.center = CGPointMake(bglayerCenter.x, _ratingView.center.y);
//    _ratingView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin;
    [_ratingView setImagesDeselected:@"zcicon_star_unsatisfied" partlySelected:@"zcicon_star_satisfied" fullSelected:@"zcicon_star_satisfied" andDelegate:self];
    _ratingView.backgroundColor = [UIColor clearColor];
    [self.contentView addSubview:_ratingView];
    
    
    _tiplab.frame = CGRectMake(30, CGRectGetMaxY(_ratingView.frame) + 15, self.viewWidth - 60, 20);
    _tiplab.text = ZCSTLocalString(@"非常满意");
    [self.contentView addSubview:_titleLab];
    
    NSDictionary *dict = [ZCUICore getUICore].satisfactionDict;
    
    _satisfactionView.hidden = YES;
    _submitBtn.hidden = NO;
    if(dict!=nil && dict.count > 0){
        NSArray * arr = dict[@"data"];

        [_tiplab setTextColor:UIColorFromThemeColor(ZCTextLinkYellowColor)];
        if(arr != nil && [arr isKindOfClass:[NSArray class]] && arr.count >= 5){
            _satisfaction = [[ZCLibSatisfaction alloc] initWithMyDict:arr[arr.count - 1]];
            // 0五星   1  0星
            defaultStartType = _satisfaction.defaultType;
            
        }
        
        if(_satisfaction!=nil && defaultStartType == 0){
            _satisfactionView.hidden = NO;
            [_satisfactionView setFrame:CGRectMake(30, CGRectGetMaxY(_tiplab.frame) + 15, self.viewWidth - 60, 0)];
            CGRect itemF = self.satisfactionView.frame ;
            if(zcLibConvertToString(_satisfaction.labelName).length > 0){
                NSArray *items =  items = [zcLibConvertToString(_satisfaction.labelName) componentsSeparatedByString:@"," ];
                
                [_satisfactionView InitDataWithArray:items];
                itemF.size.height =[ZCItemView getHeightWithArray:items];
                _satisfactionView.frame = itemF;
            }
            
            bgViewHeight = bgViewHeight + itemF.size.height;

            CGRect bgf = _bglayerView.frame;
            bgf.size.height =  bgf.size.height + itemF.size.height;
            _bglayerView.frame = bgf;
            
            [_ratingView displayRating:5.0f];
        }else{
            _tiplab.text = ZCSTLocalString(@"您的评价会让我们做得更好");
            [_tiplab setTextColor:UIColorFromThemeColor(ZCTextSubColor)];
            [_ratingView displayRating:0];
            _submitBtn.hidden = YES;
            bgViewHeight = bgViewHeight - 51;

            CGRect bgf = _bglayerView.frame;
            bgf.size.height =  bgf.size.height - 51;
            _bglayerView.frame = bgf;
        }
        
    }
    if(!_submitBtn.hidden){
        if(_satisfactionView.hidden){
            _submitBtn.frame = CGRectMake((self.viewWidth - 200)/2, CGRectGetMaxY(_tiplab.frame) + 15, 200, 36);
        }else{
            _submitBtn.frame = CGRectMake((self.viewWidth - 200)/2, CGRectGetMaxY(_satisfactionView.frame) + 15, 200, 36);
        }
    }
    
    _bgView.frame = CGRectMake(15, 10, self.viewWidth - 30, bgViewHeight);
            
    // 本地设置不自动提交
    _isShowAction = NO;
    self.rating = 5;
    self.userInteractionEnabled = YES;
    
    if (self.isRight) {
        [_bgView setBackgroundColor:[ZCUITools zcgetRightChatColor]];
    }else{
        [_bgView setBackgroundColor:[ZCUITools zcgetLeftChatColor]];
    }
    
    return self.bglayerView.frame.size.height+20;
    
}

+(CGFloat)getCellHeight:(ZCLibMessage *)model time:(NSString *)showTime viewWith:(CGFloat)width{
    CGFloat height=[super getCellHeight:model time:showTime viewWith:width];
    
    float bgViewHeight = 237;
    // 开启已解决未解决  1开启 0关闭，并且没有评价过
    if ([model.isQuestionFlag intValue] > 0 ) {
        if(model.satisfactionCommtType == 0){
            bgViewHeight = 373;
        }
    }
    
    NSDictionary *dict = [ZCUICore getUICore].satisfactionDict;
    if(dict!=nil && dict.count > 0){
        // 0五星   1  0星
        int defaultStartType = 0;
        NSArray * arr = dict[@"data"];
        ZCLibSatisfaction *satisfactionModel = nil;
        if(arr != nil && [arr isKindOfClass:[NSArray class]] && arr.count >= 5){
            satisfactionModel = [[ZCLibSatisfaction alloc] initWithMyDict:arr[arr.count - 1]];
            // 0五星   1  0星
            defaultStartType = satisfactionModel.defaultType;
        }
        
        if (defaultStartType == 0) {
            ZCItemView *item = [[ZCItemView alloc] initWithFrame:CGRectMake(0,0, width - 60, 0)];
            CGFloat sheight = 0;
            if(zcLibConvertToString(satisfactionModel.labelName).length > 0 && ![ZCUICore getUICore].kitInfo.hideManualEvaluationLabels){
                NSArray *items = [zcLibConvertToString(satisfactionModel.labelName) componentsSeparatedByString:@"," ];
                
                [item InitDataWithArray:items];
                sheight = [ZCItemView getHeightWithArray:items];
            }
            bgViewHeight = bgViewHeight + sheight + 15;
        }else{
            
            bgViewHeight = bgViewHeight - 51;
        }
    }
    return bgViewHeight + height + 10;
}

-(void)resetCellView{
    [super resetCellView];
    self.lblNickName = nil;
    self.ivHeader = nil;
    
}


- (void)robotServerButton:(ZCSatisfactionButton*)sender{
    sender.layer.borderColor = [UIColor clearColor].CGColor;
    if (sender.tag == 101) {
        //        UIButton *btn=(UIButton *)[self.backgroundView viewWithTag:102];
        //        [btn setSelected:NO];
        _resolveBtn.layer.borderColor = UIColorFromThemeColor(ZCBgLineColor).CGColor;
        _resolveBtn.selected = YES;
        _isresolveBtn.selected = NO;
        self.isResolved = 0;
    }else{
        _isresolveBtn.layer.borderColor = UIColorFromThemeColor(ZCBgLineColor).CGColor;
        _resolveBtn.selected = NO;
        _isresolveBtn.selected = YES;
        self.isResolved = 1;
    }
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

#pragma delegate
// 赋值的时候，不执行
-(void)ratingChanged:(float)newRating{
    // 优先于ratingChangedWithTap 方法
//    NSLog(@"change:%f",newRating);
}

-(void)ratingChangedWithTap:(float)newRating{
    // 始终一样，去掉此逻辑
//    if (newRating == self.rating) {
//        return;
//    }
    
    self.rating = newRating;
    if (newRating > 0 && newRating < 5) {
        [self  commitAction:1];
    }else if(newRating == 5){
        // 直接提交评价
//        [self commitAction:2];
        [self commitAction:1];
    }
    
    // 设置默认值
    if(defaultStartType == 0){
        // 重新赋值到5
        self.rating = 5;
        [self.ratingView displayRating:5.0f];
    }else{
        // 重新赋值到5
        self.rating = 0;
        [self.ratingView displayRating:0.0f];
    }
}

// 提交评价   type 1代表5星以下  2 代表5星提交
- (void)commitAction:(int)type{
    if (self.delegate && [self.delegate respondsToSelector:@selector(cellItemClick:IsResolved:Rating:problem:)]) {
        if(type == 2){
            if(_satisfaction!=nil){
                // 内容必填 ，切换为1弹评价页面
                if([_satisfaction.isInputMust intValue] == 1){
                    type = 1;
                }
            }
        }
        [ZCUICore getUICore].inviteSatisfactionCheckLabels = [_satisfactionView getSeletedTitle];
        [self.delegate cellItemClick:type IsResolved:self.isResolved Rating:self.rating problem:[_satisfactionView getSeletedTitle]];
    }
}


// 只有可能是5星的时候调用此函数
-(void)buttonClick:(UIButton *) btn{
    BOOL _isMustAdd = NO;
    if(_satisfaction!=nil){
        if ([@"" isEqual: zcLibConvertToString(_satisfaction.labelName)]) {
            _isMustAdd = NO;
        }else{
            if ([_satisfaction.isTagMust intValue] == 1 ) {
                _isMustAdd = YES;
            }else{
                _isMustAdd = NO;
            }

        }
        // 标签必填直接谈评价
        if([_satisfaction.isInputMust intValue] == 1){
            [self commitAction:1];
            return;
        }
    }
    
    // 必填项为空
    if(_isMustAdd && zcLibConvertToString([_satisfactionView getSeletedTitle]).length == 0){
        // 提示
        [[ZCUIToastTools shareToast] showToast:ZCSTLocalString(@"标签必选") duration:1.0f view:self.superview.superview
                                    position:ZCToastPositionCenter];
        
        return;
    }
    
    [self commitAction:2];
}

@end
