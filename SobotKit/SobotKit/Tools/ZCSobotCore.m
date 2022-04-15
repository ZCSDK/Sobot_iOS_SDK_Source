//
//  ZCSobotCore.m
//  SobotKit
//
//  Created by zhangxy on 2017/2/14.
//  Copyright © 2017年 zhichi. All rights reserved.
//

#import "ZCSobotCore.h"
#import "ZCStoreConfiguration.h"
#import "ZCIMChat.h"
#import "ZCLibGlobalDefine.h"
#import "ZCLibServer.h"
#import <MediaPlayer/MediaPlayer.h>
#import "ZCToolsCore.h"
#import <AVFoundation/AVFoundation.h>
#import "ZCUICore.h"

@implementation ZCSobotCore


//+(BOOL) checkInitParameterChanged{
//    // 如果杀进程了，此时通道中应该没有数据
//    if([ZCIMChat getZCIMChat].messageArr == nil || [ZCIMChat getZCIMChat].messageArr.count <= 0 || [ZCIMChat getZCIMChat].libConfig == nil || [@"" isEqual:[ZCIMChat getZCIMChat].libConfig.uid]){
//        [ZCStoreConfiguration cleanLocalParamter];
//        
//        [ZCStoreConfiguration setZCParamter:KEY_ZCCONFIGMESSAGE value:[self getCheckConfigMsg]];
//        return YES;
//    }
//        
//    if(![[self getCheckConfigMsg] isEqual:[ZCStoreConfiguration getZCParamter:KEY_ZCCONFIGMESSAGE]]){
//        // 当前是仅机器人或更换了appkey，使用户离线
//        if ([ZCLibClient getZCLibClient].libInitInfo.serviceMode == 1 || ![sobotConvertToString([ZCStoreConfiguration getZCParamter:KEY_ZCCONFIGMESSAGE]) hasPrefix:sobotConvertToString([ZCLibClient getZCLibClient].libInitInfo.appKey)]){
//            // 断开通道，重新初始化
//            [ZCLibClient closeAndoutZCServer:YES];
//        }
//        
//        [ZCStoreConfiguration setZCParamter:KEY_ZCCONFIGMESSAGE value:[self getCheckConfigMsg]];
//        [ZCStoreConfiguration setZCParamter:KEY_ZCISEVALUATIONSERVICE value:@"0"];
//        [ZCStoreConfiguration setZCParamter:KEY_ZCISEVALUATIONROBOT value:@"0"];
//        return YES;
//    }
//   
//    
//    return NO;
//}


/**
 按顺序拼接初始化判断条件
 【必须调用此方法判断，保持顺序统一】

 @return 判断字符串
 */
+(NSString *) getCheckConfigMsg{
    
    ZCLibInitInfo *initInfo = [ZCLibClient getZCLibClient].libInitInfo;
    if(initInfo){
        // appkey，商户Id，技能组、用户id，客服id，对接机器人编号、接入模式
        return [NSString stringWithFormat:@"%@|%@|%@|%@|%@|%@|%d|%@|%@",initInfo.app_key,sobotConvertToString(initInfo.customer_code),initInfo.groupid,initInfo.partnerid,initInfo.choose_adminid,initInfo.robotid,initInfo.service_mode,initInfo.params,initInfo.customer_fields];
    }
    return @"";
}


+(void)getPhotoByType:(NSInteger) buttonIndex byUIImagePickerController:(UIImagePickerController*)zc_imagepicker Delegate:(id)delegate {
    switch (buttonIndex) {
        case 2:
        {
            if ([ZCUITools isHasCaptureDeviceAuthorization]) {

                zc_imagepicker.sourceType=UIImagePickerControllerSourceTypeCamera;
                zc_imagepicker.allowsEditing=NO;
                [(UIViewController *)delegate presentViewController:zc_imagepicker animated:YES completion:^{
                }];
                
            }else{
                NSString * tipMsg = @"";//[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleDisplayName"];
                tipMsg = [tipMsg stringByAppendingString:ZCSTLocalString(@"请在《设置 - 隐私 - 相机》选项中，允许访问您的相机")];
                
                [[ZCToolsCore getToolsCore] showAlert:nil message:tipMsg cancelTitle:ZCSTLocalString(@"好的") titleArray:nil viewController:nil  confirm:^(NSInteger buttonTag) {
                    if(buttonTag == -1){
                        NSURL *url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
                        if ([[UIApplication sharedApplication] canOpenURL:url]) {
                           [[UIApplication sharedApplication] openURL:url];
                        }
                    }
                }];
            }
            break;
        }
        case 1:
        {
            //                从相册选择
            [ZCUITools isHasPhotoLibraryAuthorization:^(BOOL result) {
                if (result) {

                    zc_imagepicker.sourceType=UIImagePickerControllerSourceTypePhotoLibrary;
                    
                    // 处理导航栏和状态栏的透明的问题,并重写他的navc代理方法
                    if (iOS7) {
                        zc_imagepicker.edgesForExtendedLayout = UIRectEdgeNone;
                    }
                    
                    if ([zc_imagepicker.navigationBar respondsToSelector:@selector(setBarTintColor:)]) {
                        // 是否设置相册背景图片
                        if ([ZCUITools zcgetPhotoLibraryBgImage]) {
                            // 图片是否存在
                            if ([ZCUITools zcuiGetBundleImage:@"zcicon_navcbgImage"]) {
                                
                                [zc_imagepicker.navigationBar setBarTintColor:[UIColor colorWithPatternImage:[ZCUITools zcuiGetBundleImage:@"zcicon_navcbgImage"]]];
                            }else{
                                [zc_imagepicker.navigationBar setBarTintColor:[ZCUITools zcgetBgBannerColor]];
                                [zc_imagepicker.navigationBar setTranslucent:YES];
                                [zc_imagepicker.navigationBar setTintColor:[ZCUITools  zcgetBannerTitleColor]];
                            }
                        }else{
                            // 不设置默认治随主题色
                            [zc_imagepicker.navigationBar setBarTintColor:[ZCUITools zcgetBgBannerColor]];
                        }
                        
                        [zc_imagepicker.navigationBar setTranslucent:YES];
                        [zc_imagepicker.navigationBar setTintColor:[ZCUITools  zcgetBannerTitleColor]];
                    }else{
                        [zc_imagepicker.navigationBar setBackgroundColor:[ZCUITools zcgetBgBannerColor]];
                    }
                    // 设置系统相册导航条标题文字的大小
                    //[UIColor colorWithRed:245.0/255.0 green:245.0/255.0 blue:245.0/255.0 alpha:1.0]
                    [zc_imagepicker.navigationBar setTitleTextAttributes: [NSDictionary dictionaryWithObjectsAndKeys:[ZCUITools zcgetBannerTitleColor], NSForegroundColorAttributeName,[ZCUITools zcgetTitleFont], NSFontAttributeName, nil]];
                    
                    // 是否显示预览页面
                    zc_imagepicker.allowsEditing=[ZCUICore getUICore].kitInfo.showPhotoPreview;
                    
                    [(UIViewController *)delegate presentViewController:zc_imagepicker animated:YES completion:^{
                        
                    }];
                }else{
                    NSString * tipMsg = @"";//[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleDisplayName"];
                    tipMsg = [tipMsg stringByAppendingString:ZCSTLocalString(@"请在iPhone的《设置-隐私-照片》选项中，允许访问你的手机相册")];
                    
                    [[ZCToolsCore getToolsCore] showAlert:nil message:tipMsg cancelTitle:ZCSTLocalString(@"好的") titleArray:nil viewController:nil confirm:^(NSInteger buttonTag) {
                        if(buttonTag == -1){
                            NSURL *url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
                            if ([[UIApplication sharedApplication] canOpenURL:url]) {
                               [[UIApplication sharedApplication] openURL:url];
                            }
                        }
                    }];
                }
            }];
            break;
        }
        default:
            break;
    }

}

+(void)imagePickerController:(UIImagePickerController *)zc_imagepicker didFinishPickingMediaWithInfo:(NSDictionary *)info WithView:(UIView *)zc_sourceView Delegate:(id)delegate  block:(DidFinishPickingMediaBlock)finshBlock{
    [zc_imagepicker dismissViewControllerAnimated:NO completion:^{
        NSLog(@"页面消失了");
    }];
    
    if (zc_imagepicker.sourceType == UIImagePickerControllerSourceTypeCamera)
    {
//        UIImage * oriImage = [info objectForKey:UIImagePickerControllerOriginalImage];
//
//        // 发送图片
//        [self sendImage:oriImage withView:zc_sourceView delegate:delegate result:finshBlock];
        
        NSString *mediaType = [info objectForKey:UIImagePickerControllerMediaType];
        if([mediaType isEqualToString:@"public.movie"])
        {
            //视频
            NSURL *videoURL = [info objectForKey:UIImagePickerControllerMediaURL];
            
            [self operateVideo:videoURL view:zc_sourceView block:finshBlock];
        }
        else if([mediaType isEqualToString:@"public.image"]){
                UIImage * oriImage = [info objectForKey:UIImagePickerControllerOriginalImage];
                // 发送图片
                [self sendImage:oriImage withView:zc_sourceView delegate:delegate result:finshBlock];
            }
        else{
            UIImage * originImage = [info objectForKey:UIImagePickerControllerOriginalImage];
            [self sendImage:originImage withView:zc_sourceView delegate:delegate result:finshBlock];
        }
        
        
        
    }
    if (zc_imagepicker.sourceType == UIImagePickerControllerSourceTypePhotoLibrary) {
        NSString *mediaType = [info objectForKey:UIImagePickerControllerMediaType];
        if([mediaType isEqualToString:@"public.movie"])
        {
            //视频
            NSURL *videoURL = [info objectForKey:UIImagePickerControllerMediaURL];
            
            [self operateVideo:videoURL view:zc_sourceView block:finshBlock];
        }
        else{
            UIImage * originImage = [info objectForKey:UIImagePickerControllerOriginalImage];
            [self sendImage:originImage withView:zc_sourceView delegate:delegate result:finshBlock];
        }
    }

}

+(void) operateVideo:(NSURL *)videoURL view:(UIView *)zc_sourceView block:(DidFinishPickingMediaBlock)finshBlock{
    NSDictionary *opts = [NSDictionary dictionaryWithObject:[NSNumber numberWithBool:NO] forKey:AVURLAssetPreferPreciseDurationAndTimingKey];
    AVURLAsset *urlAsset = [AVURLAsset URLAssetWithURL:videoURL options:opts];
    if(!urlAsset){
        
        return;
    }
    CGFloat totalSecond = CMTimeGetSeconds(urlAsset.duration);// urlAsset.duration.value / urlAsset.duration.timescale;
    if(totalSecond >= 16){
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [[ZCUIToastTools shareToast] showToast:ZCSTLocalString(@"上传视频长度不能超过15s") duration:1.0 view:zc_sourceView  position:ZCToastPositionCenter];
        });// zc_sourceView.window.rootViewController.view
        return;
    }
    
    //获取视频的thumbnail
    UIImage  *thumbnail = [self getVideoPreViewImage:videoURL];
    NSData * imageData =UIImageJPEGRepresentation(thumbnail, 0.75f);
    NSString * fname = [NSString stringWithFormat:@"/sobot/image100%ld.jpg",(long)[NSDate date].timeIntervalSince1970];
    sobotCheckPathAndCreate(sobotGetDocumentsFilePath(@"/sobot/"));
    NSString *fullPath=sobotGetDocumentsFilePath(fname);
    [imageData writeToFile:fullPath atomically:YES];
    
    finshBlock(nil,ZCMessageTypeVideo, @{@"video":videoURL,@"image":fullPath});
    return;
    
}


// 获取视频第一帧k
+ (UIImage*) getVideoPreViewImage:(NSURL *)path
{
    AVURLAsset *asset = [[AVURLAsset alloc] initWithURL:path options:nil];
    AVAssetImageGenerator *assetGen = [[AVAssetImageGenerator alloc] initWithAsset:asset];
    
    assetGen.appliesPreferredTrackTransform = YES;
    CMTime time = CMTimeMakeWithSeconds(0.0, 600);
    NSError *error = nil;
    CMTime actualTime;
    CGImageRef image = [assetGen copyCGImageAtTime:time actualTime:&actualTime error:&error];
    UIImage *videoImage = [[UIImage alloc] initWithCGImage:image];
    CGImageRelease(image);
    return videoImage;
}



+(void)sendImage:(UIImage *) image withView:(UIView *)zc_sourceView  delegate:(id)delegate result:(DidFinishPickingMediaBlock)finshBlock{
    UIImage *originImage = [self normalizedImage:image];
    if (originImage) {
        NSData * imageData =UIImageJPEGRepresentation(originImage, 0.75f);
        NSString * fname = [NSString stringWithFormat:@"/sobot/image100%ld.jpg",(long)[NSDate date].timeIntervalSince1970];
        sobotCheckPathAndCreate(sobotGetDocumentsFilePath(@"/sobot/"));
        NSString *fullPath=sobotGetDocumentsFilePath(fname);
        [imageData writeToFile:fullPath atomically:YES];
        CGFloat mb=imageData.length/1024/1024;
        if(mb>20){
            if(((UIViewController *)delegate).navigationController){
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    [[ZCUIToastTools shareToast] showToast:ZCSTLocalString(@"图片大小需小于20M!") duration:1.0 view:zc_sourceView.window.rootViewController.view  position:ZCToastPositionCenter];
                });
            }else{
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    [[ZCUIToastTools shareToast] showToast:ZCSTLocalString(@"图片大小需小于20M!") duration:1.0 view:zc_sourceView  position:ZCToastPositionCenter];
                });
            }
            return;
        }
        
        if (finshBlock) {
            finshBlock(fullPath,ZCMessageTypePhoto,nil);
        }
    }
}

/**
 *  获取视频的缩略图方法
 *
 *  @param filePath 视频的本地路径
 *
 *  @return 视频截图
 */
- (UIImage *)getScreenShotImageFromVideoPath:(NSString *)filePath{
    
    UIImage *shotImage;
    //视频路径URL
    NSURL *fileURL = [NSURL fileURLWithPath:filePath];
    AVURLAsset *asset = [[AVURLAsset alloc] initWithURL:fileURL options:nil];
    AVAssetImageGenerator *gen = [[AVAssetImageGenerator alloc] initWithAsset:asset];
    gen.appliesPreferredTrackTransform = YES;
    CMTime time = CMTimeMakeWithSeconds(0.0, 600);
    NSError *error = nil;
    CMTime actualTime;
    CGImageRef image = [gen copyCGImageAtTime:time actualTime:&actualTime error:&error];
    shotImage = [[UIImage alloc] initWithCGImage:image];
    CGImageRelease(image);
    return shotImage;
}


+ (UIImage *)normalizedImage:(UIImage *) image {
    if (image.imageOrientation == UIImageOrientationUp) return image;
    
    UIGraphicsBeginImageContextWithOptions(image.size, NO, image.scale);
    [image drawInRect:(CGRect){0, 0, image.size}];
    UIImage *normalizedImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return normalizedImage;
}



@end
