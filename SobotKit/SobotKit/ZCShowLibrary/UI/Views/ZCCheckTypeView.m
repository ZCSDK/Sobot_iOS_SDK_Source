//
//  ZCCheckTypeView.m
//  SobotKit
//
//  Created by 张新耀 on 2019/9/4.
//  Copyright © 2019 zhichi. All rights reserved.
//

#import "ZCCheckTypeView.h"


#import "ZCUIColorsDefine.h"
#import "ZCLibGlobalDefine.h"
#import "ZCUIImageTools.h"
#define cellIdentifier @"ZCUITableViewCell"

#import "ZCPageSheetView.h"

typedef NS_ENUM(NSInteger, ZCButtonClickTag) {
    BUTTON_BACK   = 1, // 返回
    BUTTON_CLOSE  = 2, // 关闭(未使用)
    BUTTON_UNREAD = 3, // 未读消息
    BUTTON_MORE   = 4, // 清空历史记录
    BUTTON_TURNROBOT = 5,// 切换机器人
    BUTTON_EVALUATION =6,// 评价
    BUTTON_TEL   = 7,// 拨打电话
};


@interface ZCCheckTypeView ()<UITableViewDelegate,UITableViewDataSource>{
    
}
@property(nonatomic,strong)UITableView      *listTable;

@property(nonatomic,strong)UIView       *topView;
@property(nonatomic,strong)UIButton     *backButton;
@property(nonatomic,strong)UIButton     *moreButton;
@property(nonatomic,strong)UILabel      *titleLabel;


@end

@implementation ZCCheckTypeView


-(instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        self.frame = frame;
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
        self.userInteractionEnabled = YES;
        [self createTableView];
    }
    return self;
}



-(void)createTableView{
    [self createTitleView];

    _listTable = [[UITableView alloc]initWithFrame:CGRectMake(0, ZCSheetTitleHeight, ScreenWidth, 0) style:UITableViewStylePlain];
    _listTable.delegate = self;
    _listTable.dataSource = self;
//    _listTable.layer.masksToBounds = YES;
    [self addSubview:_listTable];
    _listTable.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    _listTable.autoresizesSubviews = YES;
    _listTable.backgroundColor = UIColorFromThemeColor(ZCBgSystemWhiteLightDarkColor);
    // 关闭安全区域，否则UITableViewCell横屏时会是全屏的宽
    NSString *version = [UIDevice currentDevice].systemVersion;
    if (version.doubleValue >= 11.0) {
        [_listTable setInsetsContentViewsToSafeArea:NO];
    }
    if (iOS7) {
        _listTable.backgroundView = nil;
    }
    
    [_listTable setSeparatorColor:[ZCUITools zcgetCommentButtonLineColor]];
    [_listTable setSeparatorStyle:UITableViewCellSeparatorStyleSingleLine];
    
    [self setTableSeparatorInset];
    if(_listArray == nil){
        _listArray = [[NSMutableArray alloc] init];
    }
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
    


-(void)setListArray:(NSMutableArray *)listArray{
    _listArray = listArray;
    CGRect f = self.listTable.frame;
    f.size.height = _listArray.count * 54;

    CGFloat scale = 0.7;
    if(isLandspace){
        scale = 0.5;
    }
    if(f.size.height > ScreenHeight * scale){
        f.size.height = ScreenHeight * scale;
    }

    _listTable.frame = f;

    [self.listTable reloadData];
    

     CGFloat h = f.size.height + ZCSheetTitleHeight + XBottomBarHeight;
    [self setFrame:CGRectMake(0, 0, self.frame.size.width, h)];
     self.superview.frame = CGRectMake(0, ScreenHeight - h, self.frame.size.width, h);
    
    if([_typeId isEqual:@"-1"]){
        _backButton.hidden = YES;
    }
}


-(void)layoutSubviews{
    [super layoutSubviews];
    
    CGRect f = self.listTable.frame;
    f.size.height = _listArray.count * 54;
    CGFloat scale = 0.7;
   if(isLandspace){
       scale = 0.5;
   }
   if(f.size.height > ScreenHeight * scale){
       f.size.height = ScreenHeight * scale;
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
   
   [self.listTable reloadData];
    
    CGFloat h = f.size.height + ZCSheetTitleHeight + XBottomBarHeight;
   [self setFrame:CGRectMake(0, 0, self.frame.size.width, h)];
    self.superview.frame = CGRectMake(0, ScreenHeight - h, self.frame.size.width, h);
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
        UIView *view=[[UIView alloc] initWithFrame:CGRectMake(0, 0, self.listTable.frame.size.width, 25)];
        [view setBackgroundColor:UIColorFromThemeColor(ZCBgSystemWhiteLightDarkColor)];
        
        UILabel *label=[[UILabel alloc] initWithFrame:CGRectMake(12, 0, self.listTable.frame.size.width-24, 25)];
        [label setFont:ZCUIFont12];
        [label setText:@""];
        [label setTextAlignment:NSTextAlignmentLeft];
        [label setTextColor:UIColorFromThemeColor(ZCTextMainColor)];
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
    cell.frame = CGRectMake(0, 0, self.listTable.frame.size.width, 54);
    [cell setBackgroundColor:UIColorFromThemeColor(ZCBgSystemWhiteLightDarkColor)];
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    [[cell.contentView subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];
    UIImageView *imageView = [[UIImageView alloc]initWithFrame:CGRectZero];
    [imageView setContentMode:UIViewContentModeScaleAspectFit];
    [cell.contentView addSubview:imageView];
    UILabel *textLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, 20, self.listTable.frame.size.width - 50, 21)];
    textLabel.font = ZCUIFont14;
//    textLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    textLabel.textColor = UIColorFromThemeColor(ZCTextMainColor);
    [cell.contentView addSubview:textLabel];
    
    ZCLibTicketTypeModel *model=[_listArray objectAtIndex:indexPath.row];
    textLabel.text = model.typeName;
    
    
    CGRect imgf = imageView.frame;
    if([model.nodeFlag intValue] == 1){
        imageView.image =  [ZCUITools zcuiGetBundleImage:@"zcicon_arrow_right_record"];
        imgf.size = CGSizeMake(7, 12);
    }
    
    imgf.origin.x = self.listTable.frame.size.width - imgf.size.width - 15;
    imgf.origin.y = (55 - imgf.size.height)/2;
    imageView.frame = imgf;
//    imageView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
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
    
    ZCLibTicketTypeModel *model = [_listArray objectAtIndex:indexPath.row];
    if([model.nodeFlag intValue] == 1){
        ZCCheckTypeView *typeVC = [[ZCCheckTypeView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, 0)];
        typeVC.typeId = model.typeId;
        typeVC.pageTitle = model.typeName;
        typeVC.orderTypeCheckBlock =  _orderTypeCheckBlock;
        typeVC.parentView = self;
        typeVC.listArray = model.items;
        [self.superview addSubview:typeVC];
//        [self.navigationController pushViewController:typeVC animated:YES];
        
        [(ZCPageSheetView *)self.superview.superview showSheet:typeVC.frame.size.height animation:NO block:^{
            self.hidden = YES;
        }];
        
    }else{
        if(_orderTypeCheckBlock){
            _orderTypeCheckBlock(model);
            
//            [self.navigationController popToViewController:_parentVC animated:YES];
            
        }
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
    [_listTable setSeparatorColor : [ZCUITools zcgetCommentButtonLineColor]];
}



-(void)createTitleView{
    
    self.topView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, ZCSheetTitleHeight)];
    self.topView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    [self.topView setBackgroundColor:UIColorFromThemeColor(ZCBgSystemWhiteLightDarkColor)];
    [self addSubview:self.topView];
    
    
    
    //    [self.topView addSubview:self.topImageView];
    
    self.titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(80,0, _topView.frame.size.width- 80*2, ZCSheetTitleHeight)];
    [self.titleLabel setTextAlignment:NSTextAlignmentCenter];
    self.titleLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    [self.titleLabel setFont:[ZCUITools zcgetscTopTextFont]];
    [self.titleLabel setTextColor:[ZCUITools zcgetscTopTextColor]];
    
    self.titleLabel.text = ZCSTLocalString(@"选择分类");
    [self.titleLabel setBackgroundColor:[UIColor clearColor]];
    [self.titleLabel setAutoresizingMask:UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleBottomMargin];
    [self.titleLabel setAutoresizesSubviews:YES];
    
    
    self.backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.backButton setFrame:CGRectMake(20, 0, 64, ZCSheetTitleHeight)];
    [self.backButton.imageView setContentMode:UIViewContentModeScaleAspectFit];
    [self.backButton setAutoresizingMask:UIViewAutoresizingFlexibleRightMargin];
    [self.backButton setImage:[ZCUITools zcuiGetBundleImage:@"zcicon_scback_gray"] forState:UIControlStateNormal];
    [self.backButton setImage:[ZCUITools zcuiGetBundleImage:@"zcicon_scback_gray"] forState:UIControlStateHighlighted];
//    [self.backButton setTitleColor:[ZCUITools zcgetscTopBackTextColor] forState:UIControlStateNormal];
//    [self.backButton.titleLabel setFont:[ZCUITools zcgetscTopBackTextFont]];
    [self.backButton setImageEdgeInsets:UIEdgeInsetsMake(0, 0, 0, 20)];
    [self.backButton setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
    [self.backButton setAutoresizesSubviews:YES];
//    [self.backButton.titleLabel setFont:[ZCUITools zcgetListKitTitleFont]];
//    [self.backButton setTitleColor:[ZCUITools zcgetTopViewTextColor] forState:UIControlStateNormal];
    self.backButton.tag = BUTTON_BACK;
    [self.backButton addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
    
    
    
    
    self.moreButton=[UIButton buttonWithType:UIButtonTypeCustom];
    [self.moreButton setFrame:CGRectMake(_topView.frame.size.width-64, 0, 64, ZCSheetTitleHeight)];
    [self.moreButton.imageView setContentMode:UIViewContentModeScaleAspectFit];
    [self.moreButton setAutoresizingMask:UIViewAutoresizingFlexibleLeftMargin];
    [self.moreButton setContentEdgeInsets:UIEdgeInsetsZero];
    [self.moreButton setContentHorizontalAlignment:UIControlContentHorizontalAlignmentRight];
    [self.moreButton setAutoresizesSubviews:YES];
    [self.moreButton setTitleEdgeInsets:UIEdgeInsetsMake(0, 0, 0, 15)];
    [self.moreButton setImageEdgeInsets:UIEdgeInsetsMake(0, 0, 0, 15)];
    [self.moreButton setAutoresizingMask:UIViewAutoresizingFlexibleLeftMargin];
//    [self.moreButton setTitle:@"" forState:UIControlStateNormal];
//    [self.moreButton.titleLabel setFont:[ZCUITools zcgetListKitTitleFont]];
//    [self.moreButton setTitleColor:[ZCUITools zcgetTopViewTextColor] forState:UIControlStateNormal];
    [self.moreButton setImage:[ZCUITools zcuiGetBundleImage:@"zcicon_sf_close"] forState:UIControlStateNormal];
    [self.moreButton setImage:[ZCUITools zcuiGetBundleImage:@"zcicon_sf_close"] forState:UIControlStateHighlighted];
    self.moreButton.tag = BUTTON_MORE;
    [self.moreButton addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
   
    
    [self.topView addSubview:self.backButton];
    [self.topView addSubview:self.moreButton];
    [self.topView addSubview:self.titleLabel];
    
    UIView *bottomLine = [[UIView alloc]initWithFrame:CGRectMake(0, ZCSheetTitleHeight -0.5, ScreenWidth, 0.5)];
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
