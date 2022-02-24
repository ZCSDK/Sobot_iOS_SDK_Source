//
//  ZCCardCollectionViewCell.m
//  SobotKit
//
//  Created by xuhan on 2019/9/4.
//  Copyright © 2019 zhichi. All rights reserved.
//

#import "ZCCardCollectionViewCell.h"
#import "ZCLibGlobalDefine.h"
#import "ZCUIImageTools.h"
#import "ZCUIColorsDefine.h"

NSString *const kZCCardCollectionViewCellID = @"ZCCollectionViewCell";
@interface ZCCardCollectionViewCell()
@property (nonatomic,assign) ZCMultitemHorizontaRollCellType  cellType;

@end

@implementation ZCCardCollectionViewCell
-(instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        self.contentView.backgroundColor = [ZCUITools zcgetLeftChatColor];
    }
    return self;
}

-(void)prepareForReuse{
    [super prepareForReuse];
    _posterView.image = nil;
}

-(void)setupViewsWithModel:(NSDictionary *)model with:(BOOL) showLinkStyle{
    
    for (UIView *view in self.contentView.subviews) {
        [view removeFromSuperview];
    }
    
    switch (self.cellType) {
        case ZCMultitemHorizontaRollCellType_text:
        {
            CGFloat gap = 15;
            CGFloat bgViewHeight = 34;
            
            _bgView = [[UIView alloc]initWithFrame:CGRectMake(gap, 1, self.contentView.bounds.size.width - gap*2, bgViewHeight - 2 )];
            _bgView.backgroundColor = UIColorFromThemeColor(ZCKeepWhiteColor);
            if([ZCUITools getZCThemeStyle] == ZCThemeStyle_Dark){
                _bgView.backgroundColor = UIColorFromThemeColor(ZCBgSystemWhiteThirdGrayColor);
            }
            
            _bgView.layer.cornerRadius = 15;

            //添加阴影
            _bgView.layer.shadowOpacity= 0.8;
            _bgView.layer.shadowColor = UIColorFromRGBAlpha(TextBlackColor, 0.07).CGColor;
            _bgView.layer.shadowOffset = CGSizeZero;//投影偏移
            _bgView.layer.shadowRadius = 2;
            
            
            
            _labTitle = [[UILabel alloc]init];
            [_labTitle setTextColor:[ZCUITools zcgetLeftChatTextColor]];
            [_labTitle setFont:ZCUIFont14];
            _labTitle.numberOfLines = 1;
            
            // 显示链接样式时，居左对齐，不要底色
            if(!showLinkStyle){
                _labTitle.textAlignment = NSTextAlignmentCenter;
                [_labTitle setFrame:CGRectMake(gap*2,0, self.contentView.bounds.size.width - gap*2*2, bgViewHeight)];
                [self.contentView addSubview:_bgView];
            }else{
                bgViewHeight = 24;
                _labTitle.textAlignment = NSTextAlignmentLeft;
                [_labTitle setFrame:CGRectMake(gap,0, self.contentView.bounds.size.width - gap*2, bgViewHeight)];
            }
            [self.contentView addSubview:_labTitle];
        }
            break;
        case ZCMultitemHorizontaRollCellType_address:
        {
//            if (_posterView) {
//                return;
//            }
            CGFloat gap = 15;
            CGFloat bgViewHeight = 94;
            
            _bgView = [[UIView alloc]initWithFrame:CGRectMake(gap, 2, self.contentView.bounds.size.width - gap*2, bgViewHeight -4)];
            _bgView.backgroundColor = UIColorFromThemeColor(ZCKeepWhiteColor);
            if([ZCUITools getZCThemeStyle] == ZCThemeStyle_Dark){
                _bgView.backgroundColor = UIColorFromThemeColor(ZCBgSystemWhiteThirdGrayColor);
            }
           
            //添加阴影
            _bgView.layer.shadowOpacity= 0.8;
            _bgView.layer.shadowColor = UIColorFromRGBAlpha(TextBlackColor, 0.07).CGColor;
            _bgView.layer.shadowOffset = CGSizeZero;//投影偏移
            _bgView.layer.shadowRadius = 2;
            
            [self.contentView addSubview:_bgView];
            
            NSString *picStr = model[@"thumbnail"];
            if ([picStr isKindOfClass:[NSNull class]] || picStr.length == 0) {
//                没有图
                _labTitle = [[UILabel alloc]init];
                [_labTitle setTextColor:UIColorFromThemeColor(ZCTextMainColor)];
                [_labTitle setFont:ZCUIFont14];
                _labTitle.numberOfLines = 1;
                [_labTitle setFrame:CGRectMake(gap*2,17, self.contentView.bounds.size.width - gap*2*2 - 80, 20)];
                //            _labTitle.backgroundColor = [UIColor blueColor];
                [self.contentView addSubview:_labTitle];
            
                _labDesc = [[UILabel alloc]init];
                [_labDesc setTextColor:UIColorFromThemeColor(ZCTextSubColor)];
                [_labDesc setFont:ZCUIFont14];
                _labDesc.numberOfLines = 1;
                [_labDesc setFrame:CGRectMake(_labTitle.frame.origin.x, CGRectGetMaxY(_labTitle.frame)+10, self.contentView.bounds.size.width - 60 - gap*5, 20)];
                [self.contentView addSubview:_labDesc];
                
                
                
                
                _labTag = [[UILabel alloc]init];
                [_labTag setTextColor:UIColorFromThemeColor(ZCTextSubColor)];
                _labTag.textAlignment = NSTextAlignmentRight;
                [_labTag setFont:ZCUIFont12];
                _labTag.numberOfLines = 1;
                [_labTag setFrame:CGRectMake(CGRectGetMaxX(_labTitle.frame) + gap,_labTitle.frame.origin.y, 80 - gap, 20)];
                //            _labTag.backgroundColor = [UIColor redColor]; _labLabel
                [self.contentView addSubview:_labTag];
            }else{
//                有图
                CGSize posterViewSize = CGSizeMake(60, 60);
                _posterView=[[SobotImageView alloc] init];
                [_posterView setContentMode:UIViewContentModeScaleAspectFill];
                _posterView.layer.cornerRadius = 5;
                _posterView.layer.masksToBounds=YES;
                [_posterView setFrame:CGRectMake(gap*2, 17, posterViewSize.width   , posterViewSize.height)];
                _posterView.backgroundColor = UIColorFromThemeColor(ZCBgSystemWhiteLightDarkColor);
                [self.contentView addSubview:_posterView];
                
                _labTitle = [[UILabel alloc]init];
                [_labTitle setTextColor:UIColorFromThemeColor(ZCTextMainColor)];
                [_labTitle setFont:ZCUIFont14];
                _labTitle.numberOfLines = 1;
                [_labTitle setFrame:CGRectMake(CGRectGetMaxX(_posterView.frame) + gap,17, self.contentView.bounds.size.width - gap*2*2 - 80 - posterViewSize.width - 15, 20)];
//                            _labTitle.backgroundColor = [UIColor blueColor];
                [self.contentView addSubview:_labTitle];
                
                _labDesc = [[UILabel alloc]init];
                [_labDesc setTextColor:UIColorFromThemeColor(ZCTextSubColor)];
                [_labDesc setFont:ZCUIFont14];
                _labDesc.numberOfLines = 1;
                [_labDesc setFrame:CGRectMake(CGRectGetMaxX(_posterView.frame) + gap, CGRectGetMaxY(_labTitle.frame)+10, self.contentView.bounds.size.width - posterViewSize.width - gap*5, 20)];
//                _labTag.backgroundColor = [UIColor blueColor];

                [self.contentView addSubview:_labDesc];
                
                
                
                
                _labTag = [[UILabel alloc]init];
                [_labTag setTextColor:UIColorFromThemeColor(ZCTextSubColor)];
                _labTag.textAlignment = NSTextAlignmentRight;
                [_labTag setFont:ZCUIFont12];
                _labTag.numberOfLines = 1;
                [_labTag setFrame:CGRectMake(CGRectGetMaxX(_labTitle.frame) + gap,_labTitle.frame.origin.y, 80 - gap, 20)];
//                            _labLabel.backgroundColor = [UIColor redColor];
                [self.contentView addSubview:_labTag];
            }

            

            
//            _labTag = [[UILabel alloc]init];
//            [_labTag setTextColor:UIColorFromThemeColor(ZCTextSubColor)];
//            _labTag.textAlignment = NSTextAlignmentRight;
//            [_labTag setFont:ZCUIFont14];
//            _labTag.numberOfLines = 1;
//            [_labTag setFrame:CGRectMake(CGRectGetMaxX(_labTitle.frame) + gap,_labTitle.frame.origin.y, 80 - gap, 20)];
//            //            _labTag.backgroundColor = [UIColor redColor];
//            [self.contentView addSubview:_labTag];
        }
            break;
        case ZCMultitemHorizontaRollCellType_card:
        {
//            if (_posterView) {
//                return;
//            }
            CGFloat gap = 15;
            CGFloat bgViewHeight = 114;
            
            _bgView = [[UIView alloc]initWithFrame:CGRectMake(gap, 2, self.contentView.bounds.size.width - gap*2, bgViewHeight - 4)];
            _bgView.backgroundColor = UIColorFromThemeColor(ZCKeepWhiteColor);
            if([ZCUITools getZCThemeStyle] == ZCThemeStyle_Dark){
                _bgView.backgroundColor = UIColorFromThemeColor(ZCBgSystemWhiteThirdGrayColor);
            }
           
            //添加阴影
            _bgView.layer.shadowOpacity= 0.8;
            _bgView.layer.shadowColor = UIColorFromRGBAlpha(TextBlackColor, 0.07).CGColor;
            _bgView.layer.shadowOffset = CGSizeZero;//投影偏移
            _bgView.layer.shadowRadius = 2;
            
            [self.contentView addSubview:_bgView];
            
            
            _labTitle = [[UILabel alloc]init];
            [_labTitle setTextColor:UIColorFromThemeColor(ZCTextMainColor)];
            [_labTitle setFont:ZCUIFont14];
            _labTitle.numberOfLines = 1;
            [_labTitle setFrame:CGRectMake(gap*2,10, self.contentView.bounds.size.width - gap*2*2, 20)];
            [self.contentView addSubview:_labTitle];
            
            CGSize posterViewSize = CGSizeMake(60, 60);
            _posterView=[[SobotImageView alloc] init];
            [_posterView setContentMode:UIViewContentModeScaleAspectFill];
            _posterView.layer.cornerRadius = 5;
            _posterView.layer.masksToBounds=YES;
            [_posterView setFrame:CGRectMake(gap*2,CGRectGetMaxY(_labTitle.frame)+10, posterViewSize.width   , posterViewSize.height)];
            _posterView.backgroundColor = UIColorFromThemeColor(ZCBgSystemWhiteLightDarkColor);
            [self.contentView addSubview:_posterView];
            
            _posterView.hidden = NO;
            if(sobotConvertToString(model[@"thumbnail"]).length == 0){
                _posterView.hidden = YES;
                [_posterView setFrame:CGRectMake(gap,CGRectGetMaxY(_labTitle.frame)+10, 0,0)];
            }
            
            _labDesc = [[UILabel alloc]init];
            [_labDesc setTextColor:UIColorFromThemeColor(ZCTextSubColor)];
            [_labDesc setFont:ZCUIFont14];
            _labDesc.numberOfLines = 1;
            [_labDesc setFrame:CGRectMake(CGRectGetMaxX(_posterView.frame) + gap, CGRectGetMaxY(_labTitle.frame)+10, self.contentView.bounds.size.width - posterViewSize.width - gap*5, 20)];
            [self.contentView addSubview:_labDesc];
            
            float labTagWidth = 100;
            
            _labLabel = [[UILabel alloc]init];
            [_labLabel setTextColor:[ZCUITools zcgetRightChatColor]];
            [_labLabel setFont:ZCUIFontBold14];
            _labLabel.numberOfLines = 1;
            [_labLabel setFrame:CGRectMake(CGRectGetMaxX(_posterView.frame) + gap,CGRectGetMaxY(_labDesc.frame)+15, self.contentView.bounds.size.width - CGRectGetMaxX(_posterView.frame) - labTagWidth - gap*2, 20)];
//            _labLabel.backgroundColor = [UIColor yellowColor];

            [self.contentView addSubview:_labLabel];
            
            _labTag = [[UILabel alloc]init];
            [_labTag setTextColor:UIColorFromThemeColor(ZCTextSubColor)];
            _labTag.textAlignment = NSTextAlignmentRight;
            [_labTag setFont:ZCUIFont12];
            _labTag.numberOfLines = 1;
            [_labTag setFrame:CGRectMake(CGRectGetMaxX(self.contentView.frame) - labTagWidth - gap*2,CGRectGetMaxY(_labDesc.frame)+15, labTagWidth, 20)];
//                        _labTag.backgroundColor = [UIColor redColor];
            [self.contentView addSubview:_labTag];
            
        }
            break;
        default:
            break;
    }
    
    
}


- (void)configureCellWithPostURL:(NSDictionary *)model WithIsHistory:(BOOL) isHistory withType:(ZCMultitemHorizontaRollCellType )cellType  linkStyle:(BOOL) showLinkStyle{
    
    self.cellType = cellType;
    
    [self setupViewsWithModel:model with:showLinkStyle];
    
    
   
    [_posterView loadWithURL:[NSURL URLWithString:sobotUrlEncodedString(model[@"thumbnail"])] placeholer:[ZCUITools zcuiGetBundleImage:@"zcicon_default_goods"] showActivityIndicatorView:YES];
    [_labTitle setText:sobotConvertToString(model[@"title"])];// [NSString stringWithFormat:@"我是标题%@",item[@"row"]] zcicon_avatar_robot
    [_labDesc setText:sobotConvertToString(model[@"summary"])];// [NSString stringWithFormat:@"我是描述%@",item[@"desc"]]
    [_labTag setText:sobotConvertToString(model[@"tag"])];
    [_labLabel setText:sobotConvertToString(model[@"label"])];
    [_labTitle setTextColor:[ZCUITools zcgetLeftChatTextColor]];
    if(cellType == ZCMultitemHorizontaRollCellType_text){
        if(!isHistory){
            [_labTitle setTextColor:[ZCUITools zcgetChatLeftLinkColor]];
        }
        
        _labTitle.numberOfLines = 1;
        // 显示连接样式时，需要显示序号
        if(showLinkStyle){
            _labTitle.numberOfLines = 2;
            // 自动折行设置
            _labTitle.lineBreakMode = NSLineBreakByCharWrapping;
            [_labTitle setText:[NSString stringWithFormat:@"%d、%@",(int)self.indexPath.row+1,sobotConvertToString(model[@"title"])]];
            [_labTitle sizeToFit];
        }
    }
}


@end
