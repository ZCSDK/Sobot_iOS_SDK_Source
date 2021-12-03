//
//  ZCGoodsCell.m
//  SobotKit
//
//  Created by zhangxy on 16/3/18.
//  Copyright © 2016年 zhichi. All rights reserved.
//

#import "ZCGoodsCell.h"

#import "ZCLibGlobalDefine.h"
#import "ZCUIColorsDefine.h"
#import "SobotXHImageViewer.h"
#import "SobotImageView.h"
#import "ZCStoreConfiguration.h"
#import "ZCUICore.h"
@implementation ZCGoodsCell{
    
    //
    UIView *_bgView;
    
    //
    UIView *_cellBgView;
    
    // 商品图片
    SobotImageView   *_imgPhoto;
    
    // 标题
    UILabel         *_lblTextTitle;
    
    // 发送
    UIButton        *_btnSendMsg;
    
    // 摘要
    UILabel         *_lblTextDet;
    
    // 标签
    UILabel         *_lblTextTip;
    
    // 发送
    UIButton        *_bgbtn;
    
}

typedef NS_ENUM(NSInteger,ZCGoodsCellType){
    ZCGoodsCellType_pic_twoText     = 1,
    ZCGoodsCellType_pic_oneText  = 2,
    ZCGoodsCellType_oneText  = 3,
    ZCGoodsCellType_twoText  = 4,
    
};

- (void)awakeFromNib {
    // Initialization code
    [super awakeFromNib];
}


-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self=[super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if(self){
        
        _bgView = [[UIView alloc]init];
        _bgView.backgroundColor = UIColorFromThemeColor(ZCBgLeftChatColor);
        _bgView.layer.cornerRadius = 15;
        _bgView.layer.masksToBounds = YES;
        [self.contentView addSubview:_bgView];
        
        _cellBgView = [[UIView alloc]init];
//        _cellBgView.backgroundColor = [UIColor whiteColor];
        _cellBgView.backgroundColor = UIColorFromThemeColor(ZCBgSystemWhiteThirdGrayColor);
        
        [self.contentView addSubview:_cellBgView];
        
        _imgPhoto = [[SobotImageView alloc] init];
        [_imgPhoto setBackgroundColor:[UIColor clearColor]];
        [_imgPhoto setContentMode:UIViewContentModeScaleAspectFill];
        _imgPhoto.layer.cornerRadius = 5;
        _imgPhoto.layer.masksToBounds = YES;
        
        [self.contentView addSubview:_imgPhoto];
        
        
        // title
        _lblTextTitle = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
        [_lblTextTitle setTextAlignment:NSTextAlignmentLeft];
        [_lblTextTitle setFont:[ZCUITools zcgetTitleGoodsFont]];
        [_lblTextTitle setTextColor:[ZCUITools zcgetGoodsTextColor]]; // 0x515a7c
        [_lblTextTitle setBackgroundColor:[UIColor clearColor]];
        _lblTextTitle.numberOfLines = 1;
        //        _lblTextTitle.lineBreakMode = NSLineBreakByTruncatingTail;
        [self.contentView addSubview:_lblTextTitle];
        
        // 摘要
        _lblTextDet = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 0, 0)];
        [_lblTextDet setTextAlignment:NSTextAlignmentLeft];
        [_lblTextDet setFont:[ZCUITools zcgetGoodsDetFont]];
        [_lblTextDet setTextColor:[ZCUITools zcgetGoodsDetColor]]; // 0xacb5c4 [ZCUITools zcgetGoodsDetFont]
        [_lblTextDet setBackgroundColor:[UIColor clearColor]];
        _lblTextDet.numberOfLines = 1;
        //        _lblTextDet.lineBreakMode = NSLineBreakByTruncatingTail|NSLineBreakByClipping;
        [self.contentView addSubview:_lblTextDet];
        
        
        // 标签
        _lblTextTip = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 0, 0)];
        [_lblTextTip setTextAlignment:NSTextAlignmentLeft];
        [_lblTextTip setFont:ZCUIFontBold14];
        [_lblTextTip setBackgroundColor:[UIColor clearColor]];
        [_lblTextTip setTextColor:[ZCUITools zcgetGoodsTipColor]]; // 0x2fb9c3
        _lblTextTip.numberOfLines = 1;
        //        _lblTextTip.lineBreakMode = NSLineBreakByTruncatingTail|NSLineBreakByClipping;
        [self.contentView addSubview:_lblTextTip];
        
        
        _bgbtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_bgbtn addTarget:self action:@selector(bgbtnClick) forControlEvents:UIControlEventTouchUpInside];
        [_bgbtn setUserInteractionEnabled:YES];
        _bgbtn.backgroundColor = [UIColor clearColor];
        [self.contentView addSubview:_bgbtn];
        
        // 发送
        _btnSendMsg = [UIButton buttonWithType:UIButtonTypeCustom];
        //        [_btnSendMsg setBackgroundColor:[UIColor clearColor]];
        [_btnSendMsg setTitle:ZCSTLocalString(@"发给客服") forState:UIControlStateNormal];
        [_btnSendMsg setTitleColor:[ZCUITools zcgetGoodsSendColor] forState:UIControlStateNormal];
        
        _btnSendMsg.titleLabel.font = ZCUIFontBold14;
        [_btnSendMsg setBackgroundColor:[ZCUITools zcgetGoodSendBtnColor]];
        //        [_btnSendMsg setFrame:CGRectMake(0, 0,70, 26)];
        [_btnSendMsg setUserInteractionEnabled:YES];
        [_btnSendMsg addTarget:self action:@selector(sendMessageToUser) forControlEvents:UIControlEventTouchUpInside];
        _btnSendMsg.layer.cornerRadius = 15;
        _btnSendMsg.layer.masksToBounds = YES;
        
        [self.contentView addSubview:_btnSendMsg];
        
        [self.contentView setBackgroundColor:[UIColor clearColor]];
        
//        UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapAction:)];
////        tap.allowedTouchTypes =
//        [self.contentView addGestureRecognizer:tap];
        


        
//        self.userInteractionEnabled = YES;
//        self.contentView.userInteractionEnabled = YES;
//        _imgPhoto.userInteractionEnabled = YES;
//        _lblTextTip.userInteractionEnabled = YES;
//        _lblTextTitle.userInteractionEnabled = YES;
//        [_imgPhoto addGestureRecognizer:tap];
//        [_lblTextTitle addGestureRecognizer:tap];
//        [_lblTextTip addGestureRecognizer:tap];
        
    }
    return self;
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


-(void)tapAction:(UITapGestureRecognizer*)sender{
    if ([@"" isEqualToString:zcLibConvertToString([self getZCproductInfo].link)]) {
        return;
    }
    if (zcLibConvertToString([self getZCproductInfo].link).length == 0) {
        return;
    }
    if(self.delegate && [self.delegate respondsToSelector:@selector(cellItemLinkClick:type:obj:)]){
        [self.delegate cellItemLinkClick:@"" type:ZCChatCellClickTypeOpenURL obj:[self getZCproductInfo].link];
    }
}

- (ZCProductInfo *)getZCproductInfo{
    ZCProductInfo * productInfo = [ZCUICore getUICore].kitInfo.productInfo;
    //    productInfo.desc = @"";
    return productInfo;
}


// 2.7.5版本开始 高度固定 图片固定 标题两行 摘要不显示
-(CGFloat) InitDataToView:(ZCLibMessage *) model time:(NSString *) showTime{
    [self resetCellView];
    
    // 时间
    CGFloat cellHeight = 22;
    if(![@"" isEqual:zcLibConvertToString(showTime)]){
        [self.lblTime setText:showTime];
        [self.lblTime setFrame:CGRectMake(0, 0, self.viewWidth, 30)];
        self.lblTime.hidden=NO;
        cellHeight = cellHeight + 30 ;
    }
    
    // 图片隐藏
    //    _imgPhoto.hidden = YES;
    //    _lblTextDet.hidden = YES;
    //    _lblTextTip.hidden = YES;
    
    self.maxWidth = self.viewWidth - 20 -28;
    
    float gap = 15;
    
    
    ZCGoodsCellType currentCellType;
    BOOL hasPic = [self getZCproductInfo].thumbUrl!=nil  && ![@"" isEqualToString:zcLibConvertToString([self getZCproductInfo].thumbUrl)];
//    NSLog(@"lblTextDet002...%@",zcLibConvertToString([self getZCproductInfo].desc));
    
    BOOL hasDesc = zcLibConvertToString([self getZCproductInfo].desc)!=nil && ![@"" isEqualToString:zcLibConvertToString([self getZCproductInfo].desc)];
    //    BOOL hasLabel = zcLibConvertToString([self getZCproductInfo].label)!=nil && ![@"" isEqualToString:[self getZCproductInfo].label];
    
    
    if (hasPic && hasDesc) {
        currentCellType = ZCGoodsCellType_pic_twoText;
    }
    else if (hasPic && !hasDesc) {
        currentCellType = ZCGoodsCellType_pic_oneText;
    }
    else if (!hasPic && !hasDesc) {
        currentCellType = ZCGoodsCellType_oneText;
    }
    else {
        currentCellType = ZCGoodsCellType_twoText;
    }
    
    
    switch (currentCellType) {
        case ZCGoodsCellType_pic_twoText:
        {
            float bgViewHeight = 158;
            
            _bgView.frame = CGRectMake(gap, 10, self.viewWidth - gap*2, bgViewHeight);
            _cellBgView.frame = CGRectMake(gap*2, gap + 10, self.viewWidth - gap*4, 128);
            
            //           标题
            _lblTextTitle.frame = CGRectMake(gap*3, gap + 10 + 10, self.viewWidth - gap*3*2, 20);
            _lblTextTitle.text = zcLibConvertToString([self getZCproductInfo].title);
            
            float h = CGRectGetMaxY(_lblTextTitle.frame) + 10;
            if (_lblTextTitle.text.length == 0) {
                h = gap + 35;
            }
            
            //            图片
            CGSize imgPhotoSize = CGSizeMake(72, 72);
            _imgPhoto.hidden = NO;
            _imgPhoto.frame = CGRectMake(gap*3, h, imgPhotoSize.width, imgPhotoSize.height);
            [_imgPhoto loadWithURL:[NSURL URLWithString:[self getZCproductInfo].thumbUrl] placeholer:[ZCUITools zcuiGetBundleImage:@"zcicon_default_goods"]  showActivityIndicatorView:YES];
            
            //            des
            _lblTextDet.hidden = NO;
            _lblTextDet.frame = CGRectMake(CGRectGetMaxX(_imgPhoto.frame) + gap, h, self.viewWidth - gap*3*2 - imgPhotoSize.width - gap*2, 20);
//            NSLog(@"lblTextDet002...%@",zcLibConvertToString([self getZCproductInfo].desc));
            _lblTextDet.text = zcLibConvertToString([self getZCproductInfo].desc);
            _lblTextDet.backgroundColor = [UIColor clearColor];
            
            CGSize btnSendMsgSize = CGSizeMake(90, 30);
            //            label
            _lblTextTip.hidden = NO;
            _lblTextTip.frame = CGRectMake(CGRectGetMaxX(_imgPhoto.frame) + gap, CGRectGetMaxY(_lblTextDet.frame) + gap, self.viewWidth - gap*3*2 - 72 - gap*2 - btnSendMsgSize.width, 20);
            _lblTextTip.text = zcLibConvertToString([self getZCproductInfo].label);
            
            //            发送按钮
            
            _btnSendMsg.frame = CGRectMake(self.viewWidth - btnSendMsgSize.width - gap*3, CGRectGetMaxY(_lblTextDet.frame) + gap + 3, btnSendMsgSize.width, btnSendMsgSize.height);
            
            cellHeight = cellHeight + bgViewHeight;
            
        }
            break;
        case ZCGoodsCellType_pic_oneText:
        {
            float bgViewHeight = 158;
            
            _bgView.frame = CGRectMake(gap, 10, self.viewWidth - gap*2, bgViewHeight);
            _cellBgView.frame = CGRectMake(gap*2, gap + 10, self.viewWidth - gap*4, 128);
            
            //           标题
            _lblTextTitle.frame = CGRectMake(gap*3, gap + 10 + 10, self.viewWidth - gap*3*2, 20);
            _lblTextTitle.text = zcLibConvertToString([self getZCproductInfo].title);
            
            //            图片
            CGSize imgPhotoSize = CGSizeMake(72, 72);
            _imgPhoto.hidden = NO;
            _imgPhoto.frame = CGRectMake(gap*3, CGRectGetMaxY(_lblTextTitle.frame) + 10, imgPhotoSize.width, imgPhotoSize.height);
            [_imgPhoto loadWithURL:[NSURL URLWithString:[self getZCproductInfo].thumbUrl] placeholer:[ZCUITools zcuiGetBundleImage:@"zcicon_default_bg"]  showActivityIndicatorView:YES];
            
            //            des
            //            _lblTextDet.hidden = NO;
            //            _lblTextDet.frame = CGRectMake(CGRectGetMaxX(_imgPhoto.frame) + gap, CGRectGetMaxY(_lblTextTitle.frame) + gap, self.viewWidth - gap*3*2 - imgPhotoSize.width - gap*2, 20);
            //            NSLog(@"lblTextDet002...%@",zcLibConvertToString([self getZCproductInfo].desc));
            //            _lblTextDet.text = zcLibConvertToString([self getZCproductInfo].desc);
            //            _lblTextDet.backgroundColor = [UIColor redColor];
            //
            CGSize btnSendMsgSize = CGSizeMake(90, 30);
            //            label
            _lblTextTip.hidden = NO;
            _lblTextTip.frame = CGRectMake(CGRectGetMaxX(_imgPhoto.frame) + gap, CGRectGetMaxY(_lblTextTitle.frame) + gap*2, self.viewWidth - gap*3*2 - 72 - gap*2 - btnSendMsgSize.width, 20);
            _lblTextTip.text = zcLibConvertToString([self getZCproductInfo].label);
            
            //            发送按钮
            
            _btnSendMsg.frame = CGRectMake(self.viewWidth - btnSendMsgSize.width - gap*3, CGRectGetMaxY(_lblTextTip.frame) , btnSendMsgSize.width, btnSendMsgSize.height);
            
            cellHeight = cellHeight + bgViewHeight;
        }
            break;
        case ZCGoodsCellType_oneText:
        {
            float bgViewHeight = 126;
            
            _bgView.frame = CGRectMake(gap, 10, self.viewWidth - gap*2, bgViewHeight);
            _cellBgView.frame = CGRectMake(gap*2, gap + 10, self.viewWidth - gap*4, bgViewHeight - gap*2);
            
            //           标题
            _lblTextTitle.frame = CGRectMake(gap*3, gap + 10 + 10, self.viewWidth - gap*3*2, 20);
            _lblTextTitle.text = zcLibConvertToString([self getZCproductInfo].title);
            
            //            图片
            //            CGSize imgPhotoSize = CGSizeMake(72, 72);
            //            _imgPhoto.hidden = NO;
            //            _imgPhoto.frame = CGRectMake(gap*3, CGRectGetMaxY(_lblTextTitle.frame) + 10, imgPhotoSize.width, imgPhotoSize.height);
            //            [_imgPhoto loadWithURL:[NSURL URLWithString:[self getZCproductInfo].thumbUrl] placeholer:[ZCUITools zcuiGetBundleImage:@"zcicon_default_goods"]  showActivityIndicatorView:YES];
            
            //            des
            //            _lblTextDet.hidden = NO;
            //            _lblTextDet.frame = CGRectMake(CGRectGetMaxX(_imgPhoto.frame) + gap, CGRectGetMaxY(_lblTextTitle.frame) + gap, self.viewWidth - gap*3*2 - imgPhotoSize.width - gap*2, 20);
            //            NSLog(@"lblTextDet002...%@",zcLibConvertToString([self getZCproductInfo].desc));
            //            _lblTextDet.text = zcLibConvertToString([self getZCproductInfo].desc);
            //            _lblTextDet.backgroundColor = [UIColor redColor];
            
            CGSize btnSendMsgSize = CGSizeMake(90, 30);
            //            label
            _lblTextTip.hidden = NO;
            _lblTextTip.frame = CGRectMake(gap*3, CGRectGetMaxY(_lblTextTitle.frame) + 20, self.viewWidth - gap*3*2 - gap*2 - btnSendMsgSize.width, 20);
            _lblTextTip.text = zcLibConvertToString([self getZCproductInfo].label);
            
            //            发送按钮
            
            _btnSendMsg.frame = CGRectMake(self.viewWidth - btnSendMsgSize.width - gap*3, CGRectGetMaxY(_lblTextTitle.frame) + gap + 3, btnSendMsgSize.width, btnSendMsgSize.height);
            
            cellHeight = cellHeight + bgViewHeight;
        }
            break;
        case ZCGoodsCellType_twoText:
        {
            float bgViewHeight = 148;
            
            _bgView.frame = CGRectMake(gap, 10, self.viewWidth - gap*2, bgViewHeight);
            _cellBgView.frame = CGRectMake(gap*2, gap + 10, self.viewWidth - gap*4, bgViewHeight - gap*2);
            
            //           标题
            _lblTextTitle.frame = CGRectMake(gap*3, gap + 20, self.viewWidth - gap*3*2, 20);
            _lblTextTitle.text = zcLibConvertToString([self getZCproductInfo].title);
            
            //            图片
            //            CGSize imgPhotoSize = CGSizeMake(72, 72);
            //            _imgPhoto.hidden = NO;
            //            _imgPhoto.frame = CGRectMake(gap*3, CGRectGetMaxY(_lblTextTitle.frame) + 10, imgPhotoSize.width, imgPhotoSize.height);
            //            [_imgPhoto loadWithURL:[NSURL URLWithString:[self getZCproductInfo].thumbUrl] placeholer:[ZCUITools zcuiGetBundleImage:@"zcicon_default_goods"]  showActivityIndicatorView:YES];
            
            //            des
            _lblTextDet.hidden = NO;
            _lblTextDet.frame = CGRectMake(gap*3, CGRectGetMaxY(_lblTextTitle.frame) + 2, self.viewWidth - gap*3*2 - gap*2, 20);
//            NSLog(@"lblTextDet002...%@",zcLibConvertToString([self getZCproductInfo].desc));
            _lblTextDet.text = zcLibConvertToString([self getZCproductInfo].desc);
            _lblTextDet.backgroundColor = [UIColor clearColor];
            
            CGSize btnSendMsgSize = CGSizeMake(90, 30);
            //            label
            _lblTextTip.hidden = NO;
            _lblTextTip.frame = CGRectMake(gap*3, CGRectGetMaxY(_lblTextDet.frame) + 20, self.viewWidth - gap*3*2 - gap*2 - btnSendMsgSize.width, 20);
            _lblTextTip.text = zcLibConvertToString([self getZCproductInfo].label);
            
            //            发送按钮
            
            _btnSendMsg.frame = CGRectMake(self.viewWidth - btnSendMsgSize.width - gap*3, CGRectGetMaxY(_lblTextDet.frame) + gap + 3, btnSendMsgSize.width, btnSendMsgSize.height);
            
            cellHeight = cellHeight + bgViewHeight;
        }
            break;
        default:
            break;
    }
    
    
    //    CGFloat textX = 10;
    
    //    if([self getZCproductInfo].thumbUrl!=nil  && ![@"" isEqualToString:[self getZCproductInfo].thumbUrl]){
    //        [_imgPhoto setFrame:CGRectMake(10+14, cellHeight, 80, 80)];
    //
    //        [_imgPhoto loadWithURL:[NSURL URLWithString:[self getZCproductInfo].thumbUrl] placeholer:[ZCUITools zcuiGetBundleImage:@"zcicon_default_goods"]  showActivityIndicatorView:YES];
    //        _imgPhoto.hidden = NO;
    //        self.maxWidth = self.viewWidth - 113 - 28;
    //        textX = 103+ 14;
    //
    //    }
    
    // 有图片
    //    [_lblTextTitle setFrame:CGRectMake(textX, cellHeight, self.maxWidth, 40)];
    //
    //    _lblTextTitle.text = zcLibConvertToString([self getZCproductInfo].title);
    //    [_lblTextTitle sizeToFit];
    
    
    // 获取 添加标题之后的商品cell
    //    cellHeight = CGRectGetMaxY(_lblTextTitle.frame) + 10 ;
    
    // 摘要  2.7.5 去掉此项
    //    if (zcLibConvertToString([self getZCproductInfo].desc)!=nil && ![@"" isEqualToString:[self getZCproductInfo].desc]) {
    //         [_lblTextDet setFrame:CGRectMake(textX, cellHeight , self.maxWidth, 0)];
    //        _lblTextDet.hidden = NO;
    //
    //        _lblTextDet.text = zcLibConvertToString([self getZCproductInfo].desc);
    //        // 获取摘要的内容大小
    //        CGRect textDetF = _lblTextDet.frame;
    //        if (zcLibConvertToString([self getZCproductInfo].label)!=nil && ![@"" isEqualToString:[self getZCproductInfo].label]) {
    //            textDetF.size.height = 44;
    //            textDetF.origin.y = cellHeight - 10;
    //
    //            cellHeight = CGRectGetMaxY(textDetF);
    //        }else{
    //            CGSize size = [_lblTextDet.text boundingRectWithSize:CGSizeMake(_lblTextDet.frame.size.width, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:[ZCUITools zcgetTitleFont]} context:nil].size;
    //            textDetF.origin.y = cellHeight;
    //            textDetF.size.height = size.height;
    //
    //            cellHeight = CGRectGetMaxY(textDetF) + 10;
    //        }
    //        _lblTextDet.frame = textDetF;
    //
    //    }
    //
    //    // 标签
    //    if (zcLibConvertToString([self getZCproductInfo].label)!=nil && ![@"" isEqualToString:[self getZCproductInfo].label]) {
    //        [_lblTextTip setFrame:CGRectMake(textX, cellHeight, ZCNumber(150), 18)];
    //        _lblTextTip.hidden = NO;
    //
    //        _lblTextTip.text = zcLibConvertToString([self getZCproductInfo].label);
    //        cellHeight = CGRectGetMaxY(_lblTextTip.frame) +15;
    //    }
    //
    //
    //    // 发送按钮（计算发送按钮的在这8中商品展示的位置）
    //    CGRect bf = _btnSendMsg.frame;
    //    bf.origin.x = self.viewWidth - _btnSendMsg.frame.size.width -10-14;
    ////    if(textX>10 && ((BY + 90)- cellHeight) > 31){
    ////        bf.origin.y = BY + 90 - 26;
    ////    }else{
    //
    //        bf.origin.y = 100-26;
    ////    }
    //    [_btnSendMsg setFrame:bf];
    //
    //    cellHeight = CGRectGetMaxY(_btnSendMsg.frame) +12;
    
    // 时间的显示这里需要在处理一下
    //    if (!self.lblTime.hidden) {
    //        [self.ivBgView setFrame:CGRectMake(14, 40, self.viewWidth-28, cellHeight - 40)];
    //    }else{
    //        [self.ivBgView setFrame:CGRectMake(14, 10, self.viewWidth-28, cellHeight - 10)];
    //    }
    //    [self.ivBgView setBackgroundColor:[UIColor whiteColor]];
    
    // 12为增加的间隙(气泡和整个frame)
    self.frame = CGRectMake(0, 0, self.viewWidth, cellHeight +12);
    
    _bgbtn.frame = self.frame;
//    if (self.isRight) {
//        [_bgView setBackgroundColor:[ZCUITools zcgetRightChatColor]];
//    }else{
//        [_bgView setBackgroundColor:[ZCUITools zcgetLeftChatColor]];
//    }
    return cellHeight;
}

- (void)sendMessageToUser{
    if (self.delegate && [self.delegate respondsToSelector:@selector(cellItemClick:type:obj:)]) {
        [self.delegate cellItemClick:nil type:ZCChatCellClickTypeSendGoosText obj:[self getZCproductInfo]];
    }
}

-(void)resetCellView{
    [super resetCellView];
    
    [self.lblNickName setText:@""];
}

- (void)bgbtnClick{
    
    if(self.delegate && [self.delegate respondsToSelector:@selector(cellItemLinkClick:type:obj:)]){
        [self.delegate cellItemLinkClick:@"" type:ZCChatCellClickTypeOpenURL obj:[self getZCproductInfo].link];
    }
}


+(CGFloat)getCellHeight:(ZCLibMessage *)model time:(NSString *)showTime viewWith:(CGFloat)width{
    CGFloat cellHeight = 12;
    if(![@"" isEqual:zcLibConvertToString(showTime)]){
        cellHeight = cellHeight + 30;
    }
    
    ZCGoodsCellType currentCellType;
    ZCGoodsCell *cell = [[ZCGoodsCell alloc]init];
    BOOL hasPic = [cell getZCproductInfo].thumbUrl!=nil  && ![@"" isEqualToString:[cell getZCproductInfo].thumbUrl];
//    NSLog(@"lblTextDet002...%@",zcLibConvertToString([cell getZCproductInfo].desc));
    
    BOOL hasDesc = zcLibConvertToString([cell getZCproductInfo].desc)!=nil && ![@"" isEqualToString:[cell getZCproductInfo].desc];
    //    BOOL hasLabel = zcLibConvertToString([self getZCproductInfo].label)!=nil && ![@"" isEqualToString:[self getZCproductInfo].label];
    
    float bgViewHeight = 0;
    
    if (hasPic && hasDesc) {
        currentCellType = ZCGoodsCellType_pic_twoText;
        bgViewHeight = 158;
    }
    else if (hasPic && !hasDesc) {
        currentCellType = ZCGoodsCellType_pic_oneText;
        bgViewHeight = 158;
        
    }
    else if (!hasPic && !hasDesc) {
        currentCellType = ZCGoodsCellType_oneText;
        bgViewHeight = 128;
        
    }
    else {
        currentCellType = ZCGoodsCellType_twoText;
        bgViewHeight = 146;
        
    }
    
    return bgViewHeight + cellHeight + 10;
}


- (CGSize)sizeThatFits:(CGSize)size {
    
    CGSize rSize = [super sizeThatFits:size];
    rSize.height +=1;
    return rSize;
}


@end
