//
//  ZCToolsCore.m
//  SobotKit
//
//  Created by zhangxy on 2018/1/29.
//  Copyright © 2018年 zhichi. All rights reserved.
//

#import "ZCToolsCore.h"
#import "ZCLibGlobalDefine.h"
#import "ZCUICore.h"
#import "ZCUIWebController.h"
#import "ZCUITools.h"
#import "ZCVideoPlayer.h"

#define RootVC  [[UIApplication sharedApplication] keyWindow].rootViewController

@implementation ZCToolsCore

static ZCToolsCore *_instance = nil;
static dispatch_once_t onceToken;
+(ZCToolsCore *)getToolsCore{
    dispatch_once(&onceToken, ^{
        if(_instance == nil){
            _instance = [[ZCToolsCore alloc] initPrivate];
        }
    });
    return _instance;
}

-(id)initPrivate{
    self=[super init];
    if(self){
        
    }
    return self;
}

-(id)init{
    return [[self class] getToolsCore];
}



-(void)clear{
    onceToken=0;
    _instance = nil;
    
}


-(NSArray *)coderDetectorWith:(UIImage *)image {
    //    CIImage *detectImage = [CIImage imageWithData:UIImagePNGRepresentation(image)];
    // 声明一个 CIDetector，并设定识别类型 CIDetectorTypeQRCode
    // 创建图形上下文
    CIContext * context = [CIContext contextWithOptions:nil];
    // 创建自定义参数字典
    NSDictionary * param = [NSDictionary dictionaryWithObject:CIDetectorAccuracyHigh forKey:CIDetectorAccuracy];
    // 创建识别器对象
    CIDetector * detector = [CIDetector detectorOfType:CIDetectorTypeQRCode context:context options:param];
    
    // 取得识别结果
    NSArray *features = [detector featuresInImage:[CIImage imageWithCGImage:image.CGImage]];
    NSMutableArray *array = [NSMutableArray array];
    if (features.count == 0) {
        
        //        NSLog(@"暂未识别出扫描的二维码");
    } else {
        
        for (int index = 0; index < [features count]; index ++) {
            
            CIQRCodeFeature *feature = [features objectAtIndex:index];
            NSString *resultStr = feature.messageString;
            //            NSLog(@"相册中读取二维码数据信息 - - %@", resultStr);
            [array addObject:resultStr];
        }
    }
    NSSet *set = [NSSet setWithArray:array];
    NSArray *sortDesc = @[[[NSSortDescriptor alloc] initWithKey:nil ascending:YES]];
    NSArray *sortSetArray = [set sortedArrayUsingDescriptors:sortDesc];
    return [sortSetArray copy];
}

// 检测图片中的二维码,返回 一个URL 字符串，或者nil
-(id )coderURLStrDetectorWith:(UIImage *)image{
    NSArray *urlStrArray = [self coderDetectorWith:image];
    if (urlStrArray.count == 1) {
        NSString *urlStr = urlStrArray.firstObject;
        return urlStr;
    }else{
        return nil;
    }
}

- (BOOL)isUrl:(NSString *)urlString{
    if(urlString == nil)
        return NO;
    NSString *url;
    if (urlString.length>4 && [[urlString substringToIndex:4] isEqualToString:@"www."]) {
        url = [NSString stringWithFormat:@"http://%@",urlString];
        
    }else{
        url = urlString;
        
    }
    
    NSString*urlRegex = ([ZCUICore getUICore].kitInfo!=nil && [ZCUICore getUICore].kitInfo.urlRegular!=nil && [ZCUICore getUICore].kitInfo.urlRegular.length>0) ? [ZCUICore getUICore].kitInfo.urlRegular:@"((http[s]{0,1}|ftp)://[a-zA-Z0-9\\.\\-]+\\.([a-zA-Z0-9]{1,4})(:\\d+)?(/[a-zA-Z0-9\\.\\-~!@#$%^&*+?:_/=<>]*)?)|(([a-zA-Z0-9]{2,4}).[a-zA-Z0-9\\.\\-]+\\.([a-zA-Z]{2,4})(:\\d+)?(/[a-zA-Z0-9\\.\\-~!@#$%^&*+?:_/=<>]*)?)";
    
    
    
    NSPredicate* urlTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", urlRegex];
    return [urlTest evaluateWithObject:url];
    
}

-(void)setRTLFrame:(UIView *)view{
    if (isRTLLayout() && view!=nil) {
        
        CGFloat width = ScreenWidth;
        if (view.superview == nil) {
//            NSAssert(0, @"must invoke after have superView");
        }else{
            width = view.superview.frame.size.width;
        }
        
        
        CGRect frame = view.frame;
        CGFloat x = width - frame.origin.x - frame.size.width;
        frame.origin.x = x;

        view.frame = frame;
    }
}

/**
 *  创建提示框
 *
 *  @param title        标题
 *  @param message      提示内容
 *  @param cancelTitle  取消按钮(无操作,为nil则只显示一个按钮)
 *  @param titleArray   标题字符串数组(为nil,默认为"确定")
 *  @param vc           VC
 *  @param confirm      点击确认按钮的回调
 */
- (void)showAlert:(NSString *)title
          message:(NSString *)message
      cancelTitle:(NSString *)cancelTitle
       titleArray:(NSArray *)titleArray
   viewController:(UIViewController *)vc
          confirm:(AlertViewBlock)confirm {
    //
    if (!vc) vc = RootVC;
    
    [self p_showAlertController:title message:message
                    cancelTitle:cancelTitle titleArray:titleArray
                 viewController:vc confirm:^(NSInteger buttonTag) {
                     if (confirm)confirm(buttonTag);
                 }];
}


/**
 *  创建提示框(可变参数版)
 *
 *  @param title        标题
 *  @param message      提示内容
 *  @param cancelTitle  取消按钮(无操作,为nil则只显示一个按钮)
 *  @param vc           VC
 *  @param confirm      点击按钮的回调
 *  @param buttonTitles 按钮(为nil,默认为"确定",传参数时必须以nil结尾，否则会崩溃)
 */
- (void)showAlert:(NSString *)title
          message:(NSString *)message
      cancelTitle:(NSString *)cancelTitle
   viewController:(UIViewController *)vc
          confirm:(AlertViewBlock)confirm
     buttonTitles:(NSString *)buttonTitles, ... NS_REQUIRES_NIL_TERMINATION {
    
    // 读取可变参数里面的titles数组
    NSMutableArray *titleArray = [[NSMutableArray alloc] initWithCapacity:0];
    va_list list;
    if(buttonTitles) {
        //1.取得第一个参数的值(即是buttonTitles)
        [titleArray addObject:buttonTitles];
        //2.从第2个参数开始，依此取得所有参数的值
        NSString *otherTitle;
        va_start(list, buttonTitles);
        while ((otherTitle = va_arg(list, NSString*))) {
            [titleArray addObject:otherTitle];
        }
        va_end(list);
    }
    
    if (!vc) vc = RootVC;
    
    [self p_showAlertController:title message:message
                    cancelTitle:cancelTitle titleArray:titleArray
                 viewController:vc confirm:^(NSInteger buttonTag) {
                     if (confirm)confirm(buttonTag);
                 }];
    
}

- (void)p_showAlertController:(NSString *)title
                      message:(NSString *)message
                  cancelTitle:(NSString *)cancelTitle
                   titleArray:(NSArray *)titleArray
               viewController:(UIViewController *)vc
                      confirm:(AlertViewBlock)confirm {
    
    UIAlertController  *alert = [UIAlertController alertControllerWithTitle:title
                                                                    message:message
                                                             preferredStyle:UIAlertControllerStyleAlert];
    //修改title
//    NSMutableAttributedString *alertControllerStr = [[NSMutableAttributedString alloc] initWithString:@"提示"];
//    [alertControllerStr addAttribute:NSForegroundColorAttributeName value:[UIColor redColor] range:NSMakeRange(0, 2)];
//    [alertControllerStr addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:17] range:NSMakeRange(0, 2)];
//    [alertController setValue:alertControllerStr forKey:@"attributedTitle"];
//
//    //修改message
//    NSMutableAttributedString *alertControllerMessageStr = [[NSMutableAttributedString alloc] initWithString:@"提示内容"];
//    [alertControllerMessageStr addAttribute:NSForegroundColorAttributeName value:[UIColor greenColor] range:NSMakeRange(0, 4)];
//    [alertControllerMessageStr addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:20] range:NSMakeRange(0, 4)];
//    [alertController setValue:alertControllerMessageStr forKey:@"attributedMessage"];
    
    // 下面两行代码 是修改 title颜色和字体的代码
        //NSAttributedString *attributedMessage = [[NSAttributedString alloc] initWithString:message attributes:@{NSForegroundColorAttributeName:kSystemBlackColor}];
        //[alert setValue:attributedMessage forKey:@"attributedMessage"];
    
    if (cancelTitle) {
        // 取消
        UIAlertAction  *cancelAction = [UIAlertAction actionWithTitle:cancelTitle
                                                                style:UIAlertActionStyleCancel
                                                              handler:^(UIAlertAction * _Nonnull action) {
                                                                  if (confirm)confirm(-1);
                                                              }];
//        [cancelAction setValue:kL2TextFont forKey:@"titleFont"];
      //  [cancelAction setValue:kSystemLightGrayColor forKey:@"titleTextColor"];
        [alert addAction:cancelAction];
    }
    // 确定操作
    if (!titleArray || titleArray.count == 0) {
        UIAlertAction  *confirmAction = [UIAlertAction actionWithTitle:ZCSTLocalString(@"确定")
                                                                 style:UIAlertActionStyleDefault
                                                               handler:^(UIAlertAction * _Nonnull action) {
                                                                   if (confirm)confirm(0);
                                                               }];
//        [confirmAction setValue:kL2TextFont forKey:@"titleFont"];
        //[confirmAction setValue:kSystemBaseColor forKey:@"titleTextColor"];
        [alert addAction:confirmAction];
    } else {
        for (NSInteger i = 0; i<titleArray.count; i++) {
            UIAlertAction  *action = [UIAlertAction actionWithTitle:titleArray[i]
                                                              style:UIAlertActionStyleDefault
                                                            handler:^(UIAlertAction * _Nonnull action) {
                                                                if (confirm)confirm(i);
                                                            }];
          //  [action setValue:kSystemBaseColor forKey:@"titleTextColor"];
            [alert addAction:action];
        }
    }
    
    alert.popoverPresentationController.sourceView = vc.view;
    alert.popoverPresentationController.sourceRect = CGRectMake(0,0,1.0,1.0);
    [vc presentViewController:alert animated:YES completion:nil];
    
}

- (void)dealWithLinkClickWithLick:(NSString *)link viewController:(UIViewController *)viewController{
    if(zcLibConvertToString(link).length == 0){
        return;
    }
    
    if([[zcLibConvertToString(link) lowercaseString] hasSuffix:@".mp4"]){
        UIWindow *window = [[ZCToolsCore getToolsCore] getCurWindow];
        ZCVideoPlayer *player = [[ZCVideoPlayer alloc] initWithFrame:window.bounds withShowInView:window url:[NSURL URLWithString:link] Image:nil];
        [player showControlsView];
        return;
    }
    
    if([[ZCUICore getUICore] LinkClickBlock] == nil || ![ZCUICore getUICore].LinkClickBlock(link)){
        if([link hasPrefix:@"tel:"] || zcLibValidateMobileWithRegex(link, [ZCUITools zcgetTelRegular])){
            
            if(![link hasSuffix:@"tel:"]){
                link = [NSString stringWithFormat:@"tel:%@",link];
            }
            if (NSFoundationVersionNumber <= NSFoundationVersionNumber_iOS_9_x_Max) {
                [[ZCToolsCore getToolsCore] showAlert:nil message:[link stringByReplacingOccurrencesOfString:@"tel:" withString:@""] cancelTitle:ZCSTLocalString(@"取消") viewController:viewController confirm:^(NSInteger buttonTag) {
                    if(buttonTag>=0){
                        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:link]];
                    }
                } buttonTitles:ZCSTLocalString(@"呼叫"), nil];
            }else{
                // 打电话
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:link]];
            }
        }else if([link hasPrefix:@"mailto:"] || zcLibValidateEmail(link)){
            if(![link hasSuffix:@"mailto:"]){
                link = [NSString stringWithFormat:@"mailto:%@",link];
            }
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:link]];
        }else{
            NSString *urlStr;
            if ([[ZCToolsCore getToolsCore] isUrl:link]) {
                if (![link hasPrefix:@"https"] && ![link hasPrefix:@"http"]) {
                    link = [@"https://" stringByAppendingString:link];
                }
                urlStr = zcUrlEncodedString(link);
            }else{
                urlStr = link;
            }
            ZCUIWebController *webPage=[[ZCUIWebController alloc] initWithURL:urlStr];
            if(viewController.navigationController != nil ){
                [viewController.navigationController pushViewController:webPage animated:YES];
            }else{
                UINavigationController *nav=[[UINavigationController alloc] initWithRootViewController:webPage];
                nav.navigationBarHidden=YES;
                nav.modalPresentationStyle = UIModalPresentationOverFullScreen;
                [viewController presentViewController:nav animated:YES completion:^{
                }];
            }
        }
    }
}


///
-(int)getCurScreenDirection{
    int direction = 0;
    if ([UIApplication sharedApplication].statusBarOrientation == UIInterfaceOrientationLandscapeLeft) {
        direction = 1;// UIInterfaceOrientationLandscapeLeft;
        
    }
    if([UIApplication sharedApplication].statusBarOrientation == UIInterfaceOrientationLandscapeRight){
        // X坐标应该从 spaceX = XBottomBarHeight;开始
        direction = 2;// UIInterfaceOrientationLandscapeRight;
        
    }
    return direction;
}


-(CGRect )settingPortraitOrLandspace:(UITableView *)tableView{
    // 关闭安全区域，否则UITableViewCell横屏时会是全屏的宽, tableview必须设置以下属性，否则配置不生效
//    NSString *version = [UIDevice currentDevice].systemVersion;
//    if (version.doubleValue >= 11.0) {
//        [_listTable setInsetsContentViewsToSafeArea:NO];
//    }
    
    CGFloat spaceX = 0;
    CGFloat spaceWidth = 0;
    UIInterfaceOrientation direction = [self getCurScreenDirection];
    if (direction == UIInterfaceOrientationLandscapeLeft || direction == UIInterfaceOrientationLandscapeRight) {
       spaceWidth = XBottomBarHeight;
       
       if(direction == UIInterfaceOrientationLandscapeRight){
           spaceX = XBottomBarHeight;
       }
    }
    
    CGRect f = tableView.frame;
    f.origin.x = spaceX;
    f.size.width = f.size.width - spaceWidth;
    
    tableView.frame = f;
    return f;
}



-(UIWindow *)getCurWindow{
    UIWindow* window = nil;
    id appDelegate = [UIApplication sharedApplication].delegate;
    if (appDelegate && [appDelegate respondsToSelector:@selector(window)]) {
        window = [appDelegate window];
        
        // 获取最上层Window，2.8.5添加，如果新建一个window会导致无法看到适配页面
        for (UIWindow *win in [[UIApplication sharedApplication].windows reverseObjectEnumerator]) {
            if ([win isEqual:window]) {
                continue;
            }
            if (win.windowLevel >= window.windowLevel && win.hidden != YES && win.isKeyWindow) {
                window =win;
            }
        }
    }
    
    if(window == nil){
        NSString *version = [UIDevice currentDevice].systemVersion;
        if (version.doubleValue >= 13.0)
        {
            for (UIWindowScene* windowScene in [UIApplication sharedApplication].connectedScenes)
            {
                if (windowScene.activationState == UISceneActivationStateForegroundActive)
                {
                    window = windowScene.windows.firstObject;
                    break;
                }
            }
        }
    }
    return window;
}

@end
