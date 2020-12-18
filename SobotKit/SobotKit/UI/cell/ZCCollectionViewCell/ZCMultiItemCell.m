//
//  ZCMultiItemCell.m
//  SobotKit
//
//  Created by lizhihui on 2017/11/13.
//  Copyright © 2017年 zhichi. All rights reserved.
//

#import "ZCMultiItemCell.h"
#import "ZCLibGlobalDefine.h"
#import "ZCUIColorsDefine.h"
#import "ZCPlatformTools.h"
#import "ZCButton.h"

@interface  ZCMultiItemCell(){
    
}

@property(nonatomic,strong)UIView *itemsView;

@property (nonatomic,strong) UILabel * titleLab;

@property (nonatomic,assign) BOOL  isHistoryMessages;

@property (nonatomic,strong) ZCButton * moreBtn;// 展开

@property (nonatomic,assign) int moreCount;// 展开

@property (nonatomic,assign) int allMoreCount;// 总个数

@property (nonatomic,strong) ZCLibMessage * countModel;// 记录当前的mode

@end


@implementation ZCMultiItemCell


-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self=[super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if(self){
        [self setupView];
        [self moreBtn];
        
    }
    return self;
}

- (void)setupView {
//    self.backgroundColor = [UIColor whiteColor];
//    self.contentView.backgroundColor = [UIColor whiteColor];
    
    _itemsView = ({
        UIView *imageView = [UIView new];
        imageView.clipsToBounds = YES;
        [imageView setBackgroundColor:UIColor.redColor];
        [self.contentView addSubview:imageView];
        [imageView setFrame:CGRectMake(0, 0, ScreenWidth, 0)];
        imageView;
    });
}

-(ZCButton *)moreBtn{
    if (!_moreBtn) {
        _moreBtn = [ZCButton buttonWithType:UIButtonTypeCustom];
        _moreBtn.type = 2;
        _moreBtn.backgroundColor = [UIColor whiteColor];
        _moreBtn.layer.cornerRadius = 13;
        _moreBtn.layer.masksToBounds = YES;
        [_moreBtn setTitle:ZCSTLocalString(@"展开") forState:UIControlStateNormal];
        [_moreBtn setImage:[ZCUITools zcuiGetBundleImage:@"zciocn_arrow_down"] forState:UIControlStateNormal];
        [_moreBtn addTarget:self action:@selector(openMoreAction:) forControlEvents:UIControlEventTouchUpInside];
        [_moreBtn setTitleColor:[ZCUITools zcgetOpenMoreBtnTextColor] forState:UIControlStateNormal];
        _moreBtn.titleLabel.font = ZCUIFont14;
        [self.contentView addSubview:_moreBtn];
        _moreBtn.hidden = YES;
    }
    return _moreBtn;
}
-(void)openMoreAction:(ZCButton*)sender{
    
        // 最大值 回复最小值9
        if (self.moreCount == self.allMoreCount) {
            self.moreCount = 9;
            self.countModel.richModel.multiModel.moreCurrtCount = self.moreCount;
            self.tempModel.richModel.multiModel.moreCurrtCount = self.moreCount;
            [_moreBtn setTitle:ZCSTLocalString(@"展开") forState:UIControlStateNormal];
            [_moreBtn setImage:[ZCUITools zcuiGetBundleImage:@"zciocn_arrow_down"] forState:UIControlStateNormal];
            if (self.delegate && [self.delegate respondsToSelector:@selector(cellItemClick:type:obj:)]) {
                [self.delegate cellItemClick:nil type:ZCChatCellClickTypeCollectionBtnSend obj:nil];
            }
            return;
        }
        
        self.moreCount = self.moreCount + 9;
        if (self.moreCount >self.allMoreCount) {
            self.moreCount = self.allMoreCount;
        }
        
        self.tempModel.richModel.multiModel.moreCurrtCount = self.moreCount;
        self.countModel.richModel.multiModel.moreCurrtCount = self.moreCount;
        if (self.delegate && [self.delegate respondsToSelector:@selector(cellItemClick:type:obj:)]) {
            [self.delegate cellItemClick:nil type:ZCChatCellClickTypeCollectionBtnSend obj:nil];
        }
        
        if (self.allMoreCount<10) {
            self.moreBtn.hidden = YES;
        }
    
}

#pragma mark -- 计算高度
-(CGFloat) InitDataToView:(ZCLibMessage *)model time:(NSString *)showTime{
    CGFloat bgY = [super InitDataToView:model time:showTime];
    CGFloat height = 0;
    if (self.countModel == nil) {
         self.countModel = model;
    }else{
        model = self.countModel;
    }
   
    _isHistoryMessages = model.richModel.multiModel.isHistoryMessages;
    
    [_itemsView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    _titleLab = [[UILabel alloc]initWithFrame:CGRectMake(15, 10, ScreenWidth - 160 - 30, 20)];
     [_itemsView addSubview:_titleLab];
    _titleLab.text = model.richModel.multiModel.msg;
    _titleLab.textColor = UIColorFromThemeColor(ZCTextMainColor);
    _titleLab.font = ZCUIFont14;
    _titleLab.backgroundColor = [UIColor clearColor];
    _titleLab.numberOfLines = 0;
    // 重新计算label的高度根据文本的内容
//    CGSize  titleSize = [self autoHeightOfLabel:_titleLab with:ScreenWidth - 160 - 30 setH:1];
//    CGRect titleFrame = _titleLab.frame;
//    titleFrame.size = titleSize;
//    _titleLab.frame = titleFrame;
    [self autoHeightOfLabel:_titleLab with:ScreenWidth - 160 - 30];

    CGFloat itemY = CGRectGetMaxY(_titleLab.frame) + 10;
    CGFloat itemX = 15;
    CGFloat itemW = ScreenWidth - 160 - 30; // 最大宽度 -160 为最大宽度 -20 为左右间距
    CGFloat allbtnH = 0;
    NSString *text = ZCSTLocalString(@"标签");
    
    CGFloat itemMaxW = 0;
    CGRect itemFrame;
    
    self.allMoreCount = (int)model.richModel.multiModel.interfaceRetList.count;
    
    if (model.richModel.multiModel.moreCurrtCount > 0) {
        self.moreCount = model.richModel.multiModel.moreCurrtCount;
    }
    if (self.moreCount == 0 ) {
        self.moreCount = 9;
    }
    if (self.allMoreCount <=9) {
        self.moreCount = self.allMoreCount;
    }else if (self.moreCount>self.allMoreCount){
        self.moreCount = (int)model.richModel.multiModel.interfaceRetList.count;
    }
    
    model.richModel.multiModel.moreCurrtCount = self.moreCount;
    if (model.isHistory) {
        if (self.moreCount >9) {
            self.moreCount = 9;
        }
    }
    
    for (int tag = 0; tag <self.moreCount; tag ++) {
        NSString * tipstr = @"";
        NSDictionary * detailModel = model.richModel.multiModel.interfaceRetList[tag];
        tipstr = detailModel[@"title"];
        text = [NSString stringWithFormat:@"%@",tipstr];
        CGRect itemF =  [self createTypeItemView:text frame:CGRectMake(itemX, itemY, itemW, 28) tag:tag];
        
        //
        if((ScreenWidth - 130 - 30 - 58 - (itemF.size.width + itemF.origin.x)) < 20){
            itemX = 15;
            itemW = ScreenWidth -160 - 30;
            itemY = itemF.size.height + itemF.origin.y + 10;
            allbtnH = itemY;
        }else{
            itemX = itemF.size.width + itemF.origin.x + 10;
            itemY = itemF.origin.y;
            allbtnH = itemY + 26 ;
        }
//        NSLog(@"当前的Y %f  tag %d",itemY,tag);
        itemFrame = itemF;
       
        if ( (itemF.origin.x + itemF.size.width) >itemMaxW) {
            itemMaxW = itemF.origin.x + itemF.size.width;
        }
        
    }
    
//    if (model.richModel.multiModel.interfaceRetList.count %2 == 0) {
//        itemY = itemY - itemFrame.size.height + 10;
//    }
    
    [_itemsView setBackgroundColor:[UIColor clearColor]];
    
    
    height = height +allbtnH;
    
    if (allbtnH == 0) {
        height = CGRectGetMaxY(_titleLab.frame) ;
    }else{
        if (allbtnH < 80) {
//            height = height - 10;
        }
        
    }
    
    CGFloat bgW = self.titleLab.frame.size.width + 20;
    if (itemMaxW > self.titleLab.frame.size.width ) {
        bgW = itemMaxW + 10 ;
    }
    
    CGFloat msgX = 0;
    msgX = 78;
    [self.ivBgView setFrame:CGRectMake(58, bgY, bgW, height+10)];
    
    
    // 设置尖角
    [self.ivLayerView setFrame:self.ivBgView.frame];
    
    // 白色背景的frame
    [_itemsView setFrame:self.ivBgView.frame];
    
    CALayer *layer              = self.ivLayerView.layer;
    layer.frame                 = (CGRect){{0,0},self.ivLayerView.layer.frame.size};
    self.ivBgView.layer.mask = layer;
    [self.ivBgView setNeedsDisplay];
    
    if (self.allMoreCount>9 && !model.isHistory) {
        [self.moreBtn setFrame:CGRectMake(CGRectGetMaxX(_itemsView.frame)-90, CGRectGetMaxY(_itemsView.frame) + 10, 90, 26)];
        self.moreBtn.hidden = NO;
        
        
        // 当前是 以增加到最大值
        if (self.moreCount == self.allMoreCount && self.allMoreCount>9) {
            [_moreBtn setImage:[ZCUITools zcuiGetBundleImage:@"zciocn_arrow_up"] forState:UIControlStateNormal];
            [_moreBtn setTitle:ZCSTLocalString(@"收起") forState:UIControlStateNormal];
        }
        
        // 36为添加的间距
        [self setFrame:CGRectMake(0, 0, self.viewWidth, height +10 +36)];
        return height + bgY +10 +36;
    }else{
        self.moreBtn.hidden = YES;
        [self setFrame:CGRectMake(0, 0, self.viewWidth, height +10)];
        return height + bgY +10;
    }
    
    

}

+(CGFloat)getCellHeight:(ZCLibMessage *)model time:(NSString *)showTime viewWith:(CGFloat)width{
    CGFloat bgY = [super getCellHeight:model time:showTime viewWith:width];
    CGFloat height = 0;
    UILabel * titleLab = [[UILabel alloc]initWithFrame:CGRectMake(15, 10, ScreenWidth - 160 - 30, 20)];
    titleLab.text = model.richModel.multiModel.msg;
    titleLab.textColor = UIColorFromThemeColor(ZCTextMainColor);
    titleLab.font = ZCUIFont14;
    titleLab.numberOfLines = 0;
    // 重新计算label的高度根据文本的内容
//    CGSize  titleSize = [self autoHeightOfLabel:titleLab with:ScreenWidth - 160 - 30 setH:1];
//    CGRect titleFrame = titleLab.frame;
//    titleFrame.size = titleSize;
//    titleLab.frame = titleFrame;
    [self autoHeightOfLabel:titleLab with:ScreenWidth - 160 - 30];
    
    CGFloat allbtnH = 0;
    CGFloat itemY = CGRectGetMaxY(titleLab.frame) + 10;
    CGFloat itemX = 15;
    CGFloat itemW = ScreenWidth - 160 - 30;
    //    CGFloat cellHeight = 10;
    
    NSString *text = ZCSTLocalString(@"标签");
    CGRect itemFrame ;
    // 获取个数
    int allMoreCount = (int)model.richModel.multiModel.interfaceRetList.count;;
    int currtMoreCount = 0;
    
    
    if (model.richModel.multiModel.moreCurrtCount != 0) {
        currtMoreCount = model.richModel.multiModel.moreCurrtCount;
    }
    
    if (currtMoreCount == 0 ) {
        currtMoreCount = 9;
    }
    if (allMoreCount <=9) {
        currtMoreCount = allMoreCount;
    }else if (currtMoreCount > allMoreCount){
        currtMoreCount = (int)model.richModel.multiModel.interfaceRetList.count;
    }
    
    model.richModel.multiModel.moreCurrtCount = currtMoreCount;
//    BOOL isHistoryMessages = model.richModel.multiModel.isHistoryMessages;
    if (model.isHistory) {
        if (currtMoreCount>9) {
            currtMoreCount = 9;
        }
    }
    for (int tag = 0; tag<currtMoreCount; tag ++) {
        NSDictionary * detailModel = model.richModel.multiModel.interfaceRetList[tag];
        text = [NSString stringWithFormat:@"%@",detailModel[@"title"]];
        CGRect itemF =  [self createTypeItemView:text frame:CGRectMake(itemX, itemY, itemW, 28) tag:tag];
        //        tag = tag + 1;
        if((ScreenWidth - 130 - 30 - 58 - (itemF.size.width + itemF.origin.x)) < 20){
            itemX = 15;
            itemW = ScreenWidth -160 - 30;
            itemY = itemF.size.height + itemF.origin.y + 10;
            allbtnH = itemY;
        }else{
            itemX = itemF.size.width + itemF.origin.x + 10;
            itemY = itemF.origin.y;
            allbtnH = itemY + 26;
        }
        itemFrame = itemF;
     
    }
    
//    if (model.richModel.multiModel.interfaceRetList.count %2 == 0) {
//        itemY = itemY - itemFrame.size.height + 10;
//    }
    
    height = height + allbtnH ;
    if (allbtnH == 0) {
        height = CGRectGetMaxY(titleLab.frame) ;
    }else{
        if (allbtnH < 80) {
//            height = height - 10;
        }
    }
    
    if (allMoreCount>9 && !model.isHistory) {
        return height + bgY +15 + 36;
    }else{
        return height + bgY +15;
    }
    
}


-(CGRect )createTypeItemView:(NSString *) text frame:(CGRect) itemF tag:(int) tag{
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    [btn setTitle:text forState:UIControlStateNormal];
    btn.tag = tag;
    [btn setContentHorizontalAlignment:UIControlContentHorizontalAlignmentCenter];
    [btn.titleLabel setFont:ZCUIFont14];
    btn.layer.cornerRadius = 4.0f;
    btn.layer.borderColor = UIColorFromThemeColor(ZCTextPlaceHolderColor).CGColor;
    btn.titleLabel.lineBreakMode = NSLineBreakByTruncatingTail;
    [btn setTitleColor:UIColorFromThemeColor(ZCTextMainColor) forState:UIControlStateNormal];
    [btn setBackgroundImage:[self createImageWithColor:UIColorFromThemeColor(ZCBgLightGrayDarkColor)]forState:UIControlStateHighlighted];
    if (_isHistoryMessages) {
        [btn setBackgroundColor:UIColorFromRGB(multiWheelBgColor)];
//        btn.userInteractionEnabled = NO;
    }else{
       
       [btn setBackgroundColor:UIColorFromThemeColor(ZCKeepWhiteColor)];
//       btn.userInteractionEnabled = YES;
    }
    [btn addTarget:self action:@selector(onItemClick:) forControlEvents:UIControlEventTouchUpInside];
    btn.layer.borderWidth = 0.75f;
    btn.layer.masksToBounds = YES;

    [btn setFrame:itemF];
    [_itemsView addSubview:btn];
    
    CGSize s = [self autoHeightOfLabel:btn.titleLabel with:ScreenWidth - 160 - 30 - 10 setH:1];
    
    s.height = s.height + 10;
    s.width = s.width + 10;
    CGRect btnF = btn.frame;
    btnF.size.width = s.width + 10;
    
    if(itemF.origin.x > 15 && (itemF.size.width - btnF.size.width < 20)){
        itemF.origin.y =  itemF.origin.y + 28 + 10;
        itemF.origin.x = 15;
    }
    
    itemF.size.width = btnF.size.width;
    [btn setFrame:itemF];
    
    return itemF;
}

- (UIImage*) createImageWithColor: (UIColor*) color
{
    CGRect rect=CGRectMake(0,0, 1, 1);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    UIImage *theImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return theImage;
}

-(void)onItemClick:(UIButton *)btn{
    
    ZCMultiwheelModel *pm = self.tempModel.richModel.multiModel;
    NSDictionary *detail = [pm.interfaceRetList objectAtIndex:btn.tag];
//    NSLog(@"%zd---%@\n%@\n%@",btn.tag,[pm getQuestion:detail],[pm getRequestText:detail],detail);
    
    if (pm.endFlag) {
        // 最后一轮会话，有外链，点击跳转外链
        if (![@"" isEqualToString: zcLibConvertToString(detail[@"anchor"])]) {
            // 点击超链跳转
            if (self.delegate && [self.delegate respondsToSelector:@selector(cellItemLinkClick:type:obj:)]) {
                [self.delegate cellItemLinkClick:nil type:ZCChatCellClickTypeOpenURL obj:zcLibConvertToString(detail[@"anchor"])];
            }
        }
        return;
    }
    
    if (_isHistoryMessages) {
        return;
    }
    
    
    NSString * title = btn.titleLabel.text;
    NSDictionary * dict = @{@"requestText":[pm getRequestText:detail],
                            @"question":[pm getQuestion:detail],
                            @"questionFlag":@"2",
                            @"title":title,@"ishotguide":@"0"
                            };
   
    if ([self getCurConfig].isArtificial) {
        dict = @{@"title":title ,@"ishotguide":@"0"};
    }
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(cellItemClick:type:obj:)]) {
        [self.delegate cellItemClick:nil type:ZCChatCellClickTypeCollectionSendMsg obj:dict];
    }
    
}


/**
 计算Label高度
 
 @param label 要计算的label，设置了值
 @param width label的最大宽度
 @param type 是否从新设置宽，1设置，0不设置
 */
- (CGSize)autoHeightOfLabel:(UILabel *)label with:(CGFloat )width setH:(int) type{
    //Calculate the expected size based on the font and linebreak mode of your label
    // FLT_MAX here simply means no constraint in height
    CGSize maximumLabelSize = CGSizeMake(width,28);
    
    CGSize expectedLabelSize = [label sizeThatFits:maximumLabelSize];
    
    //adjust the label the the new height.
    CGRect newFrame = label.frame;
    newFrame.size.width = expectedLabelSize.width;
    
    if (newFrame.size.width > width) {
        newFrame.size.width  = width;
    }
    label.frame = newFrame;
    [label updateConstraintsIfNeeded];
    return newFrame.size;
}

- (CGSize)autoHeightOfLabel:(UILabel *)label with:(CGFloat )width{
    //Calculate the expected size based on the font and linebreak mode of your label
    // FLT_MAX here simply means no constraint in height
    CGSize maximumLabelSize = CGSizeMake(width, FLT_MAX);
    
    CGSize expectedLabelSize = [label sizeThatFits:maximumLabelSize];
      CGRect newFrame = label.frame;
    //adjust the label the the new height.
    if (newFrame.size.width > width) {
        newFrame.size.width  = width;
    }
    newFrame.size.height = expectedLabelSize.height;
    label.frame = newFrame;
    [label updateConstraintsIfNeeded];
    
    return newFrame.size;
}


+(CGRect )createTypeItemView:(NSString *) text frame:(CGRect) itemF tag:(int) tag{
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    [btn setTitle:text forState:UIControlStateNormal];
    btn.tag = tag;
    [btn setContentHorizontalAlignment:UIControlContentHorizontalAlignmentCenter];
    [btn addTarget:self action:@selector(onItemClick:) forControlEvents:UIControlEventTouchUpInside];
    [btn.titleLabel setFont:ZCUIFont14];
    btn.layer.cornerRadius = 5.0f;
    btn.layer.borderColor = UIColor.lightGrayColor.CGColor;
    btn.layer.borderWidth = 1.0f;
    [btn setBackgroundColor:UIColor.lightGrayColor];
    btn.layer.masksToBounds = YES;
    [btn setFrame:itemF];

    
    CGSize s = [self autoHeightOfLabel:btn.titleLabel with:ScreenWidth - 160 - 30 - 10 setH:1];
    s.height = s.height + 10;
    s.width = s.width + 10;
    CGRect btnF = btn.frame;
    btnF.size.width = s.width + 10;
    if(itemF.origin.x > 15 && (itemF.size.width - btnF.size.width < 20)){
        itemF.origin.y =  itemF.origin.y + 28 + 10;
        itemF.origin.x = 15;
    }
    
    itemF.size.width = btnF.size.width;
    [btn setFrame:itemF];
    
    return itemF;
}


+(CGSize)autoHeightOfLabel:(UILabel *)label with:(CGFloat )width setH:(int) type{
    //Calculate the expected size based on the font and linebreak mode of your label
    // FLT_MAX here simply means no constraint in height
    CGSize maximumLabelSize = CGSizeMake(width,28);
    
    CGSize expectedLabelSize = [label sizeThatFits:maximumLabelSize];
    
    //adjust the label the the new height.
    CGRect newFrame = label.frame;
    newFrame.size.width = expectedLabelSize.width;
    if (newFrame.size.width > width) {
        newFrame.size.width  = width;
    }
    label.frame = newFrame;
    [label updateConstraintsIfNeeded];
    return newFrame.size;
}

+ (CGSize)autoHeightOfLabel:(UILabel *)label with:(CGFloat )width{
    //Calculate the expected size based on the font and linebreak mode of your label
    // FLT_MAX here simply means no constraint in height
    CGSize maximumLabelSize = CGSizeMake(width, FLT_MAX);
    
    CGSize expectedLabelSize = [label sizeThatFits:maximumLabelSize];
    CGRect newFrame = label.frame;
    //adjust the label the the new height.
    if (newFrame.size.width > width) {
        newFrame.size.width  = width;
    }
    newFrame.size.height = expectedLabelSize.height;
    label.frame = newFrame;
    [label updateConstraintsIfNeeded];
    
    return newFrame.size;
}

-(ZCLibConfig *)getCurConfig{
    return [[ZCPlatformTools sharedInstance] getPlatformInfo].config;
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
