//
//  ZCConfigBaseCell.m
//  SobotKitFrameworkTest
//
//  Created by zhangxy on 2020/7/16.
//  Copyright © 2020 zhichi. All rights reserved.
//

#import "ZCConfigBaseCell.h"
#import "EntityConvertUtils.h"
#import "ZCGuideData.h"

@interface ZCConfigBaseCell()<UITextFieldDelegate,UITextViewDelegate>

@end
@implementation ZCConfigBaseCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    [self createItemsView];
}


-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self=[super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if(self){
        self.userInteractionEnabled=YES;
        [self createItemsView];
    }
    return self;
}

-(void)createItemsView{
    if(!_labTitle){
        _labTitle = [[UILabel alloc] initWithFrame:CGRectMake(10, 12, ScreenWidth - 20, 21)];
        [_labTitle setTextColor:UIColorFromRGB(0x333333)];
        [self.contentView addSubview:_labTitle];
    }
    if(!_labDesc){
        _labDesc = [[UILabel alloc] initWithFrame:CGRectMake(10, CGRectGetMaxY(_labTitle.frame) + 5,ScreenWidth - 20, 20)];
        _labDesc.textColor = UIColorFromRGB(0x3D4966);
        _labDesc.font = [UIFont systemFontOfSize:13];
        _labDesc.numberOfLines = 0;
        [self.contentView addSubview:_labDesc];
    }
    
    if(!_fieldContent){
        _fieldContent = [[UITextField alloc] init];
        _fieldContent.textColor = UIColorFromRGB(0x333333);
        _fieldContent.layer.borderColor = UIColorFromRGB(0xEDEEF0).CGColor;
        _fieldContent.borderStyle = UITextBorderStyleLine;
        _fieldContent.layer.borderWidth = 1.0f;
        [self.contentView addSubview:_fieldContent];

        [_fieldContent addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
        [_fieldContent addTarget:self action:@selector(textFieldDidChangeBegin:) forControlEvents:UIControlEventEditingDidBegin];
    }
    
    if(!_textContent){
        _textContent = [[UITextView alloc] init];
        _textContent.textColor = UIColorFromRGB(0x333333);
        _textContent.layer.borderColor = UIColorFromRGB(0xEDEEF0).CGColor;
        _textContent.layer.borderWidth = 1.0f;
        _textContent.delegate = self;
        [self.contentView addSubview:_textContent];
    }
    
    if(!_switchControl){
        _switchControl = [[UISwitch alloc] init];
        [_switchControl setFrame:CGRectMake(ScreenWidth - 64, 5, 44, 44)];
        [_switchControl addTarget:self action:@selector(onControlChanged:) forControlEvents:UIControlEventValueChanged];
        [self.contentView addSubview:_switchControl];
    }
    
    if(!_imgArrow){
        _imgArrow = [[UIImageView alloc] initWithFrame:CGRectMake(ScreenWidth - 44, 20, 20, 20)];
        _imgArrow.image = [UIImage imageNamed:@"next_icon"];
        _imgArrow.contentMode = UIViewContentModeScaleAspectFit;
        [self.contentView addSubview:_imgArrow];
    }
}


-(void)dataToView:(NSDictionary *)item{
    self.tempDict = item;
    
    _switchControl.hidden = YES;
    _textContent.hidden = YES;
    _fieldContent.hidden = YES;
    _labDesc.hidden = YES;
    _imgArrow.hidden = YES;
    
    CGFloat maxHeight = 44;
    if(item){
        _labTitle.frame = CGRectMake(10, 12, ScreenWidth - 20, 21);
//        _labTitle.text = [NSString stringWithFormat:@"%@ %@",item[@"code"],item[@"name"]];
        _labTitle.text = [NSString stringWithFormat:@"%@-%@",item[@"name"],item[@"key"]];
        _labDesc.frame = CGRectMake(10, CGRectGetMaxY(_labTitle.frame) + 5,ScreenWidth - 20, 20);
        if(convertToString(item[@"desc"]).length > 0){
            _labDesc.text = [NSString stringWithFormat:@"【说明:%@】",item[@"desc"]];
        }else{
            _labDesc.text = @"";
        }
        [_labDesc sizeToFit];
        _labDesc.hidden = NO;
        
        NSString *ptype = item[@"type"];
        NSString *value = item[@"value"];
        if([@"BOOL" isEqual:ptype]){
            _switchControl.hidden = NO;
            if([value boolValue]){
                [_switchControl setOn:YES];
            }else{
                [_switchControl setOn:NO];
            }
            _labTitle.frame = CGRectMake(10, 12, ScreenWidth - 80, 21);
            
            maxHeight = CGRectGetMaxY(_labDesc.frame) + 10;
        }else if([@"NSString" isEqual:ptype] ||[@"UIColor" isEqual:ptype] ||[@"UIFont" isEqual:ptype]){
            _fieldContent.frame = CGRectMake(10, CGRectGetMaxY(_labDesc.frame) + 5, ScreenWidth - 20, 34);
            maxHeight = CGRectGetMaxY(_fieldContent.frame) + 10;
            _fieldContent.hidden = NO;
            [_fieldContent setText:value];
            
        }else if([@"MNSString" isEqual:ptype]){
            _textContent.frame = CGRectMake(10, CGRectGetMaxY(_labDesc.frame) + 5, ScreenWidth - 20, 80);
            maxHeight = CGRectGetMaxY(_textContent.frame) + 10;
            _textContent.hidden = NO;
            [_textContent setText:value];
        }else if([@"Function" isEqual:ptype]){
            _imgArrow.hidden = NO;
            
            maxHeight = CGRectGetMaxY(_labDesc.frame) + 10;
            _imgArrow.frame = CGRectMake(ScreenWidth - 44, maxHeight/2-10, 20, 20);
        }
    }
    self.frame = CGRectMake(0, 0, ScreenWidth, maxHeight);
}

-(void)onControlChanged:(UISwitch *) sender{
    if (self.delegate && [self.delegate respondsToSelector:@selector(itemChangedCellOnClick:dict:indexPath:)]) {
        [self.delegate itemChangedCellOnClick:@(sender.isOn) dict:self.tempDict indexPath:self.indexPath];
    }
}

-(void)textViewDidChange:(UITextView *)textView{
    if (self.delegate && [self.delegate respondsToSelector:@selector(itemChangedCellOnClick:dict:indexPath:)]) {
        [self.delegate itemChangedCellOnClick:textView.text dict:self.tempDict indexPath:self.indexPath];
    }
}

-(void)textViewDidBeginEditing:(UITextView *)textView{
    if(self.delegate && [self.delegate respondsToSelector:@selector(didKeyboardWillShow:view1:view2:)]){
        [self.delegate didKeyboardWillShow:self.indexPath view1:textView view2:nil];
    }
}



-(void)textFieldDidChangeBegin:(UITextField *) textField{
    if(self.delegate && [self.delegate respondsToSelector:@selector(didKeyboardWillShow:view1:view2:)]){
        [self.delegate didKeyboardWillShow:self.indexPath view1:nil view2:textField];
    }
}

-(void)textFieldDidChange:(UITextField *)textField{
    if (self.delegate && [self.delegate respondsToSelector:@selector(itemChangedCellOnClick:dict:indexPath:)]) {
       [self.delegate itemChangedCellOnClick:textField.text dict:self.tempDict indexPath:self.indexPath];
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

/**
 *  textField的代理方法，监听textField的文字改变
 *  textField.text是当前输入字符之前的textField中的text
 *
 *  @param textField textField
 *  @param range     当前光标的位置
 *  @param string    当前输入的字符
 *
 *  @return 是否允许改变
 */
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
   
//    if ([convertToString(self.tempDict[@"dictType"])  intValue] == 5) {
//        /*
//         * 不能输入.0-9以外的字符。
//         * 设置输入框输入的内容格式
//         * 只能有一个小数点
//         * 小数点后最多能输入两位
//         * 如果第一位是.则前面加上0.
//         * 如果第一位是0则后面必须输入点，否则不能输入。
//         */
//        BOOL isHaveDian = NO;
//        // 判断是否有小数点
//        if ([textField.text containsString:@"."]) {
//            isHaveDian = YES;
//        }else{
//            isHaveDian = NO;
//        }
//
//        if (string.length > 0) {
//
//            //当前输入的字符
//            unichar single = [string characterAtIndex:0];
//            //        BXLog(@"single = %c",single);
//
//            // 不能输入.0-9以外的字符
//            if (!((single >= '0' && single <= '9') || single == '.'))
//            {
//                //                [ZCProgressHUD showInfo:@"您的输入格式不正确"];
//                return NO;
//            }
//
//            // 只能有一个小数点
//            if (isHaveDian && single == '.') {
//                //                [ZCProgressHUD showInfo:@"最多只能输入一个小数点"];
//                return NO;
//            }
//
//            // 如果第一位是.则前面加上0.
//            if ((textField.text.length == 0) && (single == '.')) {
//                textField.text = @"0";
//            }
//
//            // 如果第一位是0则后面必须输入点，否则不能输入。
//            if ([textField.text hasPrefix:@"0"]) {
//                if (textField.text.length > 1) {
//                    NSString *secondStr = [textField.text substringWithRange:NSMakeRange(1, 1)];
//                    if (![secondStr isEqualToString:@"."]) {
//                        //                        [ZCProgressHUD showInfo:@"第二个字符需要是小数点"];
//                        return NO;
//                    }
//                }else{
//                    if (![string isEqualToString:@"."]) {
//                        //                        [ZCProgressHUD showInfo:@"第二个字符需要是小数点"];
//                        return NO;
//                    }
//                }
//            }
//
//            // 小数点后最多能输入两位
//            if (isHaveDian) {
//                NSRange ran = [textField.text rangeOfString:@"."];
//                // 由于range.location是NSUInteger类型的，所以这里不能通过(range.location - ran.location)>2来判断
//                if (range.location > ran.location) {
//                    if ([textField.text pathExtension].length > 1) {
//                        //                        [ZCProgressHUD showInfo:@"小数点后最多有两位小数"];
//                        return NO;
//                    }
//                }
//            }
//
//            // 最多输入10位
//            if (textField.text.length > 9) {
//                return NO;
//            }
//
//        }
//    }
//
//
    return YES;
}

@end
