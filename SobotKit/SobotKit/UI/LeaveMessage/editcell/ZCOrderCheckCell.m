//
//  ZCOrderCheckCell.m
//  SobotApp
//
//  Created by zhangxy on 2017/7/12.
//  Copyright © 2017年 com.sobot.chat.app. All rights reserved.
//

#import "ZCOrderCheckCell.h"
#import "ZCUIColorsDefine.h"
#import "ZCLibGlobalDefine.h"

@implementation ZCOrderCheckCell

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]){
        self.labelName = [[UILabel alloc]init];
        [self.labelName setFont:ZCUIFont14];
        [self.labelName setTextColor:UIColorFromThemeColor(ZCTextMainColor)];
        [self.labelName setNumberOfLines:0];
        [self.contentView addSubview:self.labelName];
        
        _labelContent = [[UILabel alloc]init];
        [_labelContent setTextColor:UIColorFromThemeColor(ZCTextPlaceHolderColor)];
        [_labelContent setFont:ZCUIFontBold14];
        [self.contentView addSubview:_labelContent];
        
        _imgArrow = [[UIImageView alloc]init];
        _imgArrow.image = [ZCUITools zcuiGetBundleImage:@"zcicon_arrow_right_record"];
//        _imgArrow.backgroundColor = [UIColor blueColor];
        [self.contentView addSubview:_imgArrow];
    }
    
    return self;
}



- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}


-(void)initDataToView:(NSDictionary *)dict{
//    [_labelName setText:dict[@"dictDesc"]];

   
    
    
    self.labelName.frame = CGRectMake(20, 17, self.tableWidth - 40, 20);
    
//    CGRect labelF = _labelName.frame;
//    CGSize size = [self autoHeightOfLabel:_labelName with:80.0f];
//    _labelContent.frame = CGRectMake(CGRectGetMaxX(_labelName.frame) + 10, 12, self.tableWidth - 95 -10 - 22 -20, 20);
//
//    CGFloat cellheight = 44;
//    if(size.height > labelF.size.height){
//        cellheight = size.height + 24;
//    }
//
//    [self setFrame:CGRectMake(0, 0, self.tableWidth, cellheight)];
//    CGPoint  NC = _labelName.center;
//    NC.y = self.frame.size.height/2;
//    _labelName.center = NC;
    
    [self checkLabelState:NO];
    
    self.labelName.attributedText = [self getOtherColorString:@"*" Color:[UIColor redColor] withString:dict[@"dictDesc"]];
       if(!zcLibIs_null(dict[@"dictValue"])){
           [_labelContent setText:dict[@"dictValue"]];
           [_labelContent setTextColor:UIColorFromThemeColor(ZCTextMainColor)];
       }else{
//           [_labelContent setText:dict[@"placeholder"]];
           [_labelContent setText:@""];
           [_labelContent setTextColor:UIColorFromThemeColor(ZCTextPlaceHolderColor)];
       }
       if([dict[@"propertyType"] intValue] == 3){
           _imgArrow.hidden = YES;
       }else{
           _imgArrow.hidden = NO;
       }
    
    _imgArrow.frame = CGRectMake(self.tableWidth - 25, 54/2-12/2, 7, 12);
    [self setFrame:CGRectMake(0, 0, self.tableWidth, 54)];
}

-(BOOL)checkLabelState:(BOOL) showSmall{
    BOOL isSmall = [super checkLabelState:showSmall text:@""];
    
    if(!isSmall){
        _labelContent.frame = CGRectMake(20, 17,self.tableWidth - 40,20);
//        [self setFrame:CGRectMake(0, 0, self.tableWidth, 44)];
    }else{
        //        _textContent.frame = CGRectMake(20, 29, self.tableWidth - 40, 104-30-20);
        _labelContent.frame = CGRectMake(20, 29, self.tableWidth - 40, 20);
    }
    return isSmall;
    
}


/**
 计算Label高度
 
 @param label 要计算的label，设置了值
 @param width label的最大宽度
 @param type 是否从新设置宽，1设置，0不设置
 */
- (CGSize )autoHeightOfLabel:(UILabel *)label with:(CGFloat )width{
    //Calculate the expected size based on the font and linebreak mode of your label
    // FLT_MAX here simply means no constraint in height
    CGSize maximumLabelSize = CGSizeMake(width, FLT_MAX);
    
    CGSize expectedLabelSize = [label sizeThatFits:maximumLabelSize];
    
    //adjust the label the the new height.
    CGRect newFrame = label.frame;
    newFrame.size.height = expectedLabelSize.height;
    label.frame = newFrame;
    [label updateConstraintsIfNeeded];
    
    return expectedLabelSize;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
