//
//  ZCReplyFileView.m
//  SobotKit
//
//  Created by xuhan on 2019/12/9.
//  Copyright © 2019 zhichi. All rights reserved.
//

#import "ZCReplyFileView.h"
#import "ZCUIColorsDefine.h"
#import "ZCLibGlobalDefine.h"
//#import "ZCUIImageView.h"
#import "SobotImageView.h"

@interface ZCReplyFileView ()
@property (nonatomic, strong) NSDictionary *modelDic;
@property (nonatomic, strong) UIImageView *currentImgView;
@property (nonatomic, assign) BOOL isLoading;//是否是在加载中
@end

@implementation ZCReplyFileView

- (instancetype)initWithDic:(NSDictionary *)modelDic withFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if(self){
        self.modelDic = modelDic;
        
        [self creatView];
        
    }
    return self;
}

- (void)creatView {
    
    self.backgroundColor = UIColorFromThemeColor(ZCBgChatLightGrayColor);
    
    NSString *fileType = sobotConvertToString(self.modelDic[@"fileType"]);
    NSString *fileUrlStr = sobotConvertToString(self.modelDic[@"fileUrl"]);
    NSString *fileName = sobotConvertToString(self.modelDic[@"fileName"]);
    
    NSString *cellIndexStr = sobotConvertToString(self.modelDic[@"cellIndex"]);
    UIColor *titleColor;
    if (cellIndexStr.length > 0 && [cellIndexStr isEqualToString:@"0"]) {
        titleColor = UIColorFromThemeColor(ZCTextMainColor);
    }else{
        titleColor = UIColorFromThemeColor(ZCTextSubColor);
    }
//    NSLog(@"fileurlstr ===%@",fileUrlStr);
    fileUrlStr = sobotValidURLString(fileUrlStr);
    
    NSURL *fileUrl = [NSURL URLWithString:sobotUrlEncodedString(fileUrlStr)];
    
    NSString *iconImgStr;
    if ([fileType isEqualToString:@"xls"] || [fileType isEqualToString:@"xlsx"]) {
        iconImgStr = @"zcicon_file_excel_icon";
    }
    else if([fileType isEqualToString:@"mp3"]){
        iconImgStr = @"zcicon_file_mp3_icon";
    }
    else if([fileType isEqualToString:@"mp4"]){
        iconImgStr = @"zcicon_file_mp4_icon";
    }
    else if([fileType isEqualToString:@"pdf"]){
        iconImgStr = @"zcicon_file_pdf_icon";
    }
    else if([fileType isEqualToString:@"ppt"]){
        iconImgStr = @"zcicon_file_ppt_icon";
    }
    else if([fileType isEqualToString:@"txt"]){
        iconImgStr = @"zcicon_file_txt_icon";
    }
    else if([fileType isEqualToString:@"doc"] || [fileType isEqualToString:@"docx"]){
        iconImgStr = @"zcicon_file_word_icon";
    }
    else if([fileType isEqualToString:@"zip"]){
        iconImgStr = @"zcicon_file_zip_icon";
    }
    else{
        iconImgStr = @"zcicon_file_unknow_icon";
    }
    
    
//    NSData *imgData = [NSData dataWithContentsOfURL:fileUrl];
//    NSLog(@".......fileType...%@",fileType);
    if ([[fileType lowercaseString] isEqualToString:@"jpg"]
        || [[fileType lowercaseString] isEqualToString:@"png"]
        || [[fileType lowercaseString] isEqualToString:@"jpeg"]
        ||[[fileType lowercaseString] isEqualToString:@"gif"]) {
//       如果是 图片或者视频，直接显示
//        UIButton *imgButton = [[UIButton alloc]init];
//        imgButton.frame = self.frame;
//        [imgButton setImage:[UIImage imageWithData:imgData] forState:UIControlStateNormal];
        
        SobotImageView *imgView = [[SobotImageView alloc]initWithFrame:CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height)];
        [imgView setContentMode:UIViewContentModeScaleAspectFill];
        imgView.clipsToBounds = YES;
//        [imgView loadWithURL:fileUrl placeholer:nil];
        self.isLoading = YES;
        [imgView loadWithURL:fileUrl placeholer:nil showActivityIndicatorView:YES completionBlock:^(UIImage *image, NSURL *url, NSError *error) {
            if (image !=nil) {
                self.isLoading = NO;
            }
        }];
        [self addSubview:imgView];
        
        self.currentImgView = imgView;
        

        
    }else{
        float titleLabel_margin = 10;
          float titleLabel_margin_top = 7;
          float titleLabel_height = 34;
          
          UILabel *titleLabel = [[UILabel alloc]init];
          titleLabel.frame = CGRectMake(titleLabel_margin,
                                        titleLabel_margin_top,
                                        self.frame.size.width - titleLabel_margin * 2,
                                        titleLabel_height);
          
          titleLabel.text = fileName;
        titleLabel.numberOfLines = 2;
          titleLabel.font = ZCUIFont12;
          titleLabel.textColor = titleColor;
        
//        CGSize titleLabelSize = [fileName sizeWithAttributes:@{NSFontAttributeName:ZCUIFont12}];
        
        CGSize titleLabelSize = [fileName boundingRectWithSize:CGSizeMake(titleLabel.frame.size.width, MAXFLOAT)
                                                  options:NSStringDrawingUsesLineFragmentOrigin
                                               attributes:@{NSFontAttributeName:ZCUIFont12}
                                              context:nil].size;

        
        if (titleLabelSize.height < 20) {
            titleLabel.frame = CGRectMake(titleLabel_margin,
                                                   titleLabel_margin_top,
                                                   self.frame.size.width - titleLabel_margin * 2,
                                                   16);
        }
        
        
          [self addSubview:titleLabel];
          
          CGSize iconImgViewSize = CGSizeMake(17, 20);
          
          UIImageView *iconImgView = [[UIImageView alloc]init];
          iconImgView.frame = CGRectMake(titleLabel_margin,
                                         self.frame.size.height - iconImgViewSize.height - titleLabel_margin,
                                         iconImgViewSize.width,
                                         iconImgViewSize.height);
//          iconImgView.backgroundColor = [UIColor grayColor];
        
        iconImgView.image = [ZCUITools zcuiGetBundleImage:iconImgStr];
        [self addSubview:iconImgView];

//
        float tipsLabel_margin_left = 15;
        float tipsLabel_margin_bottom = 10;
        CGSize tipsLabelSize = CGSizeMake(25, 20);
        
        UILabel *tipsLabel = [[UILabel alloc]init];
        tipsLabel.frame = CGRectMake(self.frame.size.width - tipsLabelSize.width - tipsLabel_margin_left, self.frame.size.height - tipsLabelSize.height - tipsLabel_margin_bottom, tipsLabelSize.width, tipsLabelSize.height);
        tipsLabel.text = ZCSTLocalString(@"查看");
        tipsLabel.textAlignment = NSTextAlignmentRight;
        tipsLabel.font = ZCUIFont12;
        tipsLabel.textColor = UIColorFromThemeColor(ZCTextPlaceHolderColor);;
        [self addSubview:tipsLabel];
        
        
        CGSize arrowIconSize = CGSizeMake(5, 8);

        UIImageView *arrowIcon = [[UIImageView alloc]init];
        arrowIcon.frame = CGRectMake(CGRectGetMaxX(tipsLabel.frame) + 1, tipsLabel.frame.origin.y + 6, arrowIconSize.width, arrowIconSize.height);
        arrowIcon.image = [ZCUITools zcuiGetBundleImage:@"zcicon_arrow_reply"];
        [self addSubview:arrowIcon];

        
    }
    
    UIButton *button = [[UIButton alloc]init];
    button.frame = CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height);
    button.backgroundColor = [UIColor clearColor];
    [button addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
    button.tag = self.viewTag;
    [self addSubview:button];
}

- (void)buttonClick:(UIButton *)button{
    if (self.isLoading) {
//        [[ZCUIToastTools shareToast] showToast:ZCSTLocalString(@"加载中    ") duration:2.0f view: [UIApplication sharedApplication].keyWindow position:ZCToastPositionCenter];
        return;
    }
    if (self.clickBlock) {
        self.clickBlock(self.modelDic,self.currentImgView);
    }
    
}



@end
