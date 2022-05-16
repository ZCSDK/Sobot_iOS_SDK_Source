//
//  ZCQuickEntryView.m
//  SobotKit
//
//  Created by lizhihui on 2018/5/25.
//  Copyright © 2018年 zhichi. All rights reserved.
//

#import "ZCQuickEntryView.h"
#import "ZCLibGlobalDefine.h"
#import "ZCUIColorsDefine.h"
#import "ZCPlatformTools.h"
#import "ZCUIKeyboard.h"
#import "ZCUIImageTools.h"
@interface ZCQuickEntryView(){
    CGFloat viewWidth;
    CGFloat viewHeight;
    NSMutableArray * listArray;
    ZCUIKeyboard * _keyboardView;
    UIScrollView * _scrollView;
}

@end
@implementation ZCQuickEntryView

-(ZCQuickEntryView *)initCustomViewWith:(NSMutableArray *)array WithView:(UIView *)view{
    self = [super init];
    if (self) {
        viewWidth = view.frame.size.width;
        viewHeight = view.frame.size.height;
        listArray = array;
        
        if (!listArray) {
            listArray = [NSMutableArray array];
        }
        
        self.frame = CGRectMake(0, 0, viewWidth, 50);
//        self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        self.autoresizesSubviews = YES;
        
        [self createSubviews];
    }
    
    return  self;
}

-(void)setFrame:(CGRect)frame{
    [super setFrame:frame];
    [_scrollView setContentInset:UIEdgeInsetsMake(0, 0, 0, 0)];
    NSString *version = [UIDevice currentDevice].systemVersion;
      if (version.doubleValue >= 11.0) {
         if([UIApplication sharedApplication].statusBarOrientation == UIInterfaceOrientationLandscapeRight){
             [_scrollView setContentInset:UIEdgeInsetsMake(0, XBottomBarHeight, 0, 0)];
          }
      }
    
}

-(void)createSubviews{
    
    _scrollView = [[UIScrollView alloc]initWithFrame:CGRectMake(0, 0, viewWidth, 50)];
    _scrollView.showsHorizontalScrollIndicator = NO;
    _scrollView.bounces = NO;
//    _scrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    _scrollView.backgroundColor = UIColorFromThemeColor(ZCBgSystemWhiteColor);
    [self addSubview:_scrollView];
    
    
    CGFloat x = 10;
    for (int i = 0; i< listArray.count; i++) {
        UIButton * itemBtn = [self addItemView:listArray[i] withX:x withY:10 withW:60 withH:30];
//        [itemBtn setBackgroundColor:UIColorFromRGB(0xffffff)];
        itemBtn.userInteractionEnabled = YES;
        itemBtn.tag = i;
        [itemBtn addTarget:self action:@selector(itemClick:) forControlEvents:UIControlEventTouchUpInside];
        itemBtn.layer.borderWidth = 0.5;
//        itemBtn.layer.borderColor = UIColorFromRGB(TextUnPlaceHolderColor).CGColor;
        x = x + CGRectGetWidth(itemBtn.frame) + 10;
        
        [_scrollView addSubview:itemBtn];
    }
    [_scrollView setContentSize:CGSizeMake(x, 50)];
    
}


-(UIButton*)addItemView:(ZCLibCusMenu *)model withX:(CGFloat)x withY:(CGFloat) y withW:(CGFloat)w withH:(CGFloat)h{
    UIButton *itemView = [[UIButton alloc] initWithFrame:CGRectMake(x, y, w,h)];
    [itemView setFrame:CGRectMake(x, y, w, h)];

    itemView.titleLabel.numberOfLines = 1;
    itemView.titleLabel.font = ZCUIFont12;
//    NSLog(@"%@",model.title);
    [itemView setTitle:sobotConvertToString(model.title) forState:UIControlStateNormal];
    [itemView setTitle:sobotConvertToString(model.title) forState:UIControlStateHighlighted];
    itemView.titleLabel.textAlignment = NSTextAlignmentCenter;
    [itemView setBackgroundColor:UIColorFromThemeColor(ZCBgSystemWhiteLightGrayColor)];
    [itemView setTitleColor:UIColorFromThemeColor(ZCTextMainColor) forState:UIControlStateNormal];
    [itemView setTitleColor:UIColorFromThemeColor(ZCTextMainColor) forState:UIControlStateHighlighted];
    itemView.layer.masksToBounds = YES;
    itemView.layer.cornerRadius = 15.0f;
    itemView.layer.borderWidth = 0.5;
    itemView.layer.borderColor = [ZCUITools zcgetCommentButtonLineColor].CGColor;
    [itemView sizeToFit];
//    itemView.titleEdgeInsets = UIEdgeInsetsMake(5, 15, 5, 15);
    CGRect itemViewF = itemView.frame;
    itemViewF.size.width = itemViewF.size.width + 30;
    itemViewF.size.height = itemViewF.size.height + 4;
    itemView.frame = itemViewF;
    
    return itemView;
}

- (void)showInView:(UIView *)view{
    [view addSubview:self];
    // 如果技能组先出现，为遮挡技能组的显示
//    [self insertSubview:_quickEntryView aboveSubview:_listTable];
}

- (void)tappedCancel:(BOOL) isClose{
    
}

-(void)itemClick:(UIButton *)sender{
//    UIButton * btn = (UIButton*)sender;
//    NSLog(@"%@",btn.titleLabel.text);
    if (_quickClickBlock) {
        _quickClickBlock(listArray[sender.tag]);
    }
}

@end
