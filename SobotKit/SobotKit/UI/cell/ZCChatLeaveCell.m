//
//  ZCChatLeaveCell.m
//  SobotKit
//
//  Created by sobot on 2022/4/26.
//  Copyright © 2022 zhichi. All rights reserved.
//

#import "ZCChatLeaveCell.h"
#import "ZCLibGlobalDefine.h"
#import "ZCUIColorsDefine.h"

@interface ZCChatLeaveCell()<ZCMLEmojiLabelDelegate>{
   
}


@property (nonatomic,strong) UIView *cellLeaveView;

@end




@implementation ZCChatLeaveCell


-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self=[super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if(self){
        self.ivBgView.userInteractionEnabled = YES;
        
        _cellLeaveView = [[UIView alloc]init];
        [_cellLeaveView setBackgroundColor:[UIColor clearColor]];
        [self.contentView addSubview:_cellLeaveView];
        
        
        [self.contentView setBackgroundColor:[UIColor clearColor]];
        
        
        //设置点击事件
        UITapGestureRecognizer *tapGesturer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tap:)];
        self.ivBgView.userInteractionEnabled=YES;
        [self.ivBgView addGestureRecognizer:tapGesturer];
    }
    return self;
}

-(UILabel *) createSubLable{

    // 标签
    UILabel *lblTemp = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 0, 0)];
    [lblTemp setTextAlignment:NSTextAlignmentLeft];
    [lblTemp setFont:[ZCUITools zcgetKitChatFont]];
    [lblTemp setBackgroundColor:[UIColor clearColor]];
    [lblTemp setTextColor:UIColorFromThemeColor(ZCTextMainColor)];
    lblTemp.numberOfLines = 1;
    
    return lblTemp;
}


-(BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    //    if ([NSStringFromClass([touch.view class]) isEqualToString:@"UITableViewCellContentView"]) {
    //        //判断如果点击的是tableView的cell，就把手势给关闭了
    //        return NO;//关闭手势
    //    }
    //    //否则手势存在
    //    return YES;
    
    //    if (![NSStringFromClass([touch.view class]) isEqualToString:@"UIButton"]) {
    //        if(self.delegate && [self.delegate respondsToSelector:@selector(cellItemLinkClick:type:obj:)]){
    //            [self.delegate cellItemLinkClick:@"" type:ZCChatCellClickTypeOpenURL obj:[self getZCproductInfo].link];
    //        }
    //    }
    return YES;
}



-(CGFloat) InitDataToView:(ZCLibMessage *) model time:(NSString *) showTime{
    CGFloat height=[super InitDataToView:model time:showTime];
    self.tempModel = model;
    
    
    CGFloat msgX = 0;
    CGFloat msgY = height + 15;
    // 0,自己，1机器人，2客服
    self.marginWidth = 15;
    self.paddingWidth = 15;
    
    NSString *uploadMessage = model.richModel.msg;
    
    NSArray *arr = [uploadMessage componentsSeparatedByString:@"$\n$"];
    [_cellLeaveView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    CGSize size = CGSizeMake(self.maxWidth - self.marginWidth*2, 20);
    CGFloat subH = 0;
    CGFloat itemMaxWidth = 0;
    int i=0;
    for (NSString *text in arr) {
        NSArray *items =  [text componentsSeparatedByString:@"$:$"];
        
        ZCMLEmojiLabel *subLabel = [ZCChatBaseCell createRichLabel];
        subLabel.delegate = self;
        if(self.isRight){
            [subLabel setTextColor:[ZCUITools zcgetGoodsDetColor]];
//            [subLabel setLinkColor:[ZCUITools zcgetChatRightlinkColor]];
        }else{
            [subLabel setTextColor:[ZCUITools zcgetGoodsDetColor]];
//            [subLabel setLinkColor:[ZCUITools zcgetChatLeftLinkColor]];
        }
        if(items.count > 0){
            [ZCChatLeaveCell setTextColorAndFont:subLabel str:[NSString stringWithFormat:@"%@:\n%@",items[0],items[1]] textArray:items];
        }else{
            [subLabel setText:text];
        }
        CGSize s = [subLabel preferredSizeWithMaxWidth:size.width];
        [_cellLeaveView addSubview:subLabel];
        if(itemMaxWidth < CGRectGetWidth(subLabel.frame)){
            itemMaxWidth = CGRectGetWidth(subLabel.frame);
        }
        
        if(s.height<20){
            [subLabel setFrame:CGRectMake(0, subH + (44-s.height)/2, s.width, s.height)];
            subH = subH + 44;
        }else{
            [subLabel setFrame:CGRectMake(0, subH+10, s.width, s.height)];
            subH = subH + s.height + 20;
        }
        
        if(i < (arr.count -1)){
            UIView *lineView = [[UIView  alloc] initWithFrame:CGRectMake(0, subH-1, self.maxWidth - self.marginWidth*2, 1)];
            [lineView setBackgroundColor:[ZCUITools zcgetLineRichColor]];
            [_cellLeaveView addSubview:lineView];
        }
        i = i + 1;
    }
    
    if(self.isRight){
        int rx = self.viewWidth - self.maxWidth - self.marginWidth;
        msgX = rx + self.paddingWidth;
        

        [_cellLeaveView setFrame:CGRectMake(rx + self.marginWidth, height, self.maxWidth - self.marginWidth*2, subH)];
        [self.ivBgView setFrame:CGRectMake(rx, height, self.maxWidth, subH)];
    }else{
        msgX = self.marginWidth + self.paddingWidth;
        
        [_cellLeaveView setFrame:CGRectMake(msgX, height, self.maxWidth - self.paddingWidth * 2, subH)];
        [self.ivBgView setFrame:CGRectMake(self.marginWidth, height, self.maxWidth, subH)];
        
        //                [_cellBgView setFrame:CGRectMake(self.marginWidth, height, self.maxWidth, msgY - height)];
        
    }
    

    
    
    height= msgY+11;
    
    
    [self setSendStatus:self.ivBgView.frame];
    
    
    
    // 0,自己，1机器人，2客服
    if(self.isRight){
        // 右边气泡背景图片
        UIImage * bgImage = [ZCUITools zcuiGetBundleImage:@"zcicon_pop_green_normal_line"];
        bgImage=[bgImage resizableImageWithCapInsets:UIEdgeInsetsMake(21, 21, 21, 21)];
        
        self.ivBgView.image = bgImage;
        //设置尖角
        [self.ivLayerView setImage:bgImage];
        self.ivBgView.backgroundColor = UIColorFromThemeColor(ZCBgSystemWhiteLightGrayColor);
    }else{
        self.ivBgView.image = nil;
        [self.ivBgView setBackgroundColor:[ZCUITools zcgetLeftChatColor]];
    }
    
    if([ZCUITools getZCThemeStyle] == ZCThemeStyle_Dark){
        self.ivBgView.image = nil;
        self.ivBgView.backgroundColor = UIColorFromThemeColor(ZCBgSystemWhiteThirdGrayColor);
    }
    self.ivBgView.contentMode = UIViewContentModeScaleToFill;
    
    [self.ivLayerView setFrame:self.ivBgView.frame];
    CALayer *layer              = self.ivLayerView.layer;
    layer.frame                 = (CGRect){{0,0},self.ivLayerView.layer.frame.size};
    self.ivBgView.layer.mask = layer;
    
    [self.ivBgView setNeedsDisplay];
    
    
    [self setFrame:CGRectMake(0, 0, self.viewWidth, height)];
    
    
    return height;
}

// 监听暗黑模式变化
-(void)traitCollectionDidChange:(UITraitCollection *)previousTraitCollection{
    [super traitCollectionDidChange:previousTraitCollection];
    if(sobotGetSystemDoubleVersion()>=13){
        // trait发生了改变
        if ([self.traitCollection hasDifferentColorAppearanceComparedToTraitCollection:previousTraitCollection]) {
            // 执行操作
            // 0,自己，1机器人，2客服
            if(self.isRight){
                // 右边气泡背景图片
                UIImage * bgImage = [ZCUITools zcuiGetBundleImage:@"zcicon_pop_green_normal_line"];
                bgImage=[bgImage resizableImageWithCapInsets:UIEdgeInsetsMake(21, 21, 21, 21)];
                
                self.ivBgView.image = bgImage;
                //设置尖角
                [self.ivLayerView setImage:bgImage];
                self.ivBgView.backgroundColor = UIColorFromThemeColor(ZCBgSystemWhiteLightGrayColor);
            }else{
                self.ivBgView.image = nil;
                [self.ivBgView setBackgroundColor:[ZCUITools zcgetLeftChatColor]];
            }
            
            if([ZCUITools getZCThemeStyle] == ZCThemeStyle_Dark){
                self.ivBgView.image = nil;
                self.ivBgView.backgroundColor = UIColorFromThemeColor(ZCBgSystemWhiteThirdGrayColor);
            }
        }
    }
}


// 点击查看大图
-(void) tap:(UITapGestureRecognizer *)recognizer{
//    [SobotLog logDebug:@"查看大图：%@",self.tempModel.richModel.richmoreurl];
    [self onCellClick];
}


- (void)onCellClick{
    if(self.delegate && [self.delegate respondsToSelector:@selector(cellItemLinkClick:type:obj:)]){
        
        NSString * link = @"";
        
        if (link.length > 0) {
            [self.delegate cellItemLinkClick:@"" type:ZCChatCellClickTypeOpenURL obj:link];
        }
        
    }
}

-(void)resetCellView{
    [super resetCellView];
    
    [self.lblNickName setText:@""];
}


+(CGFloat)getCellHeight:(ZCLibMessage *)model time:(NSString *)showTime viewWith:(CGFloat)width{
    CGFloat cellheith = [super getCellHeight:model time:showTime viewWith:width];
    cellheith = cellheith + 15;
    CGFloat maxWidth = width - 100;
    
    NSString *uploadMessage = model.richModel.msg;
    
    NSArray *arr = [uploadMessage componentsSeparatedByString:@"$\n$"];
    CGSize size = CGSizeMake(maxWidth, 20);
    CGFloat subH = 0;
    CGFloat itemMaxWidth = 0;
    
    for (NSString *text in arr) {
        NSArray *items =  [text componentsSeparatedByString:@"$:$"];
        
        ZCMLEmojiLabel *subLabel = [ZCChatBaseCell createRichLabel];
        
        if(items.count > 0){
            [ZCChatLeaveCell setTextColorAndFont:subLabel str:[NSString stringWithFormat:@"%@:\n%@",items[0],items[1]] textArray:items];
        }else{
            [subLabel setText:text];
        }
        
        CGSize s = [subLabel preferredSizeWithMaxWidth:size.width];
        if(itemMaxWidth < CGRectGetWidth(subLabel.frame)){
            itemMaxWidth = CGRectGetWidth(subLabel.frame);
        }
        if(s.height<20){
            subH = subH + 44;
        }else{
            subH = subH + s.height + 20;
        }
    }
    return cellheith + subH + 11;
}


- (CGSize)sizeThatFits:(CGSize)size {
    
    CGSize rSize = [super sizeThatFits:size];
    rSize.height +=1;
    return rSize;
}

/**
 * 设置UILable 的字体和颜色
 @ label            :要设置的控件
 @ str                :要设置的字符串
 @ textArray      :有几个文字需要设置
 @ colorArray     :有几个颜色
 @ fontArray      :有几个字体
 */
+(void ) setTextColorAndFont:(UILabel *)label
                        str:(NSString *)string
                  textArray:(NSArray *)textArray
{
    NSMutableAttributedString *str = [[NSMutableAttributedString alloc] initWithString:string];
    for (int i = 0 ; i < [textArray count]; i++ )
    {
        NSRange range1 = [[str string] rangeOfString:textArray[i]];
        if(i==0){
            range1 = [[str string] rangeOfString:[textArray[i] stringByAppendingString:@":"]];
            [str addAttribute:NSForegroundColorAttributeName value:[ZCUITools zcgetGoodsDetColor] range:range1];
            [str addAttribute:NSFontAttributeName value:[ZCUITools zcgetKitChatFont] range:range1];
        }else{
            [str addAttribute:NSForegroundColorAttributeName value:[ZCUITools zcgetGoodsTextColor] range:range1];
            [str addAttribute:NSFontAttributeName value:ZCUIFontBold14 range:range1];
        }
    }
    label.attributedText = str;
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
        if([url hasPrefix:@"zc_refresh_newdata"]){
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



- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
