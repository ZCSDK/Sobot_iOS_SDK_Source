//
//  ZCMultitemHorizontaRollCell.m
//  SobotKit
//
//  Created by xuhan on 2019/9/4.
//  Copyright © 2019 zhichi. All rights reserved.
//

#import "ZCMultitemHorizontaRollCell.h"
#import "ZCCardCollectionViewCell.h"
#import "ZCPlatformTools.h"
#import "ZCLibGlobalDefine.h"
#import "ZCUIImageTools.h"
#import "ZCUIColorsDefine.h"
#import "ZCCardCollectionViewFlowLayout.h"

@interface ZCMultitemHorizontaRollCell()<UICollectionViewDataSource,UICollectionViewDelegate,UICollectionViewDelegateFlowLayout,ZCMLEmojiLabelDelegate,ZCCardCollectionViewFlowLayoutDelegate>{
    int currentPage;
    NSInteger numberOfPages;
    
}

@property (nonatomic,strong) UICollectionView * collectionView;
@property (nonatomic,strong) ZCCardCollectionViewFlowLayout *layout;


@property (nonatomic,strong)  ZCMLEmojiLabel * titleLab;

@property (nonatomic,assign) BOOL  isHistoryMsg;

@property (nonatomic,strong)  UIView * bgView;

@property (nonatomic,strong) UIPageControl *pageControl;
@property (nonatomic,strong)  UIButton * btnPre;
@property (nonatomic,strong)  UIButton * btnNext;

@property (nonatomic,assign) ZCMultitemHorizontaRollCellType  cellType;

@property (nonatomic,assign) NSUInteger  collectionViewCellHeight;

@property (nonatomic,assign) NSUInteger  cellContentViewHeight;

@property (nonatomic,assign) NSUInteger  collectionViewCellGap;
@property (nonatomic,assign) NSInteger cellNumOnPageInt;

@property (nonatomic,assign) NSInteger clickFlag;
@end

@implementation ZCMultitemHorizontaRollCell

static const float gap = 15;

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self=[super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if(self){
        _isHistoryMsg = NO;
        self.contentView.backgroundColor = [ZCUITools zcgetBackgroundColor];

        [self setupView];
    }
    return self;
}

-(void)setupView{
    self.marginWidth = 15;
    self.bgView = [[UIView alloc]init];
    if (self.isRight) {
        [self.bgView setBackgroundColor:[ZCUITools zcgetRightChatColor]];
    }else{
        [self.bgView setBackgroundColor:[ZCUITools zcgetLeftChatColor]];
    }
//    self.bgView.backgroundColor = [ZCUITools zcgetLeftChatColor];
    self.bgView.layer.cornerRadius = 10;
    self.bgView.layer.masksToBounds = YES;
    
    self.titleLab = [ZCMLEmojiLabel new];
    self.titleLab.numberOfLines = 0;
    self.titleLab.font = ZCUIFontBold14;
    self.titleLab.delegate = self;
    self.titleLab.lineBreakMode = NSLineBreakByTruncatingTail;
    self.titleLab.textColor = UIColorFromThemeColor(ZCTextMainColor);
    self.titleLab.backgroundColor = [UIColor clearColor];
    self.titleLab.isNeedAtAndPoundSign = NO;
    self.titleLab.disableEmoji = NO;
    self.titleLab.lineSpacing = 3.0f;
    self.titleLab.verticalAlignment = ZCTTTAttributedLabelVerticalAlignmentCenter;
    
    
    self.layout = [ZCCardCollectionViewFlowLayout new];
    self.layout.itemSize = CGSizeMake(self.maxWidth , self.collectionViewCellHeight);
    self.layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    self.layout.minimumLineSpacing = 0;
    self.layout.delegate = self;
    
    // 12的间隙为 item 到 消息
    self.collectionView = [[UICollectionView alloc]initWithFrame:CGRectMake(self.marginWidth, 10, self.maxWidth ,self.cellContentViewHeight) collectionViewLayout:self.layout];
    self.collectionView.backgroundColor = [UIColor clearColor];
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    //        collectionView.scrollsToTop = NO;
    self.collectionView.showsVerticalScrollIndicator = NO;
    self.collectionView.showsHorizontalScrollIndicator = NO;
    self.collectionView.pagingEnabled = YES;
    [self.collectionView registerClass:[ZCCardCollectionViewCell class] forCellWithReuseIdentifier:kZCCardCollectionViewCellID];
    
    self.pageControl = [[UIPageControl alloc]initWithFrame:CGRectMake(self.marginWidth, 0,0, 20)];
    
    self.pageControl.currentPage = 0;
    self.pageControl.currentPageIndicatorTintColor = [ZCUITools zcgetRightChatColor];
    if([ZCUITools getZCThemeStyle] == ZCThemeStyle_Dark){
        self.pageControl.pageIndicatorTintColor = UIColorFromThemeColor(ZCTextPlaceHolderColor);
    }else{
        self.pageControl.pageIndicatorTintColor = UIColorFromThemeColor(ZCBgSystemWhiteLightDarkColor);
    }
    self.pageControl.hidesForSinglePage = YES;
    self.pageControl.userInteractionEnabled = NO;
    
    [self addSubview:self.bgView];
    [self addSubview:self.titleLab];
    [self addSubview:self.collectionView];
    [self.bgView addSubview:self.pageControl];
    
    
    _btnPre = [UIButton buttonWithType:UIButtonTypeCustom];
    [_btnPre setTitle:ZCSTLocalString(@"上一页") forState:0];
    [_btnPre setImage:[ZCUITools zcuiGetBundleImage:@"zcicon_pre_page"] forState:UIControlStateNormal];
    [_btnPre setImage:[ZCUITools zcuiGetBundleImage:@"zcicon_no_pre_page"] forState:UIControlStateDisabled];
    [_btnPre setTitleColor:[ZCUITools zcgetServiceNameTextColor] forState:0];
    [_btnPre setTitleColor:[ZCUITools zcgetTopBtnGreyColor] forState:UIControlStateDisabled];
    [_btnPre.titleLabel setFont:[ZCUITools zcgetKitChatFont]];
    [_btnPre addTarget:self action:@selector(onPageClick:) forControlEvents:UIControlEventTouchUpInside];
    
    _btnNext = [UIButton buttonWithType:UIButtonTypeCustom];
    [_btnNext.titleLabel setFont:[ZCUITools zcgetKitChatFont]];
    [_btnNext setTitle:ZCSTLocalString(@"下一页") forState:0];
    [_btnNext setImage:[ZCUITools zcuiGetBundleImage:@"zcicon_last_page"] forState:UIControlStateNormal];
    [_btnNext setImage:[ZCUITools zcuiGetBundleImage:@"zcicon_no_last_page"] forState:UIControlStateDisabled];
    [_btnNext setTitleColor:[ZCUITools zcgetServiceNameTextColor] forState:0];
    [_btnNext setTitleColor:[ZCUITools zcgetTopBtnGreyColor] forState:UIControlStateDisabled];
    [_btnNext addTarget:self action:@selector(onPageClick:) forControlEvents:UIControlEventTouchUpInside];
    if(zcGetSystemDoubleVersion()>=9.0){
        _btnNext.semanticContentAttribute = UISemanticContentAttributeForceRightToLeft;
    }else{
        [_btnNext setTitleEdgeInsets:UIEdgeInsetsMake(0, - _btnNext.imageView.image.size.width, 0, _btnNext.imageView.image.size.width)];
        [_btnNext setImageEdgeInsets:UIEdgeInsetsMake(0, _btnNext.titleLabel.bounds.size.width, 0, -_btnNext.titleLabel.bounds.size.width)];
    }
    [self.bgView addSubview:_btnPre];
    [self.bgView addSubview:_btnNext];
    
}

#pragma mark -- 父类的方法
-(CGFloat) InitDataToView:(ZCLibMessage *)model time:(NSString *)showTime{
    
    self.clickFlag = 0;
    currentPage = 0;
    float cellHeight = [super InitDataToView:model time:showTime];
    self.collectionViewCellHeight = 0;
    self.cellContentViewHeight = 0;
    self.collectionView.hidden = YES;
    self.pageControl.hidden = YES;
    _btnNext.hidden = YES;
    _btnPre.hidden = YES;
    
    [_titleLab setText:@""];
   
    
    _isHistoryMsg = model.richModel.multiModel.isHistoryMessages;
    // 提示语
    CGFloat height = 0;
    NSString * text = zcLibConvertToString(model.richModel.multiModel.msg);
    
    [ZCHtmlCore filterHtml:text result:^(NSString * _Nonnull text1, NSMutableArray * _Nonnull arr, NSMutableArray * _Nonnull links) {
        if (self.isRight) {
            if (text1 != nil && text1.length > 0) {
                [self titleLab].attributedText =   [ZCHtmlFilter setHtml:text1 attrs:arr view:[self titleLab] textColor:[ZCUITools zcgetRightChatTextColor] textFont:ZCUIFont14 linkColor:[ZCUITools zcgetChatRightlinkColor]];
            }else{
                [self titleLab].attributedText =   [[NSAttributedString alloc] initWithString:@""];
            }
            
        }else{
            if (text1 != nil && text1.length > 0) {
                [self titleLab].attributedText =    [ZCHtmlFilter setHtml:text1 attrs:arr view:[self titleLab] textColor:[ZCUITools zcgetLeftChatTextColor] textFont:ZCUIFont14 linkColor:[ZCUITools zcgetChatLeftLinkColor]];
            }else{
                [self titleLab].attributedText =   [[NSAttributedString alloc] initWithString:@""];
            }
        }
    }];
    
   self.cellType = ZCMultitemHorizontaRollCellType_text;
   if (model.richModel.multiModel.msgType == 0) {
       self.cellType = ZCMultitemHorizontaRollCellType_card;
   }
   else if (model.richModel.multiModel.msgType == 1){
       self.cellType = ZCMultitemHorizontaRollCellType_text;
       
   }
   else if (model.richModel.multiModel.msgType == 2){
       self.cellType = ZCMultitemHorizontaRollCellType_address;
   }
   
    
    float titleMaxWidth = self.maxWidth - gap*3*2;
    
    CGSize size = [self.titleLab preferredSizeWithMaxWidth:titleMaxWidth];
    CGRect msgF;
    msgF = CGRectMake(gap*2, 20, size.width, size.height);
    self.titleLab.frame = msgF;
    height = height + size.height +10 + Spaceheight;  //添加完提示语后的cell的高度加间距
    
    //    数据整理
    _listArray = model.richModel.multiModel.interfaceRetList;
    if(_listArray!=nil && _listArray.count > 0){
        //    每页 数目
        _cellNumOnPageInt = 0;
        numberOfPages = 0;
        if (_listArray.count <= 3) {
            _cellNumOnPageInt = _listArray.count;
            numberOfPages = 1;
        }else{
            _cellNumOnPageInt = 3;
            
            if(self.cellType == ZCMultitemHorizontaRollCellType_text){
                _cellNumOnPageInt = 10;
                if(_listArray.count < _cellNumOnPageInt){
                    _cellNumOnPageInt = _listArray.count;
                }
            }
            if (_listArray.count%_cellNumOnPageInt > 0) {
                numberOfPages = _listArray.count/_cellNumOnPageInt + 1;
            }else {
                numberOfPages = _listArray.count/_cellNumOnPageInt;
            }
        }
        
       switch (self.cellType) {
           case ZCMultitemHorizontaRollCellType_text:
           {
               self.collectionViewCellHeight = 34;
               
               if(model.richModel.multiModel.showLinkStyle){
                   self.collectionViewCellHeight = 30;
               }
               self.cellContentViewHeight = self.collectionViewCellHeight*_cellNumOnPageInt + 10*(_cellNumOnPageInt - 1);
               
           }
               break;
           case ZCMultitemHorizontaRollCellType_address:
           {
               self.collectionViewCellHeight = 94;
               self.cellContentViewHeight = self.collectionViewCellHeight*_cellNumOnPageInt + 10*(_cellNumOnPageInt - 1);
               
           }
               break;
           case ZCMultitemHorizontaRollCellType_card:
           {
               self.collectionViewCellHeight = 114;
               self.cellContentViewHeight = self.collectionViewCellHeight*_cellNumOnPageInt + 10*(_cellNumOnPageInt - 1);
           }
               break;
           default:
               break;
       }
           
           
        self.pageControl.numberOfPages = numberOfPages;
        // 设置collectionView 的frame
        CGRect CF = _collectionView.frame;
        CF.origin.y = CGRectGetMaxY(self.titleLab.frame) + 10;
        CF.size.height = self.cellContentViewHeight;
        CF.size.width  = self.maxWidth;
        [_collectionView setFrame:CF];

        // invalidate之前的layout，这个很关键
        [self.collectionView.collectionViewLayout invalidateLayout];
        // 一定要重新设置，否则尺寸不生效
        self.layout.itemSize = CGSizeMake(self.maxWidth , self.collectionViewCellHeight);
        [self.collectionView reloadData];
        [self.collectionView setNeedsLayout];
        [self.collectionView layoutIfNeeded];
        self.collectionView.hidden = NO;
        
        if(self.cellType == ZCMultitemHorizontaRollCellType_text){
            self.pageControl.hidden = YES;
            _btnNext.hidden = NO;
            _btnPre.hidden = NO;
            
            self.bgView.frame = CGRectMake(self.marginWidth, 10, self.maxWidth,CGRectGetMaxY(CF) + 30);
            
            CGRect btnPF = CGRectMake(15, CGRectGetMaxY(self.bgView.frame) - 40, 120, 25);
            _btnPre.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
            _btnNext.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
            CGRect btnNF = CGRectMake(self.maxWidth - 90 -15, CGRectGetMaxY(self.bgView.frame) - 40, 90, 25);
            _btnNext.frame = btnNF;
            _btnPre.frame = btnPF;
            _btnPre.enabled = false;
            _btnNext.enabled = true;
            if(numberOfPages == 1){
                _btnNext.enabled = false;
            }
        }else{
            
            self.pageControl.hidden = NO;
            
            self.bgView.frame = CGRectMake(self.marginWidth, 10, self.maxWidth,CGRectGetMaxY(CF) + 30);
            CGRect pageControlRect = self.pageControl.frame;
            pageControlRect.origin.x = 0;
            pageControlRect.origin.y = CGRectGetMaxY(self.bgView.frame) - 30;
            pageControlRect.size.width = self.maxWidth;
            self.pageControl.frame = pageControlRect;
        }
        
        if (numberOfPages == 1) {
            _btnNext.hidden = YES;
            _btnPre.hidden = YES;
            self.bgView.frame = CGRectMake( self.marginWidth, 10, self.maxWidth,CGRectGetMaxY(CF) + 10);
        }
    }else{
        _btnNext.hidden = YES;
        _btnPre.hidden = YES;

        self.bgView.frame = CGRectMake( self.marginWidth, 10,self.maxWidth, height + 10);
    }
    
    
    
   BOOL hasBottomView = [self isAddBottomBgView:self.bgView.frame msgIsOneLine:NO];

    //    NSLog(@"self.pageControl...%f .. %f",self.pageControl.frame.size.width,ScreenWidth);
    if (hasBottomView) {
        return self.cellContentViewHeight +  cellHeight + size.height + 60 + 40;
    }
    else{
        return self.cellContentViewHeight +  cellHeight + size.height + 60;

    }
    
    
}

+(CGFloat)getCellHeight:(ZCLibMessage *)model time:(NSString *)showTime viewWith:(CGFloat)width{
    CGFloat cellHeight = [super getCellHeight:model time:showTime viewWith:width];
    
    //    计算 title 的高度
    static ZCMLEmojiLabel *titleLab = nil;
    if (!titleLab) {
        titleLab = [ZCMLEmojiLabel new];
        titleLab.numberOfLines = 0;
        titleLab.font = ZCUIFont14;
        titleLab.backgroundColor = [UIColor clearColor];
        titleLab.lineBreakMode = NSLineBreakByTruncatingTail;
        titleLab.textColor = [UIColor whiteColor];
        titleLab.isNeedAtAndPoundSign = YES;
        titleLab.disableEmoji = NO;
        titleLab.lineSpacing = 3.0f;
        titleLab.verticalAlignment = ZCTTTAttributedLabelVerticalAlignmentCenter;
    }
    
    NSString * text = model.richModel.multiModel.msg;
    
    [ZCHtmlCore filterHtml:text result:^(NSString * _Nonnull text1, NSMutableArray * _Nonnull arr, NSMutableArray * _Nonnull links) {
        //        if (self.isRight) {
        if (text1 != nil && text1.length > 0) {
            titleLab.attributedText =   [ZCHtmlFilter setHtml:text1 attrs:arr view:titleLab textColor:[ZCUITools zcgetRightChatTextColor] textFont:[ZCUITools zcgetKitChatFont] linkColor:[ZCUITools zcgetChatRightlinkColor]];
        }else{
            titleLab.attributedText =  [[NSAttributedString alloc] initWithString:@""];
        }
    }];
    
    float titleMaxWidth = width - 90 - gap*3*2;
    
    CGSize size = [titleLab preferredSizeWithMaxWidth:titleMaxWidth];
    
    //    数据整理
    
    NSMutableArray *temListArray = [NSMutableArray arrayWithCapacity:0];
    temListArray = model.richModel.multiModel.interfaceRetList;
    if(temListArray.count == 0){

        if (model.showTurnUser) {
            cellHeight = cellHeight + 30;
        }
        return cellHeight + size.height + 10 + 40 ;
    }
    
    
    ZCMultitemHorizontaRollCellType cellType = ZCMultitemHorizontaRollCellType_text;
    
    if (model.richModel.multiModel.msgType == 0) {
        cellType = ZCMultitemHorizontaRollCellType_card;
    }
    else if (model.richModel.multiModel.msgType == 1){
        cellType = ZCMultitemHorizontaRollCellType_text;
        
    }
    else if (model.richModel.multiModel.msgType == 2){
        cellType = ZCMultitemHorizontaRollCellType_address;
        
    }
    //    每页 数目
    NSInteger numberOfPages = 0;
    NSInteger cellNumOnPageInt = 0;
    if (temListArray.count <= 3) {
        cellNumOnPageInt = temListArray.count;
        numberOfPages = 1;
    }else{
        cellNumOnPageInt = 3;
        if(cellType == ZCMultitemHorizontaRollCellType_text){
            cellNumOnPageInt = 10;
            
            if(temListArray.count < cellNumOnPageInt){
                cellNumOnPageInt = temListArray.count;
            }
        }
        if (temListArray.count%cellNumOnPageInt > 0) {
            numberOfPages = temListArray.count/cellNumOnPageInt + 1;
        }
        else {
            numberOfPages = temListArray.count/cellNumOnPageInt;
        }
    }
    
    float collectionViewCellHeight = 0;
    float cellContentViewHeight = 0;
    switch (cellType) {
        case ZCMultitemHorizontaRollCellType_text:
        {
            collectionViewCellHeight = 34;
            
            if(model.richModel.multiModel.showLinkStyle){
                collectionViewCellHeight = 30;
            }
            cellContentViewHeight = collectionViewCellHeight*cellNumOnPageInt + 10*(cellNumOnPageInt - 1);
        }
            break;
        case ZCMultitemHorizontaRollCellType_address:
        {
            collectionViewCellHeight = 94;
            cellContentViewHeight = collectionViewCellHeight*cellNumOnPageInt + 10*(cellNumOnPageInt - 1);
            
        }
            break;
        case ZCMultitemHorizontaRollCellType_card:
        {
            collectionViewCellHeight = 114;
            cellContentViewHeight = collectionViewCellHeight*cellNumOnPageInt + 10*(cellNumOnPageInt - 1);
        }
            break;
        default:
            break;
    }
    
    
    if (numberOfPages == 1) {
        cellHeight = cellContentViewHeight + cellHeight + size.height + 40;
    }else{
        cellHeight = cellContentViewHeight + cellHeight + size.height + 60;
    }
    
    if (model.showTurnUser) {
        cellHeight = cellHeight + 30;
    }

    
    return  cellHeight + 10;
}

#pragma mark - UICollectionViewDataSource
-(CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
//    if (self.cellType == ZCMultitemHorizontaRollCellType_text && self.tempModel.richModel.multiModel.showLinkStyle)
//    {
//        NSDictionary * model = _listArray[indexPath.row];
//        NSString *text = [NSString stringWithFormat:@"%d、%@",(int)indexPath.row+1,zcLibConvertToString(model[@"title"])];
//        CGSize s = [text sizeWithFont:ZCUIFont14 constrainedToSize:CGSizeMake(self.maxWidth-30, 0)];
//
//        return CGSizeMake(self.maxWidth, s.height+3);
//    }
    return self.layout.itemSize;
}
- (void)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout cellCenteredAtIndexPath:(NSIndexPath *)indexPath page:(int)page{
    currentPage = page;
    self.pageControl.currentPage = page; // 分页控制器当前显示的页数
    
    if(currentPage > 0){
        self.btnPre.enabled = true;
    }
    
    if(currentPage <= 0){
        currentPage = 0;
        self.btnPre.enabled = false;
    }
    
    if((currentPage+1) >= numberOfPages){
        self.btnNext.enabled = false;
    }else{
        if(numberOfPages > 0){
            self.btnNext.enabled = true;
        }
    }
    
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return _listArray.count;
}
-(UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    return UIEdgeInsetsMake(0, 0, 0, 0);//分别为上、左、下、右
}

- ( UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    return [collectionView dequeueReusableCellWithReuseIdentifier:kZCCardCollectionViewCellID forIndexPath:indexPath];
}

// 点击发送消息
-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    
    //    NSLog(@" 点击水平 item的 事件 %@",indexPath);
    //    NSDictionary * model = _listArray[indexPath.row];
    
    ZCMultiwheelModel *pm = self.tempModel.richModel.multiModel;
    if(pm.interfaceRetList.count == 0){
        return;
    }
    NSDictionary *detail = [pm.interfaceRetList objectAtIndex:indexPath.row];
    
    if (pm.endFlag) {
        // 最后一轮会话，有外链，点击跳转外链
        if (![@"" isEqualToString: zcLibConvertToString(detail[@"anchor"])]) {
            // 点击超链跳转
            if (self.delegate && [self.delegate respondsToSelector:@selector(cellItemLinkClick:type:obj:)]) {
                [self.delegate cellItemLinkClick:nil type:ZCChatCellClickTypeOpenURL obj:zcLibConvertToString(detail[@"anchor"])];
            }
        }
        return;
    }
    
    NSInteger clickFlagInt = [self.tempModel.richModel.multiModel.clickFlag integerValue];
    
    // 历史记录，不允许多次点击，或者允许多次点击，但是当前cid不一样
    if (_isHistoryMsg && (clickFlagInt == 0 || (clickFlagInt>0&&[self getCurConfig].cid != self.tempModel.cid))) {
        return;
    }
    
    
    if (self.clickFlag > 0 && clickFlagInt == 0) {
//        clickFlagInt == 0 只能点击一次 模版一
        return;
    }
    self.clickFlag ++;
    
    
    // 发送点击消息
    NSString * title = zcLibConvertToString(detail[@"title"]);
    NSDictionary * dict = @{@"requestText":[pm getRequestText:detail],
                            @"question":[pm getQuestion:detail],
                            @"questionFlag":@"2",
                            @"title":title,@"ishotguide":@"0"
                            };
    if ([self getCurConfig].isArtificial) {
        dict = @{@"title":title,@"ishotguide":@"0"};
    }
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(cellItemClick:type:obj:)]) {
        [self.delegate cellItemClick:nil type:ZCChatCellClickTypeCollectionSendMsg obj:dict];
    }
}

#pragma mark - UICollectionViewDelegateFlowLayout

- (void)collectionView:(UICollectionView *)collectionView willDisplayCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath {
    if(_listArray.count == 0){
        return;
    }
    NSDictionary * model = _listArray[indexPath.row];
    ((ZCCardCollectionViewCell *)cell).indexPath = indexPath;
    [(ZCCardCollectionViewCell *)cell configureCellWithPostURL:model WithIsHistory:_isHistoryMsg withType:self.cellType linkStyle:self.tempModel.richModel.multiModel.showLinkStyle];
}



-(void)resetCellView{
    [super resetCellView];
    //    [self.lblNickName setText:@""];
    
}

-(ZCLibConfig *)getCurConfig{
    return [[ZCPlatformTools sharedInstance] getPlatformInfo].config;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}



-(void)onPageClick:(UIButton *) btn{
    if(btn == _btnNext){
        currentPage = currentPage + 1;
        CGRect f = self.collectionView.frame;
        f.origin.x = currentPage * f.size.width;
        if((currentPage+1) >= numberOfPages){
            self.btnNext.enabled = false;
            
            currentPage = (int)numberOfPages-1;
        }
        if(currentPage > 0){
            self.btnPre.enabled = true;
        }
        [self.collectionView scrollRectToVisible:f animated:YES];
    }else{
        currentPage = currentPage - 1;
        if(currentPage <= 0){
            currentPage = 0;
            self.btnPre.enabled = false;
        }
        
        if(currentPage < numberOfPages){
            self.btnNext.enabled = true;
        }
        CGRect f = self.collectionView.frame;
        f.origin.x = currentPage * f.size.width;
        
        [self.collectionView scrollRectToVisible:f animated:YES];
    }
}

@end
