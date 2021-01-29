//
//  ZCFileCell.m
//  SobotKit
//
//  Created by zhangxy on 2018/11/13.
//  Copyright © 2018年 zhichi. All rights reserved.
//

#import "ZCFileCell.h"
#import "ZCProgressView.h"
#import "ZCLibGlobalDefine.h"
#import "ZCUIColorsDefine.h"

#define FileHeight 60

@interface ZCFileCell(){
//    UIView *_bgView;
    ZCProgressView *_progressView;
    UILabel *_labFileName;
    UILabel *_labFileSize;
    UIButton * cancelBtn;// 取消发送；
    ZCLibMessage *_model;
    UIView *_tapView;
}

@end

@implementation ZCFileCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self=[super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if(self){
        
//        _bgView = [[UIView alloc]init];
//        _bgView.layer.cornerRadius = 10;
//        _bgView.layer.borderWidth = 1;
//        _bgView.layer.borderColor = [ZCUITools zcgetRightChatColor].CGColor;
//        [self.contentView addSubview:_bgView];
        
        _progressView = [[ZCProgressView alloc] init];
        [_progressView.layer setMasksToBounds:YES];
        [_progressView setBackgroundColor:[UIColor clearColor]];
        [self.contentView addSubview:_progressView];
        
        _labFileName=[[UILabel alloc] init];
        [_labFileName setTextAlignment:NSTextAlignmentLeft];
        [_labFileName setFont:ZCUIFontBold14];
        [_labFileName setTextColor:UIColorFromThemeColor(ZCTextMainColor)];
        [_labFileName setBackgroundColor:[UIColor clearColor]];
        [self.contentView addSubview:_labFileName];
        
        _labFileSize=[[UILabel alloc] init];
        [_labFileSize setTextAlignment:NSTextAlignmentLeft];
        [_labFileSize setFont:ZCUIFont12];
        [_labFileSize setTextColor:UIColorFromThemeColor(ZCTextSubColor)];
        [_labFileSize setBackgroundColor:[UIColor clearColor]];
        [self.contentView addSubview:_labFileSize];
        
        //设置点击事件
        UITapGestureRecognizer *tapGesturer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tap:)];
//        _bgView.userInteractionEnabled=YES;
        
    
        _tapView = [[UIView alloc]init];
        _tapView.userInteractionEnabled=YES;
        [self.contentView addSubview:_tapView];

        [_tapView addGestureRecognizer:tapGesturer];
        
        cancelBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [cancelBtn setImage:[ZCUITools zcuiGetBundleImage:@"zcicon_close_down"] forState:UIControlStateNormal];
        [cancelBtn addTarget:self action:@selector(cancelSendMsg:) forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:cancelBtn];
        
    }
    return self;
}


-(CGFloat) InitDataToView:(ZCLibMessage *)model time:(NSString *)showTime{
    CGFloat height=[super InitDataToView:model time:showTime];
    _model = model;
    if (self.isRight) {
        [self.ivBgView setBackgroundColor:[ZCUITools zcgetRightChatSelectdeColor]];
    }else{
        [self.ivBgView setBackgroundColor:[ZCUITools zcgetLeftChatSelectedColor]];
    }
    
    
    [_progressView setFaceImage:[ZCUITools getFileIcon:model.richModel.url fileType:model.richModel.fileType]];
    [_labFileSize setText:model.richModel.fileSize];
    [_labFileName setText:zcLibTrimString(model.richModel.fileName)];
    if (model.isHistory) {
        model.progress = 1.0;
    }
    [_progressView setProgress:model.progress];
    
        self.ivBgView.hidden = NO;

    CGFloat msgX = 0;
    
    
    CGSize bgSize = CGSizeMake(self.maxWidth, 70 - 5);
    CGSize iconSize = CGSizeMake(34, 40);
    // 0,自己，1机器人，2客服
    if(self.isRight){
        int rx=self.viewWidth-bgSize.width-15;
        msgX = rx;
        self.ivBgView.frame = CGRectMake(rx, height, bgSize.width, bgSize.height);
        
        [_progressView setFrame:CGRectMake(self.ivBgView.frame.origin.x + 15, height + 12, iconSize.width, iconSize.height)];
        [_labFileName setFrame:CGRectMake(CGRectGetMaxX(_progressView.frame) + 10, height + 12, bgSize.width - iconSize.width - 36, 20)];
        [_labFileSize setFrame:CGRectMake(CGRectGetMaxX(_progressView.frame) + 10, height + 34, bgSize.width - iconSize.width - 36, 20)];
    }else{
        msgX = 15*2;

        [_progressView setFrame:CGRectMake(msgX, height + 12, 30, 40)];
        [_labFileName setFrame:CGRectMake(msgX+36, height + 12, bgSize.width - 36 - msgX, 18)];
        [_labFileSize setFrame:CGRectMake(msgX+36, height + 34, bgSize.width - 36 - msgX, 18)];

        [self.ivBgView setFrame:CGRectMake(15, height, bgSize.width, bgSize.height)];
    }
    height = bgSize.height+12;
    
    // 设置尖角
    [self.ivLayerView setFrame:self.ivBgView.frame];
    CALayer *layer              = self.ivLayerView.layer;
    layer.frame                 = (CGRect){{0,0},self.ivLayerView.layer.frame.size};
    self.ivBgView.layer.mask = layer;
    [self.ivBgView setNeedsDisplay];
   
    
    [self setFrame:CGRectMake(0, 0, self.viewWidth, height)];
    
    //    NSLog(@"_progressView.progress ==++++++++%f",_progressView.progress);
    if (self.isRight && _progressView.progress>0&& _progressView.progress != 1) {
        CGSize cancelBtnSize = CGSizeMake(20, 20);
        cancelBtn.frame = CGRectMake(self.ivBgView.frame.origin.y - cancelBtnSize.width - 10, self.ivBgView.frame.size.height/2 , cancelBtnSize.width, cancelBtnSize.width);
        cancelBtn.hidden = NO;
    }else{
        cancelBtn.hidden = YES;
    }
    
    [self setSendStatus:self.ivBgView.frame];
    
    _tapView.frame = self.ivBgView.frame;
    
    
    
    return height;
}


-(void)setProgress:(CGFloat) progress{
    [_progressView setProgress:progress];
    //    NSLog(@"progress === %f",progress);
    // 如果是右边用户正在发送的
    if (self.isRight && progress>0&& progress<1) {
        CGSize size = CGSizeMake(self.maxWidth, 60);
        int rx = self.viewWidth - size.width - 30 - 50 -18 -19;
        CGSize cancelBtnSize = CGSizeMake(20, 20);
        cancelBtn.frame = CGRectMake(self.ivBgView.frame.origin.x - cancelBtnSize.width - 10, self.ivBgView.frame.size.height/2 , cancelBtnSize.width, cancelBtnSize.width);
        cancelBtn.hidden = NO;
    }else{
        cancelBtn.hidden = YES;
    }
}


// 点击查看大图
-(void) tap:(UITapGestureRecognizer *)recognizer{
    //        [ZCLogUtils logHeader:LogHeader debug:@"查看大图：%@",self.tempModel.richModel.richmoreurl];
    if(self.delegate && [self.delegate respondsToSelector:@selector(cellItemClick:type:obj:)]){
        [self.delegate cellItemClick:self.tempModel type:ZCChatCellClickTypeItemOpenFile obj:nil];
        //                [_delegate itemOnClick:_tempModel clickType:SobotCellClickReSend];
    }
}


-(void)cancelSendMsg:(UIButton *)sender{
    //    NSLog(@"取消发送文件\\");
    if (self.delegate && [self.delegate respondsToSelector:@selector(cellItemClick:type:obj:)]) {
        [self.delegate cellItemClick:_model type:ZCChatCellClickTypeItemCancelFile obj:_model];
    }
    cancelBtn.hidden = YES;
    cancelBtn = nil;
}

-(void)resetCellView{
    //    cancelBtn = nil;
    [super resetCellView];
}


/*
 // Only override drawRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
 - (void)drawRect:(CGRect)rect {
 // Drawing code
 }
 */

+(CGFloat)getCellHeight:(ZCLibMessage *)model time:(NSString *)showTime viewWith:(CGFloat)width{
    CGFloat height = [super getCellHeight:model time:showTime viewWith:width];
    
    height=height+FileHeight + 20;
    return height;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

@end
