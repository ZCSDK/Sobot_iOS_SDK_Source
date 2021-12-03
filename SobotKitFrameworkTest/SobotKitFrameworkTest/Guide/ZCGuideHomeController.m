//
//  ZCGuideHomeController.m
//  SobotKitFrameworkTest
//
//  Created by zhangxy on 2020/7/16.
//  Copyright © 2020 zhichi. All rights reserved.
//

#import "ZCGuideHomeController.h"
#import "ZCGuideData.h"
#import "ZCSectionPropertyCell.h"
#define cellSetIdentifier @"ZCSectionPropertyCell"
#import "ZCConfigDetailController.h"

#import "ZCGuideActionController.h"

#import "EntityConvertUtils.h"

@interface ZCGuideHomeController ()<UITableViewDelegate,UITableViewDataSource>


@property (nonatomic,strong) UITableView * listTable;
@property (nonatomic,strong) NSMutableArray * dataArray;

@end

@implementation ZCGuideHomeController

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    self.navigationController.navigationBarHidden = NO;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationController.navigationBar.translucent = NO;
    // Do any additional setup after loading the view.
    [self createTableView];
    self.navigationController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName : UIColorFromRGB(0x333333)};
}



-(void)createTableView{
    _dataArray =  [NSMutableArray arrayWithArray:[ZCGuideData getZCGuideData].getSectionArray];
    CGFloat w = self.view.frame.size.width;
    _listTable = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, w,ScreenHeight - NavBarHeight) style:UITableViewStylePlain];
    _listTable.delegate = self;
    _listTable.dataSource = self;
    if (@available(iOS 13.0, *)) {
        _listTable.backgroundColor = UIColorFromRGB(0xF2F2F7);
    } else {
        // Fallback on earlier versions
        _listTable.backgroundColor = UIColor.lightGrayColor;
    }
    self.view.autoresizingMask=UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    self.view.autoresizesSubviews = YES;
    [self.view addSubview:_listTable];
    
    [_listTable registerClass:[ZCSectionPropertyCell class] forCellReuseIdentifier:cellSetIdentifier];
    // 注册cell
    
    UIView * footView = [[UIView alloc]initWithFrame:CGRectMake(0, 1, w, 0)];
    footView.backgroundColor = UIColorFromRGB(0xEFF3FA);
    _listTable.tableFooterView = footView;
    [_listTable setSeparatorColor:UIColorFromRGB(0xdadada)];
    [_listTable setSeparatorStyle:UITableViewCellSeparatorStyleSingleLine];
     [self setTableSeparatorInset];
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
#pragma mark UITableView delegate Start
// 返回section数
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return _dataArray.count;
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
    lbl.textColor = UIColorFromRGB(0x333333);
    [lbl setTextAlignment:NSTextAlignmentLeft];
    // 没有更多记录的颜色
    [lbl setAutoresizesSubviews:YES];
    [lbl setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
    [lbl setText:_dataArray[section]];
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
    return [[ZCGuideData getZCGuideData] getSectionListArray:section].count;
}

// cell
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    ZCSectionPropertyCell   *cell = [tableView dequeueReusableCellWithIdentifier:cellSetIdentifier];
    if (cell == nil) {
        cell = [[ZCSectionPropertyCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellSetIdentifier];
    }
    
    [cell setBackgroundColor:UIColorFromRGB(0xffffff)];
    
    cell.selectionStyle=UITableViewCellSelectionStyleNone;
    
    NSArray *arr = [[ZCGuideData getZCGuideData] getSectionListArray:indexPath.section];
    NSDictionary *item = arr[indexPath.row];
    if(item){
        [cell initWithNSDictionary:item];
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
    
    
    NSArray *arr = [[ZCGuideData getZCGuideData] getSectionListArray:indexPath.section];
    NSDictionary *item = arr[indexPath.row];
    ZCSectionIndex code = (ZCSectionIndex)[item[@"index"] integerValue];
    if(code == ZCSectionIndex331 ||
             code == ZCSectionIndex332 ||
             code == ZCSectionIndex341 ||
             code == ZCSectionIndex342 || 
             code == ZCSectionIndex343||
             code == ZCSectionIndex351||
             code == ZCSectionIndex353){
        ZCGuideActionController *vc = [[ZCGuideActionController alloc] init];
        vc.sectionData = item;
        [self.navigationController pushViewController:vc animated:YES];
    }else{
        ZCConfigDetailController *vc = [[ZCConfigDetailController alloc] init];
        vc.sectionData = item;
        [self.navigationController pushViewController:vc animated:YES];
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
