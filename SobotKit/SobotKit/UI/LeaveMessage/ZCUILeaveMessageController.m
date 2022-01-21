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

#import "ZCOrderEditCell.h"
#import "ZCOrderCheckCell.h"
#import "ZCOrderContentCell.h"
#import "ZCOrderCreateCell.h"
#import "ZCOrderOnlyEditCell.h"
#define cellCheckIdentifier @"ZCOrderCheckCell"
#define cellEditIdentifier @"ZCOrderEditCell"
#define cellOrderContentIdentifier @"ZCOrderContentCell"
#define cellOrderSwitchIdentifier @"ZCOrderReplyOpenCell"
#define cellOrderSingleIdentifier @"ZCOrderOnlyEditCell"
#import "ZCLibOrderCusFieldsModel.h"
#import "ZCLibTicketTypeModel.h"
//#import "ZCOrderTypeController.h"
#import "ZCLibOrderCusFieldsModel.h"
#import "ZCZHPickView.h"
//#import "ZCOrderCusFieldController.h"
//#import "ZCUploadImageModel.h"
#import "ZCLibCommon.h"
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

typedef NS_ENUM(NSInteger,ExitType) {
    ISCOLSE         = 1,// 直接退出SDK
    ISNOCOLSE       = 2,// 不直接退出SDK
    ISBACKANDUPDATE = 3,// 仅人工模式 点击技能组上的留言按钮后,（返回上一页面 提交退出SDK）
    ISROBOT         = 4,// 机器人优先，点击技能组的留言按钮后，（返回技能组 提交和机器人会话）
    ISUSER          = 5,// 人工优先，点击技能组的留言按钮后，（返回技能组 提交机器人会话）
};

@interface ZCUILeaveMessageController ()<UITextFieldDelegate,UITextViewDelegate,UIGestureRecognizerDelegate,UINavigationControllerDelegate,ZCMLEmojiLabelDelegate,UIScrollViewDelegate,UIImagePickerControllerDelegate,ZCActionSheetDelegate,ZCXJAlbumDelegate,UITableViewDataSource,UITableViewDelegate,ZCZHPickViewDelegate,ZCOrderCreateCellDelegate>
{
 
    
    CGRect scFrame  ;
    
    void(^CloseBlock)();// 直接退出
    
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

@property (nonatomic,strong) ZCOrderModel * model;

@property (nonatomic, assign) BOOL isSend;
/** 系统相册相机图片 */
@property (nonatomic,strong) UIImagePickerController *zc_imagepicker;
// 留言选项卡
@property (nonatomic,strong) UIButton * leftBtn;
// 留言记录
@property (nonatomic,strong) UIButton * rightBtn;
@property (nonatomic,strong) UITableView * listTable;

@property (nonatomic,strong) NSMutableArray * listArray;

@property(nonatomic,strong)NSMutableArray   *imageArr;

@property (nonatomic,strong) NSMutableArray * imagePathArr;// 存储本地图片路径
@property(nonatomic,strong)NSMutableArray   *imageReplyArr;

@property(nonatomic,strong)UITextView       *tempTextView;
@property(nonatomic,strong)UITextField      *tempTextField;
@property(nonatomic,assign) BOOL isReplyPhoto;// 是否是回复的图片

@property (nonatomic,strong) ZCZHPickView *pickView; // 日期控件

@property (nonatomic,strong) UIScrollView * mainScrollView;

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
    _listArray = [[NSMutableArray alloc] init];

    // 添加选项卡
    [self createTabbarItemView];
    
    // 获取用户初始化配置参数  添加子页面
    [self customLayoutSubviewsWith:[ZCUICore getUICore].kitInfo];
    _isSend = NO;
    
    
    NSString * templateId = @"1";
    if (self.templateldIdDic != nil && [[self.templateldIdDic allKeys] containsObject:@"templateId"]) {
        templateId = self.templateldIdDic[@"templateId"];
    }
    // 加载自定义字段接口
    [[ZCLibServer getLibServer] postTemplateFieldInfoWithUid:[self getCurConfig].uid Templateld:templateId start:^{
        
    } success:^(NSDictionary *dict,NSMutableArray * cusFieldArray, ZCNetWorkCode sendCode) {
        @try{
            if (cusFieldArray.count) {
                self.coustomArr = [NSMutableArray arrayWithCapacity:0];
                self.coustomArr = cusFieldArray;
            }
            // 布局子页面
            [self refreshViewData];
        } @catch (NSException *exception) {
            
        } @finally {
            
        }
    } failed:^(NSString *errorMessage, ZCNetWorkCode errorCode) {
        // 布局子页面
        [self refreshViewData];
    }];
    
    
    _model =  [[ZCOrderModel alloc]init];
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
            [self popSkillView];
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
        if(sender.tag == self.rightBtn.tag){
            [_mesRecordVC loadData];
        }
    }
    
    if (btnTag == sender.tag) {
        return;
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
-(void)refreshViewData{
    [_listArray removeAllObjects];
    //    NSDictionary *dict = [ZCJSONDataTools getObjectData:_model];
    // 0，特殊行   1 单行文本 2 多行文本 3 日期 4 时间 5 数值 6 下拉列表 7 复选框 8 单选框 9 级联字段
    // propertyType == 1是自定义字段，0固定字段, 3不可点击
    
    NSMutableArray *arr0 = [[NSMutableArray alloc] init];

    if ( _ticketTitleShowFlag) {
        NSString * text = ZCSTLocalString(@"请输入标题（必填）");
        NSString * title = ZCSTLocalString(@"标题*");
       
        [arr0 addObject:@{@"code":@"1",
                          @"dictName":@"ticketTitle",
                          @"dictDesc":title,
                          @"placeholder":text,
                          @"dictValue":zcLibConvertToString(_model.ticketTitle),
                          @"dictType":@"1",
                          @"propertyType":@"0"
        }];
    }
    if (arr0.count>0) {
        [_listArray addObject:@{@"sectionName":@"",@"arr":arr0}];
    }
    
    NSMutableArray *arr1 = [[NSMutableArray alloc] init];
    
    [arr1 addObject:@{@"code":@"2",
                      @"dictName":@"ticketType",
                      @"dictDesc":[NSString stringWithFormat:@"%@*",ZCSTLocalString(@"问题分类")],
                      @"placeholder":@"",
                      @"dictValue":zcLibConvertToString(_model.ticketTypeName),
                      @"dictType":@"3",
                      @"propertyType":@"0"
                      }];
    if (_typeArr.count && _tickeTypeFlag == 1) {
       [_listArray addObject:@{@"sectionName":ZCSTLocalString(@"问题分类"),@"arr":arr1}];
    }
    
    NSMutableArray *arr2 = [[NSMutableArray alloc] init];
        
    if (_coustomArr.count >0) {
        int index = 0;
        for (ZCLibOrderCusFieldsModel *cusModel in _coustomArr) {
            NSString *propertyType = @"1";
            if ([zcLibConvertToString(cusModel.openFlag) intValue] == 0) {
                propertyType = @"3";
                cusModel.fieldType = @"3";
            }
            NSString * titleStr = zcLibConvertToString(cusModel.fieldName);
            if([zcLibConvertToString(cusModel.fillFlag) intValue] == 1){
                titleStr = [NSString stringWithFormat:@"%@*",titleStr];
            }
            [arr2 addObject:@{@"code":[NSString stringWithFormat:@"%d",index],
                              @"dictName":zcLibConvertToString(cusModel.fieldName),
                              @"dictDesc":zcLibConvertToString(titleStr),
                              @"placeholder":zcLibConvertToString(cusModel.fieldRemark),
                              @"dictValue":zcLibConvertToString(cusModel.fieldValue),
                              @"dictType":zcLibConvertToString(cusModel.fieldType),
                              @"propertyType":propertyType,
                              @"model":cusModel
                              }];
            index = index + 1;
        }
         [_listArray addObject:@{@"sectionName":ZCSTLocalString(@"自定义字段"),@"arr":arr2}];
    }
    
    //    留言相关 1显示 0不显示
    //    telShowFlag 电话是否显示
    //    telFlag 电话是否必填
    //    enclosureShowFlag 附件是否显示
    //    enclosureFlag 附件是否必填
    //    emailFlag 邮箱是否必填
    //    emailShowFlag 邮箱是否显示
    //    ticketStartWay 工单发起方式 1邮箱，2手机
//    ZCLibConfig *libConfig = [self getCurConfig];
    
    NSString * tmp = @"";
    if (_msgTmp != nil) {
        tmp = _msgTmp;
    }
    // 过滤标签
    tmp = [ZCHtmlCore filterHTMLTag:tmp];
    while ([tmp hasPrefix:@"\n"]) {
        tmp=[tmp substringWithRange:NSMakeRange(1, tmp.length-1)];
    }
    
    if(zcLibConvertToString([ZCUICore getUICore].kitInfo.leaveContentPlaceholder).length > 0){
        tmp = ZCSTLocalString(zcLibConvertToString([ZCUICore getUICore].kitInfo.leaveContentPlaceholder));
    }
    
//    if (libConfig.enclosureShowFlag) {
        NSMutableArray *arr3 = [[NSMutableArray alloc] init];
        [arr3 addObject:@{@"code":@"1",
                          @"dictName":@"ticketReplyContent",
                          @"dictDesc":ZCSTLocalString(@"回复内容"),
                          @"placeholder":tmp,//  libConfig.msgTmp
                          @"dictValue":zcLibConvertToString(_model.ticketDesc),
                          @"dictType":@"0",
                          @"propertyType":@"0"
                          }];
        [_listArray addObject:@{@"sectionName":ZCSTLocalString(@"回复"),@"arr":arr3}];

//    }
   
    
    NSMutableArray *arr4 = [[NSMutableArray alloc] init];
    

    
    if ( _emailShowFlag) {
        NSString * text = [NSString stringWithFormat:@"%@(%@)",ZCSTLocalString(@"请输入邮箱地址"),ZCSTLocalString(@"选填")];
        NSString * title = ZCSTLocalString(@"邮箱");
        if( _emailFlag){
            text = [NSString stringWithFormat:@"%@(%@)",ZCSTLocalString(@"请输入邮箱地址"),ZCSTLocalString(@"必填")];
            title = [NSString stringWithFormat:@"%@*",ZCSTLocalString(@"邮箱")];
        }
        [arr4 addObject:@{@"code":@"1",
                          @"dictName":@"ticketEmail",
                          @"dictDesc":title,
                          @"placeholder":text,
                          @"dictValue":zcLibConvertToString(_model.email),
                          @"dictType":@"1",
                          @"propertyType":@"0"
                          }];
    }
    
    if ( _telShowFlag) {
        NSString * text = [NSString stringWithFormat:@"%@(%@)",ZCSTLocalString(@"请输入手机号码"),ZCSTLocalString(@"选填")];
        NSString * title = ZCSTLocalString(@"手机");
        if ( _telFlag) {
            text = [NSString stringWithFormat:@"%@(%@)",ZCSTLocalString(@"请输入手机号码"),ZCSTLocalString(@"必填")];
            title = [NSString stringWithFormat:@"%@*",ZCSTLocalString(@"手机")];
        }
        [arr4 addObject:@{@"code":@"1",
                          @"dictName":@"ticketTel",
                          @"dictDesc":title,
                          @"placeholder":text,
                          @"dictValue":zcLibConvertToString(_model.tel),
                          @"dictType":@"1",
                          @"propertyType":@"0"
                          }];
    }
    if (arr4.count>0) {
        [_listArray addObject:@{@"sectionName":@"",@"arr":arr4}];
    }

    [_listTable reloadData];
}


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
            [safeVC backAction];
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
    // 提交
    if(sender.tag == BUTTON_MORE){
        // 标题
        if (_ticketTitleShowFlag) {
            if (zcLibTrimString(_model.ticketTitle).length == 0) {
                [[ZCUIToastTools shareToast] showToast:ZCSTLocalString(@"请填写标题") duration:1.0f view:self.view position:ZCToastPositionCenter];
                return;
            }
            
        }
        
        // 工单类型
        if (_typeArr.count>0 && _tickeTypeFlag == 1) {
            if ([@"" isEqualToString:zcLibConvertToString(_model.ticketType)]) {
                [[ZCUIToastTools shareToast] showToast:ZCSTLocalString(@"选择分类") duration:1.0f view:self.view position:ZCToastPositionCenter];
                return;
            }
            
        }
        
        NSMutableArray *cusFields = [NSMutableArray arrayWithCapacity:0];
        // 自定义字段
        for (ZCLibOrderCusFieldsModel *cusModel in _coustomArr) {
            if([cusModel.fillFlag intValue] == 1 && zcLibIs_null(cusModel.fieldValue)){
                [[ZCUIToastTools shareToast] showToast:[NSString stringWithFormat:@"%@%@",cusModel.fieldName,ZCSTLocalString(@"不能为空")] duration:1.0f view:self.view position:ZCToastPositionCenter];
                return;
            }
            
            if(!zcLibIs_null(cusModel.fieldSaveValue)){
                [cusFields addObject:@{@"id":zcLibConvertToString(cusModel.fieldId),
                                       @"value":zcLibConvertToString(cusModel.fieldSaveValue)
                                       }];
            }else{
                [cusFields addObject:@{@"id":zcLibConvertToString(cusModel.fieldId),
                                       @"value":zcLibConvertToString(cusModel.fieldValue)
                                       }];
            }
            

            if(![self checkContentValid:cusModel.fieldSaveValue model:cusModel]){
                [[ZCUIToastTools shareToast] showToast:[NSString stringWithFormat:@"%@%@",cusModel.fieldName,ZCSTLocalString(@"格式不正确")] duration:1.0f view:self.view position:ZCToastPositionCenter];
                return;
            }
        }
        
         // 显示邮箱
        if (_emailShowFlag) {
            // 必填
            if (_emailFlag) {
                if (zcLibTrimString(_model.email).length>0) {
                     if(!zcLibValidateEmail(_model.email)){
                        [[ZCUIToastTools shareToast] showToast:ZCSTLocalString(@"请输入正确的邮箱") duration:1.0f view:self.view position:ZCToastPositionCenter];
                        return;
                     }
                }else{
                    [[ZCUIToastTools shareToast] showToast:ZCSTLocalString(@"邮箱不能为空") duration:1.0f view:self.view position:ZCToastPositionCenter];
                    return;
                }
            }else{
              // 非必填
                if(zcLibTrimString(_model.email).length>0){
                    if(!zcLibValidateEmail(_model.email)){
                        [[ZCUIToastTools shareToast] showToast:ZCSTLocalString(@"请输入正确的邮箱") duration:1.0f view:self.view position:ZCToastPositionCenter];
                        return;
                    }
                }
                
            }
            
        }
        
        // 显示 手机
        if (_telShowFlag && _telFlag &&  zcLibTrimString(_model.tel).length==0) {
            // 必填
            [[ZCUIToastTools shareToast] showToast:ZCSTLocalString(@"手机号不能为空") duration:1.0f view:self.view position:ZCToastPositionCenter];
            return;
        }
        
        // 附件
        if (self.enclosureShowFlag && self.enclosureFlag && _imagePathArr.count<=0) {
            [[ZCUIToastTools shareToast] showToast:ZCSTLocalString(@"请上传附件") duration:1.0f view:self.view position:ZCToastPositionCenter];
            return;
        }
        
        
        // 提交留言内容
        if (_model.ticketDesc.length<=0) {
            [[ZCUIToastTools shareToast] showToast:ZCSTLocalString(@"请填写问题描述")  duration:1.0f view:self.view position:ZCToastPositionCenter];
            return;
        }
        // 留言不能大于3000字
        if (_model.ticketDesc.length >3000) {
//            [[ZCUIToastTools shareToast] showToast:ZCSTLocalString(@"问题描述，最多只能输入3000字符") duration:1.0f view:self.view position:ZCToastPositionCenter];
//            return;
        }
        
        
        
        [self UpLoadWith:cusFields];
        [self allHideKeyBoard];
    }
    
    // 返回的事件
    if(sender.tag == BUTTON_BACK){
        [self backAction];
    }
    
}



-(BOOL)checkContentValid:(NSString *) text model:(ZCLibOrderCusFieldsModel *) model{
    
    if(model != nil && zcLibConvertToString(text).length >0){
        NSArray *limitOptions = nil;
        
        if([model.limitOptions isKindOfClass:[NSString class]]){
            NSString *limitOption =  zcLibConvertToString(model.limitOptions);
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
             return zcLibValidateDecimalDouble(text);
        }
        if([limitOptions containsObject:[NSNumber numberWithInt:4]] || [limitOptions containsObject:@"4"]){
             return zcLibValidateRuleNotBlank(text);
        }
        
        if([limitOptions containsObject:[NSNumber numberWithInt:5]] || [limitOptions containsObject:@"5"]){
             return zcLibValidateNumber(text);
        }
        
        if([limitOptions containsObject:[NSNumber numberWithInt:6]] || [limitOptions containsObject:@"6"]){
            if(zcLibConvertToString(text).length > [model.limitChar intValue]){
                return NO;
            }
        }
        
        if([limitOptions containsObject:[NSNumber numberWithInt:7]] || [limitOptions containsObject:@"7"]){
            return zcLibValidateEmail(text);
        }
        
        if([limitOptions containsObject:[NSNumber numberWithInt:8]] || [limitOptions containsObject:@"8"]){
        
            return zcLibValidateMobileWithRegex(text, [ZCUITools zcgetTelRegular]);
        }
        
    }
    return YES;
}

// 提交请求
- (void)UpLoadWith:(NSMutableArray*)arr{
    if(_isSend){
        return;
    }
    
    __weak ZCUILeaveMessageController *leaveVC = self;
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    [dic setValue:zcLibConvertToString(_model.ticketDesc) forKey:@"ticketContent"];
    
    if(_ticketTitleShowFlag){
        [dic setValue:zcLibConvertToString(_model.ticketTitle) forKey:@"ticketTitle"];
    }
    
    if(_emailFlag || _emailShowFlag){
        [dic setValue:zcLibConvertToString(_model.email) forKey:@"customerEmail"];
        
    }
    if ( _telFlag || _telShowFlag) {
      [dic setValue:zcLibConvertToString(_model.tel) forKey:@"customerPhone"];
    }
    
    if(!zcLibIs_null([ZCUICore getUICore].kitInfo.leaveCusFieldArray) && [ZCUICore getUICore].kitInfo.leaveCusFieldArray.count > 0){
        if(arr == nil){
            arr = [[NSMutableArray alloc] init];
        }
        for (NSDictionary *item in [ZCUICore getUICore].kitInfo.leaveCusFieldArray) {
            [arr addObject:item];
        }
        
    }
    // 添加自定义字段
    if (arr.count > 0) {
         [dic setValue:zcLibConvertToString([ZCLocalStore DataTOjsonString:arr]) forKey:@"extendFields"];
    }
    
    // 2.8.6新增对接字段，可以设置订单、城市等固定字段
    if(!zcLibIs_null([ZCUICore getUICore].kitInfo.leaveParamsExtends) && [ZCUICore getUICore].kitInfo.leaveParamsExtends.count > 0){
        [dic setValue:zcLibConvertToString([ZCLocalStore DataTOjsonString:[ZCUICore getUICore].kitInfo.leaveParamsExtends]) forKey:@"paramsExtends"];
    }
    
    
    
    // 工单类型
    if ( _tickeTypeFlag == 2 ) {
        [dic setValue:zcLibConvertToString(_ticketTypeId) forKey:@"ticketTypeId"];
    }else{
        [dic setValue:zcLibConvertToString(_model.ticketType) forKey:@"ticketTypeId"];
    }
    
    if(_imageArr.count>0){
        NSString *fileStr = @"";
        for (int i = 0; i < _imageArr.count; i++) {
            
            NSDictionary *model = _imageArr[i];
            
            NSString *fileUrlStr = zcLibConvertToString(model[@"fileUrl"]);
            if (fileUrlStr.length > 0) {
                fileStr = [fileStr stringByAppendingFormat:@"%@;",fileUrlStr];
            }
            
        }
        
        fileStr = [fileStr substringToIndex:fileStr.length-1];
        [dic setObject:zcLibConvertToString(fileStr) forKey:@"fileStr"];
    }
    
    // 技能组ID
    [dic setObject:zcLibConvertToString([ZCUICore getUICore].kitInfo.leaveMsgGroupId) forKey:@"groupId"];
    
    NSString * templateId = @"1";
    if (self.templateldIdDic != nil && [[self.templateldIdDic allKeys] containsObject:@"templateId"]) {
        templateId = self.templateldIdDic[@"templateId"];
    }
    
    _isSend = YES;
    [[[ZCUICore getUICore] getAPIServer] sendLeaveMessage:dic config:[leaveVC getCurConfig] TemplateId: templateId success:^(ZCNetWorkCode code,int status ,NSString *msg) {
        leaveVC.isSend = NO;
        
        // 手机号格式错误
        if (status ==0) {
            if(self.navigationController){
                [[ZCUIToastTools shareToast] showToast:msg duration:1.0f view:leaveVC.view position:ZCToastPositionCenter];
            }else{
                
                [[ZCUIToastTools shareToast] showToast:msg duration:1.0f view:leaveVC.presentingViewController.view position:ZCToastPositionCenter];
            }
        }else{
            // 提交成功之后，是否直接退出  2.7.0修改 新增提示页面。 清空记录

            _model = [[ZCOrderModel alloc] init];
            [self refreshViewData];
            [_imageArr removeAllObjects];
            [_imagePathArr removeAllObjects];
//            [self.listTable reloadData];
            [self addLeaveMsgSuccessView];
        }
    } failed:^(NSString *errorMessage, ZCNetWorkCode erroCode) {
        leaveVC.isSend = NO;
        [[ZCUIToastTools shareToast]showToast:errorMessage duration:1.0f view:leaveVC.view position:ZCToastPositionCenter];
    }];
    
  
}

/**
 *  设置UITableView分割线空隙
 */
-(void)setTableSeparatorInset{
    UIEdgeInsets inset = UIEdgeInsetsMake(0, 0, 0, 0);
    if ([_listTable respondsToSelector:@selector(setSeparatorInset:)]) {
        [_listTable setSeparatorInset:inset];
    }
    if ([_listTable respondsToSelector:@selector(setLayoutMargins:)]) {
        [_listTable setLayoutMargins:inset];
    }
    
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
   
    _listTable = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, [self getCurViewWidth], scrollHeight) style:UITableViewStyleGrouped];
    _listTable.backgroundColor = [UIColor clearColor];
    _listTable.dataSource = self;
    _listTable.delegate = self;
//    _listTable.bounces = YES;
    _listTable.layer.masksToBounds = YES;
//    _listTable.sectionHeaderHeight = 50;
    _listTable.sectionFooterHeight = 10;
    _listTable.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
    _listTable.autoresizesSubviews = YES;
    [_mainScrollView addSubview:_listTable];
    [_listTable registerClass:[ZCOrderCheckCell class] forCellReuseIdentifier:cellCheckIdentifier];
    [_listTable registerClass:[ZCOrderContentCell class] forCellReuseIdentifier:cellOrderContentIdentifier];
    [_listTable registerClass:[ZCOrderEditCell class] forCellReuseIdentifier:cellEditIdentifier];
    [_listTable registerClass:[ZCOrderOnlyEditCell class] forCellReuseIdentifier:cellOrderSingleIdentifier];
    [_listTable setSeparatorColor:[ZCUITools zcgetBackgroundBottomLineColor]];
//    [_listTable setSeparatorColor:UIColor.redColor];
    [self setTableSeparatorInset];
    // 关闭安全区域，否则UITableViewCell横屏时会是全屏的宽
    NSString *version = [UIDevice currentDevice].systemVersion;
    if (version.doubleValue >= 11.0) {
        [_listTable setInsetsContentViewsToSafeArea:NO];
    }
    if (version.doubleValue >= 15.0) {
        _listTable.sectionHeaderTopPadding = 0;
    }
    UITapGestureRecognizer *gestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapHideKeyboard)];
    gestureRecognizer.numberOfTapsRequired = 1;
    gestureRecognizer.cancelsTouchesInView = NO;
    [_listTable addGestureRecognizer:gestureRecognizer];
    
    
    UIView * footView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, ScreenWidth, 300)];
    footView.backgroundColor = [UIColor clearColor];
    
    // 区尾添加提交按钮 2.7.1改版
    UIButton * commitBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [commitBtn setTitle:ZCSTLocalString(@"提交") forState:UIControlStateNormal];
    [commitBtn setTitle:ZCSTLocalString(@"提交") forState:UIControlStateSelected];
    
    [commitBtn setTitleColor:[ZCUITools zcgetLeaveSubmitTextColor] forState:UIControlStateNormal];
    [commitBtn setTitleColor:[ZCUITools zcgetLeaveSubmitTextColor] forState:UIControlStateHighlighted];
    UIImage * img = [self createImageWithColor:[ZCUITools zcgetLeaveSubmitImgColor]];
    [commitBtn setBackgroundImage:img forState:UIControlStateNormal];
    [commitBtn setBackgroundImage:img forState:UIControlStateSelected];
    commitBtn.frame = CGRectMake(ZCNumber(15), ZCNumber(20), ScreenWidth- ZCNumber(30), ZCNumber(44));
    commitBtn.tag = BUTTON_MORE;
    [commitBtn addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
    commitBtn.layer.masksToBounds = YES;
    commitBtn.layer.cornerRadius = 22.f;
    commitBtn.titleLabel.font = ZCUIFont17;
    commitBtn.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleBottomMargin|UIViewAutoresizingFlexibleWidth;
    [footView addSubview:commitBtn];

    _listTable.tableFooterView = footView;
    
    
    
    _rightView = [[UIView alloc]initWithFrame:CGRectMake([self getCurViewWidth],0, [self getCurViewWidth], scrollHeight)];
    
    _rightView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleWidth;
    _rightView.autoresizesSubviews = YES;
    _mesRecordVC = [[ZCMsgRecordVC alloc]init];
    
    [_rightView addSubview:_mesRecordVC.view];
    [_mainScrollView addSubview:_rightView];
    
    [_mesRecordVC updataWithHeight:scrollHeight];
    
    __weak ZCUILeaveMessageController * saveVC = self;
    _mesRecordVC.jumpMsgDetailBlock = ^(ZCRecordListModel *model) {
        ZCMsgDetailsVC * detailVC = [[ZCMsgDetailsVC alloc]init];
        detailVC.ticketId = model.ticketId;
        detailVC.companyId = zcLibConvertToString([ZCLocalStore getLocalParamter:@"ZCKEY_COMPANYID"]);
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
-(void)goBack:(ExitType) isClose{
    if([ZCUICore getUICore].ZCViewControllerCloseBlock != nil){
        [ZCUICore getUICore].ZCViewControllerCloseBlock(self,ZC_CloseLeave);
    }
    
    if (isClose == ISCOLSE || isClose == ISBACKANDUPDATE) {
        [self isClose];
    }else{
        // 直接返回到上一级页面
        [self noIsClose : isClose];
    }
}

#pragma mark -- 返回到上一VC
- (void)backAction{
    if (_exitType == ISCOLSE) {
        [self isClose];
    }else{
        [self noIsClose:ISNOCOLSE];
    }
    [self allHideKeyBoard];
}

// 是否直接退出SDK
- (void)isClose{
    [self hideKeyboard];
    if (_isNavOpen) {
        // 用户接入VC -》chatVC -》留言VC
        if(self.navigationController.viewControllers.count>=3){
        
            [self.navigationController popToViewController:self.navigationController.viewControllers[self.navigationController.viewControllers.count -3] animated:YES];
        }else{
            [self.navigationController popToViewController:self.navigationController.viewControllers[0] animated:YES];
        }
  
        CloseBlock();
        if (self.backRefreshPageblock) {
            self.backRefreshPageblock(nil);
        }
    }else{
        [self dismissViewControllerAnimated:NO completion:^{
            CloseBlock();
            if (self.backRefreshPageblock) {
                self.backRefreshPageblock(nil);
            }
        }];
    }
    
}

-(void)setCloseBlock:(void (^)())closeBlock{
    CloseBlock = closeBlock;
}


// 不直接退出
- (void)noIsClose:(ExitType) isExitType{
    
    switch (isExitType) {
        case 1:
            [self isClose];
            break;
        case 2:
            [self popSkillView];
            break;
        case 3:
            [self isClose];
            break;
        case 4:
            [[NSNotificationCenter defaultCenter]postNotificationName:@"closeSkillView" object:nil];
            [NSTimer scheduledTimerWithTimeInterval:0.2 target:self selector:@selector(popSkillView) userInfo:nil repeats:NO];
            
            break;
        case 5:
            [[NSNotificationCenter defaultCenter]postNotificationName:@"gotoRobotChatAndLeavemeg" object:nil];
            [NSTimer scheduledTimerWithTimeInterval:0.2 target:self selector:@selector(popSkillView) userInfo:nil repeats:NO];
            break;
        default:
            break;
    }
    
}

- (void)popSkillView{
     [self hideKeyboard];
    if (self.backRefreshPageblock) {
        self.backRefreshPageblock(nil);
    }
    if(_isNavOpen){
        [self.navigationController popViewControllerAnimated:YES];
    }else{
        [self dismissViewControllerAnimated:YES completion:^{
            
        }];
    }
    
}
#pragma mark -- 页面返回的事件  End *******************************************



#pragma mark EmojiLabel链接点击事件
// 链接点击
-(void)attributedLabel:(ZCTTTAttributedLabel *)label didSelectLinkWithURL:(NSURL *)url{
    // 此处得到model 对象对应的值
    
    //    NSLog(@"url:%@  url.absoluteString:%@",url,url.absoluteString);
    [self doClickURL:url.absoluteString text:@""];
}


// 链接点击
-(void)ZCMLEmojiLabel:(ZCMLEmojiLabel *)emojiLabel didSelectLink:(NSString *)link withType:(ZCMLEmojiLabelLinkType)type{
    [self doClickURL:link text:@""];
}


// 链接点击
-(void)doClickURL:(NSString *)url text:(NSString * )htmlText{
    if(url){
        url=[url stringByReplacingOccurrencesOfString:@"\"" withString:@""];
        
        //        链接处理：
        [[ZCToolsCore getToolsCore] dealWithLinkClickWithLick:url viewController:self];
    }
    
}



#pragma mark UITableView delegate Start

-(void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    [self allHideKeyBoard];
}

// 返回section数
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return _listArray.count;
}

// 返回section高度
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if (section == 0) {
        ZCMLEmojiLabel *label = [[ZCMLEmojiLabel alloc] initWithFrame:CGRectMake(15, 12, ScreenWidth-30, 0)];
        [label setFont:ZCUIFont14];
        //    [label setText:_listArray[section][@"sectionName"]];
        [label setBackgroundColor:[UIColor clearColor]];
        [label setTextAlignment:NSTextAlignmentLeft];
        
        [label setTextColor:UIColorFromThemeColor(ZCTextSubColor)];
        label.numberOfLines = 0;
        label.isNeedAtAndPoundSign = NO;
        label.disableEmoji = NO;
        
        label.lineSpacing = 3.0f;
        [label setLinkColor:[ZCUITools zcgetChatLeftLinkColor]];
//        label.delegate = self;

         __block CGSize  labSize = CGSizeZero;

        NSString *text = _msgTxt;//[self getCurConfig].msgTxt;
        
        
        [ZCHtmlCore filterHtml:text result:^(NSString * _Nonnull text1, NSMutableArray * _Nonnull arr, NSMutableArray * _Nonnull links) {
            if (text1 !=nil && text1.length > 0) {
                 label.attributedText =   [ZCHtmlFilter setHtml:text1 attrs:arr view:label textColor:UIColorFromThemeColor(ZCTextSubColor) textFont:ZCUIFont14 linkColor:[ZCUITools zcgetChatLeftLinkColor]];
            }else{
                 label.attributedText = [[NSAttributedString alloc] initWithString:@""];
            }
            
            labSize  =  [label preferredSizeWithMaxWidth:ScreenWidth-30];
           
        }];
        return labSize.height + 24;
    }
    return 5;
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 5;
}


- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
return [UIView new];
}

// 返回section 的View
-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    UIView *view=[[UIView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, 10)];
    if (section == 0) {
        [view setBackgroundColor:[ZCUITools zcgetLightGrayDarkBackgroundColor]];
        ZCMLEmojiLabel *label = [[ZCMLEmojiLabel alloc] initWithFrame:CGRectMake(15, 10, ScreenWidth-30, 0)];
        [label setFont:ZCUIFont14];
        //    [label setText:_listArray[section][@"sectionName"]];
        [label setBackgroundColor:[UIColor clearColor]];
        [label setTextAlignment:NSTextAlignmentLeft];
        [label setTextColor:UIColorFromThemeColor(ZCTextSubColor)];
        label.numberOfLines = 0;
        label.isNeedAtAndPoundSign = NO;
        label.disableEmoji = NO;
        
        label.lineSpacing = 3.0f;
        [label setLinkColor:[ZCUITools zcgetChatLeftLinkColor]];
        label.delegate = self;

         __block CGSize  labSize = CGSizeZero;

        NSString *text = _msgTxt;//[self getCurConfig].msgTxt;
        
        if(zcLibConvertToString([ZCUICore getUICore].kitInfo.leaveMsgGuideContent).length > 0){
            text = ZCSTLocalString(zcLibConvertToString([ZCUICore getUICore].kitInfo.leaveMsgGuideContent));
        }
        
        [ZCHtmlCore filterHtml:text result:^(NSString * _Nonnull text1, NSMutableArray * _Nonnull arr, NSMutableArray * _Nonnull links) {
            if (text1 !=nil && text1.length > 0) {
                 label.attributedText =   [ZCHtmlFilter setHtml:text1 attrs:arr view:label textColor:UIColorFromThemeColor(ZCTextSubColor) textFont:ZCUIFont14 linkColor:[ZCUITools zcgetChatLeftLinkColor]];
            }else{
                 label.attributedText = [[NSAttributedString alloc] initWithString:@""];
            }
            
            labSize  =  [label preferredSizeWithMaxWidth:ScreenWidth-30];
           
        }];
        
        
        label.frame = CGRectMake(15, 12, labSize.width, labSize.height);
        [view addSubview:label];
        
        CGRect VF = view.frame;
        VF.size.height = labSize.height + 12;
        view.frame = VF;
        
        [[ZCToolsCore getToolsCore] setRTLFrame:label];
        
    }else{
        view.frame = CGRectMake(0, 0, ScreenWidth, 0.01);
    }
    
   
    return view;
}

/**
 计算Label高度
 
 @param label 要计算的label，设置了值
 @param width label的最大宽度
 @param type 是否从新设置宽，1设置，0不设置
 */
- (CGSize )autoHeightOfLabel:(UILabel *)label with:(CGFloat )width{
    //Calculate the expected size based on the font and linebreak mode of your label
    // FLT_MAX here simply means no constraint in height
    CGSize maximumLabelSize = CGSizeMake(width, FLT_MAX);
    
    CGSize expectedLabelSize = [label sizeThatFits:maximumLabelSize];
    
    //adjust the label the the new height.
    CGRect newFrame = label.frame;
    newFrame.size.height = expectedLabelSize.height;
    label.frame = newFrame;
    [label updateConstraintsIfNeeded];
    
    return expectedLabelSize;
}


// 返回section下得行数
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if(_listArray==nil){
        return 0;
    }
    NSDictionary *sectionDict = _listArray[section];
    return ((NSMutableArray *)sectionDict[@"arr"]).count;
}

// cell
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    ZCOrderCreateCell *cell = nil;
    // 0，特殊行   1 单行文本 2 多行文本 3 日期 4 时间 5 数值 6 下拉列表 7 复选框 8 单选框 9 级联字段
    NSDictionary *itemDict = _listArray[indexPath.section][@"arr"][indexPath.row];
    int type = [itemDict[@"dictType"] intValue];
//    int propertyType = [itemDict[@"propertyType"] intValue];
    if(type == 0){
        cell = (ZCOrderContentCell*)[tableView dequeueReusableCellWithIdentifier:cellOrderContentIdentifier];
        if (cell == nil) {
            cell = [[ZCOrderContentCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellOrderContentIdentifier];
        }
        cell.isReply = YES;
        ((ZCOrderContentCell *)cell).imageArr = _imageArr;
        ((ZCOrderContentCell *)cell).imagePathArr = _imagePathArr;
        ((ZCOrderContentCell *)cell).enclosureShowFlag = self.enclosureShowFlag;
    }else if(type == 1 || type ==5){
        cell = (ZCOrderOnlyEditCell*)[tableView dequeueReusableCellWithIdentifier:cellOrderSingleIdentifier];
        if (cell == nil) {
            cell = [[ZCOrderOnlyEditCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellOrderSingleIdentifier];
        }
    }else if(type == 2){
        cell = (ZCOrderEditCell*)[tableView dequeueReusableCellWithIdentifier:cellEditIdentifier];
        if (cell == nil) {
            cell = [[ZCOrderEditCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellEditIdentifier];
        }
    }else{
        cell = (ZCOrderCheckCell*)[tableView dequeueReusableCellWithIdentifier:cellCheckIdentifier];
        if (cell == nil) {
            cell = [[ZCOrderCheckCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellCheckIdentifier];
        }
    }
    [cell setBackgroundColor:UIColorFromThemeColor(ZCBgSystemWhiteLightDarkColor)];
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    cell.tableWidth = self.listTable.frame.size.width;
    cell.delegate = self;
    cell.tempModel = _model;
    cell.tempDict = itemDict;
    cell.indexPath = indexPath;
    [cell initDataToView:itemDict];
    return cell;
}



// 是否显示删除功能
-(BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath{
    return NO;
}

// 删除清理数据
-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    editingStyle = UITableViewCellEditingStyleDelete;
}


// table 行的高度
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [self tableView:tableView cellForRowAtIndexPath:indexPath];
    return cell.frame.size.height;
}

// table 行的点击事件
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NSDictionary *itemDict = _listArray[indexPath.section][@"arr"][indexPath.row];
    
    if([itemDict[@"propertyType"] intValue]==3){
        return;
    }
    
    NSString *dictName = itemDict[@"dictName"];
    
    // 多级 工单分类
    if([@"ticketType" isEqual:dictName]){
        __block ZCUILeaveMessageController *myself = self;
//        ZCOrderTypeController *typeVC = [[ZCOrderTypeController alloc] init];
        ZCCheckTypeView *typeVC = [[ZCCheckTypeView alloc] initWithFrame:CGRectMake(0, 0, [self getCurViewWidth], 0)];
        
        ZCPageSheetView *sheetView = [[ZCPageSheetView alloc] initWithTitle:ZCSTLocalString(@"选择") superView:self.view showView:typeVC type:ZCPageSheetTypeLong];
        typeVC.typeId = @"-1";
        typeVC.parentView = nil;
        typeVC.listArray = _typeArr;
        typeVC.orderTypeCheckBlock = ^(ZCLibTicketTypeModel *tempmodel) {
            if(tempmodel){
                myself.model.ticketType = tempmodel.typeId;
                myself.model.ticketTypeName = tempmodel.typeName;
                [self refreshViewData];
                
                [sheetView dissmisPageSheet];
            }
        };
        
        [sheetView showSheet:typeVC.frame.size.height animation:YES block:^{
            
        }];
        return;
    }
    
    // 0，特殊行   1 单行文本 2 多行文本 3 日期 4 时间 5 数值 6 下拉列表 7 复选框 8 单选框 9 级联字段
    int propertyType = [itemDict[@"propertyType"] intValue];
    if(propertyType == 1){
        int index = [itemDict[@"code"] intValue];
        curEditModel = _coustomArr[index];
        
        int fieldType = [curEditModel.fieldType intValue];
        if(fieldType == 4){
           _pickView = [[ZCZHPickView alloc] initWithFrame:self.view.frame DatePickWithDate:[NSDate new]  datePickerMode:UIDatePickerModeTime isHaveNavControler:NO];
            [_pickView setTitle:ZCSTLocalString(@"时间")];
            _pickView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
            _pickView.delegate = self;
            [_pickView show];

        }
        if(fieldType == 3){
            _pickView = [[ZCZHPickView alloc] initWithFrame:self.view.frame DatePickWithDate:[NSDate new]  datePickerMode:UIDatePickerModeDate isHaveNavControler:NO];
            [_pickView setTitle:ZCSTLocalString(@"日期")];
            _pickView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleBottomMargin;
            _pickView.delegate = self;
            [_pickView show];
        }
        
        if(fieldType == 6 || fieldType == 7 || fieldType == 8){
            ZCCheckCusFieldView *vc = [[ZCCheckCusFieldView alloc] initWithFrame:CGRectMake(0, 0, [self getCurViewWidth], 0)];
//            ZCOrderCusFieldController *vc = [[ZCOrderCusFieldController alloc] init];
            vc.preModel = curEditModel;
            vc.orderCusFiledCheckBlock = ^(ZCLibOrderCusFieldsDetailModel *model, NSMutableArray *arr) {
                curEditModel.fieldValue = model.dataName;
                curEditModel.fieldSaveValue = model.dataValue;
                
                if(fieldType == 7){
                    NSString *dataName = @"";
                    NSString *dataIds = @"";
                    for (ZCLibOrderCusFieldsDetailModel *item in arr) {
                        dataName = [dataName stringByAppendingFormat:@",%@",item.dataName];
                        dataIds = [dataIds stringByAppendingFormat:@",%@",item.dataValue];
                    }
                    if(dataName.length>0){
                        dataName = [dataName substringWithRange:NSMakeRange(1, dataName.length-1)];
                        dataIds = [dataIds substringWithRange:NSMakeRange(1, dataIds.length-1)];
                    }
                    curEditModel.fieldValue = dataName;
                    curEditModel.fieldSaveValue = dataIds;
                }
                
                [self refreshViewData];
            };
            
            ZCPageSheetView *sheetView = [[ZCPageSheetView alloc] initWithTitle:ZCSTLocalString(@"选择") superView:self.view showView:vc type:ZCPageSheetTypeLong];
            [sheetView showSheet:vc.frame.size.height animation:YES block:^{
                
            }];
            return;
        }
    }
}

//设置分割线间距
-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    if((indexPath.row+1) < _listArray.count){
        UIEdgeInsets inset = UIEdgeInsetsMake(0, 0, 0, 0);
        if ([cell respondsToSelector:@selector(setSeparatorInset:)]) {
            [cell setSeparatorInset:inset];
        }
        
        if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
            [cell setLayoutMargins:inset];
        }
    }
}


#pragma mark 日期控件
-(void)toobarDonBtnHaveClick:(ZCZHPickView *)pickView resultString:(NSString *)resultString{
//    NSLog(@"%@",resultString);
    if(curEditModel && ([curEditModel.fieldType intValue]==4 || [curEditModel.fieldType intValue]==3)){
        curEditModel.fieldValue = resultString;
        curEditModel.fieldSaveValue = resultString;
        [self refreshViewData];
    }
    
}

#pragma mark UITableViewCell 行点击事件处理
-(void)itemCreateCusCellOnClick:(ZCOrderCreateItemType)type dictValue:(NSString *)value dict:(NSDictionary *)dict indexPath:(NSIndexPath *)indexPath{
    // 单行或多行文本，是自定义字段，需要单独处理_coustomArr对象的内容
    if(type == ZCOrderCreateItemTypeOnlyEdit || type == ZCOrderCreateItemTypeMulEdit){
        int propertyType = [dict[@"propertyType"] intValue];
        if(propertyType == 1){
            int index = [dict[@"code"] intValue];
            ZCLibOrderCusFieldsModel *temModel = _coustomArr[index];
            temModel.fieldValue = value;
            temModel.fieldSaveValue = value;
            
            // 这里要重新处理数据 *
            NSString * titleStr = zcLibConvertToString(temModel.fieldName);
            if([zcLibConvertToString(temModel.fillFlag) intValue] == 1){
                titleStr = [NSString stringWithFormat:@"%@*",titleStr];
            }
            
            NSMutableArray *arr1 = _listArray[indexPath.section][@"arr"];
            arr1[indexPath.row] = @{@"code":[NSString stringWithFormat:@"%d",index],
                                    @"dictName":zcLibConvertToString(temModel.fieldName),
                                    @"dictDesc":zcLibConvertToString(titleStr),
                                    @"placeholder":zcLibConvertToString(temModel.fieldRemark),
                                    @"dictValue":zcLibConvertToString(temModel.fieldValue),
                                    @"dictType":zcLibConvertToString(temModel.fieldType),
                                    @"propertyType":@"1"
                                    };
        }
        if (propertyType == 0) {
            ZCLibConfig *libConfig = [self getCurConfig];
            NSMutableArray * arr4 = _listArray[indexPath.section][@"arr"];
            
            if([@"ticketEmail" isEqual:dict[@"dictName"]]){
                _model.email = value;
                
                NSString * text = [NSString stringWithFormat:@"%@(%@)",ZCSTLocalString(@"请输入邮箱地址"),ZCSTLocalString(@"选填")];
                NSString * title = ZCSTLocalString(@"邮箱");
                if( libConfig.emailFlag){
                    text = [NSString stringWithFormat:@"%@(%@)",ZCSTLocalString(@"请输入邮箱地址"),ZCSTLocalString(@"必填")];
                    title = [NSString stringWithFormat:@"%@*",ZCSTLocalString(@"邮箱")];
                }
               arr4[indexPath.row] = @{@"code":@"1",
                                  @"dictName":@"ticketEmail",
                                  @"dictDesc":title,
                                  @"placeholder":text,
                                  @"dictValue":zcLibConvertToString(_model.email),
                                  @"dictType":@"1",
                                  @"propertyType":@"0"
                                  };
                
            }
            
            if([@"ticketTel" isEqual:dict[@"dictName"]]){
                _model.tel = value;
                
                NSString * text = [NSString stringWithFormat:@"%@(%@)",ZCSTLocalString(@"请输入手机号码"),ZCSTLocalString(@"选填")];
                NSString * title = ZCSTLocalString(@"手机");
                if ( libConfig.telFlag) {
                    text =  [NSString stringWithFormat:@"%@(%@)",ZCSTLocalString(@"请输入手机号码"),ZCSTLocalString(@"必填")];
                    title = [NSString stringWithFormat:@"%@*",ZCSTLocalString(@"手机")];
                }
                arr4[indexPath.row] = @{@"code":@"1",
                                        @"dictName":@"ticketTel",
                                        @"dictDesc":title,
                                        @"placeholder":text,
                                        @"dictValue":zcLibConvertToString(_model.tel),
                                        @"dictType":@"1",
                                        @"propertyType":@"0"
                                        };
                
            }
            
            if([@"ticketTitle" isEqual:dict[@"dictName"]]){
                 _model.ticketTitle = value;
                 
                  NSString * text = ZCSTLocalString(@"请输入标题（必填）");
                  NSString * title = ZCSTLocalString(@"标题*");
                 
                 arr4[indexPath.row] = @{@"code":@"1",
                                    @"dictName":@"ticketTitle",
                                    @"dictDesc":title,
                                    @"placeholder":text,
                                    @"dictValue":zcLibConvertToString(_model.ticketTitle),
                                    @"dictType":@"1",
                                    @"propertyType":@"0"
                  };
                 
                 
                 
             }
        }
    }
}

- (void)didAddImage{
    ZCActionSheet *mysheet = [[ZCActionSheet alloc] initWithDelegate:self selectedColor:nil CancelTitle:ZCSTLocalString(@"取消") OtherTitles:ZCSTLocalString(@"拍摄"),ZCSTLocalString(@"从相册选择"), nil];
    [mysheet show];
    
}

- (void)actionSheet:(ZCActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex == 2) {
        // 保存图片到相册
        [self getPhotoByType:1];
    }
    if(buttonIndex == 1){
        [self getPhotoByType:2];
    }
}


#pragma mark - cell 代理 预览附件

-(void)itemCreateCellOnClick:(ZCOrderCreateItemType)type dictKey:(NSString *)key model:(ZCOrderModel *)model withButton:(UIButton *)button{
    if(type == ZCOrderCreateItemTypeAddPhoto || type == ZCOrderCreateItemTypeAddReplyPhoto){
        if(type == ZCOrderCreateItemTypeAddReplyPhoto){
            _isReplyPhoto = YES;
        }else{
            _isReplyPhoto = NO;
        }
        [self didAddImage];
    }
    
    // 点击删除图片
    if(type == ZCOrderCreateItemTypeDeletePhoto){
        [_imageArr removeObjectAtIndex:[key intValue]];
        [_imagePathArr removeObjectAtIndex:[key intValue]];
        [_listTable reloadData];
    }
    
    if(type == ZCOrderCreateItemTypeDesc || type == ZCOrderCreateItemTypeTitle || type == ZCOrderCreateItemTypeReplyType){
        _model = model;
    }
    
    if(type == ZCOrderCreateItemTypeLookAtPhoto || type == ZCOrderCreateItemTypeLookAtReplyPhoto){

        // 浏览图片
        if(type == ZCOrderCreateItemTypeLookAtReplyPhoto){

               NSInteger currentInt = [key intValue];

                NSString *imgPathStr;
                if(zcLibCheckFileIsExsis([_imagePathArr objectAtIndex:currentInt])){
                    imgPathStr = [_imagePathArr objectAtIndex:currentInt];
                }
                NSDictionary *imgDic = [_imageArr objectAtIndex:currentInt];
                NSString *imgFileStr =  zcLibConvertToString(imgDic[@"cover"]);
                
                if (imgFileStr.length>0) {
            //        视频预览
                    
                    NSURL *imgUrl = [NSURL fileURLWithPath:imgPathStr];
                    UIWindow *window = [[ZCToolsCore getToolsCore] getCurWindow];
                    ZCVideoPlayer *player = [[ZCVideoPlayer alloc] initWithFrame:window.bounds withShowInView:window url:imgUrl Image:button.imageView.image];
                    [player showControlsView];
                    
                }else{
            //     图片预览
                    
                    UIImageView *picView=(UIImageView*)button.imageView ;
                    CALayer *calayer = picView.layer.mask;
                    [picView.layer.mask removeFromSuperlayer];
                    
                    SobotXHImageViewer *xh=[[SobotXHImageViewer alloc] initWithImageViewerWillDismissWithSelectedViewBlock:^(SobotXHImageViewer *imageViewer, UIImageView *selectedView) {
                        
                    } didDismissWithSelectedViewBlock:^(SobotXHImageViewer *imageViewer, UIImageView *selectedView) {
                        
                        selectedView.layer.mask = calayer;
                        [selectedView setNeedsDisplay];
                    } didChangeToImageViewBlock:^(SobotXHImageViewer *imageViewer, UIImageView *selectedView) {
                        
                    }];
                    
                    NSMutableArray *photos = [[NSMutableArray alloc] init];
                    [photos addObject:picView];
                    xh.disableTouchDismiss = NO;
                    [xh showWithImageViews:photos selectedView:picView];
                }
            
            
            
//            ZCXJAlbumController *albumVC = [[ZCXJAlbumController alloc] initWithImgULocationArr:_imagePathArr CurPage:[key intValue]];
//            albumVC.myDelegate = self;
//
//            [self.navigationController pushViewController:albumVC animated:YES];
                
        }else{

        }
        
    }
    
}

#pragma mark --- 图片浏览代理
-(void)getCurPage:(NSInteger)curPage{
    
}

-(void)delCurPage:(NSInteger)curPage{
    [_imageArr removeObjectAtIndex:curPage];
    [_imagePathArr removeObjectAtIndex:curPage];
    [_listTable reloadData];
}


#pragma mark 发送图片相关
/**
 *  根据类型获取图片
 *
 *  @param buttonIndex 2，来源照相机，1来源相册
 */
-(void)getPhotoByType:(NSInteger) buttonIndex{
    _zc_imagepicker = nil;
    _zc_imagepicker = [[UIImagePickerController alloc]init];
    _zc_imagepicker.delegate = self;
    _zc_imagepicker.mediaTypes = [NSArray arrayWithObjects:@"public.movie", @"public.image", nil];
    _zc_imagepicker.modalPresentationStyle = UIModalPresentationFullScreen;
    [ZCSobotCore getPhotoByType:buttonIndex byUIImagePickerController:_zc_imagepicker Delegate:self];
}
#pragma mark - UIImagePickerControllerDelegate
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker{
    [picker dismissViewControllerAnimated:YES completion:^{
        
    }];
}

-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    __weak  ZCUILeaveMessageController *_myselft  = self;

    [ZCSobotCore imagePickerController:_zc_imagepicker didFinishPickingMediaWithInfo:info WithView:self.view Delegate:self block:^(NSString *filePath, ZCMessageType type, NSDictionary *duration) {

        if(type == ZCMessageTypePhoto){
            [_myselft updateloadFile:filePath type:ZCMessageTypePhoto dict:info];
        }else{
            [_myselft converToMp4:duration withInfoDic:info];
        }
    }];
}


-(void)updateloadFile:(NSString *)filePath type:(ZCMessageType) type dict:(NSDictionary *) cover{

    __weak  ZCUILeaveMessageController *_myself  = self;
//        [ZCSobotCore imagePickerController:_zc_imagepicker didFinishPickingMediaWithInfo:cover WithView:self.view Delegate:self block:^(NSString *filePath, ZCMessageType type, NSDictionary *dict) {

    [[[ZCUICore getUICore] getAPIServer] fileUploadForLeave:filePath config:[self getCurConfig] start:^{
                [[ZCUIToastTools shareToast] showProgress:[NSString stringWithFormat:@"%@...",ZCSTLocalString(@"上传中")]  with:_myself.view];
            } success:^(NSString *fileURL, ZCNetWorkCode code) {

                  [[ZCUIToastTools shareToast] dismisProgress];
                            if (zcLibIs_null(_imageArr)) {
                                _imageArr = [NSMutableArray arrayWithCapacity:0];
                            }
                            if (zcLibIs_null(_imagePathArr)) {
                                _imagePathArr = [NSMutableArray arrayWithCapacity:0];
                            }
                            [_imagePathArr addObject:filePath];

                            NSDictionary * dic = @{@"fileUrl":fileURL};
                //            ZCUploadImageModel * item = [[ZCUploadImageModel alloc]initWithMyDict:dic];
//                            [_imageArr addObject:dic];
                
                                if(type == ZCMessageTypeVideo){
                                    dic = @{@"cover":cover[@"cover"],@"fileUrl":fileURL};
                                    [_myself.imageArr addObject:dic];
                //
                                }else{
                                    [_myself.imageArr addObject:dic];
                                }
                
                            [_listTable reloadData];

            } fail:^(ZCNetWorkCode errorCode) {
                [[ZCUIToastTools shareToast] showToast:ZCSTLocalString(@"网络错误，请检查网络后重试") duration:1.0f view:_myself.view position:ZCToastPositionCenter];
            }];

}


- (NSString *)URLDecodedString:(NSString *) url
{
    NSString *result = [(NSString *)url stringByReplacingOccurrencesOfString:@"+" withString:@" "];
    return [result stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
}

-(void) converToMp4:(NSDictionary *)dict withInfoDic:(NSDictionary *)infoDic{

    NSURL *videoUrl = dict[@"video"];
    NSString *coverImg = dict[@"image"];
    
    NSMutableDictionary *infoMutDic = [infoDic mutableCopy];
    [infoMutDic setValue:coverImg forKey:@"cover"];

    AVURLAsset *avAsset = [AVURLAsset URLAssetWithURL:videoUrl options:nil];

    //    NSArray *compatiblePresets = [AVAssetExportSession exportPresetsCompatibleWithAsset:avAsset];

    [[ZCUIToastTools shareToast] showToast:ZCSTLocalString(@"视频处理中，请稍候!") duration:1.0 view:self.view  position:ZCToastPositionCenter];

    __weak  ZCUILeaveMessageController *keyboardSelf  = self;
    AVAssetExportSession *exportSession = [[AVAssetExportSession alloc] initWithAsset:avAsset presetName:AVAssetExportPresetMediumQuality];

    //    NSDateFormatter *formater = [[NSDateFormatter alloc] init];//用时间给文件全名，以免重复
    //    [formater setDateFormat:@"yyyy-MM-dd-HH:mm:ss"];

    NSString * fname = [NSString stringWithFormat:@"/sobot/output-%ld.mp4",(long)[NSDate date].timeIntervalSince1970];
    zcLibCheckPathAndCreate(zcLibGetDocumentsFilePath(@"/sobot/"));
    NSString *resultPath=zcLibGetDocumentsFilePath(fname);
    //    NSLog(@"resultPath = %@",resultPath);
    exportSession.outputURL = [NSURL fileURLWithPath:resultPath];
    exportSession.outputFileType = AVFileTypeMPEG4;
    exportSession.shouldOptimizeForNetworkUse = YES;
    [exportSession exportAsynchronouslyWithCompletionHandler:^(void)
     {
         switch (exportSession.status) {
             case AVAssetExportSessionStatusCompleted:{
                 //                 NSLog(@"AVAssetExportSessionStatusCompleted%@",[NSThread currentThread]);
                 // 主队列回调
                 dispatch_async(dispatch_get_main_queue(), ^{
                     [keyboardSelf updateloadFile:[self URLDecodedString:resultPath] type:ZCMessageTypeVideo dict:infoMutDic];
                 });
             }
                 break;
             case AVAssetExportSessionStatusUnknown:
                 //                 NSLog(@"AVAssetExportSessionStatusUnknown");
                 break;

             case AVAssetExportSessionStatusWaiting:

                 //                 NSLog(@"AVAssetExportSessionStatusWaiting");

                 break;

             case AVAssetExportSessionStatusExporting:

                 //                 NSLog(@"AVAssetExportSessionStatusExporting");

                 break;
             case AVAssetExportSessionStatusFailed:

                 //                 NSLog(@"AVAssetExportSessionStatusFailed");

                 break;
             case AVAssetExportSessionStatusCancelled:

                 break;
         }
     }];
}



#pragma mark -- 键盘滑动的高度
-(void)didKeyboardWillShow:(NSIndexPath *)indexPath view1:(UITextView *)textview view2:(UITextField *)textField{
    _tempTextView = textview;
    _tempTextField = textField;
    
    //获取当前cell在tableview中的位置
    CGRect rectintableview = [_listTable rectForRowAtIndexPath:indexPath];
    
    //获取当前cell在屏幕中的位置
    CGRect rectinsuperview = [_listTable convertRect:rectintableview fromView:[_listTable superview]];
    
    contentoffset = _listTable.contentOffset;
    
    if ((rectinsuperview.origin.y+50 - _listTable.contentOffset.y)>200) {
        if(!isLandspace){
            [_listTable setContentOffset:CGPointMake(_listTable.contentOffset.x,((rectintableview.origin.y-_listTable.contentOffset.y)-150)+  _listTable.contentOffset.y) animated:YES];
            contentoffset = CGPointMake(_listTable.contentOffset.x,((rectintableview.origin.y-_listTable.contentOffset.y)-150)+  _listTable.contentOffset.y);
        }
    }
}



-(void)tapHideKeyboard{
    if(!zcLibIs_null(_tempTextView)){
        [_tempTextView resignFirstResponder];
        _tempTextView = nil;
    }else if(!zcLibIs_null(_tempTextField)){
        [_tempTextField resignFirstResponder];
        _tempTextField  = nil;
    }else{
        [self allHideKeyBoard];
    }
    
    if (_listTable.contentSize.height <( ScreenHeight - NavBarHeight)) {
        [_listTable setContentOffset:CGPointMake(0, 0)];
    }
}


- (void) hideKeyboard {
    if(!zcLibIs_null(_tempTextView)){
        [_tempTextView resignFirstResponder];
        _tempTextView = nil;
    }else if(!zcLibIs_null(_tempTextField)){
        [_tempTextField resignFirstResponder];
        _tempTextField  = nil;
    }else{
        [self allHideKeyBoard];
    }

    if(contentoffset.x != 0 || contentoffset.y != 0){
        // 隐藏键盘，还原偏移量
        [_listTable setContentOffset:contentoffset];
    }
}


#pragma mark UITableView delegate end

- (void)allHideKeyBoard
{
//    for (UIWindow* window in [UIApplication sharedApplication].windows)
//    {
//        for (UIView* view in window.subviews)
//        {
//            [self dismissAllKeyBoardInView:view];
//        }
//    }
    [self.view endEditing:true];
}

-(BOOL) dismissAllKeyBoardInView:(UIView *)view
{
    if([view isFirstResponder])
    {
        [view resignFirstResponder];
        return YES;
    }
    for(UIView *subView in view.subviews)
    {
        if([self dismissAllKeyBoardInView:subView])
        {
            return YES;
        }
    }
    return NO;
}


-(void)viewDidLayoutSubviews{
    [super viewDidLayoutSubviews];
//    if(_listTable.frame.size.width != viewWidth){

//        [self setTableSeparatorInset];
        

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
    [self.listTable setFrame:CGRectMake(spaceX, 0, LW, scrollHeight)];
    [self.listTable reloadData];


    _rightView.frame = CGRectMake([self getCurViewWidth]+spaceX,0, LW, scrollHeight);
    [_mesRecordVC updataWithHeight:scrollHeight];
    
    
    // 1.获取当前的页面
    NSInteger index = (NSInteger)(btnTag - 2001);
    
    // 2.计算偏移量
    CGPoint offSetPoint = CGPointMake(index *_mainScrollView.bounds.size.width, 0);
    
    // 3。将偏移量赋值给scrollerView
    [_mainScrollView setContentOffset:offSetPoint animated:YES];
    
        
    if (_pickView != nil) {
        [_pickView setFrame:CGRectMake(0, 0, [self getCurViewWidth], [self getCurViewHeight])];
    }
  
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
        [self goBack:leaveVC.exitType];
        
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
