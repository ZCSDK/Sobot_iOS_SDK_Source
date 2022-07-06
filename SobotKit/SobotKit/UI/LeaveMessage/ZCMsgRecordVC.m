//
//  ZCMsgRecordVC.m
//  SobotKit
//
//  Created by lizhihui on 2019/2/19.
//  Copyright © 2019 zhichi. All rights reserved.
//

#import "ZCMsgRecordVC.h"

#import "ZCLibGlobalDefine.h"
#import "ZCUIColorsDefine.h"
#import "ZCMsgRecordCell.h"
#import "ZCUICore.h"
#import "ZCPlatformTools.h"
#import "ZCRecordListModel.h"
#define cellRecordIdentifier @"ZCMsgRecordCell"

@interface ZCMsgRecordVC ()<UITableViewDataSource,UITableViewDelegate>

@property (nonatomic,strong) UITableView * listView;

@property (nonatomic,strong) NSMutableArray * listArray;

//当页面的list数据为空时，给它一个带提示的占位图。
@property(nonatomic,strong) UIView *placeholderView;

@end

@implementation ZCMsgRecordVC

- (void)viewDidLoad {
    [super viewDidLoad];
    _listArray = [NSMutableArray arrayWithCapacity:0];
    
    self.view.backgroundColor = [ZCUITools zcgetBackgroundColor]; //UIColorFromRGB(0xF9FAFB);
    if (self.navigationController.navigationBar.translucent) {
        self.navigationController.navigationBar.translucent = NO;
    }
    [self createListView];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    [self loadData];
}

-(void)createListView{
    _listView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height) style:UITableViewStylePlain];
    
    _listView.backgroundColor = [ZCUITools zcgetLightGrayDarkBackgroundColor];//UIColorFromRGB(0xF9FAFB);
    _listView.dataSource = self;
    _listView.delegate = self;
    _listView.layer.masksToBounds = YES;
    
    _listView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleBottomMargin;
    _listView.autoresizesSubviews = YES;
    [self.view addSubview:_listView];
    [_listView registerClass:[ZCMsgRecordCell class] forCellReuseIdentifier:cellRecordIdentifier];
   // 关闭安全区域，否则UITableViewCell横屏时会是全屏的宽
   NSString *version = [UIDevice currentDevice].systemVersion;
   if (version.doubleValue >= 11.0) {
       [_listView setInsetsContentViewsToSafeArea:NO];
   }
    if (version.doubleValue >= 15.0) {
        _listView.sectionHeaderTopPadding = 0;
    }
    _listView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
   
//    UIView * footView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, ScreenWidth, 125)];
//    footView.backgroundColor = [UIColor clearColor];
//    _listView.tableFooterView = footView;
    _listArray = [NSMutableArray arrayWithCapacity:0];
    // 加载数据
    [self loadData];
}

-(ZCLibConfig *)getCurConfig{
    return [[ZCPlatformTools sharedInstance] getPlatformInfo].config;
}


-(void)loadData{

    [[[ZCUICore getUICore] getAPIServer] postUserTicketInfoListWithConfig:[self getCurConfig] start:^{
        
    } success:^(NSDictionary *dict, NSMutableArray *itemArray, ZCNetWorkCode sendCode) {
        @try{
            if (dict && itemArray.count >0) {
                [self removePlaceholderView];
                [_listArray removeAllObjects];
                _listArray = itemArray;
                [self.listView reloadData];
            }
            else{
                    [self createPlaceholderView:ZCSTLocalString(@"暂无相关信息") message:@"" image:nil withView:self.view action:nil];
            }
            
        } @catch (NSException *exception) {
            
        } @finally {
            
        }
        
    } failed:^(NSString *errorMessage, ZCNetWorkCode errorCode) {
        
    }];
}

// 返回section数
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

// 返回section高度
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    
    return 0;
}

// 返回section 的View
-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    UIView *view=[[UIView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, 10)];
    if (section == 0) {
        view.frame = CGRectMake(0, 0, 0, 0 );
    }
    return view;
}


// 返回section下得行数
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _listArray.count;
}

// cell
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    ZCMsgRecordCell * cell = (ZCMsgRecordCell*)[tableView dequeueReusableCellWithIdentifier:cellRecordIdentifier];
    if (cell == nil) {
        cell = [[ZCMsgRecordCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellRecordIdentifier];
    }
    if ( indexPath.row > _listArray.count -1) {
        return cell;
    }
    ZCRecordListModel * model = _listArray[indexPath.row];
    [cell initWithDict:model with:self.listView.frame.size.width];
    [cell setSelectionStyle:UITableViewScrollPositionNone];
    return cell;
}



// table 行的高度
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
//    UITableViewCell *cell = [self tableView:tableView cellForRowAtIndexPath:indexPath];
//    return cell.frame.size.height;
    return ZCNumber(120);
}

// table 行的点击事件
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    ZCRecordListModel * model = _listArray[indexPath.row];
    [_listArray enumerateObjectsUsingBlock:^( ZCRecordListModel * item, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([item.ticketCode isEqual:model.ticketCode]) {
            model.newFlag = 1;
            *stop = YES;
        }
    }];
    [self.listView reloadData];
    if (self.jumpMsgDetailBlock) {
        self.jumpMsgDetailBlock(model);
    }
   
}


#pragma mark -- 刷新数据
-(void)updataWithHeight:(CGFloat)height viewWidth:(CGFloat)w{
//    self.listView = array;
    CGRect lf = self.listView.frame;
    lf.size.height = height;
    [self.view setFrame:CGRectMake(0,0, w, height)];
    self.listView.frame = lf;
    [self.listView reloadData];
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
        [lblTitle setFont:ZCUIFont14];
        [lblTitle setTextColor:UIColorFromThemeColor(ZCTextPlaceHolderColor)];
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
        [lblTitle setFont:ZCUIFont12];
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


@end
