//
//  ZCVideoPlayer.m
//  SobotKit
//
//  Created by zhangxy on 2018/11/30.
//  Copyright © 2018年 zhichi. All rights reserved.
//

#import "ZCVideoPlayer.h"
#import "ZCLibGlobalDefine.h"
#import "ZCUIColorsDefine.h"

#import <AVFoundation/AVFoundation.h>
#import "ZCUIImageTools.h"
#import "ZCUILoading.h"

@interface ZCVideoPlayer ()

@property (nonatomic,strong) AVPlayer *player;//播放器对象

@property (nonatomic,strong) AVPlayerLayer *playerLayer;
//监控进度
@property (nonatomic,strong)NSTimer *avTimer;


@property (nonatomic,strong) UIButton *btnBack;//返回
@property (nonatomic,strong) UIView *menuView;//返回
@property (nonatomic,strong) UIButton *btnPlay;//返回
@property (nonatomic,strong) UIButton *btnPause;//暂停
@property (nonatomic,strong) UILabel *labStartTime;//开始
@property (nonatomic,strong) UISlider *sliderProgress;//进度
@property (nonatomic,strong) UILabel *labEndTime;//所有时间


@property (nonatomic,strong) UIView *tipsView;//所有时间
@property (nonatomic,strong) UIImageView * imgView;// 占位图
@end

@implementation ZCVideoPlayer

/*
 // Only override drawRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
 - (void)drawRect:(CGRect)rect {
 // Drawing code
 }
 */

- (instancetype)initWithFrame:(CGRect)frame withShowInView:(UIView *)bgView url:(NSURL *)url Image:(UIImage *)image{
    if (self = [self initWithFrame:frame]) {
       
        self.backgroundColor = UIColor.blackColor;
        self.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
        self.autoresizesSubviews = YES;
        //创建播放器层
        _playerLayer = [AVPlayerLayer playerLayerWithPlayer:self.player];
        _playerLayer.frame = self.bounds;
        _playerLayer.videoGravity = AVLayerVideoGravityResizeAspect;
        //监控播放进度
        self.avTimer = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(timer)userInfo:nil repeats:YES];
        
        [self.layer addSublayer:self.playerLayer];
        if (url) {
            self.videoUrl = url;
        }
        
        if (image != nil) {
            _imgView = [[UIImageView alloc]initWithFrame:frame];
            [_imgView setContentMode:UIViewContentModeScaleAspectFit];
            _imgView.image = image;
            [self addSubview:_imgView];
        }
        
        [bgView addSubview:self];
        
    }
    return self;
}


-(void)layoutSubviews{
    [super layoutSubviews];
    
    if(_playerLayer){
        _playerLayer.frame = self.bounds;
    }
}
-(void)showControlsView{
    
    _btnBack = [UIButton buttonWithType:UIButtonTypeCustom];
    [_btnBack setImage:[ZCUITools zcuiGetBundleImage:@"icon_video_close"] forState:0];
    [_btnBack setTitleColor:UIColor.whiteColor forState:0];
    [_btnBack setFrame:CGRectMake(10, StatusBarHeight + 10, 44, 44)];
    [_btnBack setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
    [_btnBack addTarget:self action:@selector(goBack:) forControlEvents:UIControlEventTouchUpInside];
    _btnBack.autoresizingMask = UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleBottomMargin;
    
    
    _btnPlay = [UIButton buttonWithType:UIButtonTypeCustom];
    [_btnPlay setFrame:CGRectMake(0, 0, 68, 68)];
    [_btnPlay setImage:[ZCUITools zcuiGetBundleImage:@"zcicon_video_fullplay"] forState:0];
    [_btnPlay addTarget:self action:@selector(pause:) forControlEvents:UIControlEventTouchUpInside];
    _btnPlay.center = self.center;
    [_btnPlay setBackgroundColor:UIColor.clearColor];
    _btnPlay.hidden = YES;
    _btnPlay.autoresizingMask = UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleTopMargin;
    
    _menuView = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(self.frame) - 52 - (ZC_iPhoneX?34:0), CGRectGetMaxX(self.frame), 52)];
    [_menuView setBackgroundColor:UIColor.clearColor];
    _menuView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleTopMargin;
    
    
    [self addSubview:_btnBack];
    [self addSubview:_btnPlay];
    [self addSubview:_menuView];
    
    
    _btnPause = [UIButton buttonWithType:UIButtonTypeCustom];
    [_btnPause addTarget:self action:@selector(pause:) forControlEvents:UIControlEventTouchUpInside];
    [_btnPause setFrame:CGRectMake(10, 5, 42, CGRectGetHeight(_menuView.frame) - 10)];
    [_btnPause setImage:[ZCUITools zcuiGetBundleImage:@"icon_video_menu_pause"] forState:0];
    
    _labStartTime = [[UILabel alloc] initWithFrame:CGRectMake(62, 5, 35, CGRectGetHeight(_menuView.frame) - 10)];
    [_labStartTime setFont:ZCUIFont11];
    [_labStartTime setTextColor:UIColorFromThemeColor(ZCKeepWhiteColor)];
    [_labStartTime setText:@"00:00"];
    _labStartTime.autoresizingMask = UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleTopMargin;
    
    
    _labEndTime = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetWidth(_menuView.frame) - 50, 5, 35, CGRectGetHeight(_menuView.frame) - 10)];
    [_labEndTime setFont:ZCUIFont11];
    [_labEndTime setTextColor:UIColorFromThemeColor(ZCKeepWhiteColor)];
    [_labEndTime setText:@"00:00"];
    _labEndTime.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleTopMargin;
    
    
    _sliderProgress = [[UISlider alloc] initWithFrame:CGRectMake(CGRectGetMaxX(_labStartTime.frame) + 5, 5, CGRectGetWidth(_menuView.frame) - CGRectGetMaxX(_labStartTime.frame) - 5 - 55, CGRectGetHeight(_menuView.frame) - 10)];
    _sliderProgress.tintColor = UIColorFromThemeColor(ZCKeepWhiteColor);
    _sliderProgress.minimumTrackTintColor = UIColorFromThemeColor(ZCKeepWhiteColor); // 已走过
    _sliderProgress.maximumTrackTintColor = UIColorFromThemeColor(ZCTextSubColor); // 未走过
    _sliderProgress.thumbTintColor = UIColorFromThemeColor(ZCKeepWhiteColor);        // 滑块颜色
    _sliderProgress.minimumValue = 0;
    _sliderProgress.maximumValue = 1;
    _sliderProgress.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    
    UIImage *img = [ZCUIImageTools zcimageWithColor:UIColorFromThemeColor(ZCKeepWhiteColor)];
    img = [ZCUIImageTools zcScaleToSize:CGSizeMake(12, 12) with:img];
    img = [self imageWihtSize:img.size radius:6 img:img];
    [_sliderProgress setThumbImage:img forState:UIControlStateNormal];
    [_sliderProgress setThumbImage:img forState:UIControlStateHighlighted];


    [_menuView addSubview:_btnPause];
    [_menuView addSubview:_labStartTime];
    [_menuView addSubview:_sliderProgress];
    [_menuView addSubview:_labEndTime];
}

-(UIView *) getTipsView{
    if(!_tipsView){
        _tipsView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 220, 110)];
        _tipsView.backgroundColor = UIColor.whiteColor;
        
        
        UILabel *lab1 = [[UILabel alloc] initWithFrame:CGRectMake(0, 10, 220, 30)];
        [lab1 setTextColor:[ZCUITools zcgetServiceNameTextColor]];
        [lab1 setFont:ZCUIFont17];
        [lab1 setText:ZCSTLocalString(@"播放失败")];
        [_tipsView addSubview:lab1];
        
        UILabel *lab2 = [[UILabel alloc] initWithFrame:CGRectMake(0, 40, 220, 24)];
        [lab2 setTextColor:[ZCUITools zcgetTimeTextColor]];
        [lab2 setFont:ZCUIFont14];
        [lab2 setText:ZCSTLocalString(@"视频文件损坏，无法播放")];
        [_tipsView addSubview:lab2];
        
        
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        [btn setTitle:ZCSTLocalString(@"确定") forState:0];
        [btn addTarget:self action:@selector(goBack:) forControlEvents:UIControlEventTouchUpInside];
        [btn setFrame:CGRectMake(220-60, 110-38, 50, 28)];
        [btn setBackgroundColor:[ZCUITools zcgetBgBannerColor]];
        [btn setTitleColor:[ZCUITools zcgetGoodsSendColor] forState:0];
        [_tipsView addSubview:btn];
    }
    return _tipsView;
}

-(UIImage *)imageWihtSize:(CGSize)size radius:(CGFloat)radius img:(UIImage *) img{
    // 利用绘图建立上下文
    UIGraphicsBeginImageContextWithOptions(size, false, 0);
    CGRect rect = CGRectMake(0, 0, size.width, size.height);
    // 填充颜色
    [UIColor.clearColor setFill];
    UIRectFill(rect);
    // 贝塞尔裁切
    UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:rect cornerRadius:radius];
    [path addClip];
    [img drawInRect:rect];
    
    // 获取结果
    UIImage *resultImage = UIGraphicsGetImageFromCurrentImageContext();
    // 关闭上下文
    UIGraphicsEndImageContext();
    
    return resultImage;
}




//监控播放进度方法
- (void)timer
{
    _labStartTime.text = [self getSOBOT_FORMATE_DATETIME:self.player.currentItem.currentTime];
    _sliderProgress.value = CMTimeGetSeconds(self.player.currentTime) / CMTimeGetSeconds(self.player.currentItem.duration);
    if (_sliderProgress.value >0) {
        if (_imgView != nil) {
            [_imgView removeFromSuperview];
            _imgView = nil;
        }
    }
}

-(void)pause:(UIButton *) btn{
    if(self.player){
        if (self.player.rate == 0) {
            [self.player play];
            
            if(_btnPlay){
                _btnPlay.hidden = YES;
                [_btnPause setImage:[ZCUITools zcuiGetBundleImage:@"icon_video_menu_pause"] forState:0];
            }
        }else{
            [self.player pause];
            
            if(_btnPlay){
                _btnPlay.hidden = NO;
                [_btnPause setImage:[ZCUITools zcuiGetBundleImage:@"icon_video_menu_play"] forState:0];
            }
        }
    }
}


-(void)goBack:(UIButton *) sender{
//    [self removeAvPlayerNtf];
    [self stopPlayer];
    _btnBack = nil;
    _menuView = nil;
    _btnPlay = nil;
    [self removeFromSuperview];
}

- (void)dealloc {
    [self removeAvPlayerNtf];
    [self stopPlayer];
    self.player = nil;
}

- (AVPlayer *)player {
    if (!_player) {
        _player = [AVPlayer playerWithPlayerItem:[self getAVPlayerItem]];
        [self addAVPlayerNtf:_player.currentItem];
        
    }
    
    return _player;
}

- (AVPlayerItem *)getAVPlayerItem {
    AVPlayerItem *playerItem=[AVPlayerItem playerItemWithURL:self.videoUrl];
    return playerItem;
}

- (void)setVideoUrl:(NSURL *)videoUrl {
    _videoUrl = videoUrl;
    [self removeAvPlayerNtf];
    [self nextPlayer];
}

- (void)nextPlayer {
    [self.player seekToTime:CMTimeMakeWithSeconds(0, _player.currentItem.duration.timescale)];
    [self.player replaceCurrentItemWithPlayerItem:[self getAVPlayerItem]];
    [self addAVPlayerNtf:self.player.currentItem];
    if (self.player.rate == 0) {
        [self.player play];
        
        [[ZCUILoading shareZCUILoading] showAddToSuperView:self style:YES];
    }
}

- (void) addAVPlayerNtf:(AVPlayerItem *)playerItem {
    //监控状态属性
    [playerItem addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew context:nil];
    //监控网络加载情况属性
    [playerItem addObserver:self forKeyPath:@"loadedTimeRanges" options:NSKeyValueObservingOptionNew context:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playbackFinished:) name:AVPlayerItemDidPlayToEndTimeNotification object:self.player.currentItem];
}

- (void)removeAvPlayerNtf {
    AVPlayerItem *playerItem = self.player.currentItem;
    [playerItem removeObserver:self forKeyPath:@"status"];
    [playerItem removeObserver:self forKeyPath:@"loadedTimeRanges"];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)stopPlayer {
    if (self.player.rate == 1) {
        [self.player pause];//如果在播放状态就停止
    }
}

/**
 *  通过KVO监控播放器状态
 *
 *  @param keyPath 监控属性
 *  @param object  监视器
 *  @param change  状态改变
 *  @param context 上下文
 */
-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context{
    AVPlayerItem *playerItem = object;
    if ([keyPath isEqualToString:@"status"]) {
        AVPlayerStatus status= [[change objectForKey:@"new"] intValue];
        if(status==AVPlayerStatusReadyToPlay){
            NSLog(@"正在播放...，视频总长度:%.2f",CMTimeGetSeconds(playerItem.duration));
            [[ZCUILoading shareZCUILoading] dismiss];
            [_labEndTime setText:[self getSOBOT_FORMATE_DATETIME:playerItem.duration]];
        }
    }else if([keyPath isEqualToString:@"loadedTimeRanges"]){
//        NSArray *array=playerItem.loadedTimeRanges;
//        CMTimeRange timeRange = [array.firstObject CMTimeRangeValue];//本次缓冲时间范围
//        float startSeconds = CMTimeGetSeconds(timeRange.start);
//        float durationSeconds = CMTimeGetSeconds(timeRange.duration);
//        NSTimeInterval totalBuffer = startSeconds + durationSeconds;//缓冲总长度
//        NSLog(@"共缓冲：%.2f",totalBuffer);
    }else if (self.player.status ==AVPlayerStatusFailed || self.player.status == AVPlayerStatusUnknown) {
        [self addSubview:[self getTipsView]];
        _tipsView.hidden = NO;
        _tipsView.center = self.center;
    }
        
}

-(NSString *)getSOBOT_FORMATE_DATETIME:(CMTime ) duration {
    CGFloat seconds = CMTimeGetSeconds(duration);
    NSString  *mm = (int)seconds/60 > 9 ? [NSString stringWithFormat:@"%d",(int)seconds/60] : [NSString stringWithFormat:@"0%d",(int)seconds/60];
    NSString  *ss = (int)seconds % 60 > 9 ? [NSString stringWithFormat:@"%d",(int)seconds%60] : [NSString stringWithFormat:@"0%d",(int)seconds%60];
    return [NSString stringWithFormat:@"%@:%@",mm,ss];
}

- (void)playbackFinished:(NSNotification *)ntf {
    [self.player seekToTime:CMTimeMake(0, 1)];
    [self.player play];
    
    
    [_labStartTime setText:@"00:00"];
    _sliderProgress.value = 0;
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
