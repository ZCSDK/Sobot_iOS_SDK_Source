//
//  ZCOrderGoodsCell.m
//  SobotKit
//
//  Created by 张新耀 on 2019/9/29.
//  Copyright © 2019 zhichi. All rights reserved.
//

#import "ZCOrderGoodsCell.h"

#import "ZCLibGlobalDefine.h"
#import "ZCUIColorsDefine.h"
#import "ZCUIXHImageViewer.h"
#import "ZCUIImageView.h"
#import "ZCStoreConfiguration.h"
#import "ZCLibStatusDefine.h"

@interface ZCOrderGoodsCell(){
   
}

//@property (nonatomic,strong) UIView *cellBgView;

@property (nonatomic,strong) ZCUIImageView   *imgPhoto;

@property (nonatomic,strong) UILabel * lblTextTitle;

@property (nonatomic,strong) UILabel * lblPrice;
@property (nonatomic,strong) UILabel * lblStatus;
@property (nonatomic,strong) UILabel * lblOrderNo;
@property (nonatomic,strong) UILabel * lblOrderTime;
@property (nonatomic,strong) UIView * lineView;

//@property (nonatomic,strong) UIView *cellBgView;

@end




@implementation ZCOrderGoodsCell


-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self=[super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if(self){
        self.ivBgView.userInteractionEnabled = YES;
        
//        _cellBgView = [[UIView alloc]init];
//        [self.contentView addSubview:_cellBgView];
        
        _imgPhoto = [[ZCUIImageView alloc] init];
        [_imgPhoto setBackgroundColor:[UIColor clearColor]];
        [_imgPhoto setContentMode:UIViewContentModeScaleAspectFill];
        _imgPhoto.layer.cornerRadius = 5;
        _imgPhoto.layer.masksToBounds = YES;
        
        [self.contentView addSubview:_imgPhoto];
        
        
        // title
        _lblTextTitle = [self createSubLable];
        [_lblTextTitle setFont:ZCUIFont14];
        [self.contentView addSubview:_lblTextTitle];
        
        
       
        // 标签
        _lblPrice = [self createSubLable];
        [_lblPrice setTextColor:UIColorFromThemeColor(ZCTextSubColor)];
        [self.contentView addSubview:_lblPrice];
        
        
        // 标签
        _lblStatus = [self createSubLable];
        [self.contentView addSubview:_lblStatus];
        
        
        // 标签
        _lblOrderNo = [self createSubLable];
        [self.contentView addSubview:_lblOrderNo];
        
        
        // 标签
        _lblOrderTime = [self createSubLable];
        [self.contentView addSubview:_lblOrderTime];
        
        
        _lineView = [[UIView alloc] init];
        [_lineView setBackgroundColor:UIColorFromThemeColor(ZCBgLineColor)];
        [self.contentView addSubview:_lineView];
        
        [self.contentView setBackgroundColor:[UIColor clearColor]];
        
        
        //设置点击事件
        UITapGestureRecognizer *tapGesturer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tap:)];
        self.ivBgView.userInteractionEnabled=YES;
        [self.ivBgView addGestureRecognizer:tapGesturer];
    }
    return self;
}

-(UILabel *) createSubLable{

    // 标签
    UILabel *lblTemp = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 0, 0)];
    [lblTemp setTextAlignment:NSTextAlignmentLeft];
    [lblTemp setFont:ZCUIFont12];
    [lblTemp setBackgroundColor:[UIColor clearColor]];
    [lblTemp setTextColor:UIColorFromThemeColor(ZCTextMainColor)];
    lblTemp.numberOfLines = 1;
    
    return lblTemp;
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




+(NSDictionary *)getZCproductInfo:(ZCLibMessage *) tempModel{
    NSDictionary *dict= nil;
    if(tempModel.richModel.msg!=nil){
        @try {
            NSError * err;
            dict=[NSJSONSerialization JSONObjectWithData:[zcLibConvertToString(tempModel.richModel.msg) dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableLeaves error:&err];
        } @catch (NSException *exception) {
            
        } @finally {
            
        }
        
    }
    return dict;
}

-(NSMutableAttributedString *)getOtherColorString:(NSString *)string Color:(UIColor *)Color withString:(NSString *)originalString
{
    NSMutableAttributedString *str = [[NSMutableAttributedString alloc]init];
    
    NSMutableString *temp = [NSMutableString stringWithString:zcLibConvertToString(originalString)];
    str = [[NSMutableAttributedString alloc] initWithString:temp];
    if (string.length) {
        NSRange range = [temp rangeOfString:string];
        [str addAttribute:NSForegroundColorAttributeName value:Color range:range];
        return str;
        
    }
    return str;
    
}


-(CGFloat) InitDataToView:(ZCLibMessage *) model time:(NSString *) showTime{
    CGFloat height=[super InitDataToView:model time:showTime];
        self.tempModel = model;
    
    NSDictionary *dict = model.miniPageDic;
    if(dict == nil){
        dict = [ZCOrderGoodsCell getZCproductInfo:model];
        
    }

    
    self.ivBgView.hidden = NO;
    
    _imgPhoto.hidden = YES;
    _lblTextTitle.hidden = YES;
    _lblPrice.hidden = YES;
    _lblStatus.hidden = YES;
    _lblOrderTime.hidden = YES;
    _lineView.hidden = YES;
    _lblOrderNo.hidden = YES;
    [_imgPhoto setImage:[ZCUITools zcuiGetBundleImage:@"zcicon_default_goods"]];
    if(dict){
        NSArray *goods = dict[@"goods"];
       
        
        NSString *goodsDesc = @"";
        if(goods && [goods isKindOfClass:[NSArray class]] && goods.count>0){
            NSDictionary *good = goods[0];
            goodsDesc = good[@"name"];
            [_imgPhoto loadWithURL:[NSURL URLWithString:zcUrlEncodedString(good[@"pictureUrl"])] placeholer:[ZCUITools zcuiGetBundleImage:@"zcicon_default_goods"] showActivityIndicatorView:YES];
            _imgPhoto.hidden = NO;
        }
        NSString *orderStatus = [ZCOrderGoodsModel getOrderStatusMsg:[zcLibConvertToString(dict[@"orderStatus"]) intValue]];
        NSString *orderCode = zcLibConvertToString(dict[@"orderCode"]);
        NSString *createTime = (zcLibConvertToString(dict[@"createTime"]).length > 0) ? zcLibLongdateTransformString(FormateTime, [zcLibConvertToString(dict[@"createTime"]) longLongValue]):@"";
//        NSString *orderUrl = zcLibConvertToString(dict[@"orderUrl"]);
        NSString *goodsCount = zcLibConvertToString(dict[@"goodsCount"]);
        NSString *moneySum = zcLibConvertToString(dict[@"totalFee"]);
        if(zcLibValidateNumber(moneySum)){
            moneySum = [NSString stringWithFormat:@"%0.2f%@",[zcLibConvertToString(dict[@"totalFee"]) floatValue]/100,ZCSTLocalString(@"元")];
        }
        
        if(goodsDesc.length > 0 ){
            [_lblTextTitle setText:goodsDesc];
            _lblTextTitle.hidden = NO;
         }else{
             [_lblTextTitle setText:@""];
        }

        if(moneySum.length > 0 || goodsCount.length > 0){
            
            NSString *unitStr = ZCSTLocalString(@"件");
            NSString *goodsStr = ZCSTLocalString(@"商品");
            NSString *totalStr = ZCSTLocalString(@"合计");
            
            if (moneySum.length > 0 && goodsCount.length > 0) {

                [_lblPrice setText:[NSString stringWithFormat:@"%@%@%@,%@ %@",goodsCount,unitStr,goodsStr,totalStr,moneySum]];
            }else if (moneySum.length > 0 && goodsCount.length == 0){
                [_lblPrice setText:[NSString stringWithFormat:@"%@ %@",totalStr,moneySum]];
            }else if (moneySum.length == 0 && goodsCount.length > 0) {
                [_lblPrice setText:[NSString stringWithFormat:@"%@%@%@",goodsCount,unitStr,goodsStr]];
            }
            _lblPrice.hidden = NO;

            
         }else{
             moneySum = @"    ";
             [_lblPrice setText:@"    "];
             
        }

        _lblStatus.hidden = NO;
        
        NSString *orderStr = ZCSTLocalString(@"订单");
        NSString *statusStr = ZCSTLocalString(@"状态");
        
        NSString *numStr = ZCSTLocalString(@"编号");
        NSString *giveOrderStr = ZCSTLocalString(@"下单");
        NSString *timeStr = ZCSTLocalString(@"时间");
        
        _lblStatus.attributedText = [self getOtherColorString:orderStatus Color:UIColorFromThemeColor(ZCTextNoticeLinkColor) withString:[NSString stringWithFormat:@"%@%@：%@",orderStr,statusStr,orderStatus]];
        
        if(orderCode.length > 0 ){
           _lblOrderNo.hidden = NO;
           [_lblOrderNo setText:[NSString stringWithFormat:@"%@%@：%@",orderStr,numStr,orderCode]];
        }else{
           [_lblOrderNo setText:@""];
        }
        
        if(createTime.length > 0 ){
           _lblOrderTime.hidden = NO;
           [_lblOrderTime setText:[NSString stringWithFormat:@"%@%@：%@",giveOrderStr,timeStr,createTime]];
        }else{
            [_lblOrderTime setText:@""];
        }
        
        CGSize titleSize  =  CGSizeMake(self.maxWidth, 20);
        if(!_imgPhoto.hidden){
            titleSize = CGSizeMake(self.maxWidth - 58, 20);
        }
        
        CGSize size = CGSizeMake(self.maxWidth, 20);
        
        CGFloat msgX = 0;
        CGFloat msgY = height + 15;
        // 0,自己，1机器人，2客服
        self.marginWidth = 15;
        self.paddingWidth = 15;
        if(self.isRight){
            int rx = self.viewWidth - self.maxWidth - self.marginWidth;
            msgX = rx + self.paddingWidth;
            
            if(!_imgPhoto.hidden){
                [_imgPhoto setFrame:CGRectMake(msgX, msgY, 48, 48)];
            }
            
            if(!_lblTextTitle.hidden){
                
                [_lblTextTitle setFrame:CGRectMake(msgX+(!_imgPhoto.hidden?58:0), msgY, titleSize.width - (!_imgPhoto.hidden?58:0), 22)];
                msgY = msgY + 22 + 4;
            }
            if(!_lblPrice.hidden){
                [_lblPrice setFrame:CGRectMake(msgX+(!_imgPhoto.hidden?58:0), msgY, titleSize.width  - (!_imgPhoto.hidden?58:0), 22)];
                msgY = msgY + 22 + 15;
                
            }
            if((msgY - height - 10) > 22){
                _lineView.hidden = NO;
                [_lineView setFrame:CGRectMake(msgX, msgY, size.width - self.paddingWidth*2, 1)];
                msgY  = msgY + 11;
            }
            
            if(!_lblStatus.hidden){
                [_lblStatus setFrame:CGRectMake(msgX, msgY, size.width, 20)];
                msgY = msgY + 20;
            }
            
            if(!_lblOrderNo.hidden){
                [_lblOrderNo setFrame:CGRectMake(msgX, msgY, size.width, 20)];
                msgY = msgY + 20;
            }
            
            if(!_lblOrderTime.hidden){
                [_lblOrderTime setFrame:CGRectMake(msgX, msgY, size.width, 20)];
                msgY = msgY + 20;
            }
            
            msgY = msgY + 11;
            [self.ivBgView setFrame:CGRectMake(rx, height, self.maxWidth, msgY - height)];
            
//            [_cellBgView setFrame:CGRectMake(rx, height, self.maxWidth, msgY - height)];
            
        }else{
            msgX = self.marginWidth + self.paddingWidth;
            
            if (_imgPhoto.hidden && _lblTextTitle.hidden && _lblPrice.hidden) {
                if(!_lblStatus.hidden){
                    [_lblStatus setFrame:CGRectMake(msgX, msgY, size.width, 20)];
                    msgY = msgY + 20;
                }
                
                if(!_lblOrderNo.hidden){
                    [_lblOrderNo setFrame:CGRectMake(msgX, msgY, size.width, 20)];
                    msgY = msgY + 20;
                }
                
                if(!_lblOrderTime.hidden){
                    [_lblOrderTime setFrame:CGRectMake(msgX, msgY, size.width, 20)];
                    msgY = msgY + 20;
                }
                msgY = msgY + 11;
                [self.ivBgView setFrame:CGRectMake(self.marginWidth, height, self.maxWidth, msgY - height)];
                
//                [_cellBgView setFrame:CGRectMake(self.marginWidth, height, self.maxWidth, msgY - height)];
                
            }else{
                if(!_imgPhoto.hidden){
                    [_imgPhoto setFrame:CGRectMake(msgX, msgY, 48, 48)];
                }
                
                if(!_lblTextTitle.hidden){
                    
                    [_lblTextTitle setFrame:CGRectMake(msgX+(!_imgPhoto.hidden?58:0), msgY, titleSize.width, 22)];
                    msgY = msgY + 22 + 4;
                }
                if(!_lblPrice.hidden){
                    [_lblPrice setFrame:CGRectMake(msgX+(!_imgPhoto.hidden?58:0), msgY, titleSize.width, 22)];
                    msgY = msgY + 22 + 15;
                    
                }
                if((msgY - height - 10) > 22){
                    _lineView.hidden = NO;
                    [_lineView setFrame:CGRectMake(msgX, msgY, self.maxWidth - self.paddingWidth*2, 1)];
                    msgY  = msgY + 11;
                }
                
                if(!_lblStatus.hidden){
                    [_lblStatus setFrame:CGRectMake(msgX, msgY, size.width, 20)];
                    msgY = msgY + 20;
                }
                
                if(!_lblOrderNo.hidden){
                    [_lblOrderNo setFrame:CGRectMake(msgX, msgY, size.width, 20)];
                    msgY = msgY + 20;
                }
                
                if(!_lblOrderTime.hidden){
                    [_lblOrderTime setFrame:CGRectMake(msgX, msgY, size.width, 20)];
                    msgY = msgY + 20;
                }
                msgY = msgY + 11;
                [self.ivBgView setFrame:CGRectMake(self.marginWidth, height, self.maxWidth, msgY - height)];
                
//                [_cellBgView setFrame:CGRectMake(self.marginWidth, height, self.maxWidth, msgY - height)];
                
            }

        }
        height= msgY+11;
    }

    [self setSendStatus:self.ivBgView.frame];

    
    
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
    
     [self.ivLayerView setFrame:self.ivBgView.frame];
     CALayer *layer              = self.ivLayerView.layer;
     layer.frame                 = (CGRect){{0,0},self.ivLayerView.layer.frame.size};
     self.ivBgView.layer.mask = layer;

     [self.ivBgView setNeedsDisplay];
    
    
    [self setFrame:CGRectMake(0, 0, self.viewWidth, height)];
    
        
    return height;
}

// 点击查看大图
-(void) tap:(UITapGestureRecognizer *)recognizer{
//    [ZCLogUtils logHeader:LogHeader debug:@"查看大图：%@",self.tempModel.richModel.richmoreurl];
    [self onCellClick];
}


- (void)onCellClick{
    if(self.delegate && [self.delegate respondsToSelector:@selector(cellItemLinkClick:type:obj:)]){
        
        NSString * link = @"";
        NSDictionary *dict = self.tempModel.miniPageDic;
        if(dict == nil){
            dict = [ZCOrderGoodsCell getZCproductInfo:self.tempModel];
            
        }
        if (dict) {
            link = zcLibConvertToString(dict[@"orderUrl"]);
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
    NSDictionary *dict = model.miniPageDic;
    if(dict == nil){
        dict = [ZCOrderGoodsCell getZCproductInfo:model];
    }
    
    if(dict){
        
//        NSString *orderStatus = [ZCOrderGoodsModel getOrderStatusMsg:[zcLibConvertToString(dict[@"orderStatus"]) intValue]];
        NSString *orderCode = zcLibConvertToString(dict[@"orderCode"]);
        NSString *createTime = zcLibConvertToString(dict[@"createTime"]);
//        NSString *orderUrl = zcLibConvertToString(dict[@"orderUrl"]);
        NSString *goodsDesc = @"";
        NSArray *goods = dict[@"goods"];
              
        NSString *picStr = @"";
       if(goods && [goods isKindOfClass:[NSArray class]] && goods.count > 0){
           NSDictionary *good = goods[0];
           goodsDesc = good[@"name"];
           
           picStr = good[@"pictureUrl"];
       }
        NSString *goodsCount = zcLibConvertToString(dict[@"goodsCount"]);
        NSString *moneySum = zcLibConvertToString(dict[@"totalFee"]);
        if(zcLibValidateNumber(moneySum)){
            moneySum = [NSString stringWithFormat:@"%0.2f%@",[zcLibConvertToString(dict[@"totalFee"]) floatValue]/100,ZCSTLocalString(@"元")];
        }
        
        CGFloat msgY = cellheith + 10;
        
        BOOL hasImg = NO;
        BOOL hasTitle = NO;
        BOOL hasPrice = NO;
        
        if(moneySum.length > 0 || goodsCount.length > 0){
            hasPrice = YES;
        }
        
        if (goodsDesc.length> 0) {
            hasTitle = YES;
        }
        
        if (picStr.length > 0) {
            hasImg = YES;
        }
        
        
        if (hasPrice || hasTitle || hasImg ) {
             if(goodsDesc.length > 0 ){
                       msgY = msgY + 22 + 4;
                    }
                    
            //        if(moneySum.length > 0 || goodsCount.length > 0){
                        msgY = msgY + 22 + 15;
            //        }
                    if((msgY - cellheith - 10) > 22){
                        msgY  = msgY + 11;
                    }
                    
                    // 状态肯定有数据
                     msgY = msgY + 20;
                    
                    if(orderCode.length > 0 ){
                      msgY = msgY + 20;
                    }
                    
                    if(createTime.length > 0 ){
                         msgY = msgY + 20;
                    }
                    
                    cellheith= msgY+26;
        }else{
                        // 状态肯定有数据
                         msgY = msgY + 20;
                        
                        if(orderCode.length > 0 ){
                          msgY = msgY + 20;
                        }
                        
                        if(createTime.length > 0 ){
                             msgY = msgY + 20;
                        }
                        
                        cellheith= msgY+26;
        }
        
       

        
    }
    return cellheith;
}


- (CGSize)sizeThatFits:(CGSize)size {
    
    CGSize rSize = [super sizeThatFits:size];
    rSize.height +=1;
    return rSize;
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
