//
//  ZCServiceListVC.m
//  SobotKit
//
//  Created by lizhihui on 2019/3/28.
//  Copyright © 2019 zhichi. All rights reserved.
//

#import "ZCServiceListVC.h"
#import "ZCUICore.h"
#import "ZCUIImageTools.h"
#import "ZCUIImageTools.h"
#import "ZCLibGlobalDefine.h"
#import "ZCUIColorsDefine.h"
#import "ZCLibServer.h"
#import "ZCSCListModel.h"
#import "ZCServiceListCell.h"
#define  serviceCelIdentifier   @"ZCServiceListCell"
#import "ZCLibServer.h"
#import "ZCServiceDetailVC.h"
#import "ZCUIToastTools.h"
#import "ZCToolsCore.h"

@interface ZCServiceListVC ()<UITableViewDelegate,UITableViewDataSource>{
    
    // 屏幕宽高
//    CGFloat                     viewWidth;
//    CGFloat                     viewHeigth;
    
    NSMutableArray   *_listArray;
    UITableView * _listView;
}

//当页面的list数据为空时，给它一个带提示的占位图。
@property(nonatomic,strong) UIView *placeholderView;

@end

@implementation ZCServiceListVC

#pragma mark -- 横竖屏切换问题

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

-(void)buttonClick:(UIButton *)sender{
    if (sender.tag == BUTTON_BACK) {
        if (self.navigationController) {
            [self.navigationController popViewControllerAnimated:NO];
        }else{
            [self dismissViewControllerAnimated:NO completion:nil];
        }
    }
}

- (void)viewDidAppear:(BOOL) animated{
    [super viewDidAppear:animated];
    
}
- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    if ([ZCUICore getUICore].kitInfo.navcBarHidden) {
        self.navigationController.navigationBarHidden = YES;
    }
    
    if(!self.navigationController.navigationBarHidden){
        self.navigationController.navigationBar.translucent = NO;
        [self setNavigationBarStyle];
        self.title = self.titleName;
        [self.navigationController.navigationBar setTitleTextAttributes:@{NSFontAttributeName:[ZCUITools zcgetscTopTextFont],NSForegroundColorAttributeName:[ZCUITools zcgetscTopTextColor]}];
    }else{
        [self createTitleViewWith:1];
        self.titleLabel.text = self.titleName;
        self.titleLabel.font = ZCUIFont17;
        [self.moreButton setImage:nil forState:UIControlStateNormal];
        [self.moreButton setImage:nil forState:UIControlStateHighlighted];
    }
    

    self.view.backgroundColor = UIColorFromThemeColor(ZCBgLightGrayDarkColor);
    NSLog(@"viewdidLoad：%@",NSStringFromCGRect(self.view.frame));
    _listArray = [NSMutableArray arrayWithCapacity:0];
    
    [self createSubviews];
   
    
    [self loadData];
}

-(void)createSubviews{
    CGFloat y = 0;
    if(self.navigationController.navigationBarHidden){
        y = NavBarHeight;
    }
    y = y + 12;
    _listView = [[UITableView alloc]initWithFrame:CGRectMake(0, y, [self getCurViewWidth], [self getCurViewHeight] - y - XBottomBarHeight) style:UITableViewStylePlain];
//    [_listView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"cell"]; 多轮问法转人工
    
    [_listView setAutoresizingMask:UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight];
    [_listView setAutoresizesSubviews:YES];
    [_listView registerClass:[ZCServiceListCell class] forCellReuseIdentifier:serviceCelIdentifier];
    _listView.dataSource = self;
    _listView.delegate = self;
    _listView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view addSubview:_listView];
    // 关闭安全区域，否则UITableViewCell横屏时会是全屏的宽
    NSString *version = [UIDevice currentDevice].systemVersion;
    if (version.doubleValue >= 11.0) {
       [_listView setInsetsContentViewsToSafeArea:NO];
    }
     _listView.backgroundColor = UIColorFromThemeColor(ZCBgLightGrayDarkColor);
    
    
    UIView * footView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, [self getCurViewWidth], 15)];
    _listView.tableFooterView = footView;
    
    [_listView setSeparatorColor:UIColorFromThemeColor(ZCBgLineColor)];
    [_listView setSeparatorStyle:UITableViewCellSeparatorStyleSingleLine];

    [self setTableSeparatorInset];

}

-(void)viewDidLayoutSubviews{
    [super viewDidLayoutSubviews];
    [self setTableSeparatorInset];
    
//    if (viewWidth != self.view.frame.size.width || viewHeigth != self.view.frame.size.height) {

        CGFloat viewHeigth = self.view.frame.size.height;
        CGFloat viewWidth = self.view.frame.size.width;
        
        CGFloat y = 0;
        if (self.navigationController.navigationBarHidden) {
           y = NavBarHeight;
       }else{
           if(self.navigationController.navigationBar.translucent && viewHeigth == ScreenHeight){
               viewHeigth = ScreenHeight - NavBarHeight;
           }
       }
        y = y + 12;
        CGFloat scrollHeight = viewHeigth - y - XBottomBarHeight;
        
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
        [_listView setFrame:CGRectMake(spaceX, y, LW, scrollHeight)];
        [_listView reloadData];
//    }
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 54;
}


-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _listArray.count;
}

-(UIView *) tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    UIView *lineView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, [self getCurViewWidth], 0.1)];
    lineView.backgroundColor = UIColorFromThemeColor(ZCBgLineColor);
    return lineView;
    
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if(_listArray.count == 0){
           return 0;
       }
       return 1;
}
-(UIView*)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    
    UIView *lineView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, [self getCurViewWidth], 0.1)];
    lineView.backgroundColor = UIColorFromThemeColor(ZCBgLineColor);
    return lineView;
}
-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    if(_listArray.count == 0){
        return 0;
    }
    return 1;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    ZCServiceListCell * cell = [tableView dequeueReusableCellWithIdentifier:serviceCelIdentifier];
    if (cell == nil) {
        cell = [[ZCServiceListCell alloc]initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:serviceCelIdentifier];
    }
    if(_listArray==nil || _listArray.count<indexPath.row){
        return cell;
    }
    
    ZCSCListModel * model = _listArray[indexPath.row];
    
    [cell initWithModel:model width:_listView.frame.size.width];
    [cell setBackgroundColor:UIColorFromThemeColor(ZCBgSystemWhiteLightDarkColor)];
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    return cell;
}

/**
 *  设置UITableView分割线空隙
 */
-(void)setTableSeparatorInset{
    UIEdgeInsets inset = UIEdgeInsetsMake(0, 0, 0, 0);
    if ([_listView respondsToSelector:@selector(setSeparatorInset:)]) {
        [_listView setSeparatorInset:inset];
    }
    
    if ([_listView respondsToSelector:@selector(setLayoutMargins:)]) {
        [_listView setLayoutMargins:inset];
    }
}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    ZCSCListModel * model  = _listArray[indexPath.row];
    
    ZCServiceDetailVC *VC = [[ZCServiceDetailVC alloc]init];
    VC.appId = zcLibConvertToString(self.appId);
    VC.docId = zcLibConvertToString(model.docId);
    VC.questionTitle = zcLibConvertToString(model.questionTitle);
    [VC setOpenZCSDKTypeBlock:self.OpenZCSDKTypeBlock];
   
    if (self.navigationController) {
        [self.navigationController pushViewController:VC animated:NO];
    }else{
        [self presentViewController:VC animated:NO completion:nil];
    }
    
}

-(void)loadData{
    
//    [self createPlaceholderView:@"暂无相关内容" message:@"" image:nil withView:self.view action:nil];
    __weak ZCServiceListVC * saveSelf = self;
    [[ZCLibServer getLibServer] getHelpDocByCategoryIdWith:self.appId CategoryId:self.categoryId start:^{
        [[ZCUIToastTools shareToast] showProgress:@"" with:self.view];
    } success:^(NSDictionary *dict, ZCNetWorkCode sendCode) {
        
        if (dict) {
            NSArray * dataArr = dict[@"data"];
            if ([dataArr isKindOfClass:[NSArray class]] && dataArr.count > 0) {
                for (NSDictionary * item in dataArr) {
                    ZCSCListModel * model = [[ZCSCListModel alloc]initWithMyDict:item];
                    [_listArray addObject:model];
                }
                if (_listArray.count > 0) {
                    [saveSelf removePlaceholderView];
                    [_listView reloadData];
                }else{
                    [saveSelf createPlaceholderView:ZCSTLocalString(@"暂无相关内容") message:@"" image:nil withView:self.view action:nil];
                }
            }else{
                [saveSelf createPlaceholderView:ZCSTLocalString(@"暂无相关内容") message:@"" image:nil withView:self.view action:nil];
            }
        }
        
        [[ZCUIToastTools shareToast] dismisProgress];
    } failed:^(NSString *errorMessage, ZCNetWorkCode errorCode) {
        [[ZCUIToastTools shareToast] dismisProgress];
        [saveSelf createPlaceholderView:ZCSTLocalString(@"暂无相关内容") message:@"" image:nil withView:self.view action:nil];
    }];
    
}

#pragma mark -- 处理占位 空态
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
    [_placeholderView setBackgroundColor:[UIColor clearColor]];
    //    [_placeholderView setBackgroundColor:[ZCUITools zcgetBackgroundColor]];
    [superView addSubview:_placeholderView];
    
    
    CGRect pf = CGRectMake(0, 0, superView.bounds.size.width, 0);
    UIImageView *icon = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"robot_default"]];
    if(image){
        [icon setImage:image];
    }
    [icon setContentMode:UIViewContentModeCenter];
    [icon setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
    icon.frame = CGRectMake(0,0, pf.size.width, image.size.height);
    [_placeholderView addSubview:icon];
    
    CGFloat y= icon.frame.size.height+20;
    if(title){
        CGFloat height=[self getHeightContain:title font:ZCUIFont14 Width:pf.size.width];
        
        UILabel *lblTitle=[[UILabel alloc] initWithFrame:CGRectMake(0, y, pf.size.width, height)];
        [lblTitle setText:title];
        [lblTitle setFont:ZCUIFont16];
        [lblTitle setTextColor:UIColorFromRGB(TextNetworkTipColor)];
        [lblTitle setTextAlignment:NSTextAlignmentCenter];
        [lblTitle setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
        [lblTitle setNumberOfLines:0];
        [lblTitle setBackgroundColor:[UIColor clearColor]];
        [_placeholderView addSubview:lblTitle];
        y=y+height+5;
    }
    
    if(message){
        UILabel *lblTitle=[[UILabel alloc] initWithFrame:CGRectMake(0, y, pf.size.width, 20)];
        [lblTitle setText:message];
        [lblTitle setFont:ZCUIFont14];
        [lblTitle setTextColor:UIColorFromThemeColor(ZCTextMainColor)];
        [lblTitle setTextAlignment:NSTextAlignmentCenter];
        [lblTitle setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
        [lblTitle setAutoresizesSubviews:YES];
        [lblTitle setBackgroundColor:[UIColor clearColor]];
        [_placeholderView addSubview:lblTitle];
        y=y+25;
    }
    
    
    pf.size.height= y;
    
    [_placeholderView setFrame:pf];
    [_placeholderView setCenter:CGPointMake(superView.center.x, superView.bounds.size.height/2-80)];
}

- (void)removePlaceholderView{
    if (_placeholderView && _placeholderView!=nil) {
        [_placeholderView removeFromSuperview];
        _placeholderView = nil;
    }
}


-(CGFloat)getHeightContain:(NSString *)string font:(UIFont *)font Width:(CGFloat) width
{
    if(string==nil){
        return 0;
    }
    //转化为格式字符串
    NSAttributedString *astr = [[NSAttributedString alloc]initWithString:string attributes:@{NSFontAttributeName:font}];
    CGSize contansize=CGSizeMake(width, CGFLOAT_MAX);
    if(iOS7){
        CGRect rec = [astr boundingRectWithSize:contansize options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading context:nil];
        return rec.size.height;
    }else{
        CGSize s=[string sizeWithFont:font constrainedToSize:contansize lineBreakMode:NSLineBreakByCharWrapping];
        return s.height;
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
