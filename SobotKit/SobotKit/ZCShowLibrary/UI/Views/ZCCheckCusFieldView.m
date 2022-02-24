//
//  ZCCheckCusFieldView.m
//  SobotKit
//
//  Created by 张新耀 on 2019/9/4.
//  Copyright © 2019 zhichi. All rights reserved.
//

#import "ZCCheckCusFieldView.h"



//#import "ZCOrderCustomCell.h"
#import "ZCUIImageTools.h"
#import "ZCUIColorsDefine.h"

#import "ZCLibGlobalDefine.h"

#import "ZCLibOrderCusFieldsModel.h"

#define cellIdentifier @"ZCUITableViewCell"

#import "ZCPageSheetView.h"
#import "ZCUICore.h"

#define ZCSheetTitleHeight 60
@interface ZCCheckCusFieldView ()<UITableViewDelegate,UITableViewDataSource>{
    
    NSMutableDictionary *checkDict;
    
    // 屏幕宽高
    CGFloat                     viewWidth;
    CGFloat                     viewHeigth;
}
@property(nonatomic,strong) UITableView *listTable;
@property(nonatomic,strong) NSMutableArray *mulArr;

@property(nonatomic,strong) NSMutableArray *searchArray;


@property(nonatomic,strong)UIView       *topView;
@property(nonatomic,strong)UIButton     *backButton;
@property(nonatomic,strong)UILabel      *titleLabel;
@property(nonatomic,strong)UITextField *searchField;

@end

@implementation ZCCheckCusFieldView



-(instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        //        self.frame = frame;
        self.userInteractionEnabled = YES;
        self.backgroundColor = UIColorFromThemeColor(ZCBgSystemWhiteLightDarkColor);
        self.autoresizesSubviews = YES;
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



-(void)createTableView{
    [self createTitleView];
    
    _listTable = [[UITableView alloc]initWithFrame:CGRectMake(0, ZCSheetTitleHeight, ScreenWidth, 0) style:UITableViewStylePlain];
    _listTable.delegate = self;
    _listTable.dataSource = self;
    [self addSubview:_listTable];
    [_listTable setBackgroundColor:UIColorFromThemeColor(ZCBgSystemWhiteLightDarkColor)];
    UIView * bgview = [[UIView alloc]initWithFrame:CGRectMake(0, 0, ScreenWidth, 0)];
    _listTable.tableFooterView = bgview;
    _listTable.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    
    
    [_listTable setSeparatorColor:[ZCUITools zcgetCommentButtonLineColor]];
    [_listTable setSeparatorStyle:UITableViewCellSeparatorStyleSingleLine];
    
    // 关闭安全区域，否则UITableViewCell横屏时会是全屏的宽
    NSString *version = [UIDevice currentDevice].systemVersion;
    if (version.doubleValue >= 11.0) {
        [_listTable setInsetsContentViewsToSafeArea:NO];
    }
    
    [self setTableSeparatorInset];
    
    checkDict  = [NSMutableDictionary dictionaryWithCapacity:0];
    
    
    
    if(_listArray == nil){
        _listArray = [[NSMutableArray alloc] init];
    }
}

-(void)setPreModel:(ZCLibOrderCusFieldsModel *)preModel{
    _preModel = preModel;
    _listArray = _preModel.detailArray;
    
    self.titleLabel.text = _preModel.fieldName;
    [_listTable reloadData];
    
    CGRect f = self.listTable.frame;
    
    f.size.height = _listArray.count * 54;
    float footHeight = 0;
    if(!sobotIsNull(_preModel) && [_preModel.fieldType intValue] == 7){
        footHeight = 10 + 44 + 10;
    }else{
        footHeight = 0;
    }
    
    // 如果支持模糊搜索或最大高度限制
    if(f.size.height > ScreenHeight * 0.6 || [preModel.queryFlag intValue] == 1 ||[_preModel.fieldType intValue] == 7){
        f.size.height = ScreenHeight * 0.6;
    }
    
    _listTable.frame = f;
    [self setFrame:CGRectMake(0, 0, self.frame.size.width, f.size.height + ZCSheetTitleHeight + footHeight + XBottomBarHeight)];
     self.superview.frame = CGRectMake(0, ScreenHeight - CGRectGetMaxY(self.frame), self.frame.size.width, CGRectGetMaxY(self.frame));
    
    
    if(!sobotIsNull(_preModel) && [_preModel.fieldType intValue] == 7){
        _mulArr = [NSMutableArray arrayWithCapacity:0];
        for (ZCLibOrderCusFieldsDetailModel *model in _preModel.detailArray) {
            if (model.isChecked) {
                [_mulArr addObject:model];
            }
        }
        
//        UIView * footView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, ScreenWidth, 64 + 20)];
//        footView.backgroundColor = [UIColor whiteColor];
        
        float margin = 0;
        if (![ZCUICore getUICore].kitInfo.navcBarHidden) {
            margin = 64;
        }
        
        UIView * btnFootView = [[UIView alloc]initWithFrame:CGRectMake(0, CGRectGetMaxY(f), ScreenWidth, 64 + 20 )];
        btnFootView.backgroundColor = UIColorFromThemeColor(ZCBgSystemWhiteLightDarkColor);
        btnFootView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleTopMargin;
        btnFootView.userInteractionEnabled = YES;
        
        
        // 区尾添加提交按钮 2.7.1改版
        UIButton * commitBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [commitBtn setTitle:ZCSTLocalString(@"确定") forState:UIControlStateNormal];
        [commitBtn setTitle:ZCSTLocalString(@"确定") forState:UIControlStateSelected];
        [commitBtn setBackgroundColor:[ZCUITools zcgetLeaveSubmitImgColor]];
        commitBtn.frame = CGRectMake(ZCNumber(20),10, ScreenWidth- ZCNumber(40), ZCNumber(44));
        commitBtn.tag = BUTTON_MORE;
        [commitBtn addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
        commitBtn.layer.masksToBounds = YES;
        commitBtn.layer.cornerRadius = ZCNumber(22);
        commitBtn.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        commitBtn.titleLabel.font = ZCUIFont17;
        [btnFootView addSubview:commitBtn];
        [self addSubview:btnFootView];
        
//        2.8.0 增加 线
        UIView *lineView = [[UIView alloc]init];
        lineView.frame = CGRectMake(0, 0, ScreenWidth, 0.5);
        lineView.backgroundColor = [ZCUITools zcgetCommentButtonLineColor];
        lineView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        [btnFootView addSubview:lineView];
//        _listTable.tableFooterView = footView;
        
    }
    else{
//       单选 增加 高度为 20 的尾视图
        UIView * btnFootView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, ScreenWidth, 20)];
        btnFootView.backgroundColor = UIColorFromThemeColor(ZCBgSystemWhiteLightDarkColor);
        btnFootView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        
        UIView *lineView = [[UIView alloc]init];
        lineView.frame = CGRectMake(0, 0, ScreenWidth, 0.5);
        lineView.backgroundColor =[ZCUITools zcgetCommentButtonLineColor];
        lineView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        [btnFootView addSubview:lineView];
        
        _listTable.tableFooterView = btnFootView;
        
        [self setFrame:CGRectMake(0, 0, ScreenWidth, f.size.height + ZCSheetTitleHeight + (ZC_iPhoneX?34:0))];
    }
    
    
    // 2.8.0添加搜索
    if([_preModel.queryFlag intValue] == 1){
        if(_searchArray == nil){
            _searchArray = [[NSMutableArray alloc] init];
            _searchArray = _listArray;
        }
        UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, 54)];
        [headerView setBackgroundColor:UIColorFromThemeColor(ZCBgLightGrayColor)];
        headerView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        headerView.userInteractionEnabled = YES;
        _listTable.tableHeaderView = headerView;
        
        UIImageView *bgImageView = [[UIImageView alloc] initWithFrame:CGRectMake(20, 9, ScreenWidth - 40, 36)];
        [bgImageView setBackgroundColor:UIColorFromThemeColor(ZCBgLeftChatColor)];
        bgImageView.layer.cornerRadius = 18.0f;
        bgImageView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        bgImageView.layer.masksToBounds = YES;
        [headerView addSubview:bgImageView];
        
        UIImageView *searchIcon = [[UIImageView alloc] initWithImage:[ZCUITools zcuiGetBundleImage:@"zcicon_serach"]];
        [searchIcon setFrame:CGRectMake(20, 11, 14, 14)];
        [searchIcon setBackgroundColor:UIColor.clearColor];
        searchIcon.autoresizingMask = UIViewAutoresizingFlexibleRightMargin;
        [bgImageView addSubview:searchIcon];
        
        _searchField = [[UITextField alloc] initWithFrame:CGRectMake(60, 9.5, ScreenWidth - 85, 36)];
        [_searchField setBackgroundColor:UIColor.clearColor];
        [_searchField setTextAlignment:NSTextAlignmentLeft];
        [_searchField setTextColor:UIColorFromThemeColor(ZCTextMainColor)];
        [_searchField setPlaceholder:ZCSTLocalString(@"搜索...")];
        _searchField.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        _searchField.userInteractionEnabled = YES;
        [_searchField setBorderStyle:UITextBorderStyleNone];
        [_searchField addTarget:self action:@selector(searchTextChanged:) forControlEvents:UIControlEventEditingChanged];
        if([[[UIDevice currentDevice] systemVersion] doubleValue] >= 13.0){
            [_searchField setValue:UIColorFromThemeColor(ZCTextSubColor) forKeyPath:@"placeholderLabel.textColor"];
            [_searchField setValue:ZCUIFont14 forKeyPath:@"placeholderLabel.font"];
        }
        else{
            [_searchField setValue:UIColorFromThemeColor(ZCTextSubColor) forKeyPath:@"_placeholderLabel.textColor"];
            [_searchField setValue:ZCUIFont14 forKeyPath:@"_placeholderLabel.font"];
        }
        [headerView addSubview:_searchField];
        
    }
}



-(void)layoutSubviews{
    [super layoutSubviews];
    
    
    CGRect f = self.listTable.frame;
    
    f.size.height = _listArray.count * 54;
    float footHeight = 0;
    if(!sobotIsNull(_preModel) && [_preModel.fieldType intValue] == 7){
        footHeight = 10 + 44 + 10;
    }else{
        footHeight = 0;
    }
    
    // 如果支持模糊搜索或最大高度限制
    if(f.size.height > ScreenHeight * 0.6 || [_preModel.queryFlag intValue] == 1 ){
        f.size.height = ScreenHeight * 0.6;
    }

   f.origin.y = ZCSheetTitleHeight;
    int direction = [[ZCToolsCore getToolsCore] getCurScreenDirection];
       CGFloat spaceX = 0;
       CGFloat LW = self.frame.size.width;
       // iphoneX 横屏需要单独处理
       if(direction > 0){
           LW = self.frame.size.width - XBottomBarHeight;
       }
       if(direction == 2){
           spaceX = XBottomBarHeight;
       }
    f.origin.x = spaceX;
    f.size.width = LW;
   
   
   _listTable.frame = f;
    [_listTable reloadData];
   [self setFrame:CGRectMake(0, 0, self.frame.size.width, f.size.height + ZCSheetTitleHeight + footHeight + XBottomBarHeight)];
    self.superview.frame = CGRectMake(0, ScreenHeight - CGRectGetMaxY(self.frame), self.frame.size.width, CGRectGetMaxY(self.frame));
}


-(void)buttonClick:(UIButton *) btn{
    if(btn.tag == BUTTON_BACK){
        
        [(ZCPageSheetView *)self.superview.superview  dissmisPageSheet];
    }
    
    if(btn.tag == BUTTON_MORE){
        if(_orderCusFiledCheckBlock){
            _orderCusFiledCheckBlock(nil,_mulArr);
             [(ZCPageSheetView *)self.superview.superview  dissmisPageSheet];
        }
    }
}

-(void)searchTextChanged:(UITextField *) field{
    NSString *text = field.text;
    if(sobotConvertToString(text).length > 0){
//        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"%K contains[c] '%@'",@"dataName",sobotConvertToString(text)];
//
        NSMutableArray *resultArr = [[NSMutableArray alloc] init];
        for (ZCLibOrderCusFieldsDetailModel *model in _searchArray) {
            if ([model.dataName containsString:sobotConvertToString(text)]) {
                [resultArr addObject:model];
            }
        }
        self.listArray = resultArr;
        
        [_listTable reloadData];
    }else{
        self.listArray = self.searchArray;
        
        [_listTable reloadData];
    }
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

//设置分割线间距
-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    if((indexPath.row+1) < _listArray.count){
        [self setTableSeparatorInset];
    }
}


-(void)viewDidLayoutSubviews{
    [self setTableSeparatorInset];
}

#pragma mark -- tableView delegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _listArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 54;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 0;
}

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
    [cell.contentView setFrame:CGRectMake(0, 0, self.listTable.frame.size.width, 54)];
    [cell setBackgroundColor:UIColorFromThemeColor(ZCBgSystemWhiteLightDarkColor)];
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    
    [[cell.contentView subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];
    UIImageView *imageView = [[UIImageView alloc]initWithFrame:CGRectZero];
    [imageView setContentMode:UIViewContentModeScaleAspectFit];
    [cell.contentView addSubview:imageView];
    UILabel *textLabel = [[UILabel alloc] init];
    textLabel.font = ZCUIFont14;
    textLabel.textColor = UIColorFromThemeColor(ZCTextMainColor);
    [cell.contentView addSubview:textLabel];
    [textLabel setFrame:CGRectMake(20, 16, self.listTable.frame.size.width - 50, 22)];
    
    ZCLibOrderCusFieldsDetailModel *model = [_listArray objectAtIndex:indexPath.row];
    
    textLabel.text = model.dataName;
    
    CGRect imgf = imageView.frame;
    
    imgf.size = CGSizeMake(20, 20);
    
    if (!sobotIsNull(_preModel) && [_preModel.fieldType intValue] == 7) {
        if (model.isChecked) {
            imageView.image =  [ZCUITools zcuiGetBundleImage:@"zcicon_app_moreselected_sel"];
        }else{
            imageView.image =  [ZCUITools zcuiGetBundleImage:@"zcicon_app_moreselected_nol"];
        }
        imgf.origin.x = self.listTable.frame.size.width - imgf.size.width - 15;
        imgf.origin.y = (54 - imgf.size.height)/2;
//        imgf.origin.x = 15;
//        imgf.origin.y = (44 - imgf.size.height)/2;
        
//        CGRect titleF = textLabel.frame;
//        titleF.origin.x = 39;
//        titleF.size.width = ScreenWidth - 39-20;//20为右间距
//        textLabel.frame = titleF;
    }else{
        if([model.dataValue isEqual:_preModel.fieldSaveValue]){
            imageView.image = [ZCUITools zcuiGetBundleImage:@"zcicon_ordertype_sel"];
        }
        imgf.origin.x = self.listTable.frame.size.width - imgf.size.width - 15;
        imgf.origin.y = (54 - imgf.size.height)/2;
    }
    
    imageView.frame = imgf;
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    ZCLibOrderCusFieldsDetailModel *model = [_listArray objectAtIndex:indexPath.row];
    
    
    if([_preModel.fieldType intValue] != 7){
        if(_orderCusFiledCheckBlock){
            _orderCusFiledCheckBlock(model,_mulArr);
        }
        
        
        [(ZCPageSheetView *)self.superview.superview  dissmisPageSheet];
        
    }else{
        // 复选框
        if(model.isChecked){
            model.isChecked = NO;
            [_mulArr removeObject:model];
        }else{
            model.isChecked = YES;
            [_mulArr addObject:model];
        }
        [_listTable reloadData];
    }
}


-(void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    if(_searchField){
        [_searchField resignFirstResponder];
    }
}

-(void)createTitleView{
    
    self.topView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, ZCSheetTitleHeight)];
    [self.topView setBackgroundColor:UIColorFromThemeColor(ZCBgSystemWhiteLightDarkColor)];
    self.topView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    [_topView setAutoresizesSubviews:YES];
    [self addSubview:self.topView];
    
    
    
    //    [self.topView addSubview:self.topImageView];
    
    self.titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(80,0, _topView.frame.size.width- 80*2, ZCSheetTitleHeight)];
    [self.titleLabel setTextAlignment:NSTextAlignmentCenter];
    [self.titleLabel setFont:[ZCUITools zcgetscTopTextFont]];
    [self.titleLabel setTextColor:[ZCUITools zcgetscTopTextColor]];
    [self.titleLabel setBackgroundColor:[UIColor clearColor]];
    [self.titleLabel setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
    [self.titleLabel setAutoresizesSubviews:YES];
    
    self.backButton=[UIButton buttonWithType:UIButtonTypeCustom];
    [self.backButton setFrame:CGRectMake(_topView.frame.size.width-64, 0, 64, ZCSheetTitleHeight)];
    [self.backButton.imageView setContentMode:UIViewContentModeScaleAspectFit];
    [self.backButton setAutoresizingMask:UIViewAutoresizingFlexibleLeftMargin];
    [self.backButton setContentEdgeInsets:UIEdgeInsetsZero];
    [self.backButton setContentHorizontalAlignment:UIControlContentHorizontalAlignmentRight];
    [self.backButton setAutoresizesSubviews:YES];
    [self.backButton setTitleEdgeInsets:UIEdgeInsetsMake(0, 0, 0, 15)];
    [self.backButton setImageEdgeInsets:UIEdgeInsetsMake(0, 0, 0, 15)];
//    [self.backButton setTitle:@"" forState:UIControlStateNormal];
//    [self.backButton.titleLabel setFont:[ZCUITools zcgetListKitTitleFont]];
//    [self.backButton setTitleColor:[ZCUITools zcgetTopViewTextColor] forState:UIControlStateNormal];
    [self.backButton setImage:[ZCUITools zcuiGetBundleImage:@"zcicon_sf_close"] forState:UIControlStateNormal];
    [self.backButton setImage:[ZCUITools zcuiGetBundleImage:@"zcicon_sf_close"] forState:UIControlStateHighlighted];
    [self.topView addSubview:self.backButton];
    self.backButton.tag = BUTTON_BACK;
    [self.backButton addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];

    [self.topView addSubview:self.backButton];
    [self.topView addSubview:self.titleLabel];
    
    UIView *bottomLine = [[UIView alloc]initWithFrame:CGRectMake(0, ZCSheetTitleHeight -0.5, _topView.frame.size.width, 0.5)];
    bottomLine.backgroundColor = [ZCUITools zcgetCommentButtonLineColor];
    [bottomLine setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
    [self.topView addSubview:bottomLine];
    
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
