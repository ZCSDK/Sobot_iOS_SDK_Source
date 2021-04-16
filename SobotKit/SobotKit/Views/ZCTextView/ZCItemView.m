//
//  ItemView.m
//  CollectionViewDemo
//
//  Created by on 2017/6/18.
//  Copyright © 2017年 . All rights reserved.
//

#import "ZCItemView.h"
#import "ZCLibGlobalDefine.h"
#import "ZCUIColorsDefine.h"
#import "ZCUIImageTools.h"

// 一行中最3列
#define MaxCols 2

@interface ZCItemView()

@end
@implementation ZCItemView

-(void)layoutSubviews{
    
    [super layoutSubviews];
    CGFloat inset = 20;
    NSUInteger count = self.subviews.count;
    CGFloat btnW = (self.frame.size.width - 2.5 * inset) / MaxCols;
    CGFloat btnH = 36;
    for (int i = 0; i<count; i++) {
        UIView *tempView = self.subviews[i];
        
        tempView.frame = CGRectMake(inset+ (i%MaxCols)*(10 +  btnW), 20*(i/MaxCols) + (i/MaxCols) * btnH, btnW, btnH);
    }
    self.userInteractionEnabled = YES;
}
+(CGFloat)getHeightWithArray:(NSArray *)titles{
    
    CGFloat btHeight = 36;
    int rows = (int)(titles.count/2 + ((titles.count%2==0)?0:1));
    return    btHeight*rows + (rows - 1) * 20;

}


-(void)InitDataWithArray:(NSArray *)titles{
    [self InitDataWithArray:titles withCheckLabels:nil];
}

-(void)InitDataWithArray:(NSArray *)titles withCheckLabels:(NSString *)labels{
    [self.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    int tagI = 100;
    NSArray *checksArr = @[];
    if(zcLibConvertToString(labels).length > 0){
        checksArr = [zcLibConvertToString(labels) componentsSeparatedByString:@","];
    }
    for (NSString *title in titles) {
        UIButton *titleBT= [UIButton buttonWithType:UIButtonTypeCustom];
        [titleBT setTitle:title forState:UIControlStateNormal];
        titleBT.layer.cornerRadius = 18.f;
        titleBT.layer.borderWidth = 0.75f;
        if([ZCUITools getZCThemeStyle] == ZCThemeStyle_Dark){
            titleBT.layer.borderColor = UIColorFromThemeColor(ZCBgSystemWhiteLightGrayColor).CGColor;
            [titleBT setTitleColor:UIColorFromThemeColor(ZCTextSubColor) forState:UIControlStateNormal];
            [titleBT setTitleColor:[ZCUITools zcgetTopViewTextColor] forState:UIControlStateHighlighted];
            [titleBT setTitleColor:[ZCUITools zcgetTopViewTextColor] forState:UIControlStateSelected];
        }else{
            titleBT.layer.borderColor = [UIColor whiteColor].CGColor;
            [titleBT setTitleColor:[ZCUITools zcgetCommentPageButtonTextColor] forState:UIControlStateNormal];
            [titleBT setTitleColor:UIColorFromThemeColor(ZCKeepWhiteColor) forState:UIControlStateHighlighted];
            [titleBT setTitleColor:UIColorFromThemeColor(ZCKeepWhiteColor) forState:UIControlStateSelected];
        }
        titleBT.layer.masksToBounds=YES;
        [titleBT.titleLabel setFont:ZCUIFont14];
        
//        [titleBT setBackgroundImage:[ZCUIImageTools zcimageWithColor:UIColorFromThemeColor(ZCBgLeftChatColor)] forState:UIControlStateNormal];
        [titleBT setBackgroundImage:[ZCUIImageTools zcimageWithColor:[ZCUITools zcgetCommentItemButtonBgColor]] forState:UIControlStateNormal];
        [titleBT setBackgroundImage:[ZCUIImageTools zcimageWithColor:[ZCUITools zcgetCommentItemSelButtonBgColor]] forState:UIControlStateSelected];
        [titleBT setBackgroundImage:[ZCUIImageTools zcimageWithColor:[ZCUITools zcgetCommentItemSelButtonBgColor]] forState:UIControlStateHighlighted];
        tagI = tagI + 1;
        titleBT.tag = tagI;
        [self  addSubview:titleBT];
        [titleBT addTarget:self action:@selector(Click:) forControlEvents:UIControlEventTouchUpInside];
        
        if(checksArr.count > 0 && [checksArr containsObject:title]){
            [self Click:titleBT];
        }
        
    }
}
-(void)Click:(UIButton *)bt{
 
    bt.selected = !bt.selected;
    
    if (bt.selected) {
        if([ZCUITools getZCThemeStyle] == ZCThemeStyle_Dark){
            bt.layer.borderColor = UIColorFromThemeColor(ZCBgSystemWhiteLightGrayColor).CGColor;
        }else{
            bt.layer.borderColor = [UIColor whiteColor].CGColor;
        }
    }else{
        if([ZCUITools getZCThemeStyle] == ZCThemeStyle_Dark){
            bt.layer.borderColor = UIColorFromThemeColor(ZCBgSystemWhiteLightGrayColor).CGColor;
        }else{
            bt.layer.borderColor = [UIColor whiteColor].CGColor;
        }
    }

    
}
-(NSString *)getSeletedTitle{
    
   __block NSString *title = @"";
    for(UIView *objV in self.subviews){
        int tag=(int)objV.tag;
        if(tag>100 && tag<=107 && [objV isKindOfClass:[UIButton class]]){
            UIButton *btn=(UIButton *)objV;
            if(btn.selected){
                if(title.length == 0){
                    title = btn.titleLabel.text;
                }else{
                    title=[NSString stringWithFormat:@"%@,%@",title,btn.titleLabel.text];
                }
            }
        }
    }
    
    return title;
    
}

@end
