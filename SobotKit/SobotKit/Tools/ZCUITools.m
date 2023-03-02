//
//  ZCUITools.m
//  SobotKit
//
//  Created by zhangxy on 15/11/11.
//  Copyright © 2015年 zhichi. All rights reserved.
//

#import "ZCUITools.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import <AVFoundation/AVFoundation.h>
#import "zcuiColorsDefine.h"
#import "ZCLibGlobalDefine.h"
#import "ZCStoreConfiguration.h"
#import "ZCUICore.h"
#import <Photos/Photos.h>

@implementation ZCUITools

+(ZCThemeStyle ) getZCThemeStyle{
    if([ZCUICore getUICore].kitInfo.themeStyle > 0){
        return  [ZCUICore getUICore].kitInfo.themeStyle;
    }
    
    if(sobotGetSystemDoubleVersion()>=13){
        if (UITraitCollection.currentTraitCollection.userInterfaceStyle == UIUserInterfaceStyleDark) {
            return ZCThemeStyle_Dark;
        }
        return ZCThemeStyle_Default;
    }
    return  [ZCUICore getUICore].kitInfo.themeStyle;
}

// 暗黑模式时，是否使用自定义颜色
+(BOOL) useDefaultThemeColor{
    if([self getZCKitInfo]!=nil && [self getZCThemeStyle] == ZCThemeStyle_Dark && [self getZCKitInfo].useDefaultDarkTheme){
        return YES;
    }
    return NO;
}


+(void)zcModelStringToAttributeString:(id) model{
    ZCLibMessage *temModel = model;
    if(![temModel isKindOfClass:[ZCLibMessage class]]){
        return;
    }
    
    /*
    if(sobotConvertToString([temModel getModelDisplayText]).length > 0){
        [ZCUITools attributedStringByHTML:[temModel getModelDisplayText] textColor:textColor linkColor:linkColor result:^(NSMutableAttributedString *attr) {
            temModel.displayAttr = attr;
        }];
    }
     */
    
    if(sobotConvertToString([temModel getModelDisplaySugestionText]).length > 0  && temModel.displaySugestionattr==nil){
        UIColor *textColor = [ZCUITools zcgetRightChatTextColor];
        UIColor *linkColor = [ZCUITools zcgetChatRightlinkColor];
        if(temModel.senderType > 0){
            textColor = [ZCUITools zcgetLeftChatTextColor];
            linkColor = [ZCUITools zcgetChatLeftLinkColor];
        }
        [ZCUITools attributedStringByHTML:[temModel getModelDisplaySugestionText] textColor:textColor linkColor:linkColor result:^(NSMutableAttributedString *attr,NSString *htmlText) {
            NSMutableParagraphStyle * paragraphStyle = [[NSMutableParagraphStyle alloc] init];
            [paragraphStyle setLineSpacing:12.0];
            [attr addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, [attr length])];

            temModel.displaySugestionattr = attr;
        }];
    }
}



//过滤html标签
+(NSString *)removeAllHTMLTag:(NSString *)html {
    NSScanner *theScanner;
    
    NSString *text = nil;
    
    theScanner = [NSScanner scannerWithString:html];
    
    while ([theScanner isAtEnd] == NO) {
        
        // find start of tag
        [theScanner scanUpToString:@"<" intoString:NULL] ;
        
        // find end of tag
        [theScanner scanUpToString:@">" intoString:&text] ;
        
        
        // replace the found tag with a space
        //(you can filter multi-spaces out later if you wish)
        if([[NSString stringWithFormat:@"%@>", text] hasSuffix:@"/p>"]){
            html = [html stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"%@>", text] withString:@"\n"];
        }else{
            html = [html stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"%@>", text] withString:@""];
        }
    }
    return html;
}


+(void) attributedStringByHTML:(NSString *)html textColor:(UIColor *) textColor linkColor:(UIColor *) linkColor result:(void (^)(NSMutableAttributedString *,NSString *htmlText))attrBlock
{
    if (!html || [html isKindOfClass:[NSString class]] == NO)
    {
      html = @"";
    }
    
    UIFont *font  = [ZCUITools zcgetKitChatFont];
    if (!font || [font isKindOfClass:[UIFont class]] == NO)
    {
        font = [UIFont systemFontOfSize:[UIFont systemFontSize]];
    }



    html = [html stringByReplacingOccurrencesOfString:@"\n" withString:@"<br/>"];
    if(linkColor && textColor){
        NSString *linkHexColor = [self getHexStringByColor:linkColor];
        NSString *textHexColor = [self getHexStringByColor:textColor];
        html = [NSString stringWithFormat:@"<html><head><style>body{ font-family:'%@'; font-size:%fpx;color:%@; margin:0px; padding:0px;}a{color:%@} a:hover{color:%@}</style></head><body>%@</body></html>", font.fontName, font.pointSize,textHexColor,linkHexColor,linkHexColor,html];
    }else{
        html = [NSString stringWithFormat:@"<html><head><style>body{ font-family:'%@'; font-size:%fpx; margin:0px; padding:0px;}</style></head><body>%@</body></html>", font.fontName, font.pointSize,html];
    }
    
//    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
////        NSDictionary * documentAttributes = nil;
        NSError      * error = nil;
        NSMutableAttributedString * string = [[NSMutableAttributedString alloc] initWithData:[html dataUsingEncoding:NSUTF8StringEncoding] options:@{
            NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType,
            NSCharacterEncodingDocumentAttribute: @(NSUTF8StringEncoding)} documentAttributes:nil error:&error];
//        dispatch_async(dispatch_get_main_queue(), ^{
            attrBlock((string && [string isKindOfClass:[NSMutableAttributedString class]]) ? string : nil,html);
//        });
//    });
}

+(NSString *) getHexStringByColor:(UIColor *) color{
    CGFloat r, g, b, a;
    [color getRed:&r green:&g blue:&b alpha:&a];
    int rgb = (int)(r * 255.0f)<<16 | (int)(g * 255.0f)<<8 | (int)(b * 255.0f)<<0;

    return [NSString stringWithFormat:@"%06x", rgb];
}


+(NSDictionary *) getZCThemeColors:(ZCThemeStyle) themeStyle{
    //    NSString *filePath =  [[NSBundle mainBundle] pathForResource:@"ZCEmojiExpression.bundle/expression.json" ofType:nil];
    NSString *strReource = [[NSBundle mainBundle] pathForResource:@"SobotKit" ofType:@"bundle"];
    
    NSString *filePath = [[NSBundle bundleWithPath:strReource] pathForResource:@"colors.stringsdict" ofType:nil inDirectory:nil];
    
    if(filePath==nil){
        return nil;
    }
    
    
    //格式化成json数据
    NSDictionary *dict= [[NSDictionary alloc] initWithContentsOfFile:filePath];
//    if(dict == nil){
//        return nil;
//    }
//    switch(themeStyle){
//        case ZCThemeStyle_Dark:
//            return dict[@"dark"];
//            break;
//        default:
//            return dict[@"light"];
//            break;
//
//    }
//    return dict[@"light"];
    return dict;
}

+(UIColor *)getZCThemeColorByKey:(NSString *)themeColorKey{
    return [self getZCThemeColorAlphaByKey:themeColorKey alpha:1.0f];
}

+(UIColor *)getZCThemeColorAlphaByKey:(NSString *)themeColorKey alpha:(CGFloat) alpha{
    UIColor *dyColor = nil;
    if(sobotGetSystemDoubleVersion()>=13){
        dyColor = [UIColor colorWithDynamicProvider:^UIColor * _Nonnull(UITraitCollection * _Nonnull trainCollection) {
            NSString *style = @"light";
            switch([self getZCThemeStyle]){
                case ZCThemeStyle_Dark:
                    style = @"dark";
                    break;
                default:
                    style = @"light";
                    break;
        
            }
            NSDictionary *dict = [[ZCUICore getUICore] getZCThemeColorDict:style];
            NSString *hexColor = dict[themeColorKey];
            if(sobotConvertToString(hexColor).length == 0){
                dict = [[ZCUICore getUICore] getZCThemeColorDict:@"light"];
                hexColor = dict[themeColorKey];
            }
            return [ZCUITools getZCColorByHexAlpha:hexColor alpha:alpha];
        }];
    }else{
        NSString *style = @"light";
        switch([self getZCThemeStyle]){
            case ZCThemeStyle_Dark:
                style = @"dark";
                break;
            default:
                style = @"light";
                break;
    
        }
        NSDictionary *dict = [[ZCUICore getUICore] getZCThemeColorDict:style];
        NSString *hexColor = dict[themeColorKey];
        if(sobotConvertToString(hexColor).length > 0){
            dyColor = [ZCUITools getZCColorByHexAlpha:hexColor alpha:alpha];
        }
    }
    return dyColor;
}


+ (UIColor *)getZCColorByHexAlpha:(NSString *)hexColor alpha:(CGFloat) alpha
{
    if(hexColor!=nil && hexColor.length>6){
        hexColor=[hexColor stringByReplacingOccurrencesOfString:@"#" withString:@""];
    }
    if(sobotConvertToString(hexColor).length<6){
        int len = 6 - (int)sobotConvertToString(hexColor).length;
        for (int i = 0; i < len; i++) {
            hexColor = [NSString stringWithFormat:@"%@0",sobotConvertToString(hexColor)];
        }
    }
    
    unsigned int red,green,blue;
    NSRange range;
    range.length = 2;
    range.location = 0;
    
    [[NSScanner scannerWithString:[hexColor substringWithRange:range]] scanHexInt:&red];
    
    range.location = 2;
    [[NSScanner scannerWithString:[hexColor substringWithRange:range]] scanHexInt:&green];
    
    range.location = 4;
    [[NSScanner scannerWithString:[hexColor substringWithRange:range]] scanHexInt:&blue];
    
    return [UIColor colorWithRed:(float)(red/255.0f) green:(float)(green / 255.0f) blue:(float)(blue / 255.0f) alpha:alpha];
}



+(UIImage *)zcuiGetBundleImage:(NSString *)imageName{
    if(sobotConvertToString(imageName).length == 0){
        return nil;
    }
    //    NSString *bundlePath=[self zcuiFullBundlePath:imageName];
    //    return [UIImage imageWithContentsOfFile:bundlePath];
    UIImage *defineImg = [UIImage imageNamed:imageName];
    if (defineImg) {
        return defineImg;
    }
    
    // uni-app 可能使用
    if([ZCLibClient getZCLibClient].libInitInfo
       !=nil && sobotConvertToString([ZCLibClient getZCLibClient].libInitInfo.wwwStaticPath).length > 0){
        defineImg = [UIImage imageWithContentsOfFile:[sobotConvertToString([ZCLibClient getZCLibClient].libInitInfo.wwwStaticPath) stringByAppendingFormat:@"%@",imageName]];
        if (defineImg) {
            return defineImg;
        }
    }
    
    if([self getZCKitInfo].isUseImagesxcassets){
        if(![imageName hasSuffix:@".png"]){
            imageName = [imageName stringByAppendingString:@".png"];
        }
    }
    if([self getZCThemeStyle] == ZCThemeStyle_Dark){
        UIImage *defineImg = [self checkDarkImage:imageName];
        if(defineImg!=nil){
            return defineImg;
            
        }
    }
    
    NSString *bundlePath = [[NSBundle mainBundle].resourcePath stringByAppendingPathComponent:@"SobotKit.bundle"];
    
    
    NSString *img_path = [[NSBundle bundleWithPath:bundlePath] pathForResource:imageName ofType:@"png"];
    UIImage *img = [UIImage imageWithContentsOfFile:img_path];
    
    //    NSString *bundleName=[NSString stringWithFormat:@"SobotKit.bundle/%@",imageName];
    //    UIImage *img = [UIImage imageNamed:bundleName];
    
    if(img){
        return img;
    }else{
        NSString *bundleName=[NSString stringWithFormat:@"SobotKit.bundle/%@",imageName];
//        NSBundle *bundletest = [NSBundle bundleForClass:self.class];
        NSBundle *bundletest = [NSBundle mainBundle];
        img = [UIImage imageNamed:bundleName inBundle:bundletest compatibleWithTraitCollection:nil];
    }
    
    if (!img) {
        return [UIImage imageNamed:imageName];
    }else {
        return img;
    }
}

+(UIImage *) checkDarkImage:(NSString *) imageName{
    NSString *bundlePath = [[NSBundle mainBundle].resourcePath stringByAppendingPathComponent:@"SobotKit.bundle/dark"];
    imageName = [imageName stringByAppendingString:@"_dark"];
    
    NSString *img_path = [[NSBundle bundleWithPath:bundlePath] pathForResource:imageName ofType:@"png"];
    UIImage *img = [UIImage imageWithContentsOfFile:img_path];
    
    //    NSString *bundleName=[NSString stringWithFormat:@"SobotKit.bundle/%@",imageName];
    //    UIImage *img = [UIImage imageNamed:bundleName];
    
    if(img){
        return img;
    }else{
        NSString *bundleName=[NSString stringWithFormat:@"SobotKit.bundle/dark/%@",imageName];
//        NSBundle *bundletest = [NSBundle bundleForClass:self.class];
        NSBundle *bundletest = [NSBundle mainBundle];
        img = [UIImage imageNamed:bundleName inBundle:bundletest compatibleWithTraitCollection:nil];
    }
    
    if (!img) {
        return [UIImage imageNamed:imageName];
    }else {
        return img;
    }
}

+(UIImage *)zcuiGetExpressionBundleImage:(NSString *)imageName{
    //    NSString *bundlePath=[self zcuiFullBundlePath:imageName];
    //    return [UIImage imageWithContentsOfFile:bundlePath];
    if(imageName == nil){
        return nil;
    }
    if([self getZCKitInfo].isUseImagesxcassets){
        if(![imageName hasSuffix:@".png"]){
            imageName = [imageName stringByAppendingString:@".png"];
        }
    }
    
    
    //    NSString *strReource = [[NSBundle mainBundle] pathForResource:@"SobotKit" ofType:@"bundle"];
    //    NSString *bundleName = [[NSBundle bundleWithPath:strReource] pathForResource:imageName ofType:nil inDirectory:@"emoji"];
    //    UIImage *img = [UIImage imageNamed:bundleName];
    
    NSString * path = [NSBundle.mainBundle pathForResource:[NSString stringWithFormat:@"SobotKit.bundle/emoji/%@",imageName] ofType:nil];
    UIImage * img = [UIImage imageWithContentsOfFile:path];
    
    if(img){
        return img;
    }else{
        NSString *strReource = [[NSBundle mainBundle] pathForResource:@"SobotKit" ofType:@"bundle"];
        NSString *bundleName = [[NSBundle bundleWithPath:strReource] pathForResource:imageName ofType:nil inDirectory:@"emoji"];
        
//        NSBundle *bundletest = [NSBundle bundleForClass:self.class];
        NSBundle *bundletest = [NSBundle mainBundle];
        return [UIImage imageNamed:bundleName inBundle:bundletest compatibleWithTraitCollection:nil];
    }
}


+ (NSArray *)allExpressionArray {
    //    NSString *filePath =  [[NSBundle mainBundle] pathForResource:@"ZCEmojiExpression.bundle/expression.json" ofType:nil];
    NSString *strReource = [[NSBundle mainBundle] pathForResource:@"SobotKit" ofType:@"bundle"];
    
    NSString * lanStr  = [[[NSUserDefaults standardUserDefaults] objectForKey:@"AppleLanguages"] objectAtIndex:0];
    
    NSString *filePath;
    if ([lanStr hasPrefix:@"zh-Hans"]){
        filePath = [[NSBundle bundleWithPath:strReource] pathForResource:@"expression.json" ofType:nil inDirectory:@"emoji"];
    }else{
        filePath = [[NSBundle bundleWithPath:strReource] pathForResource:@"expression_en.json" ofType:nil inDirectory:@"emoji"];
    }

    if(filePath==nil){
        return nil;
    }
    //根据文件路径读取数据
    NSData *jdata = [[NSData alloc]initWithContentsOfFile:filePath];
    if(jdata == nil){
        return nil;
    }
    //格式化成json数据
    NSArray *arr = [NSJSONSerialization JSONObjectWithData:jdata options:NSJSONReadingMutableLeaves error:nil];
    return arr;
}


+ (NSString*) zcuiFullBundlePath:(NSString*)bundlePath{
    return [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:bundlePath];
}


+(ZCKitInfo *)getZCKitInfo{
    return [ZCUICore getUICore].kitInfo;
}

+(BOOL) zcgetOpenRecord{
    ZCKitInfo * configModel = [self getZCKitInfo];
    if (configModel!= nil) {
        return configModel.isOpenRecord;
    }
    return YES;
}

+(NSString *) zcgetTelRegular{
    ZCKitInfo * configModel = [self getZCKitInfo];
    if (configModel!= nil && sobotConvertToString(configModel.telRegular).length > 0) {
        return configModel.telRegular;
    }
    return @"0+\\d{2}-\\d{8}|0+\\d{2}-\\d{7}|0+\\d{3}-\\d{8}|0+\\d{3}-\\d{7}|1+[34578]+\\d{9}|\\+\\d{2}1+[34578]+\\d{9}|400\\d{7}|400-\\d{3}-\\d{4}|\\d{11}|\\d{10}|\\d{8}|\\d{7}";
}


+(NSString *)zcgetUrlRegular{
    NSString*urlRegex = ([ZCUICore getUICore].kitInfo!=nil && [ZCUICore getUICore].kitInfo.urlRegular!=nil && [ZCUICore getUICore].kitInfo.urlRegular.length>0) ? [ZCUICore getUICore].kitInfo.urlRegular:@"(https?|ftp|file)://[-A-Za-z0-9+&@#/%?=~_|!:,.;]+[-A-Za-z0-9+&@#/%=~_|]";
    return urlRegex;
}


+(BOOL) zcgetPhotoLibraryBgImage{
    ZCKitInfo * configModel = [self getZCKitInfo];
    if (configModel!= nil) {
        return configModel.isSetPhotoLibraryBgImage;
    }
    return NO;
}

+(UIFont *)zcgetTitleFont{
    ZCKitInfo *configModel=[self getZCKitInfo];
    if(configModel!=nil && configModel.titleFont!=nil){
        return configModel.titleFont;
    }
    return ZCUIFontBold18;
}

+(UIFont *)zcgetSubTitleFont{
    
    ZCKitInfo *configModel=[self getZCKitInfo];
    if(configModel!=nil && configModel.subTitleFont!=nil){
        return configModel.subTitleFont;
    }
    return ZCUIFontBold14;
    
}

+(UIFont *)zcgetTitleGoodsFont{
    ZCKitInfo *configModel = [self getZCKitInfo];
    if (configModel != nil && configModel.goodsTitleFont) {
        return configModel.goodsTitleFont;
    }
    return ZCUIFontBold14;
}


+(UIFont *)zcgetGoodsDetFont{
    ZCKitInfo *configModel = [self getZCKitInfo];
    if (configModel !=nil && configModel.goodsDetFont) {
        return configModel.goodsDetFont;
    }
    return ZCUIFont14;
}


+(UIFont *)zcgetListKitTitleFont{
    
    ZCKitInfo *configModel=[self getZCKitInfo];
    if(configModel!=nil && configModel.listTitleFont!=nil){
        return configModel.listTitleFont;
    }
    return ZCUIFont14;
}
+(UIFont *)zcgetListKitDetailFont{
    
    ZCKitInfo *configModel=[self getZCKitInfo];
    if(configModel!=nil && configModel.listDetailFont!=nil){
        return configModel.listDetailFont;
    }
    return ZCUIFont12;
}

+(UIFont *)zcgetCustomListKitDetailFont{
    
    ZCKitInfo *configModel=[self getZCKitInfo];
    if(configModel!=nil && configModel.customlistDetailFont!=nil){
        return configModel.customlistDetailFont;
    }
    return ZCUIFont12;
}



+(UIFont *)zcgetListKitTimeFont{
    ZCKitInfo *configModel=[self getZCKitInfo];
    if(configModel!=nil && configModel.listTimeFont!=nil){
        return configModel.listTimeFont;
    }
    return ZCUIFont11;
}
+(UIFont *)zcgetKitChatFont{
    
    ZCKitInfo *configModel=[self getZCKitInfo];
    if(configModel!=nil && configModel.chatFont!=nil){
        return configModel.chatFont;
    }
    return ZCUIFont14;
}

+(UIFont *)zcgetVoiceButtonFont{
    ZCKitInfo *configModel=[self getZCKitInfo];
    if(configModel!=nil && configModel.voiceButtonFont!=nil){
        return configModel.voiceButtonFont;
    }
    return ZCUIFont15;
}


+(UIFont *)zcgetNotifitionTopViewFont{
    ZCKitInfo *configModel = [self getZCKitInfo];
    if (configModel != nil && configModel.notificationTopViewLabelFont) {
        return configModel.notificationTopViewLabelFont;
    }
    return ZCUIFont14;
}

+(UIFont *)zcgetTopBtnFont{
    ZCKitInfo *configModel = [self getZCKitInfo];
    if (configModel != nil && configModel.topBtnFont) {
        return  configModel.topBtnFont;
    }
    return ZCUIFont18;
}

+(UIFont *)zcgetscTopTextFont{
    ZCKitInfo *configModel = [self getZCKitInfo];
    if (configModel != nil && configModel.scTopTextFont && ![self useDefaultThemeColor]) {
        return configModel.scTopTextFont;
    }
    return ZCUIFontBold17;
}


+(UIFont *)zcgetscTopBackTextFont{
    ZCKitInfo *configModel = [self getZCKitInfo];
    if (configModel != nil && configModel.scTopBackTextFont && ![self useDefaultThemeColor]) {
        return configModel.scTopBackTextFont;
    }
    return ZCUIFont11;
}


/******************************************************
 自定义颜色开始
 */

/// 系统背景色
+(UIColor *)zcgetBackgroundColor{
    ZCKitInfo *configModel=[self getZCKitInfo];
    if(configModel!=nil && configModel.backgroundColor!=nil){
        return configModel.backgroundColor;
    }
    return UIColorFromThemeColor(ZCBgSystemWhiteColor);
}

/// 系统背景色
+(UIColor *)zcgetLightGrayBackgroundColor{
    return UIColorFromThemeColor(ZCBgLightGrayColor);
}

+(UIColor *)zcgetLightGrayDarkBackgroundColor{
    return UIColorFromThemeColor(ZCBgLightGrayDarkColor);
}


+(UIColor *)zcgetThemeToWhiteColor{
    if([self getZCThemeStyle] == ZCThemeStyle_Dark){
        return UIColorFromThemeColor(ZCTextMainColor);
    }
    return UIColorFromThemeColor(ZCThemeColor);
}

/**
 *  商品中发送按钮的背景色
 *
 *
 */
+(UIColor *)zcgetGoodSendBtnColor{
    ZCKitInfo *configModel = [self getZCKitInfo];
    if(configModel!=nil && configModel.goodSendBtnColor!=nil && ![self useDefaultThemeColor]){
        return configModel.goodSendBtnColor;
    }
    return UIColorFromThemeColor(ZCThemeColor);
}

+(UIColor *) zcgetBgBannerColor{
    ZCKitInfo *configModel=[self getZCKitInfo];
    if(configModel!=nil && configModel.topViewBgColor!=nil && ![self useDefaultThemeColor]){
        return configModel.topViewBgColor;
    }
    return UIColorFromThemeColor(ZCBgTopBannerColor);
}


+( UIColor *) zcgetTopBtnNolColor{
    ZCKitInfo *configModel=[self getZCKitInfo];
    if(configModel!=nil && configModel.topBtnNolColor!=nil && ![self useDefaultThemeColor]){
        return configModel.topBtnNolColor;
    }
    return UIColorFromThemeColor(ZCTextMainColor);
}

+(UIColor *)zcgetTopBtnLayerColor{
    ZCKitInfo *configModel = [self getZCKitInfo];
    if (configModel != nil && configModel.topBtnLayerNolColor !=nil && ![self useDefaultThemeColor]) {
        return configModel.topBtnLayerNolColor;
    }
    return UIColorFromThemeColor(ZCBgLineColor);
}

+(UIColor *)zcgetTopBtnLayerSelColor{
    ZCKitInfo *configModel = [self getZCKitInfo];
    if (configModel != nil && configModel.topBtnLayerSelColor !=nil && ![self useDefaultThemeColor]) {
        return configModel.topBtnLayerSelColor;
    }
    return UIColorFromThemeColorAlpha(ZCThemeColor, 0.3);
}

+(UIColor *)zcgetTopBtnBgSelColor{
    ZCKitInfo *configModel = [self getZCKitInfo];
    if (configModel != nil && configModel.topBtnBgSelColor !=nil && ![self useDefaultThemeColor]) {
        return configModel.topBtnBgSelColor;
    }
    return UIColorFromThemeColorAlpha(ZCThemeColor, 0.15);
}


+( UIColor *) zcgetTopBtnSelColor{
    ZCKitInfo *configModel=[self getZCKitInfo];
    if(configModel!=nil && configModel.topBtnSelColor!=nil && ![self useDefaultThemeColor]){
        return configModel.topBtnSelColor;
    }
    return UIColorFromThemeColor(ZCThemeColor);
}


+( UIColor *) zcgetTopBtnGreyColor{
    ZCKitInfo *configModel=[self getZCKitInfo];
    if(configModel!=nil && configModel.topBtnGreyColor!=nil && ![self useDefaultThemeColor]){
        return configModel.topBtnGreyColor;
    }
    return UIColorFromThemeColor(ZCTextPlaceHolderColor);//UIColorFromRGB(topBtnTitleColor);
}


+(UIColor *)zcgetLeaveSubmitTextColor{
    ZCKitInfo *configModel=[self getZCKitInfo];
    if(configModel!=nil && configModel.leaveSubmitBtnTextColor!=nil && ![self useDefaultThemeColor]){
        return configModel.leaveSubmitBtnTextColor;
    }
    return UIColorFromThemeColor(ZCKeepWhiteColor);
}


+(UIColor *)zcgetLeaveSubmitImgColor{
    ZCKitInfo *configModel=[self getZCKitInfo];
    if(configModel!=nil && configModel.leaveSubmitBtnImgColor!=nil && ![self useDefaultThemeColor]){
        return configModel.leaveSubmitBtnImgColor;
    }
    return UIColorFromThemeColor(ZCThemeColor); //UIColorFromRGB(BgTitleColor);
}

// 2.8.0
/**
 *  文件查看 ImgProgress 背景颜色
 *
 *  @return
 */
+(UIColor *)zcgetDocumentLookImgProgressColor{
    ZCKitInfo *configModel=[self getZCKitInfo];
    if(configModel!=nil && configModel.documentLookImgProgressColor!=nil && ![self useDefaultThemeColor]){
        return configModel.documentLookImgProgressColor;
    }
    return  UIColorFromThemeColor(ZCThemeColor);//UIColorFromRGB(BgTitleColor);
    
}

/**
 *  文件查看 ImgProgress 背景颜色
 *
 *  @return
 */
+(UIColor *)zcgetDocumentBtnDownColor{
    ZCKitInfo *configModel=[self getZCKitInfo];
    if(configModel!=nil && configModel.documentBtnDownColor!=nil && ![self useDefaultThemeColor]){
        return configModel.documentBtnDownColor;
    }
    return UIColorFromThemeColor(ZCThemeColor);//UIColorFromRGB(BgTitleColor);
    
}


+(UIColor *)zcgetScoreExplainTextColor{
    ZCKitInfo *configModel = [self getZCKitInfo];
    if (configModel != nil && configModel.scoreExplainTextColor&& ![self useDefaultThemeColor]) {
        return configModel.scoreExplainTextColor;
    }
    return UIColorFromThemeColor(ZCTextNoticeColor); //UIColorFromRGB(ScoreExplainTextColor);
}


+(UIColor *)zcgetBannerTitleColor{
    ZCKitInfo *configModel=[self getZCKitInfo];
    if (configModel!=nil && configModel.topViewTextColor != nil && ![self useDefaultThemeColor]) {
        return configModel.topViewTextColor;
    }
    return UIColorFromThemeColor(ZCTextMainColor);
}

+(UIColor *)zcgetLeftChatColor{
    ZCKitInfo *configModel=[self getZCKitInfo];
    if(configModel!=nil && configModel.leftChatColor!=nil && ![self useDefaultThemeColor]){
        return configModel.leftChatColor;
    }
    return UIColorFromThemeColor(ZCBgLeftChatColor);//UIColorFromRGB(0xF2F5F7);
    
}

+(UIColor *)zcgetRightChatColor{
    ZCKitInfo *configModel=[self getZCKitInfo];
    if(configModel!=nil && configModel.rightChatColor!=nil && ![self useDefaultThemeColor]){
        return configModel.rightChatColor;
    }
    return UIColorFromThemeColor(ZCThemeColor);//UIColorFromRGB(BgTitleColor);
}

+(UIColor *)zcgetEmojiSendBgColor{
    ZCKitInfo *configModel=[self getZCKitInfo];
    if(configModel!=nil && configModel.emojiSendBgColor!=nil && ![self useDefaultThemeColor]){
        return configModel.emojiSendBgColor;
    }
    return UIColorFromThemeColor(ZCThemeColor);//UIColorFromRGB(BgTitleColor);
}

+(UIColor *)zcgetEmojiSendTextColor{
    ZCKitInfo *configModel=[self getZCKitInfo];
    if(configModel!=nil && configModel.emojiSendTextColor!=nil && ![self useDefaultThemeColor]){
        return configModel.emojiSendTextColor;
    }
    return UIColorFromThemeColor(ZCKeepWhiteColor);//UIColorFromRGB(BgTitleColor);
}


+(UIColor *)zcgetChatTextViewColor{
    ZCKitInfo *configModel=[self getZCKitInfo];
    if(configModel!=nil && configModel.chatTextViewColor!=nil && ![self useDefaultThemeColor]){
        return configModel.chatTextViewColor;
    }
    return UIColorFromThemeColor(ZCTextMainColor);//UIColorFromThemeColor(ZCTextMainColor);
}

+(UIColor *)zcgetBackgroundBottomColor{
    ZCKitInfo *configModel=[self getZCKitInfo];
    if(configModel!=nil && configModel.backgroundBottomColor!=nil && ![self useDefaultThemeColor]){
        return configModel.backgroundBottomColor;
    }
    return UIColorFromThemeColor(ZCBgSystemWhiteLightDarkColor);//UIColorFromRGB(0xFFFFFF);
}



// 复制选中的背景色
+(UIColor *)zcgetRightChatSelectdeColor{
    ZCKitInfo *configModel=[self getZCKitInfo];
    if(configModel!=nil && configModel.rightChatSelectedColor!=nil && ![self useDefaultThemeColor]){
        return configModel.rightChatSelectedColor;
    }
    return UIColorFromThemeColor(ZCTextPlaceHolderColor);
}


+(UIColor *)zcgetLeftChatSelectedColor{
    ZCKitInfo *configModel=[self getZCKitInfo];
    if(configModel!=nil && configModel.leftChatSelectedColor!=nil && ![self useDefaultThemeColor]){
        return configModel.leftChatSelectedColor;
    }
    return UIColorFromThemeColor(ZCTextPlaceHolderColor);
}


+(UIColor *)zcgetBackgroundBottomLineColor{
    ZCKitInfo *configModel=[self getZCKitInfo];
    if(configModel!=nil && configModel.bottomLineColor!=nil && ![self useDefaultThemeColor]){
        return configModel.bottomLineColor;
    }
    return UIColorFromThemeColor(ZCBgLineColor);//UIColorFromRGB(0xedeef0);
}

+(UIColor *)zcgetCommentButtonLineColor{
    ZCKitInfo *configModel=[self getZCKitInfo];
    if(configModel!=nil && configModel.bottomLineColor!=nil && ![self useDefaultThemeColor]){
        return configModel.bottomLineColor;
    }
    return UIColorFromThemeColor(ZCBgLineColor);//UIColorFromRGB(LineCommentLineColor);
}


+(UIColor *)zcgetCommentCommitButtonColor{
    ZCKitInfo *configModel=[self getZCKitInfo];
    if(configModel!=nil && configModel.commentCommitButtonColor!=nil && ![self useDefaultThemeColor]){
        return configModel.commentCommitButtonColor;
    }
    return UIColorFromThemeColor(ZCThemeColor); //UIColorFromRGB(BgTitleColor);
}

/**
 *   评价弹出页面 ，按钮文字颜色
 *
 *   @return
 */
+(UIColor *)zcgetCommentPageButtonTextColor{
    ZCKitInfo *configModel=[self getZCKitInfo];
    if(configModel!=nil && configModel.commentButtonTextColor!=nil && ![self useDefaultThemeColor]){
        return configModel.commentButtonTextColor;
    }
    return UIColorFromThemeColor(ZCThemeColor); //UIColorFromRGB(BgTitleColor);
}

/**
 *   评价弹出页面，按钮背景颜色
 *
 *   @return
 */
+(UIColor *)zcgetCommentPageButtonBgColor{
    ZCKitInfo *configModel=[self getZCKitInfo];
    if(configModel!=nil && configModel.commentButtonBgColor!=nil && ![self useDefaultThemeColor]){
        return configModel.commentButtonBgColor;
    }
    return UIColorFromThemeColor(ZCThemeColor); // UIColorFromRGB(BgTitleColor);
}

/**
 *   评价弹出页面，按钮背景颜色
 *
 *   @return
 */
+(UIColor *)zcgetCommentItemButtonBgColor{
    ZCKitInfo *configModel=[self getZCKitInfo];
    if(configModel!=nil && configModel.commentItemButtonBgColor!=nil && ![self useDefaultThemeColor]){
        return configModel.commentItemButtonBgColor;
    }
    return UIColorFromThemeColor(ZCBgLeftChatColor); // UIColorFromRGB(BgTitleColor);
}

/**
 *   评价弹出页面，按钮背景颜色
 *
 *   @return
 */
+(UIColor *)zcgetCommentItemSelButtonBgColor{
    ZCKitInfo *configModel=[self getZCKitInfo];
    if(configModel!=nil && configModel.commentItemButtonSelBgColor!=nil && ![self useDefaultThemeColor]){
        return configModel.commentItemButtonSelBgColor;
    }
    return UIColorFromThemeColor(ZCThemeColor); // UIColorFromRGB(BgTitleColor);
}

+(UIColor *)zcgetBgTipAirBubblesColor{
    ZCKitInfo *configModel=[self getZCKitInfo];
    if(configModel!=nil && configModel.BgTipAirBubblesColor!=nil && ![self useDefaultThemeColor]){
        return configModel.BgTipAirBubblesColor;
    }
    return UIColorFromThemeColor(ZCBgLeftChatColor); // UIColorFromRGB(0xFFF8F9FA);
}

+(UIColor *)zcgetSubmitEvaluationButtonColor{
    ZCKitInfo *configModel=[self getZCKitInfo];
    if(configModel!=nil && configModel.submitEvaluationColor!=nil && ![self useDefaultThemeColor]){
        return configModel.submitEvaluationColor;
    }
    return UIColorFromThemeColor(ZCKeepWhiteColor);
}


+(UIColor *)zcgetTopViewTextColor{
    ZCKitInfo *configModel = [self getZCKitInfo];
    if (configModel != nil && configModel.topViewTextColor && ![self useDefaultThemeColor]) {
        return configModel.topViewTextColor;
    }
    return UIColorFromThemeColor(ZCTextMainColor); //UIColorFromRGB(TextUnPlaceHolderColor);
}

+(UIColor *)zcgetLeaveMsgTextColor{
    ZCKitInfo *configModel = [self getZCKitInfo];
    if (configModel != nil && configModel.leaveMsgTextColor && ![self useDefaultThemeColor]) {
        return configModel.leaveMsgTextColor;
    }
    return UIColorFromThemeColor(ZCTextMainColor);
}


+(UIColor *)zcgetLeftChatTextColor{
    ZCKitInfo *configModel = [self getZCKitInfo];
    if (configModel != nil && configModel.leftChatTextColor && ![self useDefaultThemeColor]) {
        return configModel.leftChatTextColor;
    }
    return UIColorFromThemeColor(ZCTextMainColor); //UIColorFromThemeColor(ZCTextMainColor);
}

+(UIColor *)zcgetOpenMoreBtnTextColor{
    ZCKitInfo * configModel = [self getZCKitInfo];
    if (configModel != nil && configModel.openMoreBtnTextColor && ![self useDefaultThemeColor]) {
        return configModel.openMoreBtnTextColor;
    }
    return UIColorFromThemeColor(ZCThemeColor); //UIColorFromRGB(0x0daeaf);
}

+(UIColor*)zcgetGoodsTextColor{
    ZCKitInfo * configModel = [self getZCKitInfo];
    if (configModel != nil && configModel.goodsTitleTextColor && ![self useDefaultThemeColor]) {
        return configModel.goodsTitleTextColor;
    }
    return UIColorFromThemeColor(ZCTextMainColor); //UIColorFromRGB(TextGoodTitleColor);
}

+(UIColor *)zcgetGoodsDetColor{
    ZCKitInfo *configModel = [self getZCKitInfo];
    if (configModel !=nil && configModel.goodsDetTextColor && ![self useDefaultThemeColor]) {
        return configModel.goodsDetTextColor;
    }
    return UIColorFromThemeColor(ZCTextSubColor);//UIColorFromRGB(TextGoodDetColor);
}

+(UIColor *)zcgetGoodsTipColor{
    ZCKitInfo *configModel = [self getZCKitInfo];
    if (configModel !=nil && configModel.goodsTipTextColor && ![self useDefaultThemeColor]) {
        return configModel.goodsTipTextColor;
    }
    return UIColorFromThemeColor(ZCThemeColor);
}


+(UIColor *)zcgetGoodsSendColor{
    ZCKitInfo *configModel = [self getZCKitInfo];
    if (configModel !=nil && configModel.goodsSendTextColor && ![self useDefaultThemeColor]) {
        return configModel.goodsSendTextColor;
    }
    return UIColorFromThemeColor(ZCKeepWhiteColor);
}



+(UIColor *)zcgetSatisfactionColor{
    ZCKitInfo *configModel = [self getZCKitInfo];
    if (configModel != nil && configModel.satisfactionTextColor && ![self useDefaultThemeColor]) {
        return configModel.satisfactionTextColor;
    }
    return UIColorFromThemeColor(ZCTextMainColor); //UIColorFromRGB(SatisfactionTextColor);
}


+(UIColor *)zcgetscTopTextColor{
    ZCKitInfo *configModel = [self getZCKitInfo];
    if (configModel != nil && configModel.scTopTextColor && ![self useDefaultThemeColor]) {
        return configModel.scTopTextColor;
    }
    return UIColorFromThemeColor(ZCTextMainColor);
}




+(UIColor *)zcgetscTopBgColor{
    ZCKitInfo *configModel = [self getZCKitInfo];
    if (configModel != nil && configModel.scTopBgColor && ![self useDefaultThemeColor]) {
        return configModel.scTopBgColor;
    }
    return [self zcgetBgBannerColor];
}


+(UIColor *)zcgetscTopBackTextColor{
    ZCKitInfo *configModel = [self getZCKitInfo];
    if (configModel != nil && configModel.scTopBackTextColor && ![self useDefaultThemeColor]) {
        return configModel.scTopBackTextColor;
    }
    return UIColorFromThemeColor(ZCTextMainColor);
}



+(UIColor *)zcgetNoSatisfactionTextColor{
    ZCKitInfo *configModel = [self getZCKitInfo];
    if (configModel != nil && configModel.noSatisfactionTextColor && ![self useDefaultThemeColor]) {
        return configModel.noSatisfactionTextColor;
    }
    return UIColorFromThemeColor(ZCTextSubColor); // UIColorFromRGB(NoSatisfactionTextColor);
}

+(UIColor *)zcgetSatisfactionTextSelectedColor{
    ZCKitInfo *configModel = [self getZCKitInfo];
    if (configModel != nil && configModel.satisfactionTextSelectedColor && ![self useDefaultThemeColor]) {
        return configModel.satisfactionTextSelectedColor;
    }
    return UIColorFromThemeColor(ZCTextMainColor); 
}

+(UIColor *)zcgetSatisfactionBgSelectedColor{
    ZCKitInfo *configModel = [self getZCKitInfo];
    if (configModel != nil && configModel.satisfactionSelectedBgColor && ![self useDefaultThemeColor]) {
        return configModel.satisfactionSelectedBgColor;
    }
    return UIColorFromThemeColor(ZCBgSystemWhiteLightGrayColor);
}



+(UIColor *)zcgetRightChatTextColor{
    ZCKitInfo *configModel = [self getZCKitInfo];
    if (configModel != nil && configModel.rightChatTextColor && ![self useDefaultThemeColor]) {
        return configModel.rightChatTextColor;
    }
    return UIColorFromThemeColor(ZCKeepWhiteColor);
}


+(UIColor *)zcgetTimeTextColor{
    ZCKitInfo *configModel = [self getZCKitInfo];
    if (configModel != nil && configModel.timeTextColor && ![self useDefaultThemeColor]) {
        return configModel.timeTextColor;
    }
//    return UIColorFromRGB(TextTimeColor);
    return UIColorFromThemeColor(ZCTextSubColor);
}


+(UIColor *)zcgetTipLayerTextColor{
    ZCKitInfo *configModel = [self getZCKitInfo];
    if (configModel != nil && configModel.tipLayerTextColor && ![self useDefaultThemeColor]) {
        return configModel.tipLayerTextColor;
    }
    return UIColorFromThemeColor(ZCTextSubColor); // UIColorFromRGB(tipsChatCellTextColor);
}


+(UIColor *)zcgetServiceNameTextColor{
    ZCKitInfo *configModel = [self getZCKitInfo];
    if (configModel != nil && configModel.serviceNameTextColor && ![self useDefaultThemeColor]) {
        return configModel.serviceNameTextColor;
    }
    return UIColorFromThemeColor(ZCTextSubColor); //UIColorFromRGB(TextNameColor);
}

+(UIColor *)zcgetChatLeftLinkColor{
    
    ZCKitInfo *configModel = [self getZCKitInfo];
    if (configModel != nil && configModel.chatLeftLinkColor && ![self useDefaultThemeColor]) {
        return configModel.chatLeftLinkColor;
    }
    return UIColorFromThemeColor(ZCTextLinkBlueColor);
}

+(UIColor *)zcgetChatMultLinkColor{
    
    ZCKitInfo *configModel = [self getZCKitInfo];
    if (configModel != nil && configModel.chatLeftMultColor && ![self useDefaultThemeColor]) {
        return configModel.chatLeftMultColor;
    }
    return UIColorFromThemeColor(ZCTextLinkBlueColor);
}


+(UIColor *)zcgetChatRightlinkColor{
    ZCKitInfo *configModel = [self getZCKitInfo];
    if (configModel != nil && configModel.chatRightLinkColor && ![self useDefaultThemeColor]) {
        return configModel.chatRightLinkColor;
    }
    return UIColorFromThemeColor(ZCTextLinkYellowColor);
}


+(UIColor *)zcgetChatRightVideoSelBgColor{
    ZCKitInfo *configModel = [self getZCKitInfo];
    if (configModel != nil && configModel.videoCellBgSelColor && ![self useDefaultThemeColor]) {
        return configModel.videoCellBgSelColor;
    }
    return UIColorFromThemeColor(ZCThemeColor); //UIColorFromRGB(BgVideoCellSelColor);
}


+(UIColor *)zcgetLineRichColor{
    ZCKitInfo *configModel = [self getZCKitInfo];
    if (configModel != nil && configModel.LineRichColor && ![self useDefaultThemeColor]) {
        return configModel.LineRichColor;
    }
    return UIColorFromThemeColor(ZCBgLineColor);  //UIColorFromRGB(0xebeef0);
}


+(CGFloat )zcgetChatLineSpacing{
    ZCKitInfo *configModel = [self getZCKitInfo];
    if (configModel != nil && configModel.lineSpacing>0) {
        return configModel.lineSpacing;
    }
    return 3.0f;
}


+(CGFloat )zcgetChatGuideLineSpacing{
    ZCKitInfo *configModel = [self getZCKitInfo];
    if (configModel != nil && configModel.guideLineSpacing>0) {
        return configModel.guideLineSpacing;
    }
    return [self zcgetChatLineSpacing];
}

+(UIColor *)getNotifitionTopViewBgColor{
    ZCKitInfo *configModel = [self getZCKitInfo];
    if (configModel != nil && configModel.notificationTopViewBgColor && ![self useDefaultThemeColor]) {
        return configModel.notificationTopViewBgColor;
    }
    return UIColorFromThemeColor(ZCBgNoticeColor); // UIColorFromRGB(noticBgColor);
}


+(UIColor *)getNotifitionTopViewLabelColor{
    ZCKitInfo *configModel = [self getZCKitInfo];
    if (configModel != nil && configModel.notificationTopViewLabelColor && ![self useDefaultThemeColor]) {
        return configModel.notificationTopViewLabelColor;
    }
     return UIColorFromThemeColor(ZCTextNoticeColor); //UIColorFromRGB(noticTextColor);
}



//检查是否有相册的权限
+(void)isHasPhotoLibraryAuthorization:(void(^)(BOOL))result {
    [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
//        if(sobotGetSystemDoubleVersion()>=14.0){
//            if(status == PHAuthorizationStatusLimited){
//                if(result){
//                    result(true);
//                }
//                return;
//            }
//        }
        if (status == PHAuthorizationStatusAuthorized) {
            NSLog(@"Authorized");
            dispatch_async(dispatch_get_main_queue(), ^{
                if(result){
                    result(true);
                }
            });
        }else{
            NSLog(@"Denied or Restricted");
            dispatch_async(dispatch_get_main_queue(), ^{
                if(result){
                    result(false);
                }
            });
            return;
        }
    }];
}

//检测是否有相机的权限
+(BOOL)isHasCaptureDeviceAuthorization{
    if (iOS7) {
        NSString *mediaType = AVMediaTypeVideo;
        AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:mediaType];
        if(authStatus == ALAuthorizationStatusRestricted || authStatus == ALAuthorizationStatusDenied){
            return NO;
        }
        return YES;
    }else{
        return YES;
    }
}



/**
 war获取录音设置
 @returns 录音设置
 */
+ (NSDictionary*)getAudioRecorderSettingDict
{
    NSDictionary *recordSetting = [[NSDictionary alloc] initWithObjectsAndKeys:
                                   [NSNumber numberWithFloat: 8000.0],AVSampleRateKey, //采样率
                                   //                                   [NSNumber numberWithFloat: 16000.0],AVSampleRateKey, //采样率
                                   [NSNumber numberWithInt: kAudioFormatLinearPCM],AVFormatIDKey,
                                   [NSNumber numberWithInt: 16],AVLinearPCMBitDepthKey,//采样位数 默认 16
                                   [NSNumber numberWithInt: 1], AVNumberOfChannelsKey,//通道的数目
                                   [NSNumber numberWithInt: AVAudioQualityMedium],AVEncoderAudioQualityKey,//音频编码质量
                                   //                                   [NSNumber numberWithBool:NO],AVLinearPCMIsBigEndianKey,//大端还是小端 是内存的组织方式
                                   //                                   [NSNumber numberWithBool:NO],AVLinearPCMIsFloatKey,//采样信号是整数还是浮点数
                                   nil];
    return recordSetting;
}

+(BOOL)isOpenVoicePermissions{
    __block BOOL isOpen = NO;
    AVAudioSession *avSession = [AVAudioSession sharedInstance];
    if ([avSession respondsToSelector:@selector(requestRecordPermission:)]) {
        
        
        [avSession requestRecordPermission:^(BOOL available) {
            
            if (available) {
                //                NSLog(@"语音权限开启");
                isOpen = YES;
            }
            else
            {
                isOpen = NO;
                
            }
        }];
        
    }
    
    return isOpen;
}


+ (int)IntervalDay:(NSString *)filePath
{
    NSDictionary *attributes = [[NSFileManager defaultManager] attributesOfItemAtPath:filePath error:nil];
    // [SobotLog logDebug:@"create date:%@",[attributes fileModificationDate]];
    NSString *dateString = [NSString stringWithFormat:@"%@",[attributes fileModificationDate]];
    
    NSDateFormatter *inputFormatter = [[NSDateFormatter alloc] init];
    [inputFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss Z"];
    
    NSDate *formatterDate = [inputFormatter dateFromString:dateString];
    
    // 矫正时区
    NSTimeZone *zone = [NSTimeZone systemTimeZone];
    NSInteger interval = [zone secondsFromGMTForDate: formatterDate];
    NSDate *localeDate = [formatterDate  dateByAddingTimeInterval: interval];
    
    unsigned int unitFlags = NSDayCalendarUnit;
    NSCalendar *cal = [NSCalendar currentCalendar];
    NSDateComponents *d = [cal components:unitFlags fromDate:localeDate toDate:[NSDate date] options:0];
    
    
    // [SobotLog logDebug:@"%d,%d,%d,%d",[d year],[d day],[d hour],[d minute]];
    
    int result = (int)d.day;
    
    //    return 0;
    return result;
}


#define imageVALIDMINUTES 3
#define voiceVALIDMINUTES 3
+(BOOL)imageIsValid:(NSString *)filePath{
    if ([self IntervalDay:filePath] < imageVALIDMINUTES) { //VALIDDAYS = 有效时间分钟
        return YES;
    }
    return NO;
}

+(BOOL)videoIsValid:(NSString *)filePath{
    if ([self IntervalDay:filePath] < voiceVALIDMINUTES) { //VALIDDAYS = 有效时间分钟
        return YES;
    }
    return NO;
}


+ (void)addTopBorderWithColor:(UIColor *)color andWidth:(CGFloat) borderWidth withView:(UIView *) view{
    CALayer *border = [CALayer layer];
    border.backgroundColor = color.CGColor;
    
    border.frame = CGRectMake(0, 0, view.frame.size.width, borderWidth);
    [view.layer addSublayer:border];
}

+ (void)addTopBorderWithColor:(UIColor *)color andWidth:(CGFloat)borderWidth andViewWidth:(CGFloat)viewWidth withView:(UIView *) view{
    CALayer *border = [CALayer layer];
    border.backgroundColor = color.CGColor;
    
    border.frame = CGRectMake(0, 0, viewWidth, borderWidth);
    [view.layer addSublayer:border];
}

+ (void)addBottomBorderWithColor:(UIColor *)color andWidth:(CGFloat) borderWidth withView:(UIView *) view {
    CALayer *border = [CALayer layer];
    border.backgroundColor = color.CGColor;
    border.frame = CGRectMake(0, view.frame.size.height - borderWidth, view.frame.size.width, borderWidth);
    border.name=@"border";
    [view.layer addSublayer:border];
}
+ (void)addBottomBorderWithColor:(UIColor *)color andWidth:(CGFloat) borderWidth andViewWidth:(CGFloat)viewWidth withView:(UIView *) view{
    CALayer *border = [CALayer layer];
    border.backgroundColor = color.CGColor;
    border.frame = CGRectMake(0, view.frame.size.height - borderWidth, viewWidth, borderWidth);
    border.name=@"border";
    [view.layer addSublayer:border];
}
+ (void)addLeftBorderWithColor:(UIColor *)color andWidth:(CGFloat) borderWidth  withView:(UIView *) view{
    CALayer *border = [CALayer layer];
    border.backgroundColor = color.CGColor;
    
    border.frame = CGRectMake(0, 0, borderWidth, view.frame.size.height);
    [view.layer addSublayer:border];
}

+ (void)addRightBorderWithColor:(UIColor *)color andWidth:(CGFloat) borderWidth  withView:(UIView *) view{
    CALayer *border = [CALayer layer];
    border.backgroundColor = color.CGColor;
    
    border.frame = CGRectMake(view.frame.size.width - borderWidth, 0, borderWidth, view.frame.size.height);
    [view.layer addSublayer:border];
}
+(int )changeFileType:(int) oldType{
    int newType = oldType;
    switch (oldType) {
        case 13:
            newType = 0;
            break;
        case 14:
            newType = 1;
            break;
        case 15:
            newType = 2;
            break;
        case 16:
            newType = 3;
            break;
        case 17:
            newType = 4;
            break;
        case 18:
            newType = 5;
            break;
        case 19:
            newType = 6;
            break;
        case 20:
            newType = 7;
            break;
        default:
            break;
    }
    return newType;
}

+(int) zcLibmimeWithURLType:(NSString *)filePath
{
    filePath = sobotConvertToString(filePath);
    // 先从参入的路径的出URL
    NSURL *url = [NSURL fileURLWithPath:filePath];
    if ([filePath hasPrefix:@"file:///"]){
        url = [NSURL URLWithString:filePath];
    }
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    // 只有响应头中才有其真实属性 也就是MIME
    NSURLResponse *response = nil;
    [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:nil];
    NSString *mimeType = response.MIMEType;
    
    int type = 8;
    if([@"application/msword" isEqual:mimeType] || [@"application/vnd.ms-works" isEqual:mimeType] || [filePath hasSuffix:@".docx"] || [filePath hasSuffix:@".doc"]){
        type = 0;
    }else if([@"application/vnd.ms-powerpoint" isEqual:mimeType] || [filePath hasSuffix:@".ppt"] || [filePath hasSuffix:@".pptx"]){
        type = 1;
    }else if([@"application/vnd.ms-excel" isEqual:mimeType] || [@"application/vnd.ms-excel" isEqual:mimeType] || [filePath hasSuffix:@".xls"] || [filePath hasSuffix:@".xlsx"]){
        type = 2;
    }else if([@"application/pdf" isEqual:mimeType] || [filePath hasSuffix:@".pdf"]){
        type = 3;
    }else if([@"application/zip" isEqual:mimeType] || [@"application/rar" isEqual:mimeType]){
        type = 6;
    }else if([mimeType hasPrefix:@"audio"] || [filePath hasSuffix:@".mp3"]){
        type = 4;
    }else if([mimeType hasPrefix:@"video"] || [filePath hasSuffix:@".mp4"]){
        type = 5;
    }else if([@"text/plain" isEqual:mimeType] || [filePath hasSuffix:@".txt"]){
        type = 7;
    }
    return type;
}
+(UIImage *) getFileIcon:(NSString * ) filePath fileType:(int) type{
    type  = type>0 ? [ZCUITools changeFileType:type] : [ZCUITools zcLibmimeWithURLType:filePath];
    NSString *iconName = @"";
    if(type == 0){
        iconName = @"zcicon_file_word";
    }else if( type == 1){
        iconName = @"zcicon_file_ppt";
    }else if(type == 2){
        iconName = @"zcicon_file_excel";
    }else if(type == 3){
        iconName = @"zcicon_file_pdf";
    }else if(type == 6){
        iconName = @"zcicon_file_zip";
    }else if(type == 4){
        iconName = @"zcicon_file_mp3";
    }else if(type == 5){
        iconName = @"zcicon_file_mp4";
    }else if(type == 7){
        iconName = @"zcicon_file_txt";
    }else{
        iconName = @"zcicon_file_unknow";
    }
    
    return [ZCUITools zcuiGetBundleImage:iconName];
}


+(void)zcShakeView:(UIView*)viewToShake
{
    CGFloat t =2.0;
    CGAffineTransform translateRight  =CGAffineTransformTranslate(CGAffineTransformIdentity, t,0.0);
    CGAffineTransform translateLeft =CGAffineTransformTranslate(CGAffineTransformIdentity,-t,0.0);
    
    viewToShake.transform = translateLeft;
    
    [UIView animateWithDuration:0.07 delay:0.0 options:UIViewAnimationOptionAutoreverse|UIViewAnimationOptionRepeat animations:^{
        [UIView setAnimationRepeatCount:2.0];
        viewToShake.transform = translateRight;
    } completion:^(BOOL finished){
        if(finished){
            [UIView animateWithDuration:0.05 delay:0.0 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
                viewToShake.transform =CGAffineTransformIdentity;
            } completion:NULL];
        }
    }];
}


+ (NSString *)zcTransformString:(NSString *)originalStr{
    NSString *text = originalStr;
    
    //解析http://短链接
    NSString *regex_http = @"(http(s)?://|www)([a-zA-Z|\\d]+\\.)+[a-zA-Z|\\d]+(/[a-zA-Z|\\d|\\-|\\+|_./?%&=]*)?";//http://短链接正则表达式
    
    //        NSString *regex_http = @"http(s)?://[^\\s()<>]+(?:\\([\\w\\d]+\\)|(?:[^\\p{Punct}\\s]|/))+[a-zA-Z|\\d]+(/[a-zA-Z|\\d|\\-|\\+|_./?%&=]*)?";
    // 识别 www.的链接
    //    NSString *regex_http =@"((http[s]{0,1}|ftp)://[a-zA-Z0-9\\.\\-]+\\.([a-zA-Z]{2,4})(:\\d+)?(/[a-zA-Z0-9\\.\\-~!@#$%^&*+?:_/=<>]*)?)|(www.[a-zA-Z0-9\\.\\-]+\\.([a-zA-Z]{2,4})(:\\d+)?(/[a-zA-Z0-9\\.\\-~!@#$%^&*+?:_/=<>]*)?)";
    
    NSString *regex_text=[NSString stringWithFormat:@"%@(?![^<]*>)(?![^>]*<)",regex_http];
    //    NSArray *array_http = [text componentsMatchedByRegex:regex_text];
    
    
    NSError *error;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:regex_text
                                                                           options:NSRegularExpressionCaseInsensitive
                                                                             error:&error];
    NSArray *arrayOfAllMatches = [regex matchesInString:originalStr options:0 range:NSMakeRange(0, [originalStr length])];
    
    NSInteger len = 0;
    for (NSTextCheckingResult *match in arrayOfAllMatches)
    {
        
        NSRange range = match.range;
        NSString* substringForMatch = [originalStr substringWithRange:range];
        
        //[SobotLog logDebug:@"%@,%@",NSStringFromRange(range),substringForMatch];
        
        NSString *funUrlStr = [NSString stringWithFormat:@"<a href=\"%@\">%@</a>",substringForMatch, substringForMatch];
        text = [text stringByReplacingCharactersInRange:NSMakeRange(range.location+len, substringForMatch.length) withString:funUrlStr];
        len = 15+substringForMatch.length;
    }
    
    
    
    //解析表情
    NSString *tempText = text;
    NSError *err = nil;
    // 替换掉atuser后的text
    regex = [NSRegularExpression regularExpressionWithPattern:@"\\[(.*?)\\]" options:0 error:&err];
    NSArray *matches = [regex matchesInString:text options:0 range:NSMakeRange(0, text.length)];
    
    NSInteger mxLength = 0;
    
    for (NSTextCheckingResult *match in matches) {
        NSRange wordRange = match.range;
        NSString  *key=[text substringWithRange:wordRange];
        if([[[ZCUICore getUICore] allExpressionDict] objectForKey:key]){
            NSString *imgText = [NSString stringWithFormat:@"<img src=%@.png>",[[[ZCUICore getUICore] allExpressionDict] objectForKey:key]];
            tempText = [tempText stringByReplacingOccurrencesOfString:key withString:imgText options:0 range:NSMakeRange(wordRange.location+mxLength, wordRange.length)];
            mxLength = mxLength + (imgText.length - key.length);
            
        }
    }
    text = tempText;
    
    //    NSLog(@"%@",text);
    //返回转义后的字符串
    return text;
}

+ (NSString *)zcAddTransformString:(NSString *)contentText{
    NSString *text = contentText;
    // 识别 www.的链接
    NSString *regex_http = @"(http(s)?://|www)([a-zA-Z|\\d]+\\.)+[a-zA-Z|\\d]+(/[a-zA-Z|\\d|\\-|\\+|_./?%&=]*)?";//http://短链接正则表达式
    
    NSString *regex_text=[NSString stringWithFormat:@"%@(?![^<]*>)(?![^>]*<)|([a-zA-Z0-9\\.\\-]+\\.([a-zA-Z]{2,4})(:\\d+)?(/[a-zA-Z0-9\\.\\-~!@#$^&*+?%%:_/=<>]*)?)|(www.[a-zA-Z0-9\\.\\-]+\\.([a-zA-Z]{2,4})(:\\d+)?(/[a-zA-Z0-9\\.\\-~!@#$^&*+?%%:_/=<>]*)?)",regex_http];
    
    
    NSError *error;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:regex_text
                                                                           options:NSRegularExpressionCaseInsensitive
                                                                             error:&error];
    NSArray *arrayOfAllMatches = [regex matchesInString:contentText options:0 range:NSMakeRange(0, [contentText length])];
    
    NSInteger len = 0;
    for (NSTextCheckingResult *match in arrayOfAllMatches)
    {
        
        NSRange range = match.range;
        NSString* substringForMatch = [contentText substringWithRange:range];
        
        [SobotLog logDebug:@"%@,%@",NSStringFromRange(range),substringForMatch];
        
        
        NSString *funUrlStr = [NSString stringWithFormat:@"<a href=\"%@\">%@</a>",substringForMatch, substringForMatch];
        text = [text stringByReplacingCharactersInRange:NSMakeRange(range.location+len, substringForMatch.length) withString:funUrlStr];
        len = 15+substringForMatch.length;
    }
    
    //    NSLog(@"%@",text);
    //解析表情
    NSString *tempText = text;
    NSError *err = nil;
    // 替换掉atuser后的text
    regex = [NSRegularExpression regularExpressionWithPattern:@"\\[(.*?)\\]" options:0 error:&err];
    NSArray *matches = [regex matchesInString:text options:0 range:NSMakeRange(0, text.length)];
    
    NSInteger mxLength = 0;
    
    for (NSTextCheckingResult *match in matches) {
        NSRange wordRange = match.range;
        NSString  *key=[text substringWithRange:wordRange];
        if([[[ZCUICore getUICore] allExpressionDict] objectForKey:key]){
            NSString *imgText = [NSString stringWithFormat:@"<img src=%@.png>",[[[ZCUICore getUICore] allExpressionDict] objectForKey:key]];
            tempText = [tempText stringByReplacingOccurrencesOfString:key withString:imgText options:0 range:NSMakeRange(wordRange.location+mxLength, wordRange.length)];
            mxLength = mxLength + (imgText.length - key.length);
            
        }
    }
    text = tempText;
    //    NSLog(@"%@",text);
    
    //返回转义后的字符串
    return text;
}




@end
