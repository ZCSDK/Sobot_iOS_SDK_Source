//
//  ZCUIChatListCell.m
//  SobotKit
//
//  Created by zhangxy on 2017/9/5.
//  Copyright © 2017年 zhichi. All rights reserved.
//

#import "ZCUIChatListCell.h"
#import "ZCLibGlobalDefine.h"
#import "ZCUIColorsDefine.h"
#import "ZCLibCommon.h"
#import "ZCUICore.h"

@implementation ZCUIChatListCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}


-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self=[super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if(self){
        _lblTime=[[UILabel alloc] initWithFrame:CGRectMake(ScreenWidth - 90, 5, 85, 50)];
        [_lblTime setTextAlignment:NSTextAlignmentRight];
        [_lblTime setFont:[ZCUITools zcgetListKitTimeFont]];
        [_lblTime setTextColor:[ZCUITools zcgetTimeTextColor]];
        [_lblTime setBackgroundColor:[UIColor clearColor]];
        [self.contentView addSubview:_lblTime];
        _lblTime.hidden=NO;
        
        
        _lblNickName =[[UILabel alloc] initWithFrame:CGRectMake(60, 5, ScreenWidth - 60 - 80, 25)];
        [_lblNickName setBackgroundColor:[UIColor clearColor]];
        [_lblNickName setTextAlignment:NSTextAlignmentLeft];
        [_lblNickName setFont:[ZCUITools zcgetListKitTitleFont]];
        [_lblNickName setTextColor:[ZCUITools zcgetGoodsTextColor]];
        [_lblNickName setBackgroundColor:[UIColor clearColor]];
        [self.contentView addSubview:_lblNickName];
        _lblNickName.hidden=NO;
        
        _ivHeader = [[SobotImageView alloc] initWithFrame:CGRectMake(5, 5, 50, 50)];
        [_ivHeader setContentMode:UIViewContentModeScaleAspectFill];
        [_ivHeader.layer setMasksToBounds:YES];
        [_ivHeader setBackgroundColor:[UIColor clearColor]];
        _ivHeader.layer.cornerRadius=4.0f;
        _ivHeader.layer.masksToBounds=YES;
        _ivHeader.layer.borderWidth = 0.5f;
        _ivHeader.layer.borderColor = [ZCUITools zcgetBackgroundColor].CGColor;
        [self.contentView addSubview:_ivHeader];
        
        _lblLastMsg =[[UILabel alloc] initWithFrame:CGRectMake(60, 30, ScreenWidth - 60 - 80, 25)];
        [_lblLastMsg setBackgroundColor:[UIColor clearColor]];
        [_lblLastMsg setTextAlignment:NSTextAlignmentLeft];
        [_lblLastMsg setFont:[ZCUITools zcgetListKitDetailFont]];
        [_lblLastMsg setTextColor:[ZCUITools zcgetServiceNameTextColor]];
        _lblLastMsg.numberOfLines = 1;
        [_lblLastMsg setBackgroundColor:[UIColor clearColor]];
        [self.contentView addSubview:_lblLastMsg];
        _lblLastMsg.hidden=NO;

        _lblUnRead =[[UILabel alloc] initWithFrame:CGRectMake(55-15, 3, 20, 20)];
        [_lblUnRead setBackgroundColor:[UIColor clearColor]];
        [_lblUnRead setTextAlignment:NSTextAlignmentCenter];
        [_lblUnRead setFont:[ZCUITools zcgetListKitTimeFont]];
        [_lblUnRead setTextColor:[UIColor whiteColor]];
        [_lblUnRead setBackgroundColor:UIColorFromThemeColor(ZCTextWarnRedColor)];
        _lblUnRead.layer.cornerRadius = 10;
        _lblUnRead.layer.masksToBounds = YES;
        [self.contentView addSubview:_lblUnRead];
        _lblUnRead.hidden=YES;
        
        
        self.userInteractionEnabled=YES;
    }
    return self;
}

-(void)dataToView:(ZCPlatformInfo *)info{
    if(info){
        NSString * text = zcLibConvertToString(info.lastMsg);
        // 过滤标签
        text = [text stringByReplacingOccurrencesOfString:@"<br />" withString:@"\n"];
        text = [text stringByReplacingOccurrencesOfString:@"<br/>" withString:@"\n"];
        text = [text stringByReplacingOccurrencesOfString:@"<br>" withString:@"\n"];
        text = [text stringByReplacingOccurrencesOfString:@"<BR/>" withString:@"\n"];
        text = [text stringByReplacingOccurrencesOfString:@"<BR />" withString:@"\n"];
        text = [text stringByReplacingOccurrencesOfString:@"<p>" withString:@""];
        text = [text stringByReplacingOccurrencesOfString:@"</p>" withString:@""];
        text = [text stringByReplacingOccurrencesOfString:@"&nbsp;" withString:@" "];
        
        _lblLastMsg.text = text;
        _lblNickName.text = zcLibConvertToString(info.platformName);


        if (zcLibConvertToString(info.lastDate).length >17) {
            // 处理时间，如果是当日 显示 时间 否者显示日期
            if ([[self getCurrentTimes] isEqualToString:zcLibDateTransformString(@"YYYY-MM-dd", zcLibStringFormateDate(info.lastDate))]) {
                _lblTime.text = zcLibDateTransformString(@"HH:mm", zcLibStringFormateDate(info.lastDate));
            }else{
                _lblTime.text = zcLibDateTransformString(ZCSTLocalString(@"MM月dd日"), zcLibStringFormateDate(info.lastDate));
            }
        }else{
            long long t = [zcLibConvertToString(info.lastDate) longLongValue];
            if(info.lastDate.length > 10){
                t = t/1000;
            }
            NSString * times  = [NSString stringWithFormat:@"%lld",t];
            
            // 处理时间，如果是当日 显示 时间 否者显示日期
            if ([[self getCurrentTimes] isEqualToString:[self getTimeFromTimesTamp:times withType:1]]) {
                _lblTime.text =  [self getTimeFromTimesTamp:times withType:2];
            }else{
                _lblTime.text =  [self getTimeFromTimesTamp:times withType:3];
            }
        }
        

        // 不是中文时，不显示时间
//        if([ZCUICore getUICore].kitInfo.hideChatTime && (![zcGetLanguagePrefix() hasPrefix:@"zh-"] || ![[ZCLibClient getZCLibClient].libInitInfo.absolute_language hasPrefix:@"zh-"])){
        if([ZCUICore getUICore].kitInfo.hideChatTime){
            _lblTime.text = @"";
        }
        
        NSString *url = [zcLibConvertToString(info.avatar) stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        [_ivHeader loadWithURL:[NSURL URLWithString:url] placeholer:[ZCUITools zcuiGetBundleImage:@"zcicon_useravatar_nol"] showActivityIndicatorView:NO];
        _lblUnRead.hidden = YES;
        if(info.unRead>0){
            _lblUnRead.hidden = NO;
            
            if(info.unRead>99){
                _lblUnRead.text = @"99+";
            }else{
                _lblUnRead.text = [NSString stringWithFormat:@"%d",info.unRead];
            }
        }
    }
    [self setBackgroundColor:UIColorFromThemeColor(ZCBgSystemWhiteLightDarkColor)];
    [self setFrame:CGRectMake(0, 0, ScreenWidth, 60)];
}

-(NSString*)getCurrentTimes{
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    
    // ----------设置你想要的格式,hh与HH的区别:分别表示12小时制,24小时制
    
//    [formatter setDateFormat:@"YYYY-MM-dd HH:mm:ss"];
    [formatter setDateFormat:@"YYYY-MM-dd"];
    
    //现在时间,你可以输出来看下是什么格式
    
    NSDate *datenow = [NSDate date];
    
    //----------将nsdate按formatter格式转成nsstring
    
    NSString *currentTimeString = [formatter stringFromDate:datenow];
    
//    NSLog(@"currentTimeString =  %@",currentTimeString);
    
    return currentTimeString;
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (NSString *)getTimeFromTimesTamp:(NSString *)timeStr withType:(int)type{
    
    
    double time = [timeStr doubleValue];
    
    NSDate *myDate = [NSDate dateWithTimeIntervalSince1970:time];
    
    NSDateFormatter *formatter = [NSDateFormatter new];
    if (type == 1) {
        [formatter setDateFormat:@"YYYY-MM-dd"];
    }else if (type == 2){
      [formatter setDateFormat:@"HH:mm"];
    }else if (type == 3){
        [formatter setDateFormat:ZCSTLocalString(@"MM月dd日")];
    }
    
    
    //将时间转换为字符串
    NSString *timeS = [formatter stringFromDate:myDate];
    
    return timeS;
    
}



@end
