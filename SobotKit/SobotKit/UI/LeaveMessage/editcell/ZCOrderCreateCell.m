//
//  ZCOrderCreateCell.m
//  SobotApp
//
//  Created by zhangxy on 2017/7/12.
//  Copyright © 2017年 com.sobot.chat.app. All rights reserved.
//

#import "ZCOrderCreateCell.h"
#import "ZCUIColorsDefine.h"
#import "ZCLibGlobalDefine.h"

@implementation ZCOrderCreateCell

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]){
        
    }
    
    return self;
}


- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

-(void)initDataToView:(NSDictionary *)dict{
    _tempDict = dict;
    
}


-(BOOL)checkLabelState:(BOOL) showSmall text:(NSString *)text{
    if(_labelName){
        if(sobotConvertToString(self.tempDict[@"dictValue"]).length > 0 || sobotConvertToString(text).length >0 || showSmall){
            [_labelName setFrame:CGRectMake(20, 6, ScreenWidth - 40, 17)];
            [_labelName setFont:ZCUIFont12];
            [_labelName setTextColor:UIColorFromThemeColor(ZCTextPlaceHolderColor)];
            return YES;
        }else{
            [_labelName setFrame:CGRectMake(20, 17, ScreenWidth - 40, 20)];
            [_labelName setFont:ZCUIFont14];
            [_labelName setTextColor:UIColorFromThemeColor(ZCTextMainColor)];
            return NO;
        }
    }
    return NO;
    
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (NSMutableAttributedString *)getOtherColorString:(NSString *)originalString colorArray:(NSArray<UIColor *> *)colorArray withStringArray:(NSArray<NSString *> *)stringArray {
    
    if (stringArray.count != colorArray.count) {
        
        return [[NSMutableAttributedString alloc] initWithString:sobotConvertToString(originalString)];
    }
    
    NSMutableString *temp = [NSMutableString stringWithString:sobotConvertToString(originalString)];
    NSMutableAttributedString *str = [[NSMutableAttributedString alloc] initWithString:temp];
    for (int i = 0;i < stringArray.count; i++) {
        if (stringArray[i].length) {
            NSRange range = [temp rangeOfString:stringArray[i]];
            [str addAttribute:NSForegroundColorAttributeName value:colorArray[i] range:range];
        }
    }
    return str;
}



-(NSMutableAttributedString *)getOtherColorString:(NSString *)string Color:(UIColor *)Color withString:(NSString *)originalString
{
    NSMutableString *temp = [NSMutableString stringWithString:sobotConvertToString(originalString)];
    
    NSMutableAttributedString *str = [[NSMutableAttributedString alloc] initWithString:temp];
    if (string.length) {
        NSRange range = [temp rangeOfString:string];
        [str addAttribute:NSForegroundColorAttributeName value:Color range:range];
        return str;
    }
    return str;
    
}


@end
