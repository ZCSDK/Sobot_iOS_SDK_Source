//
//  ZCReplyLeaveController.m
//  SobotKit
//
//  Created by 张新耀 on 2019/12/3.
//  Copyright © 2019 zhichi. All rights reserved.
//

#import "ZCReplyLeaveController.h"

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
#import "ZCOrderModel.h"

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
#import "ZCLibCommon.h"
#import "ZCPlatformTools.h"

#import "ZCUICore.h"
#import "ZCUIImageTools.h"

#import "ZCHtmlCore.h"
#import "ZCHtmlFilter.h"

#import <AVFoundation/AVFoundation.h>

#import "ZCToolsCore.h"

@interface ZCReplyLeaveController ()<UITextFieldDelegate,UITextViewDelegate,UIGestureRecognizerDelegate,UINavigationControllerDelegate,ZCMLEmojiLabelDelegate,UIScrollViewDelegate,UIImagePickerControllerDelegate,ZCXJAlbumDelegate,UITableViewDataSource,UITableViewDelegate,ZCActionSheetDelegate,ZCOrderCreateCellDelegate>
{
 
    
    CGRect scFrame  ;
    
    void(^CloseBlock)();// 直接退出
    
    BOOL isLandScape ; // 是否是横屏
    

    // 链接点击
    void (^LinkedClickBlock) (NSString *url);
    
    // 呼叫的电话号码
    NSString                    *callURL;
    
    NSMutableArray  *imageURLArr;

    
    CGPoint        contentoffset;// 记录list的偏移量

    
    UIView * lmsView;// 留言成功后 提示页面
    
    NSString *_msgTxt;
}


@property (nonatomic, assign) BOOL isSend;
/** 系统相册相机图片 */
@property (nonatomic,strong) UIImagePickerController *zc_imagepicker;
@property (nonatomic,strong) ZCOrderModel *model;
@property (nonatomic,strong) UITableView * listTable;

@property (nonatomic,strong) NSMutableArray * listArray;

@property(nonatomic,strong)NSMutableArray   *imageArr;

@property (nonatomic,strong) NSMutableArray * imagePathArr;// 存储本地图片路径
@property(nonatomic,strong)NSMutableArray   *imageReplyArr;

@property(nonatomic,strong)UITextView       *tempTextView;
@property(nonatomic,strong)UITextField      *tempTextField;
@property(nonatomic,assign) BOOL isReplyPhoto;// 是否是回复的图片



@end

@implementation ZCReplyLeaveController

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}



- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    if ([ZCUICore getUICore].kitInfo.navcBarHidden) {
        self.navigationController.navigationBarHidden = YES;
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [ZCUICore getUICore].kitInfo.navcBarHidden = self.navigationController.navigationBar.isHidden;
    

    // Do any additional setup after loading the view.
//    [self.navigationController setNavigationBarHidden:YES];
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    if ([ZCUICore getUICore].kitInfo.navcBarHidden) {
        self.navigationController.navigationBarHidden = YES;
        self.navigationController.navigationBar.translucent = NO;
    }
    
//    if (self.navigationController.navigationBarHidden) {
        self.navigationController.navigationBar.translucent = NO;
//    }
    
    if(!self.navigationController.navigationBarHidden){
        [self setNavigationBarStyle];
        self.title = [NSString stringWithFormat:@"%@%@",ZCSTLocalString(@"留言"),ZCSTLocalString(@"回复")];
       
        [self.navigationController.navigationBar setTitleTextAttributes:@{NSFontAttributeName:[ZCUITools zcgetTitleFont],NSForegroundColorAttributeName:[ZCUITools zcgetTopViewTextColor]}];
    }else{
        [self createTitleView];
        self.titleLabel.text = [NSString stringWithFormat:@"%@%@",ZCSTLocalString(@"留言"),ZCSTLocalString(@"回复")];
        
        // 提交 的button 2.7.1 页面改版 位置改变
        [self.moreButton setImage:nil forState:UIControlStateNormal];
        [self.moreButton setImage:nil forState:UIControlStateHighlighted];
        self.moreButton.tag = 1002;
    }
   
    
    self.view.backgroundColor = [ZCUITools zcgetLightGrayDarkBackgroundColor];
    _listArray = [[NSMutableArray alloc] init];

    // 添加选项卡
    CGFloat Y = 0;
    if (self.navigationController.navigationBarHidden) {
        Y = NavBarHeight;
    }
    
    
    // 获取用户初始化配置参数  添加子页面
    [self customLayoutSubviewsWith:[ZCUICore getUICore].kitInfo];
    _isSend = NO;
    
    // 布局子页面
    [self refreshViewData];
    
    _model =  [[ZCOrderModel alloc]init];
    
}

#pragma mark --- 选项卡 end -------

-(ZCLibConfig *)getCurConfig{
    return [[ZCPlatformTools sharedInstance] getPlatformInfo].config;
}



#pragma mark -- 数据刷新
-(void)refreshViewData{
    
    
    [_listArray removeAllObjects];
    //    NSDictionary *dict = [ZCJSONDataTools getObjectData:_model];
    // dictType 0，特殊行   1 单行文本 2 多行文本 3 日期 4 时间 5 数值 6 下拉列表 7 复选框 8 单选框 9 级联字段
//    dictName
    // propertyType == 1是自定义字段，0固定字段, 3不可点击
//  code
    
//    NSMutableArray *arr0 = [[NSMutableArray alloc] init];

    
//    NSString * text = ZCSTLocalString(@"请输入标题（必填）");
//    NSString * title = ZCSTLocalString(@"标题*");
//
//    [arr0 addObject:@{@"code":@"1",
//                      @"dictName":@"ticketTitle",
//                      @"dictDesc":title,
//                      @"placeholder":text,
//                      @"dictValue":zcLibConvertToString(_model.ticketTitle),
//                      @"dictType":@"1",
//                      @"propertyType":@"0"
//    }];
//
//    if (arr0.count>0) {
//        [_listArray addObject:@{@"sectionName":@"",@"arr":arr0}];
//    }
//
    
    
    NSMutableArray *arr3 = [[NSMutableArray alloc] init];
    [arr3 addObject:@{@"code":@"1",
                      @"dictName":@"ticketReplyContent",
                      @"dictDesc":@"问题描述",
                      @"placeholder":@"",//  libConfig.msgTmp
                      @"dictValue":zcLibConvertToString(_model.ticketDesc),
                      @"dictType":@"0",
                      @"propertyType":@"0"
                      }];
    [_listArray addObject:@{@"sectionName":@"回复",@"arr":arr3}];
    

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
        viewController.navigationController.navigationBar.translucent = NO;
        viewController.edgesForExtendedLayout = UIRectEdgeNone;
        return;
    }
    
    id<UIViewControllerTransitionCoordinator> tc = navigationController.topViewController.transitionCoordinator;
    __weak ZCReplyLeaveController *safeVC = self;
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
}


-(void)keyboardHide:(NSNotification*)notification{
    float animationDuration = [[[notification userInfo] valueForKey:UIKeyboardAnimationDurationUserInfoKey] floatValue];
    [UIView beginAnimations:@"bottomBarDown" context:nil];
    [UIView setAnimationDuration:animationDuration];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
    [UIView commitAnimations];
}



#pragma mark -- 提交事件
-(IBAction)buttonClick:(UIButton *) sender{
    if(sender.tag == BUTTON_MORE){
        // 提交留言内容
        if (zcLibTrimString(_model.ticketDesc).length<=0) {
            [[ZCUIToastTools shareToast] showToast:ZCSTLocalString(@"回复内容不能为空")  duration:1.0f view:self.view position:ZCToastPositionCenter];
            return;
        }
        // 留言不能大于3000字
        if (_model.ticketDesc.length >3000) {
//            [[ZCUIToastTools shareToast] showToast:ZCSTLocalString(@"问题描述，最多只能输入3000字符") duration:1.0f view:self.view position:ZCToastPositionCenter];
            return;
        }
        
        
        [self UpLoadWith];
        [self allHideKeyBoard];
    }
    
    // 返回的事件
    if(sender.tag == BUTTON_BACK){
        [self backAction];
    }
    
}



// 提交请求
- (void)UpLoadWith{
    if(_isSend){
        return;
    }
    _isSend = YES;
    
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    [dic setValue:zcLibConvertToString(_model.ticketDesc) forKey:@"replyContent"];
    [dic setObject:zcLibConvertToString(_ticketId) forKey:@"ticketId"];
    [dic setObject:zcLibConvertToString([self getCurConfig].companyID) forKey:@"companyId"];
    if(_imageArr.count>0){
        NSString *fileStr = @"";
        for (NSDictionary *model in _imageArr) {
            fileStr = [fileStr stringByAppendingFormat:@"%@;",zcLibConvertToString(model[@"fileUrl"])];
        }
        
        fileStr = [fileStr substringToIndex:fileStr.length-1];
        [dic setObject:zcLibConvertToString(fileStr) forKey:@"fileStr"];
    }

    __block ZCReplyLeaveController *saveSelf = self;
    [[ZCLibServer getLibServer] replyLeaveMessage:[self getCurConfig] replayParam:dic start:^{
        
    } success:^(NSDictionary *dict, NSMutableArray *itemArray, ZCNetWorkCode sendCode) {
        _isSend = NO;
        // 回复成功
        [[ZCUIToastTools shareToast] showToast:ZCSTLocalString(@"客服已经成功收到您的问题，请耐心等待") duration:1.0f view:saveSelf.view position:ZCToastPositionCenter];
        [self backAction];
    } failed:^(NSString *errorMessage, ZCNetWorkCode errorCode) {
        _isSend = NO;
    }];
    
  
}

/**
 *  设置UITableView分割线空隙
 */
-(void)setTableSeparatorInset{
    UIEdgeInsets inset = UIEdgeInsetsMake(0, 10, 0, 0);
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
   
    
    
    // 计算Y值
    CGFloat startY = 0;
    if (self.navigationController.navigationBarHidden) {
       startY = NavBarHeight;
    }
    if ([ZCUICore getUICore].kitInfo.navcBarHidden) {
       startY = NavBarHeight;
    }
    
    CGFloat scrollHeight = [self getCurViewHeight] -startY - XBottomBarHeight;
    
   
    _listTable = [[UITableView alloc]initWithFrame:CGRectMake(0, startY + 1, [self getCurViewWidth], scrollHeight) style:UITableViewStyleGrouped];
    _listTable.backgroundColor = [UIColor clearColor];
    _listTable.dataSource = self;
    _listTable.delegate = self;
//    _listTable.bounces = YES;
    _listTable.layer.masksToBounds = YES;
    _listTable.autoresizesSubviews = YES;
    _listTable.showsVerticalScrollIndicator = NO;
    _listTable.autoresizingMask =  UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    [self.view addSubview:_listTable];
    [_listTable registerClass:[ZCOrderCheckCell class] forCellReuseIdentifier:cellCheckIdentifier];
    [_listTable registerClass:[ZCOrderContentCell class] forCellReuseIdentifier:cellOrderContentIdentifier];
    [_listTable registerClass:[ZCOrderEditCell class] forCellReuseIdentifier:cellEditIdentifier];
    [_listTable registerClass:[ZCOrderOnlyEditCell class] forCellReuseIdentifier:cellOrderSingleIdentifier];
    [_listTable setSeparatorColor:[ZCUITools zcgetCommentButtonLineColor]];
    [self setTableSeparatorInset];
    // 关闭安全区域，否则UITableViewCell横屏时会是全屏的宽
    NSString *version = [UIDevice currentDevice].systemVersion;
    if (version.doubleValue >= 11.0) {
        [_listTable setInsetsContentViewsToSafeArea:NO];
    }
    
    UITapGestureRecognizer *gestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapHideKeyboard)];
    gestureRecognizer.numberOfTapsRequired = 1;
    gestureRecognizer.cancelsTouchesInView = NO;
    gestureRecognizer.delegate = self;
    [_listTable addGestureRecognizer:gestureRecognizer];
    
    
    UIView * footView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, ScreenWidth, 80 + XBottomBarHeight)];
    footView.backgroundColor = [UIColor clearColor];
    
    // 区尾添加提交按钮 2.7.1改版
    UIButton * commitBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [commitBtn setTitle:ZCSTLocalString(@"提交") forState:UIControlStateNormal];
    [commitBtn setTitle:ZCSTLocalString(@"提交") forState:UIControlStateSelected];
    commitBtn.autoresizesSubviews = YES;
    commitBtn.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleTopMargin;
    [commitBtn setTitleColor:[ZCUITools zcgetLeaveSubmitTextColor] forState:UIControlStateNormal];
    [commitBtn setTitleColor:[ZCUITools zcgetLeaveSubmitTextColor] forState:UIControlStateHighlighted];
    UIImage * img = [self createImageWithColor:[ZCUITools zcgetLeaveSubmitImgColor]];
    [commitBtn setBackgroundImage:img forState:UIControlStateNormal];
    [commitBtn setBackgroundImage:img forState:UIControlStateSelected];
    commitBtn.frame = CGRectMake(ZCNumber(15), ZCNumber(35), ScreenWidth- ZCNumber(30),44);
    commitBtn.tag = BUTTON_MORE;
    [commitBtn addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
    commitBtn.layer.masksToBounds = YES;
    commitBtn.layer.cornerRadius = 3.5f;
    commitBtn.titleLabel.font = [UIFont systemFontOfSize:15];
    [footView addSubview:commitBtn];

    _listTable.tableFooterView = footView;
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
#pragma mark -- 邮箱格式
// 正则表达式判断
- (BOOL)match:(NSString *) email{
    // 1.创建正则表达式
    NSString *pattern = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";// 判断输入的数字是否是1~99
    NSRegularExpression *regex = [[NSRegularExpression alloc] initWithPattern:pattern options:0 error:nil];
    // 2.测试字符串
    NSArray *results = [regex matchesInString:email options:0 range:NSMakeRange(0, email.length)];
    return results.count > 0;
}


#pragma mark -- 返回到上一VC
- (void)backAction{

    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        
        [[NSNotificationCenter defaultCenter] removeObserver:self];
//        [self hideKeyboard];
        if(self.navigationController!=nil){
            [self.navigationController popViewControllerAnimated:YES];
        }else{
            [self dismissViewControllerAnimated:YES completion:^{
                
            }];
        }
    });
    

    
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
        
        if(LinkedClickBlock){
            LinkedClickBlock(url);
        }else{
            if([url hasPrefix:@"tel:"] || zcLibValidateMobileWithRegex(url, [ZCUITools zcgetTelRegular])){
                callURL=url;
                
                [[ZCToolsCore getToolsCore] showAlert:nil message:[url stringByReplacingOccurrencesOfString:@"tel:" withString:@""] cancelTitle:ZCSTLocalString(@"取消") viewController:self.navigationController confirm:^(NSInteger buttonTag) {
                    if(buttonTag>=0){
                        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:callURL]];
                    }
                    
                } buttonTitles:ZCSTLocalString(@"呼叫"), nil];
            }else if([url hasPrefix:@"mailto:"] || zcLibValidateEmail(url)){
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:url]];
            } else{
                if (![url hasPrefix:@"https"] && ![url hasPrefix:@"http"]) {
                    url = [@"http://" stringByAppendingString:url];
                }
                ZCUIWebController *webPage=[[ZCUIWebController alloc] initWithURL:zcUrlEncodedString(url)];
                if(self.navigationController != nil ){
                    [self.navigationController pushViewController:webPage animated:YES];
                }else{
                    UINavigationController *nav=[[UINavigationController alloc] initWithRootViewController:webPage];
                    nav.navigationBarHidden=YES;
                    
                    nav.modalPresentationStyle = UIModalPresentationOverFullScreen;
                    [self presentViewController:nav animated:YES completion:^{
                        
                    }];
                }
            }
        }
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
    if (section == 0 && zcLibConvertToString(_msgTxt).length > 0) {
        _msgTxt = [_msgTxt stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];

        ZCMLEmojiLabel  *label=[[ZCMLEmojiLabel alloc] initWithFrame:CGRectMake(15, 15, ScreenWidth-30, 0)];
        label.numberOfLines = 0;
        [label setFont:ZCUIFont12];
        //    [label setText:_listArray[section][@"sectionName"]];
        [label setBackgroundColor:[UIColor clearColor]];
        [label setTextAlignment:NSTextAlignmentLeft];
        [label setTextColor:UIColorFromThemeColor(ZCTextSubColor)];
        label.numberOfLines = 0;
        label.isNeedAtAndPoundSign = NO;
        label.disableEmoji = NO;
        
        label.lineSpacing = 3.0f;
        NSString *text = @"";
        if (_msgTxt != nil && _msgTxt.length >0)   {
            text = zcLibConvertToString(_msgTxt);
        }
//        NSString *text = _msgTxt;//[self getCurConfig].msgTxt;
        
        [ZCHtmlCore filterHtml:text result:^(NSString * _Nonnull text1, NSMutableArray * _Nonnull arr, NSMutableArray * _Nonnull links) {
            if (text1 != nil && text1.length > 0) {
                label.attributedText =   [ZCHtmlFilter setHtml:text1 attrs:arr view:label textColor:UIColorFromThemeColor(ZCTextSubColor) textFont:ZCUIFont12 linkColor:[ZCUITools zcgetChatLeftLinkColor]];
                
            }else{
                label.attributedText = [[NSAttributedString alloc] initWithString:@""];;
                
            }
            
        }];
        

        CGSize  labSize = [label preferredSizeWithMaxWidth:ScreenWidth-30];
        if(labSize.height < 2){
            return  0.01;
        }
        return labSize.height + 30;
    }
    return 0.01;
}

// 返回section 的View
-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    UIView *view=[[UIView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, 10)];
    if (section == 0) {
        [view setBackgroundColor:[ZCUITools zcgetLightGrayDarkBackgroundColor]];
        ZCMLEmojiLabel *label=[[ZCMLEmojiLabel alloc] initWithFrame:CGRectMake(15, 15, ScreenWidth-30, 0)];
        [label setFont:ZCUIFont12];
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
        

        NSString *text = _msgTxt;//[self getCurConfig].msgTxt;
        
        [ZCHtmlCore filterHtml:text result:^(NSString * _Nonnull text1, NSMutableArray * _Nonnull arr, NSMutableArray * _Nonnull links) {
            if (text1 !=nil && text1.length > 0) {
                 label.attributedText =   [ZCHtmlFilter setHtml:text1 attrs:arr view:label textColor:UIColorFromThemeColor(ZCTextSubColor) textFont:ZCUIFont12 linkColor:[ZCUITools zcgetChatLeftLinkColor]];
            }else{
                 label.attributedText = [[NSAttributedString alloc] initWithString:@""];
            }
           
        }];
        
        
        CGSize  labSize  =  [label preferredSizeWithMaxWidth:ScreenWidth-30];
        label.frame = CGRectMake(15, 15, labSize.width, labSize.height);
        [view addSubview:label];
        
        CGRect VF = view.frame;
        VF.size.height = labSize.height + 15;
        view.frame = VF;
        
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
        ((ZCOrderContentCell *)cell).enclosureShowFlag =  YES;
    }
    
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
}

//设置分割线间距
-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    if((indexPath.row+1) < _listArray.count){
        UIEdgeInsets inset = UIEdgeInsetsMake(0, 10, 0, 0);
        if ([cell respondsToSelector:@selector(setSeparatorInset:)]) {
            [cell setSeparatorInset:inset];
        }
        
        if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
            [cell setLayoutMargins:inset];
        }
    }
}



#pragma mark UITableViewCell 行点击事件处理
-(void)itemCreateCusCellOnClick:(ZCOrderCreateItemType)type dictValue:(NSString *)value dict:(NSDictionary *)dict indexPath:(NSIndexPath *)indexPath{
    // 单行或多行文本，是自定义字段，需要单独处理_coustomArr对象的内容
    if(type == ZCOrderCreateItemTypeOnlyEdit || type == ZCOrderCreateItemTypeMulEdit){
        int propertyType = [dict[@"propertyType"] intValue];
        if(propertyType == 1){
            int index = [dict[@"code"] intValue];
//            ZCLibOrderCusFieldsModel *temModel = _coustomArr[index];
//            temModel.fieldValue = value;
//            temModel.fieldSaveValue = value;
//
//            // 这里要重新处理数据 *
//            NSString * titleStr = zcLibConvertToString(temModel.fieldName);
//            if([zcLibConvertToString(temModel.fillFlag) intValue] == 1){
//                titleStr = [NSString stringWithFormat:@"%@*",titleStr];
//            }
//
//            NSMutableArray *arr1 = _listArray[indexPath.section][@"arr"];
//            arr1[indexPath.row] = @{@"code":[NSString stringWithFormat:@"%d",index],
//                                    @"dictName":zcLibConvertToString(temModel.fieldName),
//                                    @"dictDesc":zcLibConvertToString(titleStr),
//                                    @"placeholder":zcLibConvertToString(temModel.fieldRemark),
//                                    @"dictValue":zcLibConvertToString(temModel.fieldValue),
//                                    @"dictType":zcLibConvertToString(temModel.fieldType),
//                                    @"propertyType":@"1"
//                                    };
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

            ZCXJAlbumController *albumVC = [[ZCXJAlbumController alloc] initWithImgULocationArr:_imagePathArr CurPage:[key intValue]];
            albumVC.myDelegate = self;
            
            [self.navigationController pushViewController:albumVC animated:YES];
                
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
    _zc_imagepicker.mediaTypes = [NSArray arrayWithObjects:@"public.movie", @"public.image", nil];
    _zc_imagepicker.delegate = self;
    [ZCSobotCore getPhotoByType:buttonIndex byUIImagePickerController:_zc_imagepicker Delegate:self];
}
#pragma mark UIImagePickerControllerDelegate
#pragma mark - UIImagePickerControllerDelegate
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker{
    [picker dismissViewControllerAnimated:YES completion:^{
        
    }];
}

-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    __weak  ZCReplyLeaveController *_myselft  = self;

    [ZCSobotCore imagePickerController:_zc_imagepicker didFinishPickingMediaWithInfo:info WithView:self.view Delegate:self block:^(NSString *filePath, ZCMessageType type, NSDictionary *duration) {

        if(type == ZCMessageTypePhoto){
            [_myselft updateloadFile:filePath type:ZCMessageTypePhoto dict:info];
        }else{
            [_myselft converToMp4:duration withInfoDic:info];
        }
    }];
}


-(void)updateloadFile:(NSString *)filePath type:(ZCMessageType) type dict:(NSDictionary *) cover{

    __weak  ZCReplyLeaveController *_myself  = self;
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
                                    dic = @{@"cover":cover[@"cover"]};
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

    __weak  ZCReplyLeaveController *keyboardSelf  = self;
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
        
        [_listTable setContentOffset:CGPointMake(_listTable.contentOffset.x,((rectintableview.origin.y-_listTable.contentOffset.y)-150)+  _listTable.contentOffset.y) animated:YES];
        contentoffset = CGPointMake(_listTable.contentOffset.x,((rectintableview.origin.y-_listTable.contentOffset.y)-150)+  _listTable.contentOffset.y);
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

#pragma mark - 手势
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch{
    if ([touch.view isKindOfClass:[UIButton class]])
       {
           return NO;
       }
       return YES;
    
}


#pragma mark UITableView delegate end

- (void)allHideKeyBoard
{
    for (UIWindow* window in [UIApplication sharedApplication].windows)
    {
        for (UIView* view in window.subviews)
        {
            [self dismissAllKeyBoardInView:view];
        }
    }
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
    [self setTableSeparatorInset];
    // 计算Y值
   CGFloat startY = 0;
   if (self.navigationController.navigationBarHidden) {
       startY = NavBarHeight;
   }
   if ([ZCUICore getUICore].kitInfo.navcBarHidden) {
       startY = NavBarHeight;
   }

    CGFloat scrollHeight = [self getCurViewHeight] -startY - XBottomBarHeight;
    
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
    [self.listTable setFrame:CGRectMake(spaceX, startY, LW, scrollHeight)];
    [self.listTable reloadData];
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
    
    if (lmsView != nil) {
        return;
    }
    CGFloat Y = 0;
    if (self.navigationController.navigationBarHidden) {
        Y = NavBarHeight;
    }
    
    lmsView = [[UIView alloc]initWithFrame:CGRectMake(0, Y, ScreenWidth, ScreenHeight - Y)];
    lmsView.backgroundColor = [UIColor whiteColor];
    
    UIImageView * img = [[UIImageView alloc]initWithFrame:CGRectMake(ScreenWidth/2 - ZCNumber(93/2), ZCNumber(60), ZCNumber(93), ZCNumber(93))];
    img.image = [ZCUITools zcuiGetBundleImage:@"zcicon_addleavemsgsuccess"];
    [lmsView addSubview:img];
    
    UILabel * titleLab = [[UILabel alloc]initWithFrame:CGRectMake(0, CGRectGetMaxY(img.frame)+ ZCNumber(20), ScreenWidth, ZCNumber(28))];
    titleLab.text = ZCSTLocalString(@"创建成功");
    titleLab.textAlignment = NSTextAlignmentCenter;
    titleLab.font = [UIFont fontWithName:@"Arial-BoldMT" size:20];
    [lmsView addSubview:titleLab];
    
    UILabel * tiplab = [[UILabel alloc]initWithFrame:CGRectMake(ZCNumber(45), CGRectGetMaxY(titleLab.frame) + ZCNumber(10), ScreenWidth - ZCNumber(90), ZCNumber(40))];
    tiplab.textAlignment = NSTextAlignmentCenter;
    tiplab.font = [UIFont systemFontOfSize:14];
    tiplab.text = ZCSTLocalString(@"我们将会以链接的形式在会话中向你反馈工单处理状态");
    [tiplab setNumberOfLines:2];
    tiplab.textColor = UIColorFromThemeColor(ZCTextMainColor);
    [lmsView addSubview:tiplab];
    
    UIButton * comBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    comBtn.frame = CGRectMake(ZCNumber(15), CGRectGetMaxY(tiplab.frame) + ZCNumber(15), ScreenWidth - ZCNumber(30), ZCNumber(44)) ;
    [comBtn setTitle:ZCSTLocalString(@"完成") forState:UIControlStateNormal];
    [comBtn setTitle:ZCSTLocalString(@"完成") forState:UIControlStateSelected];
    UIImage * colorimg = [self createImageWithColor:[ZCUITools zcgetLeaveSubmitImgColor]];
    [comBtn setBackgroundImage:colorimg forState:UIControlStateNormal];
    [comBtn setBackgroundImage:colorimg forState:UIControlStateSelected];
    [comBtn addTarget:self action:@selector(backAction) forControlEvents:UIControlEventTouchUpInside];
    comBtn.tag = 3001;
    comBtn.layer.masksToBounds = YES;
    comBtn.layer.cornerRadius = 3.5f;
    comBtn.titleLabel.font = [UIFont systemFontOfSize:15];
    [lmsView addSubview:comBtn];
    
    
    [self.view addSubview:lmsView];
}

#pragma mark -- 提示页面 end ------------
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
