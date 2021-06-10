//
//  ZCHotGuideCell.m
//  SobotKit
//
//  Created by lizhihui on 2018/1/11.
//  Copyright © 2018年 zhichi. All rights reserved.
//

#import "ZCHotGuideCell.h"

#import "ZCCollectionViewCell.h"
#import "ZCLibGlobalDefine.h"
#import "ZCMLEmojiLabel.h"
#import "ZCPlatformTools.h"
#import "ZCUIColorsDefine.h"
#import "ZCHtmlCore.h"
#import "ZCHtmlFilter.h"

@interface ZCHotGuideCell()<UICollectionViewDataSource,UICollectionViewDelegateFlowLayout,ZCMLEmojiLabelDelegate>{
    
}

@property (nonatomic,strong) UICollectionView * collectionView;

@property (nonatomic,strong) NSMutableArray * listArray;

@property (nonatomic,strong)  ZCMLEmojiLabel * titleLab;

@property (nonatomic,assign) BOOL  isHistoryMsg;

@end

@implementation ZCHotGuideCell


-(ZCMLEmojiLabel *)titleLab{
    if(!_titleLab){
        _titleLab = [[ZCMLEmojiLabel alloc] initWithFrame:CGRectZero];
        _titleLab.numberOfLines = 0;
        _titleLab.font = [ZCUITools zcgetKitChatFont];
        _titleLab.delegate = self;
        _titleLab.lineBreakMode = NSLineBreakByTruncatingTail;
        _titleLab.textColor = [ZCUITools zcgetLeftChatTextColor];
        _titleLab.backgroundColor = [UIColor clearColor];
        _titleLab.isNeedAtAndPoundSign = NO;
        _titleLab.disableEmoji = NO;
        _titleLab.lineSpacing = 3.0f;
        _titleLab.verticalAlignment = ZCTTTAttributedLabelVerticalAlignmentCenter;
        [self.contentView addSubview:_titleLab];
        
    }
    return _titleLab;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    [self setupView];
}

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self=[super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if(self){
        _isHistoryMsg = NO;
        [self setupView];
    }
    return self;
}

-(void)setupView{
    
    _collectionView = ({
        UICollectionViewFlowLayout *layout = [UICollectionViewFlowLayout new];
        layout.itemSize = CGSizeMake(84, 100);
        layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        layout.minimumLineSpacing = 10;
        
        // 12的间隙为 item 到 消息
        UICollectionView *collectionView = [[UICollectionView alloc]initWithFrame:CGRectMake(0, 12, ScreenWidth,100) collectionViewLayout:layout];
        collectionView.backgroundColor = [UIColor clearColor];
        collectionView.delegate = self;
        collectionView.dataSource = self;
        collectionView.scrollsToTop = NO;
        collectionView.showsVerticalScrollIndicator = NO;
        collectionView.showsHorizontalScrollIndicator = NO;
        [collectionView registerClass:[ZCCollectionViewCell class] forCellWithReuseIdentifier:kZCCollectionViewCellID];
        [self.contentView addSubview:collectionView];
        collectionView;
    });
}



#pragma mark -- 父类的方法
-(CGFloat) InitDataToView:(ZCLibMessage *)model time:(NSString *)showTime{
    [_collectionView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    [_collectionView removeFromSuperview];
    [self setupView];
    CGFloat cellHeight = [super InitDataToView:model time:showTime];
    _isHistoryMsg = NO;
#pragma mark  -- 提示语
    CGFloat rw = 0;
    CGFloat height = 0;
    NSString * text = model.richModel.guide;
    
    [ZCHtmlCore filterHtml:text result:^(NSString * _Nonnull text1, NSMutableArray * _Nonnull arr, NSMutableArray * _Nonnull links) {
        if (self.isRight) {
            if (text1 != nil && text1.length > 0) {
                self.titleLab.attributedText =   [ZCHtmlFilter setHtml:text1 attrs:arr view:self.titleLab textColor:[ZCUITools zcgetRightChatTextColor] textFont:[ZCUITools zcgetKitChatFont] linkColor:[ZCUITools zcgetChatRightlinkColor]];
            }else{
                self.titleLab.attributedText =   [[NSAttributedString alloc] initWithString:@""];
            }
            
        }else{
            if (text1 != nil && text1.length > 0) {
                self.titleLab.attributedText =    [ZCHtmlFilter setHtml:text1 attrs:arr view:self.titleLab textColor:[ZCUITools zcgetLeftChatTextColor] textFont:[ZCUITools zcgetKitChatFont] linkColor:[ZCUITools zcgetChatLeftLinkColor]];
            }else{
                self.titleLab.attributedText =   [[NSAttributedString alloc] initWithString:@""];
            }
            
        }
    }];
    
    // 处理换行
//    text = [text stringByReplacingOccurrencesOfString:@"<br />" withString:@"\n"];
//    text = [text stringByReplacingOccurrencesOfString:@"<br/>" withString:@"\n"];
//    text = [text stringByReplacingOccurrencesOfString:@"<br>" withString:@"\n"];
//    text = [text stringByReplacingOccurrencesOfString:@"<BR/>" withString:@"\n"];
//    text = [text stringByReplacingOccurrencesOfString:@"<BR />" withString:@"\n"];
//    text = [text stringByReplacingOccurrencesOfString:@"<p " withString:@"\n<p "];
//    text = [text stringByReplacingOccurrencesOfString:@"&nbsp;" withString:@" "];
//    while ([text hasPrefix:@"\n"]) {
//        text=[text substringWithRange:NSMakeRange(1, text.length-1)];
//    }
//
//    NSMutableDictionary *dict = [self.titleLab getTextADict:text];
//    if(dict){
//        text = dict[@"text"];
//    }
//    _titleLab.text = text;
//
//    if(dict){
//        NSArray *arr = dict[@"arr"];
//        //    [_emojiLabel setText:tempText];
//        for (NSDictionary *item in arr) {
//            NSString *text = item[@"htmlText"];
//            int loc = [item[@"realFromIndex"] intValue];
//
//            // 一定要在设置text文本之后设置
//            [_titleLab addLinkToURL:[NSURL URLWithString:item[@"url"]] withRange:NSMakeRange(loc, text.length)];
//        }
//    }
    
    CGSize size = [self.titleLab preferredSizeWithMaxWidth:self.maxWidth];
    CGRect msgF;
    msgF = CGRectMake(GetCellItemX(self.isRight), 10, size.width, size.height);
    [[self titleLab] setFrame:msgF];
    height = height + size.height +10 + Spaceheight;  //添加完提示语后的cell的高度加间距
    
    //    cellHeight = cellHeight + height;// 添加完提示语后的高度，下部分为item的高度
    
    rw = size.width;
    
    CGFloat msgX = 0;
    // 0,自己，1机器人，2客服
    if(self.isRight){
        int rx=self.viewWidth-rw-30 -50;
        msgX = rx;
        [self.ivBgView setFrame:CGRectMake(rx-8, cellHeight, rw+28, height + 5)];
    }else{
        msgX = 78;
        [self.ivBgView setFrame:CGRectMake(58, cellHeight, rw+33, height + 5)];
    }
    
    msgF.origin.x = msgX;
    msgF.origin.y = msgF.origin.y + cellHeight;
    [self.titleLab setFrame:msgF];
    
    // 设置collectionView 的frame
    CGRect CF = _collectionView.frame;
    CF.origin.y = CGRectGetMaxY(self.titleLab.frame) + 15;
    [_collectionView setFrame:CF];
    
    //    CGFloat sh = [self setSendStatus:self.ivBgView.frame];
    // 设置尖角
    [self.ivLayerView setFrame:self.ivBgView.frame];
    CALayer *layer              = self.ivLayerView.layer;
    layer.frame                 = (CGRect){{0,0},self.ivLayerView.layer.frame.size};
    self.ivBgView.layer.mask = layer;
    [self.ivBgView setNeedsDisplay];
    
    // 水平滑动的样式是固定的高度 188  间隙 10
    self.frame = CGRectMake(0, 0, self.viewWidth, 122 + cellHeight + height );
    self.backgroundColor = [UIColor redColor];
    
    _listArray = [NSMutableArray arrayWithCapacity:0];
    
    _listArray = model.richModel.hotGuideArr;
    
    cellHeight = cellHeight + 122  + height + 5 ;
    return cellHeight  ;
    
}

+(CGFloat)getCellHeight:(ZCLibMessage *)model time:(NSString *)showTime viewWith:(CGFloat)width{
    CGFloat cellHeight = [super getCellHeight:model time:showTime viewWith:width];
    //    CGFloat cellHeight = 22;
    CGFloat maxWidth = ScreenWidth - 160;
    //    if(![@"" isEqual:zcLibConvertToString(showTime)]){
    //        cellHeight = cellHeight + 30;
    //    }
    
    static ZCMLEmojiLabel *titleLab = nil;
    if (!titleLab) {
        titleLab = [[ZCMLEmojiLabel alloc] initWithFrame:CGRectZero];
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
    
    NSString * text = model.richModel.guide;
    
    [ZCHtmlCore filterHtml:text result:^(NSString * _Nonnull text1, NSMutableArray * _Nonnull arr, NSMutableArray * _Nonnull links) {
//        if (self.isRight) {
        if (text1 != nil && text1.length > 0) {
            titleLab.attributedText =   [ZCHtmlFilter setHtml:text1 attrs:arr view:titleLab textColor:[ZCUITools zcgetRightChatTextColor] textFont:[ZCUITools zcgetKitChatFont] linkColor:[ZCUITools zcgetChatRightlinkColor]];
        }else{
            titleLab.attributedText = [[NSAttributedString alloc] initWithString:@""];
        }
        
//        }else{
//            titleLab.attributedText =    [ZCHtmlFilter setHtml:text1 attrs:arr view:titleLab textColor:[ZCUITools zcgetLeftChatTextColor] textFont:[ZCUITools zcgetKitChatFont] linkColor:[ZCUITools zcgetChatLeftLinkColor]];
//        }
    }];
    
    // 处理换行
//    text = [text stringByReplacingOccurrencesOfString:@"<br />" withString:@"\n"];
//    text = [text stringByReplacingOccurrencesOfString:@"<br/>" withString:@"\n"];
//    text = [text stringByReplacingOccurrencesOfString:@"<br>" withString:@"\n"];
//    text = [text stringByReplacingOccurrencesOfString:@"<BR/>" withString:@"\n"];
//    text = [text stringByReplacingOccurrencesOfString:@"<BR />" withString:@"\n"];
//    text = [text stringByReplacingOccurrencesOfString:@"<p " withString:@"\n<p "];
//    text = [text stringByReplacingOccurrencesOfString:@"&nbsp;" withString:@" "];
//    while ([text hasPrefix:@"\n"]) {
//        text=[text substringWithRange:NSMakeRange(1, text.length-1)];
//    }
//
//    NSMutableDictionary *dict = [titleLab getTextADict:text];
//    if(dict){
//        text = dict[@"text"];
//    }
//    titleLab.text = text;
    CGSize msgSize = [titleLab preferredSizeWithMaxWidth:maxWidth];
    
    
    // 水平滑动的样式是固定的高度 188  间隙 10   20为距下一cell的间隙
    return  cellHeight + 122 + msgSize.height +10 + Spaceheight + 5 +10 + 5;
}

#pragma mark - UICollectionViewDataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return _listArray.count;
}
-(UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    return UIEdgeInsetsMake(0, 10, 0, 10);//分别为上、左、下、右
}

- ( UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    return [collectionView dequeueReusableCellWithReuseIdentifier:kZCCollectionViewCellID forIndexPath:indexPath];
}

// 点击发送消息
-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    
    //    NSLog(@" 点击水平 item的 事件 %@",indexPath);
    NSDictionary * model = self.tempModel.richModel.hotGuideArr[indexPath.row];
    
    if (_isHistoryMsg) {
        return;
    }
    NSString * question = zcLibConvertToString(model[@"question"]);
    // 发送点击消息
    
    NSDictionary * dict = @{@"title":question,@"ishotguide":@"1"};

    if (self.delegate && [self.delegate respondsToSelector:@selector(cellItemClick:type:obj:)]) {
        [self.delegate cellItemClick:nil type:ZCChatCellClickTypeCollectionSendMsg obj:dict];
    }
    
    
}

#pragma mark - UICollectionViewDelegateFlowLayout

- (void)collectionView:(UICollectionView *)collectionView willDisplayCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath {
    NSDictionary  *model = _listArray[indexPath.row];
    
    ZCCollectionViewCell * vcell = (ZCCollectionViewCell *)cell;
    vcell.collectionCellType = CollectionCellType_Horizontal;
    
    
    NSString * thumbnail= zcLibConvertToString(model[@"icon"]);
    if ([@"" isEqualToString:thumbnail]) {
        thumbnail = zcLibConvertToString(model[@"question"]);
    }
    NSString * title = zcLibConvertToString(model[@"title"]);
    
    NSDictionary * dict = @{
                            @"summary":@"",
                            @"tag":@"",
                            @"label":@"",
                            @"title":title,
                            @"thumbnail":thumbnail
                            };
 
    [vcell configureCellWithPostURL:dict WithIsHistory:_isHistoryMsg];
    
    [vcell.labTitle setFont:ZCUIFont12];
    [vcell.labTitle setTextColor:UIColorFromThemeColor(ZCTextMainColor)];
    vcell.labTitle.numberOfLines = 2;
    vcell.labTitle.textAlignment = NSTextAlignmentCenter;
    [vcell.labTitle sizeToFit];
    CGFloat TH = CGRectGetHeight(vcell.labTitle.frame);
    vcell.labTag.hidden = YES;
    vcell.labDesc.hidden = YES;
    
    // 重新计算高度
    vcell.posterView.hidden = NO;
    vcell.posterView.backgroundColor = [UIColor whiteColor];
    [vcell.posterView setFrame:CGRectMake(22, 18, 40, 40)];
    [vcell.posterView loadWithURL:[NSURL URLWithString:thumbnail] placeholer:nil showActivityIndicatorView:YES];
    [vcell.labTitle setFrame:CGRectMake(6, CGRectGetMaxY(vcell.posterView.frame) + 8, 72, TH)];
    
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


@end
