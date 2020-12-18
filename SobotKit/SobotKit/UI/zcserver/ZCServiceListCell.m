//
//  ZCServiceListCell.m
//  SobotKit
//
//  Created by lizhihui on 2019/3/28.
//  Copyright © 2019 zhichi. All rights reserved.
//

#import "ZCServiceListCell.h"
#import "ZCLibGlobalDefine.h"
#import "ZCUIColorsDefine.h"
#import "ZCUIImageView.h"

@interface ZCServiceListCell(){
    
}

@property (nonatomic,strong) UILabel * titleLab;

@property (nonatomic,strong) ZCUIImageView * img;


@end

@implementation ZCServiceListCell

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        _titleLab = [[UILabel alloc]initWithFrame:CGRectMake(ZCNumber(20), 0, ScreenWidth - ZCNumber(80), 54)];
        _titleLab.textColor = [ZCUITools zcgetTopViewTextColor];
        _titleLab.textAlignment = NSTextAlignmentLeft;
        _titleLab.numberOfLines = 2;
        _titleLab.font = ZCUIFont14;
//        _titleLab.text = @"weriewr";
        [self.contentView addSubview:_titleLab];
        
        _img = [[ZCUIImageView alloc]initWithFrame:CGRectMake(ScreenWidth - ZCNumber(20) - 12 , ZCNumber(20), 8, 12)];
        [_img setContentMode:UIViewContentModeScaleAspectFit];
//        [_img setAutoresizingMask:UIViewAutoresizingFlexibleLeftMargin];
        _img.image = [ZCUITools zcuiGetBundleImage:@"zcicon_list_right_arrow"];
        [self.contentView addSubview:_img];
        
    }
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

-(void)initWithModel:(ZCSCListModel *)model width:(CGFloat)tableWidth{
    _titleLab.frame = CGRectMake(ZCNumber(20), 0, tableWidth - ZCNumber(80), 54);
    _titleLab.text = zcLibConvertToString(model.questionTitle);
//    self.contentView.layer.borderColor = UIColorFromRGB(0xdedede).CGColor;
//    self.contentView.layer.borderWidth = 0.5f;
    
    _img.frame =  CGRectMake(tableWidth - ZCNumber(15) -11 , ZCNumber(20), 12, 14);
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
