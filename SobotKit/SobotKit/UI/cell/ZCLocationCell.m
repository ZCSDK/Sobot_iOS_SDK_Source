//
//  ZCLocationCell.m
//  SobotKit
//
//  Created by zhangxy on 2018/11/30.
//  Copyright © 2018年 zhichi. All rights reserved.
//

#import "ZCLocationCell.h"
#import "ZCUIImageView.h"
#import "ZCLibGlobalDefine.h"
#import "ZCUIColorsDefine.h"

#define LocationHeight 135
@interface ZCLocationCell(){
    ZCUIImageView *_imgLocation;
    UILabel *_labFileName;
    UILabel *_labFileAddress;
    UIButton * cancelBtn;// 取消发送；
    ZCLibMessage *_model;
}

//@property (nonatomic,strong) UIView *cellBgView;
//@property (nonatomic,strong) UIButton * btnSendMsg;

@end

@implementation ZCLocationCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self=[super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if(self){
        
//        _cellBgView = [[UIView alloc]init];
//        [self.contentView addSubview:_cellBgView];

        
        _imgLocation = [[ZCUIImageView alloc] init];
        [_imgLocation setContentMode:UIViewContentModeScaleAspectFill];
        [_imgLocation.layer setMasksToBounds:YES];
        [_imgLocation setBackgroundColor:[UIColor whiteColor]];
        _imgLocation.clipsToBounds = YES;
        [self.contentView addSubview:_imgLocation];
        
        _labFileName=[[UILabel alloc] init];
        [_labFileName setTextAlignment:NSTextAlignmentLeft];
        [_labFileName setFont:ZCUIFontBold14];
        [_labFileName setTextColor:[ZCUITools zcgetGoodsTextColor]];
        [_labFileName setBackgroundColor:[UIColor clearColor]];
        [self.contentView addSubview:_labFileName];
        
        _labFileAddress=[[UILabel alloc] init];
        [_labFileAddress setTextAlignment:NSTextAlignmentLeft];
        _labFileAddress.numberOfLines = 0;
        [_labFileAddress setFont:ZCUIFont14];
        [_labFileAddress setTextColor:[ZCUITools zcgetGoodsTextColor]];
        [_labFileAddress setBackgroundColor:[UIColor clearColor]];
        [self.contentView addSubview:_labFileAddress];
        
        //设置点击事件
        UITapGestureRecognizer *tapGesturer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tap:)];
        self.ivBgView.userInteractionEnabled=YES;
        [self.ivBgView addGestureRecognizer:tapGesturer];
        
//        _btnSendMsg = [UIButton buttonWithType:UIButtonTypeCustom];
//        _btnSendMsg.backgroundColor = [UIColor clearColor];
//        [_btnSendMsg addTarget:self action:@selector(tap:) forControlEvents:UIControlEventTouchUpInside];
//        [self.contentView addSubview:_btnSendMsg];
        
        
    }
    return self;
}


-(CGFloat) InitDataToView:(ZCLibMessage *)model time:(NSString *)showTime{
    CGFloat height=[super InitDataToView:model time:showTime];
    _model = model;
    self.ivBgView.backgroundColor = UIColor.whiteColor;
    
    [_imgLocation loadWithURL:[NSURL URLWithString:zcUrlEncodedString(model.richModel.richmoreurl)] placeholer:nil showActivityIndicatorView:YES];
    [_labFileName setText:model.richModel.localName];
    [_labFileAddress setText:model.richModel.localLabel];
    if (model.isHistory) {
        model.progress = 1.0;
    }
    
    self.ivBgView.hidden = NO;
    
//  cell 最大宽度 240   文字最大宽度 240 - 30
    self.maxWidth = ZCNumber(240) - ZCNumber(30);

    CGSize size = CGSizeMake(self.maxWidth, LocationHeight);
    CGSize s = [_labFileAddress sizeThatFits:size];

    CGFloat msgX = 0;
    // 0,自己，1机器人，2客服
    if(self.isRight){
        int rx = self.viewWidth - self.maxWidth - ZCNumber(30) - ZCNumber(15);
        
        msgX = rx + 15;
        
        [_labFileName setFrame:CGRectMake(msgX, height + 10, size.width, 17)];
        [_labFileAddress setFrame:CGRectMake(msgX, height + 10 + 17 + 4, size.width, s.height)];
        [_imgLocation setFrame:CGRectMake(msgX, height + 10 + 17 + 4 + s.height + 12, size.width, ZCNumber(85))];
        
//        [self.ivBgView setFrame:CGRectMake(rx, height, size.width+ZCNumber(33) , 17 + s.height + ZCNumber(85) + 10 + 4+ 2 + 15)];
        
        [self.ivBgView setFrame:CGRectMake(rx, height, self.maxWidth + ZCNumber(30) , 17 + s.height + ZCNumber(85) + 10 + 4+ 12 + 15)];
    }else{
        msgX = 15 + 12;
        
        [_labFileName setFrame:CGRectMake(msgX, height + 10, size.width, 17)];
        [_labFileAddress setFrame:CGRectMake(msgX, height + 10 + 17 + 4, size.width, s.height)];
        [_imgLocation setFrame:CGRectMake(msgX, height + 10 + 17 + 4 + s.height + 12, size.width, ZCNumber(85))];
        
//        [self.ivBgView setFrame:CGRectMake(20, height, size.width+33, 17 + s.height + ZCNumber(85) + 10 + 4+ 2 + 15)];
        
         [self.ivBgView setFrame:CGRectMake(15, height, size.width+30, 17 + s.height + ZCNumber(85) + 10 + 4+ 12 + 15)];
    }
    
    
    height= height + size.height+22;

    
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
    
    
//        __weak __typeof(self) weakSelf = self;
//
//        [_cellBgView setInsideColor:[UIColor whiteColor]];
//        [_cellBgView updateCornerRadius:^(ZCCorner *corner) {
//            if (weakSelf.isRight) {
//                corner.radius = ZCRadiusMake(20,20,20,5);
//            }else{
//                corner.radius = ZCRadiusMake(20,20,5,20);
//            }
//            corner.borderColor = [ZCUITools zcgetRightChatColor];
//            corner.borderWidth = 1;
//        }];
//    //    _cellBgView.layer.masksToBounds = YES;
//        _btnSendMsg.frame = self.cellBgView.frame;
//        [_cellBgView setNeedsDisplay];

//
//    [self setFrame:CGRectMake(0, 0, self.viewWidth, height)];
//
//    //    NSLog(@"_progressView.progress ==++++++++%f",_progressView.progress);
//    if (self.isRight && model.progress < 1) {
//        CGSize size = CGSizeMake(self.maxWidth, 60);
//        int rx = self.viewWidth - size.width - 30 - 50 -18 -19;
//        cancelBtn.frame = CGRectMake(rx, CGRectGetMaxY(_labFileName.frame) -5, 19, 19);
//        cancelBtn.hidden = NO;
//    }else{
//        cancelBtn.hidden = YES;
//    }
    
    return height;
}





// 点击查看大图
-(void) tap:(UIButton *)recognizer{
//    [ZCLogUtils logHeader:LogHeader debug:@"查看大图：%@",self.tempModel.richModel.richmoreurl];
    if(self.delegate && [self.delegate respondsToSelector:@selector(cellItemClick:type:obj:)]){
        [self.delegate cellItemClick:self.tempModel type:ZCChatCellClickTypeItemOpenLocation obj:nil];
    }
}


-(void)resetCellView{
    //    cancelBtn = nil;
    [super resetCellView];
}


/*
 // Only override drawRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
 - (void)drawRect:(CGRect)rect {
 // Drawing code
 }
 */

+(CGFloat)getCellHeight:(ZCLibMessage *)model time:(NSString *)showTime viewWith:(CGFloat)width{
    CGFloat height = [super getCellHeight:model time:showTime viewWith:width];
    static UILabel *tempLabel = nil;
           if (!tempLabel) {
               tempLabel = [UILabel new];
               tempLabel.numberOfLines = 0;
               tempLabel.font = ZCUIFont14;
           }
    [tempLabel setText:zcLibConvertToString(model.richModel.localLabel)];
    
    
    CGSize s = [tempLabel sizeThatFits:CGSizeMake(ZCNumber(240) - ZCNumber(30), LocationHeight)];

//     [self.ivBgView setFrame:CGRectMake(rx, height, size.width+ZCNumber(33) , height + 33 + s.height +  ZCNumber(85) + 10)];

    height = height + 17 + s.height + ZCNumber(85) + 10 + 4+ 12 + 15 + 10;
    

    return height;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
