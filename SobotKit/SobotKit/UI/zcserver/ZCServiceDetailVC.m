//
//  ZCServiceDetailVC.m
//  SobotKit
//
//  Created by lizhihui on 2019/4/2.
//  Copyright © 2019 zhichi. All rights reserved.
//

#import "ZCServiceDetailVC.h"
#import "ZCUICore.h"
#import "ZCUIImageTools.h"
#import "ZCUIImageTools.h"
#import "ZCLibGlobalDefine.h"
#import "ZCUIColorsDefine.h"
#import "ZCLibServer.h"
#import "ZCSCListModel.h"
#import "ZCButton.h"
#import "ZCServiceCentreVC.h"
#import "ZCUIToastTools.h"
#import <WebKit/WebKit.h>

#import "ZCUICore.h"

@interface ZCServiceDetailVC ()<WKNavigationDelegate>{
    // 屏幕宽高
//    CGFloat                     viewWidth;
//    CGFloat                     viewHeigth;
    
    UIButton    *serviceBtn;
    WKWebView   * webView;
    
    NSString * htmlStr;
    
    UILabel * titleLab;
}

@end

@implementation ZCServiceDetailVC


- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    if ([ZCUICore getUICore].kitInfo.navcBarHidden) {
        self.navigationController.navigationBarHidden = YES;
    }else if(![ZCUICore getUICore].kitInfo.navcBarHidden && self.navigationController){
        [self setNavigationBarStyle];
        self.title = ZCSTLocalString(@"问题详情");
        [self.navigationController.navigationBar setTitleTextAttributes:@{NSFontAttributeName:[ZCUITools zcgetscTopTextFont],NSForegroundColorAttributeName:[ZCUITools zcgetscTopTextColor]}];
    }
}

-(void)buttonClick:(UIButton *)sender{
    if (sender.tag == BUTTON_BACK) {
        if (self.navigationController) {
            [self.navigationController popViewControllerAnimated:NO];
        }else{
            [self dismissViewControllerAnimated:NO completion:nil];
        }
    }
}


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
//    viewHeigth = self.view.frame.size.height;
//    viewWidth = self.view.frame.size.width;
    
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    if ([ZCUICore getUICore].kitInfo.navcBarHidden) {
        self.navigationController.navigationBarHidden = YES;
        self.navigationController.navigationBar.translucent = NO;
    }
    
    if(!self.navigationController.navigationBarHidden){
        [self setNavigationBarStyle];
        self.title = ZCSTLocalString(@"问题详情");
        [self.navigationController.navigationBar setTitleTextAttributes:@{NSFontAttributeName:[ZCUITools zcgetscTopTextFont],NSForegroundColorAttributeName:[ZCUITools zcgetscTopTextColor]}];
    }else{
        [self createTitleViewWith:1];
        self.titleLabel.text = ZCSTLocalString(@"问题详情");
        self.titleLabel.font = ZCUIFont17;
        [self.moreButton setImage:nil forState:UIControlStateNormal];
        [self.moreButton setImage:nil forState:UIControlStateHighlighted];
        
    }
    
    
    [self createSubviews];
    
    [self loadData];
    
    
}

-(void)createSubviews{
    
    CGFloat Y = 0;
    if (self.navigationController.navigationBarHidden) {
        Y = NavBarHeight;
    }
    
    titleLab = [[UILabel alloc]initWithFrame:CGRectMake(ZCNumber(10), Y + 20, ScreenWidth -ZCNumber(20), 20)];
    titleLab.textColor = [ZCUITools zcgetscTopTextColor];
    titleLab.numberOfLines = 0;
    titleLab.font = ZCUIFont20;
    [self.view addSubview:titleLab];
    
    titleLab.text = sobotConvertToString(_questionTitle);
    [titleLab sizeToFit];
    
    //创建网页配置对象
    WKWebViewConfiguration *config = [[WKWebViewConfiguration alloc] init];
    // 创建设置对象
    WKPreferences *preference = [[WKPreferences alloc]init];
    // 设置字体大小(最小的字体大小)
    preference.minimumFontSize = 14;
    // 设置偏好设置对象
    config.preferences = preference;
    
    // 自适应屏幕宽度js
    NSString *jSString = @"var meta = document.createElement('meta'); meta.setAttribute('name', 'viewport'); meta.setAttribute('content', 'width=device-width'); document.getElementsByTagName('head')[0].appendChild(meta);";
    WKUserScript *wkUserScript = [[WKUserScript alloc] initWithSource:jSString injectionTime:WKUserScriptInjectionTimeAtDocumentEnd forMainFrameOnly:YES];
    [config.userContentController addUserScript:wkUserScript];
    
    
    webView = [[WKWebView alloc]initWithFrame:CGRectMake(0, CGRectGetMaxY(titleLab.frame) +ZCNumber(12), [self getCurViewWidth], [self getCurViewHeight] - ZCNumber(56) - CGRectGetMaxY(titleLab.frame) - 12 - XBottomBarHeight) configuration:config];
    [self.view addSubview:webView];
    //    webView.delegate = self;
    //    webView.scalesPageToFit = NO;
    webView.navigationDelegate = self;
    [webView setOpaque:NO];
    webView.backgroundColor = [ZCUITools zcgetLightGrayBackgroundColor];
    [webView setAutoresizingMask:UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight];
    [webView setAutoresizesSubviews:YES];
    self.view.backgroundColor = [ZCUITools zcgetLightGrayBackgroundColor];
    
    serviceBtn = [self createHelpCenterButtons:CGRectGetMaxY(webView.frame) sView:self.view];
    serviceBtn.titleLabel.adjustsFontSizeToFitWidth = YES;
}



-(void)loadData{
    [[ZCLibServer getLibServer] getHelpDocByDocIdWith:self.appId DocId:self.docId start:^{
        
    } success:^(NSDictionary *dict, ZCNetWorkCode sendCode) {
        @try{
            if (dict) {
                NSDictionary * dataDic = dict[@"data"];
                if ([dataDic isKindOfClass:[NSDictionary class]] && dataDic != nil) {
                    [webView loadHTMLString:sobotConvertToString(dict[@"data"][@"answerDesc"]) baseURL:nil];
//                    [webView loadHTMLString:sobotConvertToString(@"<a href=\"https://www.baidu.com\" >智齿</a>") baseURL:nil];
                    titleLab.text = sobotConvertToString(dict[@"data"][@"questionTitle"]);
                }
            }
            
        } @catch (NSException *exception) {
            
        } @finally {
            
        }
    } failed:^(NSString *errorMessage, ZCNetWorkCode errorCode) {
        
    }];
}


-(void)openZCSDK:(UIButton *)sender{
    
    if (self.OpenZCSDKTypeBlock) {
        self.OpenZCSDKTypeBlock(self);
    }else{
        [ZCSobot startZCChatVC:[ZCUICore getUICore].kitInfo with:self target:nil pageBlock:^(id object, ZCPageBlockType type) {
            if (type == ZCPageBlockGoBack) {
                // 直接返回到分类页面
                if (self.navigationController) {
                    for (UIViewController *controller in self.navigationController.viewControllers) {
                        if ([controller isKindOfClass:[ZCServiceCentreVC class]]) {
                            [self.navigationController popToViewController:controller animated:YES];
                        }
                    }
                    
                }else{
                    UIViewController *rootVC = self.presentingViewController;
                    
                    while (rootVC.presentingViewController) {
                        rootVC = rootVC.presentingViewController;
                    }
                    [rootVC dismissViewControllerAnimated:NO completion:nil];
                }
            }else if (type == ZCPageBlockLoadFinish){
                
            }
        } messageLinkClick:nil];
    }
    
}


- (void)webView:(WKWebView *)webView didCommitNavigation:(WKNavigation *)navigation{
    [[ZCUIToastTools shareToast] showProgress:@"" with:self.view];
    
}

- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation{
    //    self.titleLabel.text = [webView stringByEvaluatingJavaScriptFromString:@"document.title"];
    [[ZCUIToastTools shareToast] dismisProgress];
    //重写contentSize,防止左右滑动
    
    CGSize size = webView.scrollView.contentSize;
    
    size.width= webView.scrollView.frame.size.width;
    
    webView.scrollView.contentSize= size;
    
    NSString *jsStr = [NSString stringWithFormat:@"var script = document.createElement('script');"
                       "script.type = 'text/javascript';"
                       "script.text = \"function ResizeImages() { "
                       "var myimg,oldwidth;"
                       "var maxwidth=%lf;" //缩放系数
                       "for(i=0;i <document.images.length;i++){"
                       "myimg = document.images[i];"
                       "if(myimg.width > maxwidth){"
                       "oldwidth = myimg.width;"
                       "myimg.width = maxwidth;"
                       "}"
                       "}"
                       "}\";"
                       "document.getElementsByTagName('head')[0].appendChild(script);",ScreenWidth-16];// SCREEN_WIDTH是屏幕宽度
    
    
    [webView evaluateJavaScript:jsStr completionHandler:nil];
    [webView evaluateJavaScript:@"ResizeImages();" completionHandler:nil];
    [webView evaluateJavaScript:@"document.getElementsByTagName('body')[0].style.webkitTextSizeAdjust= '100%'" completionHandler:nil];

    //设置颜色
    if([ZCUITools getZCThemeStyle] == ZCThemeStyle_Dark){
        [webView evaluateJavaScript:@"document.getElementsByTagName('body')[0].style.webkitTextFillColor= '#FFFFFF'" completionHandler:nil];
    }
    
}

- (void)webView:(WKWebView *)webView didFailNavigation:(WKNavigation *)navigation withError:(NSError *)error{
    [[ZCUIToastTools shareToast] dismisProgress];
    
}

- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler
{
    // 如果是跳转一个新页面
    if (navigationAction.targetFrame == nil) {
        [webView loadRequest:navigationAction.request];
    }
    NSString *urlString = [navigationAction.request.URL absoluteString];
    
    if (![urlString isEqualToString:@"about:blank"]) {
        if([[ZCUICore getUICore] LinkClickBlock] == nil || ![ZCUICore getUICore].LinkClickBlock(urlString)){
            decisionHandler(WKNavigationActionPolicyAllow);
        }else{
            decisionHandler(WKNavigationActionPolicyCancel);
        }
    }else{
        decisionHandler(WKNavigationActionPolicyAllow);
    }
}

//获取宽度已经适配于webView的html。这里的原始html也可以通过js从webView里获取
- (NSString *)htmlAdjustWithPageWidth:(CGFloat )pageWidth
                                 html:(NSString *)html
{
    NSMutableString *str = [NSMutableString stringWithString:html];
    //计算要缩放的比例
    CGFloat initialScale = webView.frame.size.width/pageWidth;
    //将</head>替换为meta+head
    NSString *stringForReplace = [NSString stringWithFormat:@"<meta name=\"viewport\" content=\" initial-scale=%f, minimum-scale=0.1, maximum-scale=2.0, user-scalable=yes\"></head>",initialScale];
    
    NSRange range =  NSMakeRange(0, str.length);
    //替换
    [str replaceOccurrencesOfString:@"</head>" withString:stringForReplace options:NSLiteralSearch range:range];
    return str;
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
