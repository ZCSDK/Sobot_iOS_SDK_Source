//
//  ZCAppletCell.m
//  SobotKit
//
//  Created by lizh on 2022/7/26.
//  Copyright © 2022 zhichi. All rights reserved.
//

#import "ZCAppletCell.h"
#import "ZCLibGlobalDefine.h"
#import "ZCUIColorsDefine.h"
#import "SobotXHImageViewer.h"
#import "SobotImageView.h"
#import "ZCStoreConfiguration.h"
#import "ZCUICore.h"
#import "ZCMLEmojiLabel.h"
#import "ZCHtmlCore.h"
@interface  ZCAppletCell()<ZCMLEmojiLabelDelegate>
{
    ZCLibMessage *_model;
}

@property (nonatomic,strong) UIView *bgView;
//@property (nonatomic,strong) UIView *cellBgView;
@property (nonatomic,strong) SobotImageView *logoView;
@property (nonatomic,strong) SobotImageView *thumbView;
@property (nonatomic,strong) UILabel *titleLab;
@property (nonatomic,strong) UILabel *descLab;
@property (nonatomic,strong) UIView *lineView;
@property (nonatomic,strong) SobotImageView *appletIcon;
@property (nonatomic,strong) UILabel *tipLab;
@property (nonatomic,strong) UIButton *btn;
@property (nonatomic,strong) UILabel *iv;

@property (nonatomic,strong) ZCMLEmojiLabel *suglabel;

@end

@implementation ZCAppletCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self=[super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if(self){
        
        _bgView = [[UIView alloc]init];
//        _bgView.backgroundColor = UIColorFromThemeColor(ZCBgSystemWhiteColor);
        _bgView.layer.cornerRadius = 5.0;
        _bgView.layer.masksToBounds = YES;
        _bgView.frame = CGRectMake(10, 10, 200, 200);
        _bgView.backgroundColor = UIColorFromThemeColor(ZCBgSystemWhiteColor);
        [self.contentView addSubview:_bgView];
    
        
        _logoView = [[SobotImageView alloc]init];
        [_logoView setBackgroundColor:[UIColor clearColor]];
        [_logoView setContentMode:UIViewContentModeScaleAspectFill];
        [_bgView addSubview:_logoView];
        
        _descLab = [[UILabel alloc]init];
        _descLab.textColor = [ZCUITools zcgetGoodsTextColor];
        _descLab.font = ZCUIFont14;
        _descLab.numberOfLines = 1;
        [_bgView addSubview:_descLab];
        
        // title
        _titleLab = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
        [_titleLab setTextAlignment:NSTextAlignmentLeft];
        [_titleLab setFont:ZCUIFontBold16];
        [_titleLab setTextColor:UIColorFromThemeColor(ZCTextMainColor)]; // 0x515a7c
        [_titleLab setBackgroundColor:[UIColor clearColor]];
        _titleLab.numberOfLines = 0;
        [_bgView addSubview:_titleLab];
        
        _thumbView = [[SobotImageView alloc]init];
        [_thumbView setBackgroundColor:UIColorFromRGB(0xCDD9EA)];
        _thumbView.contentMode = UIViewContentModeScaleToFill;
        [_bgView addSubview:_thumbView];
        
        _lineView = [[UIView alloc]init];
        _lineView.backgroundColor = [ZCUITools zcgetLineRichColor];
        [_bgView addSubview:_lineView];
        
        _appletIcon = [[SobotImageView alloc]init];
        [_appletIcon setBackgroundColor:[UIColor clearColor]];
        [_bgView addSubview:_appletIcon];
        
        _tipLab = [[UILabel alloc]init];
        _tipLab.font = ZCUIFont12;
        _tipLab.textColor = UIColorFromThemeColor(ZCTextSubColor);
        [_bgView addSubview:_tipLab];
        
        _btn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_btn addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
        [_bgView addSubview:_btn];
        
    }
    return self;
}

-(CGFloat) InitDataToView:(ZCLibMessage *) model time:(NSString *) showTime{
    _model = model;
    [self resetCellView];
    _suglabel.text = @"";
    _suglabel = nil;

    // 时间
    CGFloat bgY=[super InitDataToView:model time:showTime];
    CGFloat bgFH = bgY;
//    CGFloat maxWidth = self.viewWidth - 100;  // 卡片宽度固定 226
    CGFloat maxWidth = 226;
    // 有留言小图标
    if (model.leaveMsgFlag == 1) {
        maxWidth = maxWidth - 20;
    }
    
    CGFloat rw = maxWidth;
    if ([ZCChatBaseCell getStatusHeight:model] >0) {
        // 显示顶踩 固定最大宽度
        rw = maxWidth;
    }
    
    CGFloat cellHeight = 0;
    if (sobotConvertToString(model.richModel.logo).length > 0) {
        // 有APP图标
        _logoView.frame = CGRectMake(10, 12, 20, 20);
        cellHeight = cellHeight + 12 + 20;
        [_logoView loadWithURL:[NSURL URLWithString:sobotConvertToString(model.richModel.logo)] placeholer:[UIImage imageNamed:@""] showActivityIndicatorView:NO];
    }else{
        _logoView.frame = CGRectMake(0, 0, 0, 0);
    }
    
    if (sobotConvertToString(model.richModel.descStr).length > 0) {
        _descLab.frame = CGRectMake(40, 10, rw - 40, 20);
        if (sobotConvertToString(model.richModel.logo).length == 0) {
//            bgY = bgY +12 + 20;
            cellHeight = cellHeight + 12 + 20;
        }
        _descLab.text = sobotConvertToString(model.richModel.descStr);
    }else{
        _descLab.frame = CGRectMake(0, 0, 0, 0);
    }
    
    // 标题
    _titleLab.frame = CGRectMake(10, cellHeight + 10, rw - 20, 30);
    _titleLab.text = sobotConvertToString(model.richModel.titleStr);
    [_titleLab sizeToFit];
    CGFloat th = _titleLab.frame.size.height;
//    bgY = bgY + 20 + th;
    cellHeight = cellHeight + th;
    
    // 封面
    _thumbView.frame = CGRectMake(0, cellHeight + 10, rw -20, 180);
    [_thumbView loadWithURL:[NSURL URLWithString:sobotConvertToString(model.richModel.thumbUrl)] placeholer:[UIImage imageNamed:@""] showActivityIndicatorView:NO];
//    bgY = bgY + 10 + 180;
    cellHeight = cellHeight + 10 + 180;
    // 线条
    _lineView.frame = CGRectMake(5, cellHeight +1, rw - 15, 0.5);
//    bgY = bgY + 2;
    cellHeight = cellHeight + 2;
    // 小图标
    _appletIcon.frame = CGRectMake(10, cellHeight + 7, 12, 12);
    [_appletIcon loadWithURL:[NSURL URLWithString:@""] placeholer:[ZCUITools zcuiGetBundleImage:@"zcicon_applet"] showActivityIndicatorView:NO];
    // 提示文字
    _tipLab.frame = CGRectMake(CGRectGetMaxX(self.appletIcon.frame) + 5, cellHeight + 5, 100, 20);
    _tipLab.text = ZCSTLocalString(@"小程序");
//    bgY = bgY + 10 + 20;
    cellHeight = cellHeight + 10 + 20 + 10 ; // 最后10 个是间隙
    CGRect bgviewR = self.bgView.frame;
    bgviewR.origin.y = bgFH + 10;
    
    // 这里查看是否有关联问题
    CGFloat h = 0;
    CGFloat lineSpace = [ZCUITools zcgetChatLineSpacing];
    // 记录实际最大宽度
    CGFloat contentWidth = rw;
    if (!self.isRight && sobotConvertToString([model getModelDisplaySugestionText]).length > 0) {
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
            [ZCAppletCell setDisplayAttributedString:model.displaySugestionattr label:_suglabel model:model guide:YES];
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
        // height +10是间距 和引导问题 ，左边加15间距
        CGRect f = CGRectMake(15+15, h - s.height - lineSpace + CGRectGetMaxY(self.bgView.frame) +10, s.width, s.height);
        _suglabel.frame = f;
        [self.contentView addSubview:_suglabel];
    }
    
    
    CGFloat msgX = 0;
    if(self.isRight){
        int rx = self.viewWidth- rw - 15;
        msgX = rx + 15;
        bgviewR.origin.x = msgX;
        bgviewR.size.width = rw;
        self.bgView.frame = bgviewR;
        [self.ivBgView setFrame:CGRectMake(rx , bgFH, rw , cellHeight + 10)];
        self.suglabel.frame = CGRectZero;
        self.suglabel.text = @"";
    }else{
        float x = 15;
        msgX = x + 10;
        bgviewR.origin.x = msgX;
        bgviewR.size.height = cellHeight -10;
        bgviewR.size.width = rw- 20;
        self.bgView.frame = bgviewR;
        if (sobotConvertToString([model getModelDisplaySugestionText]).length == 0) {
            [self.ivBgView setFrame:CGRectMake(x, bgFH, rw , cellHeight + 10)];
        }else{
            CGRect sulabF = self.suglabel.frame;
            sulabF.origin.y = CGRectGetMaxY(self.bgView.frame) + 10;
            self.suglabel.frame = sulabF;
            [self.ivBgView setFrame:CGRectMake(x, bgFH, contentWidth + 15 , cellHeight + 10 + sulabF.size.height + 20)];
            cellHeight = cellHeight + sulabF.size.height +10;
        }
    }
    
    self.btn.frame = CGRectMake(0, 0, self.bgView.frame.size.width, self.bgView.frame.size.height);
    
    CGFloat sh = [self setSendStatus:self.ivBgView.frame];
    // 添加点踩和转人工
    [self isAddBottomBgView:self.ivBgView.frame msgIsOneLine:NO];
    
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
    // 设置尖角
    [self.ivLayerView setFrame:self.ivBgView.frame];
    CALayer *layer              = self.ivLayerView.layer;
    layer.frame                 = (CGRect){{0,0},self.ivLayerView.layer.frame.size};
    self.ivBgView.layer.mask = layer;
    [self.ivBgView setNeedsDisplay];
    [self setFrame:CGRectMake(0, 0, self.viewWidth, cellHeight + bgFH + sh + 20)];
    return cellHeight+ bgFH + 20 + sh;
}

//-(void)resetCellView{
//    [super resetCellView];
//    [self.lblNickName setText:@""];
//}

#pragma mark - 获取高度
+(CGFloat)getCellHeight:(ZCLibMessage *)model time:(NSString *)showTime viewWith:(CGFloat )viewWidth{
    CGFloat cellHeight = [super getCellHeight:model time:showTime viewWith:viewWidth];
    CGFloat maxWidth = viewWidth - 100;  // 小程序卡片 226宽度固定
    if (model.leaveMsgFlag == 1) {
        maxWidth = maxWidth - 20;
    }
    
    CGFloat rw = maxWidth;
    if ([ZCChatBaseCell getStatusHeight:model] >0) {
        // 显示顶踩 固定最大宽度
        rw = maxWidth;
    }
    
    if (sobotConvertToString(model.richModel.logo).length > 0) {
        // 有APP图标
        cellHeight = cellHeight + 12 + 20;
    }
    if (sobotConvertToString(model.richModel.descStr).length > 0) {
        if (sobotConvertToString(model.richModel.logo).length == 0) {
            cellHeight = cellHeight + 12 + 20;
        }
    }
    
    // 标题
    UILabel *titleLab = [[UILabel alloc]init];
    [titleLab setTextAlignment:NSTextAlignmentLeft];
    [titleLab setFont:ZCUIFontBold16];
    [titleLab setTextColor:[ZCUITools zcgetGoodsTextColor]]; // 0x515a7c
    titleLab.numberOfLines = 0;
    titleLab.frame = CGRectMake(10, 0, rw - 20, 30);
    titleLab.text = sobotConvertToString(model.richModel.titleStr);
    [titleLab sizeToFit];
    CGFloat th = titleLab.frame.size.height;
    cellHeight = cellHeight + th;
    // 封面
    cellHeight = cellHeight + 10 + 180;
    // 线条
    cellHeight = cellHeight + 2;
    // 小图标 + 提示文字
    cellHeight = cellHeight + 10 + 20 + 10;
  
    // 一问多答出现
    cellHeight = cellHeight +  [ZCChatBaseCell getStatusHeight:model];
    
    // 判断是否是一问多答中有关联问题
    if(sobotConvertToString([model getModelDisplaySugestionText]).length > 0){
        ZCMLEmojiLabel *slabel = [ZCChatBaseCell createRichLabel];
        UIColor *textColor = [ZCUITools zcgetLeftChatTextColor];
        UIColor *linkColor = [ZCUITools zcgetChatLeftLinkColor];
        if(model.displaySugestionattr!=nil){
            [ZCAppletCell setDisplayAttributedString:model.displaySugestionattr label:slabel model:model guide:YES];
        }else{
            [ZCHtmlCore filterHtml:[model getModelDisplaySugestionText] result:^(NSString * _Nonnull text1, NSMutableArray * _Nonnull arr, NSMutableArray * _Nonnull links) {
                if (text1 != nil && text1.length > 0) {
                    slabel.attributedText =    [ZCHtmlFilter setGuideHtml:text1 attrs:arr view:slabel textColor:textColor textFont:[ZCUITools zcgetKitChatFont] linkColor:linkColor];
                }else{
                    slabel.attributedText =   [[NSAttributedString alloc] initWithString:@""];
                }
            }];
        }
        CGSize s = [slabel preferredSizeWithMaxWidth:viewWidth-70-45];
        cellHeight = cellHeight + s.height + 20;
    }
    return cellHeight + 10 ;
}

-(void)btnClick:(UIButton *)sender{
    if(self.delegate && [self.delegate respondsToSelector:@selector(cellItemClick:type:obj:)]){
        [self.delegate cellItemClick:self.tempModel type:ZCChatCellClickTypeAppletAction obj:_model];
    }
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
    if ([touch.view isMemberOfClass:[ZCMLEmojiLabel class]]){
        return NO;
    }
    return YES;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
