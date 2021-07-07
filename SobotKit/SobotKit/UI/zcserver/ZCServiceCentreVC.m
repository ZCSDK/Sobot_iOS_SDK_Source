//
//  ZCServiceCentreVC.m
//  SobotKit
//
//  Created by lizhihui on 2019/3/27.
//  Copyright © 2019 zhichi. All rights reserved.
//

#import "ZCServiceCentreVC.h"
#import "ZCUICore.h"
#import "ZCUIImageTools.h"
#import "ZCLibGlobalDefine.h"
#import "ZCUIColorsDefine.h"
#import "ZCLibServer.h"
#import "ZCButton.h"
#import "ZCUIImageView.h"
#import "ZCServiceListVC.h"
#import "ZCSCListModel.h"
#import "ZCToolsCore.h"



typedef NS_ENUM(NSInteger,ZCLineType) {
    LineLayerBorder = 0,//边框线
    LineHorizontal  = 1,//竖线
    LineVertical    = 2,//横线
};
// 理想线宽
#define LINE_WIDTH                  1
// 实际应该显示的线宽
#define SINGLE_LINE_WIDTH           floor((LINE_WIDTH / [UIScreen mainScreen].scale)*100) / 100

//偏移的宽度
#define SINGLE_LINE_ADJUST_OFFSET   floor(((LINE_WIDTH / [UIScreen mainScreen].scale) / 2)*100) / 100

typedef BOOL(^LinkClickBlock)(NSString *linkUrl);
typedef void (^PageLoadBlock)(id object,ZCPageBlockType type);

@interface ZCServiceCentreVC (){
    // 屏幕宽高
//    CGFloat                     viewWidth;
//    CGFloat                     viewHeigth;
    
    UIScrollView     * scrollView;
    
    UIButton      *serviceBtn;// 客服入口
    
    NSMutableArray   *_listArray;
    
    UIView *serviceBtnBgView;
}

//当页面的list数据为空时，给它一个带提示的占位图。
@property(nonatomic,strong) UIView *placeholderView;


@property (nonatomic,assign) id<ZCChatControllerDelegate> delegate;

@end

@implementation ZCServiceCentreVC


-(void)buttonClick:(UIButton *)sender{
    if (sender.tag == BUTTON_BACK) {
        if([ZCUICore getUICore].ZCViewControllerCloseBlock != nil){
            [ZCUICore getUICore].ZCViewControllerCloseBlock(self,ZC_CloseHelpCenter);
        }
        
        if (self.navigationController && self.isPush) {
            [self.navigationController popViewControllerAnimated:NO];
        }else{
            [self dismissViewControllerAnimated:NO completion:nil];
        }
    }
}


- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    
    self.navigationController.navigationBarHidden = NO;
    if ([ZCUICore getUICore].kitInfo.navcBarHidden) {
        self.navigationController.navigationBarHidden = YES;
        [self.titleLabel setText:ZCSTLocalString(@"客户服务中心")];
    }else if (![ZCUICore getUICore].kitInfo.navcBarHidden && self.navigationController){
        [self setNavigationBarStyle];
        self.navigationController.navigationBar.translucent = NO;
        self.title = ZCSTLocalString(@"客户服务中心");
        [self.navigationController.navigationBar setTitleTextAttributes:@{NSFontAttributeName:[ZCUITools zcgetscTopTextFont],NSForegroundColorAttributeName:[ZCUITools zcgetscTopTextColor]}];
    }
    
    if(scrollView){
        [self viewDidLayoutSubviews];
    }
        
}


-(void)viewDidLayoutSubviews{
    [super viewDidLayoutSubviews];
    CGFloat viewWidth =  self.view.frame.size.width;
    CGFloat viewHeigth = self.view.frame.size.height;
        
    CGFloat Y = 0;
    if (self.navigationController.navigationBarHidden) {
        Y = NavBarHeight;
    }else{
        if(self.navigationController.navigationBar.translucent && viewHeigth == ScreenHeight){
            viewHeigth = ScreenHeight - NavBarHeight;
        }
    }
    
    CGFloat scrollHeight = viewHeigth - ZCNumber(59) -(ZC_iPhoneX? 20:0) - Y;
    
    int direction = [[ZCToolsCore getToolsCore] getCurScreenDirection];
    CGFloat spaceX = 0;
    CGFloat LW = viewWidth;
    // iphoneX 横屏需要单独处理
    if(direction > 0){
        LW = viewWidth - XBottomBarHeight;
    }
    if(direction == 2){
        spaceX = XBottomBarHeight;
    }
    [scrollView setFrame:CGRectMake(spaceX, Y, LW, scrollHeight)];
    
    
    serviceBtnBgView.frame = CGRectMake(0, viewHeigth - 80, viewWidth, ZCNumber(80));
    
    if (_listArray.count > 0) {
        [self removePlaceholderView];
        [scrollView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
        [self layoutItemWith:_listArray];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];

    self.view.backgroundColor = UIColorFromThemeColor(ZCBgLightGrayDarkColor);
    
    
     self.automaticallyAdjustsScrollViewInsets = NO;
     if ([ZCUICore getUICore].kitInfo.navcBarHidden) {
         self.navigationController.navigationBarHidden = YES;
         self.navigationController.navigationBar.translucent = NO;
         
         [self createTitleView];
         self.moreButton.hidden = YES;
     }else{
         self.navigationController.navigationBarHidden = NO;
     }
     self.navigationController.navigationBar.translucent = NO;

    
    
    [self createSubviews];
    
    
    [self loadData];
    
    zcTestLocalString(@"关闭");
}

#pragma mark -- 添加子控件
-(void)createSubviews{
    CGFloat viewHeigth = [self getCurViewHeight];
    CGFloat viewWidth = [self getCurViewWidth];
    CGFloat Y = 0;
    if (self.navigationController.navigationBarHidden) {
        Y = NavBarHeight;
    }else{
        if(self.navigationController.navigationBar.translucent && viewHeigth == ScreenHeight){
            viewHeigth = ScreenHeight - NavBarHeight;
        }
    }
    scrollView = [[UIScrollView alloc]initWithFrame:CGRectMake(0, Y, viewWidth, viewHeigth - ZCNumber(59) -(ZC_iPhoneX? 20:0) - Y)];
//    scrollView.scrollEnabled = YES;
    scrollView.alwaysBounceVertical = YES;
    scrollView.alwaysBounceHorizontal = NO;
    scrollView.bounces = NO;
    [scrollView setAutoresizingMask:UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleTopMargin];
    [scrollView setAutoresizesSubviews:YES];
    [self.view addSubview:scrollView];
    // 关闭安全区域，否则UITableViewCell横屏时会是全屏的宽
//    NSString *version = [UIDevice currentDevice].systemVersion;
//    if (version.doubleValue >= 11.0) {
//        [scrollView setInsetsLayoutMarginsFromSafeArea:NO];
//    }
    
    
    serviceBtnBgView = [[UIView alloc]initWithFrame:CGRectMake(0, viewHeigth - 80, viewWidth, ZCNumber(80))];
    
    serviceBtnBgView.backgroundColor = UIColorFromThemeColor(ZCBgLightGrayDarkColor);
    [serviceBtnBgView setAutoresizingMask:UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleTopMargin];
    [self.view addSubview:serviceBtnBgView];
    
    serviceBtn = [self createHelpCenterButtons:10 sView:serviceBtnBgView];
    serviceBtn.titleLabel.adjustsFontSizeToFitWidth = YES;
    
    
}

// borderColor必须这么设置才起效
- (void)traitCollectionDidChange:(UITraitCollection *)previousTraitCollection{
    [super traitCollectionDidChange:previousTraitCollection];
    
    serviceBtn.layer.borderColor = UIColorFromThemeColor(ZCBgLineColor).CGColor;
}


#pragma mark -- 加载数据
-(void)loadData{
    [self createPlaceholderView:ZCSTLocalString(@"暂无帮助内容") message:ZCSTLocalString(@"可点击下方按钮咨询人工客服") image:nil withView:self.view action:nil];
    _listArray = [NSMutableArray arrayWithCapacity:0];
    
    __weak ZCServiceCentreVC *weakself = self;
    [[ZCLibServer getLibServer] getCategoryWith:[ZCLibClient getZCLibClient].libInitInfo.app_key start:^{
        
    } success:^(NSDictionary *dict, ZCNetWorkCode sendCode) {
        
        @try{
            if (dict) {
                NSArray * dataArr = dict[@"data"];
                if ([dataArr isKindOfClass:[NSArray class]] && dataArr.count > 0) {
                   
                    for (NSDictionary *item in dataArr) {
                        ZCSCListModel * listModel = [[ZCSCListModel alloc]initWithMyDict:item];
                        [_listArray addObject:listModel];
                    }
                    
                    if (_listArray.count > 0) {
                        [weakself removePlaceholderView];
                        [weakself layoutItemWith:_listArray];
                    }
                    
                }
            }
            
        } @catch (NSException *exception) {
            
        } @finally {
            
        }
        
    } failed:^(NSString *errorMessage, ZCNetWorkCode errorCode) {
        
    }];
    
}

-(void)layoutItemWith:(NSMutableArray *)array{
    CGFloat bw=scrollView.frame.size.width;
    CGFloat x= 12;
    CGFloat y= 11;
    CGFloat itemH = 76;
    CGFloat itemW = (bw-0.25 - 30)/2.0f;
    
    int index = _listArray.count%2==0?round(_listArray.count/2):round(_listArray.count/2)+1;
    for (int i =0; i<_listArray.count; i++) {
        UIView * itemView = [self addItemView:_listArray[i] withX:x withY:y withW:itemW withH:itemH Tag:i];
        itemView.layer.borderColor = UIColorFromThemeColor(ZCBgLineColor).CGColor;
        itemView.layer.borderWidth = 1.0f;
        itemView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin |UIViewAutoresizingFlexibleWidth;
        itemView.autoresizesSubviews = YES;
        [itemView setBackgroundColor:UIColorFromThemeColor(ZCBgSystemWhiteLightGrayColor)];
        itemView.userInteractionEnabled = YES;
        itemView.tag = i;
        if(i%2==1){
            // 单数添加 右边的线条和下边的线条
//            UIView * rline = [[UIView alloc]initWithFrame:CGRectMake(CGRectGetMaxX(itemView.frame), y, 0.5, itemH)];
//            rline.backgroundColor = UIColorFromRGB(0xE3E3E3); // CGRectMake(x, CGRectGetMaxY(itemView.frame), itemW+0.25, 0.5)
//            UIView * bLine = [[UIView alloc]initWithFrame:CGRectMake(x, CGRectGetMaxY(itemView.frame), itemW+0.25, 0.5)];
//            bLine.backgroundColor = UIColorFromRGB(0xE3E3E3);
////            [scrollView addSubview:rline];
//            [scrollView addSubview:bLine];
            
//            [self setLineOffset:LineVertical withView:itemView];
            
            x = 12;
            y = y + itemH + 6;
            
            
        }else if(i%2==0){// CGRectMake(x, CGRectGetMaxY(itemView.frame), itemW+0.25, 0.25)
//            UIView * bLine = [[UIView alloc]initWithFrame:CGRectMake(x, CGRectGetMaxY(itemView.frame), itemW+0.25, 0.5)];
//            bLine.backgroundColor = UIColorFromRGB(0xE3E3E3);
//            [scrollView addSubview:bLine];
////            if (i == 0) {
//                UIView * rline = [[UIView alloc]initWithFrame:CGRectMake(CGRectGetMaxX(itemView.frame) + 6, y, 0.5, itemH)];
//                rline.backgroundColor = UIColorFromRGB(0xE3E3E3);
//                [scrollView addSubview:rline];
////            }
            x = itemW + 12 + 6;
           
        }
        [scrollView addSubview:itemView];
    }
    [scrollView setContentSize:CGSizeMake(bw, index*itemH + index*6 + 10)];
    [scrollView setContentInset:UIEdgeInsetsZero];

}
-(UIImage *)grayImage:(UIImage *) image{
    if([ZCUITools getZCThemeStyle] == ZCThemeStyle_Default){
        return image;
    }
    UIGraphicsBeginImageContextWithOptions(image.size, NO, [UIScreen mainScreen].scale);
    
    [image drawInRect:CGRectMake(0, 0, image.size.width, image.size.height)
                   blendMode:kCGBlendModeDarken
                       alpha:1.0];
    UIImage *highlighted = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return highlighted;
}


#pragma mark -- 设置头像灰度
- (UIImage*)grayImage1:(UIImage*)image{
    if([ZCUITools getZCThemeStyle] == ZCThemeStyle_Default){
        return image;
    }
    
    int width = image.size.width;
    int height = image.size.height;
    //第一步:创建颜色空间(说白了就是 开辟一块颜色内存空间)
    //图片灰度处理(创建灰度空间)
    
    CGColorSpaceRef colorRef = CGColorSpaceCreateDeviceGray();
    //第二步:颜色空间的上下文(保存图像数据信息)
    //参数1:内存大小(指向这块内存区域的地址)(内存地址)
    //参数2:图片宽
    //参数3:图片高
    //参数4:像素位数(颜色空间,例如:32位像素格式和RGB颜色空间,8位)
    //参数5:图片每一行占用的内存比特数
    //参数6:颜色空间
    //参数7:图片是否包含A通道(ARGB通道)
    CGContextRef context = CGBitmapContextCreate(nil, width, height, 8, 0, colorRef, kCGImageAlphaNone);
    
    //释放内存
    CGColorSpaceRelease(colorRef);
    if (context == nil) {
        return nil;
    }
    //第三步:渲染图片(绘制图片)
    //参数1:上下文
    //参数2:渲染区域
    //参数3:源文件(原图片)(说白了现在是一个C/C++的内存区域)
    CGContextDrawImage(context, CGRectMake(0, 0, width, height), image.CGImage);
    
    //第四步:将绘制颜色空间转成CGImage(转成可识别图片类型)
    CGImageRef grayImageRef = CGBitmapContextCreateImage(context);
    
    //第五步:将C/C++ 的图片CGImage转成面向对象的UIImage(转成iOS程序认识的图片类型)
    UIImage* dstImage = [UIImage imageWithCGImage:grayImageRef];

    //释放内存
    CGContextRelease(context);
    CGImageRelease(grayImageRef);
    return dstImage;
}

-(UIView *)addItemView:(ZCSCListModel *) model withX:(CGFloat )x withY:(CGFloat) y withW:(CGFloat) w withH:(CGFloat) h Tag:(int)i{
    UIView *itemView = [[UIView alloc] initWithFrame:CGRectMake(x, y, w,h)];
    [itemView setFrame:CGRectMake(x, y, w, h)];
    [itemView setBackgroundColor:UIColorFromThemeColor(ZCKeepWhiteColor)];
    
    ZCUIImageView *img = [[ZCUIImageView alloc]initWithFrame:CGRectMake(14, 18, 40, 40)];
    [img loadWithURL:[NSURL URLWithString:zcUrlEncodedString(model.categoryUrl)] placeholer:nil showActivityIndicatorView:NO completionBlock:^(UIImage *image, NSURL *url, NSError *error) {
        if(image){
            dispatch_async(dispatch_get_main_queue(), ^{
                img.image = [self grayImage:image];
            });
        }
    }];
    img.layer.cornerRadius = 4.0f;
    img.layer.masksToBounds = YES;
    [img setBackgroundColor:UIColorFromThemeColor(ZCBgLeftChatColor)];
    [itemView addSubview:img];
    
    UILabel *titlelab = [[UILabel alloc]initWithFrame:CGRectMake(CGRectGetMaxX(img.frame) + ZCNumber(10), 20, w - 60, 20)];
    titlelab.numberOfLines = 1;
    [titlelab setTextAlignment:NSTextAlignmentLeft];
    [titlelab setTextColor:UIColorFromThemeColor(ZCTextSubColor)];
    [titlelab setText:zcLibConvertToString(model.categoryName)];
    [titlelab setFont:ZCUIFontBold14];
    [itemView addSubview:titlelab];
    [titlelab sizeToFit];
    
    
    UILabel *detailLab = [[UILabel alloc] initWithFrame:CGRectZero];
    detailLab.frame = CGRectMake(CGRectGetMaxX(img.frame) +ZCNumber(10), CGRectGetMaxY(titlelab.frame) +ZCNumber(2), w - 60, 40);
    [detailLab setTextAlignment:NSTextAlignmentLeft];
    detailLab.numberOfLines = 2;
    [detailLab setTextColor:UIColorFromThemeColor(ZCTextSubColor)];
    [detailLab setText:zcLibConvertToString(model.categoryDetail)];
    [detailLab setFont:ZCUIFont12];
    [itemView addSubview:detailLab];
    CGSize s = [detailLab sizeThatFits:CGSizeMake(w - 70, 40)];
    
    [titlelab setFrame:CGRectMake(CGRectGetMaxX(img.frame) + ZCNumber(6), (h - 20 - s.height - 2)/2, w - 70, 20)];
    detailLab.frame = CGRectMake(CGRectGetMaxX(img.frame) +ZCNumber(6), CGRectGetMaxY(titlelab.frame) +ZCNumber(2), w - 70, s.height);
    
    
    
    UIButton * btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.tag = i;
    btn.frame = CGRectMake(0, 0, CGRectGetWidth(itemView.frame),CGRectGetHeight(itemView.frame));
    btn.backgroundColor = [UIColor clearColor];
    [btn addTarget:self action:@selector(tapItemAction:) forControlEvents:UIControlEventTouchUpInside];
    [itemView addSubview:btn];

    
    return itemView;
}


-(void)tapItemAction:(UIButton *)sender{
 
    ZCServiceListVC * listVC = [[ZCServiceListVC alloc]init];
    int tag = (int)sender.tag;
    ZCSCListModel * model= _listArray[tag];
    listVC.titleName = zcLibConvertToString(model.categoryName);
    listVC.appId = zcLibConvertToString(model.appId);
    listVC.categoryId = model.categoryId;
    [listVC setOpenZCSDKTypeBlock:self.OpenZCSDKTypeBlock];
    if (self.navigationController) {
        [self.navigationController pushViewController:listVC animated:NO];
    }else{
        [self presentViewController:listVC animated:NO completion:nil];
    }
    
}

-(void)openZCSDK:(ZCButton *)sender{
    [super openZCSDK:sender];
    if(sender.tag == 1){
        if (self.OpenZCSDKTypeBlock) {
            self.OpenZCSDKTypeBlock(self);
        }else{
            [ZCSobot startZCChatVC:_kitInfo with:self target:nil pageBlock:nil messageLinkClick:nil];
        }
    }
}


-(id)initWithInitInfo:(ZCKitInfo *)info{
    self=[super init];
    if(self){
        if(info !=nil && !zcLibIs_null([ZCLibClient getZCLibClient].libInitInfo) && !zcLibIs_null([ZCLibClient getZCLibClient].libInitInfo.app_key)){
            //            self.zckitInfo=info;
        }else{
            //            self.zckitInfo=[ZCKitInfo new];
        }
        
        [ZCUICore getUICore].kitInfo = info;
        
//        self.delegate = delegate;
//        self.linkBlock = messagelinkBlock;
//        self.pageBlock = pageClick;
    }
    return self;
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
        [lblTitle setFont:ZCUIFont16];
        [lblTitle setTextColor:UIColorFromRGB(TextNetworkTipColor)];
        [lblTitle setTextAlignment:NSTextAlignmentCenter];
        [lblTitle setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
        [lblTitle setNumberOfLines:0];
        [lblTitle setBackgroundColor:[UIColor clearColor]];
        [_placeholderView addSubview:lblTitle];
        y=y+height+5;
    }
    
    if(message){
        UILabel *lblTitle=[[UILabel alloc] initWithFrame:CGRectMake(0, y, pf.size.width, 40)];
        [lblTitle setText:message];
        [lblTitle setFont:ZCUIFont14];
        [lblTitle setTextColor:UIColorFromThemeColor(ZCTextMainColor)];
        [lblTitle setTextAlignment:NSTextAlignmentCenter];
        [lblTitle setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
        [lblTitle setAutoresizesSubviews:YES];
        lblTitle.numberOfLines = 0;
        [lblTitle setBackgroundColor:[UIColor clearColor]];
        [_placeholderView addSubview:lblTitle];
        y=y+45;
    }
    
    pf.size.height= y;
    
    [_placeholderView setFrame:pf];
    [_placeholderView setCenter:CGPointMake(superView.center.x, superView.bounds.size.height/2-100)];
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


#pragma mark -- 设置分割线条 反截距
/**
 *  设置线条宽度
 *
 *  @param type 类型，横线、竖线、边框线
 *  @param view 要设置的view
 */
-(void)setLineOffset:(ZCLineType) type withView:(UIView *) view{
    CGFloat pixelAdjustOffset = 0;
    if ((int)(LINE_WIDTH * [UIScreen mainScreen].scale + 1) % 2 == 0) {
        pixelAdjustOffset = SINGLE_LINE_ADJUST_OFFSET;
    }
    
    CGRect rect = view.frame;
    
    if(type==LineHorizontal){
        rect.origin.y = rect.origin.y - pixelAdjustOffset;
        rect.size.height = SINGLE_LINE_WIDTH;
    }else if(type==LineVertical){
        rect.origin.x = rect.origin.x - pixelAdjustOffset;
        rect.size.width = SINGLE_LINE_WIDTH;
    }else{
        rect.origin.x = rect.origin.x - pixelAdjustOffset;
        rect.origin.y = rect.origin.y - pixelAdjustOffset;
        
        view.layer.borderWidth = SINGLE_LINE_WIDTH;
    }
    
    
    if(rect.size.height<0.5){
        rect.size.height = 0.5;
    }
    if(rect.size.width<0.5){
        rect.size.width = 0.5;
    }
    
    view.frame = rect;
}



-(void)dealloc{
//        NSLog(@" 客户帮助中心 释放了");
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
