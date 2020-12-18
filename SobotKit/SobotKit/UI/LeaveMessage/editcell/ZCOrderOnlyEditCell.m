//
//  ZCOrderOnlyEditCell.m
//  SobotApp
//
//  Created by zhangxy on 2017/7/21.
//  Copyright © 2017年 com.sobot.chat.app. All rights reserved.
//

#import "ZCOrderOnlyEditCell.h"
#import "ZCUIColorsDefine.h"
#import "ZCLibGlobalDefine.h"
#import "ZCLibOrderCusFieldsModel.h"
// 限制方式  1禁止输入空格   2 禁止输入小数点  3 小数点后只允许2位  4 禁止输入特殊字符  5只允许输入数字 6最多允许输入字符  7判断邮箱格式  8判断手机格式
typedef enum _ZCEditLimitType {
    ZCEditLimitType_noPoint  = 0,
    ZCEditLimitType_onlyTwo,
    ZCEditLimitType_other,
    ZCEditLimitType_special
} ZCEditLimitType;

@interface ZCOrderOnlyEditCell()<UITextFieldDelegate>
@property(nonatomic,strong) NSString *labelNameStr;

@property(nonatomic,strong) ZCLibOrderCusFieldsModel *cusModel;
@property(nonatomic,assign) BOOL isHaveDian;
@end

@implementation ZCOrderOnlyEditCell

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]){
        self.labelName = [[UILabel alloc]init];
        [self.labelName setFont:ZCUIFont14];
        [self.labelName setTextColor:UIColorFromThemeColor(ZCTextMainColor)];
        [self.labelName setNumberOfLines:0];
        [self.contentView addSubview:self.labelName];
        
        _fieldContent = [[UITextField alloc]init];
        [_fieldContent setTextColor:UIColorFromThemeColor(ZCTextMainColor)];
        [_fieldContent setFont:ZCUIFontBold14];
        [_fieldContent setBorderStyle:UITextBorderStyleNone];
        [_fieldContent setBackgroundColor:UIColor.clearColor];
        [_fieldContent addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
        _fieldContent.delegate = self;

        [_fieldContent addTarget:self action:@selector(textFieldDidChangeBegin:) forControlEvents:UIControlEventEditingDidBegin];
        [self.contentView addSubview:_fieldContent];
    }
    
    return self;
}



- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

-(void)initDataToView:(NSDictionary *)dict{
    self.tempDict = dict;
//    [_labelName setText:dict[@"dictDesc"]];
    
    // 限制方式  1禁止输入空格   2 禁止输入小数点  3 小数点后只允许2位  4 禁止输入特殊字符  5只允许输入数字 6最多允许输入字符  7判断邮箱格式  8判断手机格式
    if([dict[@"dictType"] intValue] == 5 || [dict[@"dictName"] isEqualToString:@"ticketTel"]){
        _fieldContent.keyboardType = UIKeyboardTypeDecimalPad;
    }else{
        _fieldContent.keyboardType = UIKeyboardTypeDefault;
    }
    
    if(dict[@"model"]!=nil){
        _cusModel = dict[@"model"];
    }
    
    _fieldContent.placeholder = @"";
    _fieldContent.text = @"";
    [_fieldContent setPlaceholder:dict[@"placeholder"]];
    [_fieldContent setPlaceholder:@""];
    if(!zcLibIs_null(dict[@"dictValue"])){
        [_fieldContent setText:dict[@"dictValue"]];
    }
    
    self.labelName.frame = CGRectMake(20, 17, ScreenWidth - 40, 20);
    
//    CGRect labelF = self.labelName.frame;
//    CGSize size = [self autoHeightOfLabel:self.labelName with:80.0f];
   
    
//    _fieldContent.frame = CGRectMake(CGRectGetMaxX(self.labelName.frame) +10, 12, ScreenWidth - 95 - 10 -20 , 20);
    _fieldContent.frame = CGRectMake(20, 29, ScreenWidth - 40 , 20);
    
//    CGFloat cellheight = 44;
//    if(size.height > labelF.size.height){
//        cellheight = size.height + 24;
//    }
    
//    CGPoint FC = _fieldContent.center ;
//    FC.y = cellheight/2 ;
//    _fieldContent.center = FC;
//
//    [self setFrame:CGRectMake(0, 0, ScreenWidth, cellheight)];
//
//
//    CGPoint NC = self.labelName.center;
//    NC.y = self.frame.size.height/2;
//    self.labelName.center = NC;
    
    self.labelNameStr = dict[@"dictDesc"];
    NSString *string = [NSString stringWithFormat:@"%@  %@",self.labelNameStr,ZCSTLocalString(@"请输入")];
    self.labelName.attributedText = [self getOtherColorString:string colorArray:@[[UIColor redColor],UIColorFromThemeColor(ZCTextPlaceHolderColor)] withStringArray:@[@"*",ZCSTLocalString(@"请输入")]];
    
    [self checkLabelState:NO];
    

    
    [self setFrame:CGRectMake(0, 0, ScreenWidth, 54)];
}


-(BOOL)checkContentValid:(NSString *) text model:(ZCLibOrderCusFieldsModel *) model{
    
    if(model != nil && zcLibConvertToString(text).length >0){
        NSArray *limitOptions = nil;
        
        if(limitOptions==nil || limitOptions.count == 0){
            return YES;
        }
        if([model.limitOptions isKindOfClass:[NSString class]]){
            NSString *limitOption =  zcLibConvertToString(model.limitOptions);
            limitOption = [limitOption stringByReplacingOccurrencesOfString:@"[" withString:@""];
            limitOption = [limitOption stringByReplacingOccurrencesOfString:@"]" withString:@""];
            limitOptions = [limitOption componentsSeparatedByString:@","];
        }else if([model.limitOptions isKindOfClass:[NSArray class]]){
            limitOptions = model.limitOptions;
        }
        

        
        //限制方式  1禁止输入空格   2 禁止输入小数点  3 小数点后只允许2位  4 禁止输入特殊字符  5只允许输入数字 6最多允许输入字符  7判断邮箱格式  8判断手机格式
        if([limitOptions containsObject:[NSNumber numberWithInt:1]] || [limitOptions containsObject:@"1"]){
            NSRange _range = [text rangeOfString:@" "];
            if(_range.location!=NSNotFound) {
                return NO;
            }
        }
        if([limitOptions containsObject:[NSNumber numberWithInt:2]] || [limitOptions containsObject:@"2"]){
             NSRange _range = [text rangeOfString:@"."];
            if(_range.location!=NSNotFound) {
                return NO;
            }
        }
        if([limitOptions containsObject:[NSNumber numberWithInt:3]] || [limitOptions containsObject:@"3"]){
             return zcLibValidateDecimalDouble(text);
        }
        if([limitOptions containsObject:[NSNumber numberWithInt:4]] || [limitOptions containsObject:@"4"]){
             return zcLibValidateRuleNotBlank(text);
        }
        
        if([limitOptions containsObject:[NSNumber numberWithInt:5]] || [limitOptions containsObject:@"5"]){
             return zcLibValidateNumber(text);
        }
        
        if([limitOptions containsObject:[NSNumber numberWithInt:6]] || [limitOptions containsObject:@"6"]){
            if(zcLibConvertToString(text).length > [model.limitChar intValue]){
                return NO;
            }
        }
        
        if([limitOptions containsObject:[NSNumber numberWithInt:7]] || [limitOptions containsObject:@"7"]){
//            return zcLibValidateEmail(text);
        }
        
        if([limitOptions containsObject:[NSNumber numberWithInt:8]] || [limitOptions containsObject:@"8"]){
            if(zcLibConvertToString(text).length >= 11){
                return NO;
            }
            return zcLibValidateNumber(text);
        }
        
    }
    return YES;
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


-(BOOL)checkLabelState:(BOOL) showSmall{
    BOOL isSmall = [super checkLabelState:showSmall text:_fieldContent.text];
    
    if(!isSmall){
        _fieldContent.frame = CGRectMake(70, 17, ScreenWidth - 90, 20);
//        [self setFrame:CGRectMake(0, 0, ScreenWidth, 54)];
        NSString *string = self.labelNameStr;
        if (string) {
            NSString *string = [NSString stringWithFormat:@"%@  %@",self.labelNameStr,ZCSTLocalString(@"请输入")];
            self.labelName.attributedText = [self getOtherColorString:string colorArray:@[[UIColor redColor],UIColorFromThemeColor(ZCTextPlaceHolderColor)] withStringArray:@[@"*",ZCSTLocalString(@"请输入")]];
        }
    }else{
        //        _textContent.frame = CGRectMake(20, 29, ScreenWidth - 40, 104-30-20);
        _fieldContent.frame = CGRectMake(20, 29, ScreenWidth - 40, 20);
//        [self setFrame:CGRectMake(0, 0, ScreenWidth, 54)];
        NSString *string = self.labelNameStr;
        if (string) {
            self.labelName.attributedText = [self getOtherColorString:@"*" Color:[UIColor redColor] withString:string];
        }
    }

    
    return isSmall;
    
}

-(void)textFieldDidChangeBegin:(UITextField *) textField{
    if(self.delegate && [self.delegate respondsToSelector:@selector(didKeyboardWillShow:view1:view2:)]){
        [self.delegate didKeyboardWillShow:self.indexPath view1:nil view2:textField];
    }
    [self checkLabelState:YES];
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    
    if([self getLitmitTypeWithModel:_cusModel] == ZCEditLimitType_special) {
        if (!zcLibValidateRuleNotBlank(string)) {
            return NO;
        }
    }
    
    if([self getLitmitTypeWithModel:_cusModel] == ZCEditLimitType_noPoint) {
        if ([string isEqualToString:@"."]) {
            return NO;
        }
    }
    
    // 判断是否有小数点
    if ([textField.text containsString:@"."]) {
        self.isHaveDian = YES;
    }else{
        self.isHaveDian = NO;
    }
    if (string.length > 0) {
        //当前输入的字符
        
        
        unichar single = [string characterAtIndex:0];
        // 只能有一个小数点
        if([self getLitmitTypeWithModel:_cusModel] == ZCEditLimitType_onlyTwo) {
            if (self.isHaveDian && single == '.') {
                return NO;
            }
        }

          // 小数点后最多能输入两位
        if([self getLitmitTypeWithModel:_cusModel] == ZCEditLimitType_onlyTwo) {
            if (self.isHaveDian) {
                NSRange ran = [textField.text rangeOfString:@"."];
                    // 由于range.location是NSUInteger类型的，所以这里不能通过(range.location - ran.location)>2来判断
                if (range.location > ran.location) {
                    if ([textField.text pathExtension].length > 1) {

                        return NO;
                    }
                }
            }
        }
        
    }
    
    return YES;
}

- (ZCEditLimitType )getLitmitTypeWithModel:(ZCLibOrderCusFieldsModel *)model {
     if(model != nil ){
            NSArray *limitOptions = nil;
            
            if([model.limitOptions isKindOfClass:[NSString class]]){
                NSString *limitOption =  zcLibConvertToString(model.limitOptions);
                limitOption = [limitOption stringByReplacingOccurrencesOfString:@"[" withString:@""];
                limitOption = [limitOption stringByReplacingOccurrencesOfString:@"]" withString:@""];
                limitOptions = [limitOption componentsSeparatedByString:@","];
            }else if([model.limitOptions isKindOfClass:[NSArray class]]){
                limitOptions = model.limitOptions;
            }
            
            if([limitOptions containsObject:[NSNumber numberWithInt:2]] || [limitOptions containsObject:@"2"]){
                    return ZCEditLimitType_noPoint;
            }
            if([limitOptions containsObject:[NSNumber numberWithInt:3]] || [limitOptions containsObject:@"3"]){
                 return ZCEditLimitType_onlyTwo;
            }
         
         if([limitOptions containsObject:[NSNumber numberWithInt:4]] || [limitOptions containsObject:@"4"]){
              return ZCEditLimitType_special;
         }
     }
    
    return ZCEditLimitType_other;

}


-(void)textFieldDidEndEditing:(UITextField *)textField{
    // 失去焦点
    [self checkLabelState:NO];
}

-(void)textFieldDidChange:(UITextField *)textField{
    if(![self checkContentValid:textField.text model:_cusModel]){
        textField.text= [textField.text substringToIndex:textField.text.length - 1];
        return;
    }
    if (self.delegate && [self.delegate respondsToSelector:@selector(itemCreateCusCellOnClick:dictValue:dict:indexPath:)]) {
        [self.delegate itemCreateCusCellOnClick:ZCOrderCreateItemTypeOnlyEdit dictValue:zcLibConvertToString(textField.text) dict:self.tempDict indexPath:self.indexPath];
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
