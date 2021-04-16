//
//  ZCConfigDetailController.m
//  SobotKitFrameworkTest
//
//  Created by zhangxy on 2020/7/16.
//  Copyright © 2020 zhichi. All rights reserved.
//

#import "ZCConfigDetailController.h"
#import <SobotKit/SobotKit.h>

#import "ZCGuideData.h"
#import "ZCConfigBaseCell.h"
#define cellSetIdentifier @"ZCConfigBaseCell"
#import "ZCConfigDetailController.h"

#import "ZCConfigCodeCell.h"
#define cellCodeIdentifier @"ZCConfigCodeCell"

#import "EntityConvertUtils.h"
#import "ZCTestSplitController.h"


@interface ZCConfigDetailController ()<UITableViewDelegate,UITableViewDataSource,ZCConfigBaseCellDelegate,ZCConfigCodeDelegate>{
    UITextField *_tempTextField;
    UITextView *_tempTextView;
    
    CGPoint        contentoffset;// 记录list的偏移量
}


@property (nonatomic,strong) UITableView * listTable;
@property (nonatomic,strong) NSMutableArray * dataArray;

// 事例代码
@property (nonatomic,strong) NSArray * codeUrls;

@end

@implementation ZCConfigDetailController


-(UIBarButtonItem *) createItemButtonWith:(ZCButtonClickTag) tag{
    //12 * 19
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeSystem];
    [btn.titleLabel setFont:[UIFont systemFontOfSize:16]];
    btn.frame = CGRectMake(0, 0, 44,44) ;
    btn.tag = tag;
//    [btn setTitleColor:UIColorFromRGB(0x1293F7) forState:UIControlStateNormal];
    
    [btn addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
    
    if(tag == BUTTON_SEND){
        [btn setTitle:@"保存" forState:UIControlStateNormal];
    }
        
    UIBarButtonItem *item = [[UIBarButtonItem alloc]initWithCustomView:btn];
    return item;
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

-(UIButton *)createItemButton:(NSString *) title f:(CGRect) frame tag:(int) index{
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    [btn setTitle:title forState:UIControlStateNormal];
    [btn setFrame:frame];
    btn.backgroundColor = UIColor.whiteColor;
    btn.layer.borderColor = UIColor.lightGrayColor.CGColor;
    btn.tag = index;
    btn.layer.borderWidth = 1.0f;
//    btn.layer.cornerRadius = 5;
    [btn setTitleColor:UIColor.blueColor forState:0];
    [btn addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
    return btn;
}

-(void)tapHideKeyboard{
    if(_tempTextView!=nil){
        [_tempTextView resignFirstResponder];
        _tempTextView = nil;
    }else if(_tempTextField!=nil){
        [_tempTextField resignFirstResponder];
        _tempTextField  = nil;
    }else{
        [self allHideKeyBoard];
    }
    
}

- (void) hideKeyboard {
    if(_tempTextView!=nil){
        [_tempTextView resignFirstResponder];
        _tempTextView = nil;
    }else if(_tempTextField!=nil){
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



-(void)createTableView{
    _dataArray = [[NSMutableArray alloc] init];
    
    if (@available(iOS 11.0, *)) {
        _listTable = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, ScreenWidth, ScreenHeight - NavBarHeight) style:UITableViewStylePlain];
    } else {
        _listTable = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, ScreenWidth, ScreenHeight - 64) style:UITableViewStylePlain];
        // Fallback on earlier versions
    }
    _listTable.delegate = self;
    _listTable.dataSource = self;
    if (@available(iOS 13.0, *)) {
        _listTable.backgroundColor = UIColorFromRGB(0xF2F2F7);
    } else {
        // Fallback on earlier versions
        _listTable.backgroundColor = UIColor.lightGrayColor;
    }
    [self.view addSubview:_listTable];
    
    [_listTable registerClass:[ZCConfigBaseCell class] forCellReuseIdentifier:cellSetIdentifier];
    [_listTable registerClass:[ZCConfigCodeCell class] forCellReuseIdentifier:cellCodeIdentifier];
    // 注册cell
    
    UIView * footView = [[UIView alloc]initWithFrame:CGRectMake(0, 1, ScreenWidth, 64)];
    _listTable.tableFooterView = footView;
    [_listTable setSeparatorColor:UIColorFromRGB(0xdadada)];
    [_listTable setSeparatorStyle:UITableViewCellSeparatorStyleSingleLine];
    [self setTableSeparatorInset];
    
//    UIButton *btn = [self createItemButton:@"保存" f:CGRectMake(12, 10, ScreenWidth - 24, 44) tag:0];
//    btn.layer.borderColor = UIColorFromRGB(0xEDEEF0).CGColor;
//    btn.layer.borderWidth = 0.5f;
//    btn.layer.cornerRadius = 22.0f;
//    btn.layer.masksToBounds = YES;
//    [footView addSubview:btn];
    
    NSArray *arr = [[ZCGuideData getZCGuideData] getConfigItems:_sectionData[@"code"]];
    _codeUrls = [[ZCGuideData getZCGuideData] getCodeStype:_sectionData[@"code"]];
    
    for (NSDictionary *item in arr) {
        // 交换赋值
        NSMutableDictionary *muldict = [NSMutableDictionary dictionaryWithDictionary:item];
        NSString *value = @"";
        NSInteger from = [item[@"from"] integerValue];
        NSString *key = convertToString(item[@"key"]);
        NSString *ptype = item[@"type"];
        
           if(from == ZCConfigFromClient){
              if([@"api_host" isEqual:item[@"key"]]){
                  value = convertToString([ZCGuideData getZCGuideData].apiHost);
              }else{
                  if([@"NSString" isEqual:ptype]){
                      value = [[ZCLibClient getZCLibClient] valueForKey:key];
                  }
              }
           }
           if(from == ZCConfigFromLibInit){
               if([@"MNSString" isEqual:ptype]){
                   value = [EntityConvertUtils DataTOjsonString:[[ZCGuideData getZCGuideData].libInitInfo valueForKey:key]];
               }else if([@"NSString" isEqual:ptype]){
                   value = convertToString([[ZCGuideData getZCGuideData].libInitInfo valueForKey:key]);
               }
           }
           if(from == ZCConfigFromKit){
               if([@"UIColor" isEqual:ptype]){
                   value = [EntityConvertUtils hexStringFromColor:[[ZCGuideData getZCGuideData].kitInfo valueForKey:key]];
               }else if([@"UIFont" isEqual:ptype]){
                   UIFont *font = [[ZCGuideData getZCGuideData].kitInfo valueForKey:key];
                   value = [NSString stringWithFormat:@"%.1f",font.pointSize];
               }else{
                   value = convertToString([[ZCGuideData getZCGuideData].kitInfo valueForKey:key]);
               }
           }
        muldict[@"value"] = value;
        [_dataArray addObject:muldict];
    }
}



- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.navigationController.navigationBar.translucent = NO;

    self.navigationItem.rightBarButtonItems = @[[self createItemButtonWith:BUTTON_SEND]];
    self.title = convertToString(_sectionData[@"name"]);
    [self createTableView];
    
}

-(void)buttonClick:(UIButton *)sender{
    [self hideKeyboard];
    NSString *tips=@"保存信息\n";
    BOOL isBaseInfo = NO;
    for (NSDictionary *item in _dataArray) {
        if([item.allKeys containsObject:@"value"]){
            NSString *value = item[@"value"];
            NSInteger from = [item[@"from"] integerValue];
            if(from == ZCConfigFromClient){
                if([@"api_host" isEqual:item[@"key"]]){
                    [ZCGuideData getZCGuideData].apiHost = value;
                    
                    isBaseInfo = YES;
                    [[NSUserDefaults standardUserDefaults] setObject:value forKey:@"ZC_Host"];
                }else{
                    [[ZCLibClient getZCLibClient] setValue:value forKey:item[@"key"]];
                }
            }

            NSString *ptype = item[@"type"];
            if(from == ZCConfigFromLibInit){
                if([@"MNSString" isEqual:ptype]){
                    id obj = [EntityConvertUtils dictionaryWithJsonString:value];
                    [[ZCGuideData getZCGuideData].libInitInfo setValue:obj forKey:item[@"key"]];
                }else{
                    if([@"app_key" isEqual:item[@"key"]]){

                        [[NSUserDefaults standardUserDefaults] setObject:value forKey:@"ZC_APPKEY"];
                    }
                    [[ZCGuideData getZCGuideData].libInitInfo setValue:value forKey:item[@"key"]];
                }
            }
            if(from == ZCConfigFromKit){
                if([@"isSendInfoCard" isEqual:item[@"key"]]){
                    if([value boolValue]){
                        // 商品的自定义类 ZCProductInfo  如果选择添加商品信息，请添加以下信息，其中标题"title"和页面地址url"link"是必填字段，如果没有添加页面中是不会显示的。
                        
                        ZCProductInfo *productInfo = [ZCProductInfo new];
                        // 发送商品信息，可不填
                        productInfo.thumbUrl = @"http://icon.nipic.com/BannerPic/20200706/original/20200706102839_1.jpg";
                        productInfo.title = @"标题标题标题标题标题标题";
                        productInfo.desc = @"描述描述描述描述描述描述";
                        productInfo.label = @"标签1111";
                        productInfo.link = @"www.baidu.com";
                        [ZCGuideData getZCGuideData].kitInfo.productInfo = productInfo;
                        [ZCGuideData getZCGuideData].kitInfo.isSendInfoCard = YES;
                    }else{
                        [ZCGuideData getZCGuideData].kitInfo.productInfo = nil;
                        [ZCGuideData getZCGuideData].kitInfo.isSendInfoCard = NO;
                    }
                }else if([@"autoSendOrderMessage" isEqual:item[@"key"]]){
                    if([value boolValue]){
                        ZCOrderGoodsModel *model = [ZCOrderGoodsModel new];
                        model.orderStatus = 1;
                        model.createTime = [NSString stringWithFormat:@"%.0f",[[NSDate date] timeIntervalSince1970]*1000];
                        model.goodsCount = @"3";
                        model.orderUrl  = @"https://www.sobot.com";
                        model.orderCode = @"1000234242342345";
                        model.goods =@[@{@"name":@"商品名称",@"pictureUrl":@"http://pic25.nipic.com/20121112/9252150_150552938000_2.jpg"},@{@"name":@"商品名称",@"pictureUrl":@"http://pic31.nipic.com/20130801/11604791_100539834000_2.jpg"}];
                        
                        // 单位是分，显示时会除以100，比如48.90
                        model.totalFee = @"4890";
                        [ZCGuideData getZCGuideData].kitInfo.orderGoodsInfo = model;
                        [ZCGuideData getZCGuideData].kitInfo.autoSendOrderMessage = YES;
                    }else{
                        [ZCGuideData getZCGuideData].kitInfo.orderGoodsInfo = nil;
                        [ZCGuideData getZCGuideData].kitInfo.autoSendOrderMessage = NO;
                    }
                }else{
                    if([@"UIColor" isEqual:ptype]){
                        
                        [[ZCGuideData getZCGuideData].kitInfo setValue:[EntityConvertUtils colorWithHexString:value] forKey:item[@"key"]];
                    }else if([@"UIFont" isEqual:ptype]){
                        if(value!=nil && [value floatValue] > 0 && [value floatValue] < 50){
                            [[ZCGuideData getZCGuideData].kitInfo setValue:[UIFont fontWithName:@"Helvetica" size:[value floatValue]] forKey:item[@"key"]];
                        }
                    }else{
                        [[ZCGuideData getZCGuideData].kitInfo setValue:value forKey:item[@"key"]];
                    }
                }
            }
            
            tips = [tips stringByAppendingFormat:@"%@：%@\n",item[@"name"],item[@"value"]];
        }
    }
    
    [ZCLibClient getZCLibClient].libInitInfo = [ZCGuideData getZCGuideData].libInitInfo;
    if(isBaseInfo){
        if([[ZCLibClient getZCLibClient] getInitState] && convertToString([ZCLibClient getZCLibClient].platformUnionCode).length > 0){
            [[ZCGuideData getZCGuideData] showAlertTips:tips vc:self];
        }else{
            [ZCSobotApi initSobotSDK:[ZCGuideData getZCGuideData].libInitInfo.app_key host:[ZCGuideData getZCGuideData].apiHost result:^(id  _Nonnull object) {
                [[ZCGuideData getZCGuideData] showAlertTips:object vc:self blcok:^(int code) {
                    [self.navigationController popViewControllerAnimated:YES];
                }];
            }];
        }
    }else{
        [[ZCGuideData getZCGuideData] showAlertTips:tips vc:self];
    }
    
}

-(void)openURLString:(NSString *)url{
    ZCUIWebController *web = [[ZCUIWebController alloc] initWithURL:url];
    UINavigationController * navc = [[UINavigationController alloc]initWithRootViewController:web];
    navc.modalPresentationStyle = UIModalPresentationOverFullScreen;
    [self presentViewController:navc animated:YES completion:^{
        
    }];
}


-(void)itemChangedCellOnClick:(NSString *)value dict:(NSDictionary *)dict indexPath:(NSIndexPath *)indexPath{

    // 交换赋值
    NSMutableDictionary *muldict = [NSMutableDictionary dictionaryWithDictionary:dict];
    muldict[@"value"] = value;
    _dataArray[indexPath.row] = muldict;
}

-(void)didKeyboardWillShow:(NSIndexPath *)indexPath view1:(UITextView *)textview view2:(UITextField *)textField{
    _tempTextView = textview;
    _tempTextField = textField;
    
    //获取当前cell在tableview中的位置
    CGRect rectintableview=[_listTable rectForRowAtIndexPath:indexPath];
    
    //获取当前cell在屏幕中的位置
    CGRect rectinsuperview = [_listTable convertRect:rectintableview fromView:[_listTable superview]];
    
    contentoffset = _listTable.contentOffset;
    
    if ((rectinsuperview.origin.y+50 - _listTable.contentOffset.y)>200) {
        
        [_listTable setContentOffset:CGPointMake(_listTable.contentOffset.x,((rectintableview.origin.y-_listTable.contentOffset.y)-150)+  _listTable.contentOffset.y) animated:YES];
        
    }
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
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    CGFloat sectionHeaderHeight = 40;
    if (scrollView.contentOffset.y<=sectionHeaderHeight&&scrollView.contentOffset.y>=0) {
        scrollView.contentInset = UIEdgeInsetsMake(-scrollView.contentOffset.y, 0, 0, 0);
    }
    else if (scrollView.contentOffset.y>=sectionHeaderHeight) {
        scrollView.contentInset = UIEdgeInsetsMake(-sectionHeaderHeight, 0, 0, 0);
    }
}
-(void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    //    [self hideKeyboard];
    [self allHideKeyBoard];
}
#pragma mark UITableView delegate Start
// 返回section数
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 2;
}

// 返回section高度
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    
    return 40;
}

// 返回section 的View
-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    UIView *view=[[UIView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, 40)];
    [view setBackgroundColor:[UIColor clearColor]];
    
    UILabel *lbl=[[UILabel alloc] initWithFrame:CGRectMake(20, 0, ScreenWidth-40, 40)];
    
    lbl.backgroundColor = [UIColor clearColor];
    [lbl setTextAlignment:NSTextAlignmentLeft];
    [lbl setTextColor:UIColorFromRGB(0x333333)];
    // 没有更多记录的颜色
    [lbl setAutoresizesSubviews:YES];
    [lbl setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
    if(section == 1){
        [lbl setText:@"参考文档"];
    }else{
        [lbl setText:_sectionData[@"name"]];
    }
    [view addSubview:lbl];
    return view;
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
        return 1;
    }
    return _dataArray.count;
}

// cell
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    if(indexPath.section == 1){

        ZCConfigCodeCell   *cell = [tableView dequeueReusableCellWithIdentifier:cellCodeIdentifier];
        if (cell == nil) {
            cell = [[ZCConfigCodeCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellCodeIdentifier];
        }
        cell.selectionStyle=UITableViewCellSelectionStyleNone;
        [cell setBackgroundColor:[UIColor whiteColor]];
        cell.delegate = self;
        [cell dataToView:_codeUrls];
        return cell;
    }
    ZCConfigBaseCell   *cell = [tableView dequeueReusableCellWithIdentifier:cellSetIdentifier];
    if (cell == nil) {
        cell = [[ZCConfigBaseCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellSetIdentifier];
    }
    cell.delegate = self;
    cell.indexPath = indexPath;
    cell.selectionStyle=UITableViewCellSelectionStyleNone;
    [cell setBackgroundColor:[UIColor whiteColor]];
    NSDictionary *item = _dataArray[indexPath.row];
   
    
    if(item){
        [cell dataToView:item];
    }
    
    return cell;
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
    
    
    
    NSDictionary *item = _dataArray[indexPath.row];
    NSString *code = item[@"code"];
    
    if([@"4.5.1.1" isEqual:code]){
        [[ZCGuideData getZCGuideData] showAlertTips:[NSString stringWithFormat:@"当前消息数:%d",[ZCSobotApi getUnReadMessage]] vc:self];
    }
    if([@"4.5.1.2" isEqual:code]){
        [ZCSobotApi clearUnReadNumber:[ZCLibClient getZCLibClient].libInitInfo.partnerid];
        [[ZCGuideData getZCGuideData] showAlertTips:[NSString stringWithFormat:@"已清理%@的当前消息数:%d",[ZCGuideData getZCGuideData].libInitInfo.partnerid,[ZCSobotApi getUnReadMessage]] vc:self];
    }
    if([@"4.7.8" isEqual:code]){
        if([[ZCLocalStore getLocalParamter:ZCLOCALAUTO_MATCHTIMEZONE] boolValue]){
            [ZCSobotApi setAutoMatchTimeZone:NO];
            [[ZCGuideData getZCGuideData] showAlertTips:[NSString stringWithFormat:@"已关闭自动适配时区"] vc:self];
        }else{
            [ZCSobotApi setAutoMatchTimeZone:YES];
            [[ZCGuideData getZCGuideData] showAlertTips:[NSString stringWithFormat:@"已开启自动适配时区"] vc:self];
        }
    }
    if([@"4.7.9" isEqual:code]){
        if(!isiPad){
            [[ZCGuideData getZCGuideData] showAlertTips:[NSString stringWithFormat:@"此功能仅支持ipad"] vc:self];
            return;
        }
        ZCTestSplitController *vc = [[ZCTestSplitController alloc] init];
        vc.modalPresentationStyle = UIModalPresentationFullScreen;
        UINavigationController *nvc = [[UINavigationController alloc] initWithRootViewController:vc];
        [self presentViewController:nvc animated:YES completion:^{
            
        }];
    }
    if([@"4.3.7.1" isEqual:code]){
        
        [ZCSobotApi initSobotSDK:[ZCGuideData getZCGuideData].libInitInfo.app_key result:^(id  _Nonnull object) {
            if([object hasSuffix:@"加载完成"]){
                    [ZCSobotApi openLeave:0 kitinfo:[ZCGuideData getZCGuideData].kitInfo with:self onItemClick:^(NSString * _Nonnull msg, int code) {
                        
                    }];
            }
        }];
    }
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
