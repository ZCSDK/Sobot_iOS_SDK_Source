//
//  ZCPageSheetView.m
//  SobotKit
//
//  Created by 张新耀 on 2019/9/4.
//  Copyright © 2019 zhichi. All rights reserved.
//

#import "ZCPageSheetView.h"
#import "ZCLibGlobalDefine.h"
#import "ZCUIColorsDefine.h"
#define BtnHeight 64

@interface ZCPageSheetView()<UIGestureRecognizerDelegate>{
    ZCPageSheetType showType;
}


@property (nonatomic, strong) UIView                  *sheetView;// 背景View(白色View)

@end

@implementation ZCPageSheetView

- (instancetype)initWithTitle:(NSString *)title superView:(UIView *)view showView:(UIView *)contentView type:(ZCPageSheetType)type{
    
    self = [super init];
    
    showType = type;
    
    if(showType == ZCPageSheetTypeLong){
    }
    
    self.userInteractionEnabled = YES;
    // 黑色遮盖
    self.frame = [UIScreen mainScreen].bounds;
//    self.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.3];
    self.backgroundColor = COLORWithAlpha(0, 0, 0, 0.3);
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(coverClick:)];
    tap.delegate = self;
    [self addGestureRecognizer:tap];
    [[[ZCToolsCore getToolsCore] getCurWindow] addSubview:self];
    self.autoresizesSubviews = YES;
    self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
    
    
    // sheet
    _sheetView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, ScreenHeight)];
    _sheetView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    
    
    [self addSubview:_sheetView];
    
    contentView.frame = _sheetView.bounds;
    contentView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleWidth;
    [_sheetView addSubview:contentView];
    
//    _sheetView.hidden = YES;
    _sheetView.userInteractionEnabled = YES;
    
    
    

    
    return self;
}




- (void)showSheet:(CGFloat)height animation:(BOOL)animation block:(nonnull void (^)())ShowBlock{
    self.sheetView.hidden = NO;
    
    CGRect sheetViewF = self.sheetView.frame;
    sheetViewF.origin.y = ScreenHeight;
    self.sheetView.frame = sheetViewF;
    
    CGRect newSheetViewF = self.sheetView.frame;
    newSheetViewF.origin.y = ScreenHeight - height;
    
    if(animation){
        [UIView animateWithDuration:0.3 animations:^{
            
            self.sheetView.frame = newSheetViewF;
            
            [self layoutSubviews];
            if(ShowBlock){
                ShowBlock();
            }
        }];
    }else{
        self.sheetView.frame = newSheetViewF;
        if(ShowBlock){
            ShowBlock();
        }
    }
}



- (void)coverClick:(UIGestureRecognizer *) gestap{
    CGPoint point = [gestap locationInView:self];
    CGRect f=self.sheetView.frame;
    if(point.x<f.origin.x || point.x>(f.origin.x+f.size.width) ||
       point.y<f.origin.y || point.y>(f.origin.y+f.size.height)){
        [self dissmisPageSheet];
    }
}

-(void)dissmisPageSheet{
    CGRect sheetViewF = self.sheetView.frame;
    sheetViewF.origin.y = ScreenHeight;
    
    [UIView animateWithDuration:0.2 animations:^{
        self.alpha = 0.0f;
        self.sheetView.frame = sheetViewF;
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
        [self.sheetView removeFromSuperview];
    }];
}

// button的点击事件
- (void)sheetBtnClick:(UIButton *)btn{
    if (btn.tag == 0) {
        [self dissmisPageSheet];
        return;
    }
}

- (UIImage*)createImageWithColor:(UIColor*)color
{
    CGRect rect=CGRectMake(0.0f, 0.0f, 1.0f, 1.0f);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    UIImage *theImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return theImage;
}


-(void)changePageSize:(CGFloat)height{
    self.sheetView.hidden = NO;
    
    CGRect sheetViewF = self.sheetView.frame;
    sheetViewF.origin.y = ScreenHeight;
    self.sheetView.frame = sheetViewF;
    
    CGRect newSheetViewF = self.sheetView.frame;
    newSheetViewF.origin.y = ScreenHeight - height;
    
    [UIView animateWithDuration:0.3 animations:^{
        
        self.sheetView.frame = newSheetViewF;
    }];
}

#pragma mark -- 手势冲突的代理
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    if ([touch.view isKindOfClass:[UIButton class]]  || [touch.view isKindOfClass:[UITableView class]]  ||[NSStringFromClass([touch.view class]) isEqualToString:@"UITableViewCellContentView"]) {
        //判断如果点击的是tableView的cell，就把手势给关闭了
        return NO;//关闭手势
    }
    //否则手势存在
    return YES;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
