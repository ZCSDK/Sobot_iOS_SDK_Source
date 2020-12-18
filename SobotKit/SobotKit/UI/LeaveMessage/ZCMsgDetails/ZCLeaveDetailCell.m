//
//  ZCLeaveDetailCell.m
//  SobotKit
//
//  Created by 张新耀 on 2019/9/30.
//  Copyright © 2019 zhichi. All rights reserved.
//

#import "ZCLeaveDetailCell.h"
#import "ZCUIColorsDefine.h"
#import "ZCLibGlobalDefine.h"
#import "ZCUIImageTools.h"
#import "ZCLibSatisfaction.h"
#import "ZCHtmlCore.h"
#import "ZCHtmlFilter.h"
#import "ZCMLEmojiLabel.h"

#import "ZCToolsCore.h"

#import "ZCReplyFileView.h"
#import "ZCDocumentLookController.h"
#import "ZCLibMessage.h"

//#import "ZCXJAlbumController.h"
#import "ZCUIXHImageViewer.h"
#import "ZCVideoPlayer.h"
#import "ZCUIWebController.h"
#import "ZCToolsCore.h"

@interface ZCLeaveDetailCell()<ZCMLEmojiLabelDelegate>
{
    ZCRecordListModel *tempModel;// 临时的变量
}

@property (nonatomic,strong) UILabel * timeLab;

@property (nonatomic,strong) UIButton * statusIcon; // 受理状态图标

@property (nonatomic,strong) UILabel * statusLab;

@property (nonatomic,strong) ZCMLEmojiLabel * replycont;// 回复内容

@property (nonatomic,strong) UIView * lineView; // 竖线条



@property (nonatomic,strong) UIView *infoCardView;//图片卡片显示

@property (nonatomic,strong) UIView *infoCardLineView;//图片卡片白线

@property (nonatomic,strong) UIButton * detailBtn;//跳转webview显示详情的按钮


@property(nonatomic,strong) void (^btnClickBlock)(ZCRecordListModel *model);//评价按钮点击回调

@property(nonatomic,strong) void (^LookdetailClickBlock)(ZCRecordListModel *model,NSString *urlStr);//显示详细按钮点击回调

@property (nonatomic,strong) UIView *lineView_0;//

@property (nonatomic,strong) UIView *lineView_1;//


@end

@implementation ZCLeaveDetailCell

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]){
//        self.contentView.backgroundColor = UIColorFromRGB(0xF0F0F0);
        
        _timeLab = [[UILabel alloc]init];
        _timeLab.textColor = UIColorFromThemeColor(ZCTextSubColor);
        _timeLab.font = ZCUIFont10;
        _timeLab.numberOfLines =  2;
        _timeLab.textAlignment = NSTextAlignmentCenter;
//        _timeLab.backgroundColor = [UIColor redColor];
        [self.contentView addSubview:_timeLab];
        
        
        _lineView = [[UIView alloc]init];
        _lineView.backgroundColor = [ZCUITools zcgetBackgroundBottomLineColor];
        [self.contentView addSubview:_lineView];
        
        _statusIcon = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.contentView addSubview:_statusIcon];
        
        
        
        
        _infoCardView = [[UIView alloc] init];
        _infoCardView.backgroundColor = UIColorFromThemeColor(ZCBgChatLightGrayColor);
        _infoCardView.layer.cornerRadius = 4.0;
        _infoCardView.layer.masksToBounds = YES;
        [self.contentView addSubview:_infoCardView];
        
        _infoCardLineView = [[UIView alloc] init];
        _infoCardLineView.backgroundColor = [ZCUITools zcgetCommentButtonLineColor];
        [self.contentView addSubview:_infoCardLineView];
        
        _replycont =  [[ZCMLEmojiLabel alloc] initWithFrame:CGRectMake(0, 0, self.bounds.size.width, 0)];
//        _replycont.textColor = UIColorFromRGB(TextRecordDetailColor);
        _replycont.font = ZCUIFont14;
        _replycont.numberOfLines = 0;
        _replycont.delegate = self;
        [self.contentView addSubview:_replycont];
        
        _detailBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _detailBtn.titleLabel.font = ZCUIFont12;
//        _detailBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        [_detailBtn setTitle:ZCSTLocalString(@"查看详情") forState:UIControlStateNormal];
        [_detailBtn setTitleColor:UIColorFromRGB(0x45B2E6) forState:UIControlStateNormal];
        [_detailBtn addTarget:self action:@selector(showDetailAction:) forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:_detailBtn];
        _detailBtn.hidden = YES;
        
        
        _statusLab = [[UILabel alloc]init];
        _statusLab.font = ZCUIFontBold14;
        
        [self.contentView addSubview:_statusLab];
        
        _lineView_0 = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.contentView.frame.size.width, 0.5)];
                _lineView_0.backgroundColor = [ZCUITools zcgetBackgroundBottomLineColor];
//        _lineView_0.backgroundColor = [UIColor redColor];
        [self.contentView addSubview:_lineView_0];
        
        _lineView_1 = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.contentView.frame.size.width, 0.5)];
        _lineView_1.backgroundColor =  [ZCUITools zcgetBackgroundBottomLineColor];
        
        [self.contentView addSubview:_lineView_1];
        
    }
    
    return self;
}

-(void)setShowDetailClickCallback:(void (^)(ZCRecordListModel *model,NSString *urlStr))_detailClickBlock{
    
    _LookdetailClickBlock = _detailClickBlock;
}


-(void)setString:(NSString *)string withlLabel:(UILabel *)label withColor:(UIColor *)textColor {
    [ZCHtmlCore filterHtml: [ZCHtmlCore filterHTMLTag:string] result:^(NSString * _Nonnull text1, NSMutableArray * _Nonnull arr, NSMutableArray * _Nonnull links) {
 
        if (text1.length > 0 && text1 != nil) {
            label.attributedText =   [ZCHtmlFilter setHtml:text1 attrs:arr view:label textColor:textColor textFont:label.font linkColor:[ZCUITools zcgetChatLeftLinkColor]];
        }else{
            label.attributedText =   [[NSAttributedString alloc] initWithString:@""];
        }

    }];
    
}



- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

-(void)initWithData:(ZCRecordListModel *)model IndexPath:(NSUInteger)row count:(int)count btnClick:(nonnull void (^)(ZCRecordListModel * _Nonnull))btnClickBlock{
    
    

    
    tempModel = model;
    
    // 回执
    _timeLab.text = @"";
    _statusLab.text = @"";
//    _statusIcon.image = nil;
    _replycont.text = @"";
    
    
    _lineView.frame = CGRectMake(0, 0, 0, 0);
    
    CGFloat cy = 10;
    if(row == 0){
        cy = 21;
    }
    
     //@"2018-04-11 22:22:22";
    NSString *timeText = zcLibDateTransformString(@"MM-dd HH:mm", zcLibStringFormateDate(model.timeStr));
    if(zcLibConvertToString(model.replyTimeStr).length > 8){
        timeText = zcLibDateTransformString(@"MM-dd HH:mm", zcLibStringFormateDate(model.replyTimeStr));
    }
    
    
    [_timeLab setFrame:CGRectMake(20, cy - 2, 38, 36)];
    
    // 完成、关闭
    CGFloat  lineY = 0;
    
    if(row == 0){
        if(model.flag == 3){
            
            [_statusIcon setImage:[ZCUITools zcuiGetBundleImage:@"zcicon_addleavemsgStatus_3"] forState:0];
            _statusIcon.frame = CGRectMake(64, cy+2, 16, 16);
            _statusIcon.imageView.layer.cornerRadius = 5.0f;
            _statusIcon.imageView.layer.masksToBounds  =  YES;
            lineY = 50;
        }
        else if (model.flag == 2){
            [_statusIcon setImage:[ZCUITools zcuiGetBundleImage:@"zcicon_addleavemsgStatus_2"] forState:0];
            _statusIcon.frame = CGRectMake(64, cy+2, 16, 16);
            _statusIcon.imageView.layer.cornerRadius = 5.0f;
            _statusIcon.imageView.layer.masksToBounds  =  YES;
            lineY = 50;
        }
        else if (model.flag == 1){
            [_statusIcon setImage:[ZCUITools zcuiGetBundleImage:@"zcicon_addleavemsgStatus_1"] forState:0];
            _statusIcon.frame = CGRectMake(64, cy+2, 16, 16);
            _statusIcon.imageView.layer.cornerRadius = 5.0f;
            _statusIcon.imageView.layer.masksToBounds  =  YES;
            lineY = 50;
        }
        
    }else{
        [_statusIcon setImage:[ZCUITools zcuiGetBundleImage:@"zciocn_point_old"] forState:0];
        _statusIcon.frame = CGRectMake(68, cy+6, 8, 8);
        _statusIcon.imageView.layer.cornerRadius = 2.0f;
        _statusIcon.imageView.layer.masksToBounds  =  YES;
        [_statusIcon setBackgroundColor:UIColor.clearColor];
        
        lineY = 0;
    }
    

    
    _statusLab.frame = CGRectMake(92, cy, 160, 20);
    _statusLab.text = ZCSTLocalString(@"已创建");
    [_statusLab setTextAlignment:NSTextAlignmentLeft];

    [_statusLab setTextColor:UIColorFromThemeColor(ZCTextSubColor)];
    
    NSString *tmp = zcLibConvertToString(model.replyContent);
    
    
    // 过滤标签 改为过滤图片
//    tmp = [self filterHtmlImage:tmp];
    BOOL isCardView = NO;
    //1 创建了  2 受理了 3 关闭了
    switch (model.flag) {
        case 1:
             _statusLab.text = ZCSTLocalString(@"已创建");
            tmp = @"";
            break;
        case 2:
             _statusLab.text = ZCSTLocalString(@"受理中");
            
            tmp = ZCSTLocalString(@"客服已经成功收到您的问题，请耐心等待");
            _timeLab.text =  zcLibDateTransformString(@"MM-dd HH:mm", zcLibStringFormateDate(model.replyTime));
           
            if (model.startType == 0) {
                tmp = @"";//ZCSTLocalString(@"客服回复");
                if (model.replyContent.length > 0) {
                    tmp = zcLibConvertToString(model.replyContent);
                    isCardView = [self isContaintImage:tmp];
                    tmp = [self filterHtmlImage:tmp];
                }
            }else if (model.startType == 1){
                
                _statusLab.text = ZCSTLocalString(@"我的回复");
                if (model.replyContent.length > 0) {
                    tmp = zcLibConvertToString(model.replyContent);
                    
                    isCardView = [self isContaintImage:tmp];
                    tmp = [self filterHtmlImage:tmp];
                }else{
                    tmp = ZCSTLocalString(@"无");
                }
            }
            break;
        case 3:{
            if (model.startType == 1){
                _statusLab.text = ZCSTLocalString(@"我的回复");
                if (model.replyContent.length > 0) {
                    tmp = zcLibConvertToString(model.replyContent);
                    
                    isCardView = [self isContaintImage:tmp];
                    tmp = [self filterHtmlImage:tmp];
                }else{
                    tmp = ZCSTLocalString(@"无");
                }
            }else{
                [_statusLab setTextColor:UIColorFromThemeColor(ZCTextMainColor)];
                _statusLab.text = ZCSTLocalString(@"已完成");
            }
            
            tmp = zcLibConvertToString(model.content);
            
            isCardView = [self isContaintImage:tmp];
            tmp = [self filterHtmlImage:tmp];
        }
            break;
        default:
            break;
    }
    
   if(isCardView){
       _replycont.frame = CGRectMake(92 + 15, CGRectGetMaxY(_statusLab.frame) + ZCNumber(2) + 11, ScreenWidth - 92 - 30 - 30, ZCNumber(20));
   }else{
       _replycont.frame = CGRectMake(92, CGRectGetMaxY(_statusLab.frame) + ZCNumber(2), ScreenWidth - 92 - 30, ZCNumber(20));
   }
    
    if(row == 0 ){
        [self setString:tmp withlLabel:_replycont withColor:UIColorFromThemeColor(ZCTextMainColor)];
        if ([timeText containsString:@" "]) {
               NSArray *array = [timeText componentsSeparatedByString:@" "];
               if (array.count >= 2) {
                   NSString *timeText_0 = array[0];
                   NSString *timeText_1 = array[1];
                   
                   NSMutableAttributedString *attributedStr = [[NSMutableAttributedString alloc] initWithString:timeText];
                   
                   [attributedStr addAttribute:NSFontAttributeName value:ZCUIFontBold12 range:NSMakeRange(0, timeText_0.length)];
                   [attributedStr addAttribute:NSForegroundColorAttributeName value:UIColorFromThemeColor(ZCTextMainColor) range:NSMakeRange(0, timeText_0.length)];
                   
                   [attributedStr addAttribute:NSFontAttributeName value:ZCUIFontBold10 range:NSMakeRange(timeText.length - timeText_1.length, timeText_1.length)];
                   [attributedStr addAttribute:NSForegroundColorAttributeName value:UIColorFromThemeColor(ZCTextMainColor) range:NSMakeRange(timeText.length - timeText_1.length, timeText_1.length)];

                   _timeLab.attributedText = attributedStr;
               }

           }
    }
    else{
        [self setString:tmp withlLabel:_replycont withColor:UIColorFromThemeColor(ZCTextSubColor)];
        
        if ([timeText containsString:@" "]) {
           NSArray *array = [timeText componentsSeparatedByString:@" "];
           if (array.count >= 2) {
               NSString *timeText_0 = array[0];
               NSString *timeText_1 = array[1];
               
               NSMutableAttributedString *attributedStr = [[NSMutableAttributedString alloc] initWithString:timeText];
               
               [attributedStr addAttribute:NSFontAttributeName value:ZCUIFont12 range:NSMakeRange(0, timeText_0.length)];
               [attributedStr addAttribute:NSForegroundColorAttributeName value:UIColorFromThemeColor(ZCTextSubColor) range:NSMakeRange(0, timeText_0.length)];
               
               [attributedStr addAttribute:NSFontAttributeName value:ZCUIFont10 range:NSMakeRange(timeText.length - timeText_1.length, timeText_1.length)];
               [attributedStr addAttribute:NSForegroundColorAttributeName value:UIColorFromThemeColor(ZCTextSubColor) range:NSMakeRange(timeText.length - timeText_1.length, timeText_1.length)];

               _timeLab.attributedText = attributedStr;
           }
       }
    }
    
    CGRect replyf = _replycont.frame;
    
    CGRect rf = [self getTextRectWith:_replycont.attributedText WithMaxWidth:replyf.size.width WithlineSpacing:4 AddLabel:_replycont];
    
    CGFloat h = 0;
    if (isCardView) {
        self.infoCardView.hidden = NO;
        self.infoCardLineView.hidden = NO;
        self.detailBtn.hidden = NO;
        self.infoCardLineView.hidden = NO;
        
        
        [_infoCardView setFrame:CGRectMake(92, CGRectGetMaxY(_statusLab.frame) + 2, ScreenWidth - 92 - 20, rf.size.height + 63)];
        
        [_infoCardLineView setFrame:CGRectMake(92 + 15, CGRectGetMaxY(rf) + 11, ScreenWidth - 92 - 20 - 30, 1)];
        [_detailBtn setFrame:CGRectMake(92,  CGRectGetMaxY(_infoCardLineView.frame) + 11, ScreenWidth - 92 - 20, 18)];

        h = CGRectGetMaxY(_infoCardView.frame) + 10;
    }else{
        self.infoCardView.hidden = YES;
        self.infoCardLineView.hidden = YES;
        self.detailBtn.hidden = YES;
        self.infoCardLineView.hidden = YES;
        
        h = CGRectGetMaxY(_replycont.frame) + 10;
    }
    
    
//    2.8.2 如果 有附件：
    
    for (UIView *view in [self.contentView subviews]) {
        if ([view isKindOfClass:[ZCReplyFileView class]]) {
            [view removeFromSuperview];
        }
    }
    
    if(model.fileList.count > 0 && model.flag != 1) {
        
        float fileBgView_margin_left = 92;
        float fileBgView_margin_top = 0;
        float fileBgView_margin_right = 20;
        float fileBgView_margin = 10;
        
//      宽度固定为  （屏幕宽度 - 60)/3
        CGSize fileViewRect = CGSizeMake((ScreenWidth - 60)/3, 85);
        
//      算一下每行多少个 ，
        float nums = (ScreenWidth - fileBgView_margin_left - fileBgView_margin_right)/(fileViewRect.width + fileBgView_margin);
        NSInteger numInt = floor(nums);
        
//      行数：
        NSInteger rows = ceil(model.fileList.count/(float)numInt);
        
        
        for (int i = 0 ; i < model.fileList.count;i++) {
            NSDictionary *modelDic = model.fileList[i];
            
            NSMutableDictionary *mutDic = [modelDic mutableCopy];
            [mutDic setValue:[NSString stringWithFormat:@"%lu",(unsigned long)row] forKey:@"cellIndex"];
            
            //           当前列数
            NSInteger currentColumn = i%numInt;
//           当前行数
            NSInteger currentRow = i/numInt;
            
            
            float x = fileBgView_margin_left + (fileViewRect.width + fileBgView_margin)*currentColumn;
            float y = h + fileBgView_margin_top + (fileViewRect.height + fileBgView_margin)*currentRow;
            float w = fileViewRect.width;
            float h = fileViewRect.height;
            
            ZCReplyFileView *fileBgView = [[ZCReplyFileView alloc]initWithDic:mutDic withFrame:CGRectMake(x, y, w, h)];
            fileBgView.layer.cornerRadius = 4;
            fileBgView.layer.masksToBounds = YES;
                
            
            [fileBgView setClickBlock:^(NSDictionary * _Nonnull modelDic, UIImageView * _Nonnull imgView) {
               NSString *fileType = modelDic[@"fileType"];
               NSString *fileUrlStr = modelDic[@"fileUrl"];
//                NSArray *imgArray = [[NSArray alloc]initWithObjects:fileUrlStr, nil];
                if ([fileType isEqualToString:@"jpg"] ||
                    [fileType isEqualToString:@"png"] ||
                    [fileType isEqualToString:@"gif"] ) {
                    
                    //     图片预览
                    
                    UIImageView *picView = imgView;
                    CALayer *calayer = picView.layer.mask;
                    [picView.layer.mask removeFromSuperlayer];
                    
                    ZCUIXHImageViewer *xh=[[ZCUIXHImageViewer alloc] initWithImageViewerWillDismissWithSelectedViewBlock:^(ZCUIXHImageViewer *imageViewer, UIImageView *selectedView) {
                        
                    } didDismissWithSelectedViewBlock:^(ZCUIXHImageViewer *imageViewer, UIImageView *selectedView) {
                        
                        selectedView.layer.mask = calayer;
                        [selectedView setNeedsDisplay];
                    } didChangeToImageViewBlock:^(ZCUIXHImageViewer *imageViewer, UIImageView *selectedView) {
                        
                    }];
                    
                    NSMutableArray *photos = [[NSMutableArray alloc] init];
                    [photos addObject:picView];
                    xh.disableTouchDismiss = NO;
                    [xh showWithImageViews:photos selectedView:picView];
                    
                    
                }
                else if ([fileType isEqualToString:@"mp4"]){
                    NSURL *imgUrl = [NSURL URLWithString:fileUrlStr];
                    
                     UIWindow *window = [[ZCToolsCore getToolsCore] getCurWindow];
                     ZCVideoPlayer *player = [[ZCVideoPlayer alloc] initWithFrame:window.bounds withShowInView:window url:imgUrl Image:nil];
                     [player showControlsView];
                    
                }
                
                else{
                    ZCLibMessage *message = [[ZCLibMessage alloc]init];
                    ZCLibRich *rich = [[ZCLibRich alloc]init];
                    rich.richmoreurl = fileUrlStr;
                    
                    /**
                    * 13 doc文件格式
                    * 14 ppt文件格式
                    * 15 xls文件格式
                    * 16 pdf文件格式
                    * 17 mp3文件格式
                    * 18 mp4文件格式
                    * 19 压缩文件格式
                    * 20 txt文件格式
                    * 21 其他文件格式
                    */
                    if ([fileType isEqualToString:@"doc"] || [fileType isEqualToString:@"docx"] ) {
                        rich.fileType = 13;
                    }
                    else if ([fileType isEqualToString:@"ppt"]){
                        rich.fileType = 14;
                    }
                    else if ([fileType isEqualToString:@"xls"] || [fileType isEqualToString:@"xlsx"]){
                        rich.fileType = 15;
                    }
                    else if ([fileType isEqualToString:@"pdf"]){
                        rich.fileType = 16;
                    }
                    else if ([fileType isEqualToString:@"mp3"]){
                        rich.fileType = 17;
                    }
//                    else if ([fileType isEqualToString:@"mp4"]){
//                        rich.fileType = 18;
//                    }
                    else if ([fileType isEqualToString:@"zip"]){
                        rich.fileType = 19;
                    }
                    else if ([fileType isEqualToString:@"txt"]){
                        rich.fileType = 20;
                    }
                    else{
                        rich.fileType = 21;
                    }
                    
                    
                    message.richModel = rich;
                    message.richModel.msg = modelDic[@"fileName"];
                    ZCDocumentLookController *docVc = [[ZCDocumentLookController alloc]init];
                    docVc.message = message;
                    [self openNewPage:docVc];
                    
                }
                
                
            }];
            [self.contentView addSubview:fileBgView];
        }
        
        h = h + (fileViewRect.height + fileBgView_margin_top)*rows + 30;
    }
    
    
    if(model.flag == 1){
        _lineView.frame = CGRectMake(72, lineY,0.75,cy);
        //cell大小控制
        self.contentView.frame = CGRectMake(0, 0, ScreenWidth, h+20);
        

        
    }else{
        _lineView.frame = CGRectMake(72, lineY,1,h - lineY + 2);
        //cell大小控制
        self.contentView.frame = CGRectMake(0, 0, ScreenWidth, h);
    }
    
    if(row == 0 ){
        if (count == 1) {
            _lineView.hidden = YES;
        }else{
            _lineView.hidden = NO;
        }
        _statusLab.textColor = UIColorFromThemeColor(ZCTextMainColor);
        _replycont.textColor = UIColorFromThemeColor(ZCTextMainColor);
        
        
    }else{
        _lineView.hidden = NO;
        _statusLab.textColor = UIColorFromThemeColor(ZCTextSubColor);
        _replycont.textColor = UIColorFromThemeColor(ZCTextSubColor);
    }
    
    if (row == 0) {
        _lineView_0.hidden = NO;
        _lineView_1.hidden = YES;
    }
    else if (row == count -1){
        _lineView_0.hidden = YES;
        _lineView_1.hidden = NO;
    }else{
        _lineView_0.hidden = YES;
        _lineView_1.hidden = YES;
    }
    
    if (count == 1) {
        _lineView_0.hidden = NO;
        _lineView_1.hidden = NO;
    }
    

    _lineView.backgroundColor = UIColorFromThemeColor(ZCBgLineColor);
    self.frame = self.contentView.frame;
    
    _lineView_0.frame = CGRectMake(0,0, self.contentView.frame.size.width, 0.5);

    _lineView_1.frame = CGRectMake(0, CGRectGetMaxY(self.frame) - 0.5, self.contentView.frame.size.width, 0.5);
    
    if(isRTLLayout()){
        [_statusLab setTextAlignment:NSTextAlignmentRight];
        [_replycont setTextAlignment:NSTextAlignmentRight];
        for(UIView *v in self.contentView.subviews){
            [[ZCToolsCore getToolsCore] setRTLFrame:v];
        }
    }
    
}

#pragma mark -- 计算文本高度
-(CGRect)getTextRectWith:(NSString *)str WithMaxWidth:(CGFloat)width  WithlineSpacing:(CGFloat)LineSpacing AddLabel:(UILabel *)label{
    if ([str isKindOfClass:[NSAttributedString class]]) {
        label.attributedText = (NSAttributedString *)str;
    }else{
        NSMutableAttributedString * attributedString = [[NSMutableAttributedString alloc]initWithString:str];
        NSMutableParagraphStyle * parageraphStyle = [[NSMutableParagraphStyle alloc]init];
        [parageraphStyle setLineSpacing:LineSpacing];
        [attributedString addAttribute:NSParagraphStyleAttributeName value:parageraphStyle range:NSMakeRange(0, [str length])];
        [attributedString addAttribute:NSFontAttributeName value:label.font range:NSMakeRange(0, str.length)];
        
        label.attributedText = attributedString;

    }
    
    CGSize size = [self autoHeightOfLabel:label with:width];
    
    CGRect labelF = label.frame;
    labelF.size.height = size.height;
    label.frame = labelF;
    
    
    return labelF;
}



/**
 计算Label高度
 
 @param label 要计算的label，设置了值
 @param width label的最大宽度
 @param type 是否从新设置宽，1设置，0不设置
 */
- (CGSize )autoHeightOfLabel:(UILabel *)label with:(CGFloat )width{
    //Calculate the expected size based on the font and linebreak mode of your label
    // FLT_MAX here simply means no constraint in height
    CGSize maximumLabelSize = CGSizeMake(width, FLT_MAX);
    
    CGSize expectedLabelSize = [label sizeThatFits:maximumLabelSize];// 返回最佳的视图大小
    
    //adjust the label the the new height.
    CGRect newFrame = label.frame;
    newFrame.size.height = expectedLabelSize.height;
    label.frame = newFrame;
    [label updateConstraintsIfNeeded];
    
    return expectedLabelSize;
}




//- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
//    [super setSelected:selected animated:NO];
//
//    // Configure the view for the selected state
//}



-(NSString *)filterHtmlImage:(NSString *)tmp{
    
    NSString *picStr = [NSString stringWithFormat:@"[%@]",ZCSTLocalString(@"图片")];

    NSRegularExpression *regularExpression = [NSRegularExpression regularExpressionWithPattern:@"<img.*?/>" options:0 error:nil];
    tmp  = [regularExpression stringByReplacingMatchesInString:tmp options:0 range:NSMakeRange(0, tmp.length) withTemplate:picStr];
    
    tmp = [tmp stringByReplacingOccurrencesOfString:@"<br />" withString:@"\n"];
    tmp = [tmp stringByReplacingOccurrencesOfString:@"<br/>" withString:@"\n"];
    tmp = [tmp stringByReplacingOccurrencesOfString:@"<br>" withString:@"\n"];
    tmp = [tmp stringByReplacingOccurrencesOfString:@"<BR/>" withString:@"\n"];
    tmp = [tmp stringByReplacingOccurrencesOfString:@"<BR />" withString:@"\n"];
    tmp = [tmp stringByReplacingOccurrencesOfString:@"<p>" withString:@"\n"];
    tmp = [tmp stringByReplacingOccurrencesOfString:@"</p>" withString:@" "];
    tmp = [tmp stringByReplacingOccurrencesOfString:@"&nbsp;" withString:@" "];
    while ([tmp hasPrefix:@"\n"]) {
        tmp=[tmp substringWithRange:NSMakeRange(1, tmp.length-1)];
    }
    return tmp;
    
}

-(BOOL)isContaintImage:(NSString *)srcString{
    
    NSRegularExpression *regularExpression = [NSRegularExpression regularExpressionWithPattern:@"<img.*?/>" options:0 error:nil];
    NSArray *result = [regularExpression matchesInString:srcString options:NSMatchingReportCompletion range:NSMakeRange(0, srcString.length)];
    
    return result.count;
    
    
}


-(void)showDetailAction:(UIButton *)btn{
    
    if (self.LookdetailClickBlock) {
        self.LookdetailClickBlock(tempModel,nil);
    }
    
}

#pragma mark EmojiLabel链接点击事件
// 链接点击
-(void)attributedLabel:(ZCTTTAttributedLabel *)label didSelectLinkWithURL:(NSURL *)url{
    // 此处得到model 对象对应的值
//    NSLog(@"url:%@  url.absoluteString:%@",url,url.absoluteString);
//    if (self.LookdetailClickBlock) {
//           self.LookdetailClickBlock(nil,url.absoluteString);
//       }
//    else{
//
//    }
    
    //        链接处理：
    [[ZCToolsCore getToolsCore] dealWithLinkClickWithLick:url.absoluteString viewController:[self getControllerFromView:self]];
    

}

#pragma mark - tools 获取当前控制器
- (UIViewController *)getControllerFromView:(UIView *)view {
    // 遍历响应者链。返回第一个找到视图控制器
    UIResponder *responder = view;
    while ((responder = [responder nextResponder])){
        if ([responder isKindOfClass: [UIViewController class]]){
            return (UIViewController *)responder;
        }
    }
    // 如果没有找到则返回nil
    return nil;
}

-(void)openNewPage:(UIViewController *) vc{
    if([self getControllerFromView:self] && [[self getControllerFromView:self] isKindOfClass:[UIViewController class]]){
        if ([self getControllerFromView:self].navigationController) {
//            vc.isNavOpen = YES;
            [[self getControllerFromView:self].navigationController pushViewController:vc animated:YES];
        }else{
            UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:vc];
//            vc.isNavOpen = NO;
            nav.modalPresentationStyle = UIModalPresentationOverFullScreen;
            [[self getControllerFromView:self]  presentViewController:nav animated:YES completion:^{
                
            }];
            
        }
    }
}

@end
