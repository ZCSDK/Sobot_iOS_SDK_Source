//
//  ZCHtmlFilter.m
//  SobotKit
//
//  Created by zhangxy on 2019/4/25.
//  Copyright © 2019 zhichi. All rights reserved.
//

#import "ZCHtmlFilter.h"

#import "ZCMLEmojiLabel.h"
#import "ZCUIColorsDefine.h"
#import "ZCLibGlobalDefine.h"
#import "ZCUICore.h"

@implementation ZCHtmlFilter

+(NSMutableAttributedString *)setHtml:(NSString *)text attrs:(NSMutableArray *) attrs view:(UILabel *) label  textColor:(UIColor*)textColor textFont:(UIFont*)textFont linkColor:(UIColor*)linkColor{
    __block NSMutableAttributedString  *str = nil;
    
    str = [[NSMutableAttributedString alloc] initWithString:text];
    
    // 先处理 ZCMLEmojiLabel 正则的匹配
    if ([label isKindOfClass:[ZCMLEmojiLabel class]]) {
        [label setTextColor:textColor];
        [((ZCMLEmojiLabel *)label) setLinkColor:linkColor];
        [((ZCMLEmojiLabel *)label) setText:str];
        str =[[NSMutableAttributedString alloc] initWithAttributedString:((ZCMLEmojiLabel *)label).attributedText];
    }
    
    [str addAttribute:NSFontAttributeName value:textFont range:NSMakeRange(0, str.length)];
    [str addAttribute:NSForegroundColorAttributeName value:textColor range:NSMakeRange(0, str.length)];
    
    NSRange rangeB;
    NSRange rangeI;
    
    for (NSDictionary *item in attrs) {
        NSRange range = NSMakeRange([item[@"location"] intValue], [item[@"len"] intValue]);
        
        // 2.7.8 防止闪退
        NSUInteger strLength = range.location + range.length;
        BOOL isOK = NO;
        if (strLength<=str.length && str.length>range.location) {
            isOK = YES;
        }
        
        if([item[@"tag"] isEqual:@"B"]){
            if (isOK) {
//                NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
//                paragraphStyle.lineSpacing = 4; // 调整行间距
//                //                NSRange range = NSMakeRange(0, str.length);
//                [str addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:range];
                
                [str addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:textFont.pointSize weight:UIFontWeightBold] range:range];
                if (rangeI.location != NSNotFound) {
                    if (range.length == rangeI.length && range.location == rangeI.location ) {
                    
                        CGAffineTransform matrix =  CGAffineTransformMake(1, 0, tanf(10 * (CGFloat)M_PI / 180), 1, 0, 0);
                        UIFont *font = [UIFont boldSystemFontOfSize:textFont.pointSize];
                        UIFontDescriptor *desc = [UIFontDescriptor fontDescriptorWithName:font.fontName matrix:matrix];
                        
                        [str addAttribute:NSFontAttributeName value:[UIFont fontWithDescriptor:desc size:textFont.pointSize] range:range];
                        
                    }
                }
                rangeB = range;

            }
            
        }
        
        if([item[@"tag"] isEqual:@"A"]){
            if(isOK){
                [str addAttribute:NSForegroundColorAttributeName value:linkColor range:range];
                if([label isKindOfClass:[ZCMLEmojiLabel class]]){

                    
                    if(linkColor!=nil && ( CGColorEqualToColor(linkColor.CGColor,UIColorFromThemeColor(ZCTextNoticeLinkColor).CGColor) || [ZCSTLocalString(@"留言") isEqual:item[@"href"]]|| [ZCSTLocalString(@"更新") isEqual:item[@"href"]])){
    //                         NSDictionary *attribtDic = @{NSUnderlineStyleAttributeName: [NSNumber numberWithInteger:NSUnderlineStyleSingle]};
                        //加下划线
                        [str addAttribute:NSUnderlineStyleAttributeName value:[NSNumber numberWithInteger:NSUnderlineStyleSingle] range:range];
                        if ([ZCSTLocalString(@"留言") isEqual:item[@"href"]] || [ZCSTLocalString(@"更新") isEqual:item[@"href"]]) {
                             [str addAttribute:NSForegroundColorAttributeName value:[ZCUITools zcgetRightChatColor] range:range];
                        }
                        
                        
                    }
                    
                    [((ZCMLEmojiLabel *)label) addLinkToURL:[NSURL URLWithString:item[@"href"]] withRange:range];
                }else{
                    [str addAttribute:NSLinkAttributeName value:[NSURL URLWithString:item[@"href"]] range:range];
                }
            }
        }
        if([item[@"tag"] isEqual:@"I"]){
            
            if (isOK) {
                rangeI = range;
//                NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
//                paragraphStyle.lineSpacing = 4; // 调整行间距
//                //                NSRange range = NSMakeRange(0, str.length);
//                [str addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:range];
                CGAffineTransform matrix =  CGAffineTransformMake(1, 0, tanf(10 * (CGFloat)M_PI / 180), 1, 0, 0);
                UIFont *font = [UIFont systemFontOfSize:textFont.pointSize];
                
                if (rangeB.location != NSNotFound) {
                    if (rangeB.length == range.length && rangeB.location == range.location) {
                        font = [UIFont boldSystemFontOfSize:textFont.pointSize];
                    }
                }
                UIFontDescriptor *desc = [UIFontDescriptor fontDescriptorWithName:font.fontName matrix:matrix];
                [str addAttribute:NSFontAttributeName value:[UIFont fontWithDescriptor:desc size:textFont.pointSize] range:range];
            }
        }
        if([item[@"tag"] isEqual:@"IMG"]){
//            NSString *cachesPath = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) firstObject];
//            NSString *filename = [item[@"src"] lastPathComponent];
//            NSString *file = [cachesPath stringByAppendingPathComponent:filename];
//            NSData *data = [NSData dataWithContentsOfFile:file];
//            if (data) {
//                UIImage *image = [UIImage imageWithData:data];
//                [self insertMs:image dit:item str:str];
//            } else {
//
//                [self insertMs:[UIImage imageNamed:@"Icon-72"] dit:item str:str];
//
//                [self.queue addOperationWithBlock:^{
//                    NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:item[@"src"]]];
//                    UIImage *image = [UIImage imageWithData:data];
//                    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
//                        [self replaceMs:image dit:item str:str];
//                    }];
//
//                    [data writeToFile:file atomically:YES];
//                }];
//            }
        }
        
    }
    
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    
    NSInteger lineSpaceing = [ZCUICore getUICore].kitInfo.lineSpacing;
    if (lineSpaceing > 0) {
        paragraphStyle.lineSpacing = lineSpaceing; // 调整行间距
    }
    
    if(isRTLLayout()){
        [paragraphStyle setAlignment:NSTextAlignmentRight];
    }
    NSRange range = NSMakeRange(0, str.length);
    
    [str addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:range];
    
    
    label.attributedText = str;
    return str;
}

+(NSMutableAttributedString *)setGuideHtml:(NSString *)text attrs:(NSMutableArray *) attrs view:(UILabel *) label  textColor:(UIColor*)textColor textFont:(UIFont*)textFont linkColor:(UIColor*)linkColor{
    
        __block NSMutableAttributedString  *str = nil;
        
        str = [[NSMutableAttributedString alloc] initWithString:text];
        
        // 先处理 ZCMLEmojiLabel 正则的匹配
        if ([label isKindOfClass:[ZCMLEmojiLabel class]]) {
            [label setTextColor:textColor];
            [((ZCMLEmojiLabel *)label) setLinkColor:linkColor];
            [((ZCMLEmojiLabel *)label) setText:str];
            str =[[NSMutableAttributedString alloc] initWithAttributedString:((ZCMLEmojiLabel *)label).attributedText];
        }
        
        [str addAttribute:NSFontAttributeName value:textFont range:NSMakeRange(0, str.length)];
        [str addAttribute:NSForegroundColorAttributeName value:textColor range:NSMakeRange(0, str.length)];
        
        NSRange rangeB;
        NSRange rangeI;
        
        for (NSDictionary *item in attrs) {
            NSRange range = NSMakeRange([item[@"location"] intValue], [item[@"len"] intValue]);
            
            // 2.7.8 防止闪退
            NSUInteger strLength = range.location + range.length;
            BOOL isOK = NO;
            if (strLength<=str.length && str.length>range.location) {
                isOK = YES;
            }
            
            if([item[@"tag"] isEqual:@"B"]){
                if (isOK) {
    //                NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    //                paragraphStyle.lineSpacing = 4; // 调整行间距
    //                //                NSRange range = NSMakeRange(0, str.length);
    //                [str addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:range];
                    
                    [str addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:textFont.pointSize weight:UIFontWeightBold] range:range];
                    if (rangeI.location != NSNotFound) {
                        if (range.length == rangeI.length && range.location == rangeI.location ) {
                        
                            CGAffineTransform matrix =  CGAffineTransformMake(1, 0, tanf(10 * (CGFloat)M_PI / 180), 1, 0, 0);
                            UIFont *font = [UIFont boldSystemFontOfSize:textFont.pointSize];
                            UIFontDescriptor *desc = [UIFontDescriptor fontDescriptorWithName:font.fontName matrix:matrix];
                            
                            [str addAttribute:NSFontAttributeName value:[UIFont fontWithDescriptor:desc size:textFont.pointSize] range:range];
                            
                        }
                    }
                    rangeB = range;

                }
                
            }
            
            if([item[@"tag"] isEqual:@"A"]){
                if(isOK){
                    [str addAttribute:NSForegroundColorAttributeName value:linkColor range:range];
                    if([label isKindOfClass:[ZCMLEmojiLabel class]]){

                        
                        if(linkColor!=nil && ( CGColorEqualToColor(linkColor.CGColor,UIColorFromThemeColor(ZCTextNoticeLinkColor).CGColor) || [ZCSTLocalString(@"留言") isEqual:item[@"href"]]|| [ZCSTLocalString(@"更新") isEqual:item[@"href"]])){
        //                         NSDictionary *attribtDic = @{NSUnderlineStyleAttributeName: [NSNumber numberWithInteger:NSUnderlineStyleSingle]};
                            //加下划线
                            [str addAttribute:NSUnderlineStyleAttributeName value:[NSNumber numberWithInteger:NSUnderlineStyleSingle] range:range];
                            if ([ZCSTLocalString(@"留言") isEqual:item[@"href"]] || [ZCSTLocalString(@"更新") isEqual:item[@"href"]]) {
                                 [str addAttribute:NSForegroundColorAttributeName value:[ZCUITools zcgetRightChatColor] range:range];
                            }
                            
                            
                        }
                        
                        [((ZCMLEmojiLabel *)label) addLinkToURL:[NSURL URLWithString:item[@"href"]] withRange:range];
                    }else{
                        [str addAttribute:NSLinkAttributeName value:[NSURL URLWithString:item[@"href"]] range:range];
                    }
                }
            }
            if([item[@"tag"] isEqual:@"I"]){
                
                if (isOK) {
                    rangeI = range;
    //                NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    //                paragraphStyle.lineSpacing = 4; // 调整行间距
    //                //                NSRange range = NSMakeRange(0, str.length);
    //                [str addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:range];
                    CGAffineTransform matrix =  CGAffineTransformMake(1, 0, tanf(10 * (CGFloat)M_PI / 180), 1, 0, 0);
                    UIFont *font = [UIFont systemFontOfSize:textFont.pointSize];
                    
                    if (rangeB.location != NSNotFound) {
                        if (rangeB.length == range.length && rangeB.location == range.location) {
                            font = [UIFont boldSystemFontOfSize:textFont.pointSize];
                        }
                    }
                    UIFontDescriptor *desc = [UIFontDescriptor fontDescriptorWithName:font.fontName matrix:matrix];
                    [str addAttribute:NSFontAttributeName value:[UIFont fontWithDescriptor:desc size:textFont.pointSize] range:range];
                }
            }
            if([item[@"tag"] isEqual:@"IMG"]){
    //            NSString *cachesPath = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) firstObject];
    //            NSString *filename = [item[@"src"] lastPathComponent];
    //            NSString *file = [cachesPath stringByAppendingPathComponent:filename];
    //            NSData *data = [NSData dataWithContentsOfFile:file];
    //            if (data) {
    //                UIImage *image = [UIImage imageWithData:data];
    //                [self insertMs:image dit:item str:str];
    //            } else {
    //
    //                [self insertMs:[UIImage imageNamed:@"Icon-72"] dit:item str:str];
    //
    //                [self.queue addOperationWithBlock:^{
    //                    NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:item[@"src"]]];
    //                    UIImage *image = [UIImage imageWithData:data];
    //                    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
    //                        [self replaceMs:image dit:item str:str];
    //                    }];
    //
    //                    [data writeToFile:file atomically:YES];
    //                }];
    //            }
            }
            
        }
        
        NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
        
        NSInteger lineSpaceing = [ZCUICore getUICore].kitInfo.guideLineSpacing;
        if (lineSpaceing > 0) {
            paragraphStyle.lineSpacing = lineSpaceing; // 调整行间距
        }else{
            paragraphStyle.lineSpacing = 0; // 调整行间距
        }
        NSRange range = NSMakeRange(0, str.length);
        [str addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:range];
        
        
        label.attributedText = str;
        return str;
    
}


@end
