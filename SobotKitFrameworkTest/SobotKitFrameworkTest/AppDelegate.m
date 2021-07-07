//
//  AppDelegate.m
//  SobotKitFrameworkTest
//
//  Created by zhangxy on 15/11/21.
//  Copyright © 2015年 zhichi. All rights reserved.
//

#import "AppDelegate.h"


#import <SobotKit/SobotKit.h>
//#import "SobotKit.h"
#import <UserNotifications/UserNotifications.h>
#import "ZCGuideHomeController.h"
#import "ViewController.h"
#import "EntityConvertUtils.h"

#define SYSTEM_VERSION_GRATERTHAN_OR_EQUALTO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)

@interface AppDelegate ()<UIApplicationDelegate,UNUserNotificationCenterDelegate>

@end

@implementation AppDelegate

- (UIViewController *)getCurrentVCFrom:(UIViewController *)rootVC
{
    UIViewController *currentVC = rootVC;
    
    while ([currentVC presentedViewController]) {
        // 视图是被presented出来的
        currentVC = [currentVC presentedViewController];
    }
    
    if ([currentVC isKindOfClass:[UITabBarController class]]) {
        // 根视图为UITabBarController
        currentVC = [(UITabBarController *)currentVC selectedViewController];
    }
    
    if ([currentVC isKindOfClass:[UINavigationController class]]){
        // 根视图为UINavigationController
        currentVC = [(UINavigationController *)currentVC visibleViewController];
        
    }
    
    return currentVC;
}
- (UIInterfaceOrientationMask)application:(UIApplication *)application supportedInterfaceOrientationsForWindow:(nullable UIWindow *)window{
//    UIViewController *topVC = [self getCurrentVCFrom:window.rootViewController];
//    if (topVC && ([NSStringFromClass([topVC class]) hasPrefix:@"ZC"])) {
//        return (UIInterfaceOrientationMaskPortrait);
//    }else{
        return UIInterfaceOrientationMaskAll;
//    }
}



- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
     [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
    
//    [UMConfigure initWithAppkey:@"5f23db05d30932215473e055" channel:@"App Store"];
//
//
//    // 开启崩溃收集，默认是YES，如果调试时可以关闭
//    [MobClick setCrashReportEnabled:YES];
//
//    //调试时打开日志，方便调试
//    [UMConfigure setLogEnabled:NO];
    
    
    [[ZCLibClient getZCLibClient] setAutoNotification:YES];
    
    [[ZCLibClient getZCLibClient] setReceivedBlock:^(id message, int nleft, NSDictionary *object) {
        NSLog(@"接收到消息：%@ -- %d",message,nleft);
    }];
    

    
//    ------------      -------------------
     [UIApplication sharedApplication].applicationIconBadgeNumber = 0;

    //设置全局状态栏字体颜色为白色
//     [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleBlackTranslucent;
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];

//    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationNone];
//    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationNone];

    self.window = [[UIWindow alloc]initWithFrame:[UIScreen mainScreen].bounds];

    UITabBarController * tabBar = [[UITabBarController alloc]init];

    self.window.rootViewController = tabBar;


    ViewController * viewController = [[ViewController alloc]init];
//    viewController.tabBarItem.imageInsets = UIEdgeInsetsMake(0, 0, 5, 0);

    [self setTabBarItem:viewController.tabBarItem Title:@"产品介绍" withTitleSize:10.0f andFoneName:@"Helvetica Neue" selectedImage:@"root_menu3_sel" withTitleColor:UIColorFromRGB(0x39B9C2) unselectedImage:@"root_menu1_nor" withTitleColor:UIColorFromRGB(0x8B98AD)];
    UINavigationController * navc1 = [[UINavigationController alloc]initWithRootViewController:viewController];

    ZCGuideHomeController *guideVC = [[ZCGuideHomeController alloc]init];
    [self setTabBarItem:guideVC.tabBarItem Title:@"功能设置" withTitleSize:10.0f andFoneName:@"Helvetica Neue" selectedImage:@"root_menu4_sel" withTitleColor:UIColorFromRGB(0x39B9C2) unselectedImage:@"root_menu2_nor" withTitleColor:UIColorFromRGB(0x8B98AD)];
    UINavigationController * navc4 = [[UINavigationController alloc]initWithRootViewController:guideVC];
    guideVC.title = @"功能设置";
    

    UINavigationBar * bar2 = [UINavigationBar appearance];
    bar2.barTintColor = UIColorFromRGB(0xffffff);// 0x39B9C2


    [UITabBar appearance].translucent = YES;
    tabBar.viewControllers = @[navc1,navc4];
//    tabBar.viewControllers = @[navc1,navc2,navc3];

    [[UITabBar appearance] setBackgroundColor:UIColorFromRGB(0xffffff)];


    [self.window makeKeyWindow];
    
//    ------------      -------------------
    if(SYSTEM_VERSION_GRATERTHAN_OR_EQUALTO(@"10.0")){
        UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
        center.delegate = self;
        [center requestAuthorizationWithOptions:(UNAuthorizationOptionSound | UNAuthorizationOptionAlert | UNAuthorizationOptionBadge) completionHandler:^(BOOL granted, NSError * _Nullable error){
            if( !error ){
               
                 [[UIApplication sharedApplication] registerForRemoteNotifications];

            }
        }];
    }else{
        [self registerPush:application];
    }
    
    // 设置推送是否是测试环境，测试环境将使用开发证书
    [[ZCLibClient getZCLibClient] setAutoNotification:YES];

    [[ZCLibClient getZCLibClient] setReceivedBlock:^(id message, int nleft, NSDictionary *object) {
        NSLog(@"ssss%@ -- %d",message,nleft);
    }];


    // 错误日志收集
//    [ZCLibClient setZCLibUncaughtExceptionHandler];
    
    // 设置切换到后台自动断开长连接，不会影响APP后台挂起时长
    // 进入前台会自动重连，断开期间消息会发送apns推送
    return YES;
}






-(void)registerPush:(UIApplication *)application{
    // ios8后，需要添加这个注册，才能得到授权
    if ([[UIApplication sharedApplication] respondsToSelector:@selector(registerUserNotificationSettings:)]) {
        //IOS8
        //创建UIUserNotificationSettings，并设置消息的显示类类型
        UIUserNotificationSettings *notiSettings = [UIUserNotificationSettings settingsForTypes:(UIUserNotificationTypeBadge | UIUserNotificationTypeAlert | UIRemoteNotificationTypeSound) categories:nil];
        
        [application registerUserNotificationSettings:notiSettings];
    } else{ // ios7
        [application registerForRemoteNotificationTypes:(UIRemoteNotificationTypeBadge|UIRemoteNotificationTypeSound|UIRemoteNotificationTypeAlert)];
    }
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)pToken{
    NSLog(@"---Token--%@", pToken);
    [[ZCLibClient getZCLibClient] setToken:pToken];
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo{
    
    NSString *message = [[userInfo objectForKey:@"aps"]objectForKey:@"alert"];
    
    NSLog(@"userInfo == %@\n%@",userInfo,message);
}



- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error{
    NSLog(@"Regist fail%@",error);
}


// 本地的通知回调事件
- (void)application:(UIApplication *)application didReceiveLocalNotification:(nonnull UILocalNotification *)notification{
    
}
//====================For iOS 10====================

-(void)userNotificationCenter:(UNUserNotificationCenter *)center willPresentNotification:(UNNotification *)notification withCompletionHandler:(void (^)(UNNotificationPresentationOptions options))completionHandler{
    NSLog(@"Userinfo %@",notification.request.content.userInfo);
    
    //功能：可设置是否在应用内弹出通知
    completionHandler(UNNotificationPresentationOptionAlert);
    
}

//点击推送消息后回调
-(void)userNotificationCenter:(UNUserNotificationCenter *)center didReceiveNotificationResponse:(UNNotificationResponse *)response withCompletionHandler:(void(^_Nonnull __strong)())completionHandler{
    NSLog(@"Userinfo %@",response.notification.request.content.userInfo);
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
//   此方法已弃用 [ZCLibClient closeZCServer:NO];
//    [[ZCLibClient getZCLibClient] removeIMAllObserver];
//    [[ZCLibClient getZCLibClient] closeIMConnection];
   
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
//   此方法已弃用 [[ZCLibClient getZCLibClient] aginitIMChat];
//    [[ZCLibClient getZCLibClient] checkIMObserverWithRegister];
//    [[ZCLibClient getZCLibClient] checkIMConnected];
    
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

- (void)setTabBarItem:(UITabBarItem *)tabbarItem
                Title:(NSString *)title
        withTitleSize:(CGFloat)size
          andFoneName:(NSString *)foneName
        selectedImage:(NSString *)selectedImage
       withTitleColor:(UIColor *)selectColor
      unselectedImage:(NSString *)unselectedImage
       withTitleColor:(UIColor *)unselectColor{
    
    //设置图片
    tabbarItem = [tabbarItem initWithTitle:title image:[[UIImage imageNamed:unselectedImage]imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] selectedImage:[[UIImage imageNamed:selectedImage]imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
    
    //未选中字体颜色
    [[UITabBarItem appearance] setTitleTextAttributes:@{NSForegroundColorAttributeName:unselectColor,NSFontAttributeName:[UIFont fontWithName:foneName size:size]} forState:UIControlStateNormal];
    
    //选中字体颜色
    [[UITabBarItem appearance] setTitleTextAttributes:@{NSForegroundColorAttributeName:selectColor,NSFontAttributeName:[UIFont fontWithName:foneName size:size]} forState:UIControlStateSelected];
}

@end
