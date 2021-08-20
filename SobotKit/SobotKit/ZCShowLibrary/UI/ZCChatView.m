//
//  ZCChatView.m
//  SobotKit
//
//  Created by lizhihui on 2018/1/29.
//  Copyright © 2018年 zhichi. All rights reserved.
//

#import "ZCChatView.h"
#import "ZCLibGlobalDefine.h"
#import "ZCTitleView.h"

//#import "ZCLeaveMsgController.h"
#import "ZCUIAskTableController.h"

#import <SobotKit/SobotKit.h>


#import "ZCPlatformTools.h"
#import "ZCUICore.h"
#import "ZCUILoading.h"

#import "ZCUIColorsDefine.h"
#import "ZCChatBaseCell.h"
#import "ZCChatAllRichCell.h"

#import "ZCImageChatCell.h"
#import "ZCVoiceChatCell.h"
#import "ZCTipsChatCell.h"
#import "ZCGoodsCell.h"
//#import "ZCHorizontalRollCell.h"
//#import "ZCVerticalRollCell.h"
#import "ZCMultiItemCell.h"

#import "ZCActionSheet.h"
#import "ZCUILeaveMessageController.h"
#import "ZCDocumentLookController.h"
#import "ZCLibSkillSet.h"
#import "ZCSobotCore.h"
#import "ZCStoreConfiguration.h"
#import "ZCUIImageView.h"

#import "ZCSatisfactionCell.h"

#import "ZCPlatformTools.h"

#import "ZCMultiRichCell.h"

#import "ZCHotGuideCell.h"
#import "ZCFileCell.h"
#import "ZCLocationCell.h"
#import "ZCUIToastTools.h"
#import "ZCNoticeCell.h"
#import "ZCInfoCardCell.h"
#import "ZCMultitemHorizontaRollCell.h"
#import "ZCOrderGoodsCell.h"

#define cellCardCellIdentifier @"ZCInfoCardCell"
#define cellNoticeCellIdentifier @"ZCNoticeCell"
#define cellHotGuideIdentifier @"ZCHotGuideCell"

#define cellMultitemHorizontaRollIndentifier @"ZCMultitemHorizontaRollCell"

#define cellMultiRichIdentifier @"ZCMultiRichCell"
#define cellRichAllTextIdentifier @"ZCChatAllRichCell"

#define cellImageIdentifier @"ZCImageChatCell"
#define cellVoiceIdentifier @"ZCVoiceChatCell"
#define cellTipsIdentifier @"ZCTipsChatCell"
#define cellGoodsIndentifier @"ZCGoodsCell"
#define cellSatisfactionIndentifier @"ZCSatisfactionCell"
//#define cellHorizontalRollIndentifier @"ZCHorizontalRollCell"
//#define cellVerticalRollIndentifier @"ZCVerticalRollCell"
#define cellMultilItemIndentifier @"ZCMultiItemCell"
#define cellFileIndentifier @"ZCFileCell.h"
#define cellLocationIndentifier @"ZCLocationCell.h"

#define cellOrderGoodsIndentifier @"ZCOrderGoodsCell"


//#import "ZCRichTextChatCell.h"
//#define cellRichTextIdentifier @"ZCRichTextChatCell"


#import "ZCIMChat.h"
#import "ZCUIKeyboard.h"
#import "ZCUICustomActionSheet.h"
#import "ZCUIWebController.h"
#import "ZCUIXHImageViewer.h"
#import "ZCLibServer.h"
#import "ZCUIVoiceTools.h"
#import "ZCLibGlobalDefine.h"
#import "ZCLibNetworkTools.h"

#import "ZCChatController.h"

#import "ZCTurnRobotView.h"
#import "ZCQuickEntryView.h"
#import "ZCButton.h"

#import "ZCUIImageTools.h"
#import "ZCTextGuideCell.h"
#define cellTextCellIdentifier @"ZCTextGuideCell"

#import "ZCSelLeaveView.h"
#import "ZCWsTemplateModel.h"
#import "ZCLeaveMsgVC.h"

#import "ZCToolsCore.h"

#define TableSectionHeight 44


#define MinViewWidth 320
#define MinViewHeight 540

#ifndef weakify
#if __has_feature(objc_arc)
#define weakify(self) autoreleasepool {} __attribute__((objc_ownership(weak))) __typeof__(self) weakSelf = (self)
#endif
#endif

#ifndef strongify
#if __has_feature(objc_arc)
#define strongify(self) try {} @finally {} _Pragma("clang diagnostic push") _Pragma("clang diagnostic ignored \"-Wunused-variable\"") __attribute__((objc_ownership(strong))) __typeof__(self) self = weakSelf; _Pragma("clang diagnostic pop")
#endif
#endif

@interface ZCChatView()<ZCUICoreDelegate,UITableViewDelegate,UITableViewDataSource,ZCUIBackActionSheetDelegate,ZCChatCellDelegate,ZCUIVoiceDelegate,ZCActionSheetDelegate>{
    CGFloat viewWidth;
    CGFloat viewHeight;

    // 呼叫的电话号码
    NSString                    *callURL;
    // 旋转时隐藏查看大图功能
    ZCUIXHImageViewer           *xhObj;
    
    // 无网络提醒button
    UIButton                    *_newWorkStatusButton;
    
    //长连接显示情况
    UIButton                    *_socketStatusButton;
    
    CGFloat                     navHeight;
    CGFloat                     navTableY;
    
    BOOL                        isStartConnectSockt;
    
    BOOL isViewDidBack;
    
    // 点击了关闭按钮
    BOOL                        isClickCloseBtn;
    BOOL                        isCompleteSatisfaction;  //  完成了评价
    
    BOOL isScrollBtm;
    
    BOOL isOpenNotice;// 是否展开通告
    
    BOOL isHasQuickView;// 是否有快捷入口
}




@property (nonatomic,strong) ZCUIKeyboard * keyboardTools;

// 切换机器人控件
@property (nonatomic,strong) ZCTurnRobotView *changeRobotView;

@property (nonatomic,weak) UIViewController * superController;

@property (nonatomic,strong) UIRefreshControl * refreshControl;
@property (nonatomic,strong) UIButton *goUnReadButton;
@property (nonatomic,strong) UITableView * listTable;
@property (nonatomic,assign) BOOL isNoMore;
// 通告view
@property (nonatomic,strong)  UIView           *notifitionTopView;

/***  评价页面 **/
@property (nonatomic,strong) ZCUICustomActionSheet *sheet;

/** 声音播放对象 */
@property (nonatomic,strong) ZCUIVoiceTools    *voiceTools;

/** 网络监听对象 */
@property (nonatomic,strong) ZCLibNetworkTools *netWorkTools;

/** 多机器人按钮*/
@property (nonatomic,strong) UIButton * changeRobotBtn;
@property (nonatomic,strong) UIButton  *changeRobotBtn_btn1;

@property (nonatomic,strong) ZCQuickEntryView * quickEntryView;


/**
 *  标题
 */
@property(nonatomic,strong) ZCTitleView    * zcTitleView;

// onpage 方法触发后的  ZCLibConfig ，用来判断当前 keyboardTools 布局
@property(nonatomic,strong) ZCLibConfig *currentLibConfig;
@end

@implementation ZCChatView


-(void)setUI{
    viewWidth  = self.frame.size.width;
    viewHeight = self.frame.size.height;
    navHeight = 0;
    if (_hideTopViewNav) {
        [self createTitleView];
        
        navHeight = NavBarHeight;
    }
    
    _listTable = [[UITableView alloc] initWithFrame:CGRectMake(0, navHeight, viewWidth, viewHeight - BottomHeight) style:UITableViewStylePlain];
    _listTable.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
    _listTable.autoresizesSubviews = YES;
    _listTable.delegate = self;
    _listTable.dataSource = self;
//    [_listTable registerClass:[ZCRichTextChatCell class] forCellReuseIdentifier:cellRichTextIdentifier];
    [_listTable registerClass:[ZCChatAllRichCell class] forCellReuseIdentifier:cellRichAllTextIdentifier];
    
    [_listTable registerClass:[ZCImageChatCell class] forCellReuseIdentifier:cellImageIdentifier];
    [_listTable registerClass:[ZCVoiceChatCell class] forCellReuseIdentifier:cellVoiceIdentifier];
    [_listTable registerClass:[ZCTipsChatCell class] forCellReuseIdentifier:cellTipsIdentifier];
    [_listTable registerClass:[ZCGoodsCell class] forCellReuseIdentifier:cellGoodsIndentifier];
    [_listTable registerClass:[ZCSatisfactionCell class] forCellReuseIdentifier:cellSatisfactionIndentifier];
//    [_listTable registerClass:[ZCHorizontalRollCell class] forCellReuseIdentifier:cellHorizontalRollIndentifier];
//    [_listTable registerClass:[ZCVerticalRollCell class] forCellReuseIdentifier:cellVerticalRollIndentifier];
    [_listTable registerClass:[ZCMultiItemCell class] forCellReuseIdentifier:cellMultilItemIndentifier];
    [_listTable registerClass:[ZCMultiRichCell class] forCellReuseIdentifier:cellMultiRichIdentifier];
    [_listTable registerClass:[ZCHotGuideCell  class] forCellReuseIdentifier:cellHotGuideIdentifier];
    [_listTable registerClass:[ZCTextGuideCell class] forCellReuseIdentifier:cellTextCellIdentifier];
    [_listTable registerClass:[ZCFileCell class] forCellReuseIdentifier:cellFileIndentifier];
    [_listTable registerClass:[ZCLocationCell class] forCellReuseIdentifier:cellLocationIndentifier];
    [_listTable registerClass:[ZCNoticeCell class] forCellReuseIdentifier:cellNoticeCellIdentifier];
    [_listTable registerClass:[ZCInfoCardCell class] forCellReuseIdentifier:cellCardCellIdentifier];
    [_listTable registerClass:[ZCOrderGoodsCell class] forCellReuseIdentifier:cellOrderGoodsIndentifier];
    [_listTable setSeparatorColor:[UIColor clearColor]];
    [_listTable setBackgroundColor:[UIColor clearColor]];
    _listTable.clipsToBounds=NO;
    _listTable.estimatedRowHeight = 0;
    _listTable.estimatedSectionFooterHeight = 0;
    
    //一定要插入到最底部，不然自定义导航会被覆盖
    [self insertSubview:_listTable atIndex:0];
    
//     NSLog(@"列表的frame %@",NSStringFromCGRect(_listTable.frame));
    UIView *view =[ [UIView alloc]init];
    view.backgroundColor = [UIColor clearColor];
    [_listTable setTableFooterView:view];

    self.refreshControl = [[UIRefreshControl alloc]init];
    self.refreshControl.attributedTitle = nil;
    [self.refreshControl addTarget:self action:@selector(getHistoryMessage) forControlEvents:UIControlEventValueChanged];
    [_listTable addSubview:_refreshControl];
    
    // 关闭安全区域，否则UITableViewCell横屏时会是全屏的宽
    NSString *version = [UIDevice currentDevice].systemVersion;
    if (version.doubleValue >= 11.0) {
        [_listTable setInsetsContentViewsToSafeArea:NO];
    }

    _netWorkTools = [ZCLibNetworkTools shareNetworkTools];

    _keyboardTools = [[ZCUIKeyboard alloc] initConfigView:self table:_listTable];
    if (_superController.navigationController.navigationBarHidden || !_superController.navigationController.navigationBar.translucent) {
        _keyboardTools.isNavcHide = !_hideTopViewNav;  // 同步处理键盘的高度
    }
    if (!_superController.navigationController.navigationBarHidden) {
        _keyboardTools.isTranslucent = _superController.navigationController.navigationBar.translucent;
    }
    
    [_keyboardTools handleKeyboard];
    
    __weak ZCChatView *safeSelf = self;
    _keyboardTools.scrollTableToBottomBlock = ^{
        [safeSelf keyboardscrollTableToBottom];
    };

    // 通道保护
    if([self getZCIMConfig] && [self getZCIMConfig].isArtificial){
        [[ZCIMChat getZCIMChat] checkConnected:NO];
    }
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(netWorkChanged:) name:ZCNotification_NetworkChange object:nil];
   

    // TODO 需要初始化接口返回的数据
    [self changeRobotBtn];

    if([[ZCUICore getUICore] PageLoadBlock]){
        // 通知外部可以更新UI
        [ZCUICore getUICore].PageLoadBlock(self,ZCPageBlockLoadFinish);
    }
    
    
    // 转屏通知
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(didChangeRotate:) name:UIApplicationDidChangeStatusBarFrameNotification object:nil];
}

-(instancetype)initWithFrame:(CGRect)frame WithSuperController:(UIViewController *)superController customNav:(BOOL)isCreated{
    self = [super initWithFrame:frame];
    if (self) {
        _superController = superController;
        _hideTopViewNav = !isCreated;
        self.backgroundColor = [ZCUITools zcgetBackgroundColor];
        [self setUI];
        self.userInteractionEnabled = YES;
        _voiceTools  = [[ZCUIVoiceTools alloc] init];
        _voiceTools.delegate = self;
        self.clipsToBounds=YES;
        _listTable.clipsToBounds = YES;
    }
    return self;
}

-(void)showZCChatView:(ZCKitInfo *)kitInfo{
//    [ZCUICore getUICore].chatView = self;
    __weak ZCChatView *safeSelf = self;
    [[ZCUICore getUICore] openSDKWith:[ZCLibClient getZCLibClient].libInitInfo uiInfo:kitInfo Delegate:self  blcok:^(ZCInitStatus code, NSMutableArray *arr, NSString *result) {
        if(code == ZCInitStatusLoading){
            // 开始初始化
            // 展示智齿loading
            [[ZCUILoading shareZCUILoading] showAddToSuperView:self];
        }
        if(code == ZCInitStatusLoadSuc){
            // 初始化完成

            // 智齿loading消失
            [[ZCUILoading shareZCUILoading] dismiss];
            [safeSelf configShowNotifion];
        
            [[ZCIMChat getZCIMChat] setChatPageState:ZCChatPageStateActive];
            
            [[ZCUICore getUICore] loadSatisfactionDictlock:^(int code) {
                if(code == 0 && [self getZCIMConfig].isArtificial){
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 1 ), dispatch_get_main_queue(), ^{
                        [self.listTable reloadData];
                    });
                }
                
            }];
            
        }
       
    }];
}


/**
 页面改变事件

 @param status 判断事件处理关键
 @param message 事件相关联消息
 @param object  预留参数
 */
-(void)onPageStatusChanged:(ZCShowStatus)status message:(NSString *)message obj:(id)object{
    if(status == ZCShowTextHeightChanged){
        // 重新设置标签的高度，否则会被遮挡
         if (_quickEntryView != nil && ([self getZCIMConfig].quickEntryFlag == 1 || [ZCUICore getUICore].kitInfo.cusMenuArray.count>0) && [_keyboardTools getKeyBoardViewStatus]!=ZCKeyboardStatusNewSession) {
               _quickEntryView.hidden = NO;
               _quickEntryView.frame = CGRectMake(0,CGRectGetMaxY(_keyboardTools.zc_bottomView.frame) - CGRectGetHeight(_keyboardTools.zc_bottomView.frame)- 50, viewWidth, 50);
           }
        return;
    }
    
     if (status == ZCShowStatusRefreshing) {
         ZCLibMessage *message = object;
         
         
//         NSLog(@"-----更新下载进度%f==\n %d------ \n",message.progress,isScrollBtm);
         if(isScrollBtm){
             //  执行的代码
             NSInteger index =  [[ZCUICore getUICore].listArray indexOfObject:object];
             NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];
             
             
             if( message.richModel.msgType == ZCMessageTypeFile){
            
                 ZCFileCell *cell = (ZCFileCell *)[_listTable cellForRowAtIndexPath:indexPath];
                 if(cell!=nil){
                     [cell setProgress:message.progress];
                 }
             }else if( message.richModel.msgType == ZCMessageTypeVideo || message.richModel.msgType == ZCMessageTypePhoto){
                 
                 ZCImageChatCell *cell = (ZCImageChatCell *)[_listTable cellForRowAtIndexPath:indexPath];
                 if(cell!=nil){
                     [cell setProgress:message.progress];
                 }
             } else if(indexPath != nil){
                 
                 //刷新
                 [_listTable reloadRowsAtIndexPaths:[NSArray arrayWithObjects:indexPath, nil] withRowAnimation:UITableViewRowAnimationAutomatic];
             }
         }
         return;
     }
    // 有新消息、消息列表改变
    if(status == ZCShowStatusAddMessage || status ==  ZCShowStatusMessageChanged || status == ZCInitStatusCompleteNoMore){
        
        if(status == ZCInitStatusCompleteNoMore){
            _isNoMore = YES;
        }
//        self.listTable.hidden = YES;
        [_listTable reloadData];
        
        if(self.refreshControl.refreshing){
            [self.refreshControl endRefreshing];
            
            isScrollBtm = true;
        }else{
//            isScrollBtm = true;
//            // 解决频繁刷新白屏问题
//            if ([ZCUICore getUICore].chatMessages.count > 1){
//                // 动画之前先滚动到倒数第二个消息
//                [self.listTable scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:[ZCUICore getUICore].chatMessages.count - 2 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:NO];
//            }
//            self.listTable.hidden = NO;
//            // 添加向上顶出最后一个消息的动画
//            [self.listTable scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:[ZCUICore getUICore].chatMessages.count - 1 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:YES];

            // 上面代码替换
            [self scrollTableToBottom];
        }
        
        return;
    }
    
    
    // 超过一定数量显示未读消息点击效果
    if(status == ZCShowStatusUnRead){
        [self.goUnReadButton setTitle:message forState:UIControlStateNormal];
        self.goUnReadButton.hidden = NO;
    }
    
    if (status == ZCShowStatusGoBack) {
        [self goBackIsKeep];
        return;
    }

    // 跳转到留言页面
    if (status == ZCShowStatusLeaveMsgPage) {
        
        if ([object integerValue] == 2 && [self getZCIMConfig].type == 2 && [self getZCIMConfig].msgFlag == 1) {
            [_keyboardTools setKeyBoardStatus:ZCKeyboardStatusNewSession];
            
            // 设置昵称
            [self setTitleName:ZCSTLocalString(@"暂无客服在线")];
            

            // 键盘状态发生变化了，需要重新设置table的高度，因为新会话的键盘高度变化了
            [self setFrameForListTable];
            
        }else{
            
            // 是否直接退出SDK
            NSInteger isExit = [object integerValue];
            
            // 先处理是否显示 切换留言模板
            [self changeLeaveMsgType:isExit];
        }
        return;
    }
    
    if(status == ZCShowStatusChangedTitle){
        [self setTitleName:message];
        
    }
    
    if (status == ZCShowStatusSatisfaction) {
        [_keyboardTools hideKeyboard];
        
    }
    
    // 新会话
    if (status == ZCShowStatusReConnected) {
        // 新的会话要将上一次的数据清空全部初始化在重新拉取
        [_listTable reloadData];
//        _isHadLoadHistory = NO;
        _isNoMore = NO;
        [_keyboardTools setKeyBoardStatus:ZCKeyboardStatusNewSession];
        
        // 键盘状态发生变化了，需要重新设置table的高度，因为新会话的键盘高度变化了
        [self setFrameForListTable];
        // 重新加载数据
        return;
    }
    
    //
    if (status == ZCShowStatusConnectingUser) {
        _keyboardTools.isConnectioning = YES;
        _keyboardTools.zc_turnButton.enabled = NO;
    }
    
    if (status == ZCShowStatusConnectFinished){
        _keyboardTools.zc_turnButton.enabled = YES;
        _keyboardTools.isConnectioning = NO;
        [[ZCUICore getUICore] dismissSkillSetView];
    }
    
    if (status == ZCShowCustomActionSheet) {
        // 回收键盘
        [_keyboardTools hideKeyboard];
//        [ZCUICore getUICore].chatView = self;
        [(ZCUICustomActionSheet*)object showInView:self];
        
    }
    
    // 设置键盘样式
    if (status == ZCSetKeyBoardStatus) {
        if ([@"ZCKeyboardStatusRobot" isEqualToString:message]) {
            [_keyboardTools setKeyBoardStatus:ZCKeyboardStatusRobot];
        }else if ([@"ZCKeyboardStatusWaiting" isEqualToString:message]){
            [_keyboardTools setKeyBoardStatus:ZCKeyboardStatusWaiting];
        }else if ([@"ZCKeyboardStatusUser" isEqualToString:message]){
            [_keyboardTools setKeyBoardStatus:ZCKeyboardStatusUser];
        }else if ([@"ZCKeyboardStatusNewSession" isEqualToString:message]){
            [_keyboardTools setKeyBoardStatus:ZCKeyboardStatusNewSession];
        }else if (message == nil){
            [_keyboardTools setInitConfig:(ZCLibConfig *)object];
            self.currentLibConfig = (ZCLibConfig *)object;
        }
        [_keyboardTools hideKeyboard];
        
        // 键盘状态发生变化了，需要重新设置table的高度，因为新会话的键盘高度变化了
        [self setFrameForListTable];

    }
    
    if (status == ZCShowStatusUserStyle) {
        [_keyboardTools setKeyBoardStatus:ZCKeyboardStatusUser];
        
        // 键盘状态发生变化了，需要重新设置table的高度，因为新会话的键盘高度变化了
        [self setFrameForListTable];
    }
    
    if (status == ZCSetListTabelRoad) {
        [self.listTable reloadData];
    }
    // 仅人工模式 关闭技能组 直接退出SDK页面
    if (status == ZCInitStatusCloseSkillSet) {
        [[ZCUICore getUICore].listArray removeAllObjects];
        [_listTable reloadData];
        [self goBackIsKeep];
    }
    
    // 链接中。。
    if (status == ZCInitStatusConnecting) {
        if ([message intValue] == ZC_CONNECT_KICKED_OFFLINE_BY_OTHER_CLIENT) {
            if(self.superController.navigationController){
                [[ZCUIToastTools shareToast] showToast:ZCSTLocalString(@"您打开了新窗口，本次会话结束") duration:1.0f view:self.window.rootViewController.view position:ZCToastPositionCenter];
            }else{
                [[ZCUIToastTools shareToast] showToast:ZCSTLocalString(@"您打开了新窗口，本次会话结束") duration:1.0f view:self position:ZCToastPositionCenter];
            }
        }else{
          [self showSoketConentStatus:[message intValue]];
        }
        
    }
    
    // 智能转人工，转不成功也不提示
    if (status == ZCShowStatusMessageTurnServer) {
        [ZCUICore getUICore].isSmartTurnServer = YES;
        [[ZCUICore getUICore] turnUserService:nil object:object Msg:nil];
    }
    
    if (status == ZCTurnRobotFramChange) {
        // TODO 测试数据
        if ([self getZCIMConfig].robotSwitchFlag  == 1) {
            [self setTurnRobotBtnFram];
        }
        
        if ([self getZCIMConfig].quickEntryFlag == 1) {
            [self setQuickViewFrame];
        }
    }
    
    if (status == ZCShowTurnRobotBtn) {
        // 是否显示 多机器人按钮
        if ([self getZCIMConfig].robotSwitchFlag == 1) {
            
            if ([self getZCIMConfig].type != 2 && ![self getZCIMConfig].isArtificial && ![message isEqualToString:@"1"]) {
                _changeRobotBtn.hidden = NO;
            }else{
                _changeRobotBtn.hidden = YES;
            }
        }else{
            _changeRobotBtn.hidden = YES;
        }
    }
    
    
    if (status == ZCShowQuickEntryView) {
        // 加载快捷入口标签
        if ([self getZCIMConfig].quickEntryFlag == 1) {
             NSMutableArray * array = [NSMutableArray arrayWithCapacity:0];
            [[ZCLibServer getLibServer] getLableInfoList:[self getZCIMConfig] start:^{
                
            } success:^(NSDictionary *dict, ZCMessageSendCode sendCode) {
                @try{
                    if (dict) {
                        NSArray * listArr = dict[@"data"][@"list"];
                        if (listArr.count > 0) {
                            for (NSDictionary *Dic in listArr) {
                                ZCLibCusMenu * model = [[ZCLibCusMenu alloc]initWithMyDict:Dic];
                                [array addObject:model];
                            }
                            [self quickEntryViewWithArray:array];
                           
                            if ([self getZCIMConfig].quickEntryFlag == 1 && [message intValue] == 0) {
                                isHasQuickView = YES;
                                [self setFrameForListTable];
                            }
                        }else{
                            if ([ZCUICore getUICore].kitInfo.cusMenuArray.count > 0 ) {
                                for (NSDictionary * Dic in [ZCUICore getUICore].kitInfo.cusMenuArray) {
                                    ZCLibCusMenu * model = [[ZCLibCusMenu alloc]initWithMyDict:Dic];
                                    [array addObject:model];
                                }
                                [self quickEntryViewWithArray:array];
                                if ([self getZCIMConfig].quickEntryFlag == 1 && [message intValue] == 0) {
                                    isHasQuickView = YES;
                                    [self setFrameForListTable];
                                }
                            }else{
                                [self getZCIMConfig].quickEntryFlag = 0;
                                return ;
                            }
                        }
                        
                    }
                } @catch (NSException *exception) {
                    
                } @finally {
                    
                }
            } fail:^(NSString *errorMsg, ZCMessageSendCode errorCode) {
                
            }];
        }
        
    }
    CGFloat navHeight = NavBarHeight;
    if([[ZCToolsCore getToolsCore] getCurScreenDirection] > 0){
        navHeight = NavLandspaceBarHeight;
    }
    
    if([self getZCIMConfig].isArtificial){
        if (self.delegate && [self.delegate respondsToSelector:@selector(onPageStatusChange:)]) {
            [self.delegate onPageStatusChange:YES];
        }
        self.closeButton.hidden = NO;
    }else {
        if (self.delegate && [self.delegate respondsToSelector:@selector(onPageStatusChange:)]) {
            [self.delegate onPageStatusChange:NO];
        }
        self.closeButton.hidden = YES;
    }
    [self setTitleViewRTL];
}

- (void)setQuickViewFrame{
    CGRect quickViewF = _quickEntryView.frame;
    quickViewF.origin.y =  CGRectGetMaxY(_keyboardTools.zc_bottomView.frame) - CGRectGetHeight(_keyboardTools.zc_bottomView.frame) - 50;
    _quickEntryView.frame = quickViewF;
}

-(void)setTurnRobotBtnFram{
    CGRect robotF = _changeRobotBtn.frame;
    
    CGFloat H = 20;
    if ([self getZCIMConfig].quickEntryFlag == 1) {
        H = 60;
    }
    robotF.origin.x = self.listTable.frame.origin.x + self.listTable.frame.size.width - robotF.size.width;
    if(self.listTable.frame.size.width == 0){
        return;
    }
    robotF.origin.y = CGRectGetMaxY(_keyboardTools.zc_bottomView.frame) - CGRectGetHeight(_keyboardTools.zc_bottomView.frame) - 86 - H;
    _changeRobotBtn.frame = robotF;
}

-(void)coreOpenNewPageVC:(ZCPagesType)type IsExist:(LeaveExitType) isExist  isShowToat:(BOOL) isShow  tipMsg:(NSString *)msg  Dict:(NSDictionary*)dict Object:(id)obj{
        if (type == ZC_AskTabelPage) {
            ZCUIAskTableController * askVC = [[ZCUIAskTableController alloc]init];
            askVC.dict = dict[@"data"];
            if (msg !=nil && [msg isEqualToString:@"clearskillId"]) {
                askVC.isclearskillId = YES;
            }
            askVC.isNavOpen = (self.superController.navigationController!=nil ? YES: NO);
            askVC.trunServerBlock = ^(BOOL isback) {
                if (isback && [[ZCUICore getUICore] getLibConfig].type == 2) {
                    // 返回当前页面 结束会话回到启动页面
                    [self goBackIsKeep];
                }else{
                    if (isback) {
                        return ;
                    }else{
                        // 去执行转人工的操作
                        [[ZCUICore getUICore] doConnectUserService:obj];
                    }
                    
                }
            };
            [self openNewPage:askVC];
            
        }else{
            // 统一使用此方法跳转留言
            [self changeLeaveMsgType:LeaveExitTypeISNOCOLSE showToast:isShow msg:msg];
        }
}

-(void)jumpNewPageVC:(ZCPagesType)type IsExist:(LeaveExitType)isExist isShowToat:(BOOL)isShow tipMsg:(NSString *)msg Dict:(NSDictionary *)dict{
    if (type == ZC_AskTabelPage) {
        ZCUIAskTableController * askVC = [[ZCUIAskTableController alloc]init];
        askVC.dict = dict[@"data"];
        if (msg !=nil && [msg isEqualToString:@"clearskillId"]) {
            askVC.isclearskillId = YES;
        }
       askVC.isNavOpen = (self.superController.navigationController!=nil ? YES: NO);
        askVC.trunServerBlock = ^(BOOL isback) {
            if (isback && [[ZCUICore getUICore] getLibConfig].type == 2) {
                // 返回当前页面 结束会话回到启动页面
                [self goBackIsKeep];
            }else{
                if (isback) {
                    return ;
                }else{
                    // 去执行转人工的操作
                    [[ZCUICore getUICore] doConnectUserService:nil];
                }
                
            }
        };
         [self openNewPage:askVC];
        
    }else if (type == ZC_LeaveMsgPage || type == ZC_LeaveRecordPage){
        
        
        if (_delegate && [_delegate respondsToSelector:@selector(onLeaveMsgClick:)] && _isJumpCustomLeaveVC) {
            [_delegate onLeaveMsgClick:msg];
            return;
        }
        
        // 2.8.0新增功能，添加提示，跳转前提示说辞（不超过40字符）
        if(isShow){
            // 提示 msg内容，目前放在留言页面显示
        }
        [self goToLeaveVCChecked:type IsExist:isExist isShowToat:isShow tipMsg:msg Dict:dict];
    }
}

-(void)goToLeaveVCChecked:(ZCPagesType)type IsExist:(LeaveExitType)isExist isShowToat:(BOOL)isShow tipMsg:(NSString *)msg Dict:(NSDictionary *)dict{
    // 这里要在SDK进入留言页面之前做处理 调用接口，留言记录是否显示 布局UI界面
//    if (isShow) {
//        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//            [[ZCUIToastTools shareToast] showToast:msg duration:3.0f view:self position:ZCToastPositionCenter];
//        });
//    }
    
    
    __weak ZCChatView * chatView = self;
    ZCUILeaveMessageController *leaveMessageVC = [[ZCUILeaveMessageController alloc]init];
    leaveMessageVC.exitType = isExist;
    leaveMessageVC.isShowToat = isShow;
    leaveMessageVC.tipMsg = msg;
    leaveMessageVC.isNavOpen = (self.superController.navigationController!=nil ? YES: NO);
    [leaveMessageVC setCloseBlock:^{
        [chatView goBackIsKeep];
    }];
    [leaveMessageVC setBackRefreshPageblock:^(id  _Nonnull object) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.15 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [_keyboardTools hideKeyboard];
        });
    }];
    NSString * code = @"1";
    NSString * templateId = @"1";
    if (dict != nil) {
       leaveMessageVC.templateldIdDic = dict;
       
        if ([[dict allKeys] containsObject:@"selectedType"]) {
            code = [dict valueForKey:@"selectedType"];
        }
        
        if ([code intValue] ==2) {
            if (type == ZC_LeaveRecordPage) {
                // 删除掉这条消息
                int index = -1;
                if([ZCUICore getUICore].listArray!=nil && [ZCUICore getUICore].listArray.count>0){
                    
                    for (int i = 0; i< [ZCUICore getUICore].listArray.count; i++) {
                        ZCLibMessage *libMassage = [ZCUICore getUICore].listArray[i];
                        // 删除上一次商品信息
                        if([libMassage.sysTips isEqualToString:[NSString stringWithFormat:@"%@ %@",ZCSTLocalString(@"您的留言状态有"),ZCSTLocalString(@"更新")]]){
                            index = i;
                            break;
                        }
                    }
                    if(index >= 0){
                        [[ZCUICore getUICore].listArray removeObjectAtIndex:index];
                        [self.listTable reloadData];
                    }
                }
            }
            
            // 直接跳转到 留言记录、
            leaveMessageVC.selectedType = 2;
            leaveMessageVC.ticketShowFlag  = 0;
            [chatView openNewPage:leaveMessageVC];
            return;
        }
        
        if ([[dict allKeys] containsObject:@"templateId"]) {
            templateId = [dict valueForKey:@"templateId"];
        }
        leaveMessageVC.selectedType = [code intValue];
    }

    [[ZCUIToastTools shareToast] showProgress:@"" with:self];
    
   static BOOL isJump = NO;
    // 线程处理
    dispatch_group_t group = dispatch_group_create();

    dispatch_group_enter(group);
    
    // 加载基础模板接口
    [[ZCLibServer getLibServer] postMsgTemplateConfigWithUid:[self getZCIMConfig].uid Templateld:templateId start:^{
        
    } success:^(NSDictionary *dict,NSMutableArray * typeArr, ZCNetWorkCode sendCode) {
        leaveMessageVC.tickeTypeFlag = [ zcLibConvertToString( dict[@"data"][@"item"][@"ticketTypeFlag"] )intValue];
        leaveMessageVC.ticketTypeId = zcLibConvertToString( dict[@"data"][@"item"][@"ticketTypeId"]);
        leaveMessageVC.telFlag = [zcLibConvertToString( dict[@"data"][@"item"][@"telFlag"]) boolValue];
        leaveMessageVC.telShowFlag = [zcLibConvertToString(dict[@"data"][@"item"][@"telShowFlag"]) boolValue];
        leaveMessageVC.emailFlag = [zcLibConvertToString(dict[@"data"][@"item"][@"emailFlag"]) boolValue];
        leaveMessageVC.emailShowFlag = [zcLibConvertToString(dict[@"data"][@"item"][@"emailShowFlag"]) boolValue];
        leaveMessageVC.enclosureFlag = [zcLibConvertToString(dict[@"data"][@"item"][@"enclosureFlag"]) boolValue];
        leaveMessageVC.enclosureShowFlag = [zcLibConvertToString(dict[@"data"][@"item"][@"enclosureShowFlag"]) boolValue];
//            leaveMessageVC.ticketShowFlag = [zcLibConvertToString(dict[@"data"][@"item"][@"ticketShowFlag"]) intValue];
        leaveMessageVC.ticketShowFlag = 1;
        leaveMessageVC.ticketTitleShowFlag = [zcLibConvertToString(dict[@"data"][@"item"][@"ticketTitleShowFlag"]) boolValue];
        
        leaveMessageVC.msgTmp = zcLibConvertToString(dict[@"data"][@"item"][@"msgTmp"]);
        leaveMessageVC.msgTxt = zcLibConvertToString(dict[@"data"][@"item"][@"msgTxt"]);
        if (typeArr.count) {
            if (leaveMessageVC.typeArr == nil) {
                leaveMessageVC.typeArr = [NSMutableArray arrayWithCapacity:0];
                leaveMessageVC.typeArr = typeArr;
            }
        }
        if ([dict[@"data"][@"retCode"] isEqualToString:@"000000"]) {
            isJump = YES;
        }else{
            isJump = NO;
        }
        dispatch_group_leave(group);
    } failed:^(NSString *errorMessage, ZCNetWorkCode errorCode) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [[ZCUIToastTools shareToast] showToast:ZCSTLocalString(@"网络错误，请检查网络后重试") duration:1.0f view:self position:ZCToastPositionCenter];

        });
        dispatch_group_leave(group);
    }];


    dispatch_group_notify(group, dispatch_get_main_queue(), ^{
        
        [[ZCUIToastTools shareToast] dismisProgress];
        if (isJump) {
            [chatView openNewPage:leaveMessageVC];
        }
    });
}



-(void)openNewPage:(UIViewController *) vc{
    if(self.superController && [self.superController isKindOfClass:[UIViewController class]]){
        if (self.superController.navigationController) {
//            vc.isNavOpen = YES;
            [self.superController.navigationController pushViewController:vc animated:YES];
        }else{
            UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:vc];
//            vc.isNavOpen = NO;
            nav.modalPresentationStyle = UIModalPresentationOverFullScreen;
            [self.superController  presentViewController:nav animated:YES completion:^{
                
            }];
            
        }
    }
}


#pragma mark -- 设置昵称
-(void)setTitleName:(NSString *)titleName{
    NSString *imageUrl = @"";
    /**
     * 0.默认 1.企业昵称 2.自定义昵称
     *
     */
    NSString *placeholderName = titleName;
    if ([[ZCLibClient getZCLibClient].libInitInfo.title_type intValue] == 1) {
        // 取企业昵称
        titleName = [self getZCIMConfig].companyName;
        imageUrl = [self getZCIMConfig].companyLogo;
        placeholderName = [self getZCIMConfig].companyName;
    }else if ([[ZCLibClient getZCLibClient].libInitInfo.title_type intValue] ==2) {
        if (![@"" isEqual:zcLibConvertToString([ZCLibClient getZCLibClient].libInitInfo.custom_title)]) {
            // 自定义的昵称
            titleName = [ZCLibClient getZCLibClient].libInitInfo.custom_title;
            imageUrl = [ZCLibClient getZCLibClient].libInitInfo.custom_title_url;
            placeholderName = [ZCLibClient getZCLibClient].libInitInfo.custom_title;
        }
    }else if ([[ZCLibClient getZCLibClient].libInitInfo.title_type intValue] == 3) {
           imageUrl = @"";
           if([self getZCIMConfig].isArtificial){
               titleName = [self getZCIMConfig].senderName;
           }else{
               if([self getZCIMConfig].type != 2){
                   titleName = [self getZCIMConfig].robotName;
               }
           }
    }else if ([[ZCLibClient getZCLibClient].libInitInfo.title_type intValue] == 4) {
           if([self getZCIMConfig].isArtificial){
               imageUrl = [self getZCIMConfig].senderFace;
               titleName = [self getZCIMConfig].senderName;
           }else{
               if([self getZCIMConfig].type != 2){
                   imageUrl = [self getZCIMConfig].robotLogo;
                   titleName = [self getZCIMConfig].robotName;
               }
           }
    }else{
        titleName = @"";
        if([self getZCIMConfig].isArtificial){
            imageUrl = [self getZCIMConfig].senderFace;
        }else{
            if([self getZCIMConfig].type != 2){
                imageUrl = [self getZCIMConfig].robotLogo;
            }
        }
    }
    
    // 当延迟转人工没有头像时，设置默认头像
    if([self getZCIMConfig].invalidSessionFlag && zcLibConvertToString(imageUrl).length == 0 && zcLibConvertToString(titleName).length == 0 && [self getZCIMConfig].type == 2){
        imageUrl = @"zcicon_useravatart_girl";
    }
    
    if ([placeholderName isEqualToString:ZCSTLocalString(@"排队中...")]) {
        titleName = ZCSTLocalString(@"排队中...");
        imageUrl = @"";
    }else if ([placeholderName isEqualToString:ZCSTLocalString(@"暂无客服在线")]){
        titleName = ZCSTLocalString(@"暂无客服在线");
        imageUrl = @"";
    }
    
    
    if(_hideTopViewNav){
        [self.zcTitleView setTitle:titleName image:imageUrl];
        
    }else{
        if (self.delegate && [self.delegate respondsToSelector:@selector(onTitleChanged:imageUrl:)]) {
            [self.delegate onTitleChanged:titleName imageUrl:imageUrl];
        }
    }
//    去掉 提示语句
//    NSString *placeholder = @"";
    
//    if ([self getZCIMConfig].isArtificial) {
//        placeholder = @"请反馈您的问题";
//    }else{
//        placeholder = [NSString stringWithFormat:ZCSTLocalString(@"跟%@说说你的问题吧"),placeholderName];
//    }
    
//    [self.keyboardTools.zc_chatTextView setPlaceholder:placeholder and:UIColorFromRGB(0xADB5C6)];
 
    
}
#pragma mark --  scrollTableToBottom  显示消息到TableView上
/**
 显示消息到TableView上
 */
-(void)scrollTableToBottom{
    isScrollBtm = false;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.25 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        
        if(!isScrollBtm){
            [self keyboardscrollTableToBottom];
            
        }
        isScrollBtm = true;
    });
    
}

// 加载历史消息
-(void)getHistoryMessage{
    // 调用endRefresh时，会导致table的y坐标变化，显示不全
    if(self.listTable.frame.origin.y < navTableY){
        CGRect f = self.listTable.frame;
        f.origin.y = navTableY;
        _listTable.frame = f;
    }
    
    [[ZCUICore getUICore] getChatMessages];
}

// 销毁界面
-(void)dismissZCChatView{
    if([_keyboardTools getKeyBoardViewStatus] == ZCKeyboardStatusNewSession){
        // 加上这一句，下次进入会立即初始化
        [[ZCPlatformTools sharedInstance] getPlatformInfo].config = nil;
    }
    
    [self backChatView];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    [[ZCUICore getUICore] desctoryZCBlock];
    self.closeButton = nil;
    self.delegate = nil;
    _socketStatusButton = nil;
    
    self.listTable = nil;
    self.changeRobotBtn = nil;
    
    self.topView = nil;
    self.backButton = nil;
    self.moreButton = nil;
    self.evaluationBtn = nil;
    self.telBtn = nil;
    self.zcTitleView = nil;
    self.superController = nil;
    self.refreshControl = nil;
    self.notifitionTopView = nil;
    [self removeFromSuperview];
    
}


-(void)saveDataToLocal{
    NSInteger keyboardtype = [self.keyboardTools getKeyBoardViewStatus];
    // 如果通道没有建立成功，当前正在链接中  则清空数据，下次重新初始化  2. 当前会话键盘是新会话键盘，返回时清空数据 重新初始化
    if(isStartConnectSockt || keyboardtype == ZCKeyboardStatusNewSession){
        [self getPlatformInfo].cidsArray = nil;
        
        [self getPlatformInfo].messageArr = nil;
    }else{
        [self getPlatformInfo].cidsArray = [[ZCUICore getUICore].cids mutableCopy];
        [self getPlatformInfo].messageArr = [[ZCUICore getUICore].listArray mutableCopy];
    }
    [ZCUICore getUICore].cids = nil;
    [ZCUICore getUICore].listArray = nil;
    
}

#pragma mark - tools 获取当前控制器
- (UIViewController *)getControllerFromView:(UIView *)view {
    // 遍历响应者链。返回第一个找到视图控制器
    UIResponder *responder = view;
    while ((responder = [responder nextResponder])){
        if ([responder isKindOfClass: [UIViewController class]]){
            return (UIViewController *)responder;
        }
    }
    // 如果没有找到则返回nil
    return nil;
}

#pragma mark -- 原普通版使用
#pragma mark -- 涉及到UI页面展示的时候，例如：uitabelview代理方法中计算高度 使用此方法 避免卡顿
-(ZCLibConfig *)getZCIMConfig{
    return [self getPlatformInfo].config;
    //从platforminfo 中获取config会卡顿
}


-(ZCPlatformInfo *) getPlatformInfo{
    return [[ZCPlatformTools sharedInstance] getPlatformInfo];
}




//- (void)scrollViewDidScroll:(UIScrollView *)scrollView
//{
//    CGFloat sectionHeaderHeight = 40;
//    if (scrollView.contentOffset.y<=sectionHeaderHeight&&scrollView.contentOffset.y>=0) {
//        scrollView.contentInset = UIEdgeInsetsMake(-scrollView.contentOffset.y, 0, 0, 0);
//    }
//    else if (scrollView.contentOffset.y>=sectionHeaderHeight) {
//        scrollView.contentInset = UIEdgeInsetsMake(-sectionHeaderHeight, 0, 0, 0);
//    }
//}
#pragma mark UITableView delegate Start
// 返回section数
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 2;
}

// 返回section高度
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if(_isNoMore && section == 0){
        return 0;
//        return TableSectionHeight;
    }
//    if(section == 1 && _zcKeyboardView && !_zcKeyboardView.vioceTipLabel.hidden){
//        return 40;
//    }
    return 0;
}

// 返回section 的View
-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    if(_isNoMore && section == 0){
        
//        UIView *view=[[UIView alloc] initWithFrame:CGRectMake(0, 0, viewWidth, TableSectionHeight)];
//        [view setBackgroundColor:[UIColor clearColor]];
//
//        UILabel *lbl=[[UILabel alloc] initWithFrame:CGRectMake(20, 20, viewWidth-40, TableSectionHeight -20)];
//        lbl.font=[ZCUITools zcgetListKitDetailFont];
//        lbl.backgroundColor = [UIColor clearColor];
//        [lbl setTextAlignment:NSTextAlignmentCenter];
//        // 没有更多记录的颜色
//        [lbl setTextColor:[ZCUITools zcgetTimeTextColor]];
//        [lbl setAutoresizesSubviews:YES];
//        [lbl setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
//        [lbl setText:ZCSTLocalString(@"到顶了，没有更多")];
//        [view addSubview:lbl];
//        return view;
    }
    
    if(section == 1){
        
        UIView *view=[[UIView alloc] initWithFrame:CGRectMake(0, 0, viewWidth, 40)];
        [view setBackgroundColor:[UIColor clearColor]];
        return view;
    }
    
    return nil;
}
-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 0;
}

-(UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    return nil;
}

// 返回section下得行数
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if(section == 1){
        return 0;
    }
    return [ZCUICore getUICore].chatMessages.count;
}

// cell
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    ZCChatBaseCell *cell=nil;
    //  解决数组越界问题
    if ( indexPath.row >= [ZCUICore getUICore].chatMessages.count) {
//        cell = (ZCRichTextChatCell*)[tableView dequeueReusableCellWithIdentifier:cellRichTextIdentifier];
//        if (cell == nil) {
//            cell = [[ZCRichTextChatCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellRichTextIdentifier];
//        }
        
        cell = (ZCChatAllRichCell *)[tableView dequeueReusableCellWithIdentifier:cellRichAllTextIdentifier];
        if (cell == nil) {
            cell = [[ZCChatAllRichCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellRichAllTextIdentifier];
        }
        return cell;
    }
     ZCLibMessage *model=[[ZCUICore getUICore].chatMessages objectAtIndex:indexPath.row];
//    model.commentType
//    NSLog(@".....%d",model.commentType);
    // 设置内容
    if(model.tipStyle>0){
        if (model.tipStyle == ZCReceivedMessageEvaluation) {
            cell = (ZCSatisfactionCell *)[tableView dequeueReusableCellWithIdentifier:cellSatisfactionIndentifier];
            if (cell == nil) {
                cell = [[ZCSatisfactionCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellSatisfactionIndentifier];
            }
        }else{
            cell = (ZCTipsChatCell*)[tableView dequeueReusableCellWithIdentifier:cellTipsIdentifier];
            if (cell == nil) {
                cell = [[ZCTipsChatCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellTipsIdentifier];
            }
        }
    }else if(model.tipStyle == ZCReceivedMessageUnKonw){
        // 商品内容
        cell = (ZCGoodsCell*)[tableView dequeueReusableCellWithIdentifier:cellGoodsIndentifier];
        if (cell == nil) {
            cell = [[ZCGoodsCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellGoodsIndentifier];
        }
    }else if(model.tipStyle == ZCReceiVedMessageNotice){
        // 通告消息
        cell = (ZCNoticeCell*)[tableView dequeueReusableCellWithIdentifier:cellNoticeCellIdentifier];
        if (cell == nil) {
            cell = [[ZCNoticeCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellNoticeCellIdentifier];
        }
        model.isOpenNotice = isOpenNotice;
    }else if(model.richModel.msgType == ZCMessageTypePhoto  || model.richModel.msgType == ZCMessageTypeVideo){
        cell = (ZCImageChatCell*)[tableView dequeueReusableCellWithIdentifier:cellImageIdentifier];
        if (cell == nil) {
            cell = [[ZCImageChatCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellImageIdentifier];
        }
    }else if(model.richModel.msgType == ZCMessageTypeText){
        cell = (ZCChatAllRichCell *)[tableView dequeueReusableCellWithIdentifier:cellRichAllTextIdentifier];
        if (cell == nil) {
            cell = [[ZCChatAllRichCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellRichAllTextIdentifier];
        }
    }else if(model.richModel.msgType== ZCMessageTypeSound){
        cell = (ZCVoiceChatCell*)[tableView dequeueReusableCellWithIdentifier:cellVoiceIdentifier];
        if (cell == nil) {
            cell = [[ZCVoiceChatCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellVoiceIdentifier];
        }
    }else if (model.richModel.msgType == ZCMessageTypeHotGuide){
        cell = (ZCHotGuideCell*)[tableView dequeueReusableCellWithIdentifier:cellHotGuideIdentifier];
        if (cell == nil) {
            cell = [[ZCHotGuideCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellHotGuideIdentifier];
        }
    }else if (model.richModel.msgType == ZCMessageTypeCard){
        cell = (ZCInfoCardCell*)[tableView dequeueReusableCellWithIdentifier:cellCardCellIdentifier];
        if (cell == nil) {
            cell = [[ZCInfoCardCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellCardCellIdentifier];
        }
    }else if (model.richModel.msgType == ZCMessageTypeOrder){
        cell = (ZCOrderGoodsCell*)[tableView dequeueReusableCellWithIdentifier:cellOrderGoodsIndentifier];
        if (cell == nil) {
            cell = [[ZCOrderGoodsCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellOrderGoodsIndentifier];
        }
    }
    else if (model.richModel.msgType == ZCMessageTypeFile){
        cell = (ZCFileCell*)[tableView dequeueReusableCellWithIdentifier:cellFileIndentifier];
        if (cell == nil) {
            cell = [[ZCFileCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellFileIndentifier];
        }
    }else if (model.richModel.msgType == ZCMessageTypeLocation){
        cell = (ZCLocationCell*)[tableView dequeueReusableCellWithIdentifier:cellLocationIndentifier];
        if (cell == nil) {
            cell = [[ZCLocationCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellLocationIndentifier];
        }
    }else if(model.richModel.msgType == ZCMessageTypeRichTextJson){
        if (model.richModel.multiModel.templateIdType == 0 || model.richModel.multiModel.templateIdType== 1|| model.richModel.multiModel.templateIdType== 2){
            // 横向的collection
            cell = (ZCMultitemHorizontaRollCell*)[tableView dequeueReusableCellWithIdentifier:cellMultitemHorizontaRollIndentifier];
            if (cell == nil) {
                cell =  [[ZCMultitemHorizontaRollCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellMultitemHorizontaRollIndentifier];
            }
        }else if (model.richModel.multiModel.templateIdType == 3){
            cell = (ZCMultiRichCell*)[tableView dequeueReusableCellWithIdentifier:cellMultiRichIdentifier];
            if (cell) {
                cell = [[ZCMultiRichCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellMultiRichIdentifier];
            }
        }
//        else if (model.richModel.multiModel.templateIdType == 5){
//            // 不会发生
//            cell = (ZCTextGuideCell*)[tableView dequeueReusableCellWithIdentifier:cellTextCellIdentifier];
//            if (cell) {
//                cell = [[ZCTextGuideCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellTextCellIdentifier];
//            }
//        }
    }
    if(cell == nil){
        cell = (ZCChatAllRichCell *)[tableView dequeueReusableCellWithIdentifier:cellRichAllTextIdentifier];
        if (cell == nil) {
            cell = [[ZCChatAllRichCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellRichAllTextIdentifier];
        }
    }

    
    cell.viewWidth = _listTable.frame.size.width;
    cell.delegate=self;
    NSString *time=@"";
    NSString *format=@"MM-dd HH:mm";
    
    if([model.cid isEqual:[self getZCIMConfig].cid]){// [self getZCIMConfig].cid
        format=@"HH:mm";
    }
    
    
    if(indexPath.row>0){
        ZCLibMessage *lm=[[ZCUICore getUICore].chatMessages objectAtIndex:(indexPath.row-1)];
        if(![model.cid isEqual:lm.cid]){
            //            time=intervalSinceNow(model.ts);
            time = zcLibDateTransformString(format, zcLibStringFormateDate(model.ts));
        }
    }else{
        time = zcLibDateTransformString(format, zcLibStringFormateDate(model.ts));
    }
    
    if([self getZCIMConfig].isArtificial){// [self getZCIMConfig].isArtificial
        model.isHistory = YES;
    }
    
    if(model.tipStyle == 2){
        time = @"";
    }
    
    // 不是中文时，不显示时间
//    if([ZCUICore getUICore].kitInfo.hideChatTime && (![zcGetLanguagePrefix() hasPrefix:@"zh-"] || ![[ZCLibClient getZCLibClient].libInitInfo.absolute_language hasPrefix:@"zh-"])){
    if([ZCUICore getUICore].kitInfo.hideChatTime){
        time = @"";
    }
    
    [cell InitDataToView:model time:time];
    
    [cell setBackgroundColor:[UIColor clearColor]];
    
    cell.selectionStyle=UITableViewCellSelectionStyleNone;
    return cell;
}

// table 行的高度
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([ZCUICore getUICore].chatMessages == nil || indexPath.row > [ZCUICore getUICore].chatMessages.count -1) {
        return 0;
    }
    
    ZCLibMessage *model =[[ZCUICore getUICore].chatMessages objectAtIndex:indexPath.row];
    NSString *time=@"";
    NSString *format=@"MM-dd HH:mm";
    if([model.cid isEqual:[self getZCIMConfig].cid]){// [self getZCIMConfig].cid
        format=@"HH:mm";
    }
    
    if(indexPath.row>0){
        ZCLibMessage *lm=[[ZCUICore getUICore].chatMessages objectAtIndex:(indexPath.row-1)];
        if(![model.cid isEqual:lm.cid]){
            //            time=intervalSinceNow(model.ts);
            time = zcLibDateTransformString(format, zcLibStringFormateDate(model.ts));
        }
        //        [ZCLogUtils logHeader:LogHeader debug:@"============\n%@\ncur=%@\nlast=%@\ntime=%@",model,model.cid,lm.cid,time];
    }else{
        time = zcLibDateTransformString(format, zcLibStringFormateDate(model.ts));
        //        time=intervalSinceNow(model.ts);
    }
    
    if(model.tipStyle == 2){
        time = @"";
    }
    if([ZCUICore getUICore].kitInfo.hideChatTime){
        time = @"";
    }
    
    CGFloat cellheight = 0;
    
    // 设置内容
    if(model.tipStyle>0){

        if(model.tipStyle == ZCReceivedMessageEvaluation){
            // 评价cell的高度
            cellheight = [ZCSatisfactionCell getCellHeight:model time:time viewWith:viewWidth];
        }else{
            // 提示cell的高度
            cellheight = [ZCTipsChatCell getCellHeight:model time:time viewWith:viewWidth];
        }

    }else if(model.tipStyle == ZCReceivedMessageUnKonw){
        // 商品内容
        cellheight = [ZCGoodsCell getCellHeight:model time:time viewWith:viewWidth];
    }else if(model.tipStyle == ZCReceiVedMessageNotice){
         model.isOpenNotice = isOpenNotice;
        cellheight = [ZCNoticeCell getCellHeight:model time:time viewWith:viewWidth];
    }else if(model.richModel.msgType==ZCMessageTypePhoto || model.richModel.msgType == ZCMessageTypeVideo){
        cellheight = [ZCImageChatCell getCellHeight:model time:time viewWith:viewWidth];
    }else if(model.richModel.msgType==ZCMessageTypeFile){// 文件
        cellheight = [ZCFileCell getCellHeight:model time:time viewWith:viewWidth];
    }else if(model.richModel.msgType==ZCMessageTypeLocation){// 位置
        cellheight = [ZCLocationCell getCellHeight:model time:time viewWith:viewWidth];
    }else if(model.richModel.msgType==ZCMessageTypeSound){
        cellheight = [ZCVoiceChatCell getCellHeight:model time:time viewWith:viewWidth];
    }else if (model.richModel.msgType == ZCMessageTypeHotGuide){
        cellheight = [ZCHotGuideCell getCellHeight:model time:time viewWith:viewWidth];
    }else if (model.richModel.msgType == ZCMessageTypeCard){
        cellheight = [ZCInfoCardCell getCellHeight:model time:time viewWith:viewWidth];
    }else if (model.richModel.msgType == ZCMessageTypeOrder){
        cellheight = [ZCOrderGoodsCell getCellHeight:model time:time viewWith:viewWidth];
    }else if(model.richModel.msgType==ZCMessageTypeRichTextJson){
        if (model.richModel.multiModel.templateIdType == 0 || model.richModel.multiModel.templateIdType == 1|| model.richModel.multiModel.templateIdType == 2){
            cellheight = [ZCMultitemHorizontaRollCell getCellHeight:model time:time viewWith:viewWidth];
        }
        else if (model.richModel.multiModel.templateIdType == 3){
            cellheight = [ZCMultiRichCell getCellHeight:model time:time viewWith:viewWidth];
        }
//        else if(model.richModel.multiModel.templateIdType == 5){
//            cellheight = [ZCTextGuideCell getCellHeight:model time:time viewWith:viewWidth];
//        }
    }
    if(cellheight == 0){
        cellheight = [ZCChatAllRichCell getCellHeight:model time:time viewWith:viewWidth];
    }
    return cellheight;
}

// table 行的点击事件
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}


#pragma mark table cell delegate start  cell点击的代理事件
-(void)cellItemClick:(ZCLibMessage *)model type:(ZCChatCellClickType)type obj:(id)object{
    if(type == ZCChatCellClickTypeNewDataGroup){
        int allSize         = (int)model.richModel.suggestionArr.count;
        int pageSize        =  model.richModel.guideGroupNum;
        int page         = (allSize%pageSize==0) ? (allSize/pageSize) : (allSize/pageSize+1);
        if((model.richModel.guideGroupPage + 1) < page){
            model.richModel.guideGroupPage = model.richModel.guideGroupPage + 1;
        }else{
            model.richModel.guideGroupPage = 0;
        }
        model.displaySugestionattr = nil;
        [ZCUITools zcModelStringToAttributeString:model];
        [self.listTable reloadData];
        return;
    }
    if(type == ZCChatCellClickTypeNewSession){
        //  要去初始化啊
        [[ZCUICore getUICore] initConfigData:YES IsNewChat:YES];
        return;
    }
    if (type == ZCChatCellClickTypeItemCancelFile) {
        // 取消发送文件
        [[ZCUICore getUICore] cancelSendFileMsg:model];
        return;
    }
    
    if(type == ZCChatCellClickTypeItemOpenLocation){
        NSString *linkUrl = [NSString stringWithFormat:@"sobot://openlocation?latitude=%@&longitude=%@&address=%@",model.richModel.latitude,model.richModel.longitude,model.richModel.localLabel];
        
        [self cellItemLinkClick:nil type:ZCChatCellClickTypeOpenURL obj:linkUrl];
        
        
        return;
    }
    
    if (type == ZCChatCellClickTypeNotice) {
        // 展开和收起
        isOpenNotice = NO;
        if ([object intValue] == 2) {
            isOpenNotice = YES;
        }
        [self.listTable reloadData];
        return;
    }
    
    if (type == ZCChatCellClickTypeCollectionBtnSend) {
        // 展开和收起
        [self.listTable reloadData];
        [self scrollTableToBottom];
        return;
    }
    
    // 打开文件
    if(type == ZCChatCellClickTypeItemOpenFile){
        ZCDocumentLookController *leaveMessageVC = [[ZCDocumentLookController alloc]init];
        leaveMessageVC.message = model;
        [self openNewPage:leaveMessageVC];
        return;
    }
    
    if ([_keyboardTools getKeyBoardViewStatus] == ZCKeyboardStatusNewSession && type == ZCChatCellClickTypeItemChecked) {
        [[ZCUICore getUICore] addTipsListenerMessage:ZCTipMessageOverWord];
        return;
    }
    
    if(type == ZCChatCellClickTypeSendGoosText && ![self getZCIMConfig].isArtificial){
        return;
    }
    
    if (type == ZCChatCellClickTypeShowToast) {
        [[ZCUIToastTools shareToast] showToast:[NSString stringWithFormat:@"   %@  ",ZCSTLocalString(@"复制成功！")] duration:1.0f view:[[ZCToolsCore getToolsCore] getCurWindow].rootViewController.view position:ZCToastPositionCenter Image:[ZCUITools zcuiGetBundleImage:@"zcicon_successful"]];
        return;
    }
    
    // 点击满意度，调评价
    if (type == ZCChatCellClickTypeSatisfaction) {
        
    }
    
    if (type == ZCChatCellClickTypeLeaveMessage) {
        [_keyboardTools hideKeyboard];
        // 不直接退出SDK
        [self changeLeaveMsgType:LeaveExitTypeISNOCOLSE];
    }
    
    if (type == ZCChatCellClickTypeLeaveRecordPage) {
        [_keyboardTools hideKeyboard];
        // 跳转到留言记录
        [self jumpNewPageVC:ZC_LeaveRecordPage IsExist:2 isShowToat:NO tipMsg:@"" Dict:@{@"selectedType":@"2",@"templateId":@"1"}];
    }
    
    if(type==ZCChatCellClickTypeTouchImageYES){
        if(object!=nil && [object isKindOfClass:[ZCUIXHImageViewer class]]){
            xhObj = object;
        }
        [_keyboardTools hideKeyboard];
    }
    
    if(type==ZCChatCellClickTypeTouchImageNO){
        // 隐藏大图查看
        xhObj = nil;
    }
    
    if(type==ZCChatCellClickTypeItemChecked){
        // 向导内容
        NSDictionary *dict = model.richModel.suggestionArr[[object intValue]];
        if(dict==nil || dict[@"question"]==nil){
            return;
        }
//        [[ZCUICore getUICore] sendMessage:[NSString stringWithFormat:@"%d.%@",[object intValue]+1,dict[@"question"]] questionId:dict[@"docId"] type:ZCMessageTypeText duration:@""];
        [[ZCUICore getUICore] sendMessage:[NSString stringWithFormat:@"%@",dict[@"question"]] questionId:dict[@"docId"] type:ZCMessageTypeText duration:@""];
    }
    
    
    if (type == ZCChatCellClickTypeGroupItemChecked) {
        // 点击机器人回复的技能组选项
        NSDictionary *dict = model.groupList[[object intValue]];
        if(dict==nil || dict[@"groupId"]==nil){
            return;
        }
        int temptype = [self getZCIMConfig].type;
        if ([ZCLibClient getZCLibClient].libInitInfo.service_mode >0) {
            temptype = [ZCLibClient getZCLibClient].libInitInfo.service_mode;
        }
        if (temptype == 1) {
            return;
        }
        // 点击技能组转人工
//        [ZCLibClient getZCLibClient].libInitInfo.skillSetName = zcLibConvertToString (dict[@"groupName"]);
//        [ZCLibClient getZCLibClient].libInitInfo.skillSetId = zcLibConvertToString(dict[@"groupId"]);
        
        // 执行转人工  不在显示技能组
        if ([ZCLibClient getZCLibClient].turnServiceBlock) {
            [ZCLibClient getZCLibClient].turnServiceBlock(nil, nil, ZCTurnType_CellGroupClick, model.keyword, model.keywordId);
            return;
        }
        [[ZCUICore getUICore] toConnectUserService:model  GroupId:dict[@"groupId"] GroupName:dict[@"groupName"] ZCTurnType:ZCTurnType_CellGroupClick];
        
    }
    
    // 发送商品信息给客服
    if(type == ZCChatCellClickTypeSendGoosText){
        ZCProductInfo *pinfo = object;
        NSMutableDictionary * contentDic = [NSMutableDictionary dictionaryWithCapacity:5];
        NSString *contextStr = @"";
        
        [contentDic setObject:[NSString stringWithFormat:@"%@",zcLibConvertToString(pinfo.title)] forKey:@"title"];
        
        [contentDic setObject:[NSString stringWithFormat:@"%@",zcLibConvertToString(pinfo.desc)] forKey:@"description"];
        
        [contentDic setObject:[NSString stringWithFormat:@"%@",zcLibConvertToString(pinfo.label)] forKey:@"label"];
        
        [contentDic setObject:[NSString stringWithFormat:@"%@",zcLibConvertToString(pinfo.link)] forKey:@"url"];
        
        [contentDic setObject:[NSString stringWithFormat:@"%@",zcLibConvertToString(pinfo.thumbUrl)] forKey:@"thumbnail"];
        // 转json
        contextStr = [ZCLocalStore DataTOjsonString:contentDic];
        
        [[ZCUICore getUICore] sendMessage:contextStr questionId:@"" type:ZCMessageTypeCard duration:@""];
    }
    
    // 重新发送
    if(type==ZCChatCellClickTypeReSend){
        // 当前的键盘样式是新会话的样式，重新发送的消息不在发送  （用户超时下线提示和会话结束提示）
        //        [self.zcKeyboardView getKeyBoardViewStatus] == AGAINACCESSASTATUS
        if ([_keyboardTools getKeyBoardViewStatus] == ZCKeyboardStatusNewSession) {
            [_listTable reloadData];
            return;
        }
        NSDictionary *dict = nil;
        NSString *text = model.richModel.msg;
        if(model.richModel.msgType == ZCMessageTypeLocation){
             dict = @{@"lng":model.richModel.longitude,@"lat":model.richModel.latitude,@"localName":model.richModel.localName,@"localLabel":model.richModel.localLabel,@"file":model.richModel.richmoreurl};
//            model.richModel.msg = model.richModel.richmoreurl;
            text = model.richModel.richmoreurl;
        }
        if(model.richModel.msgType == ZCMessageTypeVideo){
            dict = @{@"cover":model.richModel.msg};
//            model.richModel.msg = model.richModel.richmoreurl;
            text = model.richModel.richmoreurl;
        }
        if (model.richModel.msgType == ZCMessageTypeFile) {
            text = model.richModel.richmoreurl;
        }
        
        [[ZCLibServer getLibServer] sendMessage:text questionId:@"" msgType:model.richModel.msgType duration:model.richModel.duration config:[self getZCIMConfig] robotFlag:[NSString stringWithFormat:@"%d",[self getZCIMConfig].robotFlag] dict:dict start:^(ZCLibMessage *message) {
            model.sendStatus = 1;
            [_listTable reloadData];
        } success:^(ZCLibMessage *message, ZCMessageSendCode sendCode) {
            model.sendStatus = message.sendStatus;
            
            if(![self getZCIMConfig].isArtificial && sendCode == ZC_SENDMessage_New){
                NSInteger index = [[ZCUICore getUICore].listArray indexOfObject:model];
                
                // 如果返回的数据是最后一轮，当前的多轮会话的cell不可点击
                // 记录下标
//                if ( [zcLibConvertToString([NSString stringWithFormat:@"%d",message.richModel.answerType]) hasPrefix:@"15"]  && message.richModel.multiModel.endFlag) {
//                    for (ZCLibMessage *message in [ZCUICore getUICore].listArray) {
//                        if ([zcLibConvertToString([NSString stringWithFormat:@"%d",message.richModel.answerType]) hasPrefix:@"15"] && !message.richModel.multiModel.endFlag && !message.richModel.multiModel.isHistoryMessages ) {
//                            message.richModel.multiModel.isHistoryMessages = YES;// 变成不可点击，成为历史
//                        }
//                    }
//                }
                
                [[ZCUICore getUICore] splitMessageModel:message Index:index weakself:[ZCUICore getUICore]];
                
//                [[ZCUICore getUICore].listArray insertObject:message atIndex:index+1];
//                [_listTable reloadData];
//                [self scrollTableToBottom];
            }else if(sendCode == ZC_SENDMessage_Success){
                model.sendStatus = 0;
                model.richModel.msgtranslation = message.richModel.msgtranslation;
                
                [_listTable reloadData];
            }else{
                model.sendStatus = 2;
                [_listTable reloadData];
            }
        } progress:^(ZCLibMessage *message) {
            model.progress = message.progress;
            [_listTable reloadData];
        } fail:^(ZCLibMessage *message, ZCMessageSendCode errorCode) {
            model.sendStatus = 2;
            [_listTable reloadData];
            
        }];
    }
    
    if(type==ZCChatCellClickTypePlayVoice  || type == ZCChatCellClickTypeReceiverPlayVoice){
        if([ZCUICore getUICore].animateView){
            [[ZCUICore getUICore].animateView stopAnimating];
        }
        
        // 已经有播放的，关闭当前播放的
        if(_voiceTools){
            [_voiceTools stopVoice];
        }
        
        if([ZCUICore getUICore].playModel){
            [ZCUICore getUICore].playModel.isPlaying=NO;
            [ZCUICore getUICore].playModel=nil;
        }
        
        if([object isEqual:[ZCUICore getUICore].animateView]){
            [ZCUICore getUICore].animateView = nil;
            return;
        }
        
        
        [ZCUICore getUICore].playModel=model;
        [ZCUICore getUICore].playModel.isPlaying=YES;
        
        [ZCUICore getUICore].animateView=object;
        
        [[ZCUICore getUICore].animateView startAnimating];
        
        // 本地文件
        if(zcLibCheckFileIsExsis(model.richModel.msg)){
            if(_voiceTools){
                [_voiceTools playAudio:[NSURL fileURLWithPath:model.richModel.msg] data:nil];
            }
        }else{
            NSString *voiceURL=model.richModel.msg;
            NSString *dataPath = zcLibGetDocumentsFilePath(@"/sobot/");
            // 创建目录
            zcLibCheckPathAndCreate(dataPath);
            
            // 拼接完整的地址
            dataPath=[dataPath stringByAppendingString:[NSString stringWithFormat:@"/%@.wav",zcLibMd5(voiceURL)]];
            if(zcLibCheckFileIsExsis(dataPath)){
                if(_voiceTools){
                    [_voiceTools playAudio:[NSURL fileURLWithPath:dataPath] data:nil];
                }
                return;
            }
            
            // 下载，播放网络声音
            [[ZCLibServer getLibServer] downFileWithURL:model.richModel.msg start:^{
                
            } success:^(NSData *data) {
                [data writeToFile:dataPath atomically:YES];
                if(_voiceTools){
                    [_voiceTools playAudio:[NSURL fileURLWithPath:dataPath] data:nil];
                }
            } progress:^(float progress) {
                
            } fail:^(ZCNetWorkCode errorCode) {
                
            }];
        }
    }
    
    // 转人工
    if(type == ZCChatCellClickTypeConnectUser){
        if ([ZCLibClient getZCLibClient].turnServiceBlock) {
            [ZCLibClient getZCLibClient].turnServiceBlock(nil, nil, ZCTurnType_BtnClick, @"", @"");
            return;
        }
        NSDictionary *obj = nil;
        if(model.transferType == 4){
            obj=@{@"value":@"4"};
        }
        [[ZCUICore getUICore] checkUserServiceWithObject:obj Msg:nil];
    }
    
    // 踩/顶   -1踩   1顶
    if(type == ZCChatCellClickTypeStepOn || type == ZCChatCellClickTypeTheTop){
        
        if ([self.keyboardTools getKeyBoardViewStatus] == ZCKeyboardStatusNewSession) {
            // 置灰不可点
            [[ZCUIToastTools shareToast] showToast:ZCSTLocalString(@"会话结束，无法反馈") duration:1.5f view:self.window.rootViewController.view position:ZCToastPositionCenter];
            model.commentType = 4;
            [_listTable  reloadData];
            return;
        }
        
        
        int status = (type == ZCChatCellClickTypeStepOn)?-1:1;
        
        [[ZCLibServer getLibServer] rbAnswerComment:[self getZCIMConfig] message:model status:status start:^{
            
        } success:^(ZCNetWorkCode code) {
            if(status== -1){
                model.commentType = 3;
                [[ZCUIToastTools shareToast] showToast:ZCSTLocalString(@"我会努力学习，希望下次帮到您") duration:1.5f view:self.window.rootViewController.view position:ZCToastPositionCenter];
            }else{
                model.commentType = 2;
                [[ZCUIToastTools shareToast] showToast:ZCSTLocalString(@"感谢您的支持") duration:1.5f view:self.window.rootViewController.view position:ZCToastPositionCenter];
            }
            [_listTable  reloadData];
            
        } fail:^(ZCNetWorkCode errorCode) {
            
        }];
    }
    
    // collectionView item 点击
    if (type == ZCChatCellClickTypeCollectionSendMsg || type == ZCChatCellClickTypeItemGuide) {
        //  多轮会话，发送给机器人
        
        NSDictionary * dict = (NSDictionary*)object;
        
        // 发送完成再计数
        [[ZCUICore getUICore] cleanUserCount];
        
        //        * 正在发送的消息对象，方便更新状态
        __block ZCLibMessage    *sendMessage;
        
        __weak ZCChatView *safeVC = self;
        
        if ([self getZCIMConfig].isArtificial || [dict[@"ishotguide"] intValue] == 1) {
            [[ZCUICore getUICore] sendMessage:dict[@"title"] questionId:@"" type:ZCMessageTypeText duration:@""];
            return;
        }
        // 发送给机器人
        [[ZCLibServer getLibServer] sendToRobot:dict[@"requestText"] showText:dict[@"title"] questionStr:dict[@"question"] questionFlag:2 msgType:(int)model.richModel.msgType questionId:@"" config:[self getZCIMConfig] robotFlag:[NSString stringWithFormat:@"%d",[self getPlatformInfo].config.robotFlag]  duration:@"" start:^(ZCLibMessage *message) {
            sendMessage  = message;
            sendMessage.sendStatus=1;
            
            [ZCUITools zcModelStringToAttributeString:sendMessage];
            
            [[ZCUICore getUICore].listArray addObject:sendMessage];
            [safeVC.listTable reloadData];
            [safeVC scrollTableToBottom];
        } success:^(ZCLibMessage *message, ZCMessageSendCode sendCode) {
            [ZCUICore getUICore].isSendToUser = NO;
            [ZCUICore getUICore].isSendToRobot = YES;
            if(sendCode==ZC_SENDMessage_New){
                if(message.richModel
                   && (message.richModel.answerType==3
                       ||message.richModel.answerType==4)
                   && ![ZCUICore getUICore].kitInfo.isShowTansfer
                   && ![ZCLibClient getZCLibClient].isShowTurnBtn){
                    safeVC.unknownWordsCount ++;
                    if([[ZCUICore getUICore].kitInfo.unWordsCount integerValue]==0) {
                        [ZCUICore getUICore].kitInfo.unWordsCount =@"1";
                    }
                    if (safeVC.unknownWordsCount >= [[ZCUICore getUICore].kitInfo.unWordsCount integerValue]) {
                        
                        // 仅机器人的模式不做处理
                        if ([safeVC getZCIMConfig].type != 1) {
                            // 设置键盘的样式 （机器人，转人工按钮显示）
                            [safeVC.keyboardTools setKeyBoardStatus:ZCKeyboardStatusRobot];
                            // 保存在本次有效的会话中显示转人工按钮
                            [ZCLibClient getZCLibClient].isShowTurnBtn = YES;
                            

                            // 键盘状态发生变化了，需要重新设置table的高度，因为新会话的键盘高度变化了
                            [self setFrameForListTable];
                            
                        }
                    }
                    
                }
                
                NSInteger index = [[ZCUICore getUICore].listArray indexOfObject:sendMessage];
                
                // 如果返回的数据是最后一轮，当前的多轮会话的cell不可点击
                // 记录下标
//                if ( [zcLibConvertToString([NSString stringWithFormat:@"%d",message.richModel.answerType]) hasPrefix:@"15"]  && message.richModel.multiModel.endFlag) {
//                    // 便利所有多轮会话的消息 变成历史不可点
//                    for (ZCLibMessage *message in [ZCUICore getUICore].listArray) {
//                        if ([zcLibConvertToString([NSString stringWithFormat:@"%d",message.richModel.answerType]) hasPrefix:@"15"] && !message.richModel.multiModel.endFlag && !message.richModel.multiModel.isHistoryMessages ) {
//                            message.richModel.multiModel.isHistoryMessages = YES;// 变成不可点击，成为历史
//                        }
//                    }
//                }
//
//                [[ZCUICore getUICore].listArray insertObject:message atIndex:index+1];
//                [safeVC.listTable reloadData];
//                [safeVC scrollTableToBottom];
                
                [[ZCUICore getUICore] splitMessageModel:message Index:index weakself:[ZCUICore getUICore]];
                
                
            }else if(sendCode==ZC_SENDMessage_Success){
                sendMessage.sendStatus=0;
                sendMessage.richModel.msgtranslation = message.richModel.msgtranslation;
                [safeVC.listTable reloadData];
            }else {
                sendMessage.sendStatus=2;
                [safeVC.listTable reloadData];
                if(sendCode == ZC__SENDMessage_FAIL_STATUS){
                    /**
                     *   给人工发消息没有成功，说明当前已经离线
                     *   1.回收键盘
                     *   2.添加结束语
                     *   3.添加新会话键盘样式
                     *   4.中断计时
                     *
                     **/
                    [[ZCUICore getUICore] cleanUserCount];
                    [[ZCUICore getUICore] cleanAdminCount];
                    [_keyboardTools hideKeyboard];
                    [_keyboardTools setKeyBoardStatus:ZCKeyboardStatusNewSession];
                    [[ZCUICore getUICore] addTipsListenerMessage:ZCTipMessageOverWord];

                    // 键盘状态发生变化了，需要重新设置table的高度，因为新会话的键盘高度变化了
                    [self setFrameForListTable];
                }
            }
            
        } progress:^(ZCLibMessage *message) {
            [ZCUICore getUICore].isSendToUser = NO;
            [ZCUICore getUICore].isSendToRobot = YES;
            [ZCLogUtils logText:@"上传进度：%f",message.progress];
            sendMessage.progress = message.progress;
            [safeVC.listTable reloadData];
        } failed:^(ZCLibMessage *message, ZCMessageSendCode sendCode) {
            [ZCUICore getUICore].isSendToUser = NO;
            [ZCUICore getUICore].isSendToRobot = YES;
            sendMessage.sendStatus=2;
            [safeVC.listTable reloadData];
        }];
    }
     
}

-(void)cellItemLinkClick:(NSString *)text type:(ZCChatCellClickType)type obj:(NSString *)linkURL{
    if(type==ZCChatCellClickTypeOpenURL){
        // 通知外部可以更新UI
        
//        链接处理：
        [[ZCToolsCore getToolsCore] dealWithLinkClickWithLick:linkURL viewController:self.superController];
        

    }
}


#pragma mark UITableView delegate end

-(void)configShowNotifion{
    [[ZCUICore getUICore] setInputListener:_keyboardTools.zc_chatTextView];
    if ([[ZCUICore getUICore] getLibConfig].announceMsgFlag == 1 && [[ZCUICore getUICore] getLibConfig].announceTopFlag == 1) {
        // 初始化结束后添加通告
        [self notifitionTopViewWithisShowTopView:[self getPlatformInfo].config.announceMsg
                                          addressUrl:[self getPlatformInfo].config.announceClickUrl
                                             iconUrl:[ZCLibClient getZCLibClient].libInitInfo.notifition_icon_url];
        
        // 显示置顶的标签，重置table的坐标
        [self setFrameForListTable];
    }
}

#pragma mark -- 通告栏 eg: “国庆大酬宾。
- (UIView *)notifitionTopViewWithisShowTopView:(NSString *) title  addressUrl:(NSString *)url iconUrl:(NSString *)icoUrl{
    
    if ([[ZCUICore getUICore] getLibConfig].announceMsgFlag == 1 && [[ZCUICore getUICore] getLibConfig].announceTopFlag == 1) {

        if (!_notifitionTopView && ![@"" isEqual:zcLibConvertToString(title)]) {
            _notifitionTopView = [[UIView alloc]init];
            CGFloat Y = 0;
            if (_superController.navigationController.navigationBarHidden || [ZCUICore getUICore].kitInfo.navcBarHidden) {
                Y = NavBarHeight;
            }
            _notifitionTopView.frame = CGRectMake(0, Y, viewWidth, 36);
            [_notifitionTopView setAutoresizesSubviews:YES];
            [_notifitionTopView setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
            _notifitionTopView.backgroundColor = [ZCUITools getNotifitionTopViewBgColor];
    //        _notifitionTopView.alpha = 0.8;
      
            UITapGestureRecognizer * tapAction = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(jumpWebView:)];
            
            
            // icon
            ZCUIImageView * icon = [[ZCUIImageView alloc]initWithFrame:CGRectMake(10, 10, 14,14)];
            if (![@"" isEqual:zcLibConvertToString(icoUrl)]) {
                [icon loadWithURL:[NSURL URLWithString:zcUrlEncodedString(icoUrl)] placeholer:[ZCUITools zcuiGetBundleImage:@"zcicon_annunciate"] showActivityIndicatorView:NO];
            }else{
                [icon setImage:[ZCUITools zcuiGetBundleImage:@"zcicon_annunciate"]];
            }
            
            icon.contentMode = UIViewContentModeScaleAspectFill;
            [icon setBackgroundColor:[UIColor clearColor]];
            [icon addGestureRecognizer:tapAction];
            [_notifitionTopView addSubview:icon];
            
            CGFloat animateWidth = viewWidth - 30 - 10;
            // 跑马灯label
            UILabel *titleLab = [[UILabel alloc]initWithFrame:CGRectMake(CGRectGetMaxX(icon.frame), 0,animateWidth, 20)];
            titleLab.font = [ZCUITools zcgetNotifitionTopViewFont];
            titleLab.textColor = [ZCUITools getNotifitionTopViewLabelColor];
            [titleLab setAutoresizingMask:UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin];
            [titleLab setAutoresizesSubviews:YES];
            // 过滤 html标签
            // 处理换行
            
            NSString * text = title;
            text = [text stringByReplacingOccurrencesOfString:@"<br />" withString:@""];
            text = [text stringByReplacingOccurrencesOfString:@"<br/>" withString:@""];
            text = [text stringByReplacingOccurrencesOfString:@"<br>" withString:@""];
            text = [text stringByReplacingOccurrencesOfString:@"<BR/>" withString:@""];
            text = [text stringByReplacingOccurrencesOfString:@"<BR />" withString:@""];
            text = [text stringByReplacingOccurrencesOfString:@"<p>" withString:@""];
            text = [text stringByReplacingOccurrencesOfString:@"</p>" withString:@""];
            text = [text stringByReplacingOccurrencesOfString:@"&nbsp;" withString:@""];
            titleLab.text = text;
            [titleLab addGestureRecognizer:tapAction];
            [titleLab sizeToFit];
        
            UIView *bgView = [[UIView alloc]initWithFrame:CGRectMake(CGRectGetMaxX(icon.frame) +10, 8, viewWidth - 30- 10-10 - icon.frame.size.width, 20)];
            bgView.layer.masksToBounds = YES;
            [_notifitionTopView addSubview:bgView];
            [bgView addSubview:titleLab];
            
            // 关闭跑马灯效果,2.8.0最大20字
            if (titleLab.frame.size.width > animateWidth) {
                [self Aniantions:titleLab width:animateWidth];
            }else{
                CGRect frame = titleLab.frame;
                frame.size.height = ZCNumber(20);
                frame.origin.x = 0;
                titleLab.frame = frame;
                [titleLab setTextAlignment:NSTextAlignmentLeft];
            }
        
            if (zcLibConvertToString([self getZCIMConfig].announceClickUrl).length >0 && [self getZCIMConfig].announceClickFlag == 1) {
                // arraw
//                UIImageView * arrawIcon = [[UIImageView alloc]initWithFrame:CGRectMake(viewWidth - 30, 15, 11, 11)];
//                arrawIcon.backgroundColor = [UIColor clearColor];
//                [arrawIcon setImage:[ZCUITools zcuiGetBundleImage:@"zcicon_arrow_right"]];
//    //            arrawIcon.transform = CGAffineTransformMakeRotation(M_PI);
//                arrawIcon.contentMode = UIViewContentModeScaleAspectFill;
//                [arrawIcon addGestureRecognizer:tapAction];
//                [arrawIcon setAutoresizesSubviews:YES];
//                [arrawIcon setAutoresizingMask:UIViewAutoresizingFlexibleLeftMargin];
//                [_notifitionTopView addSubview:arrawIcon];
                
                titleLab.textColor = UIColorFromThemeColor(ZCTextNoticeLinkColor);

            }else{
                titleLab.textColor = [ZCUITools getNotifitionTopViewLabelColor];
            }

            
            [_notifitionTopView addGestureRecognizer:tapAction];
            [self addSubview:_notifitionTopView];
            _notifitionTopView.hidden = NO;
        }
    }
    return _notifitionTopView;
}

-(void)beginAniantions{
    if (_notifitionTopView != nil) {
        [_notifitionTopView removeFromSuperview];
        _notifitionTopView = nil;
        [self configShowNotifion];
    }
   
}

-(void)Aniantions:(UILabel *) titleLab width:(CGFloat )baseWidth{
    if (!_notifitionTopView.hidden) {
        
        [UIView beginAnimations:@"Marquee" context:NULL];
        [UIView setAnimationDuration:CGRectGetWidth(titleLab.frame) / 30.f * (1 / 1.0f)];
//        CGFloat duration = (titleLab.frame.size.width - baseWidth) / 30.f * (1 / 1.0f);
//        if(duration < 2){
//            duration = 2.0;
//        }
//        [UIView setAnimationDuration:duration];
        [UIView setAnimationCurve:UIViewAnimationCurveLinear];
        [UIView setAnimationRepeatAutoreverses:NO];
        
        [UIView setAnimationRepeatCount:MAXFLOAT];
        
        CGRect frame = titleLab.frame;
//        frame.origin.x = -(frame.size.width - baseWidth + 30);
        frame.origin.x = -frame.size.width;
        titleLab.frame = frame;
        [UIView commitAnimations];
    }
}


-(UIButton *)newWorkStatusButton{
    if(!_newWorkStatusButton){
        CGFloat NWY = NavBarHeight;
        if (!self.superController.navigationController.navigationBarHidden) {
            NWY = 0;
        }
        _newWorkStatusButton=[UIButton buttonWithType:UIButtonTypeCustom];
        [_newWorkStatusButton setFrame:CGRectMake(0, NWY, CGRectGetWidth(self.frame), 40)];
        [_newWorkStatusButton setContentEdgeInsets:UIEdgeInsetsMake(0, 10, 0, 10)];
        [_newWorkStatusButton setImage:[ZCUITools zcuiGetBundleImage:@"zcicon_tag_nonet"] forState:UIControlStateNormal];
        [_newWorkStatusButton.imageView setContentMode:UIViewContentModeScaleAspectFit];
        [_newWorkStatusButton setBackgroundColor:UIColorFromRGBAlpha(BgNetworkFailColor, 0.8)];
        [_newWorkStatusButton setTitle:[NSString stringWithFormat:@" %@",ZCSTLocalString(@"当前网络不可用，请检查您的网络设置")] forState:UIControlStateNormal];
        [_newWorkStatusButton setTitleColor:UIColorFromRGB(TextNetworkTipColor) forState:UIControlStateNormal];
        [_newWorkStatusButton.titleLabel setFont:ZCUIFont15];
        [_newWorkStatusButton setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
        
        [self addSubview:_newWorkStatusButton];
        
        _newWorkStatusButton.hidden=YES;
    }
    return _newWorkStatusButton;
}

-(UIButton *)socketStatusButton{
    if(!_socketStatusButton){
        _socketStatusButton=[UIButton buttonWithType:UIButtonTypeCustom];
//        [_socketStatusButton setFrame:CGRectMake(60, SSY, CGRectGetWidth(self.frame)-120, 44)];
        [_socketStatusButton.imageView setContentMode:UIViewContentModeScaleAspectFit];
        [_socketStatusButton setBackgroundColor:[ZCUITools zcgetBgBannerColor]];
        if ([ZCUICore getUICore].kitInfo.topViewBgColor != nil) {
            [_socketStatusButton setBackgroundColor:[ZCUICore getUICore].kitInfo.topViewBgColor];
        }
        [_socketStatusButton setTitle:[NSString stringWithFormat:@"  %@",ZCSTLocalString(@"收取中...")] forState:UIControlStateNormal];
        [_socketStatusButton setTitleColor:[ZCUITools zcgetTopViewTextColor] forState:UIControlStateNormal];
        [_socketStatusButton.titleLabel setFont:[ZCUITools zcgetTitleFont]];
        [_socketStatusButton setContentHorizontalAlignment:UIControlContentHorizontalAlignmentCenter];
        
        
        CGFloat SSY = NavBarHeight;
        if (!self.superController.navigationController.navigationBarHidden) {
            SSY = 0;
        }
        [_socketStatusButton setFrame:CGRectMake(0, SSY, CGRectGetWidth(self.frame), 40)];
        [self addSubview:_socketStatusButton];
        
        _socketStatusButton.hidden=YES;
        
        UIActivityIndicatorView *_activityView=[[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
        _activityView.hidden=YES;
        _activityView.tag = 1;
        _activityView.center = CGPointMake(_socketStatusButton.frame.size.width/2 - 50, 20);
        [_socketStatusButton addSubview:_activityView];
    }
    return _socketStatusButton;
    
    
}

- (void)jumpWebView:(UITapGestureRecognizer*)tap{
      [_keyboardTools hideKeyboard];
    if (zcLibConvertToString([self getZCIMConfig].announceClickUrl).length >0 && [self getZCIMConfig].announceClickFlag == 1) {
        [self cellItemLinkClick:nil type:ZCChatCellClickTypeOpenURL obj:[self getZCIMConfig].announceClickUrl];
    }
}


-(void)cleanHistoryMessage{
    [_keyboardTools hideKeyboard];
    ZCActionSheet *mysheet = [[ZCActionSheet alloc] initWithDelegate:self selectedColor:UIColorFromRGB(TextCleanMessageColor) CancelTitle:ZCSTLocalString(@"取消") OtherTitles:ZCSTLocalString(@"清空聊天记录"), nil];
    mysheet.selectIndex = 1;
    [mysheet show];

}

-(void)goEvaluation{
    [[ZCUICore getUICore] keyboardOnClickSatisfacetion:NO];
}

// 清空聊天记录代理
- (void)actionSheet:(ZCActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex == 1) {
        
        [[ZCToolsCore getToolsCore] showAlert:nil message:ZCSTLocalString(@"清空记录将无法恢复,是否要清空历史记录？") cancelTitle:ZCSTLocalString(@"取消") viewController:[self getControllerFromView:self]    confirm:^(NSInteger buttonTag) {
            
            if (buttonTag >= 0) {
                // 清空历史记录
                [[ZCUICore getUICore].listArray removeAllObjects];
                _isNoMore = NO;
                //        _isClearnHistory = YES;
                [self.listTable reloadData];
                //                [ZCUICore getUICore].isClearnHistory = YES;
            }
            
            [[ZCLibServer getLibServer] cleanHistoryMessage:[self getZCIMConfig].uid success:^(NSData *data) {
                
            } fail:^(ZCNetWorkCode errorCode) {
                
            }];
            
        } buttonTitles:ZCSTLocalString(@"清空"), nil];
      
        
    }
}

- (void)confimGoBackWithType:(ZCChatViewGoBackType )type{
    
    BOOL showEvaluation = NO;
    switch (type) {
        case ZCChatViewGoBackType_normal:
        {
            isClickCloseBtn = NO;
            if ([ZCUICore getUICore].kitInfo.isOpenEvaluation) {
                showEvaluation = YES;
            }
            
        }
            break;
        case ZCChatViewGoBackType_close: {
            isClickCloseBtn = YES;
            
            if ([ZCUICore getUICore].kitInfo.isShowCloseSatisfaction) {
                showEvaluation = YES;
            }
        }
            break;
        default:
            break;
    }
    
    // 隐藏键盘
    [_keyboardTools hideKeyboard];
    
    // 如果用户开起关闭时显示评价的弹框
    if (showEvaluation) {
        
        //  1.是否转接过人工   （人工的评价逻辑）
        //  2.本次会话没有评价过人工
        //  3.没有被拉黑过
        //  4.和人工讲过话
        //  5.仅人工模式，不能评价机器人
        //        [[ZCUICore getUICore] keyboardOnClickSatisfacetion:YES];
        
        if (([self getZCIMConfig].isArtificial || [ZCUICore getUICore].isOffline)
            && ![ZCUICore getUICore].isEvaluationService
            && [ZCUICore getUICore].isSendToUser
            && !([[self getZCIMConfig] isblack]|| [ZCUICore getUICore].isOfflineBeBlack)) {
            // 必须评价
            [self JumpCustomActionSheet:ServerSatisfcationBackType andDoBack:!isClickCloseBtn isInvitation:1 Rating:5 IsResolved:0];
            
        }else if(![ZCUICore getUICore].isEvaluationRobot
                 && [ZCUICore getUICore].isSendToRobot
                 && ![ZCUICore getUICore].isOffline
                 && [self getZCIMConfig].type !=2
                 && ![self getZCIMConfig].isArtificial){
            // 必须评价
            [self JumpCustomActionSheet:RobotSatisfcationBackType andDoBack:!isClickCloseBtn isInvitation:1 Rating:5 IsResolved:0];
        }else{
            if ([self.keyboardTools getKeyBoardViewStatus] == ZCKeyboardStatusNewSession) {
                [[ZCUICore getUICore].listArray removeAllObjects];
            }
            [_listTable reloadData];
            [self goBackIsKeep];
        }
    }
    else{
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.25 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            
            if ([_keyboardTools getKeyBoardViewStatus] == ZCKeyboardStatusNewSession) {
                [[ZCUICore getUICore].listArray removeAllObjects];
                [_listTable reloadData];
            }
        });
        [self goBackIsKeep];
    }
}


-(UITextView *) getChatTextView{
    if(_keyboardTools && _keyboardTools.zc_chatTextView){
        return _keyboardTools.zc_chatTextView;
        
    }
    return nil;
}

#pragma mark -- 添加快捷入口
- (ZCQuickEntryView *)quickEntryViewWithArray:(NSMutableArray *)array{
    if (!_quickEntryView) {
        _quickEntryView = [[ZCQuickEntryView alloc]initCustomViewWith:array WithView:self];
        [self insertSubview:_quickEntryView aboveSubview:_listTable];
        
        _quickEntryView.frame = CGRectMake(0,CGRectGetMaxY(_keyboardTools.zc_bottomView.frame) - CGRectGetHeight(_keyboardTools.zc_bottomView.frame)- 50, viewWidth, 50);
        __weak ZCChatView * safeView = self;
        _quickEntryView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
        _quickEntryView.quickClickBlock = ^(ZCLibCusMenu *itemModel) {
         
            if (itemModel.url.length) {
                [safeView cellItemLinkClick:nil type:ZCChatCellClickTypeOpenURL obj:zcLibConvertToString(itemModel.url)];
            }
        };
    }
//        [ZCUICore getUICore].isDismissRobotPage = NO;
    return  _quickEntryView;
}



-(void)setFrameForListTable{
    
    CGRect f = _listTable.frame;
    int direction = [[ZCToolsCore getToolsCore] getCurScreenDirection];
    CGFloat spaceX = 0;
    CGFloat LW = viewWidth;
    // iphoneX 横屏需要单独处理
    if(direction > 0 && !isiPad){
        LW = viewWidth -  XBottomBarHeight;
    }
    if(direction == 2 && !isiPad){
        spaceX = XBottomBarHeight;
    }
    f.origin.x = spaceX;
    // 还原默认的坐标,和默认高度
    f.origin.y = navHeight;
    f.size.height = viewHeight - navHeight - _keyboardTools.zc_bottomView.frame.size.height;
    f.size.width = LW;
    
    
    // 1、如果顶部显示通告，Y 坐标+40，并且高度减少40
    if ([[ZCUICore getUICore] getLibConfig].announceMsgFlag == 1 && [[ZCUICore getUICore] getLibConfig].announceTopFlag == 1) {
        f.origin.y = f.origin.y + 36;
        f.size.height = f.size.height - 36;
        
        if(_notifitionTopView){
            _notifitionTopView.frame = CGRectMake(0, navHeight, viewWidth, 36);
        }
        
    }
    
    // 2、判断底部标签 （快捷回复单独处理）
    if (_quickEntryView != nil && ([self getZCIMConfig].quickEntryFlag == 1 || [ZCUICore getUICore].kitInfo.cusMenuArray.count>0) && [_keyboardTools getKeyBoardViewStatus]!=ZCKeyboardStatusNewSession) {
        _quickEntryView.hidden = NO;
        _quickEntryView.frame = CGRectMake(0,CGRectGetMaxY(_keyboardTools.zc_bottomView.frame) - CGRectGetHeight(_keyboardTools.zc_bottomView.frame)- 50, viewWidth, 50);
        
        f.size.height = f.size.height - 50;
    }else{
        _quickEntryView.hidden = YES;
    }
    
    navTableY = f.origin.y;
    [_listTable setFrame:f];
    [_keyboardTools setTableStartY:navTableY];

}
#pragma mark -- 滚动到最底部
-(void)keyboardscrollTableToBottom{
    [ZCLogUtils logHeader:LogHeader debug:@"滚动到底部"];
    CGFloat ch=_listTable.contentSize.height;
    CGFloat h=_listTable.bounds.size.height;

    if(ch > h){

        CGRect tf = _listTable.frame;

        CGFloat defaultHeight = BottomHeight;
        if([_keyboardTools getKeyBoardViewStatus] == ZCKeyboardStatusNewSession){
            defaultHeight = ZCConnectBottomHeight;
        }

        if([_keyboardTools getKeyboardHeight] == 0){
            tf.origin.y   = navTableY - [_keyboardTools getKeyboardHeight] - (_keyboardTools.zc_bottomView.frame.size.height - defaultHeight);
        }else{
            tf.origin.y   = navTableY - [_keyboardTools getKeyboardHeight] - (_keyboardTools.zc_bottomView.frame.size.height - defaultHeight) + XBottomBarHeight;
        }
        if(!CGRectEqualToRect(tf,_listTable.frame)){
            _listTable.frame  = tf;
        }
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.25 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [_listTable setContentOffset:CGPointMake(0, ch-h) animated:NO];
        });
    }else{
        CGRect tf = _listTable.frame;
        if((h - ch) > ([_keyboardTools getKeyboardHeight] + (_keyboardTools.zc_bottomView.frame.size.height-BottomHeight))){
            tf.origin.y   = navTableY;
        }else{
            tf.origin.y   = navTableY - [_keyboardTools getKeyboardHeight] - (_keyboardTools.zc_bottomView.frame.size.height-BottomHeight) + XBottomBarHeight + (h - ch);
        }
        if(!CGRectEqualToRect(tf,_listTable.frame)){
            _listTable.frame  = tf;
        }

        [_listTable setContentOffset:CGPointMake(0, 0) animated:NO];
    }
}



-(UIButton *)changeRobotBtn{
    if (!_changeRobotBtn) {
        _changeRobotBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _changeRobotBtn.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
//        _changeRobotBtn.type = 3;
        [_changeRobotBtn setFrame:CGRectMake(viewWidth - 72 , CGRectGetMaxY(_keyboardTools.zc_bottomView.frame) - CGRectGetHeight(_keyboardTools.zc_bottomView.frame) - 86 - 20 , 70, 80)];
//        _changeRobotBtn.backgroundColor = [UIColor redColor];
        
        
        
        _changeRobotBtn_btn1 = [[UIButton alloc]init];
        [_changeRobotBtn_btn1 setImage:[ZCUITools zcuiGetBundleImage:@"zcicon_changerobot"] forState:UIControlStateNormal];
        [_changeRobotBtn_btn1 addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
        _changeRobotBtn_btn1.tag = BUTTON_TURNROBOT;
        [_changeRobotBtn addSubview:_changeRobotBtn_btn1];
        
        UIButton *button_2 = [[UIButton alloc]init];
        button_2.backgroundColor = UIColorFromThemeColor(ZCBgSystemWhiteLightDarkColor);
        button_2.layer.cornerRadius = 8.0f;
        button_2.layer.shadowOpacity= 1;
        button_2.layer.shadowColor = UIColorFromThemeColorAlpha(ZCTextMainColor, 0.15).CGColor;
        button_2.layer.shadowOffset = CGSizeZero;//投影偏移
        button_2.layer.shadowRadius = 4;
        
        [button_2 addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
        button_2.tag = BUTTON_TURNROBOT;
        
        NSString *titleStr = [ZCUICore getUICore].kitInfo.changeBusinessStr.length > 0?[ZCUICore getUICore].kitInfo.changeBusinessStr:ZCSTLocalString(@"换业务");
        
        [button_2 setTitle:titleStr forState:UIControlStateNormal];
        [button_2.titleLabel setFont:ZCUIFontBold10];
        
        [button_2 setTitleColor:[ZCUITools zcgetRightChatColor] forState:UIControlStateNormal];
        [_changeRobotBtn addSubview:button_2];
        
        CGSize s = [titleStr sizeWithAttributes:@{NSFontAttributeName:ZCUIFontBold10}];
       if(s.width > 72){
           [_changeRobotBtn setFrame:CGRectMake(viewWidth - s.width -5, CGRectGetMaxY(_keyboardTools.zc_bottomView.frame) - CGRectGetHeight(_keyboardTools.zc_bottomView.frame) - 80 - 20 , s.width , 80)];
           _changeRobotBtn_btn1.frame = CGRectMake(0, (s.width - 60)/2, 60, 60);
           button_2.frame = CGRectMake(0, 60, s.width, 16);
       }else{
           s.width = 72-5;
           _changeRobotBtn_btn1.frame = CGRectMake((s.width - 60)/2, 0, 60, 60);
           button_2.frame = CGRectMake(0, 54, s.width, 16);
       }

        _changeRobotBtn.tag = BUTTON_TURNROBOT;
        [_changeRobotBtn addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_changeRobotBtn];
        _changeRobotBtn.hidden = YES;
    }
    return  _changeRobotBtn;
}

-(UIButton *)goUnReadButton{
    if(!_goUnReadButton){
        _goUnReadButton=[UIButton buttonWithType:UIButtonTypeCustom];
        CGFloat btnY = 40;
        if (_superController.navigationController.navigationBarHidden) {
            btnY = NavBarHeight + 40;
        }
        [_goUnReadButton setFrame:CGRectMake(viewWidth - 120, btnY, 140, 40)];
        [_goUnReadButton setImage:[ZCUITools zcuiGetBundleImage:@"zcicon_newmessages"] forState:UIControlStateNormal];
        [_goUnReadButton setImage:[ZCUITools zcuiGetBundleImage:@"zcicon_newmessages"] forState:UIControlStateHighlighted];
        
        [_goUnReadButton.imageView setContentMode:UIViewContentModeScaleAspectFit];
        [_goUnReadButton setTitleColor:UIColorFromThemeColor(ZCThemeColor) forState:UIControlStateNormal];
        [_goUnReadButton.titleLabel setFont:[ZCUITools zcgetListKitDetailFont]];
        [_goUnReadButton setContentEdgeInsets:UIEdgeInsetsMake(0, 10, 0, 0)];
        [_goUnReadButton setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
        _goUnReadButton.layer.cornerRadius = 20;
        _goUnReadButton.layer.borderWidth = 0.75f;
        _goUnReadButton.layer.borderColor = UIColorFromThemeColor(ZCThemeColor).CGColor;
        _goUnReadButton.layer.masksToBounds = YES;
        [_goUnReadButton setBackgroundColor:[ZCUITools zcgetBgBannerColor]];
        _goUnReadButton.tag = BUTTON_UNREAD;
        [_goUnReadButton addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_goUnReadButton];
        _goUnReadButton.hidden=YES;
    }
    return _goUnReadButton;
}



// 监听暗黑模式变化
-(void)traitCollectionDidChange:(UITraitCollection *)previousTraitCollection{
    [super traitCollectionDidChange:previousTraitCollection];
    if(zcGetSystemDoubleVersion()>=13){
        // trait发生了改变
        if ([self.traitCollection hasDifferentColorAppearanceComparedToTraitCollection:previousTraitCollection]) {
            // 执行操作
            if(_goUnReadButton){
                [_goUnReadButton setImage:[ZCUITools zcuiGetBundleImage:@"zcicon_newmessages"] forState:UIControlStateNormal];
                [_goUnReadButton setImage:[ZCUITools zcuiGetBundleImage:@"zcicon_newmessages"] forState:UIControlStateHighlighted];
            }
            if(_changeRobotBtn_btn1){
               [_changeRobotBtn_btn1 setImage:[ZCUITools zcuiGetBundleImage:@"zcicon_changerobot"] forState:UIControlStateNormal];
            }
            
            if(self.backButton){
                [self.backButton setImage:[ZCUITools zcuiGetBundleImage:@"zcicon_titlebar_back_normal"] forState:UIControlStateNormal];
                [self.backButton setImage:[ZCUITools zcuiGetBundleImage:@"zcicon_titlebar_back_normal"] forState:UIControlStateHighlighted];

                [self.moreButton setImage:[ZCUITools zcuiGetBundleImage:@"zcicon_btnmore"] forState:UIControlStateNormal];
                [self.moreButton setImage:[ZCUITools zcuiGetBundleImage:@"zcicon_btnmore_press"] forState:UIControlStateHighlighted];
                if (zcLibConvertToString([ZCUICore getUICore].kitInfo.moreBtnNolImg).length >0) {
                    [self.moreButton setImage:[ZCUITools zcuiGetBundleImage:zcLibConvertToString([ZCUICore getUICore].kitInfo.moreBtnNolImg)]  forState:UIControlStateNormal];
                }
                if (zcLibConvertToString([ZCUICore getUICore].kitInfo.moreBtnSelImg).length >0) {
                    [self.moreButton setImage:[ZCUITools zcuiGetBundleImage:zcLibConvertToString([ZCUICore getUICore].kitInfo.moreBtnSelImg)]  forState:UIControlStateHighlighted];
                }
            }
            
            [_keyboardTools reloadImages];
            
        }
    }
}


-(void)layoutSubviews{
    [super layoutSubviews];
    
    BOOL isChange = NO;
    
    
    if (viewWidth != self.frame.size.width || viewHeight != self.frame.size.height || isChange){
        // 横竖屏切换的时候，需要隐藏，高度不一样，无法直接切换
        if(_sheet){
            [_sheet tappedCancel];
        }
        
        if(xhObj){
            [xhObj dismissWithAnimate:0];
            xhObj = nil;
        }
        
        viewWidth  = self.frame.size.width;
        viewHeight = self.frame.size.height;
        
        [self setFrameForListTable];
        
        // 重新设置表情键盘的高度
        [_keyboardTools hideKeyboard];
        _keyboardTools.zc_sourceView = self;
        
        [_listTable reloadData];

        if(self.topView!=nil){
            if([[ZCToolsCore getToolsCore] getCurScreenDirection] > 0 && !isiPad){
                if(!self.backButton.hidden){
                    CGRect bf = self.backButton.frame;
                    bf.origin.x = 10;
                    self.backButton.frame = bf;
                }
            }else{
                if(!self.backButton.hidden){
                    CGRect bf = self.backButton.frame;
                    bf.origin.x = 0;
                    self.backButton.frame = bf;
                }
            }
        }
        
        

        if(_topView){
            navHeight = NavBarHeight;
            if(!_hideTopViewNav){
                _topView.hidden = YES;
                navHeight = 0;
            }
            // 添加头部信息
            [_topView setFrame:CGRectMake(0, 0, viewWidth, navHeight)];
            
            if([self getZCIMConfig].isArtificial){
                self.closeButton.hidden = NO;
            }else {
                self.closeButton.hidden = YES;
            }
        }
        if (self.sheet !=nil) {
            self.sheet.frame = CGRectMake(0, 0, viewWidth, viewHeight);
        }
        
        [self setTitleViewRTL];
    }
    int direction = [[ZCToolsCore getToolsCore] getCurScreenDirection];
    CGFloat spaceX = 0;
    if(direction == 2 && !isiPad){
        spaceX = XBottomBarHeight;
    }
    CGRect f = _keyboardTools.zc_bottomView.frame;
    f.origin.x = spaceX;
    f.size.width = viewWidth - ((direction>0 && !isiPad)?XBottomBarHeight:0);
    _keyboardTools.zc_bottomView.frame = f;
}


- (void)didChangeRotate:(NSNotification*)notice {
    BOOL isShow = NO;
    // 旋转时，隐藏技能组
    if([[ZCUICore getUICore] getSkillView]!=nil){
        isShow = YES;
        [[ZCUICore getUICore] dismissSkillSetView];
    }
    
    if(isShow){
         [[ZCUICore getUICore] checkUserServiceWithObject:nil Msg:nil];
    }
    if ([[UIDevice currentDevice] orientation] == UIInterfaceOrientationPortrait
        || [[UIDevice currentDevice] orientation] == UIInterfaceOrientationPortraitUpsideDown) {
        //竖屏
    } else {
        //横屏
    }
}


-(void)setTitleViewRTL{
    if(isRTLLayout()){
        if(self.topView != nil){

            [self.backButton setFrame:CGRectMake(0, NavBarHeight-44, 64, 44)];
            [self.backButton setContentHorizontalAlignment:UIControlContentHorizontalAlignmentRight];
            [self.moreButton setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
    
            [[ZCToolsCore getToolsCore] setRTLFrame:self.moreButton];
            if(self.closeButton){
                [[ZCToolsCore getToolsCore] setRTLFrame:self.closeButton];
            }
            if(self.evaluationBtn){
                [[ZCToolsCore getToolsCore] setRTLFrame:self.evaluationBtn];
            }
            if(self.telBtn){
                [[ZCToolsCore getToolsCore] setRTLFrame:self.telBtn];
            }
            [[ZCToolsCore getToolsCore] setRTLFrame:self.backButton];
        }
    }
}


// 页面点击事件
-(IBAction)buttonClick:(UIButton *) sender{
    
    if (self.superController.navigationController.navigationBarHidden) {
        if(sender.tag == BUTTON_MORE){
            [_keyboardTools hideKeyboard];
            ZCActionSheet *mysheet = [[ZCActionSheet alloc] initWithDelegate:self selectedColor:UIColorFromRGB(TextCleanMessageColor) CancelTitle:ZCSTLocalString(@"取消") OtherTitles:ZCSTLocalString(@"清空聊天记录"), nil];
            mysheet.selectIndex = 1;
            [mysheet show];
            
        }
        if (sender.tag == BUTTON_BACK) {
            if(isViewDidBack){
                return;
            }
            // 返回提醒开关
            if ([ZCUICore getUICore].kitInfo.isShowReturnTips) {
               [[ZCToolsCore getToolsCore] showAlert:ZCSTLocalString(@"您是否要结束会话?") message:nil cancelTitle:ZCSTLocalString(@"暂时离开") titleArray:@[ZCSTLocalString(@"结束会话")] viewController:_superController 
                                             confirm:^(NSInteger buttonTag) {
                   if(buttonTag >= 0){
                       // 点击关闭，离线用户
                       [self confimGoBackWithType:ZCChatViewGoBackType_close];
                   }else{
//                       isClickCloseBtn = false;
                       [self setIsCloseNo];
                       [self goBackIsKeep];
                   }
               }];
                return;
            }
            [self confimGoBackWithType:ZCChatViewGoBackType_normal];
        }
        
        if(sender.tag == BUTTON_CLOSE){
            [self confimGoBackWithType:ZCChatViewGoBackType_close];
        }
        
        if (sender.tag == BUTTON_EVALUATION) {
            [[ZCUICore getUICore] keyboardOnClickSatisfacetion:NO];
        }
        
        if (sender.tag == BUTTON_TEL) {
            if([ZCUICore getUICore].ZCViewControllerCloseBlock != nil){
                [ZCUICore getUICore].ZCViewControllerCloseBlock(self,ZC_PhoneCustomerService);
            }
            
            NSString *phoneNumber = [NSString stringWithFormat:@"tel:%@",zcLibConvertToString([ZCUICore getUICore].kitInfo.customTel)];
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:phoneNumber]];

        }
        
        
    }
    
    // 未读消息数
    if(sender.tag == BUTTON_UNREAD){
        self.goUnReadButton.hidden = YES;
        int unNum = [[ZCIMChat getZCIMChat] getUnReadNum];
        if(unNum<=[ZCUICore getUICore].chatMessages.count){
            CGRect  popoverRect = [_listTable rectForRowAtIndexPath:[NSIndexPath indexPathForRow:([ZCUICore getUICore].chatMessages.count - unNum) inSection:0]];
            [_listTable setContentOffset:CGPointMake(0,popoverRect.origin.y-40) animated:NO];
        }
        
    }
    
    // 切换机器人
    if (sender.tag == BUTTON_TURNROBOT) {
        sender.enabled = NO;
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            sender.enabled = YES;
        });
        
        [_keyboardTools hideKeyboard];
        if (![ZCUICore getUICore].isDismissRobotPage) {
            return;
        }
         __weak  ZCChatView * safeView = self;
        [[ZCLibServer getLibServer] getrobotlist:[self getPlatformInfo].config start:^{
            
        } success:^(NSDictionary *dict, ZCMessageSendCode sendCode) {
            
             @try{
                 NSMutableArray * listaArr = [NSMutableArray arrayWithCapacity:0];
                 NSArray * arr = dict[@"data"][@"list"];
                 if (arr.count == 0) {
                     return ;
                 }
                for (NSDictionary * Dic in arr) {
                    ZCLibRobotSet * model = [[ZCLibRobotSet alloc]initWithMyDict:Dic];
                    [listaArr addObject:model];
                }
                 
                 // 已经存在，不重复创建
                 if(safeView.changeRobotView!=nil){
                     return;
                 }
                 
                safeView.changeRobotView = [[ZCTurnRobotView alloc]initActionSheet:listaArr WithView:self RobotId:[safeView getPlatformInfo].config.robotFlag];
         
                [safeView.changeRobotView showInView:self];
                 [ZCUICore getUICore].isDismissRobotPage = NO;
               
                safeView.changeRobotView.robotSetClickBlock = ^(ZCLibRobotSet *itemModel) {
                    safeView.changeRobotView = nil;
                    if (itemModel == nil) {
                        [ZCUICore getUICore].isDismissRobotPage = YES;
                        return ;
                    }
                    if ([itemModel.robotFlag intValue] == [safeView getZCIMConfig].robotFlag) {
                        return ;
                    }else{
                        
                        [safeView getPlatformInfo].config.robotFlag = [itemModel.robotFlag intValue];
                        [safeView getZCIMConfig].robotName = itemModel.robotName;
                        [safeView getZCIMConfig].robotLogo = itemModel.robotLog;
                        [safeView getZCIMConfig].robotFlag = [itemModel.robotFlag intValue];
                        
                        [self getPlatformInfo].config.robotName = itemModel.robotName;
                        // 自定义喜欢有有，不设置
                        if(zcLibConvertToString([ZCLibClient getZCLibClient].libInitInfo.robot_hello_word).length == 0){
                            // 切换机器人，切换每个机器人的欢迎语
                            [self getPlatformInfo].config.robotHelloWord = itemModel.robotHelloWord;
                        }
                        if(itemModel.guideFlag){
                            [self getPlatformInfo].config.guideFlag = 1;
                        }else{
                            [self getPlatformInfo].config.guideFlag = 0;
                        }
                        
                        [[ZCUICore getUICore] changeRobotBtnClickAddRobotHelloWolrd];
                    
                        [ZCUICore getUICore].isSendToRobot = NO;
                        
                        // 2.8.0 切换机器人，不重复评价
//                        [ZCUICore getUICore].isEvaluationRobot = NO;
                        
                    }
                    
                };
            } @catch (NSException *exception) {
                
            } @finally {
                
            }
        } fail:^(NSString *errorMsg, ZCMessageSendCode errorCode) {
            NSLog(@"%@",errorMsg);
        }];
        
        
    }
}

#pragma mark -- 点击评价
-(void)JumpCustomActionSheet:(int) sheetType andDoBack:(BOOL) isBack isInvitation:(int) invitationType Rating:(int)rating IsResolved:(int)isResolve{
    [_keyboardTools hideKeyboard];
    if(_sheet){
        [_sheet tappedCancel];
    }
    _sheet = [[ZCUICustomActionSheet alloc] initActionSheet:sheetType Name:[ZCUICore getUICore].receivedName Cofig:[self getZCIMConfig] cView:self IsBack:isBack isInvitation:invitationType WithUid:[self getZCIMConfig].uid IsCloseAfterEvaluation:[ZCUICore getUICore].kitInfo.isCloseAfterEvaluation Rating:rating IsResolved:isResolve IsAddServerSatifaction:[ZCUICore getUICore].isAddServerSatifaction];
    _sheet.delegate=self;
    [_sheet showInView:self];
    [ZCUICore getUICore].isDismissSheetPage = NO;
}

// 评价完成
-(void)commentSusccess:(ZCLibMessage *)model{
    [self actionSheetClick:6];
    isCompleteSatisfaction = YES;
    
}

- (void)thankFeedBack:(int)type rating:(float)rating IsResolve:(int)isresolve{
    [[ZCUICore getUICore] thankFeedBack:type rating:rating IsResolve:isresolve];
    // 邀请评价 1-4星 点击提交后  判断是否开启 评价完人工结束会话
    [[ZCUICore getUICore] thankFeedBack];
    
}

-(void)dimissCustomActionSheetPage{
    _sheet = nil;
    
    //  在isShowReturnTips 为true 切点击了暂时离开，否则下次无法评价
    isClickCloseBtn = false;
    [ZCUICore getUICore].isDismissSheetPage = YES;
    
    
    [_keyboardTools removeKeyboardObserver];
    [_keyboardTools handleKeyboard];
}


-(void)actionSheetClick:(int)isCommentType{
    if (isCommentType != 4) {
        // 此处使用window rootView,解决提前返回导致的如法显示，特殊情况可能需要延迟1秒展示，因为当前页面会提前释放
        [[ZCUIToastTools shareToast] showToast:ZCSTLocalString(@"感谢您的评价！") duration:1.5f view:[[ZCToolsCore getToolsCore] getCurWindow].rootViewController.view position:ZCToastPositionCenter Image:[ZCUITools zcuiGetBundleImage:@"zcicon_successful"]];
    }
    
    if(isCommentType == 1){
          // 评价完成后 结束会话
        [[ZCUICore getUICore] thankFeedBack];

//       [[ZCLibServer getLibServer] logOut:[[ZCPlatformTools sharedInstance] getPlatformInfo].config];
//        [[ZCLibClient getZCLibClient] closeIMConnection];
//        [ZCUICore getUICore].isSayHello = NO;
//        [ZCUICore getUICore].isShowRobotHello = NO;
//        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//            [self goBackIsKeep];
//        });
    }else if(isCommentType == 0){
        if ([self.keyboardTools getKeyBoardViewStatus] == ZCKeyboardStatusNewSession) {
            [[ZCUICore getUICore].listArray removeAllObjects];
            [_listTable reloadData];
        }
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self goBackIsKeep];
        });
    
    }else if (isCommentType == 3){
        [[ZCUICore getUICore] thankFeedBack];
    }else if(isCommentType == 4){
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.25 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self goBackIsKeep];
        });
    }else if (isCommentType == 5){
        // 评价完成后 结束会话
        [[ZCUICore getUICore] thankFeedBack];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self goBackIsKeep];
        });
        
    }else{
        // 关闭了评价页面
    }
    
}


- (void)cellItemClick:(int)satifactionType IsResolved:(int)isResolved Rating:(int)rating problem:(NSString *) problem scoreFlag:(int)scoreFlag{
    if (satifactionType == 1) {
        // 弹评价页面
        
//        [[ZCUICore getUICore] CustomActionSheet:ServerSatisfcationInviteType andDoBack:NO isInvitation:0 Rating:rating IsResolved:isResolved];
        [self JumpCustomActionSheet:ServerSatisfcationInviteType andDoBack:NO isInvitation:0 Rating:rating IsResolved:isResolved];
        
    }else{
        // 提交评价,10分实际是11
        if(scoreFlag == 1){
            rating = rating - 1;
            if(rating < 0){
                rating = 0;
            }
        }
        [[ZCUICore getUICore] commitSatisfactionWithIsResolved:isResolved Rating:rating problem:problem scoreFlag:scoreFlag];
    }
}



#pragma mark 音频播放设置
-(void)voicePlayStatusChange:(ZCVoicePlayStatus)status{
    switch (status) {
        case ZCVoicePlayStatusReStart:
            if([ZCUICore getUICore].animateView){
                [[ZCUICore getUICore].animateView startAnimating];
            }
            break;
        case ZCVoicePlayStatusPause:
            if([ZCUICore getUICore].animateView){
                [[ZCUICore getUICore].animateView stopAnimating];
                
            }
            break;
        case ZCVoicePlayStatusStartError:
            if([ZCUICore getUICore].animateView){
                [[ZCUICore getUICore].animateView stopAnimating];
            }
            break;
        case ZCVoicePlayStatusFinish:
        case ZCVoicePlayStatusError:
            if([ZCUICore getUICore].animateView){
                [[ZCUICore getUICore].animateView stopAnimating];
                [ZCUICore getUICore].animateView=nil;
                
                [ZCUICore getUICore].playModel.isPlaying=NO;
                [ZCUICore getUICore].playModel=nil;
            }
            break;
        default:
            break;
    }
}

-(void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    [_keyboardTools hideKeyboard];
    // 隐藏复制小气泡
    [[NSNotificationCenter defaultCenter] postNotificationName:UIMenuControllerDidHideMenuNotification object:nil];
}

#pragma mark 网络链接改变时会调用的方法
-(void)netWorkChanged:(NSNotification *)note
{
    BOOL isReachable = _netWorkTools.isZCReachable;
    if(!isReachable){
        self.newWorkStatusButton.hidden=NO;
        [_listTable setContentInset:UIEdgeInsetsMake(40, 0, 0, 0)];
        
        if([self getZCIMConfig]==nil){
            [[ZCUILoading shareZCUILoading] showAddToSuperView:self];
        }
//        [self insertSubview:_newWorkStatusButton aboveSubview:_notifitionTopView];
        [self bringSubviewToFront:_newWorkStatusButton];
    }else{
        self.newWorkStatusButton.hidden=YES;
        [_listTable setContentInset:UIEdgeInsetsMake(0, 0, 0, 0)];
        
        // 初始化数据
        if([self getZCIMConfig]==nil && [@"" isEqual:zcLibConvertToString([self getZCIMConfig].cid)] && ![ZCUICore getUICore].isInitLoading){
            [[ZCUICore getUICore] initConfigData:YES IsNewChat:NO];
        }
    }
}


// 长连接通道发生变化时显示连接状态
-(void)showSoketConentStatus:(ZCConnectStatusCode)status{
    // 连接中
    if(status == ZC_CONNECT_START){
        UIButton *btn = [self socketStatusButton];
        [btn setTitle:[NSString stringWithFormat:@"  %@",ZCSTLocalString(@"收取中...")] forState:UIControlStateNormal];
        UIActivityIndicatorView *activityView  = [btn viewWithTag:1];
        btn.hidden = NO;
        activityView.hidden = NO;
        [activityView startAnimating];
        
        isStartConnectSockt = YES;
        // 机器人时，不显示
        if(![self getZCIMConfig].isArtificial){
            btn.hidden = YES;
        }
        
    }else{
        isStartConnectSockt = NO;
        
        UIButton *btn = [self socketStatusButton];
        UIActivityIndicatorView *activityView  = [btn viewWithTag:1];
        [activityView stopAnimating];
        activityView.hidden = YES;
        
        if(status == ZC_CONNECT_SUCCESS){
            btn.hidden = YES;
        }else{
            if([self getZCIMConfig].isArtificial){
                btn.hidden = NO;
                [self bringSubviewToFront:btn];
                [btn setTitle:[NSString stringWithFormat:@"%@",ZCSTLocalString(@"未连接")] forState:UIControlStateNormal];
            }else{
                btn.hidden = YES;
            }
        }
    }
}

// 接收链接改变
-(void)onConnectStatusChanged:(ZCConnectStatusCode)status{
    
    if(status == ZC_CONNECT_KICKED_OFFLINE_BY_OTHER_CLIENT){
        if(self.superController.navigationController){
            [[ZCUIToastTools shareToast] showToast:ZCSTLocalString(@"您打开了新窗口，本次会话结束") duration:1.0f view:self.window.rootViewController.view position:ZCToastPositionCenter];
        }else{
            [[ZCUIToastTools shareToast] showToast:ZCSTLocalString(@"您打开了新窗口，本次会话结束") duration:1.0f view:self position:ZCToastPositionCenter];
        }
    }else{
        [self showSoketConentStatus:status];
    }
}

-(void)backChatView{
    
    [ZCLibClient getZCLibClient].isShowTurnBtn = NO;
    [ZCUICore getUICore].unknownWordsCount = 0;
    
    // 判断是否保存会话id，以判断是否重新初始化
    // 没有说过话，下次进入时判断是否需要重新初始化，如果当前时间-time,大于out_time就重新初始化
    if(![ZCUICore getUICore].isSendToUser && ![ZCUICore getUICore].isSendToRobot){
        NSDictionary *lastChat = @{@"cid":zcLibConvertToString([self getZCIMConfig].cid),
                                   @"time":zcLibDateTransformString(FormateTime,[NSDate new]),
                                   @"out_time":[NSString stringWithFormat:@"%d",[self getZCIMConfig].userOutTime]
        };
        [ZCStoreConfiguration setZCParamter:KEY_ZCLASTCHAT value:lastChat];
    }
    
    if (_keyboardTools) {
        [_keyboardTools removeKeyboardObserver];
        _keyboardTools = nil;
    }
    if (_voiceTools) {
        [_voiceTools stopVoice];
        _voiceTools.delegate = nil;
        _voiceTools = nil;
    }
    
    if (_netWorkTools) {
        [_netWorkTools removeNetworkObserver];
        _netWorkTools = nil;
    }
    
    if ([ZCUICore getUICore].lineModel) {
        [[ZCUICore getUICore].listArray removeObject:[ZCUICore getUICore].lineModel];
    }
    
    @try{
        if([ZCUICore getUICore].listArray && [ZCUICore getUICore].listArray.count>0){
            ZCLibMessage *lastMsg = [[ZCUICore getUICore].listArray lastObject];
            if(lastMsg.tipStyle>0){
                [[ZCPlatformTools sharedInstance] getPlatformInfo].lastMsg = lastMsg.sysTips;
                [[ZCPlatformTools sharedInstance] getPlatformInfo].lastDate = lastMsg.ts;
            } else {
                [[ZCPlatformTools sharedInstance] getPlatformInfo].lastMsg = [lastMsg getLastMessage];
                [[ZCPlatformTools sharedInstance] getPlatformInfo].lastDate = lastMsg.ts;
            }
        }
        [[ZCUICore getUICore] clearData];
        // 如果设置NO，每次返回都会从新添加
//        [ZCUICore getUICore].isAddNotice = NO;
        
        [self saveDataToLocal];
        
        [[ZCPlatformTools sharedInstance] savePlatformInfo:[self getPlatformInfo]];
        
        [ZCUICore getUICore].cids = nil;
        [ZCUICore getUICore].listArray = nil;
        
        [[ZCIMChat getZCIMChat] setChatPageState:ZCChatPageStateBack];
        
        if([ZCUICore getUICore].PageLoadBlock){
            [ZCUICore getUICore].PageLoadBlock(self,ZCPageBlockGoBack);
        }
        
        // 离线用户，关闭通道
        if ([ZCUICore getUICore].kitInfo.isShowCloseSatisfaction) {
            //  如果打开 关闭弹出评价开关，需要判断是否已经评价，如果没有评价，则不关闭会话
            if (isClickCloseBtn) {
                [ZCLibClient closeAndoutZCServer:YES];
            }
            else{
                if (isCompleteSatisfaction) {
                    [ZCLibClient closeAndoutZCServer:YES];
                }
            }
        }
        else{
            if(isClickCloseBtn){
            [ZCLibClient closeAndoutZCServer:YES];
            }
        }

    } @catch (NSException *exception) {
        
    } @finally {
        
    }
}

-(void)goBackIsKeep{
    // 如果有返回的回调，不要直接调用，否则会在页面还没有返回时，清理数据
    if (self.delegate && [self.delegate respondsToSelector:@selector(topViewBtnClick:)]) {
        isViewDidBack = YES;
        [self.delegate topViewBtnClick:BUTTON_BACK];
    }else{
        [self backChatView];
    }
}


-(void)createTitleView{
    self.topView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, NavBarHeight)];
    [self.topView setBackgroundColor:[ZCUITools zcgetBgBannerColor]];
    [_topView setAutoresizingMask:UIViewAutoresizingFlexibleLeftMargin|
     UIViewAutoresizingFlexibleBottomMargin|
     UIViewAutoresizingFlexibleRightMargin|
     UIViewAutoresizingFlexibleWidth];
    [_topView setAutoresizesSubviews:YES];
    [self addSubview:self.topView];
    
    self.zcTitleView = [[ZCTitleView alloc] initWithFrame:CGRectMake(80, NavBarHeight-44, self.frame.size.width- 80*2, 44)];
    [self.zcTitleView setAutoresizingMask:UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleTopMargin];
    [self.zcTitleView setAutoresizesSubviews:YES];
    [self.topView addSubview:self.zcTitleView];
    
    UIView *lineView = [[UIView alloc]initWithFrame:CGRectMake(0, NavBarHeight - 1, self.frame.size.width, 0.5)];
    lineView.backgroundColor = UIColorFromThemeColor(ZCBgLineColor);
    [lineView setAutoresizingMask:UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleTopMargin];
    [self.topView addSubview:lineView];
    
    self.backButton=[UIButton buttonWithType:UIButtonTypeCustom];
    [self.backButton setFrame:CGRectMake(0, NavBarHeight-44, 64, 44)];
    [self.backButton.imageView setContentMode:UIViewContentModeScaleAspectFit];
    [self.backButton setAutoresizingMask:UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleTopMargin];
    [self.backButton setImage:[ZCUITools zcuiGetBundleImage:@"zcicon_titlebar_back_normal"] forState:UIControlStateNormal];
    [self.backButton setImage:[ZCUITools zcuiGetBundleImage:@"zcicon_titlebar_back_normal"] forState:UIControlStateHighlighted];
    
    if (zcLibConvertToString([ZCUICore getUICore].kitInfo.topBackNolImg).length >0) {
        [self.backButton setImage:[ZCUITools zcuiGetBundleImage:zcLibConvertToString([ZCUICore getUICore].kitInfo.topBackNolImg)] forState:UIControlStateNormal];
    }
    if (zcLibConvertToString([ZCUICore getUICore].kitInfo.topBackSelImg).length >0) {
        [self.backButton setImage:[ZCUITools zcuiGetBundleImage:zcLibConvertToString([ZCUICore getUICore].kitInfo.topBackSelImg)] forState:UIControlStateHighlighted];
    }
    
    [self.backButton setBackgroundColor:[UIColor clearColor]];
    if ([ZCUICore getUICore].kitInfo.topBackNolColor != nil ) {
        [self.backButton setBackgroundImage:[ZCUIImageTools zcimageWithColor: [ZCUICore getUICore].kitInfo.topBackNolColor]  forState:UIControlStateNormal];
    }
    if ([ZCUICore getUICore].kitInfo.topBackSelColor != nil) {
        [self.backButton setBackgroundImage:[ZCUIImageTools zcimageWithColor:[ZCUICore getUICore].kitInfo.topBackSelColor] forState:UIControlStateHighlighted];
    }
    [self.backButton setImageEdgeInsets:UIEdgeInsetsMake(0, 10, 0, 0)];
    [self.backButton setContentEdgeInsets:UIEdgeInsetsZero];
    [self.backButton setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
    [self.backButton setAutoresizesSubviews:YES];
    [self.backButton setTitle:ZCSTLocalString(@"") forState:UIControlStateNormal];
    if ([ZCUICore getUICore].kitInfo.topBackTitle != nil) {
      [self.backButton setTitle:[ZCUICore getUICore].kitInfo.topBackTitle forState:UIControlStateNormal];
    }
    
    [self.backButton setTitleEdgeInsets:UIEdgeInsetsMake(0, 15, 0, 0)];
    [self.backButton.titleLabel setFont:[ZCUITools zcgetListKitTitleFont]];
    [self.backButton setTitleColor:[ZCUITools zcgetTopViewTextColor] forState:UIControlStateNormal];
    [self.topView addSubview:self.backButton];
    self.backButton.tag = BUTTON_BACK;
    [self.backButton addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
    
   
   
    
    self.moreButton=[UIButton buttonWithType:UIButtonTypeCustom];
    [self.moreButton setFrame:CGRectMake(self.frame.size.width-44, NavBarHeight-44, 44, 44)];
    [self.moreButton.imageView setContentMode:UIViewContentModeScaleAspectFit];
    [self.moreButton setContentEdgeInsets:UIEdgeInsetsZero];
    [self.moreButton setContentHorizontalAlignment:UIControlContentHorizontalAlignmentRight];
    [self.moreButton setAutoresizesSubviews:YES];
    [self.moreButton setAutoresizingMask:UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleTopMargin];
    [self.moreButton setImageEdgeInsets:UIEdgeInsetsMake(0, 0, 0, 15)];
    [self.moreButton setImage:[ZCUITools zcuiGetBundleImage:@"zcicon_btnmore"] forState:UIControlStateNormal];
    [self.moreButton setImage:[ZCUITools zcuiGetBundleImage:@"zcicon_btnmore_press"] forState:UIControlStateHighlighted];
    if (zcLibConvertToString([ZCUICore getUICore].kitInfo.moreBtnNolImg).length >0) {
        [self.moreButton setImage:[ZCUITools zcuiGetBundleImage:zcLibConvertToString([ZCUICore getUICore].kitInfo.moreBtnNolImg)]  forState:UIControlStateNormal];
    }
    if (zcLibConvertToString([ZCUICore getUICore].kitInfo.moreBtnSelImg).length >0) {
        [self.moreButton setImage:[ZCUITools zcuiGetBundleImage:zcLibConvertToString([ZCUICore getUICore].kitInfo.moreBtnSelImg)]  forState:UIControlStateHighlighted];
    }
    CGFloat btnItemWidth = 0;
    if(![ZCUICore getUICore].kitInfo.hideNavBtnMore){
        btnItemWidth = 44;
        [self.moreButton setFrame:CGRectMake(self.frame.size.width-btnItemWidth, NavBarHeight-44, 44, 44)];
        [self.topView addSubview:self.moreButton];
        self.moreButton.tag = BUTTON_MORE;
        [self.moreButton addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
    }
    
    if ([ZCUICore getUICore].kitInfo.isShowEvaluation) {
        
        self.zcTitleView.frame = CGRectMake(100, NavBarHeight-44, self.frame.size.width- btnItemWidth*2.5 - 44*2.5, 44);
        
        self.evaluationBtn=[UIButton buttonWithType:UIButtonTypeCustom];
        [self.evaluationBtn setFrame:CGRectMake(self.frame.size.width-44 - btnItemWidth, NavBarHeight-44, 44, 44)];
        [self.evaluationBtn.imageView setContentMode:UIViewContentModeScaleAspectFit];
        [self.evaluationBtn setContentEdgeInsets:UIEdgeInsetsZero];
        [self.evaluationBtn setContentHorizontalAlignment:UIControlContentHorizontalAlignmentRight];
        [self.evaluationBtn setAutoresizingMask:UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleTopMargin];
        [self.evaluationBtn setAutoresizesSubviews:YES];
//        [self.evaluationBtn setTitleEdgeInsets:UIEdgeInsetsMake(0, 0, 0, 15)];
        [self.evaluationBtn setImageEdgeInsets:UIEdgeInsetsMake(0, 0, 0, 15)];
     
            [self.evaluationBtn setImage:[ZCUITools zcuiGetBundleImage:@"zcicon_evaluate"] forState:UIControlStateNormal];
            [self.evaluationBtn setImage:[ZCUITools zcuiGetBundleImage:@"zcicon_evaluate"] forState:UIControlStateHighlighted];
            self.evaluationBtn.tag = BUTTON_EVALUATION;
        
        [self.topView addSubview:self.evaluationBtn];
        [self.evaluationBtn addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
        btnItemWidth = btnItemWidth + 44;
    }
    
    if ([ZCUICore getUICore].kitInfo.isShowTelIcon ) {
        
        self.zcTitleView.frame = CGRectMake(100, NavBarHeight-44, self.frame.size.width- btnItemWidth*2.5 - 44*2.5, 44);
        
        self.telBtn=[UIButton buttonWithType:UIButtonTypeCustom];
        [self.telBtn setFrame:CGRectMake(self.frame.size.width-44 - btnItemWidth, NavBarHeight-44, 44, 44)];
        [self.telBtn.imageView setContentMode:UIViewContentModeScaleAspectFit];
        [self.telBtn setContentEdgeInsets:UIEdgeInsetsZero];
        [self.telBtn setContentHorizontalAlignment:UIControlContentHorizontalAlignmentRight];
        [self.telBtn setAutoresizingMask:UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleTopMargin];
        [self.telBtn setAutoresizesSubviews:YES];
        [self.telBtn setImageEdgeInsets:UIEdgeInsetsMake(0, 0, 0, 15)];
     
            [self.telBtn setImage:[ZCUITools zcuiGetBundleImage:@"zccion_call_icon"] forState:UIControlStateNormal];
            [self.telBtn setImage:[ZCUITools zcuiGetBundleImage:@"zccion_call_icon"] forState:UIControlStateHighlighted];
            self.telBtn.tag = BUTTON_TEL;
        
        
        [self.topView addSubview:self.telBtn];
        [self.telBtn addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
        btnItemWidth = btnItemWidth + 44;
    }
    
    if ([ZCUICore getUICore].kitInfo.isShowClose) {
        
        self.zcTitleView.frame = CGRectMake(btnItemWidth+44, NavBarHeight-44, self.frame.size.width-(btnItemWidth+44)*2, 44);
        
        self.closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.closeButton setFrame:CGRectMake(self.frame.size.width-btnItemWidth - 44, NavBarHeight-44, 44, 44)];
        [self.closeButton.imageView setContentMode:UIViewContentModeScaleAspectFit];
        [self.closeButton setAutoresizingMask:UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleTopMargin];
        [self.closeButton setContentEdgeInsets:UIEdgeInsetsZero];
        [self.closeButton setContentHorizontalAlignment:UIControlContentHorizontalAlignmentCenter];
        [self.closeButton setAutoresizesSubviews:YES];
//        [self.closeButton setTitleEdgeInsets:UIEdgeInsetsMake(0, 0, 0, 15)];
//        [self.closeButton setImageEdgeInsets:UIEdgeInsetsMake(0, 0, 0, 15)];
        //        [self.evaluationBtn setTitle:@"评价" forState:UIControlStateNormal];
        [self.closeButton.titleLabel setFont:[ZCUITools zcgetSubTitleFont]];
        [self.closeButton setTitleColor:[ZCUITools zcgetTopViewTextColor] forState:UIControlStateNormal];
        [self.closeButton setTitle:ZCSTLocalString(@"关闭") forState:0];
        self.closeButton.tag = BUTTON_CLOSE;
        
        
        [self.topView addSubview:self.closeButton];
        [self.closeButton addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
        if(![self getZCIMConfig].isArtificial){
            self.closeButton.hidden = YES;
        }
    }
    
    [self setTitleViewRTL];
}


-(void)dealloc{
    NSLog(@"chatView页面销毁");
    
    [[ZCIMChat getZCIMChat] setChatPageState:ZCChatPageStateBack];
}
         
         
         
#pragma mark -- 先处理是否显示 切换留言模板

-(void)changeLeaveMsgType:(LeaveExitType) isExist{
    [self changeLeaveMsgType:isExist showToast:NO msg:@""];
}
-(void)changeLeaveMsgType:(LeaveExitType) isExist showToast:(BOOL) isShow msg:(NSString *) msg{
    
    [_keyboardTools hideKeyboard];
    
    //先判定 留言的方式 转离线留言
    if ([self getZCIMConfig].msgToTicketFlag == 2) {
        if (_delegate && [_delegate respondsToSelector:@selector(onLeaveMsgClick:)] && _isJumpCustomLeaveVC) {
            [_delegate onLeaveMsgClick:[self getZCIMConfig].msgLeaveTxt];
            return;
        }
        
        // 2.8.9版本添加人工状态不支持留言转离线消息
        if([self getZCIMConfig].isArtificial){
            return;
        }
        
        ZCLeaveMsgVC *vc = [[ZCLeaveMsgVC alloc]init];
        vc.msgTxt = [self getZCIMConfig].msgLeaveTxt;
        vc.msgTmp = [self getZCIMConfig].msgLeaveContentTxt;
        
        vc.passMsgBlock = ^(NSString *msg) {
          // 发送离线消息 （只是本地数据的展示，不可发给机器人或者人工客服）

            ZCLibMessage * libMessage =  [[ZCUICore getUICore] setLocalDataToArr:ZCTipMessageOrderLeave type:0 duration:0 style:0 send:YES name:@"" content:msg config:[self getZCIMConfig]];
            libMessage.leaveMsgFlag = 1;
            libMessage.sendStatus = 0;
            [ZCUITools zcModelStringToAttributeString:libMessage];
            [[ZCUICore getUICore].listArray addObject:libMessage];
            
//            ZCLibMessage *tipMsg = [[ZCUICore getUICore] setLocalDataToArr:ZCTipMessageLeaveSuccess type:0 duration:0 style:ZCTipMessageLeaveSuccess send:NO name:@"" content:@"" config:[self getZCIMConfig]];
//            [[ZCUICore getUICore].listArray addObject:tipMsg];
            
            ZCLibMessage *tipMsg2 = [[ZCUICore getUICore] setLocalDataToArr:ZCTipMessageChatCloseByLeaveMsg type:0 duration:0 style:ZCTipMessageLeaveSuccess send:NO name:@"" content:@"" config:[self getZCIMConfig]];
            
            [ZCUITools zcModelStringToAttributeString:tipMsg2];
            [[ZCUICore getUICore].listArray addObject:tipMsg2];
            
            [self.listTable reloadData];
            [self scrollTableToBottom];
            
            [_keyboardTools setKeyBoardStatus:ZCKeyboardStatusNewSession];

            // 键盘状态发生变化了，需要重新设置table的高度，因为新会话的键盘高度变化了
            [self setFrameForListTable];
        };
        
        if (isShow) {

            [[ZCUIToastTools shareToast] showToast:msg duration:2.0f view:self position:ZCToastPositionCenter];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self openNewPage:vc];
            });
        }else{

            [self openNewPage:vc];
        }
        
        
        return;
    }
    
    
// 1. 开关是否开启
    [[ZCLibServer getLibServer] getWsTemplateList:[self getZCIMConfig] start:^{
        [[ZCUIToastTools shareToast] showProgress:@"" with:self];
    } success:^(NSDictionary *dict, ZCMessageSendCode sendCode) {
        [[ZCUIToastTools shareToast] dismisProgress];
        [ZCLogUtils logHeader:LogHeader info:@"留言模板%@", dict];
        if (dict != nil && [zcLibConvertToString(dict[@"code"]) intValue] == 1) {
            NSArray * arr = dict[@"data"];
            if (arr.count > 0) {
                NSMutableArray * array = [NSMutableArray arrayWithCapacity:0];
                //
                for (NSDictionary * item in arr) {
                    ZCWsTemplateModel * model = [[ZCWsTemplateModel alloc]initWithMyDict:item];
                    [array addObject:model];
                }
                 __weak ZCChatView * saveSelf = self;
                
                if (arr.count == 1) {
                    ZCWsTemplateModel * model = [array lastObject];
                    NSDictionary * Dic = @{@"templateId":zcLibConvertToString(model.templateId)};
                    
                    [saveSelf jumpNewPageVC:ZC_LeaveMsgPage IsExist:isExist isShowToat:NO tipMsg:@"" Dict:Dic];
                }else{
                    
                    
                    
                    // 2.掉接口 布局UI
                    ZCSelLeaveView * selMsgView = [[ZCSelLeaveView alloc]initActionSheet:array  WithView:self MsgID:[self getPlatformInfo].config.robotFlag IsExist:isExist];
                    
                    if (isShow) {

                        [[ZCUIToastTools shareToast] showToast:msg duration:2.0f view:self position:ZCToastPositionCenter];
                        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                            [selMsgView showInView:self];
                        });
                    }else{

                        [selMsgView showInView:self];
                    }
                        
                   
                    selMsgView.msgSetClickBlock = ^(ZCWsTemplateModel * _Nonnull itemModel) {
                
                        NSDictionary * Dic = @{@"templateId":zcLibConvertToString(itemModel.templateId)};
                        [saveSelf jumpNewPageVC:ZC_LeaveMsgPage IsExist:isExist isShowToat:isShow tipMsg:msg Dict:Dic];
                    };
                }
                
            }else{
                [self jumpNewPageVC:ZC_LeaveMsgPage IsExist:isExist isShowToat:isShow tipMsg:msg Dict:nil];
            }

         }
      
     } fail:^(NSString *errorMsg, ZCMessageSendCode errorCode) {
          [[ZCUIToastTools shareToast] showToast:errorMsg duration:1.5 view:self position:ZCToastPositionCenter];
    }];
    
}
/*
  设置 成员变量 isClickCloseBtn 为false
  在isShowReturnTips 为true 切点击了暂时离开 去调用
 */
- (void)setIsCloseNo {
    isClickCloseBtn = false;
}
@end
