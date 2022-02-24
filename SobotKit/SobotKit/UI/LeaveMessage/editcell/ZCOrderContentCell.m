//
//  ZCOrderContentCell.m
//  SobotApp
//
//  Created by zhangxy on 2017/7/12.
//  Copyright © 2017年 com.sobot.chat.app. All rights reserved.
//

#import "ZCOrderContentCell.h"
//#import "ZCUploadImageModel.h"
#import "ZCUIColorsDefine.h"
#import "ZCLibGlobalDefine.h"
#import "SobotImageView.h"
#import "ZCLibConfig.h"
#import "ZCIMChat.h"
#import "ZCPlatformTools.h"

#import "ZCHtmlFilter.h"
#import "ZCHtmlCore.h"
#import "ZCToolsCore.h"
#import "ZCActionSheet.h"

@interface ZCOrderContentCell()<UITextViewDelegate,UITextFieldDelegate,ZCActionSheetDelegate>{
    SobotImageView * imageView;
    UIButton *delButton;
}
@end

@implementation ZCOrderContentCell
-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]){
//        _viewContent = [[UIView alloc]init];
//        _viewContent.backgroundColor = [UIColor whiteColor];
//        [self.contentView addSubview:_viewContent];
        
        _textDesc = [[ZCUIPlaceHolderTextView alloc]init];
        _textDesc.placeholder = @"";
        [_textDesc setPlaceholderColor:UIColorFromThemeColor(ZCTextPlaceHolderColor)];
        [_textDesc setFont:ZCUIFont14];
        [_textDesc setTextColor:UIColorFromThemeColor(ZCTextMainColor)];
        _textDesc.delegate = self;
        _textDesc.placeholederFont = ZCUIFont14;
        _textDesc.layer.cornerRadius = 4.0f;
        _textDesc.layer.masksToBounds = YES;
        [_textDesc setBackgroundColor:[ZCUITools zcgetLeftChatColor]];
        _textDesc.textContainerInset = UIEdgeInsetsMake(10, 10, 0, 10);
//        _textDesc.backgroundColor = [UIColor blueColor];
        [self.contentView addSubview:_textDesc];
        
        _fileScrollView = [[UIScrollView alloc]init];
        _fileScrollView.scrollEnabled = YES;
        _fileScrollView.userInteractionEnabled = YES;
        _fileScrollView.showsVerticalScrollIndicator = NO;
        _fileScrollView.pagingEnabled = NO;
        _fileScrollView.backgroundColor = [UIColor clearColor];
        [self.contentView addSubview:_fileScrollView];
        
        _tipLab = [[UILabel  alloc]init];
        _tipLab.textColor = UIColorFromThemeColor(ZCTextSubColor);
         [_tipLab setFont:ZCUIFont14];
        _tipLab.text = @"";
        [self.contentView addSubview:_tipLab];
        self.backgroundColor = UIColorFromThemeColor(ZCBgSystemWhiteLightDarkColor);

    }
    
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}


- (NSMutableArray *)imageArr{
    if (!_imageArr) {
        _imageArr = [NSMutableArray arrayWithCapacity:0];
    }
    return _imageArr;
}


-(ZCLibConfig *)getCurConfig{
    return [[ZCPlatformTools sharedInstance] getPlatformInfo].config;
}

-(void)initDataToView:(NSDictionary *)dict{
    _tipLab.frame = CGRectMake(15, 12, self.tableWidth - 30, 0);
    
    _textDesc.text   = @"";
    _textDesc.frame = CGRectMake(20, 20, self.tableWidth-40, 154);
    
    UILabel * detailLab = [[UILabel alloc]initWithFrame:CGRectMake(20, CGRectGetMaxY(_tipLab.frame) + 10, self.tableWidth-80, 102)];
    detailLab.numberOfLines = 0;
    
    __block CGFloat DH = CGRectGetHeight(detailLab.frame);
    [ZCHtmlCore filterHtml:dict[@"placeholder"] result:^(NSString * _Nonnull text1, NSMutableArray * _Nonnull arr, NSMutableArray * _Nonnull links) {
        _textDesc.placeholder = text1;
       CGRect labelF  = [self getTextRectWith:text1 WithMaxWidth:self.tableWidth WithlineSpacing:0 AddLabel:detailLab];
        DH = labelF.size.height;
        _textDesc.placeholderLinkColor = UIColorFromThemeColor(ZCTextPlaceHolderColor);
    }];
    
    if (DH > 102) {
        _textDesc.frame = CGRectMake(20, 20, self.tableWidth-40, DH + 20);
    }
    
    [_textDesc setText:sobotConvertToString(self.tempModel.ticketDesc)];
    _tipLab.attributedText = [self getOtherColorString:@"*" Color:[UIColor redColor] withString:[NSString stringWithFormat:ZCSTLocalString(@"问题描述"),@"*"]];
       _tipLab.hidden = YES;
    if (_enclosureShowFlag) {
        _fileScrollView.frame = CGRectMake(20, CGRectGetMaxY(_textDesc.frame) + 10, self.tableWidth - 40, 80);
        [self reloadScrollView];
        self.frame = CGRectMake(0, 0, self.tableWidth, CGRectGetMaxY(_fileScrollView.frame));
    }else{
        self.frame = CGRectMake(0, 0, self.tableWidth, CGRectGetMaxY(_textDesc.frame) + 20 );
    }
    
    if(sobotIsRTLLayout()){
        [_textDesc setTextAlignment:NSTextAlignmentRight];
        [_tipLab setTextAlignment:NSTextAlignmentRight];
    }
}



- (void)reloadScrollView{
    
    // 先移除，后添加
    [[self.fileScrollView subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];
    // 加一是为了有个添加button
    NSUInteger assetCount = self.imageArr.count +1 ;
    
    CGFloat width = (self.fileScrollView.frame.size.width - 5*3)/4;
    CGFloat heigth = 60;
    CGFloat x = 0;
    NSUInteger countX = 0;
    if(sobotIsRTLLayout()){
        countX = (assetCount < 4) ? 4 : assetCount;
    }
    
    for (NSInteger i = 0; i < assetCount; i++) {
        
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        [btn setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
        x = (width + 5)*i;
        if(sobotIsRTLLayout()){
            x = (width + 5)* (countX - i - 1);
        }
        
        btn.imageView.contentMode = UIViewContentModeScaleAspectFill;
        btn.frame = CGRectMake(x,0, width, heigth);
        imageView.frame = btn.frame;
        // UIButton
        if (i == self.imageArr.count){
            // 最后一个Button
            [btn setImage: [ZCUITools zcuiGetBundleImage:@"zcicon_add_photo"]  forState:UIControlStateNormal];
            // 添加图片的点击事件
            [btn addTarget:self action:@selector(photoSelecte) forControlEvents:UIControlEventTouchUpInside];
            if (assetCount == 11) {
                assetCount = 10;
                btn.frame = CGRectZero;
            }
            [btn.imageView setContentMode:UIViewContentModeScaleAspectFit];
        }else{
            [btn.imageView setContentMode:UIViewContentModeScaleAspectFill];
            // 就从本地取
//            ZCUploadImageModel *model = [_imageArr objectAtIndex:i];
            if(sobotCheckFileIsExsis([_imagePathArr objectAtIndex:i])){
                UIImage *localImage=[UIImage imageWithContentsOfFile:[_imagePathArr objectAtIndex:i]];
                [btn setImage:localImage forState:UIControlStateNormal];
            }
            
            NSDictionary *imgDic = [_imageArr objectAtIndex:i];
            NSString *imgFileStr =  sobotConvertToString(imgDic[@"cover"]);
            if (imgFileStr.length>0) {
                UIImage *localImage=[UIImage imageWithContentsOfFile:imgFileStr];
                [btn setImage:localImage forState:UIControlStateNormal];
            }
            
            btn.tag = i;
            // 点击放大图片，进入图片
            [btn addTarget:self action:@selector(tapBrowser:) forControlEvents:UIControlEventTouchUpInside];
                btn.layer.borderColor = UIColorFromThemeColor(ZCBgLineColor).CGColor;
        }
        
        
        btn.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin;
        [self.fileScrollView addSubview:btn];

        if (i != self.imageArr.count){
            UIButton *btnDel = [UIButton buttonWithType:UIButtonTypeCustom];
            btnDel.imageView.contentMode = UIViewContentModeScaleAspectFit;
            x = (width + 5)*i + width - 24;
            if(sobotIsRTLLayout()){
                x = (width + 5)* (countX - i - 1) + width - 24;
            }
            
            btnDel.frame = CGRectMake(x,4, 20, 20);
            [btnDel setImage:[ZCUITools zcuiGetBundleImage:@"zcicon_close_down"] forState:0];
            btnDel.tag = 100 + i;
            // 点击放大图片，进入图片
            [btnDel addTarget:self action:@selector(tapDelFiles:) forControlEvents:UIControlEventTouchUpInside];
            [self.fileScrollView addSubview:btnDel];
        }
    }
    
    if(assetCount >= 4){
        self.fileScrollView.scrollEnabled = YES;
    }else{
        self.fileScrollView.scrollEnabled = NO;
    }
    // 设置contentSize
    self.fileScrollView.contentSize = CGSizeMake((width+5)*assetCount,self.fileScrollView.frame.size.height);
    if(assetCount > 4){
        if(sobotIsRTLLayout()){
            [self.fileScrollView setContentOffset:CGPointMake(0, 0)];
            
        }else{
            [self.fileScrollView setContentOffset:CGPointMake(self.fileScrollView.contentSize.width - self.fileScrollView.frame.size.width, 0)];
        }
    }
}


#pragma mark - 选择图片
// 添加图片
- (void)photoSelecte{
    if (self.delegate && [self.delegate respondsToSelector:@selector(itemCreateCellOnClick:dictKey:model:withButton:)]) {
        if(self.isReply){
            [self.delegate  itemCreateCellOnClick:ZCOrderCreateItemTypeAddReplyPhoto dictKey:@"dictContentImages" model:self.tempModel withButton:nil];
        }else{
        [self.delegate  itemCreateCellOnClick:ZCOrderCreateItemTypeAddPhoto dictKey:@"dictContentImages" model:self.tempModel withButton:nil];
        }
    }
    [_textDesc resignFirstResponder];
}


//预览图片
- (void)tapBrowser:(UIButton *)btn{
    // 点击图片浏览器 放大图片
//    NSLog(@"点击图片浏览器 放大图片");
    if (self.delegate && [self.delegate respondsToSelector:@selector(itemCreateCellOnClick:dictKey:model:withButton:)]) {
        if(self.isReply){
            [self.delegate  itemCreateCellOnClick:ZCOrderCreateItemTypeLookAtReplyPhoto dictKey: [NSString stringWithFormat:@"%d",(int)btn.tag] model:self.tempModel withButton:btn];
        }else{
            [self.delegate  itemCreateCellOnClick:ZCOrderCreateItemTypeLookAtPhoto dictKey:[NSString stringWithFormat:@"%d",(int)btn.tag]  model:self.tempModel withButton:btn];
        }
    }
    [_textDesc resignFirstResponder];
}


//
- (void)tapDelFiles:(UIButton *)btn{
    // 点击图片浏览器 放大图片
    //    NSLog(@"点击图片浏览器 放大图片");
    delButton = btn;
    NSString *tip = ZCSTLocalString(@"要删除这张图片吗？");
   NSInteger currentInt = btn.tag - 100;
   if(currentInt < _imagePathArr.count){
       NSString *file  = _imagePathArr[currentInt];
       if([file hasSuffix:@".mp4"]){
           tip = ZCSTLocalString(@"要删除这个视频吗?");
       }
   }
    ZCActionSheet *mysheet = [[ZCActionSheet alloc] initWithDelegate:self selectedColor:UIColorFromRGB(TextCleanMessageColor) showTitle:tip CancelTitle:ZCSTLocalString(@"取消") OtherTitles:ZCSTLocalString(@"删除"), nil];
    mysheet.tag = 3;
    mysheet.selectIndex = 2;
    [mysheet show];

    [_textDesc resignFirstResponder];
}

- (void)actionSheet:(ZCActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    if(actionSheet.tag == 3){
        if(buttonIndex == 2){
            if (self.delegate && [self.delegate respondsToSelector:@selector(itemCreateCellOnClick:dictKey:model:withButton:)]) {
                   if(self.isReply){
                       [self.delegate  itemCreateCellOnClick:ZCOrderCreateItemTypeDeletePhoto dictKey: [NSString stringWithFormat:@"%d",(int)delButton.tag - 100]  model:self.tempModel withButton:nil];
                   }else{
                       [self.delegate  itemCreateCellOnClick:ZCOrderCreateItemTypeDeletePhoto dictKey:[NSString stringWithFormat:@"%d",(int)delButton.tag - 100]   model:self.tempModel withButton:nil];
                   }
            }
        }
    }
}
-(void)textViewDidChange:(ZCUIPlaceHolderTextView *)textView{
    
    self.tempModel.ticketDesc = sobotConvertToString(textView.text);
   
    if (self.delegate && [self.delegate respondsToSelector:@selector(itemCreateCellOnClick:dictKey:model:withButton:)]) {
        
        [self.delegate  itemCreateCellOnClick:ZCOrderCreateItemTypeTitle dictKey:@"dictDesc" model:self.tempModel withButton:nil];
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

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}



-(CGRect)getTextRectWith:(NSString *)str WithMaxWidth:(CGFloat)width  WithlineSpacing:(CGFloat)LineSpacing AddLabel:(UILabel *)label{
    NSMutableAttributedString * attributedString = [[NSMutableAttributedString alloc]initWithString:str];
    NSMutableParagraphStyle * parageraphStyle = [[NSMutableParagraphStyle alloc]init];
    [parageraphStyle setLineSpacing:LineSpacing];
    [attributedString addAttribute:NSParagraphStyleAttributeName value:parageraphStyle range:NSMakeRange(0, [str length])];
    [attributedString addAttribute:NSFontAttributeName value:label.font range:NSMakeRange(0, str.length)];
    
    label.attributedText = attributedString;
    
    // 这里的高度的计算，不能在按 attributedString的属性去计算了，需要拿到label中的
    CGSize size = [self autoHeightOfLabel:label with:width];
    
    CGRect labelF = label.frame;
    labelF.size.height = size.height;
    label.frame = labelF;
    
    
    return labelF;
}


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


@end
