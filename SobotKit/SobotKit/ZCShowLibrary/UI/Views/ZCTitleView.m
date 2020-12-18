//
//  ZCTitleView.m
//  SobotKit
//
//  Created by 张新耀 on 2019/9/2.
//  Copyright © 2019 zhichi. All rights reserved.
//

#import "ZCTitleView.h"
#import "ZCLibGlobalDefine.h"
#import "ZCUIXHImageViewer.h"
#import "ZCUIImageView.h"
#import "ZCUIImageTools.h"
#import "ZCLibClient.h"

#define ImgWidth 38

@interface ZCTitleView(){
    CGFloat lastSize;
    CGFloat maxWidth;
}


@property(nonatomic,strong) UILabel *labTitle;
@property(nonatomic,strong) ZCUIImageView *imgAvatar;

@end

@implementation ZCTitleView


-(instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        self.frame = frame;
        self.userInteractionEnabled = YES;
        self.backgroundColor = UIColor.clearColor;
        [self layoutTitleUI];
        
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self layoutTitleUI];
    }
    return self;
}



-(void) layoutTitleUI{
    if(!_labTitle){
        CGRect f = self.frame;
        maxWidth = f.size.width;
//        f.origin.x = 180;
//        maxWidth = ScreenWidth - 160;
//        f.size.height = 44;
//        self.frame = f;
        lastSize = f.size.width;
        
        _labTitle = [[UILabel alloc] init];
        [_labTitle setBackgroundColor:UIColor.clearColor];
        [_labTitle setTextAlignment:NSTextAlignmentCenter];
        [_labTitle setFont:[ZCUITools zcgetTitleFont]];
        [_labTitle setTextColor:[ZCUITools zcgetTopViewTextColor]];
        [_labTitle setAutoresizingMask:UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleWidth];
        
        _labTitle.numberOfLines = 1;
        [self addSubview:_labTitle];
        
        
        _imgAvatar = [[ZCUIImageView alloc] init];
        [_imgAvatar setContentMode:UIViewContentModeScaleAspectFill];
        [_imgAvatar setFrame:CGRectMake(0, self.bounds.size.height/2 - ImgWidth/2, ImgWidth, ImgWidth)];
        [_imgAvatar setBackgroundColor:[UIColor clearColor]];
        _imgAvatar.layer.cornerRadius= ImgWidth/2;
        _imgAvatar.layer.masksToBounds=YES;
        _imgAvatar.layer.borderWidth = 0.5f;
        _imgAvatar.layer.borderColor = [ZCUITools zcgetBackgroundColor].CGColor;
        [self addSubview:_imgAvatar];
        _imgAvatar.hidden = YES;
        
    }
}

-(void)setTitle:(NSString *)title image:(NSString *)imageUrl{
    _labTitle.hidden = NO;
    _imgAvatar.hidden = NO;
    if(_labTitle){
        if(zcLibConvertToString(title).length > 0){
            [_labTitle setText:zcLibConvertToString(title)];
        }else{
            _labTitle.hidden = YES;
        }
        
        if(zcLibConvertToString(imageUrl).length > 0){
            UIImage *img = [ZCUITools zcuiGetBundleImage:imageUrl];
            if(img){
                [_imgAvatar setImage:img];
            }else{
                [_imgAvatar loadWithURL:[NSURL URLWithString:zcLibConvertToString(imageUrl)]];
            }
        }else{
            _imgAvatar.hidden = YES;
        }
    }
    
    [self centerTitleView];
}

-(void)centerTitleView{
    if(self.imgAvatar.isHidden){
        self.labTitle.frame = self.bounds;
        self.labTitle.center = CGPointMake(self.bounds.size.width/2, self.bounds.size.height/2);
    }else if(_labTitle.isHidden){
        self.imgAvatar.center = CGPointMake(self.bounds.size.width/2, self.bounds.size.height/2);
    }else{
        CGSize s =[self.labTitle sizeThatFits:CGSizeMake(_labTitle.bounds.size.width, NavBarHeight)];
        
        CGRect titleF = self.labTitle.frame;
        CGRect imgF   = self.imgAvatar.frame;
        
        titleF.size.height = self.frame.size.height;
        titleF.origin.y = 0;
        
        imgF.origin.y = self.frame.size.height/2 - ImgWidth/2;
        
        if(s.width > 0 && s.width > (self.bounds.size.width - ImgWidth)){
            titleF.origin.x = ImgWidth;
            titleF.size.width = self.bounds.size.width - ImgWidth;
            
            imgF.origin.x = 0;
        }else{
            imgF.origin.x = (self.bounds.size.width - ImgWidth - s.width)/2;
            
            titleF.origin.x = imgF.origin.x + ImgWidth;
            titleF.size.width = s.width;
        }
        self.labTitle.frame = titleF;
        self.imgAvatar.frame = imgF;

    }
}

// 监听暗黑模式变化
-(void)traitCollectionDidChange:(UITraitCollection *)previousTraitCollection{
    [super traitCollectionDidChange:previousTraitCollection];
    if(zcGetSystemDoubleVersion()>=13){
        // trait发生了改变
        if ([self.traitCollection hasDifferentColorAppearanceComparedToTraitCollection:previousTraitCollection]) {
            // 执行操作
            _imgAvatar.layer.borderColor = [ZCUITools zcgetBackgroundColor].CGColor;
        }
    }
}


-(void)layoutSubviews{
    [super layoutSubviews];
    if(lastSize != self.frame.size.width){
        maxWidth = self.frame.size.width;
        lastSize = maxWidth;
        
        CGRect f = self.frame;
        f.size.width = maxWidth;
        
        self.frame = f;
        [self centerTitleView];
    }
}
@end
