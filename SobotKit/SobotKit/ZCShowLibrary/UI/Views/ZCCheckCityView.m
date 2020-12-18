//
//  ZCCheckCityView.m
//  SobotKit
//
//  Created by 张新耀 on 2019/10/10.
//  Copyright © 2019 zhichi. All rights reserved.
//

#import "ZCCheckCityView.h"

#import "ZCUIColorsDefine.h"
#import "ZCLibGlobalDefine.h"

#import "ZCUIImageTools.h"

#define cellIdentifier @"ZCUITableViewCell"

#import "ZCPageSheetView.h"
#import "ZCUICore.h"


@interface ZCCheckCityView()<UITableViewDelegate,UITableViewDataSource>{
    // 屏幕宽高
    CGFloat                     viewWidth;
    CGFloat                     viewHeigth;
}


@property(nonatomic,strong)UITableView      *listTable;


@property(nonatomic,strong)UIView       *topView;
@property(nonatomic,strong)UIButton     *backButton;
@property(nonatomic,strong)UIButton     *moreButton;
@property(nonatomic,strong)UILabel      *titleLabel;
@end

@implementation ZCCheckCityView

-(instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        //        self.frame = frame;
        self.userInteractionEnabled = YES;
        self.autoresizesSubviews = YES;
        self.clipsToBounds = YES;
        self.backgroundColor = UIColorFromThemeColor(ZCBgSystemWhiteLightDarkColor);
        [self createTableView];
        
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self createTableView];
    }
    return self;
}


-(void)setLevle:(int)levle{
    _levle = levle;
    
    [self loadAddressData];
}


-(void)loadAddressData{
    NSString * addId = @"";
    switch (_levle) {
        case 1:
            
            break;
        case 2:
            addId = _proviceId;
            break;
        case 3:
            addId = _cityId;
            break;
        default:
            break;
    }
    
    [[self getZCAPIServer] getAddressWithLevel:_levle nextaddressId:addId start:^{
        
    } success:^(NSDictionary *dict, ZCNetWorkCode sendCode) {
//        NSLog(@"%@",dict);
        NSArray * addressArr = [NSArray array];
        if (dict) {
            switch (_levle) {
                case 1:
                    addressArr = dict[@"data"][@"provinces"];
                    break;
                case 2:
                    addressArr = dict[@"data"][@"citys"];
                    break;
                case 3:
                    addressArr = dict[@"data"][@"areas"];
                    break;
                    
                default:
                    break;
            }
            
            for (NSDictionary * item in addressArr) {
                ZCAddressModel * model = [[ZCAddressModel alloc] initWithMyDict:item];
                if (self.levle ==3) {
                    model.provinceName = self.proviceName;
                    model.provinceId = self.proviceId;
                    model.cityId = self.cityId;
                    model.cityName = self.cityName;
                }else if(self.levle == 2){
                    model.provinceName = self.proviceName;
                    model.provinceId = self.proviceId;
                }
                [_listArray addObject:model];
            }
            [self reloadTabview];
        }
        
    } failed:^(NSString *errorMessage, ZCNetWorkCode errorCode) {
        
    }];
}

-(void)reloadTabview{
//    CGRect f = self.listTable.frame;
//    f.size.height = _listArray.count * 44;
//    if(f.size.height > ScreenHeight * 0.7){
//        f.size.height = ScreenHeight * 0.7;
//    }
//    _listTable.frame = f;
//    [self setFrame:CGRectMake(0, 0, ScreenWidth, f.size.height + ZCSheetTitleHeight)];
    

    [_listTable reloadData];
}


-(void)createTitleView{
    
    self.topView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, ZCSheetTitleHeight)];
    
    [self.topView setBackgroundColor:UIColorFromThemeColor(ZCBgSystemWhiteLightDarkColor)];
    [self.topView setAutoresizingMask:UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight];
    [self addSubview:self.topView];
    
    
    
    //    [self.topView addSubview:self.topImageView];
    
    self.titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(80,0, _topView.frame.size.width- 80*2, ZCSheetTitleHeight)];
    [self.titleLabel setTextAlignment:NSTextAlignmentCenter];
    [self.titleLabel setFont:[ZCUITools zcgetscTopTextFont]];
    [self.titleLabel setTextColor:[ZCUITools zcgetscTopTextColor]];
    
    self.titleLabel.text = zcLibConvertToString(_pageTitle);
    [self.titleLabel setBackgroundColor:[UIColor clearColor]];
    [self.titleLabel setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
    [self.titleLabel setAutoresizesSubviews:YES];
    
    
    self.backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.backButton setFrame:CGRectMake(20, 0, 64, ZCSheetTitleHeight)];
    [self.backButton.imageView setContentMode:UIViewContentModeScaleAspectFit];
    [self.backButton setImage:[ZCUITools zcuiGetBundleImage:@"zcicon_scback_gray"] forState:UIControlStateNormal];
    [self.backButton setImage:[ZCUITools zcuiGetBundleImage:@"zcicon_scback_gray"] forState:UIControlStateHighlighted];
    [self.backButton setImageEdgeInsets:UIEdgeInsetsMake(0, 0, 0, 20)];
    [self.backButton setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
    [self.backButton setAutoresizesSubviews:YES];
    [self.backButton setAutoresizingMask:UIViewAutoresizingFlexibleRightMargin];
    self.backButton.tag = BUTTON_BACK;
    [self.backButton addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
    
    self.backButton.hidden = YES;
    
    self.moreButton=[UIButton buttonWithType:UIButtonTypeCustom];
    [self.moreButton setFrame:CGRectMake(_topView.frame.size.width-64, 0, 64, ZCSheetTitleHeight)];
    [self.moreButton.imageView setContentMode:UIViewContentModeScaleAspectFit];
    [self.moreButton setContentEdgeInsets:UIEdgeInsetsZero];
    [self.moreButton setContentHorizontalAlignment:UIControlContentHorizontalAlignmentRight];
    [self.moreButton setAutoresizesSubviews:YES];
    [self.moreButton setTitleEdgeInsets:UIEdgeInsetsMake(0, 0, 0, 15)];
    [self.moreButton setImageEdgeInsets:UIEdgeInsetsMake(0, 0, 0, 15)];
    [self.moreButton setImage:[ZCUITools zcuiGetBundleImage:@"zcicon_sf_close"] forState:UIControlStateNormal];
    [self.moreButton setImage:[ZCUITools zcuiGetBundleImage:@"zcicon_sf_close"] forState:UIControlStateHighlighted];
    self.moreButton.tag = BUTTON_MORE;
    [self.moreButton setAutoresizingMask:UIViewAutoresizingFlexibleLeftMargin];
    [self.moreButton setAutoresizingMask:UIViewAutoresizingFlexibleLeftMargin];
    [self.moreButton addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
   
    
    [self.topView addSubview:self.backButton];
    [self.topView addSubview:self.moreButton];
    [self.topView addSubview:self.titleLabel];
    
    UIView *bottomLine = [[UIView alloc]initWithFrame:CGRectMake(0, ZCSheetTitleHeight -0.5, ScreenWidth, 0.5)];
    bottomLine.backgroundColor = [ZCUITools zcgetCommentButtonLineColor];
    [bottomLine setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
    [self.topView addSubview:bottomLine];
    
}

-(void)setPageTitle:(NSString *)pageTitle{
    _pageTitle = pageTitle;
    
    self.titleLabel.text = zcLibConvertToString(_pageTitle);
}


-(void)buttonClick:(UIButton *) btn{
    if(btn.tag == BUTTON_BACK){
        if(_parentView!=nil){
            _parentView.hidden = NO;
            
            [(ZCPageSheetView *)self.superview.superview showSheet:_parentView.frame.size.height animation:NO block:^{
                [self removeFromSuperview];
            }];
           
            
            
        }
    }
    if(btn.tag == BUTTON_MORE){
        [(ZCPageSheetView *)self.superview.superview  dissmisPageSheet];
    }
}

-(void)createTableView{
    [self createTitleView];
    
    _listTable = [[UITableView alloc]initWithFrame:CGRectMake(0, ZCSheetTitleHeight, ScreenWidth, ScreenHeight * 0.7) style:UITableViewStylePlain];
    _listTable.delegate = self;
    _listTable.dataSource = self;
    _listTable.layer.masksToBounds = YES;
    [_listTable setBackgroundColor:UIColorFromThemeColor(ZCBgSystemWhiteLightDarkColor)];
    [self addSubview:_listTable];
    
    if (iOS7) {
        _listTable.backgroundView = nil;
    }
    
    [_listTable setSeparatorColor:[ZCUITools zcgetCommentButtonLineColor]];
    [_listTable setSeparatorStyle:UITableViewCellSeparatorStyleSingleLine];
    
    // 关闭安全区域，否则UITableViewCell横屏时会是全屏的宽
    NSString *version = [UIDevice currentDevice].systemVersion;
    if (version.doubleValue >= 11.0) {
        [_listTable setInsetsContentViewsToSafeArea:NO];
    }
    [self setTableSeparatorInset];
    
    UIView * bgView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, ScreenWidth, 0)];
    bgView.backgroundColor = [ZCUITools zcgetCommentButtonLineColor];
    _listTable.tableFooterView = bgView;
    
    if(_listArray == nil){
        _listArray = [[NSMutableArray alloc] init];
    }
    [self setFrame:CGRectMake(0, 0, self.frame.size.width, _listTable.frame.size.height + ZCSheetTitleHeight + 20 + XBottomBarHeight)];
}


-(void)layoutSubviews{
    [super layoutSubviews];
    
    CGRect f = self.listTable.frame;
    CGFloat scale = 0.7;
    if(isLandspace){
        scale = 0.5;
    }
    f.size.height = ScreenHeight * scale;
    
    f.origin.y = ZCSheetTitleHeight;
    int direction = [[ZCToolsCore getToolsCore] getCurScreenDirection];
    CGFloat spaceX = 0;
    CGFloat LW = ScreenWidth;
    // iphoneX 横屏需要单独处理
   if(direction > 0){
       LW = ScreenWidth - XBottomBarHeight;
   }
   if(direction == 2){
       spaceX = XBottomBarHeight;
   }
    f.origin.x = spaceX;
    f.size.width = LW;
   _listTable.frame = f;
   
   [self.listTable reloadData];
    
    CGFloat h = f.size.height + ZCSheetTitleHeight + XBottomBarHeight;
   [self setFrame:CGRectMake(0, 0, LW, h)];
    
    self.topView.frame = CGRectMake(0, 0, LW, ZCSheetTitleHeight);
    self.titleLabel.frame = CGRectMake(80,0, _topView.frame.size.width- 80*2, ZCSheetTitleHeight);
    self.superview.frame = CGRectMake(0, ScreenHeight - h, self.frame.size.width, h);
}


#pragma mark UITableView delegate Start
// 返回section数
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

// 返回section高度
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if(section==0){
        return 0;
    }else{
        return 25;
    }
}

// 返回section 的View
-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    if(section==1){
        UIView *view=[[UIView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, 25)];
        [view setBackgroundColor:UIColorFromThemeColor(ZCBgSystemWhiteLightDarkColor)];
        
        UILabel *label=[[UILabel alloc] initWithFrame:CGRectMake(12, 0, ScreenWidth-24, 25)];
        [label setFont:ZCUIFont12];
        [label setTextAlignment:NSTextAlignmentLeft];
        [view addSubview:label];
        return view;
    }
    return nil;
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
    UITableViewCell *cell = (UITableViewCell*)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
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
    
    
    if(_listArray.count < indexPath.row){
        return cell;
    }
    [[cell.contentView subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];
    UIImageView *imageView = [[UIImageView alloc]initWithFrame:CGRectZero];
    [imageView setContentMode:UIViewContentModeScaleAspectFit];
    [cell.contentView addSubview:imageView];
    UILabel *textLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, 17, self.listTable.frame.size.width - 50, 21)];
    textLabel.font = ZCUIFont14;
    textLabel.textColor = UIColorFromThemeColor(ZCTextMainColor);
    [cell.contentView addSubview:textLabel];
    [cell setBackgroundColor:UIColorFromThemeColor(ZCBgSystemWhiteLightDarkColor)];
    [cell setSelectionStyle:UITableViewScrollPositionNone];
    ZCAddressModel *model=[_listArray objectAtIndex:indexPath.row];
    
    switch (_levle) {
        case 1:
            textLabel.text = model.provinceName;
            break;
        case 2:
            textLabel.text = model.cityName;
            break;
        case 3:
            textLabel.text = model.areaName;
            break;
        default:
            break;
    }
    
    CGRect imgf = imageView.frame;
    if(self.levle != 3){
        imageView.image =  [ZCUITools zcuiGetBundleImage:@"zcicon_arrow_right_record"];
        imgf.size = CGSizeMake(7, 12);
    }
    
    if (self.levle == 1) {
        self.backButton.hidden = YES;
    }else{
        self.backButton.hidden = NO;

    }
    
    imgf.origin.x = self.listTable.frame.size.width - imgf.size.width - 15;
    imgf.origin.y = (54 - imgf.size.height)/2;
    imageView.frame = imgf;
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
    return 54.0f;
    //    UITableViewCell *cell = [self tableView:tableView cellForRowAtIndexPath:indexPath];
    //    return cell.frame.size.height;
}

// table 行的点击事件
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if(_listArray==nil || _listArray.count<indexPath.row){
        return;
    }
    
    ZCAddressModel *model = [_listArray objectAtIndex:indexPath.row];
    if (model.endFlag == 1 || self.levle == 3) {
        if(_orderTypeCheckBlock){
            _orderTypeCheckBlock(model);
//            [self.navigationController popToViewController:_parentVC animated:YES];
        }
    }else{
        ZCCheckCityView *typeVC = [[ZCCheckCityView alloc] init];
        typeVC.orderTypeCheckBlock =  _orderTypeCheckBlock;
        typeVC.parentView = self;
        int count = 1;
        count  += self.levle;
        typeVC.pageTitle = _pageTitle;
        typeVC.proviceId = model.provinceId;
        typeVC.proviceName = model.provinceName;
        typeVC.cityName = model.cityName;
        typeVC.cityId = model.cityId;
        
        
        typeVC.levle = count;
        
        [self.superview addSubview:typeVC];
        [(ZCPageSheetView *)self.superview.superview showSheet:typeVC.frame.size.height animation:NO block:^{
            self.hidden = YES;
        }];
//        [self.navigationController pushViewController:typeVC animated:YES];
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

-(void)viewDidLayoutSubviews{
    [self setTableSeparatorInset];
    
    [self.listTable reloadData];
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



-(ZCLibServer *)getZCAPIServer{
    return [[ZCUICore getUICore] getAPIServer];
}


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
