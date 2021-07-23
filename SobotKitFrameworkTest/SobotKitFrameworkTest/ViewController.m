//
//  ViewController.m
//  SobotKitFrameworkTest
//
//  Created by zhangxy on 15/11/21.
//  Copyright © 2015年 zhichi. All rights reserved.
//

#import "ViewController.h"
#import <SobotKit/SobotKit.h>
#import "EntityConvertUtils.h"
#import "ZCProductView.h"
#import "ZCGuideData.h"

@interface ViewController ()<ZCChatControllerDelegate>{
    UIView *menuView;
    int     _type ;
    UISwitch * _imagePickerSwitch;
    UIColor * _selectedColor;
    int     _aidTurn;
    NSString *titleType;
    BOOL    isPlatformUnion;
}

@property (nonatomic,strong) UIScrollView * scrollView; // 背景

@property (nonatomic,strong) UILabel * titleLab;//

@property (nonatomic,strong) UILabel * detailLab;

@property (nonatomic,strong) UIImageView * bgImg;// 背景图





@end

@implementation ViewController


#pragma mark - lifeCycle
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.tabBarController.tabBar.hidden = NO;
    self.navigationController.navigationBarHidden = NO;
    [self.navigationController.navigationBar setBarTintColor:[UIColor whiteColor]];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = UIColorFromRGB(0xEFF3FA);
    [self setUpUI];
    [self setTitleView];
    
    NSLog(@"SDK:%@",[ZCSobotApi getVersion]);
    
//    WSLSuspendingView * suspendingView = [WSLSuspendingView sharedSuspendingView];
//
//    WSLFPS * fps = [WSLFPS sharedFPSIndicator];
//    [fps startMonitoring];
//    fps.FPSBlock = ^(float fps) {
//       suspendingView.fpsLabel.text = [NSString stringWithFormat:@"FPS = %.2f",fps];
//        NSLog(@"FPS = %@",suspendingView.fpsLabel.text);
//    };
    // 获取系统当前支持的语言代号：
//    NSArray *localeIdentifiers = [NSLocale availableLocaleIdentifiers];
//    NSLog(@"%@",localeIdentifiers);
}

-(IBAction)buttonClick:(UIButton *)sender{
    self.extendedLayoutIncludesOpaqueBars = true; //Push 黑边和这个参数有关系
    
    [ZCSobotApi setShowDebug:YES];

    if(![[ZCLibClient getZCLibClient] getInitState]){
        [[ZCGuideData getZCGuideData] showAlertTips:@"请设置appkey后初始化,功能设置->基础参数配置" vc:self];
        
        [ZCSobotApi synchronizeLanguage:@"ms_lproj" write:NO result:^(NSString * _Nonnull message, int code) {
            NSLog(@"%@",message);
        }];
        return;
    }
    [self initSDK];
}


#pragma mark - 开发入口
- (void)initSDK{
    [ZCLibClient getZCLibClient].receivedBlock=^(id obj,int unRead,NSDictionary *object){
        NSLog(@"******************************");
        NSLog(@"******************************未读消息数量：\n%d,%@",unRead,obj);
        NSLog(@"******************************");
    };
    
//    [ZCLibClient getZCLibClient].serverConnectBlock
    [[ZCLibClient getZCLibClient] setServerConnectBlock:^(id message, ZCServerConnectStatus status, NSDictionary *object) {
        
        
    }];
    
    
    
    [ZCSobotApi setMessageLinkClick:^BOOL(NSString * _Nonnull linkUrl) {
        if ([linkUrl containsString:@"sobot://sendOrderMsg"]) {
            [ZCSobotApi sendOrderGoodsInfo:[ZCUICore getUICore].kitInfo.orderGoodsInfo resultBlock:^(NSString * _Nonnull msg, int code) {
                
            }];
            return YES;
        }
        if ([linkUrl containsString:@"sobot://sendLocation"]) {
            // 发送位置信息
            [ZCSobotApi sendLocation:@{
                @"lat":@"40.001693",
                @"lng":@"116.353276",
                @"localLabel":@"北京市海淀区学清路38号金码大厦",
                @"localName":@"云景四季餐厅",
                @"file":@""} resultBlock:^(NSString * _Nonnull msg, int code) {
                
            }];
            return YES;
        }
        
        if([linkUrl containsString:@"sobot://sendProductInfo"]){
            
            [ZCSobotApi sendProductInfo:[ZCUICore getUICore].kitInfo.productInfo resultBlock:^(NSString * _Nonnull msg, int code) {
                
            }];
            return YES;
        }
        
        if([linkUrl hasPrefix:@"www.open.com"]){
            [ZCSobotApi openZCChat:[ZCKitInfo new] with:self pageBlock:^(id  _Nonnull object, ZCPageBlockType type) {
                
            }];
            return YES;
        }
        
        return NO;
    }];
    
//
//    if(ISDebug == 1){
////        initInfo.user_nick = @"我是Debug Nick";
//        [[ZCLibClient getZCLibClient] setIsDebugMode:YES];
//    }else{
//        [[ZCLibClient getZCLibClient] setIsDebugMode:NO];
////        initInfo.user_nick = @"我是nick";
//    }
    
    
    // 进入聊天页面
    [ZCSobotApi openZCServiceCenter:[ZCGuideData getZCGuideData].kitInfo with:self onItemClick:^(ZCUIBaseController *object) {
        
        [ZCSobotApi openZCChat:[ZCGuideData getZCGuideData].kitInfo with:object pageBlock:^(id  _Nonnull object, ZCPageBlockType type) {
            if([object isKindOfClass:[ZCChatView class]] && type == ZCPageBlockLoadFinish){
                UITextView *tv = [((ZCChatView *)object) getChatTextView];
                if(tv){
                    //                    tv.textColor  = UIColor.greenColor;
                }
            }
        }];
        
    }];
}




#pragma mark - 布局
-(void)setTitleView{
    
    UIImageView * titleimgView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 72, 23)];
    titleimgView.image = [UIImage imageNamed:@"titleImg"];
    titleimgView.contentMode = UIViewContentModeScaleAspectFit;
    self.navigationItem.titleView = titleimgView;
    
    
    UIButton * rightBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    rightBtn.frame = CGRectMake(ScreenWidth - 90, NavBarHeight - 40, 80, 40);
    rightBtn.titleLabel.font = [UIFont systemFontOfSize:14];
    [rightBtn setTitle:@"联系我们" forState:UIControlStateNormal];
    rightBtn.titleEdgeInsets = UIEdgeInsetsMake(5, 15, 5, -5);
    [rightBtn setTitleColor:UIColorFromRGB(0x0DAEAF) forState:UIControlStateNormal];
    [rightBtn setTitleColor:UIColorFromRGB(0x0DAEAF) forState:UIControlStateHighlighted];
//    [rightBtn setTitleColor:UIColorFromRGB(0xF5F6F7) forState:0];
    [rightBtn addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem * rightItem = [[UIBarButtonItem alloc]initWithCustomView:rightBtn];
 
    self.navigationItem.rightBarButtonItem = rightItem;
    
}

-(void)setUpUI{
//    CGFloat XH = 0;
//    if (ZC_iPhoneX) {
//        XH = 34;
//    }
    
    CGFloat itemW = self.view.frame.size.width;

    self.scrollView = [[UIScrollView alloc]initWithFrame:CGRectMake(0, NavBarHeight, itemW, ScreenHeight - NavBarHeight - 48 - (ZC_iPhoneX? 34 :0))];
    self.scrollView.backgroundColor = [UIColor clearColor];
    self.scrollView.scrollEnabled = YES;
//    self.scrollView.alwaysBounceVertical = YES;
    self.scrollView.alwaysBounceHorizontal = NO;
//    self.scrollView.showsVerticalScrollIndicator = NO;
    self.scrollView.pagingEnabled = NO;
    self.scrollView.bounces = NO;
    self.scrollView.userInteractionEnabled = YES;
    
    [self.view addSubview:self.scrollView];
    
    self.bgImg  = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, itemW, 20)];
    [self.bgImg setBackgroundColor:[UIColor clearColor]];
    self.bgImg.image = [UIImage imageNamed:@"productBgImg"];
    [self.scrollView addSubview:self.bgImg];
    
    self.titleLab = [[UILabel alloc]initWithFrame:CGRectMake(ZCNumber(20), ZCNumber(27), itemW - 40, 33)];
    self.titleLab.textAlignment = NSTextAlignmentLeft;
    self.titleLab.font = [UIFont fontWithName:@"Arial Rounded MT Bold" size:24];
    self.titleLab.text = @"智齿客服";
    [self.bgImg addSubview:self.titleLab];


    self.detailLab = [[UILabel alloc]initWithFrame:CGRectMake(ZCNumber(20), ZCNumber(CGRectGetMaxY(self.titleLab.frame) + 20), ZCNumber(itemW - 40), 40)];
    self.detailLab.numberOfLines = 0;
    self.detailLab.textAlignment = NSTextAlignmentLeft;
    self.detailLab.textColor = UIColorFromRGB(0x3D4966);
    self.detailLab.font = [UIFont systemFontOfSize:14];
    NSMutableAttributedString * attributedString = [[NSMutableAttributedString alloc]initWithString:@"智齿客服是以人工智能整合云呼叫中心、机器人客服、人工在线客服、工单系统的全客服平台"];
    NSMutableParagraphStyle * paragraphstyle = [[NSMutableParagraphStyle alloc]init];
    [attributedString addAttribute:NSParagraphStyleAttributeName value:paragraphstyle range:NSMakeRange(0, [@"智齿客服是以人工智能整合云呼叫中心、机器人客服、人工在线客服、工单系统的全客服平台" length])];
    [self.detailLab setAttributedText:attributedString];
    [self.bgImg addSubview:self.detailLab];

    CGRect bgimgF = self.bgImg.frame;
    bgimgF.size.height = CGRectGetMaxY(self.detailLab.frame) + ZCNumber(36);
    self.bgImg.frame= bgimgF;
    
    
    // 智能机器人。。。。
    
    NSMutableArray * arr = [NSMutableArray arrayWithCapacity:0];
    
    NSDictionary * dict1 = @{@"Img":@"home_Robot",
                            @"title":@"智能机器人",
                            @"detail":@"金牌客服永不离线，节省85%以上人力成本",
                            @"tag":@"0",
                            };
    NSDictionary * dict2 = @{@"Img":@"home_chat",
                             @"title":@"人工在线客服",
                             @"detail":@"把握每一次访问。专注线上转化，提升业绩",
                             @"tag":@"1",
                             };
    NSDictionary * dict3 = @{@"Img":@"home_call",
                             @"title":@"云呼叫中心",
                             @"detail":@"稳定强大的云呼叫中心，价格更低，效果更佳",
                             @"tag":@"2",
                             };
    NSDictionary * dict4 = @{@"Img":@"home_order",
                             @"title":@"工单系统",
                             @"detail":@"推动全公司协同处理客户问题，提升解决率",
                             @"tag":@"3",
                             };
    
    [arr addObject:dict1];
    [arr addObject:dict2];
    [arr addObject:dict3];
    [arr addObject:dict4];
    
    CGFloat itemH = CGRectGetMaxY(self.bgImg.frame) ;
    for (int i = 0; i<arr.count; i++) {
        ZCProductView *_productView =[[ZCProductView alloc]initWithFrame:CGRectMake(ZCNumber(20), itemH, itemW - ZCNumber(40), 140) WithDict:arr[i] WithSuperView:self.scrollView];
        itemH = itemH + 150;
    }
    
    self.scrollView.contentSize = CGSizeMake(itemW, itemH + 20);

}

@end
