//
//  ZCMsgDetailsVC.m
//  SobotKit
//
//  Created by lizhihui on 2019/2/20.
//  Copyright © 2019 zhichi. All rights reserved.
//

#import "ZCMsgDetailsVC.h"
#import "ZCUIColorsDefine.h"
#import "ZCLibGlobalDefine.h"
#import "ZCUIImageTools.h"
#import "ZCUICore.h"
//#import "ZCMsgDetailCell.h"
#import "ZCButton.h"
#import "ZCHtmlCore.h"


#import "ZCPlatformTools.h"
#import "ZCUICore.h"
#import "ZCRecordListModel.h"
#import "ZCLeaveDetailCell.h"
#define cellmsgDetailIdentifier @"ZCLeaveDetailCell"
#import "ZCUICustomActionSheet.h"
#import "ZCUIWebController.h"
#import "ZCUIRatingView.h"
#import "ZCHtmlFilter.h"

#import "ZCReplyLeaveController.h"

#import "ZCReplyLeaveView.h"

#import "ZCSobotCore.h"
#import <AVFoundation/AVFoundation.h>

#import "ZCToolsCore.h"

#import "ZCUIXHImageViewer.h"
#import "ZCVideoPlayer.h"

#import "ZCReplyFileView.h"
#import "ZCDocumentLookController.h"
#import "ZCLocalStore.h"

@interface ZCMsgDetailsVC ()
<UITableViewDelegate,
UITableViewDataSource,
ZCUIBackActionSheetDelegate,
RatingViewDelegate,
ZCReplyLeaveViewDelegate,
UIImagePickerControllerDelegate,
UINavigationControllerDelegate,ZCMLEmojiLabelDelegate>
{
    
    BOOL     isShowHeard;
    CGSize contSize;
    
}
@property(nonatomic,strong)UITableView      *listTable;

@property (nonatomic,strong) NSMutableArray * listArray;

@property (nonatomic,strong) ZCButton * showBtn;

@property (nonatomic,strong) UIView * headerView;
@property (nonatomic,strong) UIView * headerMoreFileView;

@property (nonatomic,strong) ZCMLEmojiLabel * conlab;
// 线条
@property (nonatomic,strong) UIView *headerlineView1;
// 线条
@property (nonatomic,strong) UILabel *headerTitleLab;
@property (nonatomic,strong) UILabel *headerStateLab;

@property (nonatomic,strong) UIView * footView;

@property (nonatomic,strong) UIView * commitFootView;


/***  评价页面 **/
@property (nonatomic,strong) ZCUICustomActionSheet *sheet;

@property (nonatomic, strong) UIImagePickerController *zc_imagepicker;

@property (nonatomic, strong) ZCReplyLeaveView *replyLeaveView;

@property (nonatomic, strong) NSMutableArray *imageArr;
@property (nonatomic, strong) NSMutableArray * imagePathArr;

//  2.8.2 已创建  model ，单独处理 ，
@property (nonatomic, strong) ZCRecordListModel *creatRecordListModel;

@property (nonatomic, strong) UIView *buttonBgView;
@property (nonatomic, strong) UIButton *replyButton;
@property (nonatomic, strong) UIButton *evaluateButton;

@property (nonatomic, strong) NSString *replyStr;
@property (nonatomic, strong) NSDictionary *evaluateModelDic;
@end

@implementation ZCMsgDetailsVC


#pragma mark - lift cycle
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    if(self.listTable){
        [self orientationChanged];
        [self viewDidLayoutSubviews];
    }
    
    if (isLandspace) {
        [self loadData];
    }
}


- (void)viewDidLoad {
    [super viewDidLoad];
    if ([ZCUICore getUICore].kitInfo.navcBarHidden) {
        self.navigationController.navigationBarHidden = YES;
        self.navigationController.navigationBar.translucent = NO;
    }
    
    if (self.navigationController.navigationBarHidden) {
        self.navigationController.navigationBar.translucent = NO;
    }
    
    if(!self.navigationController.navigationBarHidden){
        self.navigationController.navigationBar.translucent = NO;
        [self setNavigationBarStyle];
        self.title = ZCSTLocalString(@"留言详情");
        [self.navigationController.navigationBar setTitleTextAttributes:@{NSFontAttributeName:[ZCUITools zcgetTitleFont],NSForegroundColorAttributeName:[ZCUITools zcgetTopViewTextColor]}];
    }else{
        [self createTitleView];
        self.titleLabel.text = ZCSTLocalString(@"留言详情");
        [self.backButton.imageView setContentMode:UIViewContentModeScaleAspectFit];
        [self.backButton setTitle:ZCSTLocalString(@"") forState:UIControlStateNormal];
        [self.moreButton setHidden:YES];
        
    }
    
    
    isShowHeard = NO;
    _listArray = [NSMutableArray arrayWithCapacity:0];
    [self.view setBackgroundColor:[ZCUITools zcgetLightGrayDarkBackgroundColor]];
    [self createTableView];
    [self loadData];
}

-(void)viewDidLayoutSubviews{
    [super viewDidLayoutSubviews];
    [self setTableSeparatorInset];
    
    CGFloat Y = 0;
    if (self.navigationController.navigationBarHidden) {
        Y = NavBarHeight;
    }
    [self reloadReplyButton];
    
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
    
    CGFloat scrollHeight = self.view.frame.size.height - 60 - XBottomBarHeight - Y;
    [self.listTable setFrame:CGRectMake(spaceX, Y, LW, scrollHeight)];
    [self.listTable reloadData];
    if(isLandspace){
        if(self.replyLeaveView){
            [self.replyLeaveView tappedCancel:YES];
        }
    }
    
    if(_sheet){
        [_sheet tappedCancel];
    }
    
}

-(ZCLibConfig *)getCurConfig{
    return [[ZCUICore getUICore] getLibConfig];
}
// 加载数据
-(void)loadData{
    [[ZCUIToastTools shareToast] showProgress:@"" with:self.view];
    __weak ZCMsgDetailsVC * weakSelf = self;
    NSDictionary *dict = @{
        @"partnerid":zcLibConvertToString([ZCLibClient getZCLibClient].libInitInfo.partnerid),
        @"uid":zcLibConvertToString([self getCurConfig].uid),
        @"companyId":zcLibConvertToString(_companyId)};
    [[[ZCUICore getUICore] getAPIServer] postUserDealTicketinfoListWith:dict ticketld:_ticketId start:^{
        
    } success:^(NSDictionary *dict, NSMutableArray *itemArray, ZCNetWorkCode sendCode) {
        [[ZCUIToastTools shareToast] dismisProgress];
        if (itemArray.count > 0) {
            [_listArray removeAllObjects];
            // flag ==2 时是 还需要处理
            for (ZCRecordListModel * model in itemArray) {
                
                if (model.flag == 2 && model.replayList.count > 0) {
                    for (ZCRecordListModel * item in model.replayList) {
                        item.flag = 2;
                        item.content = model.content;
                        item.timeStr = model.timeStr;
                        item.time = model.time;
                        
                        [self.listArray addObject:item];
                    }
                }else{
                    
                    if(model.flag == 1){
                        self.creatRecordListModel = model;
//                       创建 状态，去掉 附件
//                        model.fileList = nil;
                    }
                    
                    [self.listArray addObject:model];
                }
                
                [self reloadReplyButton];
                    
            }
            
            
            ZCRecordListModel * model = [_listArray lastObject];
            [ZCHtmlCore filterHtml:[self filterHtmlImage:model.content] result:^(NSString * _Nonnull text1, NSMutableArray * _Nonnull arr, NSMutableArray * _Nonnull links) {
                if (text1.length > 0 && text1 != nil) {
                    model.contentAttr =   [ZCHtmlFilter setHtml:text1 attrs:arr view:nil textColor:UIColorFromThemeColor(ZCTextSubColor) textFont:ZCUIFont14 linkColor:[ZCUITools zcgetChatLeftLinkColor]];
                }else{
                    model.contentAttr =   [[NSMutableAttributedString alloc] initWithString:model.content];
                }
            }];
            
    
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self createStarView];
            
            //这里进行UI更新
            [weakSelf.listTable reloadData];
            [weakSelf.listTable layoutIfNeeded];
//            NSLog(@"刷新了");
        });
        
        [self updateReadStatus];
    } failed:^(NSString *errorMessage, ZCNetWorkCode errorCode) {
        [[ZCUIToastTools shareToast] dismisProgress];
        [self updateReadStatus];
    } ];
    
}

// 设置留言已读
-(void)updateReadStatus{
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] initWithDictionary:@{
    @"partnerId":zcLibConvertToString([ZCLibClient getZCLibClient].libInitInfo.partnerid),
    @"ticketId":zcLibConvertToString(_ticketId),
    @"companyId":zcLibConvertToString(_companyId)}];
    [[[ZCUICore getUICore] getAPIServer] updateUserTicketReplyInfo:dict start:^{
       
    } success:^(NSDictionary *dict, ZCNetWorkCode sendCode) {
       
    } failed:^(NSString *errorMessage, ZCNetWorkCode errorCode) {
        
    }];
}

-(void)buttonClick:(UIButton *)sender{
    if([self autoAlertEvaluate]){
        return;
    }
    
    if (self.presentingViewController) {
        [self dismissViewControllerAnimated:YES completion:nil];
    }else{
        [self.navigationController popViewControllerAnimated:YES];
    }
    
}


-(void)didMoveToParentViewController:(UIViewController *)parent{
    
    [super didMoveToParentViewController:parent];
    NSLog(@"页面侧滑返回：%@",parent);
    if(!parent){
        if([self autoAlertEvaluate]){
            return;
        }
    }
}

-(BOOL)autoAlertEvaluate{
    
    if(self.listArray!=nil && self.listArray.count > 0){
        ZCRecordListModel *first = self.listArray.firstObject;
        // evaluateModelDic当前评价信息，已经评价过
        if(first.isOpen && first.isEvalution == 0 && !self.evaluateModelDic)
        {
            NSString *key = [NSString stringWithFormat:@"TicketKEY_%@",zcLibConvertToString(_ticketId)];
            
            if([ZCUICore getUICore].kitInfo.showLeaveDetailBackEvaluate && zcLibConvertToString([ZCLocalStore getLocalParamter:key]).length == 0){
                [ZCLocalStore addObject:key forKey:key];
                [self commitScore];
                return YES;
            }
        }
    }
    
    return NO;
    
}


-(void)createTableView{
    // 计算Y值
    CGFloat Y = 0;
    if (self.navigationController.navigationBarHidden) {
        Y = NavBarHeight;
    }
    
//    线条
    UIView *lineView = [[UIView alloc]initWithFrame:CGRectMake(0, Y, self.view.frame.size.width, 0.5)];
    lineView.backgroundColor = [ZCUITools zcgetBackgroundBottomLineColor];
    [self.view addSubview:lineView];
    
    _listTable = [[UITableView alloc]initWithFrame:CGRectMake(0, Y+1, [self getCurViewWidth], [self getCurViewHeight] - Y- 60 - XBottomBarHeight) style:UITableViewStyleGrouped];
    [_listTable registerClass:[ZCLeaveDetailCell class] forCellReuseIdentifier:cellmsgDetailIdentifier];
    _listTable.delegate = self;
    _listTable.dataSource = self;
    _listTable.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    _listTable.autoresizesSubviews = YES;
    _listTable.backgroundColor = [ZCUITools zcgetLightGrayDarkBackgroundColor];
    [self.view addSubview:_listTable];
    // 关闭安全区域，否则UITableViewCell横屏时会是全屏的宽
    NSString *version = [UIDevice currentDevice].systemVersion;
    if (version.doubleValue >= 11.0) {
        [_listTable setInsetsContentViewsToSafeArea:NO];
    }
    
    if (iOS7) {
        _listTable.backgroundView = nil;
    }
    [_listTable setSeparatorColor:UIColorFromThemeColor(ZCBgLineColor)];
    [_listTable setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    [self setTableSeparatorInset];
//    2.8.2 增加 客户回复
    
    self.buttonBgView = [[UIView alloc]initWithFrame:CGRectMake(0, CGRectGetMaxY(self.listTable.frame) + 10, [self getCurViewWidth], 50 + XBottomBarHeight)];
    self.buttonBgView.backgroundColor = UIColorFromThemeColor(ZCBgSystemWhiteLightDarkColor);
    self.buttonBgView.layer.shadowOpacity= 1;
    self.buttonBgView.layer.shadowColor = UIColorFromRGBAlpha(0x515a7c, 0.15).CGColor;
    self.buttonBgView.layer.shadowOffset = CGSizeZero;//投影偏移
    self.buttonBgView.layer.shadowRadius = 2;
    
    self.buttonBgView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleTopMargin;
    [self.view addSubview:self.buttonBgView];
    
    
//    UIView *buttonTopLineView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, viewWidth, 0.5)];
//    buttonTopLineView.backgroundColor = UIColorFromRGB(lineGrayColor);
//    buttonTopLineView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
//    [self.buttonBgView addSubview:buttonTopLineView];
    
    
    self.replyButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.replyButton setFrame:CGRectMake(0,7, [self getCurViewWidth], 36)];
    self.replyButton.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleTopMargin;
    self.replyButton.backgroundColor = [UIColor clearColor];
    self.replyButton.titleLabel.font = ZCUIFontBold14;
    [self.replyButton setTitleColor:[ZCUITools zcgetLeaveSubmitImgColor] forState:UIControlStateNormal];
    [self.replyButton setTitle:ZCSTLocalString(@"回复") forState:UIControlStateNormal];
    [self.replyButton setImage:[ZCUITools zcuiGetBundleImage:@"zcicon_reply_button_icon"] forState:UIControlStateNormal];
    [self.replyButton setImage:[ZCUITools zcuiGetBundleImage:@"zcicon_reply_button_icon"] forState:UIControlStateHighlighted];
//    [self.replyButton setTitleEdgeInsets:UIEdgeInsetsMake(0, -self.replyButton.imageView.image.size.width, 0, self.replyButton.imageView.image.size.width)];
//    [self.replyButton setImageEdgeInsets:UIEdgeInsetsMake(0, self.replyButton.titleLabel.bounds.size.width, 0, -self.replyButton.titleLabel.bounds.size.width)];
//    [self.replyButton setTitleEdgeInsets:UIEdgeInsetsMake(0, -6, 0, 6)];
    if(isRTLLayout()){

        [self.replyButton setTitleEdgeInsets:UIEdgeInsetsMake(0, -6, 0, 6)];
    }else{
        [self.replyButton setImageEdgeInsets:UIEdgeInsetsMake(0, -6, 0, 6)];
    }
     
    [self.replyButton addTarget:self action:@selector(replyButtonClick) forControlEvents:UIControlEventTouchUpInside];
    [self.buttonBgView addSubview:self.replyButton];
//    self.replyButton.hidden = YES;
    
    
    self.evaluateButton = [[UIButton alloc]initWithFrame:CGRectMake(0,5, ScreenWidth, 36 )];
    self.evaluateButton.backgroundColor = [ZCUITools zcgetLeaveSubmitImgColor];
    self.evaluateButton.layer.cornerRadius = 18;
    self.evaluateButton.layer.masksToBounds = YES;
    self.evaluateButton.titleLabel.font = [UIFont systemFontOfSize:14];
    [self.evaluateButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.evaluateButton setTitle:ZCSTLocalString(@"服务评价") forState:UIControlStateNormal];
    self.evaluateButton.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    [self.evaluateButton addTarget:self action:@selector(commitScore) forControlEvents:UIControlEventTouchUpInside];
    
    [self.buttonBgView addSubview:self.evaluateButton];
    self.evaluateButton.hidden = YES;
}

- (void)reloadReplyButton {
    CGFloat viewWidth = [self getCurViewWidth];
    float replyButton_height = 36;
    
    float evaluateButton_margin = 10;
    
    float replyButton_y = 10;
    ZCRecordListModel *first = self.listArray.firstObject;
    if( (first.isOpen && first.isEvalution == 0) && !self.evaluateModelDic)
    {
        if (first.flag == 3 && ![ZCUICore getUICore].kitInfo.leaveCompleteCanReply) {
            //        已完成 状态，并且 配置 不能回复，
            self.replyButton.hidden = YES;
            self.evaluateButton.hidden = NO;
            self.evaluateButton.frame = CGRectMake(0, replyButton_y, viewWidth, replyButton_height );
        }else{
            //        有评价按钮
            self.replyButton.hidden = NO;
            self.evaluateButton.hidden = NO;
            //        self.replyButton.backgroundColor = UIColor.redColor;
            //        self.evaluateButton.backgroundColor = UIColor.redColor;
            self.replyButton.frame = CGRectMake(0, replyButton_y, viewWidth/3, replyButton_height );
            
            self.evaluateButton.frame = CGRectMake(viewWidth/3 + evaluateButton_margin, replyButton_y, viewWidth/3*2 - evaluateButton_margin*2, replyButton_height );
        }
    }else{
        
        if (first.flag == 3 && ![ZCUICore getUICore].kitInfo.leaveCompleteCanReply) {
            //        已完成 状态，并且 配置 不能回复，
            self.replyButton.hidden = YES;
            self.evaluateButton.hidden = YES;
            
        }else{
            self.replyButton.hidden = NO;
            self.evaluateButton.hidden = YES;
            self.replyButton.frame = CGRectMake(0, replyButton_y, [self getCurViewWidth], replyButton_height );
        }
    }
    
}

-(void)commitScore{
    if(_sheet){
        [_sheet tappedCancel];
    }
    
     ZCRecordListModel *model = self.listArray.firstObject;
    // 去评价
    _sheet = [[ZCUICustomActionSheet alloc] initActionSheet:ServerSatisfcationOrderType Name:@"" Cofig:[ZCUICore getUICore].getLibConfig cView:self.view IsBack:NO isInvitation:1 WithUid:[ZCUICore getUICore].getLibConfig.uid   IsCloseAfterEvaluation:NO Rating:5 IsResolved:YES IsAddServerSatifaction:NO txtFlag:model.txtFlag ticketld:_ticketId ticketScoreInfooList:model.ticketScoreInfooList];
    _sheet.delegate = self;
    [_sheet showInView:self.view];
}

#pragma mark - click
- (void)replyButtonClick {
    
//    如果是横屏 跳转页面
    if (isLandspace) {
        ZCReplyLeaveController *vc = [[ZCReplyLeaveController alloc]init];
        vc.ticketId = _ticketId;
        [self.navigationController pushViewController:vc animated:YES];
        
    }else{
        //    弹出留言
            self.replyLeaveView = [[ZCReplyLeaveView alloc]initActionSheetWithView:self.view];
            self.replyLeaveView.delegate = self;
            self.replyLeaveView.ticketId = _ticketId;
            
            [self.replyLeaveView showInView:self.view];
            
        //
            self.replyLeaveView.imageArr = self.imageArr;
            self.replyLeaveView.imagePathArr = self.imagePathArr;
            self.replyLeaveView.textDesc.text = self.replyStr;
            
            [self.replyLeaveView reloadScrollView];
    }
    


}

#pragma mark - view
-(void)createStarView{
    ZCRecordListModel *first = self.listArray.firstObject;
    if(first.isOpen && first.isEvalution == 0 && !self.evaluateModelDic)
    {
        UIView * bgView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, ScreenWidth, 64 + XBottomBarHeight)];
        bgView.backgroundColor = [ZCUITools zcgetLightGrayBackgroundColor];
        _listTable.tableFooterView = bgView;
        
        
        _commitFootView = [[UIView alloc]initWithFrame:CGRectMake(0, ScreenHeight - 84 - XBottomBarHeight - NavBarHeight, ScreenWidth, 84 + XBottomBarHeight)];
        _commitFootView.backgroundColor = UIColorFromThemeColor(ZCBgSystemWhiteLightDarkColor);

        
        _commitFootView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleTopMargin;
        _commitFootView.autoresizesSubviews = YES;
//        [self.view addSubview:_commitFootView];
        
        // 区尾添加提交按钮 2.7.1改版
        UIButton * commitBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [commitBtn setTitle:ZCSTLocalString(@"服务评价") forState:UIControlStateNormal];
        
        [commitBtn setTitleColor:UIColorFromThemeColor(ZCKeepWhiteColor) forState:UIControlStateNormal];
        [commitBtn setTitleColor:UIColorFromThemeColor(ZCKeepWhiteColor) forState:UIControlStateHighlighted];
        UIImage * img = [ZCUIImageTools zcimageWithColor:[ZCUITools zcgetLeaveSubmitImgColor]];
        [commitBtn setBackgroundImage:img forState:UIControlStateNormal];
        [commitBtn setBackgroundImage:img forState:UIControlStateSelected];
        commitBtn.frame = CGRectMake(ZCNumber(20), 20, ScreenWidth- ZCNumber(40), ZCNumber(44));
        commitBtn.tag = BUTTON_MORE;
        [commitBtn addTarget:self action:@selector(commitScore) forControlEvents:UIControlEventTouchUpInside];
        commitBtn.layer.masksToBounds = YES;
        commitBtn.layer.cornerRadius = 22.f;
        commitBtn.titleLabel.font = ZCUIFont17;
        commitBtn.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleTopMargin;
        commitBtn.autoresizesSubviews = YES;
        [_commitFootView addSubview:commitBtn];
    }else{
        UIView * bgView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 0, 0)];
        _listTable.tableFooterView = bgView;
        
        if(self.commitFootView){
            [self.commitFootView removeFromSuperview];
        }
    }
}


#pragma mark UITableView delegate Start
// 返回section数
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

// 返回section高度
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if(section == 0){
        if(_listArray.count > 0){
            if(_headerView){
                [self changeHeaderStyle];
                return CGRectGetHeight(_headerView.frame);
            }else{
                [self getHeaderViewHeight];
                return CGRectGetHeight(_headerView.frame);
            }
        }
        return 0;
    }else{
        return 114;
    }
    
}




-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
   if(section == 0){
       
        ZCRecordListModel *first = self.listArray.firstObject;
               if((first.isOpen && first.isEvalution == 1) || self.evaluateModelDic)
               {
                   NSString *remarkStr = @"";
//                   NSString *scoreStr = @"";
                   if(self.evaluateModelDic){
                       NSDictionary *dic = self.evaluateModelDic[@"data"];
                       if (dic) {
                           NSDictionary *itemDic = dic[@"item"];
                           if (itemDic) {
//                               scoreStr = zcLibConvertToString(itemDic[@"score"]);
                               remarkStr = zcLibConvertToString(itemDic[@"remark"]);
                           }
                       }
                   }
                   
                   NSString *sting = @"--";

                   ZCRecordListModel * model = _listArray[0];

                   if (remarkStr.length > 0) {
                       sting = remarkStr;
                   }else{
                       if(zcLibConvertToString(model.remark).length > 0){
                           sting = zcLibConvertToString(model.remark);
                       }
                   }
                   
                   NSString *lanStr = ZCSTLocalString(@"评语");
                                      
                   UILabel *conlab = [[UILabel alloc]init];
                   conlab.text = [NSString stringWithFormat:@"%@：%@",lanStr,sting];
                   
                   
                   CGSize textSize = [self autoHeightOfLabel:conlab with: self.listTable.frame.size.width - ZCNumber(40) IsSetFrame:NO];
                                      
                   
                   return ZCNumber(20) + ZCNumber(114) - ZCNumber(18) + textSize.height + ZCNumber(10);
                   
                   
               }
       
       return 20;
    }
    return 0;
}

// 返回section 的View
-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    if(section == 0){
        NSString * str = @"";
        if (self.listArray.count > 0) {
            ZCRecordListModel * model = [_listArray lastObject];
            
            str = zcLibConvertToString(model.content);
        }
        if(_headerView){
            [self changeHeaderStyle];
            return _headerView;
        }
        return [self getHeaderViewHeight];
    }else{
        UIView *view=[[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, 1)];
        view.backgroundColor = [UIColor clearColor];

        return view;
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    if (section == 0) {
        
        ZCRecordListModel *first = self.listArray.firstObject;
        if((first.isOpen && first.isEvalution == 1) || self.evaluateModelDic)
        {
            return [self getHeaderStarViewHeight];
        }else{
            UIView *bgView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, ScreenWidth, 20)];
            bgView.backgroundColor =[ZCUITools zcgetLightGrayDarkBackgroundColor];
            return bgView;
        }
    }
    else {
        return nil;
    }
}


-(void)showMoreAction:(UIButton *)sender{
    if (sender.tag == 1001) {
        isShowHeard = YES;
    }else{
        isShowHeard = NO;
    }
    
    [self.listTable reloadData];
}

// 返回section下得行数
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
//    if(_listArray==nil){
//        return 0;
//    }
    if(section == 0){
        return _listArray.count;
    }
    return 0;
}

// cell
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    ZCLeaveDetailCell *cell = (ZCLeaveDetailCell*)[tableView dequeueReusableCellWithIdentifier:cellmsgDetailIdentifier];
    if (cell == nil) {
        cell = [[ZCLeaveDetailCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellmsgDetailIdentifier];
    }
    if(indexPath.row==_listArray.count-1){
        if ([cell respondsToSelector:@selector(setSeparatorInset:)]) {
            [cell setSeparatorInset:UIEdgeInsetsZero];
        }
        
        if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
            [cell setLayoutMargins:UIEdgeInsetsZero];
        }
        
        if([cell respondsToSelector:@selector(setPreservesSuperviewLayoutMargins:)]){
            [cell setPreservesSuperviewLayoutMargins:NO];
        }
    }
    if ( indexPath.row > _listArray.count -1) {
        return cell;
    }
    
    [cell setBackgroundColor:UIColorFromThemeColor(ZCBgSystemWhiteLightDarkColor)];
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    
    ZCRecordListModel * model = _listArray[indexPath.row];
    
    __weak ZCMsgDetailsVC * saveSelf = self;
    
    [cell initWithData:model IndexPath:indexPath.row count:(int)self.listArray.count];

    [cell setShowDetailClickCallback:^(ZCRecordListModel * _Nonnull model,NSString *urlStr) {
        if (urlStr) {
            ZCUIWebController *webVC = [[ZCUIWebController alloc] initWithURL:urlStr];
            [saveSelf.navigationController pushViewController:webVC animated:YES];
            return;
        }

        NSString *htmlString = model.replyContent;
        if (model.flag == 3) {
            htmlString = model.content;
        }
        ZCUIWebController *webVC = [[ZCUIWebController alloc] initWithURL:htmlString];

        [saveSelf.navigationController pushViewController:webVC animated:YES];
    }];

    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    cell.selected = NO;

    return cell;
}

//-(void)dimissCustomActionSheetPage{
//    _sheet = nil;
//    [ZCUICore getUICore].isDismissSheetPage = YES;
    // 刷新数据
//    [self loadData];
//}


// table 行的高度
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [self tableView:tableView cellForRowAtIndexPath:indexPath];
    return cell.frame.size.height;
}

// table 行的点击事件
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

//设置分割线间距
-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    if((indexPath.row+1) < _listArray.count){
        [self setTableSeparatorInset];
    }
}



#pragma mark UITableView delegate end

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


#pragma mark -- 计算文本高度
-(CGRect)getTextRectWith:(NSString *)str WithMaxWidth:(CGFloat)width  WithlineSpacing:(CGFloat)LineSpacing AddLabel:(UILabel *)label {
    
    [ZCHtmlCore filterHtml:[self filterHtmlImage:str] result:^(NSString * _Nonnull text1, NSMutableArray * _Nonnull arr, NSMutableArray * _Nonnull links) {
        if (text1.length > 0 && text1 != nil) {
            label.attributedText =   [ZCHtmlFilter setHtml:text1 attrs:arr view:label textColor:UIColorFromThemeColor(ZCTextSubColor) textFont:label.font linkColor:[ZCUITools zcgetChatLeftLinkColor]];
        }else{
            label.attributedText =   [[NSAttributedString alloc] initWithString:@""];
        }
        
        CGRect labelF = label.frame;
        label.text = text1;
        CGSize size = [self autoHeightOfLabel:label with:width IsSetFrame:YES];
        
        labelF.size.height = size.height;
        label.frame = labelF;

    }];
    
    
    return label.frame;
}

/**
 计算Label高度
 
 @param label 要计算的label，设置了值
 @param width label的最大宽度
 @param type 是否从新设置宽，1设置，0不设置
 */
- (CGSize )autoHeightOfLabel:(UILabel *)label with:(CGFloat )width IsSetFrame:(BOOL)isSet{
    //Calculate the expected size based on the font and linebreak mode of your label
    // FLT_MAX here simply means no constraint in height
    CGSize maximumLabelSize = CGSizeMake(width, FLT_MAX);
    
    CGSize expectedLabelSize = [label sizeThatFits:maximumLabelSize];// 返回最佳的视图大小
    
    //adjust the label the the new height.
    if (isSet) {
        CGRect newFrame = label.frame;
        newFrame.size.height = expectedLabelSize.height;
        label.frame = newFrame;
        [label updateConstraintsIfNeeded];
    }
    return expectedLabelSize;
}


-(UIView*)getHeaderViewHeight{
    if (_headerView != nil) {
        [_headerView removeFromSuperview];
        _headerView = nil;
    }
    CGFloat tableWidth = self.listTable.frame.size.width;
    
    _headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableWidth, ZCNumber(140))];
    _headerView.backgroundColor = UIColorFromThemeColor(ZCBgSystemWhiteLightDarkColor);
    _headerView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    _headerView.autoresizesSubviews = YES;
    
    _headerTitleLab = [[UILabel alloc] initWithFrame:CGRectMake(20,27, 170, ZCNumber(22))];
    [_headerTitleLab setFont:ZCUIFontBold17];
    [_headerTitleLab setTextAlignment:NSTextAlignmentLeft];
    [_headerTitleLab setTextColor:UIColorFromThemeColor(ZCTextMainColor)];
    _headerTitleLab.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    _headerTitleLab.autoresizesSubviews =  YES;
    [_headerView addSubview:_headerTitleLab];
    
    _headerStateLab = [[UILabel alloc] initWithFrame:CGRectMake(tableWidth - 70, 30,50, 20)];
    [_headerStateLab setBackgroundColor:UIColorFromThemeColor(ZCThemeColor)];
    [_headerStateLab setFont:ZCUIFont12];
    _headerStateLab.layer.cornerRadius = 10.0f;
    [_headerStateLab setTextColor:UIColorFromThemeColor(ZCKeepWhiteColor)];
    [_headerStateLab setTextAlignment:NSTextAlignmentCenter];
    _headerStateLab.layer.masksToBounds = YES;
    _headerStateLab.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
    _headerStateLab.autoresizesSubviews = YES;
    [_headerView addSubview:_headerStateLab];
    

    ZCRecordListModel * model = nil;
    if(_listArray.count > 0){
        model = [_listArray lastObject];
        _headerTitleLab.text = zcLibConvertToString(zcLibDateTransformString(@"yyyy-MM-dd HH:mm:ss", zcLibStringFormateDate(model.timeStr)));
        
        ZCRecordListModel *firstFlag = [_listArray firstObject];
        
        
        switch (firstFlag.flag) {
            case 1:
                _headerStateLab.text =  ZCSTLocalString(@"已创建");
                _headerStateLab.backgroundColor = UIColorFromThemeColor(ZCTextPlaceHolderColor);
                break;
            case 2:
                _headerStateLab.text =  ZCSTLocalString(@"受理中");
                _headerStateLab.backgroundColor = UIColorFromThemeColor(ZCTextNoticeLinkColor);
                break;
            case 3:
                _headerStateLab.text =  ZCSTLocalString(@"已完成");
                _headerStateLab.backgroundColor = UIColorFromThemeColor(ZCThemeColor);
                break;
            default:
                break;
        }
    }
    
    _conlab = [[ZCMLEmojiLabel alloc]initWithFrame:CGRectMake(ZCNumber(20), CGRectGetMaxY(_headerTitleLab.frame) + ZCNumber(8), tableWidth - ZCNumber(40), ZCNumber(50))];
    _conlab.numberOfLines = 0;
    [_conlab setTextColor:UIColorFromThemeColor(ZCTextSubColor)];
    [_conlab setLinkColor:[ZCUITools zcgetChatLeftLinkColor]];
    _conlab.font = ZCUIFont14;
    _conlab.lineSpacing = 4.0f;
    _conlab.delegate = self;
    if(model){
        // 优化卡顿问题，此处希望使用setText，暂未优化
//        _conlab.attributedText = model.contentAttr;
        [_conlab setText:model.content];
        [_conlab setLinkColor:[ZCUITools zcgetChatLeftLinkColor]];
        
        CGRect labelF = _conlab.frame;
    //    conlab.text = text1;
        CGSize size = [self autoHeightOfLabel:_conlab with:CGRectGetWidth(_conlab.frame) IsSetFrame:YES];
        
        labelF.size.height = size.height;
        _conlab.frame = labelF;
    //    conlab.text = ;
        [_headerView addSubview:_conlab];
        
        
        contSize = [self autoHeightOfLabel:_conlab with:tableWidth - ZCNumber(30) IsSetFrame:NO];
    }
    
    
    
    float h = _conlab.frame.origin.y + contSize.height + 10;
    
//    2.8.2 增加客户回复：
    float pics_height = [self addContentFileList:h];
    
    
    _showBtn = [ZCButton buttonWithType:UIButtonTypeCustom];
    _showBtn.frame = CGRectMake([self getCurViewWidth]/2- ZCNumber(120/2), pics_height + contSize.height + ZCNumber(8), 120, ZCNumber(0));
    [_showBtn addTarget:self action:@selector(showMoreAction:) forControlEvents:UIControlEventTouchUpInside];
    _showBtn.tag = 1001;
    _showBtn.type = 2;
    _showBtn.space = ZCNumber(0);
    [_showBtn setContentHorizontalAlignment:UIControlContentHorizontalAlignmentCenter];
    _showBtn.titleLabel.font = ZCUIFont12;
    [_showBtn setTitle:[NSString stringWithFormat:@"%@    ",ZCSTLocalString(@"展开")] forState:UIControlStateNormal];
    [_showBtn setImage:[ZCUITools zcuiGetBundleImage:@"zciocn_arrow_down"] forState:UIControlStateNormal];


//    _showBtn.backgroundColor = [UIColor redColor];
    [_headerView addSubview: _showBtn];
    _showBtn.hidden = YES;
    [_showBtn setTitleColor:UIColorFromThemeColor(ZCThemeColor) forState:UIControlStateNormal];
    
    if (contSize.height > 35 || self.creatRecordListModel.fileList.count > 0) {
        // 添加 展开全文btn
        _showBtn.hidden = NO;
    }
    
    // 线条
    UIView *lineView = [[UIView alloc]initWithFrame:CGRectMake(0,0, tableWidth, 10)];
    lineView.backgroundColor = [ZCUITools zcgetLightGrayDarkBackgroundColor];
    [_headerView addSubview:lineView];
    
    CGFloat y = CGRectGetMaxY(_showBtn.frame)+17;
    if(_showBtn.isHidden){
        y = CGRectGetMaxY(_conlab.frame)+17;
    }
    
    // 线条
    _headerlineView1 = [[UIView alloc]initWithFrame:CGRectMake(0,y, tableWidth, 10)];
    _headerlineView1.backgroundColor = [ZCUITools zcgetLightGrayDarkBackgroundColor];
    UIView *lineView_1 = [[UIView alloc]initWithFrame:CGRectMake(0, 0, tableWidth, 0.5)];
    lineView_1.backgroundColor = [ZCUITools zcgetBackgroundBottomLineColor];
    [_headerlineView1 addSubview:lineView_1];
    [_headerView addSubview:_headerlineView1];
    
    
    UIView *lineView_0 = [[UIView alloc]initWithFrame:CGRectMake(0, 10, tableWidth, 0.5)];
    lineView_0.backgroundColor =  [ZCUITools zcgetBackgroundBottomLineColor];
    
    [_headerView addSubview:lineView_0];
    
    
    
    [self changeHeaderStyle];
    
    return _headerView;
}

-(void)changeHeaderStyle{
    CGFloat tableWidth = self.listTable.frame.size.width;
    ZCRecordListModel * model = nil;
    if(_listArray.count > 0){
        model = [_listArray lastObject];
        _headerTitleLab.text = zcLibConvertToString(zcLibDateTransformString(@"yyyy-MM-dd HH:mm:ss", zcLibStringFormateDate(model.timeStr)));
        
        ZCRecordListModel *firstFlag = [_listArray firstObject];
        
        
        switch (firstFlag.flag) {
            case 1:
                _headerStateLab.text =  ZCSTLocalString(@"已创建");
                _headerStateLab.backgroundColor = UIColorFromThemeColor(ZCTextPlaceHolderColor);
                break;
            case 2:
                _headerStateLab.text =  ZCSTLocalString(@"受理中");
                _headerStateLab.backgroundColor = UIColorFromThemeColor(ZCTextNoticeLinkColor);
                break;
            case 3:
                _headerStateLab.text =  ZCSTLocalString(@"已完成");
                _headerStateLab.backgroundColor = UIColorFromThemeColor(ZCThemeColor);
                break;
            default:
                break;
        }
    }
   
    CGSize s = [_headerStateLab.text sizeWithAttributes:@{NSFontAttributeName:_headerStateLab.font}];
    if(s.width > 50){
        _headerStateLab.frame = CGRectMake(tableWidth - 20 - s.width-10, 30, s.width+10, ZCNumber(20));
    }
    
    if (!_showBtn.hidden) {
        if (isShowHeard) {
            CGFloat pics_height = 0;
            if(_headerMoreFileView!=nil){
                pics_height =  CGRectGetHeight(_headerMoreFileView.frame);
                _headerMoreFileView.hidden = NO;
            }
            NSString *clickText = [NSString stringWithFormat:@"%@    ",ZCSTLocalString(@"收起")];
            CGSize s = [clickText sizeWithFont:ZCUIFont12];
            CGFloat textwidth = s.width + 25;
            
            // 显示全部
            _showBtn.frame = CGRectMake(tableWidth/2-textwidth/2, CGRectGetMaxY(_conlab.frame) + ZCNumber(8) + pics_height,textwidth, ZCNumber(20));
//            [self getTextRectWith:str WithMaxWidth:tableWidth - ZCNumber(30) WithlineSpacing:6 AddLabel:conlab];
            //展开之后
            _conlab.frame = CGRectMake(ZCNumber(15), CGRectGetMaxY(_headerTitleLab.frame) + ZCNumber(10) , contSize.width, contSize.height);
            _showBtn.tag = 1002;
            _showBtn.space = ZCNumber(1);
            [_showBtn setTitle:clickText forState:UIControlStateNormal];
            [_showBtn setImage:[ZCUITools zcuiGetBundleImage:@"zciocn_arrow_up"] forState:UIControlStateNormal];
            CGRect sf = _showBtn.frame;
            sf.origin.y = CGRectGetMaxY(_conlab.frame) + ZCNumber(20) + pics_height;
            _showBtn.frame = sf;
            for (UIView *view in [_headerView subviews]) {
                 if ([view isKindOfClass:[ZCReplyFileView class]]) {
                     view.hidden = NO;
                 }
             }
        }else{
            if(_headerMoreFileView!=nil){
                _headerMoreFileView.hidden = YES;
            }
            // 收起之后
            _conlab.frame = CGRectMake(ZCNumber(20), CGRectGetMaxY(_headerTitleLab.frame) + ZCNumber(8), tableWidth - ZCNumber(40), ZCNumber(40));
            NSString *clickText = [NSString stringWithFormat:@"%@    ",ZCSTLocalString(@"展开")];
            CGSize s = [clickText sizeWithFont:ZCUIFont12];
            CGFloat textwidth = s.width + 25;
            _showBtn.frame = CGRectMake(tableWidth/2 - textwidth/2, CGRectGetMaxY(_conlab.frame) + ZCNumber(8), textwidth, ZCNumber(20));
            _showBtn.tag = 1001;
            _showBtn.space = ZCNumber(1);
            [_showBtn setTitle:[NSString stringWithFormat:@"%@    ",ZCSTLocalString(@"展开")] forState:UIControlStateNormal];
            [_showBtn setImage:[ZCUITools zcuiGetBundleImage:@"zciocn_arrow_down"] forState:UIControlStateNormal];
            
            for (UIView *view in [_headerView subviews]) {
                 if ([view isKindOfClass:[ZCReplyFileView class]]) {
                     view.hidden = YES;
                 }
             }
            
        }
    }
    CGFloat y = CGRectGetMaxY(_showBtn.frame)+17;
    if(_showBtn.isHidden){
        y = CGRectGetMaxY(_conlab.frame)+17;
    }
    // 线条
    _headerlineView1.frame = CGRectMake(0,y, tableWidth, 10);
    
    CGRect hf = _headerView.frame;
    hf.size.height = y + 10;
    _headerView.frame = hf;
}

-(CGFloat)addContentFileList:(CGFloat) topY{
    CGFloat  pics_height = 0;
    if(self.creatRecordListModel.fileList.count > 0) {
         
         float fileBgView_margin_left = 20;
         float fileBgView_margin_top = 10;
         float fileBgView_margin_right = 20;
         float fileBgView_margin = 10;
         
 //      宽度固定为  （屏幕宽度 - 60)/3
//            CGSize fileViewRect = CGSizeMake((self.view.frame.size.width - 60)/3, 85);
         
 //      算一下每行多少个 ，
        float nums = 3;//(self.view.frame.size.width - fileBgView_margin_left - fileBgView_margin_right)/(fileViewRect.width + fileBgView_margin);
         NSInteger numInt = floor(nums);

        CGSize fileViewRect = CGSizeMake((self.view.frame.size.width - fileBgView_margin_left - fileBgView_margin_right - fileBgView_margin*2)/3, 85);
         
 //      行数：
         NSInteger rows = ceil(self.creatRecordListModel.fileList.count/(float)numInt);
        _headerMoreFileView = [[UIView alloc] initWithFrame:CGRectMake(fileBgView_margin_left, topY+fileBgView_margin_top, self.view.frame.size.width - fileBgView_margin_left - fileBgView_margin_right, 0)];
         
         for (int i = 0 ; i < self.creatRecordListModel.fileList.count;i++) {
             NSDictionary *modelDic = self.creatRecordListModel.fileList[i];
             
             //           当前列数
             NSInteger currentColumn = i%numInt;
 //           当前行数
             NSInteger currentRow = i/numInt;
             
             float x = (fileViewRect.width + fileBgView_margin)*currentColumn;
             float y = (fileViewRect.height + fileBgView_margin)*currentRow;
             float w = fileViewRect.width;
             float h = fileViewRect.height;
             
             ZCReplyFileView *fileBgView = [[ZCReplyFileView alloc]initWithDic:modelDic withFrame:CGRectMake(x, y, w, h)];
             fileBgView.layer.cornerRadius = 4;
             fileBgView.layer.masksToBounds = YES;
             
             [fileBgView setClickBlock:^(NSDictionary * _Nonnull modelDic, UIImageView * _Nonnull imgView) {
                NSString *fileType = modelDic[@"fileType"];
                NSString *fileUrlStr = modelDic[@"fileUrl"];
 //                NSArray *imgArray = [[NSArray alloc]initWithObjects:fileUrlStr, nil];
                 if ([fileType isEqualToString:@"jpg"] ||
                     [fileType isEqualToString:@"png"] ||
                     [fileType isEqualToString:@"gif"] ) {
                     
                     //     图片预览
                     
                     UIImageView *picView = imgView;
                     CALayer *calayer = picView.layer.mask;
                     [picView.layer.mask removeFromSuperlayer];
                     
                     ZCUIXHImageViewer *xh=[[ZCUIXHImageViewer alloc] initWithImageViewerWillDismissWithSelectedViewBlock:^(ZCUIXHImageViewer *imageViewer, UIImageView *selectedView) {
                         
                     } didDismissWithSelectedViewBlock:^(ZCUIXHImageViewer *imageViewer, UIImageView *selectedView) {
                         
                         selectedView.layer.mask = calayer;
                         [selectedView setNeedsDisplay];
                     } didChangeToImageViewBlock:^(ZCUIXHImageViewer *imageViewer, UIImageView *selectedView) {
                         
                     }];
                     
                     NSMutableArray *photos = [[NSMutableArray alloc] init];
                     [photos addObject:picView];
                     xh.disableTouchDismiss = NO;
                     [xh showWithImageViews:photos selectedView:picView];
                     
                     
                 }
                 else if ([fileType isEqualToString:@"mp4"]){
                     NSURL *imgUrl = [NSURL URLWithString:fileUrlStr];
                     
                      UIWindow *window = [[ZCToolsCore getToolsCore] getCurWindow];
                      ZCVideoPlayer *player = [[ZCVideoPlayer alloc] initWithFrame:window.bounds withShowInView:window url:imgUrl Image:nil];
                      [player showControlsView];
                     
                 }
                 
                 else{
                     ZCLibMessage *message = [[ZCLibMessage alloc]init];
                     ZCLibRich *rich = [[ZCLibRich alloc]init];
                     rich.richmoreurl = fileUrlStr;
                     
                     /**
                     * 13 doc文件格式
                     * 14 ppt文件格式
                     * 15 xls文件格式
                     * 16 pdf文件格式
                     * 17 mp3文件格式
                     * 18 mp4文件格式
                     * 19 压缩文件格式
                     * 20 txt文件格式
                     * 21 其他文件格式
                     */
                     if ([fileType isEqualToString:@"doc"] || [fileType isEqualToString:@"docx"]) {
                         rich.fileType = 13;
                     }
                     else if ([fileType isEqualToString:@"ppt"]){
                         rich.fileType = 14;
                     }
                     else if ([fileType isEqualToString:@"xls"] || [fileType isEqualToString:@"xlsx"]){
                         rich.fileType = 15;
                     }
                     else if ([fileType isEqualToString:@"pdf"]){
                         rich.fileType = 16;
                     }
                     else if ([fileType isEqualToString:@"mp3"]){
                         rich.fileType = 17;
                     }
 //                    else if ([fileType isEqualToString:@"mp4"]){
 //                        rich.fileType = 18;
 //                    }
                     else if ([fileType isEqualToString:@"zip"]){
                         rich.fileType = 19;
                     }
                     else if ([fileType isEqualToString:@"txt"]){
                         rich.fileType = 20;
                     }
                     else{
                         rich.fileType = 21;
                     }
                     
                     
                     message.richModel = rich;
                     
                     ZCDocumentLookController *docVc = [[ZCDocumentLookController alloc]init];
                     docVc.message = message;
                     [self.navigationController pushViewController:docVc animated:YES];
                     
                 }
                 
                 
             }];
             [_headerMoreFileView addSubview:fileBgView];
         }
         
         pics_height =  (fileViewRect.height + fileBgView_margin_top)*rows;
        
        CGRect hff = _headerMoreFileView.frame;
        hff.size.height = pics_height;
        _headerMoreFileView.frame = hff;
        [_headerView addSubview:_headerMoreFileView];
     }
    
    
    return pics_height;
}


-(UIView*)getHeaderStarViewHeight{
    if (_footView != nil) {
        [_footView removeFromSuperview];
        _footView = nil;
    }
    if(_listArray.count == 0){
        return nil;
    }

    [self createStarView];
    
    NSString *remarkStr = @"";
    NSString *scoreStr = @"";
    if(self.evaluateModelDic){
        NSDictionary *dic = self.evaluateModelDic[@"data"];
        if (dic) {
            NSDictionary *itemDic = dic[@"item"];
            if (itemDic) {
                scoreStr = zcLibConvertToString(itemDic[@"score"]);
                remarkStr = zcLibConvertToString(itemDic[@"remark"]);
            }
        }
    }
    
    ZCRecordListModel * model = _listArray[0];
    
    _footView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.listTable.frame.size.width, ZCNumber(114))];
    _footView.backgroundColor = [ZCUITools zcgetLightGrayBackgroundColor];
    
    UIView *bgView_1 = [[UIView alloc]initWithFrame:CGRectMake(0, 0, ScreenWidth, 10)];
    bgView_1.backgroundColor = UIColorFromThemeColor(ZCBgLineColor);
    [_footView addSubview:bgView_1];
    
    UIView *lineView = [[UIView alloc]initWithFrame:CGRectMake(0, 10, self.listTable.frame.size.width, 0.5)];
    lineView.backgroundColor = [ZCUITools zcgetCommentButtonLineColor];
    [_footView addSubview:lineView];
    
    UILabel *titleLab = [[UILabel alloc] initWithFrame:CGRectMake(ZCNumber(21), ZCNumber(26), self.listTable.frame.size.width - ZCNumber(40), ZCNumber(24))];
    [titleLab setFont:ZCUIFontBold14];
    titleLab.text =ZCSTLocalString(@"我的服务评价");
    [titleLab setTextAlignment:NSTextAlignmentLeft];
    [titleLab setTextColor:UIColorFromThemeColor(ZCTextMainColor)];
    [_footView addSubview:titleLab];
    
    UILabel * labScore = [[UILabel alloc]initWithFrame:CGRectMake(ZCNumber(20), CGRectGetMaxY(titleLab.frame) + ZCNumber(5), 36, ZCNumber(18))];
    labScore.numberOfLines = 0;
    labScore.textColor = UIColorFromThemeColor(ZCTextSubColor);
    labScore.font = ZCUIFont12;
    labScore.text = [NSString stringWithFormat:@"%@：",ZCSTLocalString(@"评分")];
    [_footView addSubview:labScore];
    
    
    ZCUIRatingView *startView = [[ZCUIRatingView alloc] initWithFrame:CGRectMake(54, CGRectGetMaxY(titleLab.frame)+5, 140, 18)];
    [startView setImagesDeselected:@"zcicon_star_unsatisfied" partlySelected:@"zcicon_star_satisfied" fullSelected:@"zcicon_star_satisfied" andDelegate:self];
    startView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin;
    
    if (scoreStr.length > 0) {
        [startView displayRating:[scoreStr floatValue]];
    }else{
        [startView displayRating:[model.score floatValue]];
    }
    
    startView.backgroundColor = [UIColor clearColor];
    startView.userInteractionEnabled = NO;
    [_footView addSubview:startView];
    
    
    if(isRTLLayout()){
        [titleLab setTextAlignment:NSTextAlignmentRight];
        [[ZCToolsCore getToolsCore] setRTLFrame:labScore];
        [[ZCToolsCore getToolsCore] setRTLFrame:startView];
    }
    
    
    UILabel * conlab = [[UILabel alloc]initWithFrame:CGRectMake(ZCNumber(20), CGRectGetMaxY(labScore.frame) + ZCNumber(7), self.listTable.frame.size.width - ZCNumber(40), ZCNumber(18))];
    conlab.numberOfLines = 0;
    conlab.textColor = UIColorFromThemeColor(ZCTextSubColor);
    conlab.font = ZCUIFont12;
    NSString *sting = @"--";

    if (remarkStr.length > 0) {
        sting = remarkStr;
    }else{
        if(zcLibConvertToString(model.remark).length > 0){
            sting = zcLibConvertToString(model.remark);
        }
    }
    
    NSString *lanStr = ZCSTLocalString(@"评语");
        
    conlab.text = [NSString stringWithFormat:@"%@：%@",lanStr,sting];
    
    [_footView addSubview:conlab];
    [conlab setTextAlignment:NSTextAlignmentLeft];
    if(isRTLLayout()){
           [conlab setTextAlignment:NSTextAlignmentRight];
    }
        
    
    CGSize textSize = [self autoHeightOfLabel:conlab with: self.listTable.frame.size.width - ZCNumber(40) IsSetFrame:NO];
    
    conlab.frame = CGRectMake(ZCNumber(20), CGRectGetMaxY(labScore.frame) + ZCNumber(7), self.listTable.frame.size.width - ZCNumber(40), textSize.height);
    
    _footView.frame = CGRectMake(0, 0, self.listTable.frame.size.width, ZCNumber(114) - ZCNumber(18) + textSize.height);
    
    
    // 线条
    UIView *lineView_1 = [[UIView alloc]initWithFrame:CGRectMake(0, _footView.frame.size.height - 1, self.listTable.frame.size.width, 0.5)];
    lineView_1.backgroundColor = [ZCUITools zcgetCommentButtonLineColor];
    [_footView addSubview:lineView_1];
    
    UIView *bgView = [[UIView alloc]initWithFrame:CGRectMake(0, CGRectGetMaxY(lineView_1.frame), ScreenWidth, 40)];
    bgView.backgroundColor = UIColorFromThemeColor(ZCBgLineColor);
    [_footView addSubview:bgView];

    return _footView;
}




-(NSString *)filterHtmlImage:(NSString *)tmp{
    
    NSString *picStr = [NSString stringWithFormat:@"[%@]",ZCSTLocalString(@"图片")];
    
    NSRegularExpression *regularExpression = [NSRegularExpression regularExpressionWithPattern:@"<img.*?/>" options:0 error:nil];
    tmp  = [regularExpression stringByReplacingMatchesInString:tmp options:0 range:NSMakeRange(0, tmp.length) withTemplate:picStr];
    
    tmp = [tmp stringByReplacingOccurrencesOfString:@"<br />" withString:@"\n"];
    tmp = [tmp stringByReplacingOccurrencesOfString:@"<br/>" withString:@"\n"];
    tmp = [tmp stringByReplacingOccurrencesOfString:@"<br>" withString:@"\n"];
    tmp = [tmp stringByReplacingOccurrencesOfString:@"<BR/>" withString:@"\n"];
    tmp = [tmp stringByReplacingOccurrencesOfString:@"<BR />" withString:@"\n"];
    tmp = [tmp stringByReplacingOccurrencesOfString:@"<p>" withString:@"\n"];
    tmp = [tmp stringByReplacingOccurrencesOfString:@"</p>" withString:@" "];
    tmp = [tmp stringByReplacingOccurrencesOfString:@"&nbsp;" withString:@" "];
    while ([tmp hasPrefix:@"\n"]) {
        tmp=[tmp substringWithRange:NSMakeRange(1, tmp.length-1)];
    }
    return tmp;
    
}

#pragma mark - 评论返回结果
- (void)actionSheetClickWithDic:(NSDictionary *)modelDic{
    self.evaluateModelDic = modelDic;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        ZCRecordListModel *first = self.listArray.firstObject;
        first.isEvalution = 1;
        
        [self loadData];
        
        NSString *key = [NSString stringWithFormat:@"TicketKEY_%@",zcLibConvertToString(_ticketId)];
        [ZCLocalStore removeObjectByKey:key];
    });
}

#pragma delegate
// 赋值的时候，不执行
-(void)ratingChanged:(float)newRating{

}

-(void)ratingChangedWithTap:(float)newRating{
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/


#pragma mark - ZCReplyLeaveView delegate

- (void)replyLeaveViewPickImg:(NSInteger )buttonIndex {
//    [self.replyLeaveView tappedCancel:YES];
    
    
    self.zc_imagepicker = nil;
    self.zc_imagepicker = [[UIImagePickerController alloc]init];
    self.zc_imagepicker.delegate = self;
    _zc_imagepicker.mediaTypes = [NSArray arrayWithObjects:@"public.movie", @"public.image", nil];
    self.zc_imagepicker.modalPresentationStyle = UIModalPresentationFullScreen;
    [ZCSobotCore getPhotoByType:buttonIndex byUIImagePickerController:_zc_imagepicker Delegate:self];
    
}

- (void)replyLeaveViewPreviewImg:(UIButton *)button{
    NSInteger currentInt = button.tag - 100;

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
        
        ZCUIXHImageViewer *xh=[[ZCUIXHImageViewer alloc] initWithImageViewerWillDismissWithSelectedViewBlock:^(ZCUIXHImageViewer *imageViewer, UIImageView *selectedView) {
            
        } didDismissWithSelectedViewBlock:^(ZCUIXHImageViewer *imageViewer, UIImageView *selectedView) {
            
            selectedView.layer.mask = calayer;
            [selectedView setNeedsDisplay];
        } didChangeToImageViewBlock:^(ZCUIXHImageViewer *imageViewer, UIImageView *selectedView) {
            
        }];
        
        NSMutableArray *photos = [[NSMutableArray alloc] init];
        [photos addObject:picView];
        xh.disableTouchDismiss = NO;
        [xh showWithImageViews:photos selectedView:picView];
    }
    
}

- (void)closeWithReplyStr:(NSString *)replyStr{
    self.replyStr = replyStr;
    
}

- (void)replyLeaveViewDeleteImg:(NSInteger )buttonIndex{
    NSInteger currentInt = buttonIndex - 100;
    if(_imageArr && _imageArr.count > currentInt){
        [_imageArr removeObjectAtIndex:currentInt];
    }
    if(_imagePathArr && _imagePathArr.count > currentInt){
        [_imagePathArr removeObjectAtIndex:currentInt];
    }
    
    self.replyLeaveView.imagePathArr = self.imagePathArr;
    self.replyLeaveView.imageArr = self.imageArr;
    [self.replyLeaveView reloadScrollView];
    
    
}

- (void)replySuccess{
    
    [_imageArr removeAllObjects];
    [_imagePathArr removeAllObjects];
//    [self.replyLeaveView reloadScrollView];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [[ZCUIToastTools shareToast] showToast:ZCSTLocalString(@"提交成功") duration:1.0f view:self.view position:ZCToastPositionCenter Image:[ZCUITools zcuiGetBundleImage:@"zcicon_successful"]];
    });
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
       [self loadData];
    });
    
    
}


#pragma mark - UIImagePickerControllerDelegate
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker{
    [picker dismissViewControllerAnimated:YES completion:^{
        
    }];
}


-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    __weak  ZCMsgDetailsVC *_myselft  = self;
    [ZCSobotCore imagePickerController:_zc_imagepicker didFinishPickingMediaWithInfo:info WithView:self.view Delegate:self block:^(NSString *filePath, ZCMessageType type, NSDictionary *duration) {
        
        if(type == ZCMessageTypePhoto){
            [_myselft updateloadFile:filePath type:ZCMessageTypePhoto dict:info];
        }else{
            [_myselft converToMp4:duration withInfoDic:info];
        }
    }];
}


-(void)updateloadFile:(NSString *)filePath type:(ZCMessageType) type dict:(NSDictionary *) cover{

    __block  ZCMsgDetailsVC *safeSelf  = self;
//        [ZCSobotCore imagePickerController:_zc_imagepicker didFinishPickingMediaWithInfo:cover WithView:self.view Delegate:self block:^(NSString *filePath, ZCMessageType type, NSDictionary *dict) {

            [[[ZCUICore getUICore] getAPIServer] fileUploadForLeave:filePath config:[self getCurConfig] start:^{
                [[ZCUIToastTools shareToast] showProgress:[NSString stringWithFormat:@"%@...",ZCSTLocalString(@"上传中")]  with:safeSelf.view];
            } success:^(NSString *fileURL, ZCNetWorkCode code) {

                [[ZCUIToastTools shareToast] dismisProgress];
                if (zcLibIs_null(_imageArr)) {
                    safeSelf.imageArr = [NSMutableArray arrayWithCapacity:0];
                }
                if (zcLibIs_null(_imagePathArr)) {
                    safeSelf.imagePathArr = [NSMutableArray arrayWithCapacity:0];
                }
                [safeSelf.imagePathArr addObject:filePath];

                NSDictionary * dic = @{@"fileUrl":fileURL};
    //            ZCUploadImageModel * item = [[ZCUploadImageModel alloc]initWithMyDict:dic];
                
                if(type == ZCMessageTypeVideo){
                    dic = @{@"cover":cover[@"cover"],@"fileUrl":fileURL};
                    [safeSelf.imageArr addObject:dic];
//
                }else{
                    [safeSelf.imageArr addObject:dic];
                }
                
                safeSelf.replyLeaveView.imagePathArr = safeSelf.imagePathArr;
                safeSelf.replyLeaveView.imageArr = safeSelf.imageArr;
                [safeSelf.replyLeaveView reloadScrollView];
    ////            [_listTable reloadData];
    //            [_myself reloadScrollView];

            } fail:^(ZCNetWorkCode errorCode) {
                [[ZCUIToastTools shareToast] showToast:ZCSTLocalString(@"网络错误，请检查网络后重试") duration:1.0f view:safeSelf.view position:ZCToastPositionCenter];
            }];

//        }];
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

    __weak  ZCMsgDetailsVC *keyboardSelf  = self;
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


#pragma mark EmojiLabel链接点击事件
// 链接点击
-(void)attributedLabel:(ZCTTTAttributedLabel *)label didSelectLinkWithURL:(NSURL *)url{
    //        链接处理：
    [[ZCToolsCore getToolsCore] dealWithLinkClickWithLick:url.absoluteString viewController:self];
    

}

@end
