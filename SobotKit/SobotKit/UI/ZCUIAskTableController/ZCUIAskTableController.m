//
//  ZCUIAskTableController.m
//  SobotKit
//
//  Created by lizhihui on 2018/1/2.
//  Copyright © 2018年 zhichi. All rights reserved.
//

#import "ZCUIAskTableController.h"
#import "ZCLibOrderCusFieldsModel.h"
#import "ZCLibGlobalDefine.h"
#import "ZCUIColorsDefine.h"
#import "ZCUIWebController.h"

#import "ZCZHPickView.h"
//#import "ZCOrderCusFieldController.h"

#import "ZCLocalStore.h"
#import "ZCPlatformInfo.h"
#import "ZCPlatformTools.h"

#import "ZCOrderEditCell.h"
#import "ZCOrderCheckCell.h"

#import "ZCOrderCreateCell.h"
#import "ZCOrderOnlyEditCell.h"

//#import "ZCUIAskCityController.h"
#import "ZCUIImageTools.h"
#define cellCheckIdentifier @"ZCOrderCheckCell"
#define cellEditIdentifier @"ZCOrderEditCell"

#define cellOrderSwitchIdentifier @"ZCOrderReplyOpenCell"
#define cellOrderSingleIdentifier @"ZCOrderOnlyEditCell"

#import "ZCAddressModel.h"
#import "ZCUICore.h"
#import "ZCHtmlCore.h"
#import "ZCHtmlFilter.h"
#import "ZCCheckCusFieldView.h"
#import "ZCPageSheetView.h"
#import "ZCCheckCityView.h"
#import "ZCCheckMulCusFieldView.h"

#import "ZCToolsCore.h"

@interface ZCUIAskTableController ()<UITextFieldDelegate,UITextViewDelegate,UIGestureRecognizerDelegate,UINavigationControllerDelegate,UITableViewDataSource,UITableViewDelegate,ZCMLEmojiLabelDelegate,UIScrollViewDelegate,ZCZHPickViewDelegate,ZCOrderCreateCellDelegate>{
    
    // 链接点击
    void (^LinkedClickBlock) (NSString *url);
    
    // 呼叫的电话号码
    NSString                    *callURL;
    
    ZCLibOrderCusFieldsModel    *curEditModel;
    
    CGPoint        contentoffset;// 记录list的偏移量
    
    CGFloat     headerViewH ;// 区头的高度
    
    // 屏幕宽高
//    CGFloat                     viewWidth;
//    CGFloat                     viewHeigth;
}

@property (nonatomic, assign) BOOL isSend;// 是否正在发送

@property (nonatomic,strong) UITableView * listTable;

@property (nonatomic,strong) NSMutableArray * listArray;

@property(nonatomic,strong)NSMutableArray   *coustomArr;// 用户自定义字段数组

@property(nonatomic,strong)UITextView       *tempTextView;

@property(nonatomic,strong)UITextField      *tempTextField;

@property (nonatomic,strong) UIView * placeholderView;

@property (nonatomic,copy) NSString * detailStr;// 表单描述

@property (nonatomic,strong) ZCAddressModel * addressModel;

@property (nonatomic,assign)  BOOL isCommitSuccess;// 是否提交成功
@end

@implementation ZCUIAskTableController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
//    [self.navigationController setNavigationBarHidden:YES];
    
    if ([ZCUICore getUICore].kitInfo.navcBarHidden) {
        self.navigationController.navigationBarHidden = YES;
    }
    
    
    NSString *title=ZCSTLocalString(@"请填写询前表单");
    
    if(!self.navigationController.navigationBarHidden){
        [self setNavigationBarStyle];
        self.title = title;
        [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName : UIColorFromThemeColor(ZCTextMainColor),NSFontAttributeName : ZCUIFontBold17}];
    }else{
        [self createTitleView];
        
        self.titleLabel.text = title;

    }
    self.navigationController.navigationBar.translucent = NO;

    
    _listArray = [[NSMutableArray alloc] init];
    
    
    // 布局页面
    [self customLayoutSubviews];
        
    [self.moreButton setImage:nil forState:UIControlStateNormal];
    [self.moreButton setImage:nil forState:UIControlStateHighlighted];
    [self.moreButton setTitle:ZCSTLocalString(@"提交") forState:UIControlStateNormal];
    [self.moreButton addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
    //back
    [self.backButton addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
    
    
    self.moreButton.hidden = YES;
    
//    UIView *lineView = [[UIView alloc]initWithFrame:CGRectMake(0, NavBarHeight, ScreenWidth, 0.5)];
//    lineView.backgroundColor = UIColorFromRGB(lineGrayColor);
//    [self.view addSubview:lineView];
    
    
    UIView * footView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, ScreenWidth, 15 + 30 + 80)];
    footView.backgroundColor = [UIColor clearColor];
    footView.autoresizingMask = UIViewAutoresizingFlexibleWidth;

    UIView *lineView_2 = [[UIView alloc]initWithFrame:CGRectMake(0, 0, ScreenWidth, 0.5)];
    lineView_2.backgroundColor = UIColorFromThemeColor(ZCBgLineColor);
    [footView addSubview:lineView_2];
    
    int th = 0;
    if(sobotConvertToString(_dict[@"formSafety"]).length > 0){
        UILabel *label=[[UILabel alloc] initWithFrame:CGRectMake(15, 10, [self getCurViewWidth]-30, 0)];
        label.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        [label setFont:ZCUIFont14];
        [label setText:sobotConvertToString(_dict[@"formSafety"])];
        //    [label setText:_listArray[section][@"sectionName"]];
        [label setBackgroundColor:[UIColor clearColor]];
        [label setTextAlignment:NSTextAlignmentLeft];
        [label setTextColor:UIColorFromThemeColor(ZCTextSubColor)];
        label.numberOfLines = 0;
        [label sizeToFit];
        [footView addSubview:label];
        th = CGRectGetMaxY(label.frame);
    }
    
    // 区尾添加提交按钮 2.7.1改版
    UIButton * commitBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [commitBtn setTitle:ZCSTLocalString(@"提交并咨询") forState:UIControlStateNormal];
    [commitBtn setTitle:ZCSTLocalString(@"提交并咨询") forState:UIControlStateSelected];
    [commitBtn setBackgroundColor:[ZCUITools zcgetLeaveSubmitImgColor]];
    [commitBtn setTitleColor:[ZCUITools zcgetLeaveSubmitTextColor] forState:UIControlStateNormal];
    [commitBtn setTitleColor:[ZCUITools zcgetLeaveSubmitTextColor] forState:UIControlStateHighlighted];
    commitBtn.frame = CGRectMake(ZCNumber(15),th + ZCNumber(15), ScreenWidth- ZCNumber(30), ZCNumber(44));
    commitBtn.tag = BUTTON_MORE;
    [commitBtn addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
    commitBtn.layer.masksToBounds = YES;
    commitBtn.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    commitBtn.layer.cornerRadius = ZCNumber(22);
    commitBtn.titleLabel.font = ZCUIFontBold17;
    [footView addSubview:commitBtn];
    
    _listTable.tableFooterView = footView;
    
    
    _isSend = NO;
    
    
    // 加载数据
    [self loadDataForPage];
    
    // 布局子页面
    [self refreshViewData];
   
    
    
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

#pragma mark -- 返回和提交
-(void)buttonClick:(UIButton*)sender{
    if (sender.tag == BUTTON_BACK) {
        // 点击技能组的Item 之后会记录当前点选的技能组，返回是置空 重新显示技能组弹框
        if (_isclearskillId) {
            [ZCUICore getUICore].checkGroupId = @"";
            [ZCUICore getUICore].checkGroupName = @"";
        }
        
        [ZCUICore getUICore].isShowForm = NO;
        [self backAction];
        if (_trunServerBlock) {
            _trunServerBlock(YES);
        }
    }else{
        
        NSMutableDictionary *cusFields = [NSMutableDictionary dictionaryWithCapacity:0];
        // 自定义字段
        for (ZCLibOrderCusFieldsModel *cusModel in _coustomArr) {
            if([cusModel.fillFlag intValue] == 1 && sobotIsNull(cusModel.fieldValue)){
                [[ZCUIToastTools shareToast] showToast:[NSString stringWithFormat:@"%@%@",cusModel.fieldName,ZCSTLocalString(@"不能为空")] duration:1.0f view:self.view position:ZCToastPositionCenter];
                
                return;
            }
            
            
            if(![self checkContentValid:cusModel.fieldSaveValue model:cusModel]){
                [[ZCUIToastTools shareToast] showToast:[NSString stringWithFormat:@"%@%@",cusModel.fieldName,ZCSTLocalString(@"格式不正确")] duration:1.0f view:self.view position:ZCToastPositionCenter];
                return;
            }
            
            if( [@"tel" isEqual:sobotConvertToString(cusModel.fieldId)] && sobotConvertToString(cusModel.fieldValue).length>0 && !sobotValidateMobile(sobotConvertToString(cusModel.fieldValue))){
                [[ZCUIToastTools shareToast] showToast:[NSString stringWithFormat:@"%@%@",cusModel.fieldName,ZCSTLocalString(@"格式不正确")] duration:1.0f view:self.view position:ZCToastPositionCenter];
                return;
            }
            
            if( [@"email" isEqual:sobotConvertToString(cusModel.fieldId)] && sobotConvertToString(cusModel.fieldValue).length>0 && !sobotValidateEmail(sobotConvertToString(cusModel.fieldValue))){
                [[ZCUIToastTools shareToast] showToast:ZCSTLocalString(@"请输入正确的邮箱") duration:1.0f view:self.view position:ZCToastPositionCenter];
                return;
            }
            
            
            if(!sobotIsNull(cusModel.fieldSaveValue)){
                if (![@"city" isEqualToString:sobotConvertToString(cusModel.fieldId)]) {
                    if([cusModel.fieldType intValue] == 9){
                        [cusFields setObject:@{@"id":sobotConvertToString(cusModel.fieldId),
                                               @"text":sobotConvertToString(cusModel.fieldValue),
                                               @"value":sobotConvertToString(cusModel.fieldSaveValue)
                                               } forKey:sobotConvertToString(cusModel.fieldId)];
                    
                    }else{
                        [cusFields setObject:sobotConvertToString(cusModel.fieldSaveValue) forKey:sobotConvertToString(cusModel.fieldId)];
                        
                    }
                }else if([@"city" isEqualToString:sobotConvertToString(cusModel.fieldId)]){
                    [cusFields setObject:sobotConvertToString(_addressModel.provinceId) forKey:@"proviceId"];
                    [cusFields setObject:sobotConvertToString(_addressModel.provinceName) forKey:@"proviceName"];
                    [cusFields setObject:sobotConvertToString(_addressModel.cityId) forKey:@"cityId"];
                    [cusFields setObject:sobotConvertToString(_addressModel.cityName) forKey:@"cityName"];
                    [cusFields setObject:sobotConvertToString(_addressModel.areaId) forKey:@"areaId"];
                    [cusFields setObject:sobotConvertToString(_addressModel.areaName) forKey:@"areaName"];
                }
            }
        
        }
        
        [self UpLoadWith:cusFields];
        [self allHideKeyBoard];
        
//        [self backAction];
        
    }
}


// 提交请求
- (void)UpLoadWith:(NSMutableDictionary*)dict{
    if(_isSend){
        return;
    }
    
    _isSend = YES;
     NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    // 添加自定义字段
    if (_coustomArr>0) {
        [dic setValue:sobotConvertToString([ZCLocalStore DataTOjsonString:dict]) forKey:@"customerFields"];
    }
    
    // 调用接口
    __weak ZCUIAskTableController *weakSelf = self;
    [[self getZCAPIServer] postAskTabelWithUid:[self getZCLibConfig].uid Parms:dic start:^{
        
    } success:^(NSDictionary *dict, ZCNetWorkCode sendCode) {
        weakSelf.isCommitSuccess = YES;
        [[ZCUIToastTools shareToast] showToast:ZCSTLocalString(@"提交成功") duration:1.0f view:self.view position:ZCToastPositionCenter Image:[ZCUITools zcuiGetBundleImage:@"zcicon_successful"]];
      
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.2f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self backAction];
            if (_trunServerBlock) {
                _trunServerBlock(NO);
            }
            _isSend = NO;
        });
    } failed:^(NSString *errorMessage, ZCNetWorkCode errorCode) {
         _isSend = NO;
        
        [[ZCUIToastTools shareToast] showToast:errorMessage duration:1.0f view:self.view position:ZCToastPositionCenter];
        
    }];
    
}

-(void)backAction{
    if (self.navigationController != nil) {
        [self.navigationController popViewControllerAnimated:NO];
    }else{
        [self dismissViewControllerAnimated:NO completion:nil];
    }
}

-(void)customLayoutSubviews{
    self.automaticallyAdjustsScrollViewInsets = NO;
    if(!self.navigationController.navigationBarHidden){
        _listTable = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, [self getCurViewWidth], [self getCurViewHeight]) style:UITableViewStylePlain];
    }else{
        _listTable = [[UITableView alloc]initWithFrame:CGRectMake(0, NavBarHeight, [self getCurViewWidth], [self getCurViewHeight] - NavBarHeight) style:UITableViewStylePlain];
    }
    
    _listTable.delegate = self;
    _listTable.dataSource = self;
    _listTable.bounces = YES;
    [self.view addSubview:_listTable];
    _listTable.estimatedRowHeight = 0;
    _listTable.estimatedSectionFooterHeight = 0;

    _listTable.clipsToBounds = YES;
    [_listTable registerClass:[ZCOrderCheckCell class] forCellReuseIdentifier:cellCheckIdentifier];
    [_listTable registerClass:[ZCOrderEditCell class] forCellReuseIdentifier:cellEditIdentifier];
    [_listTable registerClass:[ZCOrderOnlyEditCell class] forCellReuseIdentifier:cellOrderSingleIdentifier];
    [_listTable setSeparatorColor:UIColorFromThemeColor(ZCBgLineColor)];
    _listTable.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    [self setTableSeparatorInset];
    // 关闭安全区域，否则UITableViewCell横屏时会是全屏的宽
    NSString *version = [UIDevice currentDevice].systemVersion;
    if (version.doubleValue >= 11.0) {
        [_listTable setInsetsContentViewsToSafeArea:NO];
    }
    if (version.doubleValue >= 15.0) {
        _listTable.sectionHeaderTopPadding = 0;
    }
    _listTable.backgroundColor = UIColorFromThemeColor(ZCBgLightGrayDarkColor);
    
    UITapGestureRecognizer *gestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapHideKeyboard)];
    gestureRecognizer.numberOfTapsRequired = 1;
    gestureRecognizer.cancelsTouchesInView = NO;
    [_listTable addGestureRecognizer:gestureRecognizer];
    
    
    UIView * footView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, ScreenWidth, 300)];
    footView.backgroundColor = [UIColor clearColor];
    _listTable.tableFooterView = footView;
    
}


-(void)refreshViewData{
    [_listArray removeAllObjects];
    
    //    NSDictionary *dict = [ZCJSONDataTools getObjectData:_model];
    // 0，特殊行   1 单行文本 2 多行文本 3 日期 4 时间 5 数值 6 下拉列表 7 复选框 8 单选框 9 级联字段
    // propertyType == 1是自定义字段，0固定字段, 3不可点击
    
    NSMutableArray * arr1 = [NSMutableArray arrayWithCapacity:0];
    if (_coustomArr.count >0 && ![_coustomArr isKindOfClass:[NSNull class]]) {
        int index = 0;
        for (ZCLibOrderCusFieldsModel *cusModel in _coustomArr) {
            NSString *propertyType = @"1";
            NSString * titleStr = sobotConvertToString(cusModel.fieldName);
            if([sobotConvertToString(cusModel.fillFlag) intValue] == 1){
                titleStr = [NSString stringWithFormat:@"%@ *",titleStr];
            }
            // 城市
            if ([sobotConvertToString(cusModel.fieldId) isEqualToString:@"city"] ) {
                cusModel.fieldValue = [NSString stringWithFormat:@"%@%@%@", sobotConvertToString(self.addressModel.provinceName) ,sobotConvertToString(self.addressModel.cityName) ,sobotConvertToString(self.addressModel.areaName)];
                cusModel.fieldSaveValue = cusModel.fieldValue;
            }
            
            if ([sobotConvertToString(cusModel.fieldId) isEqualToString:@"qq"]) {
                cusModel.fieldType = @"5";
            }
            [arr1 addObject:@{@"code":[NSString stringWithFormat:@"%d",index],
                              @"dictName":sobotConvertToString(cusModel.fieldName),
                              @"dictDesc":sobotConvertToString(titleStr),
                              @"placeholder":sobotConvertToString(cusModel.fieldRemark),
                              @"dictValue":sobotConvertToString(cusModel.fieldValue),
                              @"dictType":sobotConvertToString(cusModel.fieldType),
                              @"propertyType":propertyType,
                              @"dictfiledId":sobotConvertToString(cusModel.fieldId),
                              @"model":cusModel
                              }];
            index = index + 1;
        }

        [_listArray addObjectsFromArray:arr1];
    }
    [self reloadHeaderView];
    [_listTable reloadData];
    
}

-(void)reloadHeaderView{
    UIView *view=[[UIView alloc] initWithFrame:CGRectMake(0, 0, [self getCurViewWidth], 0)];
    view.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    if (_coustomArr.count) {
        [view setBackgroundColor:UIColorFromThemeColor(ZCBgLightGrayDarkColor)];
        ZCMLEmojiLabel *label=[[ZCMLEmojiLabel alloc] initWithFrame:CGRectMake(15, 15, [self getCurViewWidth]-30, 0)];
        label.autoresizingMask = UIViewAutoresizingFlexibleWidth;
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
        
        NSString *text = self.detailStr;
        [ZCHtmlCore filterHtml:text result:^(NSString * _Nonnull text1, NSMutableArray * _Nonnull arr, NSMutableArray * _Nonnull links) {
            if (text1 !=nil && text1.length > 0) {
                label.attributedText =   [ZCHtmlFilter setHtml:text1 attrs:arr view:label textColor:UIColorFromThemeColor(ZCTextSubColor) textFont:ZCUIFont14 linkColor:[ZCUITools zcgetChatLeftLinkColor]];
            }else{
                label.attributedText = [[NSAttributedString alloc] initWithString:@""];
            }
            
            
        }];
        CGSize  labSize  =  [label preferredSizeWithMaxWidth:ScreenWidth-30];
        label.frame = CGRectMake(15, 12, labSize.width, labSize.height);
        [view addSubview:label];
        
        CGRect VF = view.frame;
        VF.size.height = labSize.height + 24;
        view.frame = VF;
        
        UIView *lineView = [[UIView alloc]initWithFrame:CGRectMake(0, view.frame.size.height - 1, ScreenWidth, 0.5)];
        lineView.backgroundColor = UIColorFromThemeColor(ZCBgLineColor);
        lineView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        [view addSubview:lineView];
    }else{
        view.frame = CGRectMake(0, 0, ScreenWidth, 0.01);
    }
    
    headerViewH = CGRectGetHeight(view.frame);
    self.listTable.tableHeaderView = view;
}
-(void)loadDataForPage{
    
    if (_coustomArr == nil) {
        _coustomArr = [NSMutableArray arrayWithCapacity:0];
    }else{
        [_coustomArr removeAllObjects];
    }
  
    
    if (_dict) {
        
        if(sobotConvertToString(_dict[@"formTitle"]).length >0){
            if(!self.navigationController.navigationBarHidden){
                self.title = ZCSTLocalString(sobotConvertToString(_dict[@"formTitle"]));
            }else{
                self.titleLabel.text = ZCSTLocalString(sobotConvertToString(_dict[@"formTitle"]));
            }
        }
        
        if (![_dict[@"fields"] isKindOfClass:[NSNull class]]) {
            for (NSDictionary * item  in _dict[@"fields"]) {
                ZCLibOrderCusFieldsModel * model = [[ZCLibOrderCusFieldsModel alloc]initWithMyDict:item];
                [_coustomArr addObject:model];
            }
        }
        self.detailStr = sobotConvertToString(_dict[@"formDoc"]);
    }
    
    
    if (_coustomArr.count<1) {
        [self createPlaceholderView:nil message:ZCSTLocalString(@"网络原因请求超时 重新加载") image:[UIImage imageNamed:@"zcicon_networkfail"] withView:_listTable action:nil];
    }else{
        [self removePlaceholderView];
    }
    
}

#pragma mark --  监听左滑返回的事件
- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    // 解决ios7调用系统的相册时出现的导航栏透明的情况
    if ([navigationController isKindOfClass:[UIImagePickerController class]]) {
        viewController.navigationController.navigationBar.translucent = NO;
        viewController.edgesForExtendedLayout = UIRectEdgeNone;
        return;
    }
    
    id<UIViewControllerTransitionCoordinator> tc = navigationController.topViewController.transitionCoordinator;
    __weak ZCUIAskTableController *weakSelf = self;
    [tc notifyWhenInteractionEndsUsingBlock:^(id<UIViewControllerTransitionCoordinatorContext> context) {
        if(![context isCancelled]){
            // 设置页面不能使用边缘手势关闭
//            if(iOS7 && navigationController!=nil){
//                navigationController.interactivePopGestureRecognizer.enabled = NO;
//            }
            [weakSelf backAction];
        }
    }];
    
}




#pragma mark EmojiLabel链接点击事件
// 链接点击
-(void)attributedLabel:(ZCTTTAttributedLabel *)label didSelectLinkWithURL:(NSURL *)url{
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
            if([url hasPrefix:@"tel:"] || sobotValidateMobile(url)){
                callURL=url;
                
                [[ZCToolsCore getToolsCore] showAlert:nil message:[url stringByReplacingOccurrencesOfString:@"tel:" withString:@""] cancelTitle:ZCSTLocalString(@"取消") viewController:self confirm:^(NSInteger buttonTag) {
                    if(buttonTag>=0){
                        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:callURL]];
                    }
                    
                    
                } buttonTitles:ZCSTLocalString(@"呼叫"), nil];
                
                
            }else if([url hasPrefix:@"mailto:"] || sobotValidateEmail(url)){
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:url]];
            }
            
            else{
                if (![url hasPrefix:@"https"] && ![url hasPrefix:@"http"]) {
                    url = [@"http://" stringByAppendingString:url];
                }
                ZCUIWebController *webPage=[[ZCUIWebController alloc] initWithURL:sobotUrlEncodedString(url)];
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





#pragma mark --- EmojiLabel链接点击事件 end


#pragma mark -- uitabelView delegate
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

-(void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    [self allHideKeyBoard];
}

// 返回section数
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}


// 返回section下得行数
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if(_listArray==nil){
        return 0;
    }
    
    return _listArray.count;
}


// cell
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    ZCOrderCreateCell *cell = nil;
    // 0，特殊行   1 单行文本 2 多行文本 3 日期 4 时间 5 数值 6 下拉列表 7 复选框 8 单选框 9 级联字段
    NSDictionary *itemDict = _listArray[indexPath.row];
    int type = [itemDict[@"dictType"] intValue];
    if(type == 1 || type ==5){
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
//    cell.tempModel = _model;
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
    
    NSDictionary *itemDict = _listArray[indexPath.row];
    
    if([itemDict[@"propertyType"] intValue]==3){
        return;
    }
    
    
    // 0，特殊行   1 单行文本 2 多行文本 3 日期 4 时间 5 数值 6 下拉列表 7 复选框 8 单选框 9 级联字段
    int propertyType = [itemDict[@"propertyType"] intValue];
    if(propertyType == 1){
        int index = [itemDict[@"code"] intValue];
        curEditModel = _coustomArr[index];
        
        int fieldType = [curEditModel.fieldType intValue];
        if(fieldType == 4){
//            ZCZHPickView *pickView = [[ZCZHPickView alloc] initDatePickWithDate:[NSDate new] datePickerMode:UIDatePickerModeTime isHaveNavControler:NO];
            ZCZHPickView *pickView = [[ZCZHPickView alloc] initWithFrame:self.view.frame DatePickWithDate:[NSDate new]  datePickerMode:UIDatePickerModeTime isHaveNavControler:NO];
            pickView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleBottomMargin;
            pickView.delegate = self;
            [pickView show];
        }
        if(fieldType == 3){
//            ZCZHPickView *pickView = [[ZCZHPickView alloc] initDatePickWithDate:[NSDate new] datePickerMode:UIDatePickerModeDate isHaveNavControler:NO];
            ZCZHPickView *pickView = [[ZCZHPickView alloc] initWithFrame:self.view.frame DatePickWithDate:[NSDate new]  datePickerMode:UIDatePickerModeDate isHaveNavControler:NO];
            pickView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleBottomMargin;
            pickView.delegate = self;
            [pickView show];
        }
        if(fieldType == 9){
            __weak  ZCUIAskTableController *weakSelf = self;
            // 城市 级联字段
            if ([itemDict[@"dictfiledId"] isEqualToString:@"city"]) {
                ZCCheckCityView *cityVC = [[ZCCheckCityView alloc] initWithFrame:CGRectMake(0, 0, [self getCurViewWidth], 0)];
                
                ZCPageSheetView *sheetView = [[ZCPageSheetView alloc] initWithTitle:ZCSTLocalString(@"选择") superView:self.view showView:cityVC type:ZCPageSheetTypeLong];
                
    //            ZCUIAskCityController * cityVC = [[ZCUIAskCityController alloc]init];
                cityVC.pageTitle = itemDict[@"dictDesc"];
                cityVC.parentView = nil;
                cityVC.levle = 1;
                cityVC.orderTypeCheckBlock = ^(ZCAddressModel *model) {
                    weakSelf.addressModel = model;
                    // 刷新 城市
                    [self refreshViewData];
                    
                    [sheetView dissmisPageSheet];
                };
                
                
                [sheetView showSheet:cityVC.frame.size.height animation:YES block:^{
                    
                }];
                return;
    //            [self.navigationController pushViewController:cityVC animated:YES];
            }else{
                __block ZCUIAskTableController *myself = self;
                ZCCheckMulCusFieldView *typeVC = [[ZCCheckMulCusFieldView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 0)];
                
                ZCPageSheetView *sheetView = [[ZCPageSheetView alloc] initWithTitle:ZCSTLocalString(@"选择") superView:self showView:typeVC type:ZCPageSheetTypeLong];
                typeVC.parentDataId = @"";
                typeVC.parentView = nil;
                typeVC.allArray = curEditModel.detailArray;
                typeVC.orderCusFiledCheckBlock = ^(ZCLibOrderCusFieldsDetailModel *model, NSString *dataIds,NSString *dataNames) {
                    curEditModel.fieldValue = dataNames;
                    curEditModel.fieldSaveValue = dataIds;
                    
                    [myself refreshViewData];
                    [sheetView dissmisPageSheet];
                };
                [sheetView showSheet:typeVC.frame.size.height animation:YES block:^{
                    
                }];
            }
            return;
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
//            if (_isNavOpen) {
//                vc.isPush = YES;
//                [self.navigationController pushViewController:vc animated:YES];
//            }else{
//                vc.isPush = NO;
//                [self presentViewController:vc animated:YES completion:nil];
//            }
            
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
    if(curEditModel && ([curEditModel.fieldType intValue]== 4 || [curEditModel.fieldType intValue] == 3)){
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
            
            _listArray[indexPath.row] = @{@"code":[NSString stringWithFormat:@"%d",index],
                                    @"dictName":sobotConvertToString(temModel.fieldName),
                                    @"dictDesc":sobotConvertToString(temModel.fieldName),
                                    @"placeholder":sobotConvertToString(temModel.fieldRemark),
                                    @"dictValue":sobotConvertToString(temModel.fieldValue),
                                    @"dictType":sobotConvertToString(temModel.fieldType),
                                    @"propertyType":@"1"
                                    };
        }
    }
}

#pragma mark -- 系统键盘的监听事件
- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    // 影藏NavigationBar
    
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    
//    if (iOS7) {
//        if (self.navigationController !=nil) {
//            self.navigationController.interactivePopGestureRecognizer.delegate = nil;
//            self.navigationController.delegate = nil;
//        }
//    }
    // 移除键盘的监听
//    [[NSNotificationCenter defaultCenter] removeObserver:self];
}



-(void)keyboardHide:(NSNotification*)notification{
    float animationDuration = [[[notification userInfo] valueForKey:UIKeyboardAnimationDurationUserInfoKey] floatValue];
    [UIView beginAnimations:@"bottomBarDown" context:nil];
    [UIView setAnimationDuration:animationDuration];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
    [UIView commitAnimations];
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
        
    }
}

-(void)tapHideKeyboard{
    if(!sobotIsNull(_tempTextView)){
        [_tempTextView resignFirstResponder];
        _tempTextView = nil;
    }else if(!sobotIsNull(_tempTextField)){
        [_tempTextField resignFirstResponder];
        _tempTextField  = nil;
    }else{
        [self allHideKeyBoard];
    }

    if(contentoffset.x != 0 || contentoffset.y != 0){
        // 隐藏键盘，还原偏移量
//        [_listTable setContentOffset:contentoffset];
        [_listTable setContentOffset:CGPointMake(0, 0) animated:YES];
    }
}

- (void) hideKeyboard {
    if(!sobotIsNull(_tempTextView)){
        [_tempTextView resignFirstResponder];
        _tempTextView = nil;
    }else if(!sobotIsNull(_tempTextField)){
        [_tempTextField resignFirstResponder];
        _tempTextField  = nil;
    }else{
        [self allHideKeyBoard];
    }
    
    if(contentoffset.x != 0 || contentoffset.y != 0){
        // 隐藏键盘，还原偏移量
//        [_listTable setContentOffset:contentoffset];
        [_listTable setContentOffset:CGPointMake(0, 0) animated:YES];
    }
}

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

#pragma mark -- 加载失败的占位页面
- (void)createPlaceholderView:(NSString *)title message:(NSString *)message image:(UIImage *)image withView:(UIView *)superView action:(void (^)(UIButton *button)) clickblock{
    if (_placeholderView) {
        [_placeholderView removeFromSuperview];
        _placeholderView = nil;
    }
    if(superView==nil){
        superView=self.view;
    }
    
    _placeholderView = [[UIView alloc]initWithFrame:superView.frame];
    
//    NSLog(@"%@",NSStringFromCGRect(superView.bounds));
    
    [_placeholderView setAutoresizingMask:UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleBottomMargin];
    [_placeholderView setAutoresizesSubviews:YES];
    [_placeholderView setBackgroundColor:[UIColor whiteColor]];
    [self.view addSubview:_placeholderView];
    
    
    CGRect pf = CGRectMake(0, 0, superView.bounds.size.width, 0);
    UIImageView *icon = [[UIImageView alloc]initWithImage:[ZCUITools zcuiGetBundleImage:@"zcicon_networkfail"]];
    if(image){
        [icon setImage:image];
    }
    [icon setContentMode:UIViewContentModeCenter];
    [icon setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
    icon.frame = CGRectMake(pf.size.width/2 - 55/2, ZCNumber(110), 55, 76);
    [_placeholderView addSubview:icon];
    
    CGFloat y= CGRectGetMaxY(icon.frame) + 10;


    if(message){
        UILabel *lblTitle=[[UILabel alloc] initWithFrame:CGRectMake(0, y, pf.size.width, 20)];
        
        [lblTitle setFont:ZCUIFont14];
        [lblTitle setTextAlignment:NSTextAlignmentCenter];
        [lblTitle setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
        [lblTitle setAutoresizesSubviews:YES];
        lblTitle.textColor = UIColorFromThemeColor(ZCTextSubColor);
        lblTitle.attributedText = [self getOtherColorString:ZCSTLocalString(@"重新加载") Color:UIColorFromRGB(0x4d9dfe) withString:message];
        [lblTitle setBackgroundColor:[UIColor clearColor]];
        lblTitle.userInteractionEnabled = YES;
        [_placeholderView addSubview:lblTitle];
        y = y+25;
        
        
        UITapGestureRecognizer *gestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(refreshViewDataAgain)];
        gestureRecognizer.numberOfTapsRequired = 1;
        gestureRecognizer.cancelsTouchesInView = NO;
        [lblTitle addGestureRecognizer:gestureRecognizer];
    }
    
}


-(void)refreshViewDataAgain{
//    NSLog(@"点击了");
}


-(NSMutableAttributedString *)getOtherColorString:(NSString *)string Color:(UIColor *)Color withString:(NSString *)originalString
{
    NSMutableAttributedString *str = [[NSMutableAttributedString alloc]init];
    
    NSMutableString *temp = [NSMutableString stringWithString:originalString];
    str = [[NSMutableAttributedString alloc] initWithString:temp];
    if (string.length) {
        NSRange range = [temp rangeOfString:string];
        [str addAttribute:NSForegroundColorAttributeName value:Color range:range];
        return str;
        
    }
    return str;
    
}


#pragma mark -- 邮箱格式


-(ZCLibServer *)getZCAPIServer{
    return [[ZCUICore getUICore] getAPIServer];
}


-(ZCLibConfig *)getZCLibConfig{
    return [self getPlatformInfo].config;
}

-(ZCPlatformInfo *) getPlatformInfo{
    return [[ZCPlatformTools sharedInstance] getPlatformInfo];
}


// 移除
- (void)removePlaceholderView{
    if (_placeholderView && _placeholderView!=nil) {
        [_placeholderView removeFromSuperview];
        _placeholderView = nil;
    }
}

-(void)dealloc{
    // 移除键盘的监听
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


-(void)didMoveToParentViewController:(UIViewController *)parent{
    [super didMoveToParentViewController:parent];
    if(!parent){
        if (!self.isCommitSuccess) {
            // 没有提交成功 侧滑返回了，也要回置
//            NSLog(@"页面侧滑返回：%@",parent);
            [ZCUICore getUICore].isShowForm = NO;
        }
    }
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark -- 重新布局
-(void)viewDidLayoutSubviews{
    [super viewDidLayoutSubviews];
    [self setTableSeparatorInset];
    CGFloat Y = 0;
       if (self.navigationController.navigationBarHidden) {
           Y = NavBarHeight;
       }
    

    
            CGFloat viewHeigth = self.view.frame.size.height;
            CGFloat viewWidth = self.view.frame.size.width;
    CGRect f = CGRectMake(0, Y, viewWidth,viewHeigth - Y);
    
    int direction = [[ZCToolsCore getToolsCore] getCurScreenDirection];
          CGFloat spaceX = 0;
          CGFloat LW = viewWidth;
          // iphoneX 横屏需要单独处理
          if(direction > 0){
              LW = viewWidth - XBottomBarHeight;
          }
          if(direction == 2){
              spaceX = XBottomBarHeight;
          }
       f.origin.x = spaceX;
       f.size.width = LW;
      _listTable.frame = f;
    
    [_listTable reloadData];
    

    
}

@end
