//
//  RatingViewController.m
//  RatingController
//
//  Created by Ajay on 2/28/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "ZCUIRatingView.h"
#import "ZCUIColorsDefine.h"
#import "ZCLibGlobalDefine.h"
@interface ZCUIRatingView()

//@property (nonatomic ,strong)
@end
@implementation ZCUIRatingView

-(void)setImagesDeselected:(NSString *)unselectedImage partlySelected:(NSString *)partlySelectedImage fullSelected:(NSString *)fullSelectedImage andDelegate:(id<RatingViewDelegate>)d{
    [self setImagesDeselected:unselectedImage partlySelected:partlySelectedImage fullSelected:fullSelectedImage count:5 andDelegate:d];
}

-(void)setImagesDeselected:(NSString *)deselectedImage
			partlySelected:(NSString *)halfSelectedImage
			  fullSelected:(NSString *)fullSelectedImage
                     count:(int)count andDelegate:(id<RatingViewDelegate>)d{
    unselectedImage = [ZCUITools zcuiGetBundleImage:deselectedImage];// [UIImage imageNamed:deselectedImage];
    partlySelectedImage =  halfSelectedImage == nil ? unselectedImage : [ZCUITools zcuiGetBundleImage:halfSelectedImage]; //[UIImage imageNamed:halfSelectedImage];
    fullySelectedImage = [ZCUITools zcuiGetBundleImage:fullSelectedImage]; //[UIImage imageNamed:fullSelectedImage];
	viewDelegate = d;
	
	height= 29;
    if(height > self.frame.size.height){
        height = self.frame.size.height;
    }
    _starView = [[NSMutableArray alloc] init];
    starRating = 0;
    lastRating = 0;
    CGFloat space = 0;
    CGFloat y = 0;
    if(count > 5){
        // 增加0
        count = count + 1;
        UILabel *lab1 = [self createLabel:0 title:ZCSTLocalString(@"非常不满意")];
        UILabel *lab2 = [self createLabel:self.frame.size.width/2 title:ZCSTLocalString(@"非常满意")];
        [self addSubview:lab1];
        [self addSubview:lab2];
        [lab2 setTextAlignment:NSTextAlignmentRight];
        y = 25;
        space =  5;
    }
    
    width=  self.frame.size.width/count;
    for (int i=1; i<=count; i++) {
        UIView *ss = nil;
        if(count > 5){
            ss = [self createLabel:(i-1)*width title:[NSString stringWithFormat:@"%d",i - 1]];
            [ss setFrame:CGRectMake((i-1)*width, y, width-5, height)];
            [ss setBackgroundColor:UIColorFromThemeColor(ZCBgSystemWhiteColor)];
            [(UILabel *)ss setTextColor:[ZCUITools getNotifitionTopViewLabelColor]];
            ((UILabel *)ss).layer.cornerRadius = 4;
            ((UILabel *)ss).layer.borderColor = UIColorFromThemeColor(ZCBgLineColor).CGColor;
            ((UILabel *)ss).layer.borderWidth = 1.0f;
            ((UILabel *)ss).textAlignment = NSTextAlignmentCenter;
            ((UILabel *)ss).layer.masksToBounds = YES;
            ((UILabel *)ss).font = [ZCUITools zcgetKitChatFont];
        }else{
            ss = [[UIImageView alloc] initWithImage:unselectedImage];
            [ss setContentMode:UIViewContentModeScaleAspectFit];
            [ss setFrame:CGRectMake((i-1)*width,         y, width, height)];
        }
        
        [ss setUserInteractionEnabled:YES];
        ss.tag = 100+i;
        
        UITapGestureRecognizer * tap1 = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapAction:)];
        
        [ss addGestureRecognizer:tap1];
        [self addSubview:ss];
        [_starView addObject:ss];
    }
    
    
	CGRect frame = [self frame];
	frame.size.width = width * count;
	frame.size.height = height + y;
	[self setFrame:frame];
}

-(void)displayRating:(float)rating {
    for (UIView *ss in _starView) {
        int index = (int)ss.tag - 100;
        
        if([ss isKindOfClass:[UIImageView class]]){
            
            if(index<=rating){
                [(UIImageView *)ss setImage:fullySelectedImage];
            }else{
                [(UIImageView *)ss setImage:unselectedImage];
            }
        }else{
            
            if(index<=rating){
                ((UILabel *)ss).layer.borderColor = [UIColor clearColor].CGColor;
                ((UILabel *)ss).layer.borderWidth = 0;
                [ss setBackgroundColor:UIColorFromThemeColor(ZCRatingBGColor)];
                [(UILabel *)ss setTextColor:UIColorFromThemeColor(ZCBgSystemWhiteColor)];
            }else{
                
                [(UILabel *)ss setTextColor:UIColorFromThemeColor(ZCTextMainColor)];
                [ss setBackgroundColor:UIColorFromThemeColor(ZCBgSystemWhiteColor)];
                ((UILabel *)ss).layer.borderColor = UIColorFromThemeColor(ZCBgLineColor).CGColor;;
                ((UILabel *)ss).layer.borderWidth = 1;
            }
        }
        
        // 0.5分情况不考虑
//        if((rating*10)%5){
//[ss setImage:partlySelectedImage];
//        }
    }
	
	
	starRating = rating;
	lastRating = rating;
	[viewDelegate ratingChanged:rating];
}

//-(void) touchesBegan: (NSSet *)touches withEvent: (UIEvent *)event
//{
//    [super touchesBegan:touches withEvent:event];
//	[self touchesMoved:touches withEvent:event];
//}
//
//-(void) touchesMoved: (NSSet *)touches withEvent: (UIEvent *)event
//{
//    [super touchesMoved:touches withEvent:event];
//    
//	CGPoint pt = [[touches anyObject] locationInView:self];
//	int newRating = (int) (pt.x / width) + 1;
//	if (newRating < 1 || newRating > 5)
//		return;
//	
//	if (newRating != lastRating)
//    {
//        [self displayRating:newRating];
//    }else{
//        [self displayRating:newRating-1];
//    }
//}
//
//-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
//    [super touchesEnded:touches withEvent:event];
//	[self touchesMoved:touches withEvent:event];
//}

- (void)tapAction:(UITapGestureRecognizer*)tap{
    [self displayRating:tap.view.tag-100];
    if(viewDelegate && [viewDelegate respondsToSelector:@selector(ratingChangedWithTap:)]){
        [viewDelegate ratingChangedWithTap:tap.view.tag-100];
    }
    
}


-(float)rating {
	return starRating;
}


-(UILabel *)createLabel:(CGFloat ) x title:(NSString *) text{
    UILabel *lab = [[UILabel alloc] initWithFrame:CGRectMake(x, 0, self.frame.size.width/2, 20)];
    [lab setTextColor:UIColorFromThemeColor(ZCTextSubColor)];
    [lab setText:text];
    [lab setFont:[ZCUITools zcgetListKitDetailFont]];
    return lab;
}
@end
