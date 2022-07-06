//
//  ZCUILeaveMessageController.m
//  SobotKit
//
//  Created by lizhihui on 16/1/21.
//  Copyright © 2016年 zhichi. All rights reserved.
//

#import "ZCUILeaveMessageController.h"
#import "ZCLibGlobalDefine.h"
#import "ZCUIColorsDefine.h"
#import "ZCUIPlaceHolderTextView.h"
#import "ZCLibServer.h"
#import "ZCIMChat.h"
#import "ZCMLEmojiLabel.h"
#import "ZCUIWebController.h"
#import "ZCStoreConfiguration.h"

#import "ZCXJAlbumController.h"
#import "ZCSobotCore.h"
#import "ZCActionSheet.h"

#import "ZCUILoading.h"


#import "ZCLibOrderCusFieldsModel.h"
#import "ZCLibTicketTypeModel.h"
//#import "ZCOrderTypeController.h"
#import "ZCLibOrderCusFieldsModel.h"
#import "ZCZHPickView.h"
//#import "ZCOrderCusFieldController.h"
//#import "ZCUploadImageModel.h"
#import "SobotUtils.h"
#import "ZCPlatformTools.h"

#import "ZCUICore.h"
#import "ZCUIImageTools.h"
#import "ZCMsgDetailsVC.h"
#import "ZCMsgRecordVC.h"

#import "ZCHtmlCore.h"
#import "ZCHtmlFilter.h"
#import "ZCPageSheetView.h"
#import "ZCCheckTypeView.h"
#import "ZCCheckCusFieldView.h"

#import "ZCToolsCore.h"

#import <AVFoundation/AVFoundation.h>

#import "ZCVideoPlayer.h"
//#import "ZCUIXHImageViewer.h"
#import "SobotXHImageViewer.h"
#import "ZCToolsCore.h"


#import "ZCLeaveEditView.h"

typedef NS_ENUM(NSInteger,ExitType) {
    ISCOLSE         = 1,// 直接退出SDK
    ISNOCOLSE       = 2,// 不直接退出SDK
    ISBACKANDUPDATE = 3,// 仅人工模式 点击技能组上的留言按钮后,（返回上一页面 提交退出SDK）
    ISROBOT         = 4,// 机器人优先，点击技能组的留言按钮后，（返回技能组 提交和机器人会话）
    ISUSER          = 5,// 人工优先，点击技能组的留言按钮后，（返回技能组 提交机器人会话）
};

@interface ZCUILeaveMessageController ()<UIGestureRecognizerDelegate,UIScrollViewDelegate,ZCActionSheetDelegate,ZCXJAlbumDelegate>
{
 
    
    CGRect scFrame  ;
    
    // 链接点击
    void (^LinkedClickBlock) (NSString *url);
    
    // 呼叫的电话号码
    NSString                    *callURL;
    
    NSMutableArray  *imageURLArr;

    
    ZCLibOrderCusFieldsModel *curEditModel;
    CGPoint        contentoffset;// 记录list的偏移量

    
    UIView *btnBgView; // 选项卡
    
    int  btnTag; // 当前选中的选项卡下标
    UIView *lineView; // 选项卡下面的线条
    
    UIView * lmsView;// 留言成功后 提示页面
}

// 留言选项卡
@property (nonatomic,strong) UIButton * leftBtn;
// 留言记录
@property (nonatomic,strong) UIButton * rightBtn;


@property (nonatomic,strong) UIScrollView * mainScrollView;

// 留言编辑view
@property (nonatomic,strong)  ZCLeaveEditView *leaveEditView;

@property (nonatomic,strong)  ZCMsgRecordVC * mesRecordVC;// 留言记录

@property (nonatomic,strong) UIView * rightView;



@end

@implementation ZCUILeaveMessageController


- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    if(_mainScrollView){
        if([self orientationChanged]){
            [self viewDidLayoutSubviews];
        }
    }

    [self.mesRecordVC loadData];
    // 当从 “您的留言状态有 更新” 进入留言页面 只显示留言记录刷新时 设置选中留言记录页面
    if (self.selectedType == 2) {
        [self itemsClick:self.rightBtn];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if ([ZCUICore getUICore].kitInfo.navcBarHidden) {
        self.navigationController.navigationBarHidden = YES;
    }
    
    if(!self.navigationController.navigationBarHidden){
        self.navigationController.navigationBar.translucent = NO;
        [self setNavigationBarStyle];
        self.title = ZCSTLocalString(@"留言");
        if (self.selectedType == 2) {
             self.title = ZCSTLocalString(@"留言记录");
        }
        [self.navigationController.navigationBar setTitleTextAttributes:@{NSFontAttributeName:[ZCUITools zcgetTitleFont],NSForegroundColorAttributeName:[ZCUITools zcgetTopViewTextColor]}];

        [self.navigationController.navigationBar setBarTintColor:[ZCUITools zcgetBgBannerColor]];
    }else{
        [self createTitleView];
        [self.backButton setImage:[ZCUITools zcuiGetBundleImage:@"zcicon_leave_back"] forState:UIControlStateNormal];
        [self.backButton setImage:[ZCUITools zcuiGetBundleImage:@"zcicon_leave_back"] forState:UIControlStateHighlighted];
        
        self.titleLabel.text = ZCSTLocalString(@"留言");
        
        if (self.selectedType == 2) {
            self.titleLabel.text = ZCSTLocalString(@"留言记录");
        }
        self.moreButton.hidden = YES;
    }
   
    
    self.view.backgroundColor = [ZCUITools zcgetLightGrayDarkBackgroundColor]; //UIColorFromRGB(0xF9FAFB);
    
    // 添加选项卡
    [self createTabbarItemView];
    
    // 获取用户初始化配置参数  添加子页面
    [self customLayoutSubviewsWith:[ZCUICore getUICore].kitInfo];
    
    
    
    NSString * templateId = @"1";
    if (self.templateldIdDic != nil && [[self.templateldIdDic allKeys] containsObject:@"templateId"]) {
        templateId = self.templateldIdDic[@"templateId"];
    }
    
    // 工单自定义字段和类型接口
//    [self loadDataForPage];
    
    // 设置选中的选项卡
    if (self.selectedType != 2) {
        self.leftBtn.selected = YES;
        self.rightBtn.selected = NO;
    }else{
        [self itemsClick:self.rightBtn];
    }
    
//    2.8.0 增加导航栏下面 细线
    UIView *lineView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 0.5)];
    lineView.backgroundColor = [ZCUITools zcgetBackgroundBottomLineColor];// UIColorFromRGB(lineGrayColor);
    [self.view addSubview:lineView];
    
    
    if([ZCPlatformTools checkLeaveMessageModule]){
        [[ZCToolsCore getToolsCore] showAlert:ZCSTLocalString(@"由于服务到期，该功能已关闭。") message:nil cancelTitle:nil titleArray:@[ZCSTLocalString(@"确定")] viewController:self confirm:^(NSInteger buttonTag) {
            [self goBack];
        }];
    }
}

#pragma mark -- 添加选项卡

-(void)createTabbarItemView{
    CGFloat Y = 20;
    if (self.navigationController.navigationBarHidden) {
        Y = ZC_iPhoneX?40:20;
    }
    if(self.topView!=nil){
        Y = CGRectGetHeight(self.topView.frame) - 44;
    }
    
    NSMutableArray * titleArr = [NSMutableArray arrayWithCapacity:0];
    [titleArr addObject:ZCSTLocalString(@"请您留言")];
    [titleArr addObject:ZCSTLocalString(@"留言记录")];
    NSMutableArray * tagArr = [NSMutableArray arrayWithCapacity:0];
    [tagArr addObject:@"2001"];
    [tagArr addObject:@"2002"];
    [self createBtnItem:titleArr withTags:tagArr Y:Y];
    
    if (self.ticketShowFlag == 0) {
        return;
    }
    if(self.navigationController.navigationBarHidden){
        [self.topView addSubview:btnBgView];
        
        self.titleLabel.hidden = YES;
    }else{
         self.navigationItem.titleView = btnBgView;
    }
    
}


-(void)createBtnItem:(NSMutableArray *)titleArr withTags:(NSMutableArray *)tagArr Y:(CGFloat)Y{
    if (btnBgView!= nil) {
        [btnBgView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    }
    CGFloat maxWidth = ScreenWidth - 64*2;
    btnBgView = [[UIView alloc]initWithFrame:CGRectMake(64, Y, maxWidth, 44)];
    [btnBgView setAutoresizingMask:UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleTopMargin];
    btnBgView.autoresizesSubviews = true;
    
    CGFloat BY = ZCNumber(15);
    CGFloat BW = maxWidth/2;
    CGFloat BH = ZCNumber(21);
    
    CGFloat BX = 0;
    for (int i = 0; i< titleArr.count; i++) {
        int tag = [tagArr[i] intValue];
        if(i==1){
            BX = maxWidth - BW;
        }else{
            BX = 0;
        }
        UIButton * btn = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.frame = CGRectMake(BX, BY, BW, BH);
        btn.tag = tag;
        [btn setTitle:titleArr[i] forState:UIControlStateNormal];
        [btn setTitle:titleArr[i] forState:UIControlStateHighlighted];
        [btn addTarget:self action:@selector(itemsClick:) forControlEvents:UIControlEventTouchUpInside];
        btn.titleLabel.textAlignment = NSTextAlignmentCenter;
        btn.titleLabel.font = [ZCUITools zcgetSubTitleFont];;
        btn.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
        [btn setTitleColor:UIColorFromThemeColor(ZCTextSubColor) forState:UIControlStateNormal];
        [btn setTitleColor:UIColorFromThemeColor(ZCTextMainColor) forState:UIControlStateHighlighted];
        [btn setTitleColor:UIColorFromThemeColor(ZCTextMainColor) forState:UIControlStateSelected];
        
        btn.autoresizesSubviews = YES;
        if(i == 0 ){

            btn.autoresizingMask = UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleRightMargin;
        }else{

            btn.autoresizingMask = UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleLeftMargin;
        }
        [btnBgView addSubview:btn];
        
        if (i == 0) {
            self.leftBtn = btn;
        }else if(i == 1){
            self.rightBtn = btn;
        }
        if(btnTag == tag){
            btn.selected = YES;
        }else if(btnTag == 0 && i == 0){
            btn.selected = YES;
        }
        
        [[ZCToolsCore getToolsCore] setRTLFrame:btn];
    }
    btnTag = [[tagArr firstObject] intValue];
    lineView = [[UIView alloc]initWithFrame:CGRectMake(ZCNumber(11), ZCNumber(41)-5, 20, 3)];
    lineView.backgroundColor = [ZCUITools zcgetLeaveSubmitImgColor];
    
    lineView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
    lineView.layer.cornerRadius = 1.5f;
    lineView.layer.masksToBounds = YES;
    CGRect LF = lineView.frame;
    LF.origin.x = self.leftBtn.frame.origin.x + self.leftBtn.frame.size.width/2-10;
    lineView.frame = LF;
    [btnBgView addSubview:lineView];
}

-(void) itemsClick:(UIButton *)sender{
    if(lmsView!=nil){
        lmsView.hidden = YES;
    }
    
    if (btnTag == sender.tag) {
        return;
    }
    
    if(sender.tag == self.rightBtn.tag){
        [_mesRecordVC loadData];
    }
    
    if(sender.tag == self.leftBtn.tag){
        _leftBtn.selected = YES;
        _rightBtn.selected = NO;
    }else{
        _leftBtn.selected = NO;
        _rightBtn.selected = YES;
        
    }
    
    
    CGRect LF = lineView.frame;
    LF.origin.x = sender.frame.origin.x + sender.frame.size.width/2 - 10;
    lineView.frame = LF;
    btnTag = (int)sender.tag;
    [self.navigationItem.titleView setNeedsDisplay];
    
    // 1.获取当前的页面
    NSInteger index = (NSInteger)(sender.tag - 2001);
    
    // 2.计算偏移量
    CGPoint offSetPoint = CGPointMake(index *_mainScrollView.bounds.size.width, 0);
    
    // 3。将偏移量赋值给scrollerView
    [_mainScrollView setContentOffset:offSetPoint animated:YES];
    
}
#pragma mark --- 选项卡 end -------

-(ZCLibConfig *)getCurConfig{
    return [[ZCUICore getUICore] getLibConfig];
}

#pragma mark -- 数据刷新


/**
 *  监听滑动返回的事件
 *
 *  @param navigationController  导航控制器
 *  @param viewController  将要显示的VC
 *  @param animated  是否添加动画
 */
- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    // 解决ios7调用系统的相册时出现的导航栏透明的情况
    if ([navigationController isKindOfClass:[UIImagePickerController class]]) {
//        viewController.navigationController.navigationBar.translucent = NO;
        viewController.edgesForExtendedLayout = UIRectEdgeNone;
        return;
    }
    
    id<UIViewControllerTransitionCoordinator> tc = navigationController.topViewController.transitionCoordinator;
    __weak ZCUILeaveMessageController *safeVC = self;
    [tc notifyWhenInteractionEndsUsingBlock:^(id<UIViewControllerTransitionCoordinatorContext> context) {
        if(![context isCancelled]){
            // 设置页面不能使用边缘手势关闭
            [safeVC goBack];
        }
    }];
    
}
#pragma mark -- 系统键盘的监听事件


- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
//    [self.navigationController setNavigationBarHidden:NO];

}


#pragma mark -- 提交事件
-(IBAction)buttonClick:(UIButton *) sender{
    // 返回的事件
    if(sender.tag == BUTTON_BACK){
        [self goBack];
    }
}



-(BOOL)checkContentValid:(NSString *) text model:(ZCLibOrderCusFieldsModel *) model{
    
    if(model != nil && sobotConvertToString(text).length >0){
        NSArray *limitOptions = nil;
        
        if([model.limitOptions isKindOfClass:[NSString class]]){
            NSString *limitOption =  sobotConvertToString(model.limitOptions);
            limitOption = [limitOption stringByReplacingOccurrencesOfString:@"[" withString:@""];
            limitOption = [limitOption stringByReplacingOccurrencesOfString:@"]" withString:@""];
            limitOptions = [limitOption componentsSeparatedByString:@","];
        }else if([model.limitOptions isKindOfClass:[NSArray class]]){
            limitOptions = model.limitOptions;
        }
        
        if(limitOptions==nil || limitOptions.count == 0){
            return YES;
        }
        
        //限制方式  1禁止输入空格   2 禁止输入小数点  3 小数点后只允许2位  4 禁止输入特殊字符  5只允许输入数字 6最多允许输入字符  7判断邮箱格式  8判断手机格式
        if([limitOptions containsObject:[NSNumber numberWithInt:1]] || [limitOptions containsObject:@"1"]){
            NSRange _range = [text rangeOfString:@" "];
            if(_range.location!=NSNotFound) {
                return NO;
            }
        }
        if([limitOptions containsObject:[NSNumber numberWithInt:2]] || [limitOptions containsObject:@"2"]){
             NSRange _range = [text rangeOfString:@"."];
            if(_range.location!=NSNotFound) {
                return NO;
            }
        }
        if([limitOptions containsObject:[NSNumber numberWithInt:3]] || [limitOptions containsObject:@"3"]){
             return sobotValidateFloatWithNum(text,2);
        }
        if([limitOptions containsObject:[NSNumber numberWithInt:4]] || [limitOptions containsObject:@"4"]){
             return sobotValidateRuleNotBlank(text);
        }
        
        if([limitOptions containsObject:[NSNumber numberWithInt:5]] || [limitOptions containsObject:@"5"]){
             return sobotValidateNumber(text);
        }
        
        if([limitOptions containsObject:[NSNumber numberWithInt:6]] || [limitOptions containsObject:@"6"]){
            if(sobotConvertToString(text).length > [model.limitChar intValue]){
                return NO;
            }
        }
        
        if([limitOptions containsObject:[NSNumber numberWithInt:7]] || [limitOptions containsObject:@"7"]){
            return sobotValidateEmail(text);
        }
        
        if([limitOptions containsObject:[NSNumber numberWithInt:8]] || [limitOptions containsObject:@"8"]){
        
            return sobotValidateMobileWithRegex(text, [ZCUITools zcgetTelRegular]);
        }
        
    }
    return YES;
}


#pragma mark -- 布局子视图
- (void)customLayoutSubviewsWith:(ZCKitInfo *)zcKitInfo{
    
    // 屏蔽橡皮筋功能
    self.automaticallyAdjustsScrollViewInsets = NO;
//    // 计算Y值
    CGFloat TY = 0;
    if(self.topView!=nil){
        TY = CGRectGetHeight(self.topView.frame);
    }else{
        TY = NavBarHeight;
    }
    
    if (self.ticketShowFlag != 1) {
        btnBgView.hidden = YES;
        self.title = ZCSTLocalString(@"留言记录");

        self.titleLabel.text = ZCSTLocalString(@"留言记录");
    }

    CGFloat viewHeigth = [self getCurViewHeight];
    // 添加滑动控件
    CGFloat scrollHeight = viewHeigth - TY - XBottomBarHeight;
    _mainScrollView = [[UIScrollView alloc]initWithFrame:CGRectMake(0, TY, ScreenWidth, scrollHeight)];
    [_mainScrollView setContentSize:CGSizeMake(ScreenWidth*2 , scrollHeight)];
    _mainScrollView.pagingEnabled = YES;
    _mainScrollView.delegate = self;
    _mainScrollView.userInteractionEnabled = YES;
    _mainScrollView.scrollEnabled = NO;
    _mainScrollView.backgroundColor = [UIColor clearColor];
    _mainScrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    _mainScrollView.autoresizesSubviews = YES;
    [self.view addSubview:_mainScrollView];
   
    
    _leaveEditView = [[ZCLeaveEditView alloc] initWithFrame:CGRectMake(0, 0, [self getCurViewWidth], scrollHeight) withController:self];
    [_mainScrollView addSubview:_leaveEditView];
    _leaveEditView.ticketTitleShowFlag = _ticketTitleShowFlag;
    _leaveEditView.tickeTypeFlag = _tickeTypeFlag;
    _leaveEditView.typeArr = _typeArr;
    _leaveEditView.ticketTypeId = _ticketTypeId;
    _leaveEditView.msgTmp = _msgTmp;
    _leaveEditView.msgTxt = _msgTxt;
    _leaveEditView.templateldIdDic = _templateldIdDic;
    _leaveEditView.emailFlag = _emailFlag;
    _leaveEditView.emailShowFlag = _emailShowFlag;
    _leaveEditView.telFlag = _telFlag;
    _leaveEditView.telShowFlag = _telShowFlag;
    _leaveEditView.enclosureFlag = _enclosureFlag;
    _leaveEditView.enclosureShowFlag = _enclosureShowFlag;
    _leaveEditView.coustomArr = _coustomArr;
    __block ZCUILeaveMessageController *safeSelf = self;
    [_leaveEditView setPageChangedBlock:^(id  _Nonnull object, int code) {
        //code==1 添加成功,code == 2点击完成，跳转页面
        if(code == 3001 && _selectedType!=2){
            [safeSelf goBack];
        }
        
        if(code == 3002){
            [safeSelf itemsClick:safeSelf->_rightBtn];
        }
    }];
    
    [_leaveEditView loadCustomFields];
    
    
    
    _rightView = [[UIView alloc]initWithFrame:CGRectMake([self getCurViewWidth],0, [self getCurViewWidth], scrollHeight)];
    
    _rightView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleWidth;
    _rightView.autoresizesSubviews = YES;
    _mesRecordVC = [[ZCMsgRecordVC alloc]init];
    
    [_rightView addSubview:_mesRecordVC.view];
    [_mainScrollView addSubview:_rightView];
    
    [_mesRecordVC updataWithHeight:scrollHeight viewWidth:self.view.frame.size.width];
    
    __weak ZCUILeaveMessageController * saveVC = self;
    _mesRecordVC.jumpMsgDetailBlock = ^(ZCRecordListModel *model) {
        ZCMsgDetailsVC * detailVC = [[ZCMsgDetailsVC alloc]init];
        detailVC.ticketId = model.ticketId;
        detailVC.leaveMsgController = saveVC;
        detailVC.companyId = sobotConvertToString([ZCLocalStore getLocalParamter:@"ZCKEY_COMPANYID"]);
        if (saveVC.navigationController!= nil) {
            [saveVC.navigationController pushViewController:detailVC animated:YES];
        }else{
            UINavigationController * navc = [[UINavigationController alloc]initWithRootViewController: detailVC];
            // 设置动画效果
            navc.modalPresentationStyle = UIModalPresentationOverFullScreen;
            [saveVC presentViewController:navc animated:YES completion:^{
                
            }];
        }
    };
}

- (UIImage*) createImageWithColor: (UIColor*) color
{
    CGRect rect=CGRectMake(0.0f, 0.0f, 1.0f, 1.0f);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    UIImage *theImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return theImage;
}


#pragma mark -- 页面返回的事件 *******************************************
// 关闭页面
-(void)goBack{
    [self.leaveEditView hideKeyboard];
    
    if([ZCUICore getUICore].ZCViewControllerCloseBlock != nil){
        [ZCUICore getUICore].ZCViewControllerCloseBlock(self,ZC_CloseLeave);
    }
    
    if(_isExitSDK){
        if (_isNavOpen) {
            // 用户接入VC -》chatVC -》留言VC
            if(self.navigationController.viewControllers.count>=3){
            
                [self.navigationController popToViewController:self.navigationController.viewControllers[self.navigationController.viewControllers.count -3] animated:YES];
            }else{
                [self.navigationController popToViewController:self.navigationController.viewControllers[0] animated:YES];
            }
      
            if (self.backRefreshPageblock) {
                self.backRefreshPageblock(self);
            }
        }else{
            [self dismissViewControllerAnimated:NO completion:^{
                if (self.backRefreshPageblock) {
                    self.backRefreshPageblock(self);
                }
            }];
        }
    }
    else{
        if (self.backRefreshPageblock) {
            self.backRefreshPageblock(self);
        }
        if(_isNavOpen){
            [self.navigationController popViewControllerAnimated:YES];
        }else{
            [self dismissViewControllerAnimated:YES completion:^{
                
            }];
        }
    }
}


#pragma mark -- 页面返回的事件  End *******************************************



-(void)viewDidLayoutSubviews{
    [super viewDidLayoutSubviews];
    
    CGFloat TY = 0;
    if(self.topView!=nil){
        TY = CGRectGetHeight(self.topView.frame);
    }else{
        if(self.navigationController.navigationBar.translucent){
            TY = NavBarHeight;
        }
    }
    
    if (self.ticketShowFlag != 1) {
        btnBgView.hidden = YES;
    }

    // 添加滑动控件
    CGFloat scrollHeight = self.view.frame.size.height - TY - XBottomBarHeight;
    
    int direction = [[ZCToolsCore getToolsCore] getCurScreenDirection];
    CGFloat spaceX = 0;
    CGFloat LW = [self getCurViewWidth];
    // iphoneX 横屏需要单独处理
    if(direction > 0){
        LW = LW - XBottomBarHeight;
    }
    if(direction == 2){
        spaceX = XBottomBarHeight;
    }
    [self.mainScrollView setFrame:CGRectMake(0, TY, LW, scrollHeight)];
    [self.leaveEditView setFrame:CGRectMake(spaceX, 0, LW, scrollHeight)];
    [self.leaveEditView refreshViewData];


    _rightView.frame = CGRectMake([self getCurViewWidth]+spaceX,0, LW, scrollHeight);
    [_mesRecordVC updataWithHeight:scrollHeight viewWidth:LW];
    
    
    // 1.获取当前的页面
    NSInteger index = (NSInteger)(btnTag - 2001);
    
    // 2.计算偏移量
    CGPoint offSetPoint = CGPointMake(index *_mainScrollView.bounds.size.width, 0);
    
    // 3。将偏移量赋值给scrollerView
    [_mainScrollView setContentOffset:offSetPoint animated:YES];
  
    // 横竖屏切换的时候重新布局 标题页面
    [self createTabbarItemView];
}


- (void)dealloc{
//    NSLog(@" go to dealloc");
    // 移除键盘的监听
    [[NSNotificationCenter defaultCenter] removeObserver:self];

    
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -- 留言创建成功弹层

-(void)addLeaveMsgSuccessView{
    CGFloat viewWidth = [self getCurViewWidth];
    CGFloat viewHeigth = [self getCurViewHeight];
    if (lmsView != nil) {
        lmsView.hidden = NO;
        return;
    }
    
    CGFloat Y = 0;
    if (self.navigationController.navigationBarHidden) {
        Y = NavBarHeight;
    }
    lmsView = [[UIView alloc]initWithFrame:CGRectMake(0, Y, viewWidth, viewHeigth)];
    lmsView.backgroundColor = [ZCUITools zcgetLightGrayBackgroundColor];
    
    
    UIImageView * img = [[UIImageView alloc]initWithFrame:CGRectMake(viewWidth/2 - ZCNumber(60/2), ZCNumber(60), ZCNumber(60), ZCNumber(60))];
    if(isLandspace){
        img.frame = CGRectMake(viewWidth/2 - ZCNumber(60/2), ZCNumber(40), ZCNumber(60), ZCNumber(60));
    }
    img.image = [ZCUITools zcuiGetBundleImage:@"zcicon_addleavemsgsuccess"];
    [lmsView addSubview:img];
//
    UILabel * titleLab = [[UILabel alloc]initWithFrame:CGRectMake(0, CGRectGetMaxY(img.frame)+ ZCNumber(30), viewWidth, ZCNumber(28))];
    titleLab.text = ZCSTLocalString(@"提交成功");
    titleLab.textAlignment = NSTextAlignmentCenter;
    titleLab.font = ZCUIFontBold20;
    titleLab.textColor = UIColorFromThemeColor(ZCTextMainColor);
    [lmsView addSubview:titleLab];
    
    btnBgView.hidden = YES;
    
    UILabel * tiplab = [[UILabel alloc]initWithFrame:CGRectMake(ZCNumber(45), CGRectGetMaxY(titleLab.frame) + ZCNumber(10), viewWidth - ZCNumber(90), ZCNumber(40))];
    tiplab.textAlignment = NSTextAlignmentCenter;
    tiplab.font = ZCUIFont14;
    tiplab.text = ZCSTLocalString(@"我们将会以链接的形式在会话中向你反馈工单处理状态");
    [tiplab setNumberOfLines:2];
    tiplab.textColor = UIColorFromThemeColor(ZCTextSubColor);
    [lmsView addSubview:tiplab];
    
    UIButton * comBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    comBtn.frame = CGRectMake(ZCNumber(15), CGRectGetMaxY(tiplab.frame) + ZCNumber(100), viewWidth - ZCNumber(30), ZCNumber(44)) ;
    if(isLandspace){
        comBtn.frame = CGRectMake(ZCNumber(15), CGRectGetMaxY(tiplab.frame) + ZCNumber(10), viewWidth - ZCNumber(30), ZCNumber(44)) ;
    }
    
    [comBtn setTitle:ZCSTLocalString(@"完成") forState:UIControlStateNormal];
    [comBtn setTitle:ZCSTLocalString(@"完成") forState:UIControlStateSelected];
    UIImage * colorimg = [self createImageWithColor:[ZCUITools zcgetLeaveSubmitImgColor]];
    [comBtn setBackgroundImage:colorimg forState:UIControlStateNormal];
    [comBtn setBackgroundImage:colorimg forState:UIControlStateSelected];
    [comBtn addTarget:self action:@selector(completionBackAction:) forControlEvents:UIControlEventTouchUpInside];
    comBtn.tag = 3001;
    comBtn.layer.masksToBounds = YES;
    comBtn.layer.cornerRadius = 22.0f;
    comBtn.titleLabel.font = ZCUIFont17;
    [lmsView addSubview:comBtn];
    
    UIButton * recordBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    recordBtn.frame = CGRectMake(ZCNumber(30), CGRectGetMaxY(comBtn.frame) + ZCNumber(20), [self getCurViewWidth]- ZCNumber(60), ZCNumber(30));
    [recordBtn setTitle:ZCSTLocalString(@"前往留言记录") forState:UIControlStateNormal];
    [recordBtn setTitleColor:[ZCUITools zcgetLeaveSubmitImgColor] forState:UIControlStateNormal];
    recordBtn.tag = 3002;
    [recordBtn addTarget:self action:@selector(completionBackAction:) forControlEvents:UIControlEventTouchUpInside];
    recordBtn.titleLabel.font = ZCUIFont14;
    [lmsView addSubview:recordBtn];
    
    [self.view addSubview:lmsView];
}

-(void)removeAddLeaveMsgSuccessView{
    if (lmsView && lmsView!=nil) {
        [lmsView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
        [lmsView removeFromSuperview];
        lmsView = nil;
    }
}

-(void)completionBackAction:(UIButton *)sender{
    if (sender.tag == 3001) {
        __weak ZCUILeaveMessageController *leaveVC = self;
        [self removeAddLeaveMsgSuccessView];
        [self goBack];
        
    }else if (sender.tag == 3002){
        btnBgView.hidden = NO;
        // 不要移除，可以隐藏，否则会执行viewDidLayoutSubviews ，导致itemsClick 无效
//        [self removeAddLeaveMsgSuccessView];
        lmsView.hidden = YES;
        [self itemsClick:_rightBtn];
        [_mesRecordVC loadData];
    }
}
#pragma mark -- 提示页面 end ------------
@end
