//
//  ZCGuideStartController.m
//  SobotKitFrameworkTest
//
//  Created by zhangxy on 2020/7/28.
//  Copyright © 2020 zhichi. All rights reserved.
//

#import "ZCGuideActionController.h"
#import "EntityConvertUtils.h"

@interface ZCGuideActionController ()

@end

#import "ZCGuideData.h"

#import "ZCConfigCodeCell.h"
#define cellCodeIdentifier @"ZCConfigCodeCell"

@interface ZCGuideActionController ()<UITableViewDelegate,UITableViewDataSource,ZCConfigCodeDelegate>{
    NSString *code;
}


@property (nonatomic,strong) UITableView * listTable;

// 事例代码
@property (nonatomic,strong) NSArray * codeUrls;

@end

@implementation ZCGuideActionController

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




- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.navigationController.navigationBar.translucent = NO;
    [self createTableView];
    
}

-(void)buttonClick:(UIButton *)sender{
    [ZCLibClient getZCLibClient].libInitInfo = [ZCGuideData getZCGuideData].libInitInfo;
    if([ZCLibClient getZCLibClient].libInitInfo.app_key == nil){
        [[ZCGuideData getZCGuideData] showAlertTips:@"请添加app_key" vc:self];
        return;
    }
    if([@"3.5" isEqual:code]){
        [ZCSobotApi outCurrentUserZCLibInfo:NO];
        [[ZCGuideData getZCGuideData] showAlertTips:@"离线调用完成" vc:self blcok:^(int code) {
            [self.navigationController popViewControllerAnimated:YES];
        }];
    }
    if([@"3.5.3" isEqual:code]){
        NSString *msg =  [ZCSobotApi readLogFileDateString:@"20200804"];
        if(msg == nil){
            msg = @"";
        }
        if(msg.length > 300){
            msg = [msg substringToIndex:299];
        }
        NSLog(@"%@",msg);
        
        [[ZCGuideData getZCGuideData] showAlertTips:msg vc:self blcok:^(int code) {
            //系统级别
            UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
            pasteboard.string = msg;
//            NSString *crashLogInfo = [NSString stringWithFormat:@"exception type : %@ \n crash reason : %@ \n call stack info : %@", name, reason, arr];
//            NSString *urlStr = [NSString stringWithFormat:@"mailto://mailto://__@163.com?subject=bug报告&body=感谢您的配合!错误详情:%@",crashLogInfo];
//            NSURL *url = [NSURL URLWithString:[urlStr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
//            [[UIApplication sharedApplication] openURL:url];
        }];
        
    }
    if([@"3.3.1" isEqual:code]){
        
        [ZCSobotApi initSobotSDK:[ZCLibClient getZCLibClient].libInitInfo.app_key host:[ZCGuideData getZCGuideData].apiHost result:^(id  _Nonnull object) {
            [[ZCGuideData getZCGuideData] showAlertTips:object vc:self];
        }];
    }
    if([@"3.3.1" isEqual:code]){
        [ZCSobotApi initSobotSDK:[ZCLibClient getZCLibClient].libInitInfo.app_key host:[ZCGuideData getZCGuideData].apiHost result:^(id  _Nonnull object) {
            [[ZCGuideData getZCGuideData] showAlertTips:object vc:self];
        }];
    }
    if([@"3.3.2" isEqual:code]){
//        [ZCLibClient getZCLibClient].platformUnionCode = @"";
//        [ZCLibClient getZCLibClient].libInitInfo.platform_key = @"";
        if([ZCLibClient getZCLibClient].platformUnionCode == nil){
            [[ZCGuideData getZCGuideData] showAlertTips:@"请添加电商编号" vc:self];
            return;
        }
        [ZCSobotApi initSobotSDK:[ZCLibClient getZCLibClient].libInitInfo.app_key host:[ZCGuideData getZCGuideData].apiHost result:^(id  _Nonnull object) {
            [[ZCGuideData getZCGuideData] showAlertTips:object vc:self];
        }];
    }
    if([@"3.4.1" isEqual:code]){
        if(![[ZCLibClient getZCLibClient] getInitState]){
            [[ZCGuideData getZCGuideData] showAlertTips:@"请添先初始化" vc:self];
            return;
        }
        
        [ZCSobotApi openZCChat:[ZCGuideData getZCGuideData].kitInfo with:self pageBlock:^(id  _Nonnull object, ZCPageBlockType type) {

        }];
    }
    
    if([@"3.4.2" isEqual:code]){
        if(![[ZCLibClient getZCLibClient] getInitState]){
            [[ZCGuideData getZCGuideData] showAlertTips:@"请添先初始化" vc:self];
            return;
        }
        [ZCSobotApi openZCChatListView:[ZCGuideData getZCGuideData].kitInfo with:self onItemClick:^(ZCUIChatListController * _Nonnull object, ZCPlatformInfo * _Nonnull info) {
            [ZCLibClient getZCLibClient].libInitInfo.app_key = info.app_key;
            [ZCSobotApi openZCChat:[ZCGuideData getZCGuideData].kitInfo with:self pageBlock:^(id  _Nonnull object, ZCPageBlockType type) {
                
            }];
        }];
    }
    
    if([@"3.4.3" isEqual:code]){
        if(![[ZCLibClient getZCLibClient] getInitState]){
            [[ZCGuideData getZCGuideData] showAlertTips:@"请添先初始化" vc:self];
            return;
        }
        [ZCSobotApi openZCServiceCenter:[ZCGuideData getZCGuideData].kitInfo with:self onItemClick:^(ZCUIBaseController * _Nonnull object) {
            [ZCSobotApi openZCChat:[ZCGuideData getZCGuideData].kitInfo with:self pageBlock:^(id  _Nonnull object, ZCPageBlockType type) {
                
            }];
        }];
    }
    
    if([@"3.6" isEqual:code]){
        if(![[ZCLibClient getZCLibClient] getInitState]){
            [[ZCGuideData getZCGuideData] showAlertTips:@"请添先初始化" vc:self];
            return;
        }
        [ZCSobotApi openZCServiceCenter:[ZCGuideData getZCGuideData].kitInfo with:self onItemClick:^(ZCUIBaseController * _Nonnull object) {
            [ZCSobotApi openZCChat:[ZCGuideData getZCGuideData].kitInfo with:self pageBlock:^(id  _Nonnull object, ZCPageBlockType type) {
                
            }];
        }];
    }
}





-(void)createTableView{
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
    [_listTable registerClass:[ZCConfigCodeCell class] forCellReuseIdentifier:cellCodeIdentifier];
    // 注册cell
    
    UIView * footView = [[UIView alloc]initWithFrame:CGRectMake(0, 1, ScreenWidth, 64)];
    _listTable.tableFooterView = footView;
    [_listTable setSeparatorColor:UIColorFromRGB(0xdadada)];
    [_listTable setSeparatorStyle:UITableViewCellSeparatorStyleSingleLine];
    [self setTableSeparatorInset];
    
    UIButton *btn = [self createItemButton:_sectionData[@"name"] f:CGRectMake(12, 10, ScreenWidth - 24, 44) tag:0];
    btn.layer.borderColor = UIColorFromRGB(0xEDEEF0).CGColor;
    btn.layer.borderWidth = 0.5f;
    btn.layer.cornerRadius = 22.0f;
    btn.layer.masksToBounds = YES;
    [footView addSubview:btn];
    
    code = _sectionData[@"code"];
    _codeUrls = [[ZCGuideData getZCGuideData] getCodeStype:code];
}


-(void)openURLString:(NSString *)url{
    ZCUIWebController *web = [[ZCUIWebController alloc] initWithURL:url];
    UINavigationController * navc = [[UINavigationController alloc]initWithRootViewController:web];
    navc.modalPresentationStyle = UIModalPresentationOverFullScreen;
    [self presentViewController:navc animated:YES completion:^{
        
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
    
}
#pragma mark UITableView delegate Start
// 返回section数
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
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
    [lbl setTextColor:UIColorFromRGB(0x333333)];
    [lbl setTextAlignment:NSTextAlignmentLeft];
    // 没有更多记录的颜色
    [lbl setAutoresizesSubviews:YES];
    [lbl setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
    [lbl setText:@"参考文档"];
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
    return 1;
}

// cell
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
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

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
