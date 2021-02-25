//
//  ZCGuideData.m
//  SobotKitFrameworkTest
//
//  Created by zhangxy on 2020/7/16.
//  Copyright © 2020 zhichi. All rights reserved.
//

#import "ZCGuideData.h"
#import <UIKit/UIKit.h>


@interface ZCGuideData(){
}

@property(nonatomic,strong)NSMutableArray *sectionItems;


@property(nonatomic,strong)NSMutableDictionary *configItems;


@property(nonatomic,strong)NSMutableDictionary *codeItems;



@end

@implementation ZCGuideData


+(ZCGuideData *)getZCGuideData{
    static ZCGuideData *_instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if(_instance == nil){
            _instance = [[ZCGuideData alloc] initPrivate];
            
        }
    });
    return _instance;
}

-(void)setDefaultValue{

//            NSString *appkey = @"e851c8ec5826445fbf4e63ac49ce257e";  // xinyao  测试
            NSString *appkey = @"e550c6e4250c4ab490f290c6d7cb5ac2";  // xinyao  正式
    appkey = @"6ab2f5150bf2415cbbabac589731d52a";
    #pragma mark - 环境
            NSString *apiHost = @"https://api.sobot.com";
//            apiHost = @"http://test.sobot.com";
//            apiHost = @"https://ten.sobot.com";
//            apiHost = @"http://172.16.4.208:8082";
//    apiHost = @"http://kefu.popmart.com";
    
    

    _apiHost = apiHost;
    _libInitInfo.app_key = appkey;
    _libInitInfo.partnerid = @"xinyao1234567";
//    _libInitInfo.robotid = @"2";
    
//    _libInitInfo.absolute_language = @"tr_lproj";
//    _libInitInfo.absolute_language = @"it_lproj";
    
    
    /**
     *  链接地址正则表达式
     *  默认为：
        @"((http[s]{0,1}|ftp)://[a-zA-Z0-9\\.\\-]+\\.([a-zA-Z0-9]{1,4})(:\\d+)?(/[a-zA-Z0-9\\.\\-~!@#$%^&*+?:_/=<>]*)?)|(([a-zA-Z0-9]{2,4}).[a-zA-Z0-9\\.\\-]+\\.([a-zA-Z]{2,4})(:\\d+)?(/[a-zA-Z0-9\\.\\-~!@#$%^&*+?:_/=<>]*)?)"
     */
//    _kitInfo.urlRegular = @"((http[s]{0,1}|ftp)://[a-zA-Z0-9\\.\\-]+\\.([a-zA-Z0-9]{1,4})(:\\d+)?(/[a-zA-Z0-9\\.\\-~!@#$%^&*+?:_/=<>]*)?)";

    _kitInfo.isShowPortrait = YES;
    _kitInfo.showPhotoPreview = YES;
//    _kitInfo.isShowReturnTips = YES;
//    _kitInfo.isOpenEvaluation = YES;
//    _kitInfo.isShowCloseSatisfaction = YES;
//    _kitInfo.navcBarHidden = YES;
//    _kitInfo.isCloseInquiryForm = YES;
//    _kitInfo.topViewBgColor = UIColor.redColor;
//    _kitInfo.hideRototEvaluationLabels = YES;
//    _kitInfo.hideManualEvaluationLabels = YES;
    
    
    ZCProductInfo *productInfo = [ZCProductInfo new];
    // 发送商品信息，可不填
    productInfo.thumbUrl = @"http://icon.nipic.com/BannerPic/20200706/original/20200706102839_1.jpg";
    productInfo.title = @"标题标题标题标题标题标题";
    productInfo.desc = @"描述描述描述描述描述描述111描述描述描述描述描述描述2222描述描述描述描述描述描述333描述描述描述描述描述描述";
    productInfo.label = @"标签1111";
    productInfo.link = @"www.baidu.com";
//    _kitInfo.productInfo = productInfo;
    
    
//    _kitInfo.leaveParamsExtends = @[@{@"id":@"23c0019171d74c73b8dde5045766db8a",@"value":@"sdfsdfssdf",@"params":@"zhangxy"}];

    
    
        NSMutableArray * leaveParamsExtends = [NSMutableArray new];
        [leaveParamsExtends addObject:@{@"id":@"5212011cae9f4f22b0e792d5f68c8b00",@"value":@"device1111111",@"params":@"device"}];
        [leaveParamsExtends addObject:@{@"id":@"31c65e32b5584f62971e73a647fe114e",@"value":@"IOS",@"params":@"system"}];
        [leaveParamsExtends addObject:@{@"id":@"a71db61b65cd4216bb19098bdf48026c",@"value":@"33333systemVersion",@"params":@"systemVersion"}];
        [leaveParamsExtends addObject:@{@"id":@"8caa1be6dea74074b214109ad30a89f1",@"value":@"wifi",@"params":@"netWork"}];
        [leaveParamsExtends addObject:@{@"id":@"ce97e63e2f0e4c26beb6e41ac17d081d",@"value":@"44444carrier",@"params":@"carrier"}];
        [leaveParamsExtends addObject:@{@"id":@"47f0a3a922b342c4bb5feaff2764e20d",@"value":@"xvalue",@"params":@"screenPix"}];
        [leaveParamsExtends addObject:@{@"id":@"2d2e3c0aca1744738b299672c82c356c",@"value":@"versionsssssss",@"params":@"appVersion"}];
        [leaveParamsExtends addObject:@{@"id":@"68b86f5674b1470193069fa4ee04ea40",@"value":@"轻听英语",@"params":@"appName"}];
        [leaveParamsExtends addObject:@{@"id":@"53778393357f429e954a2560e2ee62b9",@"value":@"userIdvalue",@"params":@"userId"}];
//        _kitInfo.leaveParamsExtends = leaveParamsExtends;
    
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
        
        
        ZCLibCusMenu *menu3 = [[ZCLibCusMenu alloc] init];
        menu3.title = [NSString stringWithFormat:@"图片"];
        menu3.url = [NSString stringWithFormat:@"sobot://sendpic"];
        menu3.imgName = @"zcicon_sendpictures";
        [arr addObject:menu3];
        
        
        ZCLibCusMenu *menu4 = [[ZCLibCusMenu alloc] init];
        menu4.title = [NSString stringWithFormat:@"位置"];
        menu4.url = [NSString stringWithFormat:@"sobot://sendLocation"];
        menu4.imgName = @"zcicon_sendpictures";
        
        [arr addObject:menu4];
    }
    
//    _kitInfo.cusMoreArray = arr;
//    _kitInfo.cusRobotMoreArray = arr;
    
    
    ZCOrderGoodsModel *model = [ZCOrderGoodsModel new];
    model.orderStatus = 1;
    model.totalFee = @"881";
    model.orderUrl = @"https://www.sobot.com";
    model.orderStatus = 1;
    model.createTime = [NSString stringWithFormat:@"%.0f",[[NSDate date] timeIntervalSince1970]*1000];
    model.goodsCount = @"2";
    model.orderUrl  = @"https://www.sobot.com";
    model.orderCode = @"1000234242342345";
    model.goods =@[@{@"name":@"商品名称",@"pictureUrl":@"http://pic25.nipic.com/20121112/9252150_150552938000_2.jpg"},@{@"name":@"商品名称",@"pictureUrl":@"http://pic31.nipic.com/20130801/11604791_100539834000_2.jpg"}];
    
//    _kitInfo.orderGoodsInfo = model;
//    NSString *skey = [[NSUserDefaults standardUserDefaults] objectForKey:@"ZC_APPKEY"];
//    if(skey!=nil && skey.length > 10){
//        _libInitInfo.app_key = skey;
//    }
//    
//    NSString *sHost = [[NSUserDefaults standardUserDefaults] objectForKey:@"ZC_Host"];
//    if(sHost!=nil && sHost.length > 5){
//        _apiHost = sHost;
//    }
    
    [ZCSobotApi setShowDebug:YES];
    
}

-(id)initPrivate{
    self=[super init];
    if(self){

        _kitInfo = [ZCKitInfo new];
        _libInitInfo = [ZCLibInitInfo new];
        
        [self setDefaultValue];
        
        _sectionItems = [[NSMutableArray alloc] init];
        [_sectionItems addObject:@[
            @{@"index":@(ZCSectionIndex31),@"code":@"3.1",@"name":@"基本设置",@"desc":@"设置服务域名、app_key、电商平台信息等",@"extends":@""},
            @{@"index":@(ZCSectionIndex331),@"code":@"3.3.1",@"name":@"初始化普通版",@"desc":@"需要app_key和域名正确",@"extends":@""},
            @{@"index":@(ZCSectionIndex332),@"code":@"3.3.2",@"name":@"初始化电商版",@"desc":@"需要app_key、域名、平台id、平台私钥正确",@"extends":@""},
            @{@"index":@(ZCSectionIndex341),@"code":@"3.4.1",@"name":@"启动客服",@"desc":@"初始化后有效",@"extends":@""},
            @{@"index":@(ZCSectionIndex342),@"code":@"3.4.2",@"name":@"启动商家列表",@"desc":@"仅电商版支持",@"extends":@""},
            @{@"index":@(ZCSectionIndex343),@"code":@"3.4.3",@"name":@"启动客户服务中心",@"desc":@"帮助中心列表",@"extends":@""},
            @{@"index":@(ZCSectionIndex351),@"code":@"3.5",@"name":@"结束会话",@"desc":@"离线用户，断开消息链接",@"extends":@""}
//            ,
//            @{@"index":@(ZCSectionIndex353),@"code":@"3.5.3",@"name":@"读取日志",@"desc":@"本地日志查询",@"extends":@""}
        ]];
        
        [_sectionItems addObject:@[
                   @{@"index":@(ZCSectionIndex41),@"code":@"4.1",@"name":@"机器人客服",@"desc":@"指定机器人",@"extends":@""},
                   @{@"index":@(ZCSectionIndex42),@"code":@"4.2",@"name":@"人工客服",@"desc":@"设置客服相关配置",@"extends":@""},
                   @{@"index":@(ZCSectionIndex43),@"code":@"4.3",@"name":@"留言工单相关",@"desc":@"",@"extends":@""},
                   @{@"index":@(ZCSectionIndex44),@"code":@"4.4",@"name":@"评价",@"desc":@"评价相关的开关、提醒等",@"extends":@""},
                   @{@"index":@(ZCSectionIndex45),@"code":@"4.5",@"name":@"消息相关",@"desc":@"消息监听、离线、拦截等说明",@"extends":@""},
                   @{@"index":@(ZCSectionIndex46),@"code":@"4.6",@"name":@"自定义UI设置",@"desc":@"",@"extends":@""},
                   @{@"index":@(ZCSectionIndex47),@"code":@"4.7",@"name":@"其它配置",@"desc":@"",@"extends":@""}
               ]];
        
        
        [_sectionItems addObject:@[
                   @{@"index":@(ZCSectionIndex51),@"code":@"5.1",@"name":@"UI(ZCKitInfo)类配置说明",@"desc":@"主要字体、颜色、显/隐配置",@"extends":@""},
                   @{@"index":@(ZCSectionIndex52),@"code":@"5.2",@"name":@"(ZCLibInitInfo)类说明",@"desc":@"主要功能性配置",@"extends":@""}
               ]];
        
        
        _configItems = [[NSMutableDictionary alloc] init];
        [_configItems setObject:@[
            @{@"index":@(ZCConfigIndex31),@"code":@"3.1",@"name":@"设置域名",@"desc":@"不设置默认为https://api.sobot.com，腾讯云为https://ten.sobot.com，其它根据自己服务配置域名",@"extends":@"",@"key":@"api_host",@"type":@"NSString",@"from":@(ZCConfigFromClient)},
            @{@"index":@(ZCConfigIndex32),@"code":@"3.2",@"name":@"设置app_key",@"desc":@"必须配置",@"extends":@"",@"key":@"app_key",@"type":@"NSString",@"from":@(ZCConfigFromLibInit)},
            @{@"index":@(ZCConfigIndex32),@"code":@"3.2",@"name":@"设置partnerid",@"desc":@"用户唯一标识，不能写死，如果为空会自动生成一个",@"extends":@"",@"key":@"partnerid",@"type":@"NSString",@"from":@(ZCConfigFromLibInit)},
            @{@"index":@(ZCConfigIndex321),@"code":@"3.2",@"name":@"设置电商平台标识",@"desc":@"仅电商版本需要",@"extends":@"",@"key":@"platformUnionCode",@"type":@"NSString",@"from":@(ZCConfigFromClient)},
            @{@"index":@(ZCConfigIndex322),@"code":@"3.2",@"name":@"设置电商平台秘钥",@"desc":@"仅电商版本需要",@"extends":@"",@"key":@"platform_key",@"type":@"NSString",@"from":@(ZCConfigFromLibInit)}
        ] forKey:@"3.1"];
        [_configItems setObject:@[
            @{@"index":@(ZCConfigIndex411),@"code":@"4.1.1",@"name":@"机器人id",@"desc":@"指定机器人编号",@"extends":@"",@"key":@"robotid",@"type":@"NSString",@"from":@(ZCConfigFromLibInit)},
            @{@"index":@(ZCConfigIndex412),@"code":@"4.1.2",@"name":@"机器人别名",@"desc":@"指定机器人别名",@"extends":@"",@"key":@"robot_alias",@"type":@"NSString",@"from":@(ZCConfigFromLibInit)}, @{@"index":@(ZCConfigIndex413),@"code":@"4.1.3",@"name":@"接待模式",@"desc":@"0：跟随系统设置（默认） 1：只有机器人, 2：仅人工,3：机器人优先 ,4：人工优先 默认跟随服务端配置，如果本地配置，本地优先",@"extends":@"",@"key":@"service_mode",@"type":@"NSString",@"from":@(ZCConfigFromLibInit)},
            @{@"index":@(ZCConfigIndex414),@"code":@"4.1.4",@"name":@"转人工溢出",@"desc":@"转人工溢出组设置，详情参考文档",@"extends":@"",@"key":@"transferaction",@"type":@"MNSString",@"from":@(ZCConfigFromLibInit)},
         @{@"index":@(ZCConfigIndex414),@"code":@"4.1.5",@"name":@"隐藏评价按钮",@"desc":@"隐藏“+”评价按钮",@"extends":@"",@"key":@"hideMenuSatisfaction",@"type":@"BOOL",@"from":@(ZCConfigFromKit)},
         @{@"index":@(ZCConfigIndex414),@"code":@"4.1.5",@"name":@"隐藏留言按钮",@"desc":@"隐藏“+”留言按钮",@"extends":@"",@"key":@"hideMenuLeave",@"type":@"BOOL",@"from":@(ZCConfigFromKit)},
         @{@"index":@(ZCConfigIndex414),@"code":@"4.1.5",@"name":@"给机器人发送一条消息类型",@"desc":@" 0 不发 1 给机器人发送 2 给人工发送  3 机器人和人工都发送",@"extends":@"",@"key":@"good_msg_type",@"type":@"NSString",@"from":@(ZCConfigFromLibInit)},
         @{@"index":@(ZCConfigIndex414),@"code":@"4.1.5",@"name":@"给机器人发送一条消息",@"desc":@"消息类型",@"extends":@"",@"key":@"content",@"type":@"NSString",@"from":@(ZCConfigFromLibInit)}
        ] forKey:@"4.1"];
        
        [_configItems setObject:@[
            @{@"index":@(ZCConfigIndex42),@"code":@"4.2.1",@"name":@"技能组id",@"desc":@"指定技能组id，如果指定了转人工不会再弹技能组选项",@"extends":@"",@"key":@"groupid",@"type":@"NSString",@"from":@(ZCConfigFromLibInit)},
            @{@"index":@(ZCConfigIndex42),@"code":@"4.2.2",@"name":@"客服id",@"desc":@"指定客服",@"extends":@"",@"key":@"choose_adminid",@"type":@"NSString",@"from":@(ZCConfigFromLibInit)},
            @{@"index":@(ZCConfigIndex42),@"code":@"4.2.2",@"name":@"指定客服类型",@"desc":@"指定客服转接类型 0:可转入其他客服,1:必须转入指定客服",@"extends":@"",@"key":@"tran_flag",@"type":@"NSString",@"from":@(ZCConfigFromLibInit)},
            @{@"index":@(ZCConfigIndex42),@"code":@"4.2.2",@"name":@"用户自定义字段",@"desc":@"用户自定义字段，需要设置->自定义字段->客户字段获取字段id作为key,例:\n{\"customField22\":\"我是自定义的分校\"}",@"extends":@"",@"key":@"customer_fields",@"type":@"MNSString",@"from":@(ZCConfigFromLibInit)},
            @{@"index":@(ZCConfigIndex42),@"code":@"4.2.2",@"name":@"接入成功后自动发送对象",@"desc":@"接入成功后自动发送一条消息， 0 不发 1 给机器人发送 2 给人工发送  3 机器人和人工都发送",@"extends":@"",@"key":@"good_msg_type",@"type":@"NSString",@"from":@(ZCConfigFromLibInit)},
            @{@"index":@(ZCConfigIndex42),@"code":@"4.2.3",@"name":@"接入成功后自动发送内容",@"desc":@"",@"extends":@"",@"key":@"content",@"type":@"NSString",@"from":@(ZCConfigFromLibInit)},
            @{@"index":@(ZCConfigIndex42),@"code":@"4.2.4",@"name":@"接入成功后自动发送内容类型",@"desc":@"0:文本，1:图片,12:文件, 23:视频",@"extends":@"",@"key":@"auto_send_msgtype",@"type":@"NSString",@"from":@(ZCConfigFromLibInit)},
            @{@"index":@(ZCConfigIndex42),@"code":@"4.2.5",@"name":@"指定客户排队优先接入",@"desc":@"同pc设置-在线客服分配-排队优先设置-指定客户优先,开启传1 默认不设置",@"extends":@"",@"key":@"queue_first",@"type":@"NSString",@"from":@(ZCConfigFromLibInit)},
            @{@"index":@(ZCConfigIndex42),@"code":@"4.2.6",@"name":@"服务总结自定义字段",@"desc":@"pc设置配置自定义字段的，添加如下：\n{\"customField15615315349481\":\"字段value1\"} 默认不设置",@"extends":@"",@"key":@"summary_params",@"type":@"MNSString",@"from":@(ZCConfigFromLibInit)},
            @{@"index":@(ZCConfigIndex42),@"code":@"4.2.7",@"name":@"多伦会话自定义字段",@"desc":@"在使用多轮会话功能时,每一个接口我们都会传入 uid 和 mulitParams",@"extends":@"",@"key":@"multi_params",@"type":@"MNSString",@"from":@(ZCConfigFromLibInit)},
            @{@"index":@(ZCConfigIndex42),@"code":@"4.2.8",@"name":@"商品卡片",@"desc":@"详细设置请参考文档4.2.8 商品卡片部分",@"extends":@"",@"key":@"isSendInfoCard",@"type":@"BOOL",@"from":@(ZCConfigFromKit)},
            @{@"index":@(ZCConfigIndex42),@"code":@"4.2.9",@"name":@"订单卡片",@"desc":@"详细设置请参考文档4.2.9 订单卡片部分",@"extends":@"",@"key":@"autoSendOrderMessage",@"type":@"BOOL",@"from":@(ZCConfigFromKit)},
            @{@"index":@(ZCConfigIndex42),@"code":@"4.2.11",@"name":@"客户身份是否VIP",@"desc":@"指定客户是否为vip",@"extends":@"",@"key":@"isVip",@"type":@"BOOL",@"from":@(ZCConfigFromLibInit)},
            @{@"index":@(ZCConfigIndex42),@"code":@"4.2.11",@"name":@"指定客户的vip等级",@"desc":@"设置-自定义字段-VIP等级",@"extends":@"",@"key":@"vip_level",@"type":@"NSString",@"from":@(ZCConfigFromLibInit)},
            @{@"index":@(ZCConfigIndex42),@"code":@"4.2.11",@"name":@"用户标签",@"desc":@"多个字段用逗号分隔",@"extends":@"",@"key":@"user_label",@"type":@"NSString",@"from":@(ZCConfigFromLibInit)},
            @{@"index":@(ZCConfigIndex42),@"code":@"4.2.12",@"name":@"隐藏评价按钮",@"desc":@"隐藏“+”评价按钮",@"extends":@"",@"key":@"hideMenuSatisfaction",@"type":@"BOOL",@"from":@(ZCConfigFromKit)},
            @{@"index":@(ZCConfigIndex42),@"code":@"4.2.12",@"name":@"隐藏留言按钮",@"desc":@"隐藏“+”留言按钮",@"extends":@"",@"key":@"hideMenuLeave",@"type":@"BOOL",@"from":@(ZCConfigFromKit)},
            @{@"index":@(ZCConfigIndex42),@"code":@"4.2.12",@"name":@"隐藏图片按钮",@"desc":@"隐藏“+ 图片按钮",@"extends":@"",@"key":@"hideMenuPicture",@"type":@"BOOL",@"from":@(ZCConfigFromKit)},
            @{@"index":@(ZCConfigIndex42),@"code":@"4.2.12",@"name":@"隐藏拍摄按钮",@"desc":@"隐藏“+”相机按钮",@"extends":@"",@"key":@"hideMenuCamera",@"type":@"BOOL",@"from":@(ZCConfigFromKit)},
            @{@"index":@(ZCConfigIndex42),@"code":@"4.2.12",@"name":@"隐藏文件按钮",@"desc":@"隐藏“+”文件按钮",@"extends":@"",@"key":@"hideMenuFile",@"type":@"BOOL",@"from":@(ZCConfigFromKit)}
        ] forKey:@"4.2"];
        
        [_configItems setObject:@[
            @{@"index":@(ZCConfigIndex43),@"code":@"4.3.2",@"name":@"留言自定义扩展字段",@"desc":@"直接进入留言自定义字段，数组，可以以传递多个",@"extends":@"",@"key":@"leaveCusFieldArray",@"type":@"MNSString",@"from":@(ZCConfigFromKit)},
            @{@"index":@(ZCConfigIndex43),@"code":@"4.3.2",@"name":@"留言自定义扩展字段",@"desc":@"直接进入留言自定义字段",@"extends":@"",@"key":@"leaveParamsExtends",@"type":@"MNSString",@"from":@(ZCConfigFromKit)},
            @{@"index":@(ZCConfigIndex43),@"code":@"4.3.2",@"name":@"技能组id",@"desc":@"指定留言技能组",@"extends":@"",@"key":@"leaveMsgGroupId",@"type":@"NSString",@"from":@(ZCConfigFromKit)},
            @{@"index":@(ZCConfigIndex42),@"code":@"4.3.5",@"name":@"是否显示回复按钮",@"desc":@"留言完成后，是否 显示 回复按钮，默认YES显示",@"extends":@"",@"key":@"leaveCompleteCanReply",@"type":@"BOOL",@"from":@(ZCConfigFromKit)},
            @{@"index":@(ZCConfigIndex42),@"code":@"4.3.7",@"name":@"留言完成主动提醒",@"desc":@"已完成留言详情界面：返回时是否弹出服务评价窗口(只会第一次返回提醒)，默认NO,不提醒",@"extends":@"",@"key":@"showLeaveDetailBackEvaluate",@"type":@"BOOL",@"from":@(ZCConfigFromKit)},
            @{@"index":@(ZCConfigIndex42),@"code":@"4.3.7.1",@"name":@"启动留言",@"desc":@"初始化完，直接启动留言",@"extends":@"",@"key":@"openLeave",@"type":@"Function",@"from":@(ZCConfigFromFunction)}
        ] forKey:@"4.3"];
        
        [_configItems setObject:@[
            @{@"index":@(ZCConfigIndex44),@"code":@"4.4.2",@"name":@"导航栏评价按钮",@"desc":@"聊天导航右上角显示评价按钮，默认不显示",@"extends":@"",@"key":@"isShowEvaluation",@"type":@"BOOL",@"from":@(ZCConfigFromKit)},
            @{@"index":@(ZCConfigIndex44),@"code":@"4.4.2",@"name":@"导航栏关闭按钮",@"desc":@"聊天导航右上角显示关闭按钮，默认不显示",@"extends":@"",@"key":@"isShowClose",@"type":@"BOOL",@"from":@(ZCConfigFromKit)},
            @{@"index":@(ZCConfigIndex44),@"code":@"4.4.2",@"name":@"关闭时是否显示评价",@"desc":@"针对关闭按钮，单独设置是否显示评价界面，默认不显示,仅人工有关闭",@"extends":@"",@"key":@"isShowCloseSatisfaction",@"type":@"BOOL",@"from":@(ZCConfigFromKit)},
            @{@"index":@(ZCConfigIndex44),@"code":@"4.4.2",@"name":@"评价完是否结束会话",@"desc":@"评价完是否结束会话，默认不开启",@"extends":@"",@"key":@"isCloseAfterEvaluation",@"type":@"BOOL",@"from":@(ZCConfigFromKit)},
            @{@"index":@(ZCConfigIndex44),@"code":@"4.4.2",@"name":@"返回是否显示评价",@"desc":@"默认不开启",@"extends":@"",@"key":@"isOpenEvaluation",@"type":@"BOOL",@"from":@(ZCConfigFromKit)},
            @{@"index":@(ZCConfigIndex43),@"code":@"4.4.2",@"name":@"评价是否显示暂不评价",@"desc":@"默认不显示",@"extends":@"",@"key":@"canBackWithNotEvaluation",@"type":@"BOOL",@"from":@(ZCConfigFromKit)},
            @{@"index":@(ZCConfigIndex42),@"code":@"4.4.3",@"name":@"返回提醒",@"desc":@"“是否离开会话提醒”，默认不显示",@"extends":@"",@"key":@"isShowReturnTips",@"type":@"BOOL",@"from":@(ZCConfigFromKit)}
        ] forKey:@"4.4"];
        
        [_configItems setObject:@[
            @{@"index":@(ZCConfigIndex45),@"code":@"4.5.1",@"name":@"本地消息自动提醒",@"desc":@"当收到本地消息时，弹一个通知提醒",@"extends":@"",@"key":@"autoNotification",@"type":@"BOOL",@"from":@(ZCConfigFromClient)},
            @{@"index":@(ZCConfigIndex45),@"code":@"4.5.1",@"name":@"自动断开服务",@"desc":@"程序退出前台自动断开服务，不影响应用后台挂起时长",@"extends":@"",@"key":@"autoCloseConnect",@"type":@"BOOL",@"from":@(ZCConfigFromClient)},
            @{@"index":@(ZCConfigIndex451),@"code":@"4.5.1.1",@"name":@"获取未读消息数",@"desc":@"当前客服发送的未读消息",@"extends":@"",@"key":@"getUnReadMessage",@"type":@"Function",@"from":@(ZCConfigFromFunction)},
            @{@"index":@(ZCConfigIndex451),@"code":@"4.5.1.2",@"name":@"清空未读消息数",@"desc":@"清空当前客服发送的未读消息",@"extends":@"",@"key":@"clearUnReadNumber",@"type":@"Function",@"from":@(ZCConfigFromFunction)}
        ] forKey:@"4.5"];
        
        
        [_configItems setObject:@[
            @{@"index":@(ZCConfigIndex45),@"code":@"4.6.1",@"name":@"自定义标题类型",@"desc":@"0.默认，显示头像 1.企业名称  2.自定义字段，3.仅显示文字、4显示头像和文字",@"extends":@"",@"key":@"title_type",@"type":@"NSString",@"from":@(ZCConfigFromLibInit)},
            @{@"index":@(ZCConfigIndex45),@"code":@"4.6.1",@"name":@"自定义标题",@"desc":@"显示的标题文本",@"extends":@"",@"key":@"custom_title",@"type":@"NSString",@"from":@(ZCConfigFromLibInit)},
            @{@"index":@(ZCConfigIndex45),@"code":@"4.6.1",@"name":@"自定义标题头像",@"desc":@"设置本地图片路径",@"extends":@"",@"key":@"custom_title_url",@"type":@"NSString",@"from":@(ZCConfigFromLibInit)},
            @{@"index":@(ZCConfigIndex45),@"code":@"4.6.1",@"name":@"聊天背景",@"desc":@"例如:#FFFFFF",@"extends":@"",@"key":@"backgroundColor",@"type":@"UIColor",@"from":@(ZCConfigFromKit)},
            @{@"index":@(ZCConfigIndex45),@"code":@"4.6.1",@"name":@"导航背景",@"desc":@"导航栏背景颜色，例如:#FFFFFF",@"extends":@"",@"key":@"topViewBgColor",@"type":@"UIColor",@"from":@(ZCConfigFromKit)},
            @{@"index":@(ZCConfigIndex45),@"code":@"4.6.1",@"name":@"顶部标题颜色",@"desc":@"导航栏文字颜色，例如:#FFFFFF",@"extends":@"",@"key":@"topViewTextColor",@"type":@"UIColor",@"from":@(ZCConfigFromKit)}
        ] forKey:@"4.6"];
        
        
        //    _kitInfo.hideRototEvaluationLabels = YES;
        //    _kitInfo.hideManualEvaluationLabels = YES;
        [_configItems setObject:@[
            @{@"index":@(ZCConfigIndex45),@"code":@"4.7.1",@"name":@"历史记录时间范围",@"desc":@"历史记录时间范围，单位分钟(例:100-表示从现在起前100分钟的会话)",@"extends":@"",@"key":@"scope_time",@"type":@"NSString",@"from":@(ZCConfigFromLibInit)},
            @{@"index":@(ZCConfigIndex45),@"code":@"4.7.6",@"name":@"默认语言",@"desc":@"指定默认语言,系统语言无法识别时使用",@"extends":@"",@"key":@"default_language",@"type":@"NSString",@"from":@(ZCConfigFromLibInit)},
            @{@"index":@(ZCConfigIndex45),@"code":@"4.7.6",@"name":@"指定语言",@"desc":@"强制指定语言",@"extends":@"",@"key":@"absolute_language",@"type":@"NSString",@"from":@(ZCConfigFromLibInit)},
            @{@"index":@(ZCConfigIndex45),@"code":@"4.7.6",@"name":@"服务端接口多语言支持",@"desc":@"暂时支持中文zh-Hans，繁体中文zh-Hant，英文en、西班牙语es、葡萄牙语pt",@"extends":@"",@"key":@"locale",@"type":@"NSString",@"from":@(ZCConfigFromLibInit)},
            @{@"index":@(ZCConfigIndex45),@"code":@"4.7.6",@"name":@"隐藏机器人评价标签",@"desc":@"评价标签不支持多语言配置是，可以不显示",@"extends":@"",@"key":@"hideRototEvaluationLabels",@"type":@"BOOL",@"from":@(ZCConfigFromKit)},
            @{@"index":@(ZCConfigIndex45),@"code":@"4.7.6",@"name":@"隐藏人工评价标签",@"desc":@"评价标签不支持多语言配置时，可以不显示",@"extends":@"",@"key":@"hideManualEvaluationLabels",@"type":@"BOOL",@"from":@(ZCConfigFromKit)},
            @{@"index":@(ZCConfigIndex45),@"code":@"4.7.8",@"name":@"时区适配",@"desc":@"自动根据手机时区适配时间显示，默认显示东八区时间",@"extends":@"",@"key":@"setAutoMatchTimeZone",@"type":@"Function",@"from":@(ZCConfigFromFunction)},
            @{@"index":@(ZCConfigIndex45),@"code":@"4.7.9",@"name":@"分屏配置",@"desc":@"分屏效果ipad",@"extends":@"",@"key":@"setSplit",@"type":@"Function",@"from":@(ZCConfigFromFunction)}
        ] forKey:@"4.7"];
        
        
        [_configItems setObject:@[
            @{@"index":@(ZCConfigIndex45),@"code":@"5.1.1",@"name":@"隐藏导航",@"desc":@"默认NO，不隐藏；隐藏系统导航,SDK会使用UIView自定义导航",@"extends":@"",@"key":@"navcBarHidden",@"type":@"BOOL",@"from":@(ZCConfigFromKit)},
            @{@"index":@(ZCConfigIndex45),@"code":@"5.1.1",@"name":@"关闭询前表单",@"desc":@"默认NO，使用系统配置",@"extends":@"",@"key":@"isCloseInquiryForm",@"type":@"BOOL",@"from":@(ZCConfigFromKit)},
            @{@"index":@(ZCConfigIndex45),@"code":@"5.1.1",@"name":@"开启语音",@"desc":@"是否开启语音功能，默认YES",@"extends":@"",@"key":@"isOpenRecord",@"type":@"BOOL",@"from":@(ZCConfigFromKit)},
            @{@"index":@(ZCConfigIndex45),@"code":@"5.1.1",@"name":@"开启机器人语音",@"desc":@"默认NO，机器人是否可发送语音，单独付费使用",@"extends":@"",@"key":@"isOpenRobotVoice",@"type":@"BOOL",@"from":@(ZCConfigFromKit)},
            @{@"index":@(ZCConfigIndex45),@"code":@"5.1.1",@"name":@"聊天背景",@"desc":@"例如:#FFFFFF",@"extends":@"",@"key":@"backgroundColor",@"type":@"UIColor",@"from":@(ZCConfigFromKit)},
            @{@"index":@(ZCConfigIndex45),@"code":@"5.1.1",@"name":@"导航背景",@"desc":@"导航栏背景颜色，例如:#FFFFFF",@"extends":@"",@"key":@"topViewBgColor",@"type":@"UIColor",@"from":@(ZCConfigFromKit)},
            @{@"index":@(ZCConfigIndex45),@"code":@"5.1.1",@"name":@"顶部标题颜色",@"desc":@"导航栏文字颜色，例如:#FFFFFF",@"extends":@"",@"key":@"topViewTextColor",@"type":@"UIColor",@"from":@(ZCConfigFromKit)},
            @{@"index":@(ZCConfigIndex45),@"code":@"5.1.1",@"name":@"聊天字号",@"desc":@"聊天内容字体大小，只能设置字号，例如:18",@"extends":@"",@"key":@"chatFont",@"type":@"UIFont",@"from":@(ZCConfigFromKit)}
        ] forKey:@"5.1"];
        
        [_configItems setObject:@[
            @{@"index":@(ZCConfigIndex45),@"code":@"5.2.1",@"name":@"电商商户ID",@"desc":@"仅电商版适用，如果没有app_key，请提供此编码",@"extends":@"",@"key":@"customer_code",@"type":@"NSString",@"from":@(ZCConfigFromLibInit)},
            @{@"index":@(ZCConfigIndex45),@"code":@"5.2.1",@"name":@"跨公司转接人工",@"desc":@"仅电商版本可用",@"extends":@"",@"key":@"flow_type",@"type":@"NSString",@"from":@(ZCConfigFromLibInit)},
            @{@"index":@(ZCConfigIndex45),@"code":@"5.1.1",@"name":@"转接到的公司ID",@"desc":@"对应flow_type,转接公司id，如设置transferaction，将覆盖flow_type、flow_companyid、flow_groupid的配置",@"extends":@"",@"key":@"flow_companyid",@"type":@"NSString",@"from":@(ZCConfigFromLibInit)},
            @{@"index":@(ZCConfigIndex45),@"code":@"5.1.1",@"name":@"转接技能组ID",@"desc":@"转接到的公司技能组",@"extends":@"",@"key":@"flow_groupid",@"type":@"NSString",@"from":@(ZCConfigFromLibInit)},
            @{@"index":@(ZCConfigIndex45),@"code":@"5.1.1",@"name":@"昵称",@"desc":@"用户显示名称",@"extends":@"",@"key":@"user_nick",@"type":@"NSString",@"from":@(ZCConfigFromLibInit)},
            @{@"index":@(ZCConfigIndex45),@"code":@"5.1.1",@"name":@"备注",@"desc":@"用户备注信息",@"extends":@"",@"key":@"remark",@"type":@"NSString",@"from":@(ZCConfigFromLibInit)},
            @{@"index":@(ZCConfigIndex45),@"code":@"5.1.1",@"name":@"自定义字段",@"desc":@"JSON字符串，固定KEY的自定义字段 所有的KEY均在工作台设置后生效（设置->自定义字段->用户信息字段）",@"extends":@"",@"key":@"customer_fields",@"type":@"MNSString",@"from":@(ZCConfigFromLibInit)}
        ] forKey:@"5.2"];
        
        
        _codeItems = [[NSMutableDictionary alloc] init];
        [_codeItems setObject:@[
            @"https://www.sobot.com/developerdocs/app_sdk/ios.html#_3-1-域名设置",
           @"https://www.sobot.com/developerdocs/app_sdk/ios.html#_3-2-获取appkey"]
          forKey:@"3.1"];
        [_codeItems setObject:@[
          @"https://www.sobot.com/developerdocs/app_sdk/ios.html#_3-3-1-普通版："]
        forKey:@"3.3.1"];
        [_codeItems setObject:@[
          @"https://www.sobot.com/developerdocs/app_sdk/ios.html#_3-3-2-电商版"]
        forKey:@"3.3.2"];
        
        [_codeItems setObject:@[
          @"https://www.sobot.com/developerdocs/app_sdk/ios.html#_3-4-1-启动客服页面"]
        forKey:@"3.4.1"];
        [_codeItems setObject:@[
          @"https://www.sobot.com/developerdocs/app_sdk/ios.html#_3-1-域名设置",
         @"https://www.sobot.com/developerdocs/app_sdk/ios.html#_3-2-获取appkey"]
        forKey:@"3.4.2"];
        [_codeItems setObject:@[
          @"https://www.sobot.com/developerdocs/app_sdk/ios.html#_3-1-域名设置",
         @"https://www.sobot.com/developerdocs/app_sdk/ios.html#_3-2-获取appkey"]
        forKey:@"3.4.3"];
        [_codeItems setObject:@[
         @"https://www.sobot.com/developerdocs/app_sdk/ios.html#_3-5-结束会话"]
        forKey:@"3.5"];
        
        [_codeItems setObject:@[
            @"https://www.sobot.com/developerdocs/app_sdk/ios.html#_4-1-机器人客服",
        @"https://www.sobot.com/developerdocs/app_sdk/ios.html#_4-1-4-设置转人工溢出"]
          forKey:@"4.1"];
        
        [_codeItems setObject:@[
            @"https://www.sobot.com/developerdocs/app_sdk/ios.html#_4-2-人工客服",
        @"https://www.sobot.com/developerdocs/app_sdk/ios.html#_4-2-8-商品卡片"]
          forKey:@"4.2"];
        
        [_codeItems setObject:@[
            @"https://www.sobot.com/developerdocs/app_sdk/ios.html#_4-3-留言工单相关"]
          forKey:@"4.3"];
        
        
        [_codeItems setObject:@[
            @"https://www.sobot.com/developerdocs/app_sdk/ios.html#_4-4-评价"]
          forKey:@"4.4"];
        
        
        [_codeItems setObject:@[
            @"https://www.sobot.com/developerdocs/app_sdk/ios.html#_4-5-1-消息推送",
            @"https://www.sobot.com/developerdocs/app_sdk/ios.html#_4-5-5-链接拦截"]
          forKey:@"4.5"];
        
        
        [_codeItems setObject:@[
          @"https://www.sobot.com/developerdocs/app_sdk/ios.html#_4-6-自定义ui设置"]
        forKey:@"4.6"];
        [_codeItems setObject:@[
            @"https://www.sobot.com/developerdocs/app_sdk/ios.html#_4-7-2-自定义聊天记录显示时间范围"]
          forKey:@"4.7"];
          [_codeItems setObject:@[
              @"https://www.sobot.com/developerdocs/app_sdk/ios.html#_5-1-zckitinfo类说明（ui相关配置）"]
            forKey:@"5.1"];
        [_codeItems setObject:@[
                @"https://www.sobot.com/developerdocs/app_sdk/ios.html#_5-2-zclibinitinfo类说明"]
              forKey:@"5.2"];
    }
    return self;
}

-(id)init{
    return [[self class] getZCGuideData];
}

-(NSArray *)getSectionArray{
    return @[@"基本集成配置",@"功能说明",@"功能属性设置"];
}
-(NSArray *)getSectionListArray:(NSInteger )section{
    if(_sectionItems.count < section){
           return @[];
       }
    return _sectionItems[section];
}

-(NSArray *)getConfigItems:(NSString *) code{
    return _configItems[code];
}

-(NSArray *) getCodeStype:(NSString *)code{
    return _codeItems[code];
}


-(void)showAlertTips:(NSString *)message vc:(UIViewController *) pvc{
    [self showAlertTips:message vc:pvc blcok:nil];
}

-(void)showAlertTips:(NSString *)message vc:(UIViewController *)pvc blcok:(nonnull void (^)(int))alerClick{
    
    UIAlertController *vc = [UIAlertController alertControllerWithTitle:nil message:message preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"好的" style: UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        if(alerClick){
            alerClick(-1);
        }
    }];
    [vc addAction:cancelAction];

    vc.popoverPresentationController.sourceView = pvc.view;
    vc.popoverPresentationController.sourceRect = CGRectMake(0,0,1.0,1.0);
    [pvc presentViewController:vc animated:YES completion:nil];
}

@end
