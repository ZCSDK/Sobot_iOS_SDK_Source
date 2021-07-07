# iOS集成文档
相关限制及注意事项  
1、iOS SDK新版支持 iOS8 以上版本，同时支持 iPhone、iPad，支持竖屏和横屏。

2、目前发布xcode版本为XCode 11.3.1,建议使用新版开发

3、iOS目前仅仅支持超链接标签，其他html标签和属性均不识别

4、iOS需要申请麦克风、相机、相册、推送权限，否则部分功能无法使用

![图片](https://img.sobot.com/mobile/sdk/images/a-0.png)

智齿客服SDK为企业提供了一整套完善的智能客服解决方案。智齿客服 SDK 既包含客服业务逻辑，也提供交互界面；企业只需简单两步，便可在App中集成智齿客服，让App拥有7*24小时客服服务能力。


管理员可以在后台「设置-支持渠道-APP」添加APP，然后按照本接入文档说明完成SDK对接。

智齿客服SDK具有以下特性

* 在线咨询：咨询机器人、咨询人工客服（收发图片、发送语音）、发送表情；
* 指定技能组接待；
* 排队或客服不在线时引导用户留言；
* 机器人优先模式下隐藏转人工按钮，N次机器人未知问题问题是显现；
* 客服满意度评价：用户主动满意度评价+用户退出时询问评价；
* 传入用户资料：用户对接lD+基础资料+自定义字段；
* 传入商品来源页：来源页标题+来源页URL；
* 高度自定义UI；

## 1 文档介绍

## 1.1 集成流程示意图
![图片](https://img.sobot.com/mobile/sdk/images/i_1_1.png)
## 1.2.文件说明
**SDK包含（SobotKit.framework和SobotKit.bundle）、SobotDemo、和Doc相关说明文档。**

| 文件名   | 说明   |备注|
|:----|:----|:----|
| SobotKit.framework   | 智齿SDK代码库   |    |
| SobotKit.bundle   | SDK资源库，包含图片文件、多语言文件、颜色   |    |
| ZCSobotApi.h   | 该文件提供接入功能(替换原有ZCSobot.h)   |    |
| ZCLibInitInfo.h   | 基础功能参数类(用户信息、接待模式、技能组等)   |    |
| ZCKitInfo.h   | 基础UI参数类(颜色、控件显/隐等)   |    |
| ZCUIBaseController   | UI界面父类，所有其它页面都继承此控制器   |    |
| ZCChatController   | 聊天界面   |    |
| SobotLocalizable.strings   | 国际化语言文件,默认根据系统语言自动匹配   |    |
| ZCLibClient.h   | 全局配置类，主要包含非UI相关的操作配置   |    |

## 2 集成方式
## 2.1 手动集成

普通版：

下载链接：[iOS_SDK_2.9.9](https://img.sobot.com/mobile/sdk/iOS_SDK_2.9.9.zip)

电商版：

下载链接：[iOS_SDK_2.9.9_电商版](https://img.sobot.com/mobile/sdk/iOS_SDK_2.9.9_MALL.zip)

解压[iOS_SDK]，添加必要文件SobotKit.framework和SobotKit.bundle到你的工程里。智齿iOS_SDK 的实现，依赖了一些系统的框架，在开发应用时需要在工程里加入这些框架。开发者首先点击工程右边的工程名，然后在工程名右边依次选择TARGETS -> BuiLd Phases -> Link Binary With Libraries，展开 LinkBinary With Libraries后点击展开后下面的 + 来添加下面的依赖项:

* AVFoundation.framework
* AssetsLibrary.framework
* AudioToolbox.framework
* SystemConfiguration.framework
* MobileCoreServices.framework
* libz.1.2.5.tbd( dylib)
* webkit.framwork  

## 2.2 CocoPods集成
在podfile中加入：

```js  
// 普通版：
pod 'SobotKit'
// 电商版：
pod 'SobotPlatform'
```


如果搜索不到最新版本，请运行以下命令更新CocoPods仓库   

```js  
pod repo update --verbose
如果无法更新到最新版本，可以删除索引文件，重新尝试
rm ~/Library/Caches/CocoaPods/search_index.json

```

清除pod缓存：

```js
删除代码中的pod 文件夹，
pod cache clean SobotKit
再重新 pod install
```

## 3.1 域名设置
域名说明：

      * 默认SaaS平台域名为:https://api.sobot.com

      * 如果您是腾讯云服务，请设置为：https://www.soboten.com

      * 如果您是本地化部署，请使用自己的部署的服务域名

示例代码：

【注意：2.8.5之前版本设置域名一定要在所有接口请求之前设置，即在初始化之前就必须设置完】

```C
// 2.8.5版本开始设置方式
// 初始化是设置域名，如果不设置，默认SaaS域名
[ZCSobotApi initSobotSDK:@"your appkey" host:@"" result:^(id  _Nonnull object) {
    
}];



//2.8.4及以前版本使用如下方式设置
//if([ZCLibClient getZCLibClient].libInitInfo == nil){
//    [ZCLibClient getZCLibClient].libInitInfo = [ZCLibInitInfo new];
//}
//[ZCLibClient getZCLibClient].libInitInfo.api_host = @"域名";
```
## 3.2 获取appkey
登录 [智齿科技管理平台](https://www.sobot.com/console/login) 获取，如图

![图片](https://img.sobot.com/mobile/sdk/images/i_3_2.png)

## 3.3 初始化 
### 3.3.1 普通版：
初始化参数和调用方式：初始化信息和UI自定义分为2个模型，使用ZCLibInitInfo设置功能相关属性，ZCKitInfo设置相关UI属性，一起传递给初始化方法，详情见Demo调用代码；

主要调用代码如下：

【注意：启动智齿SDK之前，必须调用初始化接口initSobotSDK，否则将无法启动SDK】

接口：

```js

// 2.8.5版本设置方式
// 初始化是设置域名，如果不设置，默认SaaS域名
[ZCSobotApi initSobotSDK:@"your appkey" host:@"" result:(void (^)(id object))resultBlock;

/**
 初始化智齿客服 2.7.2开始使用,默认使用SaaS域名
 @param appkey 智齿app_key(如果是电商版本，请填写自己公司的app_key)
 @param resultBlock 初始化结果回调
 */
-(void)initSobotSDK:(NSString *) app_key result:(void (^)(id object))resultBlock;

```
参数：  

| 参数名   | 类型   | 描述   |
|:----|:----|:----|
| app_key   | NSString   | app_key为必传，在支持后台->设置->APP，中查看   |
| host   | NSString   | 默认为阿里云域名，如果是其它域名需要自己指定   |
| resultBlock   | NSString   | 初始化状态回调   |

示例代码：

```js
#import <SobotKit/SobotKit.h>
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {   
      // Override point for customization after application launch.
    NSLog(@"%@",[ZCSobot getVersion]);
    // 错误日志收集(可选)
    // [ZCLibClient setZCLibUncaughtExceptionHandler];
    // 可选参数设置
    if([ZCLibClient getZCLibClient].libInitInfo == nil){
        [ZCLibClient getZCLibClient].libInitInfo = [ZCLibInitInfo new];
    }
    
    // 初始化，必须执行，并且必须在进入SDK之前调用
    [[ZCLibClient getZCLibClient] initSobotSDK:@"your app_key" result:^(id object) {
        NSLog(@"初始化完成%@",object);
    }];
    return YES;
}
```
### 3.3.2 电商版
初始化参数和调用方式：初始化信息和UI自定义分为2个模型，使用ZCLibInitInfo设置功能相关属性，ZCKitInfo设置相关UI属性，一起传递给初始化方法，详情见Demo调用代码；

主要调用代码如下：

【注意：启动智齿SDK之前，必须调用初始化接口initSobotSDK，否则将无法启动SDK,多次执行不会重复调用接口】

接口：

示例代码：

```js
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {   
      // Override point for customization after application launch.
    NSLog(@"%@",[ZCSobot getVersion]);
    // 错误日志收集(可选)
    // [ZCLibClient setZCLibUncaughtExceptionHandler];
    // 可选参数设置
    if([ZCLibClient getZCLibClient].libInitInfo == nil){
        [ZCLibClient getZCLibClient].libInitInfo = [ZCLibInitInfo new];
    }    
    [ZCLibClient getZCLibClient].libInitInfo.platform_key = @"私钥"
    //customer_code 商户对接id （仅电商版适用，如果没有app_key则必须提供）
    //[ZCLibClient getZCLibClient].libInitInfo.customer_code = @"商户id"
    // 添加  平台标识 （电商版必填）
    [ZCLibClient getZCLibClient].platformUnionCode = @"您注册的平台ID";
    
    // 初始化 
    //如果需要，请设置域名，一定要在初始化之前设置，否则初始化接口会失败
    [ZCSobotApi initSobotSDK:@"your app_key" host:@"" result:^(id object) {
    }];
    return YES;
}
```
### 3.3.3 权限设置
 需要加入的权限

```js
<key>NSCameraUsageDescription</key>
  <string>发送图片需要访问相机</string>
<key>NSLocalizedDescription</key>
  <string>使用推送服务</string>
<key>NSMicrophoneUsageDescription</key>
  <string>发送语音需要访问麦克风</string>
<key>NSPhotoLibraryUsageDescription</key>
  <string>发送图片需要访问相册</string>
```
## 3.4 启动智齿页面
### 3.4.1 启动客服页面
普通版本和电商版本启动方式一样.  
【注意：电商版本要重新指定商户app_key，启动那个商户就重新设置那个商户的app_key.】

接口

```js


/// 启动聊天页面，简单处理
/// @param info 自定义UI属性
/// @param byController  启动的页面
/// @param pageClick 页面当前状态
+ (void)openZCChat:(ZCKitInfo *) info
            with:(UIViewController *) byController
       pageBlock:(void (^)(id object,ZCPageBlockType type))pageClick;
    
 
// messageLinkClick 链接点击事件
+(void)setMessageLinkClick:(BOOL (^)(NSString * _Nonnull))messagelinkBlock
    
    
```
参数

| 参数名   | 类型   | 描述   |
|:----|:----|:----|
| info   | ZCKitInfo   | 初始化参数自定义设置 |  
| byController   | UIViewController   | 执行跳转的vc|
| delegate   | ZCChatControllerDelegate   | 聊天页面的代理，可以实现留言跳转到自定义页面|
| pageClick   | void (^)(id object,ZCPageBlockType type)   | 点击返回时的回调   |
| messagelinkBlock   | BOOL (^)(NSString *link)   | 点击消息连接回调，返回YES代表自己处理，返回NO代表不处理，可以设置为nil，如果此处不为空会覆盖setMessageLinkClick的值，后设置的覆盖前一次设置的值  |

示例代码：

```js
//设置必传参数，ZCLibInitInfo中的参数，都可以重新设置
ZCLibInitInfo *initInfo = [ZCLibClient getZCLibClient].libInitInfo;
// 设置用户id，标识用户的唯一依据，（一定不要写如123456、0、000000等固定值，同一个id的聊天记录会一样），如果不设置，默认会根据手机证书生成一个唯一标,最大支持300个字符，超过后会自动截取
initInfo.partnerid = @"";

// 如果是电商版本，需要重新指定商户app_key或商户编码customer_code
//initInfo.app_key = @"";

// 重新赋值
[ZCLibClient getZCLibClient].libInitInfo = initInfo;

//配置UI
ZCKitInfo *uiInfo=[ZCKitInfo new];
// 如设置导航条颜色
uiInfo.topViewBgColor = [UIColor redColor];
//[注意:初始化方法从2.7.0开始messageLinkClick带有Bool返回值，true自己处理，false表示不处理]
// target  如果传入的参数不为nil 需要实现 -(void)openLeaveMsgClick:(NSString*)tipMsg;代理方法 留言跳转到用户自定义的留言页
[ZCSobotApi openZCChat:uiInfo with:self target:nil pageBlock:^(id object, ZCPageBlockType type) {
                // 点击返回
                if(type==ZCPageBlockGoBack){
//                    NSLog(@"点击了关闭按钮");
                }
                
                // 页面UI初始化完成，可以获取UIView，自定义UI
                if(type==ZCPageBlockLoadFinish){
//                    NSLog(@"页面加载完成");
                }
    } messageLinkClick:^(NSString *link) { 
        NSLog(@"%@",link);
//        当收到link = sobot://sendlocation 调用智齿接口发送位置信息
//        当收到link = sobot://openlocation?latitude=xx&longitude=xxx&address=xxx 可根据自己情况处理相关业务
        if( [link hasPrefix:@"sobot://sendlocation"]){
            //发送坐标点
            NSString *fullPath = GetDocumentsFilePath(fname);
            [imageData writeToFile:fullPath atomically:YES];
            // 发送位置信息
            [ZCSobot sendLocation:@{
                                    @"lat":@"40.001693",
                                    @"lng":@"116.353276",
                                    @"localLabel":@"北京市海淀区学清路38号金码大厦A座23层金码大酒店",
                                    @"localName":@"云景四季餐厅",
                                    @"file":fullPath}];
            return YES;
        }else if([link hasPrefix:@"sobot://openlocation"]){
            // 解析经度、纬度、地址：latitude=xx&longitude=xxx&address=xxx
            // 跳转到地图的位置
            NSLog(link);
            // 测试打开地图 高德网页版            
            NSString * urlString = @"";
            urlString = [[NSString stringWithFormat:@"http://uri.amap.com/marker?position=%f,%f&name=%@&coordinate=gaode&src=%@&callnative=0",@116.353276,@40.001693,@"北京市海淀区学清路38号金码大厦A座23层金码大酒店",@"智齿SDK"] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
            [[UIApplication sharedApplication]openURL:[NSURL URLWithString:urlString]];
           return YES;
        }
        return NO;
 }];


```


### 3.4.2 启动商家列表（电商版）
【注：启动商家列表(仅电商版本支持)】

接口

```js

// 2.8.5版本使用
+ (void)openZCChatListView:(ZCKitInfo *)info with:(UIViewController *)byController onItemClick:(void (^)(ZCUIChatListController *object,ZCPlatformInfo *info))itemClickBlock;

```
参数

| 参数名   | 类型   | 描述   |
|:----|:----|:----|
| info   | ZCKitInfo   | 设置UI 相关自定义参数 |
| byController   | UIViewController   | 执行跳转的vc  |
| delegate   | ZCChatControllerDelegate  | 聊天页面的代理，可以实现留言跳转到自定义页面|
| pageClick   | void (^)(id object,ZCPageBlockType type)   | 点击返回时的回调 |
| itemClickBlock   | void (^)(ZCUIChatListController *object,ZCPlatformInfo *info)   | 自定义跳转,可以为null(注意：如果不为空内部不在做跳转处理)|


示例代码：

```js

// 新方法
[ZCSobotApi openZCChatListView:info with:byController onItemClick:itemClickBlock];
    


// 直接启动商家列表页面，2.8.4以前方式，建议使用新方法   
[ZCSobot startZCChatListView:uiInfo with:self onItemClick:nil];

// 启动商家列表，但是点击具体某一个商家可能需要重新配置参数，自己处理跳转情况，2.8.4以前方式，建议使用新方法
[ZCSobotApi openZCChatListView:uiInfo with:self onItemClick:^(ZCUIChatListController *object, ZCPlatformInfo *info) {
   // 商家某一条点击事件触发，自行启动智齿聊天页面，可以修改必传参数，ZCLibInitInfo中的参数，都可以重新设置
   [ZCLibClient getZCLibClient].libInitInfo.app_key = info.app_key;
   [ZCSobotApi openZCChat:[ZCGuideData getZCGuideData].kitInfo with:self pageBlock:^(id  _Nonnull object, ZCPageBlockType type) {
                
   }];
}];
```
### 3.4.3 启动客户服务中心
```js

ZCKitInfo *kitInfo = [ZCKitInfo new];
//kitInfo.helpCenterTel = @"40012345678";
//kitInfo.helpCenterTelTitle = @"400-客服";

// 打开帮助中心页面
+ (void)openZCServiceCenter:(ZCKitInfo *) info
                         with:(UIViewController *) byController
                  onItemClick:(void (^)(ZCUIBaseController *object))itemClickBlock;
    
```
效果如图：
![图片](https://img.sobot.com/mobile/sdk/images/i_3_4_3_1.jpeg)

### 3.5 结束会话
```js

     
/// 关闭通道，清理内存，退出智齿客户 移除推送
/// @param isClosePush YES 关闭push；NO 离线用户，但是可以收到push推送
[ZCSobotApi outCurrentUserZCLibInfo:NO];

```


## 4.1 机器人客服
### 4.1.1 对接指定机器人
在后台获取机器人编号：

![图片](https://img.sobot.com/mobile/sdk/images/i_4_1_1_1.png)

在 SDK 代码中配置：

```js
ZCLibInitInfo *initInfo = [ZCLibClient getZCLibClient].libInitInfo;
libInitInfo.robotid =  @"机器人ID";

// 不设置指定无效，注意如果指定了别名，需要把robotid设置为空，否则在别名不正确的时候，会使用上次的默认值
libInitInfo.robot_alias =  @"机器人别名";

```
注意：如果不设置，取默认
### 4.1.2 自定义接入模式
根据自身业务的需要，可进行以下初始化参数配置，控制接入模式：

```js
ZCKitInfo *uiInfo=[ZCKitInfo new];
// 是否开启语音功能 默认开启
  kitInfo.isOpenRecord = @"YES";
// 是否开启机器人语音，（付费，否则语音无法识别）
  kitInfo.isOpenRobotVoice = @"YES";
// 是否显示转人工按钮
  kitInfo.isShowTansfer = @"YES";
// 机器人未知回复次数
  kitInfo.unWordsCount = @"1";
// 是否开启智能转人工 (如输入“转人工”，直接转接人工),
需要隐藏转人工按钮，请参见isShowTansfer和unWordsCount属性
  kitInfo.isOpenActiveUser = @"YES";
// 智能转人工关键字，关键字作为key{@"转人工",@"1",@"R":@"1"}
  kitInfo.activeKeywords = @{@"转人工":@"",@"R":@"",@"r":@""};
//自定义接待模式 
注意：接待模式本地设置后本地优先，
PC端设置接待模式不再起效，建议使用PC端的设置
PC端的设置
0：跟随系统设置（默认） 
1：只有机器人,
2：仅人工 
3：智能客服-机器人优先 
4：智能客服-人工客
libInitInfo.service_mode = 4;
```

### 4.1.3 自定义转人工事件
自定义转人工事件方法：

```js
-(void)turnServiceWithGroupId:(NSString *)groupId  Obj:(id)obj Msg:(NSString*)msg KitInfo:(ZCKitInfo*)uiInfo ZCTurnType:(NSInteger)turnType Keyword:(NSString*)keyword KeywordId:(NSString*)keywordId
```
参数说明：

groupId 传入技能组id

obj   转人工参数

msg   转人工信息

uiInfo   配置商品信息和自动发送参数

turnType  转人工事件类型（按钮触发，关键字触发等）

keyword 关键字

keywordId 关键字id

【注意：如果实现该方法，SDK中转人工事件将交由外部控制处理，您可以跳转到自己设计的技能组页面，或者切换商品信息等,SDK中不会再执行转人工操作，需要自己调用转人工加接口turnServiceWithGroupId:实现具体的转人工操作】

自定义转人工回调事件：

拦截SDK 转人工事件 用于跳转到自己的app页面动态处理转人工 配置技能组id 商品信息等参数

```js
@property (nonatomic,strong)  TurnServiceBlock    turnServiceBlock;
```
示例代码：

```js
[ZCLibClient getZCLibClient].turnServiceBlock = ^(id obj,NSString *msg,NSInteger turnType, NSString *keyword ,NSString *keywordId) {
            // 自定义商品信息
            //ZCProductInfo *productInfo = [ZCProductInfo new];
            //productInfo.thumbUrl = @"商品图片URL";
            //productInfo.title = @"商品标题";
            //productInfo.desc = @"摘要";
            //productInfo.label = @"标签";
            //productInfo.link = @"http://www.sobot.com";
            //uiInfo.productInfo = productInfo;
            //uiInfo.isSendInfoCard = YES;// 转人工工成功后是否自动发送该商品卡片信息
        [[ZCLibClient getZCLibClient] turnServiceWithGroupId:@"技能组id" Obj:obj Msg:msg KitInfo:uiInfo ZCTurnType:turnType Keyword:keyword KeywordId:keywordId];
    };
```
### 4.1.4 设置转人工溢出
sdk中可以设置转人工指定技能组溢出

示例代码：

```js
/**
 *  转人工 指定技能组 溢出
 *
 参数说明

    actionType 执行动作类型：
        to_group 指定技能组；
        to_service 指定客服。
    deciId 指定技能组或客服id
    optionId 溢出标记
        1:溢出；指定客服时
        2:不溢出；指定客服时
        3:溢出；指定技能组时
        4:不溢出；指定技能组时
    spillId 溢出条件
        1:客服不在线；指定客服时
        2:客服忙碌；指定客服时
        3:智能判断；指定客服时
        4:技能组无客服在线；指定客服组时
        5:技能组所有客服忙碌；指定客服组时
        6:技能组不上班；指定客服组时
        7:智能判断；指定客服组时
 
 [{"actionType":"to_group","optionId":"3","deciId":"162bb6bb038d4a9ea018241a30694064","spillId":"7"},{"actionType":"to_group","optionId":"4","deciId":"a457f4dfe92842f8a11d1616c1c58dc1"}]
  actionType:执行动作类型：
  to_group:转接指定技能组
  optionId:是否溢出  指定技能组时：3：溢出，4：不溢出。
  deciId:指定的技能组。
  spillId:溢出条件  指定客服组时：4:技能组无客服在线,5:技能组所有客服忙碌,6:技能组不上班,7:智能判断
  数组中最多设置4组，依次溢出
 */
 
 ZCLibInitInfo *initInfo = [ZCLibClient getZCLibClient].libInitInfo;
    initInfo.transferaction = @[@{@"actionType":@"to_group",@"optionId":@"3",@"deciId":@"a890849f552b4b69b4a027db4e9a1880",@"spillId":@"4"},@{@"actionType":@"to_group",@"optionId":@"3",@"deciId":@"5600aa6786f34629a7484819b8132c3a",@"spillId":@"4"}];
```


### 4.1.5 隐藏“+”号菜单栏中的按钮

```
在 ZCKitInfo 中传入相关字段
eg：
ZCKitInfo *kitInfo=[ZCKitInfo new]; 
//  聊天页面底部加号中功能：隐藏评价，默认NO(不隐藏)
kitInfo.hideMenuSatisfaction = YES;
// 聊天页面底部加号中功能：隐藏留言，默认NO(不隐藏)
kitInfo.hideMenuLeave = YES;

```

### 4.1.6 指定机器人引导语  
不同的场景可以设置不同的机器人引导语

```
在 ZCKitInfo 中传入相关字段
eg：

ZCLibInitInfo *_libInitInfo [ZCLibClient getZCLibClient].libInitInfo;
_libInitInfo.faqId = 24;

```



## 4.2  人工客服
### 4.2.1 对接指定技能组
在后台获取技能组编号：

![图片](https://img.sobot.com/mobile/sdk/images/i_4_2_1_1.png)

在 SDK 代码中配置技能组ID：

```js
ZCLibInitInfo *initInfo = [ZCLibClient getZCLibClient].libInitInfo;
initInfo.groupid =  @"技能组ID";
```
注意：此字段可选，如果传入技能组ID那么SDK内部转人工之后不在弹技能组的选择框，直接跳转到传入ID所对应的技能组中
### 4.2.2 对接指定客服
在后台获取指定客服ID：

![图片](https://img.sobot.com/mobile/sdk/images/i_4_2_2_1.png)

![图片](https://img.sobot.com/mobile/sdk/images/i_4_2_2_2.png)

在 SDK 代码中设置：

```js
ZCLibInitInfo *initInfo = [ZCLibClient getZCLibClient].libInitInfo;
libInitInfo.choose_adminid =  @"客服ID";
libInitInfo.tran_flag =  @"0";
```
注意：
1 choose_adminid ：指定对接的客服，如果不设置，取默认

2 tran_flag ：设置指定客服之后是否必须转入指定客服 

0 ：可转入其他客服， 

1： 必须转入指定客服，  

注意：如果设置为1 ，当指定的客服不在线，不能再转接到其他客服

### 4.2.3 设置用户自定义资料和自定义字段
开发者可以直接传入这些用户信息，供客服查看。

在工作台自行配置所需要显示的字段，配置方法如下图：

![图片](https://img.sobot.com/mobile/sdk/images/i_4_2_3_1.png)

固定key的自定义字段  

```js
// 设置用户自定义字段
- (void)customUserInformation:(ZCLibInitInfo*)libInitInfo{
  libInitInfo.customer_fields = @{@"customField22":@"我是自定义的分校",
                              @"userSex":@"保密",
                              @"weixin":@"微信号",
                              @"weibo":@"微博账号",
                              @"birthday":@"2017-06-08"};
}
```


用户自定义资料，自定义key

```js
//自定义用户料
libInitInfo.params = @{@"昵称":@"我是智齿小客服"};

```

效果图如下：
![图片](https://img.sobot.com/mobile/sdk/images/a-4-2-3-1.png)


### 4.2.4 **设置转接成功后自动发消息**
```js
// 自动发送信息
ZCLibInitInfo *initInfo = [ZCLibClient getZCLibClient].libInitInfo;
// 0 不发 1 给机器人发送 2 给人工发送  3 机器人和人工都发送
initInfo.good_msg_type = 1; 
//如果是非文本，传本地路径
initInfo.content = @"123";
// 内容类型， 0, //文本 1, //图片 12, // 文件 // 视频
initInfo.auto_send_msgtype = 0;


/// 发送消息给人工
/// @param textMsg  消息内如，如果是视频、图片、音频、文件时，请传本地图片路径
/// @param msgType  0, //文本   1, //图片  12, // 文件   23, // 视频
/// @param ResultBlock 发送结果 code == 0表示已发送
+ (void)sendMessageToUser:(NSString *)textMsg type:(NSInteger ) msgType resultBlock:(nonnull void (^)(NSString *, int code))ResultBlock;


```
### 4.2.5 **设置指定客户排队优先接入**
sdk可以设置当前用户排队优先，当此用户进入排队状态时，将会被优先接待。

```js
// 同PC端 设置-在线客服分配-排队优先设置-指定客户优先   开启传1 默认不设置
@property(nonatomic,assign) int queue_first;
```
### 4.2.6 **设置服务总结自定义字段**
![图片](https://img.sobot.com/mobile/sdk/images/i_4_2_6_1.png)

```js
 initInfo.summary_params = @{@"customField15615315349481":@"字段value1",@"customField15615315349482":@"字段value2"};
```
### 4.2.7 **设置多轮会话接口参数**
在使用多轮会话功能时,每一个接口我们都会传入 uid 和 mulitParams 两个固定的自定义参数，uid 是用户的唯一标识，mulitParams是自定义字段json字符串、如果用户对接了这两个字段，我们会将这两个字段回传给第三方接口、如果没有我们会传入空字段。

```js
initInfo.multi_params = @{@"customField15619769556831":@"显示xxyyyzzz1032"};
```
### 4.2.8  商品卡片
商品的咨询信息并支持直接发送消息卡片仅人工模式下支持,在ZCKitInfo.h中配置如下信息，启动页面时传入即可：

```js


/**
 *   商品卡片信息是否自动发送（转人工成功时，自动发送商品卡片信息）
 *   默认不发送
 **/
// @property (nonatomic,assign) BOOL isSendInfoCard;

// 商品的自定义类 ZCProductInfo  如果选择添加商品信息，请添加以下信息，其中标题"title"和页面地址url"link"是必填字段，如果没有添加页面中是不会显示的。
ZCProductInfo *productInfo = [ZCProductInfo new];
//thumbUrl 缩略图地址
productInfo.thumbUrl = @"缩略图的Url";
//  title 标题 (必填)
productInfo.title = @"标题";
//  desc 摘要
productInfo.desc = @"摘要";
//  label 标签
productInfo.label = @"标签";
//  页面地址url（必填) 
productInfo.link = @"发送商品链接";
kitInfo.productInfo = productInfo;



//手动调用直接发送商品卡片
ZCProductInfo *productInfo = [ZCProductInfo new];
productInfo.thumbUrl = @"缩略图地址";
productInfo.title = @"标题";
productInfo.desc = @"摘要";
productInfo.label = @"标签";
productInfo.link = @"页面链接";
[ZCSobotApi sendProductInfo:productInfo resultBlock:nil];
```
效果图：
![图片](https://img.sobot.com/mobile/sdk/images/i_4_2_9_1.jpeg)

### 4.2.9 订单卡片
sdk中可以发送自定义订单信息，仅人工模式下支持，如有此需求，可以使用如下方法进行设置：

配置按钮:

```js
ZCKitInfo *kitInfo=[ZCKitInfo new];
NSMutableArray *arr = [[NSMutableArray alloc] init];
ZCLibCusMenu *menu1 = [[ZCLibCusMenu alloc] init];
menu1.title = [NSString stringWithFormat:@"订单"];
menu1.url = [NSString stringWithFormat:@"sobot://sendOrderMsg"];;
menu1.imgName = @"zcicon_sendpictures";
[arr addObject:menu1];
kitInfo.cusMoreArray = arr;
```
模拟自定义“+”点击发送事件:  
返回YES表示事件拦截，交由用户手动处理
返回NO表示事件不拦截 由智齿SDK内部处理

```js

    [ZCSobotApi setMessageLinkClick:^BOOL(NSString *linkUrl) {
        if ([linkUrl hasPrefix:@"sobot://sendOrderMsg"]){
                ZCOrderGoodsModel *model = [ZCOrderGoodsModel new];
                model.orderStatus = 0; // 新增0为自定义状态，显示statusCustom内容
                model.statusCustom = @"自定义状态";
                model.createTime = [NSString stringWithFormat:@"%.0f",[[NSDate date] timeIntervalSince1970]*1000];
                model.goodsCount = @"3";
                model.orderUrl  = @"https://www.sobot.com";
                model.orderCode = @"1000234242342345";
                model.goods =@[@{@"name":@"商品名称",@"pictureUrl":@"http://pic25.nipic.com/20121112/9252150_150552938000_2.jpg"},@{@"name":@"商品名称",@"pictureUrl":@"http://pic31.nipic.com/20130801/11604791_100539834000_2.jpg"}];
                
                // 单位是分，显示时会除以100，比如48.90
                model.totalFee = @"4890";
                [ZCSobotApi sendOrderGoodsInfo:model resultBlock:nil];
                
                return YES;
            }
        
        return NO;
    }];
```
ZCOrderGoodsModel 类说明：

```js
/**
发送订单消息字段：
 订单状态: orderStatus
 订单编号: orderCode
 订单创建时间: createTime
 商品图片链接: goodsPicturesUrls
 订单链接: orderUrl  ，
 商品描述: goodsDesc
 商品件数: goodsCount
 总金额: totalFee，单位为分，显示时会默认格式化为元，例如，传入4890，显示效果为48.90元
*/
/*
自定义：0,显示statusCustom的内容
待付款: 1,
待发货: 2,
运输中: 3,
派送中: 4,
已完成: 5,
待评价: 6,
已取消: 7,
其它: 不在编码中的
 */
@property (nonatomic,assign) int orderStatus;

// 自定义订单状态显示内容，仅当orderStatus=0时生效
@property (nonatomic,strong) NSString *statusCustom;

```
效果图：
![图片](https://img.sobot.com/mobile/sdk/images/i_4_2_8_1.jpeg)


### 4.2.10 查看商户客服是否正在和用户聊天 (仅电商版可用)
```js
/**
 *
 *   获取对应商户客服是否正在和用户聊天（仅电商版使用）
 *   appkey：商户id   uid： ZCPlatformInfo 类中的uid 
 **/
+(BOOL)getPlatformIsArtificialWithAppkey:(NSString *)appkey Uid:(NSString*)uid;

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
 ZCPlatformInfo *info = [_listArray objectAtIndex:indexPath.row];
[ZCSobotApi getPlatformIsArtificialWithAppkey:info.appkey Uid:info.uid];
}
```
### 4.2.11 设置vip等级和用户标签

```
/**
 *
 *  指定客户是否为vip，0:普通 1:vip
 *  同PC端 设置-在线客服分配-排队优先设置-VIP客户排队优先   开启传1 默认不设置
 *  开启后 指定客户发起咨询时，如果出现排队，系统将优先接入。
 **/
@property (nonatomic,copy) NSString *isVip;


/**
 *
 *  指定客户的vip等级，传入等级
 *  同PC端 设置-自定义字段-VIP等级,拿到等级对应的ID或者名称
 **/
@property (nonatomic,copy) NSString *vip_level;


/**
 *用户标签,多个字段用逗号分隔;
用户标签可在智齿管理端（系统设置>自定义字段>客户字段）中编辑，拿到用户标签对应的ID或者名称
 **/
@property (nonatomic,copy) NSString *user_label;

在 ZCLibInitInfo 中传入相关字段
eg：
ZCLibInitInfo *libInitInfo = [ZCLibClient getZCLibClient].libInitInfo;
//通过名称设置vip等级
libInitInfo.vip_level = @"尊贵";
//可添加多个用户标签，多个标签ID或者名称之间用,分割
libInitInfo.user_label = @"明星,记者";
```

### 4.2.12 转人工后隐藏“+”号菜单栏中的按钮

```
在 ZCKitInfo 中传入相关字段
eg：
ZCKitInfo *kitInfo=[ZCKitInfo new]; 
//  聊天页面底部加号中功能：隐藏评价，默认NO(不隐藏)
kitInfo.hideMenuSatisfaction = YES;
// 聊天页面底部加号中功能：隐藏留言，默认NO(不隐藏)
kitInfo.hideMenuLeave = YES;
// 聊天页面底部加号中功能：隐藏图片，默认NO(不隐藏)
kitInfo.hideMenuPicture = YES;
// 隐藏拍摄，默认NO(不隐藏)
kitInfo.hideMenuCamera = YES;
// 隐藏文件，默认NO(不隐藏)
kitInfo.hideMenuFile = YES;

```



## 4.3 留言工单相关

### 4.3.1 工作台设置留言界面
在工作台可以设置留言界面

![图片](https://img.sobot.com/mobile/sdk/images/i_4_3_4_1.png)


### 4.3.2 留言页面用户信息自定义配置  
留言中的邮箱、电话、附件这三个参数的校验和显示逻辑可在pc端console页面配置。

![图片](https://img.sobot.com/mobile/sdk/images/i_4_3_1_1.png)

### 4.3.3 跳转到留言页面
可以直接跳转到留言页面：

```js

ZCKitInfo *kitInfo = [[ZCKitInfo alloc] init];
kitInfo.leaveContentPlaceholder = @"请输入内容";
kitInfo.leaveMsgGuideContent = @"我是自定义引导语";
NSMutableArray *customField = [[NSMutableArray alloc] init];
[customField addObject:@{@"id" : @"510fb45d6e9d4a9c99a7c24861d584d7", @"value" : @"ca55f29ed5dd4879bdf3ab213fec3381"}];
[customField addObject:@{@"id" : @"6ee93dd945ac47fcac1a80bf03fd23fd", @"value" : @"6ee93dd945ac47fcac1a80bf03fd23fd"}];
[customField addObject:@{@"id" : @"abd0229cd5a64798b74516b3f09bbd7e", @"value" : @"abd0229cd5a64798b74516b3f09bbd7e"}];
                        
kitInfo.leaveCusFieldArray = [customField copy];
// 进入留言转工单，需要对接型字段
kitInfo.leaveParamsExtends = @[@{@"id":@"d93847a05710483893fd2d05e16a2b82",@"params":@"msgid",@"value":@"数据1"}];
kitInfo.leaveMsgGroupId = @"540a910a760f4387918b0fa7302a0eca";
[ZCSobotApi openLeanve:0 kitinfo:kitInfo with:self onItemClick:^(NSString *msg, int code) {
                            
     }];
```
其中参数：

```js  
/**
 自定义留言内容预置文案，如果需要国际化，可自行在bundle文件中，以文案为key，翻译即可
 例如："请输入内容"="Please enter content";
 */
@property (nonatomic,strong) NSString *leaveContentPlaceholder;

/**
 自定义留言引导语，如果需要国际化，可自行在bundle文件中，以文案为key，翻译即可
 例如："无法解答你的问题，你可以留言"="Please leave";
 */
@property (nonatomic,strong) NSString *leaveMsgGuideContent;

/**
 *  直接进入留言自定义字段
 *  数组，可以以传递多个
 *  id: 自定义字段的id
 *  value: 想传递的数据
 *  @{@"id":@"",@"value":@"我是数据"}
 **/
@property (nonatomic,strong) NSMutableArray * leaveCusFieldArray;


/**
 *  进入留言转工单，需要对接型字段
 *  数组，可以以传递多个
 *  id: 对接字段系统自动生成的id
 *  value: 想传递的数据
 *  params: 显示的字段ID，例如city、address，与id对应
 *  @{@"id":@"textfield12",@"value":@"我是数据",@"params":@"city"}
 **/
@property (nonatomic,strong) NSMutableArray * leaveParamsExtends;


/**
 留言技能组 id
 获取：设置 —>工单技能组设置
*/
@property (nonatomic,strong) NSString * leaveMsgGroupId;

```

### 4.3.4 留言页面事件拦截
sdk中留言可跳转到自定义页面，如有此需求，可以使用如下方法进行设置：

```js
在启动VC 服从ZCChatControllerDelegate协议 
  在启动方法中 target（代理）传入启动VC 
[ZCSobotApi openZCChat:uiInfo with:self target:vc pageBlock:^(ZCChatController *object, ZCPageBlockType type) {
 } messageLinkClick:^(NSString *link) {
}];
实现代理方法：
-(void)openLeaveMsgClick:(NSString*)tipMsg{
// 点击留言的代理事件
    NSLog(@"tipMsg ==%@",tipMsg);
}
```

### 4.3.5 工单回复按钮
可通过参数配置是否显示留言按钮：

```js
/**
 *  留言完成后，是否 显示 回复按钮
 *  默认为 yes  , 可以回复
 */
@property (nonatomic,assign) BOOL leaveCompleteCanReply;
```

### 4.3.6 获取最新留言回复

```
/// 获取最新回复
/// @param partnerid  用户id
/// @param ResultBlock code=1返回成功，
/// dict :data:items:[{(ticketId(工单id),ticketTitle(工单标题),replyContent(回复内容),replyTime(回复时间),customerId(客户id),serviceNick(客服昵称）}] 
+ (void)getLastLeaveReplyMessage:(NSString *) partnerid resultBlock:(void (^)(NSDictionary *dict,NSMutableArray *arr,int code))ResultBlock;

示例代码
 [ZCSobotApi getLastLeaveReplyMessage:[ZCLibClient getZCLibClient].libInitInfo.partnerid resultBlock:^(NSDictionary * _Nonnull dict, NSMutableArray * _Nonnull arr, int code) {
                            if(arr!=nil && arr.count > 0){
                                ZCRecordListModel *model = [arr firstObject];
                                
                                // 通知参数
                                NSString *identifier = [NSString stringWithFormat:@"leavereply.www.sobot.com%f",[[NSDate date] timeIntervalSinceNow]];
                                NSDictionary *userInfo = @{@"msgfrom":@"sobot",@"pushType":identifier,
                                             @"ticketId":model.ticketId
                                };
                                
                                
                                NSTimeInterval time = [model.replyTime doubleValue]/1000; // 传入的时间戳str如果是精确到毫秒的记得要/1000
                                NSDate *detailDate = [NSDate dateWithTimeIntervalSince1970:time];
                                NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init]; // 实例化一个NSDateFormatter对象
                                // 设定时间格式,这里可以设置成自己需要的格式
                                [dateFormatter setDateFormat:@"MM-dd HH:mm"];
                                NSString *currentDateStr = [dateFormatter stringFromDate:detailDate];
                                
                                NSString *replyContent = model.replyContent;
                                replyContent = [replyContent stringByReplacingOccurrencesOfString:@"<p>" withString:@""];
                                replyContent = [replyContent stringByReplacingOccurrencesOfString:@"</p>" withString:@""];
                                replyContent = [replyContent stringByReplacingOccurrencesOfString:@"<br/>" withString:@""];
                                NSString *replyStr = [NSString stringWithFormat:@"%@\n %@ \n %@",model.ticketTitle,currentDateStr,replyContent];
                                
                                
                                
                                [ZCSobotApi postLocalNotification:replyStr dict:userInfo];
                            }
                        }];
```


### 4.3.7 添加留言评价主动提醒开关

```
在 ZCKitInfo 中传入相关字段
eg：
ZCKitInfo *kitInfo=[ZCKitInfo new]; 
// 已完成留言详情界面：返回时是否弹出服务评价窗口(只会第一次返回弹，下次返回不会再弹)
// 默认为 NO   , 不主动提醒
kitInfo.showLeaveDetailBackEvaluate = YES;

```

### 4.3.8 添加留言扩展参数
在 ZCKitInfo 中传入相关字段 ，字段说明;

```  
/**
 *  直接进入留言自定义字段
 *  数组，可以以传递多个
 *  id: 自定义字段的id
 *  value: 想传递的数据
 *  @{@"id":@"",@"value":@"我是数据"}
 **/
@property (nonatomic,strong) NSMutableArray * leaveCusFieldArray;



/**
 *  直接进入留言对接字段
 *  数组，可以以传递多个
 *  id: 对接字段系统自动生成的id
 *  value: 想传递的数据
 *  params: 显示的字段ID，例如city、address，与id对应
 *  @{@"id":@"textfield12",@"value":@"我是数据",@"params":@"city"}
 **/
@property (nonatomic,strong) NSMutableArray * leaveParamsExtends;


/**
 留言技能组 id
 获取：设置 —>工单技能组设置
*/
@property (nonatomic,strong) NSString * leaveMsgGroupId;


```

## 4.4 评价
### 4.4.1 设置评价界面
在工作台可以设置 满意度评价界面

![图片](https://img.sobot.com/mobile/sdk/images/i_4_4_1_1.png)


### 4.4.2 评价的相关配置
```js
/**
 *
 *   导航栏右上角 是否显示 评价按钮  默认不显示
 *
 **/
@property (nonatomic,assign) BOOL isShowEvaluation;

/**
 *导航栏右上角 是否显示 关闭按钮 默认不显示，关闭按钮，点击后无法监听后台消息
 **/
@property (nonatomic,assign) BOOL isShowClose;

/**
 *
 *   针对关闭按钮，单独设置是否显示评价界面，默认不显示
 *
 **/
@property (nonatomic,assign) BOOL isShowCloseSatisfaction;
/**
 *  评价完人工是否关闭会话（人工满意度评价后释放会话）
 *  默认为NO 未开启
 *
 */
@property (nonatomic,assign) BOOL      isCloseAfterEvaluation;
/**
 *  返回时是否开启满意度评价
 *  默认为NO 未开启
 *
 */
@property (nonatomic,assign) BOOL      isOpenEvaluation;


/**
 *  返回时开启满意度评价,显示暂不评价
 *  默认为NO 未开启
 */
@property (nonatomic,assign) BOOL      canBackWithNotEvaluation;

```

参考效果：

![图片](https://img.sobot.com/mobile/sdk/images/a-4-4-2.png)![图片](https://img.sobot.com/mobile/sdk/images/a-4-4-2-1.png)

### 4.4.3 返回时要求用户评价，关闭时要求用户评价
```js
//返回或关闭时是否开启满意度评价 默认为NO 未开启
kitInfo.isOpenEvaluation = @"YES";
//评价完人工是否关闭会话（人工满意度评价后释放会话） 默认为NO 未开启
kitInfo.isCloseAfterEvaluation = @"YES";

// 是否有返回提示，默认为 NO,设置为YES，会提醒“是否结束会话”
kitInfo.isShowReturnTips = YES;

```

### 4.4.4 配置用户提交人工满意度评价后释放会话
```js

/**
 *  评价完人工是否关闭会话（人工满意度评价后释放会话）
 *  默认为NO 未开启
 *
 */
@property (nonatomic,assign) BOOL      isCloseAfterEvaluation;

```

### 4.4.5 左上角返回和右上角关闭时,人工满意度评价弹窗界面配置是否显示暂不评价按钮
```js

/**
 *  返回时开启满意度评价,显示暂不评价
 *  默认为NO 未开启
 */
@property (nonatomic,assign) BOOL      canBackWithNotEvaluation;

```


##  4.5 消息相关
### 4.5.1 消息推送
注：如果你需要SDK推送的功能请参考以下消息通知、注册推送的相关代码，如果您的项目不需要请略过。

1、在生成appkey的时候，上传推送证书(.p12格式)，导出证书一定要有密码；

2、推送只有与人工会话才会有效，机器人是直接回答没有推送；本地IM正常通信时会直接走支持IM通道，不会发送apns推送；

相关配置和代码

 推送ZCLibClient.h关键属性说明

```js
/**
推送的token
每次启动应用都需要重新设置
*/
@property (nonatomic,strong) NSData *token;
/**
测试模式，
根据此设置调用的推送证书，默认NO
NO ,调用生产环境
YES，测试环境
*/
@property (nonatomic,assign) BOOL isDebugMode;

/**
自动提醒消息
说明：如果开启自动提醒消息，当没有在智齿聊天页面的时候，都会主动把消息作为本地通知展示
此提醒为本地消息推送，与apns无关，仅是本地IM消息不在聊天页面的提醒
*/
@property (nonatomic,assign) BOOL autoNotification;


/**
 退出道后台，自动关闭长连接，默认NO
 说明：如果设置YES，退出后台立即关闭通道，不影响应用后台挂起时长
 */
@property (nonatomic,assign) BOOL autoCloseConnect;

/**
获取未读消息数
@return 未读消息数(进入智齿聊天页面会清空)
*/
-(int) getUnReadMessage;
```
注册推送

在AppDelegate.m 文件中注册推送。

导入头文件

```js
#import <SobotKit/SobotKit.h>
#import <UserNotifications/UserNotifications.h>
#define SYSTEM_VERSION_GRATERTHAN_OR_EQUALTO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)
```
服从协议  

```js

<UIApplicationDelegate,UNUserNotificationCenterDelegate>

```
注册  

```js
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationNone];
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationNone];
    
    if (SYSTEM_VERSION_GRATERTHAN_OR_EQUALTO(@"10")) {
        UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
        center.delegate = self;
        [center requestAuthorizationWithOptions:(UNAuthorizationOptionSound | UNAuthorizationOptionAlert |UNAuthorizationOptionBadge) completionHandler:^(BOOL granted, NSError * _Nullable error) {
            if (!error) {
                [[UIApplication sharedApplication] registerForRemoteNotifications];
            }
        }];
    }else{
         [self registerPush:application];
    }
    [[ZCLibClient getZCLibClient].libInitInfo setApp_key:@"your appKey"];
    // 设置推送是否是测试环境，测试环境将使用开发证书
    [[ZCLibClient getZCLibClient] setIsDebugMode:YES];
    // 错误日志收集
    [ZCLibClient setZCLibUncaughtExceptionHandler];
    return YES;
}
 
-(void)registerPush:(UIApplication *)application{
    // ios8后，需要添加这个注册，才能得到授权
    if ([[UIApplication sharedApplication] respondsToSelector:@selector(registerUserNotificationSettings:)]) {
        //IOS8
        //创建UIUserNotificationSettings，并设置消息的显示类类型
        UIUserNotificationSettings *notiSettings = [UIUserNotificationSettings settingsForTypes:(UIUserNotificationTypeBadge | UIUserNotificationTypeAlert | UIRemoteNotificationTypeSound) categories:nil];
        
        [application registerUserNotificationSettings:notiSettings];
        
    } else{ // ios7
        [application registerForRemoteNotificationTypes:(UIRemoteNotificationTypeBadge|UIRemoteNotificationTypeSound|UIRemoteNotificationTypeAlert)];
    }
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)pToken{
    NSLog(@"---Token--%@", pToken);
    // 注册token
    [[ZCLibClient getZCLibClient] setToken:pToken];

}
```


### 4.5.2 设置是否开启消息提醒
当用户不处在聊天界面时，收到客服的消息，APP 可以在通知栏或者聊天入口给出提醒。通知栏提醒可以显示最近一条消息的内容。


```js  
// 是否自动提醒， 当用户不在聊天页面，收到本地连接消息主动发送一条本地推送
[[ZCLibClient getZCLibClient] setAutoNotification:YES];
 
// 设置推送环境 
[[ZCLibClient getZCLibClient] setIsDebugMode:NO];  

```



### 4.5.3 离线消息
离线消息设置

```js

// 设置切换到后台自动断开长连接，不会影响APP后台挂起时长
// 进入前台会自动重连，断开期间消息会发送apns推送
[ZCLibClient getZCLibClient].autoCloseConnect = YES;



//  @note 检查当前消息通道是否建立，没有就重新建立， 如果调用 closeIMConnection 后，可调用此方法重新建立链接
[[ZCLibClient getZCLibClient] checkIMConnected];  
/* 检查当前监听是否被移除，如果移除就重新注册(重新激活
 网络监听 ZCNotification_NetworkChange
 UIApplicationDidBecomeActiveNotification
 UIApplicationDidEnterBackgroundNotifica
)，经常和checkIMConnected一起使用
*/
[[ZCLibClient getZCLibClient] checkIMObserverWithRegister];
/**
 移除IM所有监听，可能会影响应用在后台存活时长，如果调用此方法后需要checkIMObserverWithCreate重新激活
 网络监听 ZCNotification_NetworkChange
 UIApplicationDidBecomeActiveNotification
 UIApplicationDidEnterBackgroundNotification
 */
[[ZCLibClient getZCLibClient] removeIMAllObserver];

/**
 @note 关闭当前消息通道，使其不再接受消息，如果配置推送了，消息会走apns送达
 */  
 [[ZCLibClient getZCLibClient] closeIMConnection];
 
 
 

     
// ReceivedMessageBlock 未读消息数， obj 当前消息  unRead 未读消息数
 [ZCLibClient getZCLibClient].receivedBlock = ^(id obj,int unRead,NSDictionary *object){
//        NSLog(@"当前消息数：%d \n %@",unRead,obj);
    };
    
// 关闭通道，清理内存，退出智齿客户(如果当前是人工咨询状态客户会离线，如果是机器人状态会直接中断当前会话，下次进入是新会话)
// 说明：调用此方法后将不能接收到离线消息，除非再次进入智齿SDK重新激活
// isClosePush:YES ,是关闭push；NO离线用户，但是可以收到push推送
+(void) closeAndoutZCServer:(BOOL) isClosePush; 
//事例
[ZCLibClient  closeAndoutZCServer:YES];
```
### 4.5.4 未读消息数操作
```js
//直接获取未读消息数
[[ZCLibClient getZCLibClient] getUnReadMessage];
//清空未读消息数
 [[ZCLibClient getZCLibClient] clearUnReadNumber:@"partnerid"];
```
### 4.5.5 发送位置消息
发送位置信息，此方法，只能是收到初始化的链接监听到url=sobot://sendlocation时发起定位调用，否则可能发送失败，详细说明见ZCKitInfo.h中的canSendLocation属性说明

```js
ZCKitInfo *uiInfo=[ZCKitInfo new];
// 设置开启发送
uiInfo.canSendLocation = YES;
// 配置发送按钮，注意menu1.url = sobot://sendlocation在启动页面的messageLinkClick中监听
NSMutableArray *arr = [[NSMutableArray alloc] init];
    for (int i = 0; i<1; i++) {
        ZCLibCusMenu *menu1 = [[ZCLibCusMenu alloc] init];
        menu1.title = [NSString stringWithFormat:@"位置"];
        menu1.url = [NSString stringWithFormat:@"sobot://sendlocation"];;
        menu1.imgName = @"zcicon_sendlocation";
        [arr addObject:menu1];
        ZCLibCusMenu *menu2 = [[ZCLibCusMenu alloc] init];
        menu2.title = [NSString stringWithFormat:@"商品"];
        menu2.url = [NSString stringWithFormat:@"sobot://sendProductInfo"];;
        menu2.imgName = @"zcicon_sendpictures";
        [arr addObject:menu2];
    }
uiInfo.cusMoreArray = arr;



// 发送位置方法，fullPath为图片本地完整路径
[ZCSobotApi sendLocation:@{
                        @"lat":@"40.001693",
                        @"lng":@"116.353276",
                        @"localLabel":@"北京市海淀区学清路38号金码大厦A座23层金码大酒店",
                        @"localName":@"云景四季餐厅",
                        @"file":fullPath}];
```

### 4.5.6 链接拦截
可以通过初始化之前的代码：

```js

/// 点击链接拦截 帮助中心、留言、聊天、留言记录
/// @param messagelinkBlock 获取到链接，如果返回 YES 则拦截
    [ZCSobotApi setMessageLinkClick:^BOOL(NSString *linkUrl) {
        
        return NO;
    }];
```
拦截用户点击消息中的链接
### 4.5.7 监听当前聊天模式的变化

可以通过初始化之前的代码：

```js
    
// 当前用户会话状态
typedef NS_ENUM(NSInteger,ZCServerConnectStatus) {
    ZCServerConnectOffline    = 0, // 当前会话已经结束
    ZCServerConnectRobot      = 1, // 机器人
    ZCServerConnectArtificial = 2, // 人工接入成功
    ZCServerConnectWaiting    = 3  // 仅人工的排队
};
[[ZCLibClient getZCLibClient] setServerConnectBlock:^(id message, ZCServerConnectStatus status, NSDictionary *object) {
       
        
    }];
    
    
    // 返回事件监听
    [ZCSobotApi setZCViewControllerBackClick:^(id _Nonnull obj, ZCPageCloseType type) {
        NSLog(@"点击返回了%@，%d",obj,type);
    }];
    
```

### 4.5.8 替换消息中手机或固话识别的正则表达式

修改自己的电话号码识别规则：

```js
    
/**
*  电话号码正则表达式
 *  默认为@"0+\\d{2}-\\d{8}|0+\\d{2}-\\d{7}|0+\\d{3}-\\d{8}|0+\\d{3}-\\d{7}|1+[34578]+\\d{9}|\\+\\d{2}1+[34578]+\\d{9}|400\\d{7}|400-\\d{3}-\\d{4}|\\d{11}|\\d{10}|\\d{8}|\\d{7}"
 * 例如：82563452、01082563234、010-82543213、031182563234、0311-82563234
 、+8613691080322、4008881234、400-888-1234
 */
@property (nonatomic,strong) NSString * telRegular;

```


### 4.5.9 替换聊天消息中识别超链接的正则表达式

修改消息中超链接的识别规则：

```js
    

/**
 *  链接地址正则表达式
 *  默认为：
    @"((http[s]{0,1}|ftp)://[a-zA-Z0-9\\.\\-]+\\.([a-zA-Z0-9]{1,4})(:\\d+)?(/[a-zA-Z0-9\\.\\-~!@#$%^&*+?:_/=<>]*)?)|(([a-zA-Z0-9]{2,4}).[a-zA-Z0-9\\.\\-]+\\.([a-zA-Z]{2,4})(:\\d+)?(/[a-zA-Z0-9\\.\\-~!@#$%^&*+?:_/=<>]*)?)"
 */
@property (nonatomic,strong) NSString * urlRegular;


```


### 4.5.10 隐藏消息列表中的时间提示


```js
    

/**
  是否隐藏会话时间，默认NO不隐藏；如果不是中国区，与客户端的真实时间是有差异可以选择隐藏会话中的时间
*/
@property (nonatomic,assign) BOOL hideChatTime;


```


## 4.6 自定义UI设置
1.  在导航栏区域，我们支持自定义导航栏区域的颜色及其字体颜色；
2. 在会话页面区域，我们支持自定义会话区域的背景颜色、会话气泡颜色、会话字体颜色、提示气泡颜色、提示字体颜色、时间文字颜色；
3. 在底部区域，我们支持自定义底部bottom背景颜色及输入框线条背景颜色；
4. 其它部分，我们支持自定义相册导航栏的背景颜色及文字颜色、评价弹框中的文字颜色及按钮颜色、录音控件中的文字、商品详情展示中文字颜色（标题、详情、标签、发送）
5. 图片替换，如果想替换SDK中展示的图片，可以直接替换SobotKit.bundle中的资源；也可以放一个同名的资源名称在自己的项目中，会优先获取项目中的图片资源  

### 4.6.1 配置属性值
具体代码实现请 查看代码中的  ZCKitInfo.h 文件 ，参考 ZCKitInfo 类说明

```js

ZCKitInfo *uiInfo=[ZCKitInfo new];
// 比如：设置对话页面背景为红色
uiInfo.backgroundColor = [UIColor redColor];
// 设置顶部导航绿色
uiInfo.topViewBgColor = [UIColor greenColor];

// 启动页面是传入即可
[ZCSobotApi openZCChat:uiInfo with:self pageBlock:^(id  _Nonnull object, ZCPageBlockType type) {

        }];


```

【说明：代码未涉及到的自定义UI，可以直接替换SobotKit.bundle中的图片以达到你想要的效果或者直接放一张同名图片到你的项目中，目前SDK仅支持超链接A、斜体I，加粗：strong、b，  换行br这几种html标签，可随意组合，对于除上述之外的html标签无法很好处理，会直接过滤掉其他的标签】

### 4.6.2 自定义顶部标题
```js
ZCLibInitInfo *initInfo = [ZCLibClient getZCLibClient].libInitInfo;
// 0.默认，自动判断显示机器人头像和人工头像
// 1.始终企业名称和企业logo
// 2.显示自定义标题和图片，需要设置，custom_title、custom_title_url
// 3.仅显示机器人或人工名称，不显示头像
// 4.自动判断，显示机器人、人工的头像和名称
initInfo.title_type = @"0";

// 仅当title_type=@"2"时以下配置有效
initInfo.custom_title = @"我是自定义标题，title_type=2是生效";
initInfo.custom_title_url = @"我是自定义标题，title_type=2是生效";  

```


## 4.7 其他配置
### 4.7.1 自定义自动应答语
sdk中的自动应答语可以在pc工作台进行动态设置，

如果pc工作台的设置满足不了您的需求，那么您可以使用以下接口在代码中进行本地配置

注意：本地设置本地优先，PC端不在起效

```js
- (void)customTipWord:(ZCLibInitInfo*)libInitInfo{
    // 用户超时下线提示语
    libInitInfo.user_out_word = @"用户超时下线提示语";
    // 用户超时提示语
    libInitInfo.user_tip_word = @"用户超时提示语";
    // 人工客服提示语
    libInitInfo.admin_tip_word = @"人工客服提示语";
    // 机器人欢迎语
    libInitInfo.robot_hello_word = @"机器人欢迎语";
    // 暂无客服在线说辞
    libInitInfo.admin_offline_title = @"暂无客服在线说辞";
    // 人工客服欢迎语
    libInitInfo.admin_hello_word  = @"人工客服欢迎语";
}
```
### 4.7.2 自定义聊天记录显示时间范围
如想设置用户只能看到xx天内的聊天记录，那么可以调用以下方法进行设置:

```js
/**
 历史记录时间范围，单位分钟(例:100-表示从现在起前100分钟的会话)
 */

@property(nonatomic,assign) int scope_time;
```
### 4.7.3 “+”号面板菜单扩展

1.  固定按钮配置；

```js  
	ZCKitInfo *uiInfo=[ZCKitInfo new];
    uiInfo.canSendLocation = NO;
    uiInfo.hideMenuSatisfaction = YES;
//    uiInfo.hideMenuLeave = YES;
//    uiInfo.hideMenuPicture = YES;
//    uiInfo.hideMenuCamera = YES;
//    uiInfo.hideMenuFile = YES;

```

2. 添加自定义按钮


客服聊天界面中点击“+”按钮后所出现的菜单面板，可以根据需求自行添加菜单，代码如下：

```js
    ZCKitInfo *uiInfo=[ZCKitInfo new];
    NSMutableArray *arr = [[NSMutableArray alloc] init];
    for (int i = 0; i<1; i++) {
        ZCLibCusMenu *menu1 = [[ZCLibCusMenu alloc] init];
        menu1.title = [NSString stringWithFormat:@"订单"];
        menu1.url = [NSString stringWithFormat:@"sobot://sendOrderMsg"];
        menu1.imgName = @"zcicon_sendpictures";
        [arr addObject:menu1];
        
        ZCLibCusMenu *menu2 = [[ZCLibCusMenu alloc] init];
        menu2.title = [NSString stringWithFormat:@"商品"];
        menu2.url = [NSString stringWithFormat:@"sobot://sendProductInfo"];
        menu2.imgName = @"zcicon_sendpictures";
        
        [arr addObject:menu2];
    }
    
    
    uiInfo.cusMoreArray = arr;
    
    uiInfo.cusRobotMoreArray = arr;
```
其中：

``` 

/**
 * 自定义输入框下方更多(+号图标)按钮下面内容(不会替换原有内容，会在原有基础上追加)
 * 修改人工模式的按钮
 * 填充内容为：ZCLibCusMenu.h
 *  title:按钮名称
 *  url：点击链接(点击后会调用初始化linkBock)
 *  imgName:本地图片名称，如xxx@2x.png,icon=xxx
 */
@property (nonatomic,strong) NSMutableArray * cusMoreArray;

/**
 * 自定义输入框下方更多(+号图标)按钮下面内容(不会替换原有内容，会在原有基础上追加)
 * 修改机器人模式的按钮
 * 填充内容为：ZCLibCusMenu.h
 *  title:按钮名称
 *  url：点击链接(点击后会调用初始化linkBock)
 *  imgName:本地图片名称，如xxx@2x.png,icon=xxx
 */
@property (nonatomic,strong) NSMutableArray * cusRobotMoreArray;
```
### 4.7.4  调起拨号界面接口
```js
/**
 *  设置电话号码
 *  当导航栏右上角 显示 拨号按钮时  （和isShowTelIcon 一起设置有效）
 *
 **/
@property (nonatomic,copy) NSString * customTel;
/**
 *
 *   导航栏右上角 是否显示 拨号按钮 默认不显示    注意：和isShowEvaluation 互斥 只能设置一个有效
 *
 **/
@property (nonatomic,assign) BOOL isShowTelIcon;
```
### 4.7.5 智齿日志显示开关
```js
/**
 *  显示日志信息
 *
 *  @param isShowDebug 默认不显示
 */
+(void) setShowDebug:(BOOL) isShowDebug;
```
### 4.7.6 iOS多语言支持
目前SDK支持英文和中文两种语言，语言会根据当前手机语言自行切换适配，如果当前手机语言不识别，默认使用中文。

语言文件的统一放在SobotKit.bundle文件中，如果需要新增语言包，把支持的语言文件放入对应的语言目录下即可，例如；英文路径：SobotKit.bundle⁩/⁨en_lproj/SobotLocalizable.strings，中文的路径⁨ ⁨SobotKit.bundle⁩/⁨zh-Hans_lproj/SobotLocalizable.strings;

[说明：语言文件夹名称为当前语言名称的后面加上_lproj，例如zh-Hans_lproj,en_lproj]

```js

//获取语言名称
NSString * languages = [ZCSobotApi getCurLanguagePreHeader];


    ZCLibInitInfo *initInfo = [ZCLibClient getZCLibClient].libInitInfo;

// 设置默认语言，如果无法识别当前系统语言默认语言，不设置默认为en_lproj
initInfo.default_language = @"zh-Hans_lproj";

// 指定语言，不根据系统变化，如果找不到指定语言走默认语言逻辑
initInfo.absolute_language = @"ar_lproj";


/*
 指定接口语言，
 例如：en、zh-Hant、zh-Hans、pt、ar等
 */
 
// 指定接口语言：2.8.9之后提供
initInfo.locale = @"en";


// 下载语言(2.8.6之后提供)，如果你需要支持bundle包之外的其它语言，可提供给我们语言翻译放入我们服务器中支持动态同步
/// 从服务端同步语言文件
/// @param lan  要同步的语言，如果本地bundle中已存在不会下载，en_lproj,zh-Hans_lproj
/// @param isReWrite  如果已经下载过了是否重复下载
+(void)synchronizeLanguage:(NSString *) language write:(BOOL) isReWrite;



```


特殊处理：  
如果多语言时配置了人工评价或机器人评价标签，不支持多语言显示，可以通过如下属性隐藏显示（不影响评价功能使用，仅评价内容中缺失标签内如）

```js

//  隐藏机器人是评价标签
_kitInfo.hideRototEvaluationLabels = YES;

//  隐藏人工时评价标签
_kitInfo.hideManualEvaluationLabels = YES;





```


### 4.7.7 设置暗黑模式

从2.8.5版本开始支持暗黑模式，默认根据手机系统设置自动适配；也可强制指定使用，配置如下：

```js

	ZCKitInfo *uiInfo=[ZCKitInfo new];
	// 默认为0,跟随系统设置, 1强制使用暗黑风格
    uiInfo.themeStyle = 1;
   
   // 默认为YES，当为暗黑模式时候自定义颜色属性将失效
   // 如果要保持暗黑模式时自定义颜色生效，设置为NO
    uiInfo.useDefaultDarkTheme = YES;

```


### 4.7.8 时区适配
从2.8.9版本开始支持，默认系统北京东八区标准事件，如果根据手机时间动态适配，配置如下代码：  

```js

[ZCSobotApi setAutoMatchTimeZone:YES];

```

### 4.7.9 智齿部分功能页面点击返回和事件的监听（只记录不拦截），可自己添加逻辑（例如埋点）

```js

    [ZCSobotApi setFunctionClickListener:^(id _Nonnull obj, ZCPageCloseType type) {
    	 //1:留言返回,2:会话页面返回,3:帮助中心返回,4:电商消息中心页面返回,5:电话打电话按钮
        NSLog(@"点击返回了%@，%zd",obj,type);
    }];

```


## 5 配置类属性说明
## 5.1 ZCKitInfo类说明（UI相关配置）
每次启动智齿页面都可以重新设置
### UI逻辑相关：
| 属性名称   | 数据类型   | 说明   | 备注   |
|:----|:----|:----|:----|
| isOpenEvaluation   | BOOL   | 点击返回时是否开启满意度评价   | 默认为NO 未开启   |
| isCloseAfterEvaluation   | BOOL   | 点击返回时开启满意度评价后，评价完人工是否关闭会话   | 默认为NO，未开启   |
| isShowTansfer   | BOOL   | 机器人优先模式，是否直接显示转人工按钮（值为NO时，会在人工无法回答时和unWordsCount参数配合显示转人工按钮）   | 默认为YES显示转人工按钮   |
| unWordsCount | NSString | 机器人优先模式，通过记录机器人未知说辞的次数设置是否直接显示转人工按钮 | 默认不设置 |
| isShowTelIcon   | BOOL   | 导航栏右上角 是否显示 拨号按钮 默认不显示    注意：和isShowEvaluation 互斥 只能设置一个有效   |      |
| isShowEvaluation   | BOOL   | 导航栏右上角 是否显示 评价按钮   | 默认不显示   |
| customTel | NSString | 当导航栏右上角 显示 拨号按钮时  （和isShowTelIcon 一起设置有效） |    |
| isOpenRecord   | BOOL   | 是否开启语音功能(人工接待时)   | 默认YES，开启   |
| isShowNickName   | BOOL   | 留言页面是否显示昵称输入框   | 默认NO不显示   |
| isAddNickName   | BOOL   | 非必须输入，留言时是否必须输入昵称   | 默认为NO   |
| isSetPhotoLibraryBgImage   | BOOL   | 是否设置相册背景图片（不设置会跟着导航颜色配置）   |    |
| isOpenRobotVoice   | BOOL   | 是否开启机器人语音（需要开通，未开通时机器人无法识别语音）   |    |
| navcBarHidden   | BOOL   | SDK 页面中使用自定义的导航栏，不在使用系统的导航栏（隐藏）   |    |
| canSendLocation   | BOOL   | 人工状态，是否可以发送位置   【 注意：   由于每个App定位插件选择不同，智齿没有实现选择位置功能，所以需要自行传递位置到SDK以及打开显示，步骤如下：   1、实现messageLinkClick事件（在ZCSobot startZCChatVC函数中）   2、当收到link = sobot://sendlocation 调用智齿接口发送位置信息   3、当收到link = sobot://openlocation?latitude=xx&longitude=xxx&address=xxx 可根据自己情况处理相关业务   |    |
| isSendInfoCard   | BOOL   | 商品卡片信息是否自动发送（转人工成功时，自动发送商品卡片信息）   默认不自动发送   |    |
| productInfo   | ZCProductInfo   | 产品信息 ，配合 isSendInfoCard 使用   |    |
| isShowCloseSatisfaction   | BOOL   | 关闭按钮时是否显示评价界面，默认不显示   |    |
| isShowReturnTips   | BOOL   | 返回时是否开启提示，提示文案默认为：您是否要结束会话？，如需修改，请修改国际化配置文件   |    |
| ishidesBottomBarWhenPushed   | BOOL   | push后隐藏 BottomBar    | 默认是 yes   |
| isShowPortrait   | BOOL   | 仅支持竖屏   | 默认为 NO   |
| isCloseInquiryForm   | BOOL   | 是否关闭询前表单（默认为NO，使用系统默认配置）   |    |
| isShowClose   | BOOL   | 导航栏右上角 是否显示 关闭按钮 默认不显示，关闭按钮，点击后无法监听后台消息   |    |
| isUseImagesxcassets   | BOOL   | 是否使用 .xcassets 里的图片   | 默认为NO 未开启   |
| isOpenActiveUser   | BOOL   | 是否开启智能转人工,(如输入“转人工”，直接转接人工)，需要隐藏转人工按钮，请参见isShowTansfer和unWordsCount属性     |    |
| activeKeywords   | BOOL   | 智能转人工关键字，关键字作为key{@"转人工",@"1",@"R":@"1"}   |    |
| autoSendOrderMessage   | BOOL   | 人工后，是否主动发送一条信息   |    |
| orderGoodsInfo   | ZCOrderGoodsModel   | 需要发送的订单信息 ，配合 autoSendOrderMessage 使用   |    |
| leaveCompleteCanReply   | BOOL   | 留言完成后，是否 显示 回复按钮   | 默认为 yes  , 可以回复   |
| hideMenuSatisfaction   | BOOL   | 聊天页面底部加号中功能：隐藏评价   | 默认NO(不隐藏) |
| hideMenuLeave   | BOOL   | 聊天页面底部加号中功能隐藏留言   | 默认NO(不隐藏) |
| hideMenuPicture   | BOOL   | 聊天页面底部加号中功能：隐藏图片   | 默认NO(不隐藏)|
| hideMenuCamera   | BOOL   | 聊天页面底部加号中功能：隐藏拍摄   | 默认NO(不隐藏) |
| hideMenuFile   | BOOL   | 聊天页面底部加号中功能：隐藏文件   | 默认NO(不隐藏)  |
| themeStyle   | BOOL   | 是否设置为暗黑模式,1暗黑,0跟随系统设置   | 默认为0   |
| useDefaultDarkTheme   | BOOL   | 如果设置了自定义颜色，是否使用默认暗黑模式,如果设置为NO，当为暗黑模式时候自定义颜色属性将失效   | 默认为YES  |
| leaveContentPlaceholder   | NSString   | 自定义留言内容预置文案   |   |
| leaveMsgGuideContent   | NSString   |  自定义留言引导语   |   |
| leaveCusFieldArray   | NSMutableArray   | 直接进入留言自定义字段   |   |
| leaveMsgGroupId   | NSString   | 留言技能组 id,获取：设置 —>工单技能组设置  |   |
| hideChatTime   | BOOL   | 是否隐藏会话时间   |  默认NO |
| hideRototEvaluationLabels   | BOOL   | 是否隐藏机器人评价标签   |  默认NO，不隐藏 |
| hideManualEvaluationLabels   | BOOL   | 是否隐藏人工评价标签   |  默认NO，不隐藏 |
| helpCenterTel   | NSString   | 帮助中心可跳转电话号码   |  默认不显示 |
| helpCenterTelTitle   | NSString   | 帮助中心电话号码显示内容  |  默认不显示 |
| showPhotoPreview   | BOOL   | 选择图片时，不直接发送，预览发送【注意：预览方框仅为放大镜效果，不是裁切图片，发送的还是原图】  |  默认NO，关闭 |
| leaveTemplateId   | NSString   |  留言模板 id【注意 配合ZCChatControllerDelegate 使用 】  |    |
| hideNavBtnMore   | BOOL   |  是否隐藏导航右上角“...”更多按钮  |  默认NO，默认不隐藏 |

### 字体相关：
| 属性名称 | 数据类型 | 说明 | 备注 |
|:----|:----|:----|:----|
| titleFont   | UIFont   | 顶部标题的font   |    |
| listDetailFont   | UIFont   | 各种按钮，网络提醒 font   |    |
| listTimeFont   | UIFont   | 消息提醒(转人工、客服接待等)  font   |    |
| chatFont   | UIFont   | 聊天气泡中文字 font   |    |
| voiceButtonFont   | UIFont   | 录音按钮的文字 font   |    |
| goodsTitleFont   | UIFont   | 商品详情cell 中title的文字 font   |    |
| goodsDetFont   | UIFont   | 商品详情cell中摘要的文字 font   |    |
| notificationTopViewLabelFont   | UIFont   | 通告的文字 字号 大小   |    |

### 背景颜色相关:
| 属性名称 | 数据类型 | 说明 | 备注 |
|:----|:----|:----|:----|
| goodSendBtnColor   | UIColor   | 商品详情cell中btn的背景色   |    |
| backgroundColor   | UIColor   | 对话页面背景色   |    |
| imagePickerColor   | UIColor   | 相册导航栏的颜色   |    |
| imagePickerTitleColor   | UIColor   | 相册导航栏的标题颜色   |    |
| leftChatColor   | UIColor   | 左边聊天气泡的颜色   |    |
| rightChatColor   | UIColor   | 右边聊天气泡的颜色   |    |
| leftChatSelectedColor   | UIColor   | 左边气泡复制选中的颜色   |    |
| rightChatSelectedColor   | UIColor   | 右边气泡复制选中的颜色   |    |
| backgroundBottomColor   | UIColor   | 底部bottom的背景颜色   |    |
| commentCommitButtonColor   | UIColor   | 评价提交按钮背景颜色   |    |
| BgTipAirBubblesColor   | UIColor   | 提示气泡的背景颜色   |    |
| goodSendBtnColor   | UIColor   | 商品发送按钮的背景色   |    |
| satisfactionSelectedBgColor   | UIColor   | 评价页“已解决”和“未解决”背景色   |    |
| satisfactionTextSelectedColor   | UIColor   | 评价页“已解决”和“未解决”文字颜色   |    |
| topViewBgColor   | UIColor   | 自定义导航栏背景色   |    |
| trunServerBtnColor   | UIColor   | 机器人的问答中 提示转人工按钮的文字颜色   |    |
| bottomLineColor   | UIColor   | 底部bottom框边框线颜色(输入框、录音按钮、分割线)   |    |
| notificationTopViewBgColor   | UIColor   | 通告栏的背景色   |    |
| commentButtonBgColor   | UIColor   | 评价弹出页面 按钮选中颜色(默认跟随主题色)  |    |
| commentItemButtonBgColor   | UIColor   | 评价选项按钮选中颜色(默认跟随主题色)   |    |
| commentItemButtonSelBgColor   | UIColor   | 评价选项按钮选中颜色(默认跟随主题色)   |    |

### 文字颜色相关：
| 属性名称 | 数据类型 | 说明 | 备注 |
|:----|:----|:----|:----|
| submitEvaluationColor   | UIColor   | 提交评价按钮的文字颜色   |    |
| topViewTextColor   | UIColor   | 顶部文字颜色   |    |
| leftChatTextColor   | UIColor   | 左边气泡文字颜色   |    |
| rightChatTextColor   | UIColor   | 右边气泡文字颜色   |    |
| timeTextColor   | UIColor   | 时间文字的颜色   |    |
| tipLayerTextColor   | UIColor   | 提示文字的颜色   |    |
| chatLeftLinkColor   | UIColor   | 左边气泡中链接颜色   |    |
| chatRightLinkColor   | UIColor   | 右边气泡中链接颜色   |    |
| goodsTitleTextColor   | UIColor   | 商品cell中title的文字颜色   |    |
| goodsTipTextColor   | UIColor   | 商品cell中标签的文字颜色   |    |
| goodsDetTextColor   | UIColor   | 商品cell中摘要的文字颜色   |    |
| goodsSendTextColor   | UIColor   | 商品详情cell中发送的文字颜色   |    |
| scoreExplainTextColor   | UIColor   | 满意度星级说明的文字颜色   |    |
| chatTextViewColor   | UIColor   | 输入框文本颜色   |    |
| notificationTopViewLabelColor   | UIColor   | 通告栏的文字颜色   |    |
| emojiSendBgColor   | UIColor   | 表情键盘发送按钮背景颜色,2.8.5新增   |    |
| commentItemButtonBgColor   | UIColor   |  评价选项按钮选中颜色(默认跟随主题色)  |    |
| commentItemButtonSelBgColor   | UIColor   |  评价选项按钮选中颜色(默认跟随主题色)   |    |

### 图片相关：
| 属性名称 | 数据类型 | 说明 | 备注 |
|:----|:----|:----|:----|
| moreBtnNolImg   | NSString   | 自定义导航栏更多按钮默认状态图片   |    |
| moreBtnSelImg   | NSString   | 自定义导航栏更多按钮选中状态图片   |    |
| turnBtnSelImg   | NSString   | 转人工按钮选中状态图片   |    |
| turnBtnNolImg   | NSString   | 转人工按钮默认状态图片   |    |
| topBackSelImg   | NSString   | 返回按钮选中状态图片   |    |
| topBackNolImg   | NSString   | 返回按钮默认状态图片   |    |

### 其他：
| 属性名称 | 数据类型 | 说明 | 备注 |
|:----|:----|:----|:----|
| topBackTitle   | NSString   | 聊天页面 左上角 返回按钮的文字 （默认 “返回”）   |    |
| cusMoreArray   | NSMutableArray   | 自定义输入框下方更多(+号图标)按钮下面内容(不会替换原有内容，会在原有基础上追加)   填充内容为：ZCLibCusMenu.h   title:按钮名称   url：点击链接(点击后会调用初始化linkBock)   imgName:本地图片名称，如xxx@2x.png,icon=xxx   |    |
| cusMenuArray   | NSMutableArray   | 自定义快捷入口   填充内容为： ZCLibCusMenu.h    url: 快捷入口链接(点击后会调用初始化linkBock)    title: 按钮标题    lableId: 自定义快捷入口的ID   |    |
| cusRobotMoreArray   | NSMutableArray   | 自定义输入框下方更多(+号图标)按钮下面内容(不会替换原有内容，会在原有基础上追加)  填充内容为：ZCLibCusMenu.h   |    |

## 5.2 ZCLibInitInfo类说明
初始化后会自动创建此对象，后续直接使用即可
### id 相关：
| 属性名称 | 数据类型 | 说明 | 备注 |
|:----|:----|:----|:----|:----:|
| api_host   | NSString   | 接口域名,默认SaaS平台域名为:[https://api.sobot.com](https://api.sobot.com)   | 【2.8.6版本去掉此属性，由初始化直接指定】如果您是腾讯云服务，请设置为：[https://ten.sobot.com](https://ten.sobot.com)  如果您是本地化部署，请使用你们自己的部署的服务域名   |
| app_key   | NSString   | 必须设置，不设置初始化不成功，初始化会自动赋值。   | 必填   |
| choose_adminid   | NSString   | 指定客服ID   |    |
| tran_flag   | int   | 定指客服 转接类型    |  0 可转入其他客服  1 必须转入指定客服   |
| partnerid   | NSString   | 用户唯一标识   | 对接用户可靠身份，不能写死(写固定值会是同一个身份，后果很严重)，不建议为null，如果为空会以设备区别，最大支持300个字符，超过后会自动截取   |
| robotid   | NSString   | 对接机器人ID   |    |
| robot_alias   | NSString   | 对接机器人别名,如果设置此值每次都需要设置robotid为空   |    |
| platform_userid   | NSString   | 平台通道参数，初始化成功后会自动赋值   |    |
| platform_key   | NSString   | 私钥   |    |

电商版：

设置电商转人工溢出策略，以下属性与transferaction冲突，如果设置transferaction，将覆盖flow_type、flow_companyid、flow_groupid的配置。

| 属性名称 | 数据类型 | 说明 | 备注 |
|:----:|:----:|:----|:----|
| customer_code | NSString | 商户对接id （仅电商版适用，如果没有app_key，请提供此编码）   |    |
| flow_type   | int   | 跨公司转接人工(仅电商版本可用)   | 默认0不开启 1-全部溢出，2-忙碌时溢出，3-不在线时溢出     |
| flow_companyid   | NSString   | 转接到的公司ID   |    |
| flow_groupid   | NSString   | 转接到的公司技能组   |    |

### 客服工作台显示：
| 属性名称 | 数据类型 | 说明 | 备注 |
|:----|:----|:----|:----|
| user_nick   | NSString   | 昵称   |    |
| user_name   | NSString   | 真实姓名   |    |
| user_tels   | NSString   | 用户电话   |    |
| user_emails   | NSString   | 用户邮箱   |    |
| qq   | NSString   | qq   |    |
| remark   | NSString   | 备注   |    |
| face   | NSString   | 用户自定义头像   |    |
| visit_title   | NSString   | 接入来源页面标题   |    |
| visit_url   | NSString   | 接入的来源URL   |    |
| params   | NSDictionary   | 用户资料   |    |
| customer_fields   | NSDictionary   | 固定KEY的自定义字段  所有的KEY均在工作台设置后生效（设置->自定义字段->用户信息字段）   | ```@{@"customField22":@"我是自定义的分校"};```   |
| group_name   | NSString   | 技能组名称   |    |
| groupid   | NSString   | 技能组编号   |    |
| isVip   | NSString   | 指定客户是否为vip，0:普通 1:vip   | 同PC端 设置-在线客服分配-排队优先设置-VIP客户排队优先   开启传1 默认不设置   开启后 指定客户发起咨询时，如果出现排队，系统将优先接入。   |
| vipLevel   | NSString   | 指定客户的vip等级，传入等级   | 同PC端 设置-自定义字段-客户字段   |

### 说辞相关：
| 属性名称 | 数据类型 | 说明 | 备注 |
|:----|:----|:----|:----|
| admin_hello_word   | NSString   | 自定义客服欢迎语,默认为空 （如果传入，优先使用该字段）   |    |
| robot_hello_word   | NSString   | 自定义机器人欢迎语,默认为空 （如果传入，优先使用该字段）   |    |
| user_tip_word   | NSString   | 自定义用户超时提示语,默认为空 （如果传入，优先使用该字段）   |    |
| admin_offline_title   | NSString   | 自定义客服不在线的说辞,默认为空 （如果传入，优先使用该字段）   |    |
| admin_tip_word   | NSString   | 自定义客服超时提示语,默认为空 （如果传入，优先使用该字段）   |    |
| user_out_word   | NSString   | 自定义用户超时下线提示语,默认为空 （如果传入，优先使用该字段）   |    |

### 会话页面相关：
| 属性名称 | 数据类型 | 说明 | 备注 |
|:----|:----|:----|:----|
| service_mode   | int   | 自定义接入模式  1只有机器人,2.仅人工 3.智能客服-机器人优先 4智能客服-人工客服优先   |    |
| title_type   | NSString   | 聊天页顶部标题 的自定义方式 0.默认  1.企业名称  2.自定义字段，3.仅显示文字、4显示头像和文字   |    |
| custom_title   | NSString   | 聊天页顶部标题 自定义字段   |    |
| custom_title_url   | NSString   | 自定义图像路径    |    |
| scope_time   | int   | 历史记录时间范围，单位分钟(例:100-表示从现在起前100分钟的会话)   |    |
| notifition_icon_url   | NSString   | 通告的icon 的URL   |    |
| faqId   | int   | 指定引导语,不同的用户设置特定的引导语   |    |


### 其他：
| 属性名称 | 数据类型 | 说明 | 备注 |
|:----|:----|:----|:----:|
| is_enable_hot_guide   | BOOL   | 是否允许请求热点引导问题接口   |    |
| margs   | NSDictionary   | 热点引导问题的扩展字段   |    |
| support   | BOOL   | 机器人问答是否支持分词联想   |    |
| transferaction   | NSArray   | 转人工 指定技能组 溢出   actionType:执行动作类型：to_group:转接指定技能组   optionId:是否溢出  指定技能组时：3：溢出，4：不溢出。   deciId:指定的技能组。   spillId:溢出条件  指定客服组时：4:技能组无客服在线,5:技能组所有客服忙碌,6:技能组不上班,7:智能判断 eg:[{"actionType":"to_group","optionId":"3","deciId":"162bb6bb038d4a9ea018241a30694064","spillId":"7"}, {"actionType":"to_group","optionId":"4","deciId":"a457f4dfe92842f8a11d1616c1c58dc1"}]  |    |
| summary_params   | NSDictionary   | 转人工自定义字段  key： ```@{@"customField15619769556831":@"显示xxyyyzzz1032"};```  |    |
| multi_params   | NSDictionary   | 多轮会话 自定义字段   |    |
| good_msg_type   | int   | 自定发送商品订单信息类型; 0 不发 1 给机器人发送 2 给人工发送  3 机器人和人工都发送  |    |
| content   | NSString   | 自动发送商品订单信息内容   |    |
| queue_first   | int   | 指定客户优先   |    |
| default_language   | NSString   | 默认语言,不指定不识别系统语言默认英语，en_lproj   | 不识别时才使用   |
| absolute_language   | NSString   | 指定语言，不跟随系统语言自动切换   |    |

## 6 资源库源码
      智齿 iOS_SDK [UI源码](https://github.com/ZCSDK/sobotKit_UI_iOS);  
      智齿SDK功能使用体验[APP下载](https://apps.apple.com/us/app/id1507872824) [使用视频引导](https://img.sobot.com/mobile/sdk/sobot_sdk_demo_android.mp4)

## 7 常见问题
       常见问题解答：


请[点击链接](https://www.sobot.com/chat/pc/v2/index.html?sysnum=a76f3cef7d1043c69dd592c3e43f8242#0) 进入智能机器人输入您的问题

      
## 8 更新说明

   [《智齿iOS_SDK 版本更新说明》](https://shimo.im/docs/3no79A6BJ8EbxWJG)

