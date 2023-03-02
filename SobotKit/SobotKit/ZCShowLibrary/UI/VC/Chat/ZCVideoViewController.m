//
//  ZCVideoViewController.m
//  SobotKit
//
//  Created by zhangxy on 2018/11/30.
//  Copyright © 2018年 zhichi. All rights reserved.
//

#import "ZCVideoViewController.h"
#import <AVFoundation/AVFoundation.h>
#import "ZCVideoPlayer.h"
#import "ZCCircleProgressView.h"
#import <Foundation/Foundation.h>
#import <AssetsLibrary/AssetsLibrary.h>

#import "ZCLibGlobalDefine.h"
#import "ZCUIColorsDefine.h"
#import "ZCUIImageTools.h"
#import "ZCUIToastTools.h"

@interface ZCVideoViewController ()<AVCaptureFileOutputRecordingDelegate>

typedef void(^ZCPropertyChangeBlock)(AVCaptureDevice *captureDevice);

@property (assign, nonatomic) NSInteger HSeconds;

//轻触拍照，按住摄像
@property (strong, nonatomic) UILabel *labelTipTitle;

//视频输出流
@property (strong,nonatomic) AVCaptureMovieFileOutput *captureMovieFileOutput;
//图片输出流
//@property (strong,nonatomic) AVCaptureStillImageOutput *captureStillImageOutput;//照片输出流
//负责从AVCaptureDevice获得输入数据

@property (strong,nonatomic) AVCaptureDeviceInput *captureDeviceInput;
//后台任务标识
@property (assign,nonatomic) UIBackgroundTaskIdentifier backgroundTaskIdentifier;

@property (assign,nonatomic) UIBackgroundTaskIdentifier lastBackgroundTaskIdentifier;

@property (weak, nonatomic) UIImageView *focusCursor; //聚焦光标

//负责输入和输出设备之间的数据传递
@property(nonatomic)AVCaptureSession *session;

//图像预览层，实时显示捕获的图像
@property(nonatomic)AVCaptureVideoPreviewLayer *previewLayer;

@property (strong, nonatomic) IBOutlet UIButton *btnBack;
//重新录制
@property (strong, nonatomic) IBOutlet UIButton *btnAfresh;
//确定
@property (strong, nonatomic) IBOutlet UIButton *btnEnsure;
//摄像头切换
@property (strong, nonatomic) IBOutlet UIButton *btnCamera;

@property (strong, nonatomic) IBOutlet UIImageView *bgView;
//记录录制的时间 默认最大15秒
@property (assign, nonatomic) NSInteger seconds;

//记录需要保存视频的路径
@property (strong, nonatomic) NSURL *saveVideoUrl;

//是否在对焦
@property (assign, nonatomic) BOOL isFocus;

//视频播放
@property (strong, nonatomic) ZCVideoPlayer *player;

@property (strong, nonatomic) ZCCircleProgressView *progressView;

//是否是摄像 YES 代表是录制  NO 表示拍摄
@property (assign, nonatomic) BOOL isVideo;

@property (strong, nonatomic) UIImage *takeImage;
@property (strong, nonatomic) UIImageView *takeImageView;
@property (strong, nonatomic) UIImageView *imgRecord;

@end

//时间大于这个就是视频，否则为拍摄
#define TimeMax 1

@implementation ZCVideoViewController

-(void)setupView{
    self.view.autoresizesSubviews = YES;
    _bgView = [[UIImageView alloc] initWithFrame:self.view.bounds];
    _bgView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
    _btnCamera = [UIButton buttonWithType:UIButtonTypeCustom];
    [_btnCamera setFrame:CGRectMake(ScreenWidth - 64,StatusBarHeight + 20, 44, 44)];
    [_btnCamera setImage:[ZCUITools zcuiGetBundleImage:@"zcicon_change_camera"] forState:0];
    _btnCamera.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin|UIViewAutoresizingFlexibleLeftMargin;
    
    _btnBack = [UIButton buttonWithType:UIButtonTypeCustom];
    [_btnBack setFrame:CGRectMake(50,ScreenHeight - 50 - 68, 68, 68)];
    [_btnBack setImage:[ZCUITools zcuiGetBundleImage:@"zcicon_video_down"] forState:0];
    _btnBack.autoresizingMask = UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleRightMargin;
    
    
    _btnAfresh = [UIButton buttonWithType:UIButtonTypeCustom];
    [_btnAfresh setFrame:CGRectMake(50,ScreenHeight - 50 - 68, 68, 68)];
    [_btnAfresh setImage:[ZCUITools zcuiGetBundleImage:@"zcicon_video_reload"] forState:0];
    _btnAfresh.hidden = YES;
    _btnAfresh.autoresizingMask = UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin;
    
    _btnEnsure = [UIButton buttonWithType:UIButtonTypeCustom];
    [_btnEnsure setFrame:CGRectMake(ScreenWidth - 68 - 50 ,ScreenHeight - 68-50, 68, 68)];
    [_btnEnsure setImage:[ZCUITools zcuiGetBundleImage:@"zcicon_video_confirm"] forState:0];
    _btnEnsure.hidden = YES;
    _btnEnsure.autoresizingMask = UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin;
    
    
    _progressView = [[ZCCircleProgressView alloc] initWithFrame:CGRectMake(ScreenWidth/2 - 45, ScreenHeight - 90 - 39, 90, 90)];
    _progressView.lineWidth = 5.0f;
    _progressView.tintColor = UIColorFromThemeColor(ZCThemeColor);
    _progressView.borderWidth = 0;
    [_progressView setBackgroundColor:UIColorFromThemeColor(ZCBgLineColor)];
    _progressView.hidden = YES;
    _progressView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin;
    
    _imgRecord = [[UIImageView alloc] initWithFrame:CGRectMake(ScreenWidth/2 - 68/2, ScreenHeight - 68 - 50, 68, 68)];
    [_imgRecord setImage:[ZCUITools zcuiGetBundleImage:@"zcicon_video_camera"]];
    _imgRecord.layer.cornerRadius = 34.0;
    _imgRecord.layer.masksToBounds = YES;
    [_imgRecord setUserInteractionEnabled:YES];
    _imgRecord.autoresizingMask = UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin;
    
    
    _labelTipTitle = [[UILabel alloc] initWithFrame:CGRectMake(10, ScreenHeight - 68 - 50 - 46, ScreenWidth-20, 36)];
    [_labelTipTitle setTextColor:UIColorFromThemeColor(ZCKeepWhiteColor)];
    [_labelTipTitle setTextAlignment:NSTextAlignmentCenter];
    _labelTipTitle.numberOfLines = 2;
    [_labelTipTitle setFont:ZCUIFont14];
    [_labelTipTitle setText:ZCSTLocalString(@"轻触拍照，按住摄像")];
    _labelTipTitle.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleTopMargin;
    
    [self.view addSubview:_bgView];
    [self.view addSubview:_progressView];
    [self.view addSubview:_btnCamera];
    [self.view addSubview:_btnEnsure];
    [self.view addSubview:_btnAfresh];
    [self.view addSubview:_btnBack];
    [self.view addSubview:_labelTipTitle];
    [self.view addSubview:_imgRecord];
    
    
    [_btnBack addTarget:self action:@selector(onCancelAction:) forControlEvents:UIControlEventTouchUpInside];
    [_btnCamera addTarget:self action:@selector(onCameraAction:) forControlEvents:UIControlEventTouchUpInside];
    [_btnAfresh addTarget:self action:@selector(onAfreshAction:) forControlEvents:UIControlEventTouchUpInside];
    [_btnEnsure addTarget:self action:@selector(onEnsureAction:) forControlEvents:UIControlEventTouchUpInside];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setupView];
//    UIImage *image = [UIImage imageNamed:@"sc_btn_take.png"];
    
    self.progressView.layer.cornerRadius = self.progressView.frame.size.width/2;
    
    if (self.HSeconds == 0) {
        self.HSeconds = 15;
    }
    
    [self performSelector:@selector(hiddenTipsLabel) withObject:nil afterDelay:4];
}


- (void)hiddenTipsLabel {
    self.labelTipTitle.hidden = YES;
}


- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [[UIApplication sharedApplication] setStatusBarHidden:YES];
    [self customCamera];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self.session startRunning];
    });
}


-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
}

-(void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    [self.session stopRunning];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
}


- (void)customCamera {
    //初始化会话，用来结合输入输出
    self.session = [[AVCaptureSession alloc] init];
    //设置分辨率 (设备支持的最高分辨率)
    if ([self.session canSetSessionPreset:AVCaptureSessionPresetHigh]) {
        self.session.sessionPreset = AVCaptureSessionPresetHigh;
    }

    //取得后置摄像头
    AVCaptureDevice *captureDevice = [self getCameraDeviceWithPosition:AVCaptureDevicePositionBack];
    //添加一个音频输入设备
    AVCaptureDevice *audioCaptureDevice=[[AVCaptureDevice devicesWithMediaType:AVMediaTypeAudio] firstObject];
    
    //设置闪光灯状态为自动
    [captureDevice lockForConfiguration:nil];
    if ([captureDevice hasFlash]) {
        if ([captureDevice isFlashModeSupported:AVCaptureFlashModeAuto]) {
            [captureDevice setFlashMode:AVCaptureFlashModeAuto];
        }
    }
    [captureDevice unlockForConfiguration];
        
    //初始化输入设备
    NSError *error = nil;
    self.captureDeviceInput = [[AVCaptureDeviceInput alloc] initWithDevice:captureDevice error:&error];
    if (error) {
//        NSlog(@"取得设备输入对象时出错，错误原因：%@",error.localizedDescription);
        return;
    }
    
    //添加音频
    error = nil;
    AVCaptureDeviceInput *audioCaptureDeviceInput=[[AVCaptureDeviceInput alloc]initWithDevice:audioCaptureDevice error:&error];
    if (error) {
//        NSlog(@"取得设备输入对象时出错，错误原因：%@",error.localizedDescription);
        return;
    }
    
    //输出对象
    self.captureMovieFileOutput = [[AVCaptureMovieFileOutput alloc] init];//视频输出
    
    //将输入设备添加到会话
    if ([self.session canAddInput:self.captureDeviceInput]) {
        [self.session addInput:self.captureDeviceInput];
        [self.session addInput:audioCaptureDeviceInput];
        //设置视频防抖
        AVCaptureConnection *connection = [self.captureMovieFileOutput connectionWithMediaType:AVMediaTypeVideo];
        if ([connection isVideoStabilizationSupported]) {
            connection.preferredVideoStabilizationMode = AVCaptureVideoStabilizationModeCinematic;
        }
    }
    
    //将输出设备添加到会话 (刚开始 是照片为输出对象)
    if ([self.session canAddOutput:self.captureMovieFileOutput]) {
        [self.session addOutput:self.captureMovieFileOutput];
    }
    
    //创建视频预览层，用于实时展示摄像头状态
    self.previewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:self.session];
    self.previewLayer.frame = self.view.bounds;//CGRectMake(0, 0, self.view.width, self.view.height);
    self.previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;//填充模式
    [self.bgView.layer addSublayer:self.previewLayer];
    
    [self addNotificationToCaptureDevice:captureDevice];
    [self addGenstureRecognizer];
}

/**
 横竖屏切换时，刷新页面布局
 */
-(void)viewDidLayoutSubviews{
    [super viewDidLayoutSubviews];
    if(self.previewLayer){
        self.previewLayer.frame = self.view.bounds;//CGRectMake(0, 0, self.view.width, self.view.height);
        self.previewLayer.connection.videoOrientation = [self videoOrientationFromCurrentDeviceOrientation];
    }
}


- (AVCaptureVideoOrientation) videoOrientationFromCurrentDeviceOrientation {
    AVCaptureVideoOrientation orientation = AVCaptureVideoOrientationPortrait;
    UIInterfaceOrientation interfaceOrientation = [[UIApplication sharedApplication] statusBarOrientation];
    switch (interfaceOrientation) {
        case UIInterfaceOrientationPortrait: {
            orientation = AVCaptureVideoOrientationPortrait;
            break;
        }
        case UIInterfaceOrientationLandscapeLeft: {
            orientation = AVCaptureVideoOrientationLandscapeLeft;
            break;
        }
        case UIInterfaceOrientationLandscapeRight: {
            orientation = AVCaptureVideoOrientationLandscapeRight;
            break;
        }
        case UIInterfaceOrientationPortraitUpsideDown: {
            orientation = AVCaptureVideoOrientationPortraitUpsideDown;
            break;
        }
        case UIInterfaceOrientationUnknown: {
            
            break;
        }
    }
    return orientation;
}

- (IBAction)onCancelAction:(UIButton *)sender {
    if(self.player){
        [self.player stopPlayer];
    }
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
    
}


- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    if ([[touches anyObject] view] == self.imgRecord) {
//        NSlog(@"开始录制");
        //根据设备输出获得连接
        AVCaptureConnection *connection = [self.captureMovieFileOutput connectionWithMediaType:AVMediaTypeVideo];
        //根据连接取得设备输出的数据
        if (![self.captureMovieFileOutput isRecording]) {
            //如果支持多任务则开始多任务
            if ([[UIDevice currentDevice] isMultitaskingSupported]) {
                self.backgroundTaskIdentifier = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:nil];
            }
            if (self.saveVideoUrl) {
                [[NSFileManager defaultManager] removeItemAtURL:self.saveVideoUrl error:nil];
            }
            
            //预览图层和视频方向保持一致
            if ([connection isVideoOrientationSupported]) {
                connection.videoOrientation = [self videoOrientationFromCurrentDeviceOrientation];
            }
            NSString *outputFielPath=[NSTemporaryDirectory() stringByAppendingString:@"myMovie.mp4"];
//            NSLog(@"save path is :%@",outputFielPath);
            NSURL *fileUrl=[NSURL fileURLWithPath:outputFielPath];
//            NSLog(@"fileUrl:%@",fileUrl);
            [self.captureMovieFileOutput startRecordingToOutputFileURL:fileUrl recordingDelegate:self];
        } else {
            [self.captureMovieFileOutput stopRecording];
        }
    }
}


- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    if ([[touches anyObject] view] == self.imgRecord) {
//        NSlog(@"结束触摸");
        if (!self.isVideo) {
            [self performSelector:@selector(endRecord) withObject:nil afterDelay:0.3];
        } else {
            [self endRecord];
        }
    }
}

- (void)endRecord {
    [self.captureMovieFileOutput stopRecording];//停止录制
}

- (IBAction)onAfreshAction:(UIButton *)sender {
//    NSlog(@"重新录制");
    [self recoverLayout];
}

- (IBAction)onEnsureAction:(UIButton *)sender {
//    NSlog(@"确定 这里进行保存或者发送出去");
    if (self.saveVideoUrl) {
        if (self.operationResultBlock) {
            
            [self converToMp4];
        }
        [self onCancelAction:nil];
        
//        __weak __typeof(&*self)weakSelf = self;
//        [[ZCUIToastTools shareToast] showToast:[NSString stringWithFormat:@"   %@  ",ZCSTLocalString(@"视频处理中...")] duration:1.0f view:self.view.window.rootViewController.view position:ZCToastPositionCenter Image:[ZCUITools zcuiGetBundleImage:@"zcicon_successful"]];
//
//
//        ALAssetsLibrary *assetsLibrary=[[ALAssetsLibrary alloc]init];
//        [assetsLibrary writeVideoAtPathToSavedPhotosAlbum:self.saveVideoUrl completionBlock:^(NSURL *assetURL, NSError *error) {
//            NSLog(@"outputUrl:%@",weakSelf.saveVideoUrl);
//            [[NSFileManager defaultManager] removeItemAtURL:weakSelf.saveVideoUrl error:nil];
//            if (weakSelf.lastBackgroundTaskIdentifier!= UIBackgroundTaskInvalid) {
//                [[UIApplication sharedApplication] endBackgroundTask:weakSelf.lastBackgroundTaskIdentifier];
//            }
//            if (error) {
////                NSlog(@"保存视频到相簿过程中发生错误，错误信息：%@",error.localizedDescription);
//                [[ZCUIToastTools shareToast] showToast:[NSString stringWithFormat:@"   %@  ",ZCSTLocalString(@"保存视频到相册发生错误")] duration:1.0f view:self.view.window.rootViewController.view position:ZCToastPositionCenter Image:[ZCUITools zcuiGetBundleImage:@"zcicon_successful"]];
//            } else {
//                if (weakSelf.operationResultBlock) {
//                    weakSelf.operationResultBlock(assetURL);
//                }
////                NSlog(@"成功保存视频到相簿.");
//                [weakSelf onCancelAction:nil];
//            }
//        }];
    } else {
        //照片
//        UIImageWriteToSavedPhotosAlbum(self.takeImage, self, nil, nil);
        if (self.operationResultBlock) {
            self.operationResultBlock(self.takeImage);
        }
        
        [self onCancelAction:nil];
    }
}


-(void) converToMp4{
    NSURL *videoUrl = self.saveVideoUrl;
    AVURLAsset *avAsset = [AVURLAsset URLAssetWithURL:videoUrl options:nil];
//    [[ZCUIToastTools shareToast] showToast:ZCSTLocalString(@"视频处理中，请稍候!") duration:1.0 view:self.view  position:ZCToastPositionCenter];
    
    __weak  ZCVideoViewController *videoSaveSelf  = self;
    AVAssetExportSession *exportSession = [[AVAssetExportSession alloc] initWithAsset:avAsset presetName:AVAssetExportPresetMediumQuality];
    
    //    NSDateFormatter *formater = [[NSDateFormatter alloc] init];//用时间给文件全名，以免重复
    //    [formater setDateFormat:@"yyyy-MM-dd-HH:mm:ss"];
    
    NSString * fname = [NSString stringWithFormat:@"/sobot/output-%ld.mp4",(long)[NSDate date].timeIntervalSince1970];
    sobotCheckPathAndCreate(sobotGetTempFilePath(@"/sobot/"));
    NSString *resultPath=sobotGetTempFilePath(fname);
//    NSLog(@"resultPath = %@",resultPath);
    exportSession.outputURL = [NSURL fileURLWithPath:resultPath];
    exportSession.outputFileType = AVFileTypeMPEG4;
    exportSession.shouldOptimizeForNetworkUse = YES;
    [exportSession exportAsynchronouslyWithCompletionHandler:^(void)
     {
         switch (exportSession.status) {
             case AVAssetExportSessionStatusCompleted:{
//                 NSLog(@"AVAssetExportSessionStatusCompleted%@",[NSThread currentThread]);
                 // 主队列回调
                 dispatch_async(dispatch_get_main_queue(), ^{
                     UIImage *img = [self createVideoImage:self.saveVideoUrl];
                     
                     NSData * imageData =UIImageJPEGRepresentation(img, 1.0f);
                     NSString * fname = [NSString stringWithFormat:@"/sobot/image100%ld.jpg",(long)[NSDate date].timeIntervalSince1970];
                     sobotCheckPathAndCreate(sobotGetDocumentsFilePath(@"/sobot/"));
                     NSString *fullPath=sobotGetDocumentsFilePath(fname);
                     [imageData writeToFile:fullPath atomically:YES];
                     videoSaveSelf.operationResultBlock(@{@"video":[NSURL fileURLWithPath:[self URLDecodedString:sobotConvertToString(resultPath)]],@"image":sobotConvertToString(fullPath)});
                 });
             }
                 break;
             case AVAssetExportSessionStatusUnknown:
//                 NSLog(@"AVAssetExportSessionStatusUnknown");
                 break;
                 
             case AVAssetExportSessionStatusWaiting:
                 
//                 NSLog(@"AVAssetExportSessionStatusWaiting");
                 
                 break;
                 
             case AVAssetExportSessionStatusExporting:
                 
//                 NSLog(@"AVAssetExportSessionStatusExporting");
                 
                 break;
             case AVAssetExportSessionStatusFailed:
                 
//                 NSLog(@"AVAssetExportSessionStatusFailed");
                 
                 break;
             case AVAssetExportSessionStatusCancelled:
                 
                 break;
         }
     }];
}


- (NSString *)URLDecodedString:(NSString *) url
{
    NSString *result = [(NSString *)url stringByReplacingOccurrencesOfString:@"+" withString:@" "];
    return [result stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
}

//前后摄像头的切换
- (IBAction)onCameraAction:(UIButton *)sender {
//    NSlog(@"切换摄像头");
    AVCaptureDevice *currentDevice=[self.captureDeviceInput device];
    AVCaptureDevicePosition currentPosition=[currentDevice position];
    [self removeNotificationFromCaptureDevice:currentDevice];
    AVCaptureDevice *toChangeDevice;
    AVCaptureDevicePosition toChangePosition = AVCaptureDevicePositionFront;//前
    if (currentPosition == AVCaptureDevicePositionUnspecified || currentPosition == AVCaptureDevicePositionFront) {
        toChangePosition = AVCaptureDevicePositionBack;//后
    }
    toChangeDevice=[self getCameraDeviceWithPosition:toChangePosition];
    [self addNotificationToCaptureDevice:toChangeDevice];
    
    //设置闪光灯状态为自动
    [toChangeDevice lockForConfiguration:nil];
    if ([toChangeDevice hasFlash]) {
        if ([toChangeDevice isFlashModeSupported:AVCaptureFlashModeAuto]) {
            [toChangeDevice setFlashMode:AVCaptureFlashModeAuto];
        }
    }
    [toChangeDevice unlockForConfiguration];
    
    
    //获得要调整的设备输入对象
    AVCaptureDeviceInput *toChangeDeviceInput=[[AVCaptureDeviceInput alloc]initWithDevice:toChangeDevice error:nil];
    
    //改变会话的配置前一定要先开启配置，配置完成后提交配置改变
    [self.session beginConfiguration];
    //移除原有输入对象
    [self.session removeInput:self.captureDeviceInput];
    //添加新的输入对象
    if ([self.session canAddInput:toChangeDeviceInput]) {
        [self.session addInput:toChangeDeviceInput];
        self.captureDeviceInput = toChangeDeviceInput;
    }
    //提交会话配置
    [self.session commitConfiguration];
}


- (void)onStartTranscribe:(NSURL *)fileURL {
    if ([self.captureMovieFileOutput isRecording]) {
        -- self.seconds;
        if (self.seconds > 0) {
            if (self.HSeconds - self.seconds >= TimeMax && !self.isVideo) {
                self.isVideo = YES;//长按时间超过TimeMax 表示是视频录制
                _progressView.hidden = NO;
            }
            [_progressView setProgress:(self.HSeconds - self.seconds)*1.0/self.HSeconds];
//            NSLog(@"当前进度：----%zd -- %f",self.seconds,(self.HSeconds - self.seconds)*100.0/self.HSeconds);
            [self performSelector:@selector(onStartTranscribe:) withObject:fileURL afterDelay:1.0];
        } else {
            if ([self.captureMovieFileOutput isRecording]) {
                [self.captureMovieFileOutput stopRecording];
            }
        }
    }
}


#pragma mark - 视频输出代理
-(void)captureOutput:(AVCaptureFileOutput *)captureOutput didStartRecordingToOutputFileAtURL:(NSURL *)fileURL fromConnections:(NSArray *)connections{
//    NSlog(@"开始录制...");
    self.seconds = self.HSeconds;
    [self performSelector:@selector(onStartTranscribe:) withObject:fileURL afterDelay:1.0];
}

#pragma mark -- 视频录制完成
-(void)captureOutput:(AVCaptureFileOutput *)captureOutput didFinishRecordingToOutputFileAtURL:(NSURL *)outputFileURL fromConnections:(NSArray *)connections error:(NSError *)error{
//    NSlog(@"视频录制完成.");
    [self changeLayout];
    if (self.isVideo) {
        self.saveVideoUrl = outputFileURL;
        
        if (!self.player) {
            self.player = [[ZCVideoPlayer alloc] initWithFrame:self.bgView.bounds withShowInView:self.bgView url:outputFileURL Image:nil];
        } else {
            if (outputFileURL) {
                self.player.videoUrl = outputFileURL;
                self.player.hidden = NO;
            }
        }
    } else {
        //照片
        self.saveVideoUrl = nil;
        [self videoHandlePhoto:outputFileURL];
    }
    
}

- (void)videoHandlePhoto:(NSURL *)url {
    self.takeImage = [self createVideoImage:url];//[UIImage imageWithCGImage:cgImage];
    if(self.takeImageView){
        [self.takeImageView removeFromSuperview];
        self.takeImageView = nil;
    }
    
    if (!self.takeImageView) {
        self.takeImageView = [[UIImageView alloc] initWithFrame:self.view.frame];
        self.takeImageView.backgroundColor = [UIColor blackColor];
        self.takeImageView.contentMode = UIViewContentModeScaleAspectFit;
        [self.bgView addSubview:self.takeImageView];
    }
    self.takeImageView.hidden = NO;
    self.takeImageView.image = self.takeImage;
//    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//        [[NSFileManager defaultManager] removeItemAtURL:url error:nil];
//    });
}

-(UIImage *)createVideoImage:(NSURL *) url{
    NSLog(@"url === %@",url);
    AVURLAsset *urlSet = [AVURLAsset assetWithURL:url];
    AVAssetImageGenerator *imageGenerator = [AVAssetImageGenerator assetImageGeneratorWithAsset:urlSet];
    imageGenerator.appliesPreferredTrackTransform = YES;    // 截图的时候调整到正确的方向
//    imageGenerator.maximumSize = CGSizeMake(ScreenWidth, ScreenHeight);
    imageGenerator.apertureMode = AVAssetImageGeneratorApertureModeEncodedPixels;
    NSError *error = nil;
//    Float64 durationSeconds = CMTimeGetSeconds([urlSet duration]);
//    CMTime firstThird = CMTimeMakeWithSeconds(durationSeconds/3.0, 600);
//    CMTime secondThird = CMTimeMakeWithSeconds(durationSeconds*2.0/3.0, 600);
//    CMTime end = CMTimeMakeWithSeconds(durationSeconds, 600);

    CMTime time = CMTimeMake(0,60);//缩略图创建时间 CMTime是表示电影时间信息的结构体，第一个参数表示是视频第几秒，第二个参数表示每秒帧数.(如果要获取某一秒的第几帧可以使用CMTimeMake方法)
    CMTime actucalTime; //缩略图实际生成的时间
    CGImageRef cgImage = [imageGenerator copyCGImageAtTime:time actualTime:&actucalTime error:&error];
    if (error) {
//        NSLog(@"截取视频图片失败:%@",error.localizedDescription);
    }
    CMTimeShow(actucalTime);
    UIImage *image = [UIImage imageWithCGImage:cgImage];
    
    CGImageRelease(cgImage);
    if (image) {
//        NSLog(@"视频截取成功");
    } else {
//        NSLog(@"视频截取失败");
    }
    return image;
}

#pragma mark - 通知

//注册通知
- (void)setupObservers
{
    NSNotificationCenter *notification = [NSNotificationCenter defaultCenter];
    [notification addObserver:self selector:@selector(applicationDidEnterBackground:) name:UIApplicationWillResignActiveNotification object:[UIApplication sharedApplication]];
}

//进入后台就退出视频录制
- (void)applicationDidEnterBackground:(NSNotification *)notification {
    [self onCancelAction:nil];
}

/**
 *  给输入设备添加通知
 */
-(void)addNotificationToCaptureDevice:(AVCaptureDevice *)captureDevice{
    //注意添加区域改变捕获通知必须首先设置设备允许捕获
    [self changeDeviceProperty:^(AVCaptureDevice *captureDevice) {
        captureDevice.subjectAreaChangeMonitoringEnabled=YES;
    }];
    NSNotificationCenter *notificationCenter= [NSNotificationCenter defaultCenter];
    //捕获区域发生改变
    [notificationCenter addObserver:self selector:@selector(areaChange:) name:AVCaptureDeviceSubjectAreaDidChangeNotification object:captureDevice];
}
-(void)removeNotificationFromCaptureDevice:(AVCaptureDevice *)captureDevice{
    NSNotificationCenter *notificationCenter= [NSNotificationCenter defaultCenter];
    [notificationCenter removeObserver:self name:AVCaptureDeviceSubjectAreaDidChangeNotification object:captureDevice];
}
/**
 *  移除所有通知
 */
-(void)removeNotification{
    NSNotificationCenter *notificationCenter= [NSNotificationCenter defaultCenter];
    [notificationCenter removeObserver:self];
}

-(void)addNotificationToCaptureSession:(AVCaptureSession *)captureSession{
    NSNotificationCenter *notificationCenter= [NSNotificationCenter defaultCenter];
    //会话出错
    [notificationCenter addObserver:self selector:@selector(sessionRuntimeError:) name:AVCaptureSessionRuntimeErrorNotification object:captureSession];
}

/**
 *  设备连接成功
 *
 *  @param notification 通知对象
 */
-(void)deviceConnected:(NSNotification *)notification{
//    NSLog(@"设备已连接...");
}
/**
 *  设备连接断开
 *
 *  @param notification 通知对象
 */
-(void)deviceDisconnected:(NSNotification *)notification{
//    NSLog(@"设备已断开.");
}
/**
 *  捕获区域改变
 *
 *  @param notification 通知对象
 */
-(void)areaChange:(NSNotification *)notification{
//    NSLog(@"捕获区域改变...");
}

/**
 *  会话出错
 *
 *  @param notification 通知对象
 */
-(void)sessionRuntimeError:(NSNotification *)notification{
//    NSLog(@"会话发生错误.");
}



/**
 *  取得指定位置的摄像头
 *
 *  @param position 摄像头位置
 *
 *  @return 摄像头设备
 */
-(AVCaptureDevice *)getCameraDeviceWithPosition:(AVCaptureDevicePosition )position{
    NSArray *cameras= [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    for (AVCaptureDevice *camera in cameras) {
        if ([camera position] == position) {
            return camera;
        }
    }
    return nil;
}

/**
 *  改变设备属性的统一操作方法
 *
 *  @param propertyChange 属性改变操作
 */
-(void)changeDeviceProperty:(ZCPropertyChangeBlock)propertyChange{
    AVCaptureDevice *captureDevice= [self.captureDeviceInput device];
    NSError *error;
    //注意改变设备属性前一定要首先调用lockForConfiguration:调用完之后使用unlockForConfiguration方法解锁
    if ([captureDevice lockForConfiguration:&error]) {
        //自动白平衡
        if ([captureDevice isWhiteBalanceModeSupported:AVCaptureWhiteBalanceModeContinuousAutoWhiteBalance]) {
            [captureDevice setWhiteBalanceMode:AVCaptureWhiteBalanceModeContinuousAutoWhiteBalance];
        }
        //自动根据环境条件开启闪光灯
        if ([captureDevice isFlashModeSupported:AVCaptureFlashModeAuto]) {
            [captureDevice setFlashMode:AVCaptureFlashModeAuto];
        }
        
        propertyChange(captureDevice);
        [captureDevice unlockForConfiguration];
    }else{
        NSLog(@"设置设备属性过程发生错误，错误信息：%@",error.localizedDescription);
    }
}

/**
 *  设置闪光灯模式
 *
 *  @param flashMode 闪光灯模式
 */
-(void)setFlashMode:(AVCaptureFlashMode )flashMode{
    [self changeDeviceProperty:^(AVCaptureDevice *captureDevice) {
        if ([captureDevice isFlashModeSupported:flashMode]) {
            [captureDevice setFlashMode:flashMode];
        }
    }];
}
/**
 *  设置聚焦模式
 *
 *  @param focusMode 聚焦模式
 */
-(void)setFocusMode:(AVCaptureFocusMode )focusMode{
    [self changeDeviceProperty:^(AVCaptureDevice *captureDevice) {
        if ([captureDevice isFocusModeSupported:focusMode]) {
            [captureDevice setFocusMode:focusMode];
        }
    }];
}
/**
 *  设置曝光模式
 *
 *  @param exposureMode 曝光模式
 */
-(void)setExposureMode:(AVCaptureExposureMode)exposureMode{
    [self changeDeviceProperty:^(AVCaptureDevice *captureDevice) {
        if ([captureDevice isExposureModeSupported:exposureMode]) {
            [captureDevice setExposureMode:exposureMode];
        }
    }];
}
/**
 *  设置聚焦点
 *
 *  @param point 聚焦点
 */
-(void)focusWithMode:(AVCaptureFocusMode)focusMode exposureMode:(AVCaptureExposureMode)exposureMode atPoint:(CGPoint)point{
    [self changeDeviceProperty:^(AVCaptureDevice *captureDevice) {
        //        if ([captureDevice isFocusPointOfInterestSupported]) {
        //            [captureDevice setFocusPointOfInterest:point];
        //        }
        //        if ([captureDevice isExposurePointOfInterestSupported]) {
        //            [captureDevice setExposurePointOfInterest:point];
        //        }
        if ([captureDevice isExposureModeSupported:exposureMode]) {
            [captureDevice setExposureMode:exposureMode];
        }
        if ([captureDevice isFocusModeSupported:focusMode]) {
            [captureDevice setFocusMode:focusMode];
        }
    }];
}

/**
 *  添加点按手势，点按时聚焦
 */
-(void)addGenstureRecognizer{
    UITapGestureRecognizer *tapGesture=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapScreen:)];
    self.bgView.userInteractionEnabled = YES;
    [self.bgView addGestureRecognizer:tapGesture];
}

-(void)tapScreen:(UITapGestureRecognizer *)tapGesture{
    if ([self.session isRunning]) {
        CGPoint point= [tapGesture locationInView:self.bgView];
        //将UI坐标转化为摄像头坐标
        CGPoint cameraPoint= [self.previewLayer captureDevicePointOfInterestForPoint:point];
        [self setFocusCursorWithPoint:point];
        [self focusWithMode:AVCaptureFocusModeContinuousAutoFocus exposureMode:AVCaptureExposureModeContinuousAutoExposure atPoint:cameraPoint];
    }
}

/**
 *  设置聚焦光标位置
 *
 *  @param point 光标位置
 */
-(void)setFocusCursorWithPoint:(CGPoint)point{
    if (!self.isFocus) {
        self.isFocus = YES;
        self.focusCursor.center=point;
        self.focusCursor.transform = CGAffineTransformMakeScale(1.25, 1.25);
        self.focusCursor.alpha = 1.0;
        [UIView animateWithDuration:0.5 animations:^{
            self.focusCursor.transform = CGAffineTransformIdentity;
        } completion:^(BOOL finished) {
            [self performSelector:@selector(onHiddenFocusCurSorAction) withObject:nil afterDelay:0.5];
        }];
    }
}

- (void)onHiddenFocusCurSorAction {
    self.focusCursor.alpha=0;
    self.isFocus = NO;
}

//拍摄完成时调用
- (void)changeLayout {
    self.imgRecord.hidden = YES;
    self.btnCamera.hidden = YES;
    self.btnAfresh.hidden = NO;
    self.btnEnsure.hidden = NO;
    self.progressView.hidden = YES;
    self.btnBack.hidden = YES;
    if (self.isVideo) {
        [self.progressView setProgress:0];
    }
    
    [UIView animateWithDuration:0.25 animations:^{
        [self.view layoutIfNeeded];
    }];
    
    self.lastBackgroundTaskIdentifier = self.backgroundTaskIdentifier;
    self.backgroundTaskIdentifier = UIBackgroundTaskInvalid;
    [self.session stopRunning];
}


//重新拍摄时调用
- (void)recoverLayout {
    if (self.isVideo) {
        self.isVideo = NO;
        [self.player stopPlayer];
        self.player.hidden = YES;
    }
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self.session startRunning];
    });
        
    if (!self.takeImageView.hidden) {
        self.takeImageView.hidden = YES;
    }
    //    self.saveVideoUrl = nil;
    self.imgRecord.hidden = NO;
    self.btnCamera.hidden = NO;
    self.btnAfresh.hidden = YES;
    self.btnEnsure.hidden = YES;
    self.btnBack.hidden = NO;
    [UIView animateWithDuration:0.25 animations:^{
        [self.view layoutIfNeeded];
    }];
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
