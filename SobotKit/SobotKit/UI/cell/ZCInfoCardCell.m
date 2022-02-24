//
//  ZCInfoCardCell.m
//  SobotKit
//
//  Created by lizhihui on 2019/4/24.
//  Copyright © 2019 zhichi. All rights reserved.
//

#import "ZCInfoCardCell.h"
#import "ZCLibGlobalDefine.h"
#import "ZCUIColorsDefine.h"
#import "SobotXHImageViewer.h"
#import "SobotImageView.h"
#import "ZCStoreConfiguration.h"
#import "ZCUICore.h"

@interface ZCInfoCardCell(){
    ZCLibMessage * tempModel;// 临时存储
}
typedef NS_ENUM(NSInteger,ZCGoodsCellType){
    ZCGoodsCellType_pic_twoText     = 1,
    ZCGoodsCellType_pic_oneText  = 2,
    ZCGoodsCellType_oneText  = 3,
    ZCGoodsCellType_twoText  = 4,
    
};
//@property (nonatomic,strong) UIView *cellBgView;

@property (nonatomic,strong) SobotImageView   *imgPhoto;

@property (nonatomic,strong) UILabel * lblTextTitle;

@property (nonatomic,strong) UILabel * lblTextDet;

@property (nonatomic,strong) UILabel * lblTextTip;

@property (nonatomic,strong) UIButton * btnSendMsg;

@end




@implementation ZCInfoCardCell

//-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
//    self=[super initWithStyle:style reuseIdentifier:reuseIdentifier];
//    if(self){
//        UITapGestureRecognizer *tapG = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tap)];
//        tapG.delegate = self;
//        [self.ivBgView addGestureRecognizer:tapG];
//    }
//    return self;
//}
-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self=[super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if(self){
        //        UITapGestureRecognizer *tapG = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(sendMessageToUser)];
        //        tapG.delegate = self;
        self.ivBgView.userInteractionEnabled = YES;
        //        [self.ivBgView addGestureRecognizer:tapG];
        
//        _cellBgView = [[UIView alloc]init];

//        [self.contentView addSubview:_cellBgView];
        
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
        [_lblTextTitle setTextColor:[ZCUITools zcgetGoodsTextColor]];
        [_lblTextTitle setBackgroundColor:[UIColor clearColor]];
        _lblTextTitle.numberOfLines = 1;
        //        _lblTextTitle.lineBreakMode = NSLineBreakByTruncatingTail;
        [self.contentView addSubview:_lblTextTitle];
        
        // 摘要
        _lblTextDet = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 0, 0)];
        [_lblTextDet setTextAlignment:NSTextAlignmentLeft];
        [_lblTextDet setFont:[ZCUITools zcgetGoodsDetFont]];
        [_lblTextDet setTextColor:[ZCUITools zcgetGoodsDetColor]];
        [_lblTextDet setBackgroundColor:[UIColor clearColor]];
        _lblTextDet.numberOfLines = 1;
        //        _lblTextDet.lineBreakMode = NSLineBreakByTruncatingTail|NSLineBreakByClipping;
        [self.contentView addSubview:_lblTextDet];
        
        
        // 标签
        _lblTextTip = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 0, 0)];
        [_lblTextTip setTextAlignment:NSTextAlignmentLeft];
        [_lblTextTip setFont:ZCUIFontBold14];
        [_lblTextTip setBackgroundColor:[UIColor clearColor]];
        [_lblTextTip setTextColor:[ZCUITools zcgetGoodsTipColor]];
        _lblTextTip.numberOfLines = 1;
        //        _lblTextTip.lineBreakMode = NSLineBreakByTruncatingTail|NSLineBreakByClipping;
        [self.contentView addSubview:_lblTextTip];
        
        
        [self.contentView setBackgroundColor:[UIColor clearColor]];
        
        //        self.contentView.userInteractionEnabled = YES;
        //        self.userInteractionEnabled = YES;
        //        self.imgPhoto.userInteractionEnabled = YES;
        //        self.titleLab.userInteractionEnabled = YES;
        //        self.tipLab.userInteractionEnabled = YES;
        //        [self.imgPhoto addGestureRecognizer:tapG];
        //        [self.titleLab addGestureRecognizer:tapG];
        //        [self.tipLab addGestureRecognizer:tapG];
        
        
//        _btnSendMsg = [UIButton buttonWithType:UIButtonTypeCustom];
//        _btnSendMsg.backgroundColor = [UIColor clearColor];
//        [_btnSendMsg addTarget:self action:@selector(sendMessageToUser) forControlEvents:UIControlEventTouchUpInside];
//        [self.contentView addSubview:_btnSendMsg];
        
        //设置点击事件
        UITapGestureRecognizer *tapGesturer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(sendMessageToUser)];
        self.ivBgView.userInteractionEnabled=YES;
        [self.ivBgView addGestureRecognizer:tapGesturer];
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




- (ZCProductInfo *)getZCproductInfoWith:(ZCLibMessage *)model {
    ZCProductInfo * productInfo = nil;
    if(model.richModel.msg!=nil){
        @try {
            NSError * err;
            NSDictionary *dict=[NSJSONSerialization JSONObjectWithData:[sobotConvertToString(model.richModel.msg) dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableLeaves error:&err];
            if (!err) {
                productInfo = [ZCProductInfo new];
                productInfo.thumbUrl = sobotConvertToString(dict[@"thumbnail"]);
                productInfo.title = sobotConvertToString(dict[@"title"]);
                productInfo.desc = sobotConvertToString(dict[@"description"]);
                productInfo.label = sobotConvertToString(dict[@"label"]);
                productInfo.link = sobotConvertToString(dict[@"link"]);
                if (!productInfo.link.length){
                    productInfo.link = sobotConvertToString(dict[@"url"]);
                }
            }else{
                productInfo = [ZCUICore getUICore].kitInfo.productInfo;
            }
            
        } @catch (NSException *exception) {
            productInfo = [ZCUICore getUICore].kitInfo.productInfo;
        } @finally {
            
        }
        
    }
    
    
    //    productInfo.desc = @"";
    return productInfo;
}

- (ZCProductInfo *)getZCproductInfo{
    return [self getZCproductInfoWith:self.tempModel];
}

-(CGFloat) InitDataToView:(ZCLibMessage *) model time:(NSString *) showTime{
    CGFloat cellHeight = [super InitDataToView:model time:showTime];
    
    [_lblTextDet setText:@""];
    [_lblTextTip setText:@""];
    [_lblTextTitle setText:@""];
    [_imgPhoto setImage:[ZCUITools zcuiGetBundleImage:@"zcicon_default_goods"]];
    
    tempModel = model;
    
    for (UIView *v in self.ivBgView.subviews) {
        [v removeFromSuperview];
    }
    
    float gap = 10;
    
    //    标题
    NSString *titleStr;
    if (model.miniPageDic && model.isHistory) {
        titleStr = sobotConvertToString(model.miniPageDic[@"title"]);
    }else{
        titleStr = sobotConvertToString([self getZCproductInfo].title);
    }
    
    //    pic
    NSURL *picUrl = [NSURL URLWithString:@""];
    if (model.miniPageDic && model.isHistory) {
        picUrl = [NSURL URLWithString:sobotConvertToString(model.miniPageDic[@"thumbnail"])];
    }else{
        picUrl = [NSURL URLWithString:sobotConvertToString([self getZCproductInfo].thumbUrl)];
    }
    
    //    des
    NSString *desStr = [NSString string];
    if (model.miniPageDic && model.isHistory) {
        desStr = sobotConvertToString(model.miniPageDic[@"description"]);
    }else{
        desStr = sobotConvertToString([self getZCproductInfo].desc);
    }
    
    
    NSString *labelStr = [NSString string];
    if (model.miniPageDic && model.isHistory) {
        labelStr = sobotConvertToString(model.miniPageDic[@"label"]);
    }else{
        labelStr = sobotConvertToString([self getZCproductInfo].label);
    }
    
    ZCGoodsCellType currentCellType;
    BOOL hasPic = sobotConvertToString(picUrl)!=nil  && ![@"" isEqualToString:sobotConvertToString(picUrl)];
    
    BOOL hasDesc = sobotConvertToString(desStr)!=nil && ![@"" isEqualToString:sobotConvertToString(desStr)];
    
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
    
    float bgWidth = 282;
    
    float bgX;
    if (self.isRight) {
        bgX = self.viewWidth - bgWidth - 15;
    }else{
        bgX = 15;
    }
    switch (currentCellType) {
        case ZCGoodsCellType_pic_twoText:
        {
            float bgViewHeight = 137;
            
            self.ivBgView.frame = CGRectMake(bgX, cellHeight , bgWidth, bgViewHeight - gap*2);
            
            
            //           标题
            _lblTextTitle.frame = CGRectMake(bgX + gap + 5, cellHeight + gap , bgWidth - gap*2, 20);
            _lblTextTitle.text = titleStr;
            
            float h =  CGRectGetMaxY(_lblTextTitle.frame) + 10;
            if (titleStr.length == 0) {
                h = cellHeight + 25;
            }
            
            //            图片
            CGSize imgPhotoSize = CGSizeMake(60, 60);
            _imgPhoto.hidden = NO;
            _imgPhoto.frame = CGRectMake(bgX + gap + 5, h, imgPhotoSize.width, imgPhotoSize.height);
            [_imgPhoto loadWithURL:picUrl placeholer:[ZCUITools zcuiGetBundleImage:@"zcicon_default_goods"]  showActivityIndicatorView:YES];
            
            //            des
            _lblTextDet.hidden = NO;
            _lblTextDet.frame = CGRectMake(CGRectGetMaxX(_imgPhoto.frame) + gap, h, bgWidth - gap*2 - imgPhotoSize.width - gap*2, 20);
            _lblTextDet.text = desStr;
            _lblTextDet.backgroundColor = [UIColor clearColor];
            
            //            label
            _lblTextTip.hidden = NO;
            _lblTextTip.frame = CGRectMake(CGRectGetMaxX(_imgPhoto.frame) + gap, h + gap*2 + 10, bgWidth - gap*2 - 72 - gap*2, 20);
            _lblTextTip.text = labelStr;
            
            cellHeight = cellHeight + bgViewHeight;
            
        }
            break;
        case ZCGoodsCellType_pic_oneText:
        {
            float bgViewHeight = 137;
            
            self.ivBgView.frame = CGRectMake(bgX, cellHeight , bgWidth, bgViewHeight - gap*2);
            
            //           标题
            _lblTextTitle.frame = CGRectMake(bgX + 15, cellHeight + gap , bgWidth - gap*2, 20);
            _lblTextTitle.text = titleStr;
            
            _lblTextDet.hidden = YES;
            //            图片
            CGSize imgPhotoSize = CGSizeMake(60, 60);
            _imgPhoto.hidden = NO;
            _imgPhoto.frame = CGRectMake(bgX + 15, CGRectGetMaxY(_lblTextTitle.frame) + 10, imgPhotoSize.width, imgPhotoSize.height);
            [_imgPhoto loadWithURL:picUrl placeholer:[ZCUITools zcuiGetBundleImage:@"zcicon_default_bg"]  showActivityIndicatorView:YES];
            //            label
            _lblTextTip.hidden = NO;
            _lblTextTip.frame = CGRectMake(CGRectGetMaxX(_imgPhoto.frame) + gap, CGRectGetMaxY(_lblTextTitle.frame) + gap*2, bgWidth - gap*2 - 72 - gap*2, 20);
            _lblTextTip.text = labelStr;
            
            cellHeight = cellHeight + bgViewHeight;
        }
            break;
        case ZCGoodsCellType_oneText:
        {
            float bgViewHeight = 96;
            
            self.ivBgView.frame = CGRectMake(bgX, cellHeight , bgWidth, bgViewHeight - gap*2);
            
            //           标题
            _lblTextTitle.frame = CGRectMake(bgX + gap*1.5, cellHeight + gap *1.2, bgWidth - gap*3, 20);
            _lblTextTitle.text = titleStr;
            
            _lblTextDet.hidden = YES;
            _imgPhoto.hidden = YES;

            //            label
            _lblTextTip.hidden = NO;
            _lblTextTip.frame = CGRectMake(bgX + gap*1.5, CGRectGetMaxY(_lblTextTitle.frame) + 12, bgWidth - gap*3 - gap*2, 20);
            _lblTextTip.text = labelStr;
            
            cellHeight = cellHeight + bgViewHeight;
        }
            break;
        case ZCGoodsCellType_twoText:
        {
            float bgViewHeight = 117;
            
            self.ivBgView.frame = CGRectMake(bgX, cellHeight , bgWidth, bgViewHeight - gap*2);
            
            //           标题
            _lblTextTitle.frame = CGRectMake(bgX + gap*1.5, cellHeight + gap, bgWidth - gap*2, 20);
            _lblTextTitle.text = titleStr;
            
            float h =  CGRectGetMaxY(_lblTextTitle.frame) + 2;
            if (titleStr.length == 0) {
                h = cellHeight + 15;
            }
            
            //            des
            _lblTextDet.hidden = NO;
            _lblTextDet.frame = CGRectMake(bgX + gap*1.5, h, bgWidth - gap*3 - gap*2, 20);
            _lblTextDet.text = desStr;
            _lblTextDet.backgroundColor = [UIColor clearColor];
            
            _imgPhoto.hidden = YES;

            //            label
            _lblTextTip.hidden = NO;
            _lblTextTip.frame = CGRectMake(bgX + gap*1.5, CGRectGetMaxY(_lblTextDet.frame) + gap, bgWidth - gap*3 - gap*2, 20);
            _lblTextTip.text = labelStr;
            
            cellHeight = cellHeight + bgViewHeight;
        }
            break;
        default:
            break;
    }
    
    // 0,自己，1机器人，2客服
    if(self.isRight){
        // 右边气泡背景图片
        UIImage * bgImage = [ZCUITools zcuiGetBundleImage:@"zcicon_pop_green_normal_line"];
        bgImage=[bgImage resizableImageWithCapInsets:UIEdgeInsetsMake(21, 21, 21, 21)];
        
        self.ivBgView.image = bgImage;
        self.ivBgView.backgroundColor = UIColorFromThemeColor(ZCBgSystemWhiteLightGrayColor);
        //设置尖角
        [self.ivLayerView setImage:bgImage];
    }else{
        self.ivBgView.image = nil;
        [self.ivBgView setBackgroundColor:[ZCUITools zcgetLeftChatColor]];
    }

    if([ZCUITools getZCThemeStyle] == ZCThemeStyle_Dark){
        self.ivBgView.backgroundColor = UIColorFromThemeColor(ZCBgSystemWhiteLightGrayColor);
    }
    self.ivBgView.contentMode = UIViewContentModeScaleToFill;

    // 设置尖角
   [self.ivLayerView setFrame:self.ivBgView.frame];
   CALayer *layer              = self.ivLayerView.layer;
   layer.frame                 = (CGRect){{0,0},self.ivLayerView.layer.frame.size};
   self.ivBgView.layer.mask = layer;

   [self.ivBgView setNeedsDisplay];
    
    self.frame = CGRectMake(0, 0, self.viewWidth, cellHeight + 5);
    
    return cellHeight + 5;
}



- (void)sendMessageToUser{
    if(self.delegate && [self.delegate respondsToSelector:@selector(cellItemLinkClick:type:obj:)]){
        
        NSString * link = @"";
        if (tempModel.miniPageDic && tempModel.isHistory) {
            link = sobotConvertToString(tempModel.miniPageDic[@"url"]);
        }else{
            link = sobotConvertToString([self getZCproductInfo].link);
        }
        [self.delegate cellItemLinkClick:@"" type:ZCChatCellClickTypeOpenURL obj:link];
    }
}

-(void)resetCellView{
    [super resetCellView];
    
    [self.lblNickName setText:@""];
}


+(CGFloat)getCellHeight:(ZCLibMessage *)model time:(NSString *)showTime viewWith:(CGFloat)width{
    CGFloat cellheith = [super getCellHeight:model time:showTime viewWith:width];
    //    标题
    NSString *titleStr;
    ZCInfoCardCell *cell = [[ZCInfoCardCell alloc]init];
    if (model.miniPageDic && model.isHistory) {
        titleStr = sobotConvertToString(model.miniPageDic[@"title"]);
    }else{
        titleStr = sobotConvertToString([cell getZCproductInfoWith:model].title);
    }
    
    //    pic
    NSURL *picUrl = [NSURL URLWithString:@""];
    if (model.miniPageDic && model.isHistory) {
        picUrl = [NSURL URLWithString:sobotConvertToString(model.miniPageDic[@"thumbnail"])];
    }else{
        picUrl = [NSURL URLWithString:sobotConvertToString([cell getZCproductInfoWith:model].thumbUrl)];
    }
    
    //    des
    NSString *desStr = [NSString string];
    if (model.miniPageDic && model.isHistory) {
        desStr = sobotConvertToString(model.miniPageDic[@"description"]);
    }else{
        desStr = sobotConvertToString([cell getZCproductInfoWith:model].desc);
    }

    //    label
    
//    NSString *labelStr = [NSString string];
//    if (model.miniPageDic && model.isHistory) {
//        labelStr = sobotConvertToString(model.miniPageDic[@"label"]);
//    }else{
//        labelStr = sobotConvertToString([cell getZCproductInfo].label);
//    }
    
    
    ZCGoodsCellType currentCellType;
    BOOL hasPic = sobotConvertToString(picUrl)!=nil  && ![@"" isEqualToString:sobotConvertToString(picUrl)];
    
    BOOL hasDesc = sobotConvertToString(desStr)!=nil && ![@"" isEqualToString:sobotConvertToString(desStr)];
    

    
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
    
    float bgHeight = 0;
    switch (currentCellType) {
        case ZCGoodsCellType_pic_twoText:
        {
            bgHeight = 137;
        }
            break;
        case ZCGoodsCellType_pic_oneText:
        {
            bgHeight = 137;
            
        }
            break;
        case ZCGoodsCellType_oneText:
        {
            bgHeight = 96;
            
        }
            break;
        case ZCGoodsCellType_twoText:
        {
            bgHeight = 117;
            
        }
            break;
        default:
            break;
    }
    
    return cellheith + bgHeight - 10;
}


- (CGSize)sizeThatFits:(CGSize)size {
    
    CGSize rSize = [super sizeThatFits:size];
    rSize.height +=1;
    return rSize;
}



- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

@end
