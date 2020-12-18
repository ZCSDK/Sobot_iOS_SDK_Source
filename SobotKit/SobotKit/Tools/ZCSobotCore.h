//
//  ZCSobotCore.h
//  SobotKit
//
//  Created by zhangxy on 2017/2/14.
//  Copyright © 2017年 zhichi. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ZCKitInfo.h"
#import "ZCLibClient.h"
#import "ZCLibMessageConstants.h"
//#import "ZCUIKeyboardDelegate.h"

/**
 *  DidFinishPickingMediaBlock
 */
typedef void(^DidFinishPickingMediaBlock)(NSString *filePath , ZCMessageType type, NSDictionary *duration);

/**
 *  ZCSobotCore
 */
@interface ZCSobotCore : NSObject


/**
 *  根据类型获取图片
 *  @param zc_imagepicker UIImagePickerController
 *  @param buttonIndex 2，来源照相机，1来源相册
 *  @param delegate       ZCUIKeyboardDelegate
 *
 */
+(void)getPhotoByType:(NSInteger) buttonIndex byUIImagePickerController:(UIImagePickerController*)zc_imagepicker Delegate:(id)delegate ;


/**
 *  系统相机相册的完成的代理事件
 *  @param zc_imagepicker  UIImagePickerController
 *  @param zc_sourceView   父类VC的view
 *  @param delegate       ZCUIKeyboardDelegate
 *  @param info           图片资源
 */
+(void)imagePickerController:(UIImagePickerController *)zc_imagepicker
didFinishPickingMediaWithInfo:(NSDictionary *)info WithView:(UIView *)zc_sourceView
                    Delegate:(id)delegate block:(DidFinishPickingMediaBlock) finshBlock;



/**
 发送图片

 @param image 图片 UIImage
 @param zc_sourceView
 @param delegate
 @param finshBlock 
 */
+(void)sendImage:(UIImage *) image withView:(UIView *)zc_sourceView  delegate:(id)delegate result:(DidFinishPickingMediaBlock)finshBlock;

@end
