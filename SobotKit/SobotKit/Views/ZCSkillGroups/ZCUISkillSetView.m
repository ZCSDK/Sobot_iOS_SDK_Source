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
//#import "ZCUIImageView.h"
#import "SobotImageView.h"

@interface ZCUISkillSetView()

@property(nonatomic,strong) UIView *backGroundView;
@property(nonatomic,strong) UIScrollView *scrollView;
@property(nonatomic,strong) UIView *lineView;
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
    CGFloat titleLabH ; // 默认60
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
        if(!sobotIsNull(listArray) && listArray.count > 0){
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
    titleLabel.numberOfLines = 0;
    [titleLabel setText:ZCSTLocalString(@"请选择要咨询的内容")];
    [titleLabel setTextAlignment:NSTextAlignmentCenter];
    [titleLabel setBackgroundColor:UIColorFromThemeColor(ZCBgSystemWhiteLightDarkColor)];
    [titleLabel setTextColor:UIColorFromThemeColor(ZCTextMainColor)];
    [titleLabel setFont:ZCUIFontBold17];
    titleLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    [self.backGroundView addSubview:titleLabel];
    
    //groupStyle:无值 或 0 文本样式， 1 图文样式        2 图文+描述样式
    ZCLibSkillSet *firstModel = [listArray firstObject];
    int style = firstModel.groupStyle;
//    style = 2;
    if(sobotConvertToString(firstModel.groupGuideDoc).length>0){
        [titleLabel setText:sobotConvertToString(firstModel.groupGuideDoc)];
    }
    
    [titleLabel sizeToFit];
    CGRect TF = titleLabel.frame;
    TF.origin.x = bx +40;
    TF.origin.y = 0;
    TF.size.width = bw -80;
    TF.size.height = titleLabel.frame.size.height +10;
    if (TF.size.height <50) {
        TF.size.height = 60;
    }
    titleLabel.frame = TF;
    titleLabH = TF.size.height;
    
    UIButton *cannelButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [cannelButton setFrame:CGRectMake(bw - 54, 8, 44,44)];
    [cannelButton setBackgroundColor:UIColor.clearColor];
    cannelButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleBottomMargin;
    [cannelButton setImage:[ZCUITools zcuiGetBundleImage:@"zcicon_sf_close"] forState:UIControlStateNormal];
    [cannelButton addTarget:self action:@selector(tappedCancel) forControlEvents:UIControlEventTouchUpInside];
   [self.backGroundView addSubview:cannelButton];
    
    // 线条
     _lineView = [[UIView alloc]initWithFrame:CGRectMake(0, titleLabH, viewWidth, 0.5)];
    _lineView.backgroundColor = [ZCUITools zcgetCommentButtonLineColor];
    _lineView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
     [self.backGroundView addSubview:_lineView];
    
    self.scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(bx, titleLabH, bw, 0)];
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

    CGFloat styleH1 = 20;// 记录格式1 的初始高度 和最终scrollView需要内容视图高度
    CGFloat styleH2 = 20;// 记录格式2 的初始高度 和最终scrollView需要内容视图高度
    CGFloat styleH3 = 20;// 记录格式3 的初始高度 和最终scrollView需要内容视图高度
    for (int i=0; i<listArray.count; i++) {
        ZCLibSkillSet *skillmodel = listArray[i];
        ZCLibSkillSet *nextModel;
//        skillmodel.groupStyle = 2;
        if (skillmodel.groupStyle <= 0 && i%2 == 0) {
            // 处理样式0
            if (i+1 <listArray.count) {
                nextModel = listArray[i+1];
            }
            CGFloat leftH = [self getItemMaxHWith:skillmodel withW:itemW];
            CGFloat rightH = 0;
            if (!sobotIsNull(nextModel)) {
                rightH = [self getItemMaxHWith:nextModel withW:itemW];
            }
            itemH = leftH >rightH ? leftH :rightH;
            styleH1 = styleH1 + itemH + spaceH;
        }
        if (skillmodel.groupStyle == 1 && i%4 == 0) {
            CGFloat leftH = [self getItemMaxWith:skillmodel withW:itemW groupStyle:1];
            CGFloat rightH = 0;
            CGFloat maxH = 0;
            // 处理样式 1 图在上 文字在下
            for (int j = i+1; j<listArray.count; j++) {
                if (j % 4 == 0) {
                    break;
                }
                nextModel = listArray[j];
                rightH = [self getItemMaxWith:nextModel withW:itemW groupStyle:1];
                if (maxH == 0) {
                    itemH = leftH >rightH ? leftH :rightH;
                    maxH = itemH;
                }else{
                    if (maxH < leftH) {
                        maxH = leftH;
                    }
                    if (maxH < rightH) {
                        maxH = rightH;
                    }
                    itemH = maxH;
                }
            }
            styleH2 = styleH2 + itemH + spaceH;
        }
        if (skillmodel.groupStyle == 2) {
            itemH = [self getItemMaxWith:skillmodel withW:itemW groupStyle:2];
            styleH3 = styleH3 + itemH + spaceH;
        }
        UIButton *itemView = [self addItemView:listArray[i] withX:x withY:y withW:itemW withH:itemH];
        itemView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin |UIViewAutoresizingFlexibleWidth;
        [itemView setBackgroundColor:UIColorFromThemeColor(ZCBgSystemWhiteLightDarkColor)];
        itemView.userInteractionEnabled = YES;
        itemView.tag = i;
        [itemView addTarget:self action:@selector(itemClick:) forControlEvents:UIControlEventTouchUpInside];
        
        if((i+1)%column==0 || column == 1){
            x = startX;
            if (skillmodel.groupStyle <= 0) {
                y = styleH1;
            }else if(skillmodel.groupStyle == 1){
                y = styleH2;
            }else if (skillmodel.groupStyle == 2){
                y = styleH3;
            }else{
                y = y + itemH + spaceH;
            }
        }else{
            x = x + itemW + spaceW;
        }
        [self.scrollView addSubview:itemView];
    }
    // 行高是动态
    CGFloat h = rows*(itemH) + (rows + 1) * spaceH;
    if (styleH1 >20) {
        // 格式1
        h = styleH1;
    }
    if (styleH2 > 20) {
        h = styleH2;
    }
    if (styleH3 > 20) {
        h = styleH3;
    }
    CGFloat sch = h;// 实际展示内容高度
    if(h > viewHeight*0.6){
        h = viewHeight*0.6;
    }
    [self.scrollView setFrame:CGRectMake(bx, titleLabH, bw, h)];
//    [self.scrollView setContentSize:CGSizeMake(bw, rows*itemH + (rows+1)*spaceH)];
    [self.scrollView setContentSize:CGSizeMake(bw, sch)];
        
    [ZCUITools addTopBorderWithColor:[ZCUITools zcgetCommentButtonLineColor] andWidth:1.0f withView:cannelButton];
    
    
    [UIView animateWithDuration:0.25f animations:^{
        [self.backGroundView setFrame:CGRectMake(self.backGroundView.frame.origin.x, viewHeight - h - titleLabH - 30 ,self.backGroundView.frame.size.width, h + titleLabH + 30)];
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
#pragma mark - 技能组弹窗样式1 获取最终高度
-(CGFloat)getItemMaxHWith:(ZCLibSkillSet *)model withW:(CGFloat)w{
    if (model.groupStyle <= 0) {
        UILabel *itemName = [[UILabel alloc] initWithFrame:CGRectZero];
        [itemName setFont:ZCUIFont14];
        [itemName setText:model.groupName];
        itemName.numberOfLines = 0;
        if (!model.isOnline) {
            [itemName setFont:ZCUIFont12];
            [itemName setFrame:CGRectMake(8, 8, w-2*8, 13)];
            [itemName setTextAlignment:NSTextAlignmentCenter];
            UILabel *_itemStatus = [[UILabel alloc] initWithFrame:CGRectMake(8,8+13, w-2*8, 16)];
            [_itemStatus setTextAlignment:NSTextAlignmentCenter];
            [_itemStatus setFont:ZCUIFont10];
            _itemStatus.numberOfLines = 0;
            if ([[ZCPlatformTools sharedInstance] getPlatformInfo].config.msgFlag == 0) {
                NSString *string = [NSString stringWithFormat:@"%@，%@%@",ZCSTLocalString(@"暂无客服在线"),ZCSTLocalString(@"您可以"),ZCSTLocalString(@"留言")];
                NSMutableAttributedString *attribut = [[NSMutableAttributedString alloc]initWithString:string];
                NSMutableDictionary *dic = [NSMutableDictionary dictionary];
                dic[NSForegroundColorAttributeName] = UIColorFromThemeColor(ZCTextPlaceHolderColor);
                [attribut addAttributes:dic range:NSMakeRange(0,string.length - 2)];
                
                NSMutableDictionary *dic_1 = [NSMutableDictionary dictionary];
                dic_1[NSForegroundColorAttributeName] = [ZCUITools zcgetRightChatColor];
                [attribut addAttributes:dic_1 range:NSMakeRange(string.length - 2,2)];
                
                _itemStatus.attributedText = attribut;
            }else{
                [_itemStatus setText:ZCSTLocalString(@"暂无客服在线")];
            }
            
            [itemName sizeToFit];
            [_itemStatus sizeToFit];
            CGRect NF = itemName.frame;
            CGRect SF = _itemStatus.frame;
            if (NF.size.height + SF.size.height + 2*8 >36) {
                return NF.size.height + SF.size.height + 2*8;
            }
            
        }else{
            // 单个的高度
            [itemName setFrame:CGRectMake(8, 8, w-2*8, 35)];
            [itemName sizeToFit];
            CGRect NF = itemName.frame;
            if (NF.size.height >(36 -2*8)) {
                return NF.size.height + 2*8;
            }
        }
        
    }
    return 36;
}

#pragma mark - 技能组弹窗样式 2 图片在上 文案在下
-(CGFloat)getItemMaxWith:(ZCLibSkillSet *)model withW:(CGFloat)w groupStyle:(int)style{
    if (style == 1) {
        SobotImageView *imgView = [SobotImageView imageViewWithURL:[NSURL URLWithString:sobotConvertToString(model.groupPic)] autoLoading:YES];
        [imgView setFrame:CGRectMake(w/2-25, 0, 50, 50)];
        UILabel *_itemName = [[UILabel alloc] initWithFrame:CGRectZero];
        _itemName.numberOfLines = 0;
        [_itemName setText:model.groupName];
//        [_itemName setText:@"了深刻的减肥了卡机了快递费记录卡极乐迪斯科房间里卡绝对是浪费埃里克的健身房了空间啊了打开是解封了卡坚实的离开房间开始看舒克舒克"];
        [_itemName setFont:ZCUIFont14];
        _itemName.textAlignment = NSTextAlignmentCenter;
        [_itemName setFrame:CGRectMake(0, 55, w, 36)];
        
        // 文字置顶显示
        [_itemName sizeToFit];
        CGRect f = _itemName.frame;
        f.size.width = w;
        f.size.height = _itemName.frame.size.height;
        _itemName.frame = f;
        
        if (f.size.height + 55 > 87) {
            return f.size.height + 55 ;
        }
        return 87;
    }else if (style == 2){
        // 图片在左边 文本加描述在右边 上下布局
        SobotImageView *imgView = [SobotImageView imageViewWithURL:[NSURL URLWithString:sobotConvertToString(model.groupPic)] autoLoading:YES];
        [imgView setFrame:CGRectMake(0, 0, 40, 40)];
        
        UILabel *_itemName = [[UILabel alloc] initWithFrame:CGRectZero];
        _itemName.numberOfLines = 0;
        [_itemName setText:model.groupName];
//        [_itemName setText:@"了深刻的减肥了卡机了快递费记录卡极乐迪斯科房间里卡绝对是浪费埃里克的健身房了空间啊了打开是解封了卡坚实的离开房间开始看舒克舒克"];
        [_itemName setFont:ZCUIFont14];
        [_itemName setFrame:CGRectMake(48, 0, w-48, 20)];
        
        UILabel *_itemStatus = [[UILabel alloc] initWithFrame:CGRectMake(48,CGRectGetMaxY(_itemName.frame), w-48, 18)];
        [_itemStatus setTextAlignment:NSTextAlignmentLeft];
        [_itemStatus setFont:ZCUIFont12];
        _itemStatus.numberOfLines = 0;
        [_itemStatus setText:sobotConvertToString(model.desc)];
//        [_itemStatus setText:@"skdjfllkaksjdflkjlaksdjfl来思考点击了发卡机蓝思科技奥拉夫看记录打开就是劳动法开讲啦空数据登录分开"];
        [_itemName sizeToFit];
        CGRect NF = _itemName.frame;
        NF.size.height = _itemName.frame.size.height;
        _itemName.frame = NF;
        
        [_itemStatus sizeToFit];
        CGRect SF = _itemStatus.frame;
        SF.size.height = _itemStatus.frame.size.height;
        SF.origin.y = CGRectGetMaxY(_itemName.frame)+1;
        _itemStatus.frame = SF;
        
        if (NF.size.height + SF.size.height >40) {
            return NF.size.height + SF.size.height;
        }

        return 40;
    }
    return 0;
}

#pragma mark - 构建子控件
-(UIButton *)addItemView:(ZCLibSkillSet *) model withX:(CGFloat )x withY:(CGFloat) y withW:(CGFloat) w withH:(CGFloat) h{
    UIButton *itemView = [[UIButton alloc] initWithFrame:CGRectMake(x, y, w,h)];
    [itemView setFrame:CGRectMake(x, y, w, h)];
    
    UILabel *_itemName = [[UILabel alloc] initWithFrame:CGRectZero];
    _itemName.numberOfLines = 0;
    [_itemName setBackgroundColor:[UIColor clearColor]];
    [_itemName setText:model.groupName];
//    [_itemName setText:@"了深刻的减肥了卡机了快递费记录卡极乐迪斯科房间里卡绝对是浪费埃里克的健身房了空间啊了打开是解封了卡坚实的离开房间开始看舒克舒克"];
    [_itemName setFont:ZCUIFont14];
    [itemView addSubview:_itemName];
//    model.groupStyle = 2;
    if(model.groupStyle <=0){
        itemView.layer.cornerRadius = 18.0f;
        itemView.layer.masksToBounds = YES;
        [itemView setBackgroundImage:[ZCUIImageTools zcimageWithColor:[ZCUITools zcgetCommentItemButtonBgColor]] forState:UIControlStateNormal];
        [itemView setBackgroundImage:[ZCUIImageTools zcimageWithColor:[ZCUITools zcgetCommentButtonLineColor]] forState:UIControlStateSelected];
        [itemView setBackgroundImage:[ZCUIImageTools zcimageWithColor:[ZCUITools zcgetCommentButtonLineColor]] forState:UIControlStateHighlighted];
        
        [_itemName setTextAlignment:NSTextAlignmentCenter];
        [_itemName setTextColor:[ZCUITools zcgetRightChatColor]];
        if(!model.isOnline){
            [_itemName setFont:ZCUIFont12];
            [_itemName setFrame:CGRectMake(8, 8 , itemView.frame.size.width-2*8, _itemName.frame.size.height)];
            UILabel *_itemStatus = [[UILabel alloc] initWithFrame:CGRectMake(8,CGRectGetMaxY(_itemName.frame), itemView.frame.size.width-2*8, h-2*8-_itemName.frame.size.height)];
            [_itemStatus setBackgroundColor:[UIColor clearColor]];
            [_itemStatus setTextAlignment:NSTextAlignmentCenter];
            [_itemStatus setFont:ZCUIFont10];
            _itemStatus.numberOfLines = 0;

            if ([[ZCPlatformTools sharedInstance] getPlatformInfo].config.msgFlag == 0) {
                [_itemName setTextColor:UIColorFromThemeColor(ZCTextSubColor)];
                NSString *string = [NSString stringWithFormat:@"%@，%@ %@",ZCSTLocalString(@"暂无客服在线"),ZCSTLocalString(@"您可以"),ZCSTLocalString(@"留言")];
                NSString *lstring = ZCSTLocalString(@"留言");
                NSUInteger len = lstring.length;
                NSMutableAttributedString *attribut = [[NSMutableAttributedString alloc]initWithString:string];
                NSMutableDictionary *dic = [NSMutableDictionary dictionary];
                dic[NSForegroundColorAttributeName] = UIColorFromThemeColor(ZCTextPlaceHolderColor);
                [attribut addAttributes:dic range:NSMakeRange(0,string.length - len)];
                
                NSMutableDictionary *dic_1 = [NSMutableDictionary dictionary];
                dic_1[NSForegroundColorAttributeName] = [ZCUITools zcgetRightChatColor];
                [attribut addAttributes:dic_1 range:NSMakeRange(string.length - len,len)];
                
                _itemStatus.attributedText = attribut;
                itemView.enabled = YES;
                
            }else{
                [_itemName setTextColor:UIColorFromThemeColor(ZCTextSubColor)];
                [_itemStatus setText:ZCSTLocalString(@"暂无客服在线")];
                
                [_itemStatus setTextColor:UIColorFromThemeColor(ZCTextPlaceHolderColor)];
                itemView.enabled = NO;
            }
            [_itemName sizeToFit];
            CGRect nf = _itemName.frame;
            nf.origin.y = 8;
            nf.origin.x = 8;
            nf.size.width = w -2*8;
            nf.size.height = _itemName.frame.size.height;
            _itemName.frame = nf;
            
            [_itemStatus sizeToFit];
            CGRect sf = _itemStatus.frame;
            sf.origin.x = 8;
            sf.origin.y = CGRectGetMaxY(_itemName.frame);
            sf.size.width = itemView.frame.size.width-2*8;
            sf.size.height = _itemStatus.frame.size.height;
            _itemStatus.frame = sf;
            [itemView addSubview:_itemStatus];
            
        }else{
             [_itemName setTextColor:[ZCUITools zcgetRightChatColor]];
            [_itemName setFrame:CGRectMake(8, 8 , itemView.frame.size.width -2*8, h-2*8)];
            itemView.enabled = YES;
            
        }
    }else{
        [itemView setBackgroundColor:UIColor.clearColor];
        
        [_itemName setTextColor:UIColorFromThemeColor(ZCTextMainColor)];
        SobotImageView *imgView = [SobotImageView imageViewWithURL:[NSURL URLWithString:sobotConvertToString(model.groupPic)] autoLoading:YES];
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
            f.size.height = _itemName.frame.size.height;
            _itemName.frame = f;
        }else{
            [imgView setFrame:CGRectMake(0, 0, 40, 40)];
//            imgView.layer.cornerRadius = 20.0f;
//            imgView.layer.masksToBounds = YES;
            [_itemName setFrame:CGRectMake(48, 0, w-48, 20)];
            _itemName.numberOfLines = 0;
            _itemName.textAlignment = NSTextAlignmentLeft;
            
            
            UILabel *_itemStatus = [[UILabel alloc] initWithFrame:CGRectMake(48,21, w-48, 18)];
            [_itemStatus setBackgroundColor:[UIColor clearColor]];
            [_itemStatus setTextAlignment:NSTextAlignmentLeft];
            [_itemStatus setFont:ZCUIFont12];
            _itemStatus.numberOfLines = 0;
            [_itemStatus setTextColor:UIColorFromThemeColor(ZCTextSubColor)];
            [_itemStatus setText:sobotConvertToString(model.desc)];
//            [_itemStatus setText:@"skdjfllkaksjdflkjlaksdjfl来思考点击了发卡机蓝思科技奥拉夫看记录打开就是劳动法开讲啦空数据登录分开"];
            [itemView addSubview:_itemStatus];
            
            [_itemName sizeToFit];
            CGRect NF = _itemName.frame;
            NF.size.height = _itemName.frame.size.height;
            _itemName.frame = NF;
            
            [_itemStatus sizeToFit];
            CGRect SF = _itemStatus.frame;
            SF.size.height = _itemStatus.frame.size.height;
            SF.origin.y = CGRectGetMaxY(_itemName.frame)+1;
            _itemStatus.frame = SF;
        }
        
    }
    
    return itemView;
}


- (void)itemClick:(UIButton *) view{
    ZCLibSkillSet *model =  listArray[view.tag];
    [SobotLog logHeader:SobotLogHeader info:@"%@",model.groupName];
    
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
