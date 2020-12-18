//
//  ZCMsgRecordCell.m
//  SobotKit
//
//  Created by lizhihui on 2019/2/19.
//  Copyright © 2019 zhichi. All rights reserved.
//

#import "ZCMsgRecordCell.h"
#import "ZCUIColorsDefine.h"
#import "ZCLibGlobalDefine.h"
#import "ZCHtmlCore.h"
#import "ZCHtmlFilter.h"

@interface ZCMsgRecordCell(){
    
}

@property (nonatomic,strong) UILabel * titleLab;

@property (nonatomic,strong) UIImageView * picLab;

@property (nonatomic,strong) UILabel * statusLab;

@property (nonatomic,strong) UILabel * conLab;// content

@property (nonatomic,strong) UILabel * timeLab;

@property (nonatomic,strong) UILabel * orderIdLab;// 工单编号

@property (nonatomic,strong) UIView * bgView;

@property (nonatomic,strong) UIView * lineView;

// 2.8.0 增加两条线
@property (nonatomic,strong) UIView * topLineView;

@property (nonatomic,strong) UIView * bottomLineView;


@end

@implementation ZCMsgRecordCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]){
        self.backgroundColor = [ZCUITools zcgetLightGrayDarkBackgroundColor]; //UIColorFromRGB(TextRecordBgColor);
        _bgView = [[UIView alloc]init];
        _bgView.backgroundColor = UIColorFromThemeColor(ZCBgSystemWhiteLightDarkColor);
        [self.contentView addSubview:_bgView];
//        _bgView.layer.cornerRadius = 3.5f;
//        _bgView.layer.masksToBounds = YES;
        
        _topLineView = [[UIView alloc]init];
        _topLineView.backgroundColor = [ZCUITools zcgetBackgroundBottomLineColor];//UIColorFromRGB(lineGrayColor);
//        _topLineView.backgroundColor = [UIColor redColor];
        [_bgView addSubview:_topLineView];
        
        _bottomLineView = [[UIView alloc]init];
        _bottomLineView.backgroundColor = [ZCUITools zcgetBackgroundBottomLineColor];//UIColorFromRGB(lineGrayColor);
//        _bottomLineView.backgroundColor = [UIColor clearColor];

        [_bgView addSubview:_bottomLineView];
        
        _titleLab = [[UILabel alloc]init];
        _titleLab.font = ZCUIFont14;
        _titleLab.textColor = UIColorFromThemeColor(ZCTextSubColor);
        [_titleLab setNumberOfLines:2];
        [_bgView addSubview:_titleLab];
        
        
        _picLab = [[UIImageView alloc] initWithImage:[ZCUITools zcuiGetBundleImage:@"zcicon_new_tag"]];
        
        
        
        [_bgView addSubview:_picLab];
        
        
        
        _statusLab = [[UILabel alloc]init];
        _statusLab.textAlignment = NSTextAlignmentCenter;
        _statusLab.textColor = UIColorFromThemeColor(ZCKeepWhiteColor);
        _statusLab.backgroundColor = UIColorFromThemeColor(ZCThemeColor);
        _statusLab.font = ZCUIFont14;
        _statusLab.layer.cornerRadius = ZCNumber(15);
        _statusLab.layer.masksToBounds = YES;
        [_bgView addSubview:_statusLab];
        
//        _conLab = [[UILabel alloc]init];
//        [_conLab setNumberOfLines:2];
//        _conLab.textColor = UIColorFromRGB(TextRecordDetailColor);
//        _conLab.font = ZCUIFont14;
//        [_bgView addSubview:_conLab];
        
        
        _timeLab = [[UILabel alloc]init];
        _timeLab.textAlignment = NSTextAlignmentLeft;
        _timeLab.font = ZCUIFontBold16;
        [_timeLab setTextColor:UIColorFromThemeColor(ZCTextMainColor)];
        [_bgView addSubview:_timeLab];
        
        _orderIdLab = [[UILabel alloc]init];

//        _orderIdLab.textColor = UIColorFromRGB(TextRecordOrderIdColor);
//        _orderIdLab.font = ZCUIFont11;
//        _orderIdLab.textAlignment = NSTextAlignmentLeft;
//        [_bgView addSubview:_orderIdLab];
//
//        _lineView = [[UIView alloc] init];
//        _lineView.backgroundColor = UIColorFromRGB(lineGrayColor);
//        [_bgView addSubview:_lineView];
        
    }
    
    return self;
}


-(void)initWithDict:(ZCRecordListModel*)model with:(CGFloat) width{
    
    _bgView.frame = CGRectMake(ZCNumber(0), 11, width - ZCNumber(0), ZCNumber(110));
    
    _timeLab.frame =  CGRectMake(ZCNumber(20), ZCNumber(16), ZCNumber(170), ZCNumber(20));
//    _timeLab.backgroundColor = [UIColor blueColor];
    NSMutableAttributedString *attributedStr = [[NSMutableAttributedString alloc] initWithString:zcLibConvertToString(model.content)];
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.lineSpacing = 6.0; // 设置行间距
    [attributedStr addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, attributedStr.length)];
    
//    _titleLab.text = zcLibConvertToString(model.content);
//    _titleLab.attributedText = attributedStr;
    
    //@"问题描述lsakl阿里速度快缴费拉卡掉了金风科技埃里克森的家乐福卡拉伸的开发";
    _titleLab.frame = CGRectMake(ZCNumber(20),ZCNumber(47), CGRectGetWidth(_bgView.frame) -ZCNumber(122), ZCNumber(20));
//    _titleLab.backgroundColor = [UIColor blueColor];
    // 计算文本的宽度
    CGSize titleSize = [self sizeWithText:_titleLab.text withFont:_titleLab.font];
    if (titleSize.width > _titleLab.frame.size.width) {
        [_titleLab sizeToFit];
    }
    
    
    [self setString:zcLibConvertToString(model.content) withlLabel:_titleLab withColor:UIColorFromThemeColor(ZCTextSubColor)];
    
    
//    _titleLab.backgroundColor = [UIColor redColor];
    //    _timeLab.frame = CGRectMake(CGRectGetMaxX(_orderIdLab.frame), CGRectGetMaxY(_lineView.frame) + ZCNumber(6), CGRectGetWidth(_orderIdLab.frame), CGRectGetHeight(_orderIdLab.frame));
        _timeLab.text = zcLibConvertToString(zcLibDateTransformString(@"yyyy-MM-dd HH:mm:ss", zcLibStringFormateDate(model.timeStr)));// @"2019年01月11日 22:10";
    [_timeLab sizeToFit];
    // 显示最新处理过的工单编号 new

    _picLab.frame = CGRectMake(CGRectGetMaxX(_timeLab.frame)+ZCNumber(5), _timeLab.frame.origin.y+ZCNumber(2), ZCNumber(26), ZCNumber(14));

    _picLab.hidden = YES;
    if (model.newFlag == 2) {
        _picLab.hidden = NO;
    }
    
//    [_picLab sizeToFit];
    
    _statusLab.frame = CGRectMake(CGRectGetWidth(_bgView.frame) - ZCNumber(92), CGRectGetHeight(_bgView.frame) - ZCNumber(30) - ZCNumber(24), ZCNumber(72), ZCNumber(30));
    _statusLab.text = ZCSTLocalString(@"已创建");
    
    switch (model.flag) {
        case 1:
            _statusLab.text =  ZCSTLocalString(@"已创建");
            _statusLab.backgroundColor = UIColorFromThemeColor(ZCTextPlaceHolderColor);
            break;
        case 2:
            _statusLab.text =  ZCSTLocalString(@"受理中");
            _statusLab.backgroundColor = UIColorFromThemeColor(ZCTextNoticeLinkColor);
            break;
        case 3:
            _statusLab.text =  ZCSTLocalString(@"已完成");
            _statusLab.backgroundColor = UIColorFromThemeColor(ZCThemeColor);
            break;
        default:
            break;
    }
    
    
    CGSize s = [_statusLab.text sizeWithAttributes:@{NSFontAttributeName:_statusLab.font}];
    if(s.width > 72){
        _statusLab.frame = CGRectMake(CGRectGetWidth(_bgView.frame) - 10 - s.width-10, _titleLab.frame.origin.y, s.width+10, ZCNumber(20));
    }
    
    
    _topLineView.frame = CGRectMake(0, 0, _bgView.frame.size.width, 0.5);
    _bottomLineView.frame = CGRectMake(0, _bgView.frame.size.height - 0.5, _bgView.frame.size.width, 0.5);

}


#pragma mark -- 获取文本的宽度
/**
 
 计算单行文字的size
 
 @parms  文本
 
 @parms  字体
 
 @return  字体的CGSize
 
 */
-(CGSize)sizeWithText:(NSString *)text withFont:(UIFont *)font{
    
    CGSize size = [text sizeWithAttributes:@{NSFontAttributeName:font}];
    
    return size;
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void)setString:(NSString *)string withlLabel:(UILabel *)label withColor:(UIColor *)textColor {
    [ZCHtmlCore filterHtml: [ZCHtmlCore filterHTMLTag:string] result:^(NSString * _Nonnull text1, NSMutableArray * _Nonnull arr, NSMutableArray * _Nonnull links) {
 
        if (text1.length > 0 && text1 != nil) {
            label.attributedText =   [ZCHtmlFilter setHtml:text1 attrs:arr view:label textColor:textColor textFont:label.font linkColor:[ZCUITools zcgetChatLeftLinkColor]];
        }else{
            label.attributedText =   [[NSAttributedString alloc] initWithString:@""];
        }

    }];
    
}

@end
