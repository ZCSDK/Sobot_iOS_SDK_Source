//
//  ZCOrderEditCell.m
//  SobotApp
//
//  Created by zhangxy on 2017/7/12.
//  Copyright © 2017年 com.sobot.chat.app. All rights reserved.
//  多行文本的编辑状态

#import "ZCOrderEditCell.h"
#import "ZCUIColorsDefine.h"
#import "ZCLibGlobalDefine.h"

@interface ZCOrderEditCell()<UITextViewDelegate>
@property(nonatomic,strong) NSString *labelNameStr;

@end

@implementation ZCOrderEditCell
-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]){
        self.labelName = [[UILabel alloc]init];
        self.labelName.backgroundColor = [UIColor clearColor];
        [self.labelName setFont:ZCUIFont14];
        [self.labelName setTextColor:UIColorFromThemeColor(ZCTextMainColor)];
        [self.labelName setNumberOfLines:0];
        
        [self.contentView addSubview:self.labelName];
        
        _textContent = [[ZCUIPlaceHolderTextView alloc]init];
        _textContent.placeholder = @"";
        _textContent.placeholederFont = ZCUIFont14;
        [_textContent setPlaceholderColor:UIColorFromThemeColor(ZCTextPlaceHolderColor)];
        [_textContent setTextColor:UIColorFromThemeColor(ZCTextMainColor)];
        [_textContent setFont:ZCUIFontBold14];
        [_textContent setBackgroundColor:UIColor.clearColor];
        _textContent.delegate = self;
        [self.contentView addSubview:_textContent];
    }
    
    return self;
}


- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

-(void)initDataToView:(NSDictionary *)dict{
//    [_labelName setText:dict[@"dictDesc"]];

    
    self.labelName.frame = CGRectMake(20, 12, self.tableWidth - 40, 0);
    [self autoHeightOfLabel:self.labelName with:self.tableWidth - 40];
    
//    CGFloat TH = CGRectGetHeight(_labelName.frame);
//    if (TH < 60) {
//        TH = 60;
//    }
    
//    _textContent.frame = CGRectMake(CGRectGetMaxX(_labelName.frame) + 6, 5, self.tableWidth - 90 - 15 -22, 104-15 -10);
    _textContent.frame = CGRectMake(20, 20, self.tableWidth - 20, 76-40);
//    [_textContent setPlaceholder:dict[@"placeholder"]];
    [_textContent setText:@""];
    if(!sobotIsNull(dict[@"dictValue"])){
        [_textContent setText:dict[@"dictValue"]];
    }
    [self checkLabelState:NO];
    
//    self.labelName.attributedText = [self getOtherColorString:@"*" Color:[UIColor redColor] withString:dict[@"dictDesc"]];
    
    self.labelNameStr = dict[@"dictDesc"];
    NSString *string = [NSString stringWithFormat:@"%@  %@",self.labelNameStr,ZCSTLocalString(@"请输入")];
    self.labelName.attributedText = [self getOtherColorString:string colorArray:@[[UIColor redColor],UIColorFromThemeColor(ZCTextPlaceHolderColor)] withStringArray:@[@"*",ZCSTLocalString(@"请输入")]];
    [self setFrame:CGRectMake(0, 0, self.tableWidth, 76)];

}


-(void)textViewDidChange:(ZCUIPlaceHolderTextView *)textView{
    if (self.delegate && [self.delegate respondsToSelector:@selector(itemCreateCusCellOnClick:dictValue:dict:indexPath:)]) {
        [self.delegate itemCreateCusCellOnClick:ZCOrderCreateItemTypeOnlyEdit dictValue:sobotConvertToString(textView.text) dict:self.tempDict indexPath:self.indexPath];
    }
    
    
}


-(BOOL)checkLabelState:(BOOL) showSmall{
    BOOL isSmall = [super checkLabelState:showSmall text:_textContent.text];
    
    if(!isSmall){
        _textContent.frame = CGRectMake(70, 17, self.tableWidth - 90, 76-40);
//        [self setFrame:CGRectMake(0, 0, self.tableWidth, 104)];
        NSString *string = self.labelNameStr;
        if (string) {
            NSString *string = [NSString stringWithFormat:@"%@  %@",self.labelNameStr,ZCSTLocalString(@"请输入")];
            self.labelName.attributedText = [self getOtherColorString:string colorArray:@[[UIColor redColor],UIColorFromThemeColor(ZCTextPlaceHolderColor)] withStringArray:@[@"*",ZCSTLocalString(@"请输入")]];
        }
    }else{
//        _textContent.frame = CGRectMake(20, 29, self.tableWidth - 40, 104-30-20);
        _textContent.frame = CGRectMake(17, 29, self.tableWidth - 40, 76-40);
//        [self setFrame:CGRectMake(0, 0, self.tableWidth, 104+12)];
        NSString *string = self.labelNameStr;
        if (string) {
            self.labelName.attributedText = [self getOtherColorString:@"*" Color:[UIColor redColor] withString:string];
        }
    }
    return isSmall;
    
}


-(void)textViewDidBeginEditing:(UITextView *)textView{
    if(self.delegate && [self.delegate respondsToSelector:@selector(didKeyboardWillShow:view1:view2:)]){
        [self.delegate didKeyboardWillShow:self.indexPath view1:textView view2:nil];
    }
    
    [self checkLabelState:YES];
}


- (void)textViewDidEndEditing:(UITextView *)textView{
    // 失去焦点
    [self checkLabelState:NO];
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
