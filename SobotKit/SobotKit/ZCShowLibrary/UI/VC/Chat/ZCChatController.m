//
//  ZCChatController.m
//  SobotKit
//
//  Created by zhangxy on 2018/1/29.
//  Copyright © 2018年 zhichi. All rights reserved.
//

#import "ZCChatController.h"

#import "ZCLibGlobalDefine.h"

#import "ZCUIImageTools.h"
#import "ZCUICore.h"
#import "ZCLibServer.h"
#import "ZCAutoListView.h"
//#import "ZCTitleView.h"
#import "ZCUIColorsDefine.h"
#import "ZCToolsCore.h"

#define MinViewWidth 320
#define MinViewHeight 540
#import "ZCLibClient.h"

@interface ZCChatController ()<ZCChatViewDelegate>{
    
}

@property (nonatomic,strong) ZCChatView * chatView;

//@property (nonatomic,strong)NSDate *countDate;

@end

@implementation ZCChatController

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    if ([ZCUICore getUICore].kitInfo.navcBarHidden) {
        self.navigationController.navigationBarHidden = YES;
    }else{
        [self setNavigationBarStyle];
    }

    
    // 从其他页面返回时，重新布局
    if(self.chatView){
        [self viewDidLayoutSubviews];
    }
    
    
    [_chatView beginAniantions];

    
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
    [ZCAutoListView getAutoListView].isAllowShow = YES;
    
    // 如果多级返回的，此数据为空
    if([ZCUICore getUICore].listArray == nil){
        // 多级跳转的时候，需要重新初始化一次UI
        [_chatView showZCChatView:[ZCUICore getUICore].kitInfo];
    }
#pragma mark -- 查看当前时间和之前记录的时间差值是否相差30min 如果达到，重新初始化
//    if (_countDate != nil) {
//        NSDate *currtDate = [NSDate date];
//        NSTimeInterval distanceBetweenDates = [currtDate timeIntervalSinceDate:_countDate];
//        CGFloat hours = distanceBetweenDates / 3600;
//        if (hours>0.5) {
//            [[ZCUICore getUICore] initConfigData:YES IsNewChat:YES];
//            _countDate = nil;
//        }
//    }
}

-(void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];

    [ZCAutoListView getAutoListView].isAllowShow = NO;
    
//    NSDate *newdate = [NSDate date];
//    _countDate = newdate;
}

- (BOOL)shouldAutorotate {
    return YES;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}


//**************************项目中的导航栏一部分是自定义的View,一部分是系统自带的NavigationBar*********************************
- (void)setNavigationBarStyle{
    NSMutableArray *itemsArr = [[NSMutableArray alloc] init];
    if(![ZCUICore getUICore].kitInfo.hideNavBtnMore){
        [itemsArr addObject:@(BUTTON_MORE)];
    }
    
    if ([ZCUICore getUICore].kitInfo.isShowEvaluation || [ZCUICore getUICore].kitInfo.isShowTelIcon) {
        if ([ZCUICore getUICore].kitInfo.isShowEvaluation) {
            [itemsArr addObject:@(BUTTON_EVALUATION)];
        }
        if([ZCUICore getUICore].kitInfo.isShowTelIcon){
             [itemsArr addObject:@(BUTTON_TEL)];
        }
        
    }
    if([ZCUICore getUICore].kitInfo.isShowClose){
        if (self.isArtificial) {
            [itemsArr addObject:@(BUTTON_CLOSE)];
        }
    }
    
    [self setNavigationBarLeft:@[@(BUTTON_BACK)] right:itemsArr];


    if(_titleView==nil){
        CGFloat maxWidth = itemsArr.count * 40 + itemsArr.count * 15;
        _titleView = [[ZCTitleView alloc] initWithFrame:CGRectMake(maxWidth, 0, ScreenWidth - maxWidth*2, 44)];
        [self.titleView setAutoresizingMask:UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleTopMargin];
        [self.titleView setAutoresizesSubviews:YES];
        self.navigationItem.titleView = _titleView;
    }
}


- (void)viewDidLoad {
    [super viewDidLoad];
    
    CGFloat viewHeigth = self.view.frame.size.height;

    self.view.userInteractionEnabled = YES;
    
    if ([ZCUICore getUICore].kitInfo.navcBarHidden) {
        self.navigationController.navigationBarHidden = YES;
        if (self.navigationController.navigationBar.translucent) {
            self.navigationController.navigationBar.translucent = NO;
        }
    }
    if (self.navigationController.navigationBarHidden ) {
        self.navigationController.navigationBar.translucent = NO;
    }
    
    if (!self.navigationController.navigationBarHidden || self.navigationController.navigationBar.translucent) {
        [self setNavigationBarStyle];
        self.navigationController.interactivePopGestureRecognizer.delegate = (id)self;
        self.navigationController.navigationBar.translucent = NO;
        
    }
    

    self.view.backgroundColor = UIColorFromThemeColor(ZCBgSystemWhiteLightDarkColor);//[ZCUITools zcgetBackgroundColor];
    
    CGFloat startY = 0;
    CGFloat chatHeight = viewHeigth;
    
    if (!self.navigationController.navigationBarHidden) {
        // 使用系统导航栏的时候
        if(self.navigationController.navigationBar.translucent){
            startY = NavBarHeight;
            chatHeight = viewHeigth - NavBarHeight ;
        }else{
            startY = 0;
            chatHeight = viewHeigth -NavBarHeight ;
        }
    }
    
    chatHeight = chatHeight - XBottomBarHeight ;//(isLandspace?0:XBottomBarHeight);

    
    // 创建聊天视图
    _chatView = [[ZCChatView alloc]initWithFrame:CGRectMake(0, startY, self.view.frame.size.width, chatHeight) WithSuperController:self customNav:!self.navigationController.navigationBarHidden];
    _chatView.autoresizesSubviews = YES;
    _chatView.autoresizingMask = UIViewAutoresizingFlexibleWidth |UIViewAutoresizingFlexibleHeight;
    _chatView.delegate = self;
    if (self.chatdelegate && [_chatdelegate respondsToSelector:@selector(openLeaveMsgClick:)]) {
        _chatView.isJumpCustomLeaveVC = YES;
    }

    [self.view addSubview:_chatView];
    [_chatView showZCChatView:[ZCUICore getUICore].kitInfo];
    
    // 用户在自己的页面关闭智齿页面
    [ZCUICore getUICore].ZCClosePageBlock = ^(ZCPagesType type) {
        if (type == ZC_UserClosePage) {
            [self closePage];
        }
    };
}

- (void)orientChange:(NSNotification *)notification{
    if([self orientationChanged]){
        // 切换的方法必须调用
        [self viewDidLayoutSubviews];
    }
}



-(void)buttonClick:(UIButton *)sender{
    if (sender.tag == BUTTON_BACK) {
        // 返回提醒开关
        if ([ZCUICore getUICore].kitInfo.isShowReturnTips) {
           [[ZCToolsCore getToolsCore] showAlert:ZCSTLocalString(@"您是否要结束会话?") message:nil cancelTitle:ZCSTLocalString(@"暂时离开") titleArray:@[ZCSTLocalString(@"结束会话")] viewController:self  confirm:^(NSInteger buttonTag) {
//               self.countDate = nil;
               [[ZCUICore getUICore] setclosepamasAndClearConfig];
               if(buttonTag >= 0){
                   // 点击关闭，离线用户
                   [self.chatView confimGoBackWithType:ZCChatViewGoBackType_close];
               }else{
                   [self.chatView setIsCloseNo];
                   if (self.navigationController && _isPush) {
                       // 滑动返回会调用 goBack方法
                       [self.navigationController popViewControllerAnimated:YES];
                   }else{
                       [self goBack];
                       [self dismissViewControllerAnimated:YES completion:nil];
                   }
               }
           }];
            return;
        }
        // 点击返回，清理数据
        [self.chatView confimGoBackWithType:ZCChatViewGoBackType_normal];
//        self.countDate = nil;
        [[ZCUICore getUICore] setclosepamasAndClearConfig];
    }else if (sender.tag == BUTTON_CLOSE) {
//        self.countDate = nil;
        [[ZCUICore getUICore] setclosepamasAndClearConfig];
        // 点击关闭，离线用户
        [self.chatView confimGoBackWithType:ZCChatViewGoBackType_close];
    }else if (sender.tag == BUTTON_MORE){
        // 点击清理数据事件
        [self.chatView cleanHistoryMessage];
    }else if (sender.tag == BUTTON_EVALUATION){
        // 去评价
        [self.chatView goEvaluation];
    }else if (sender.tag == BUTTON_TEL){
        if([ZCUICore getUICore].ZCViewControllerCloseBlock != nil){
            [ZCUICore getUICore].ZCViewControllerCloseBlock(self,ZC_PhoneCustomerService);
        }
        // 去打电话
        NSString *phoneNumber = [NSString stringWithFormat:@"tel:%@",sobotConvertToString([ZCUICore getUICore].kitInfo.customTel)];
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:phoneNumber]];
    }
    
}

-(void)goBack{
     NSLog(@"页面清理了数据啊");
    if(self.chatView !=nil){
       [self.chatView dismissZCChatView];
    }
    if([ZCUICore getUICore].ZCViewControllerCloseBlock != nil){
        [ZCUICore getUICore].ZCViewControllerCloseBlock(self,ZC_CloseChat);
    }
}

-(void)didMoveToParentViewController:(UIViewController *)parent{
    
    [super didMoveToParentViewController:parent];
//    NSLog(@"页面侧滑返回：%@",parent);
    if(!parent){
        [self goBack];
    }
}

- (void)interfaceOrientation:(UIInterfaceOrientation)orientation {
    if ([[UIDevice currentDevice] respondsToSelector:@selector(setOrientation:)]) {
        SEL selector             = NSSelectorFromString(@"setOrientation:");
        NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:[UIDevice instanceMethodSignatureForSelector:selector]];
        [invocation setSelector:selector];
        [invocation setTarget:[UIDevice currentDevice]];
//        int val                  = orientation;
        [invocation setArgument:&orientation atIndex:2];
        [invocation invoke];
    }
}

/**
 监听顶部点击事件，返回/ 更多(清空历史记录)

 @param Tag
 */
-(void)topViewBtnClick:(ZCButtonClickTag)Tag{
    if (Tag == BUTTON_BACK) {
        // 延迟返回，解决"Unable to insert COPY_SEND" 警告
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            if (self.navigationController && _isPush) {
                [self.navigationController popViewControllerAnimated:YES];
            }else{
                [self goBack];
                [self dismissViewControllerAnimated:YES completion:nil];
            }
        });
        
        // 延迟清理数据，解决返回是白屏
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            if([ZCUICore getUICore].listArray!=nil){
                [_chatView dismissZCChatView];
                _chatView = nil;
            }
        });

    }else if (Tag == BUTTON_MORE){
        
    }
}


/**
 点击到留言

 @param tipMsg
 */
-(void)onLeaveMsgClick:(NSString *)tipMsg{
    // 通过代理通知外部留言点击了
    if(_chatdelegate && [_chatdelegate respondsToSelector:@selector(openLeaveMsgClick:)]){
        [_chatdelegate openLeaveMsgClick:tipMsg];
    }
    if ([ZCUICore getUICore].PageLoadBlock) {
        [ZCUICore getUICore].PageLoadBlock(self, ZCPageBlockLeave);
    }
}



/**
 更换标题

 @param title
 */
-(void)onTitleChanged:(NSString *)title imageUrl:(NSString *)url{
    // 如果是使用系统导航，更换标题
    if(!self.navigationController.navigationBarHidden){
        [self.titleView setTitle:sobotConvertToString(title) image:url];
    }
}

- (void)onPageStatusChange:(BOOL)isArtificial{
    if(self.isArtificial == isArtificial){
        return;
    }
        
    self.isArtificial = isArtificial;
    
    if ([ZCUICore getUICore].kitInfo.navcBarHidden) {
        self.navigationController.navigationBarHidden = YES;
    }else{
        [self setNavigationBarStyle];
    }
    
}

/**
 横竖屏切换时，刷新页面布局
 */
-(void)viewDidLayoutSubviews{
    [super viewDidLayoutSubviews];
    
    
    
    CGRect vf = self.chatView.frame;
    vf.size.height = [self getCurViewHeight];
    
    CGFloat startY = 0;
    CGFloat chatHeight = [self getCurViewHeight];
    
    if (!self.navigationController.navigationBarHidden) {
        // 使用系统导航栏的时候
        if(self.navigationController.navigationBar.translucent){
            startY = NavBarHeight;   // 设置了透明度 添加子视图的 （0，0）点坐标是从 导航栏的下标开始计算的 chatView的0点坐标 就是相对chatVC （0，NavBarHeight）
            chatHeight = [self getCurViewHeight] - NavBarHeight ;
            if([self getCurViewWidth] > [self getCurViewHeight]){

                startY = self.navigationController.navigationBar.frame.size.height;   // 设置了透明度 添加子视图的 （0，0）点坐标是从 导航栏的下标开始计算的 chatView的0点坐标 就是相对chatVC （0，NavBarHeight）
                chatHeight = [self getCurViewHeight] - startY ;
            }
            
            
        }else{
            startY = 0; // 不设置透明度 添加子视图的坐标 （0，0） 同chatVC的（0，0）一致
            chatHeight = [self getCurViewHeight] -NavBarHeight ;
            if(NavBarHeight != self.view.frame.origin.y && XBottomBarHeight == 0){
                chatHeight = self.view.frame.size.height;
            }
        }
        int itemsArrcount = (int)self.navigationItem.rightBarButtonItems.count;
        CGFloat maxWidth = itemsArrcount * 44 + itemsArrcount * 15;
        if(self.titleView!=nil){
            self.titleView.frame = CGRectMake(0, 0, self.view.frame.size.width - maxWidth*2, 44);
        }
    }
    chatHeight = chatHeight - XBottomBarHeight;//(isLandspace?0:XBottomBarHeight);
    
    
    vf.origin.y = startY;
    vf.size.height = chatHeight;
    _chatView.frame = vf;
    
    [_chatView setNeedsLayout];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/


//-(UIView*)hitTest:(CGPoint)point withEvent:(UIEvent *)event{
////    UIView * view = [super hitTest:point withEvent:event];
//    if (view == nil) {
//        CGPoint staitionPoint = [self.chatView convertPoint:point fromView:self];
//        if (CGRectContainsPoint(self.chatView.bounds, staitionPoint)) {
//            view = self.chatView;
//        }
//    }
//}
-(id)initWithInitInfo:(ZCKitInfo *)info{
    self=[super init];
    if(self){
        if(info !=nil && !sobotIsNull([ZCLibClient getZCLibClient].libInitInfo) && !sobotIsNull([ZCLibClient getZCLibClient].libInitInfo.app_key)){
//            self.zckitInfo=info;
        }else{
//            self.zckitInfo=[ZCKitInfo new];
        }
        [ZCUICore getUICore].kitInfo = info;
    }
    return self;
}

#pragma mark 用户在其他页面主动关闭页面
-(void)closePage{
    [self.chatView setIsCloseNo];
    if (self.navigationController && _isPush) {
        // 滑动返回会调用 goBack方法
        [self.navigationController popViewControllerAnimated:YES];
    }else{
        [self goBack];
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}


-(void)dealloc{
    
}

@end
