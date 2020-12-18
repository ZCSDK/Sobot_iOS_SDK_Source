//
//  EntityConvertUtils.m
//  SobotKitFrameworkTest
//
//  Created by 张新耀 on 2020/1/8.
//  Copyright © 2020 zhichi. All rights reserved.
//

#import "EntityConvertUtils.h"
#import <Foundation/Foundation.h>
#import <objc/runtime.h>

@implementation EntityConvertUtils


+(EntityConvertUtils *)getEntityConvertUtils{
    static EntityConvertUtils *_instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if(_instance == nil){
            _instance = [[EntityConvertUtils alloc] initPrivate];
            
        }
    });
    return _instance;
}

-(id)initPrivate{
    self=[super init];
    if(self){
        [self setDefaultConfiguration];
    }
    return self;
}

-(id)init{
    return [[self class] getEntityConvertUtils];
}



/// 设置默认值
-(void)setDefaultConfiguration{
    _kitInfo = [[ZCKitInfo alloc] init];
    _kitInfo.topViewBgColor =  UIColorFromRGB(0xFFFFFF);
    _kitInfo.leftChatColor = UIColorFromRGB(0xF2F5F7);
    _kitInfo.rightChatColor = UIColorFromRGB(0x2fb9c3);
    _kitInfo.leftChatTextColor = UIColorFromRGB(0x515a7c);
    _kitInfo.rightChatTextColor = UIColorFromRGB(0xFFFFFF);
    
    _kitInfo.hideMenuSatisfaction = NO;
    _kitInfo.hideMenuLeave = NO;
    _kitInfo.hideMenuPicture = NO;
    _kitInfo.hideMenuCamera = NO;
    _kitInfo.hideMenuFile = NO;
    _kitInfo.showLeaveDetailBackEvaluate = NO;
    _kitInfo.telRegular = @"";
    _kitInfo.urlRegular = @"";
    _kitInfo.useDefaultDarkTheme = YES;
//    _kitInfo.navcBarHidden = YES;
    _kitInfo.isOpenEvaluation = YES;
    _kitInfo.canBackWithNotEvaluation = YES;
    _kitInfo.isCloseAfterEvaluation = YES;
    
    _kitInfo.isShowCloseSatisfaction = YES;
//    _kitInfo.isShowReturnTips = YES;
    _kitInfo.isShowClose = YES;
    _kitInfo.hideChatTime = YES;
    _kitInfo.isOpenRobotVoice = YES;
    
    if(_libInitInfo == nil || convertToString(_libInitInfo.app_key).length == 0){
        _libInitInfo = [[ZCLibInitInfo alloc] init];
//        _libInitInfo.app_key = @"ae6fb3c9b22340f198aebf7f7f82b736";
        _apiHost = @"https://test.sobot.com";
        _libInitInfo.app_key = @"a94733365df440ebb8e124a77d098540";
        _libInitInfo.partnerid = @"001";
        
        
//        _apiHost = @"https://api.sobot.com";
//        _libInitInfo.app_key = @"e550c6e4250c4ab490f290c6d7cb5ac2";
//        _libInitInfo.partnerid = @"xinyao123456";
        
//        _libInitInfo.isVip = @"1";
//        _libInitInfo.user_label = @"565169198700853";
//        _libInitInfo.vip_level = @"0f7a494ca8af435bb7906b15890b4365";
        
    }

    _libInitInfo.robot_alias = @"robot_alias1";
//    _libInitInfo.default_language = @"zh-Hans_lproj";
//    _libInitInfo.absolute_language = @"zh-Hans_lproj";
    
    NSString *mulDict1 = [[NSUserDefaults standardUserDefaults] objectForKey:@"defaultInitInfo"];
    NSString *mulDict2 = [[NSUserDefaults standardUserDefaults] objectForKey:@"defaultKitInfo"];
    if(mulDict1){
//        [self saveMessageToEntity:mulDict1];
    }
    if(mulDict2){
//        [self saveMessageToEntity:mulDict2];
    }
}


// 获取当前设置对象的json字符串
-(NSString *)getJsonStringByTooldsByKeys:(NSArray *)keys{
    
    NSDictionary *dict1 = [EntityConvertUtils entityConvertToDict:_libInitInfo];
    NSDictionary *dict2 = [EntityConvertUtils entityConvertToDict:_kitInfo];
    
    NSMutableDictionary *mulDict = [[NSMutableDictionary alloc] init];
    for (NSString *key in keys) {
        if(dict1[key]!=nil){
            [mulDict setObject:dict1[key] forKey:key];
        }
        if(dict2[key]!=nil){
            [mulDict setObject:dict2[key] forKey:key];
        }
        
//  电商 platformUnionCode 单独处理
        if([key isEqualToString:@"platformUnionCode"]){
            
            if ([ZCLibClient getZCLibClient].platformUnionCode.length > 0) {
                [mulDict setObject:[ZCLibClient getZCLibClient].platformUnionCode forKey:key];
            }else{
                [mulDict setObject:@"" forKey:key];
            }
        }
    }
    [mulDict setObject:_apiHost forKey:@"api_host"];
    return [EntityConvertUtils DataTOjsonString:mulDict];
}



/// 保存页面的json数据到对象中
/// @param jsonString
-(void)saveMessageToEntity:(NSString *)jsonString{
    NSDictionary *dict = [EntityConvertUtils dictionaryWithJsonString:jsonString];
    
    if(dict){
        NSMutableDictionary *mulDict = [[NSMutableDictionary alloc] init];
        for (NSString *key in dict.allKeys) {
            if([@"api_host" isEqual:key]){
                _apiHost = dict[key];
            }else if([@"isDebugMode" isEqual:key]){
                [ZCLibClient getZCLibClient].isDebugMode = [convertToString(dict[key]) boolValue];
            }else if([@"autoNotification" isEqual:key]){
                [ZCLibClient getZCLibClient].autoNotification = [convertToString(dict[key]) boolValue];
            }else if([@"platformUnionCode" isEqual:key]){
                [ZCLibClient getZCLibClient].platformUnionCode = dict[key];
            }else if([key containsString:@"Color"]){
                if(dict[key]!=[NSNull null] && [dict[key] containsString:@"#"]){

                    [mulDict setObject:[EntityConvertUtils colorWithHexString:dict[key]] forKey:key];
                }
            }else if([key containsString:@"Font"]){
                if([dict[key] isKindOfClass:[NSNumber class]]){
                    [mulDict setObject:[UIFont fontWithName:@"Helvetica" size:[dict[key] floatValue]] forKey:key];
                }else if(dict[key]==[NSNull null]){
                    // 不赋值
//                    [mulDict setObject:[NSNull null] forKey:key];
                }else if([dict[key] containsString:@"=>"]){
                    NSArray *fontValue = [dict[key] componentsSeparatedByString:@"=>"];
                    [mulDict setObject: [UIFont fontWithName:@"Helvetica" size:[fontValue[1] floatValue]] forKey:key];
                }
            }else{
                 [mulDict setObject:dict[key] forKey:key];
            }
            
            
        }
        _libInitInfo = [_libInitInfo initByJsonDict:mulDict];
        [EntityConvertUtils initByJsonDict:mulDict obj:_kitInfo];
        
        

        NSDictionary *dict1 = [EntityConvertUtils entityConvertToDict:_libInitInfo];
        NSDictionary *dict2 = [EntityConvertUtils entityConvertToDict:_kitInfo];

        [[NSUserDefaults standardUserDefaults] setObject:[EntityConvertUtils DataTOjsonString:dict1] forKey:@"defaultInitInfo"];
        [[NSUserDefaults standardUserDefaults] setObject:[EntityConvertUtils DataTOjsonString:dict2] forKey:@"defaultKitInfo"];
        
    }
}



/// 对象转字典
/// @param entity
+(NSDictionary *)entityConvertToDict:(id) entity
{
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    unsigned int propsCount;
    objc_property_t *props = class_copyPropertyList([entity class], &propsCount);//获得属性列表
    for(int i = 0;i < propsCount; i++)
    {

        objc_property_t prop = props[i];

        NSString *propName = [NSString stringWithUTF8String:property_getName(prop)];//获得属性的名称

        id value = [entity valueForKey:propName];//kvc读值

        if(value == nil)
        {
            value = [NSNull null];
        }
        else
        {
            value = [self getObjectInternal:value];//自定义处理数组，字典，其他类
        }

        [dic setObject:value forKey:propName];
    }
    
    free(props);
    return dic;
}


+ (id)getObjectInternal:(id)obj
{
    if([obj isKindOfClass:[NSString class]]
       || [obj isKindOfClass:[NSNumber class]]
       || [obj isKindOfClass:[NSNull class]])
    {
        return obj;
    }
    
    if([obj isKindOfClass:[UIColor class]]){
        return  [self hexStringFromColor:((UIColor *)obj)];
    }
    if([obj isKindOfClass:[UIFont class]]){
       return  [NSString stringWithFormat:@"%@=>%.1f",((UIFont *)obj).fontName,((UIFont *)obj).pointSize];
    }

    if([obj isKindOfClass:[NSArray class]])
    {

        NSArray *objarr = obj;

        NSMutableArray *arr = [NSMutableArray arrayWithCapacity:objarr.count];

        for(int i = 0;i < objarr.count; i++)

        {

            [arr setObject:[self getObjectInternal:[objarr objectAtIndex:i]] atIndexedSubscript:i];

        }

        return arr;

    }

    

    if([obj isKindOfClass:[NSDictionary class]])
    {

        NSDictionary *objdic = obj;

        NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithCapacity:[objdic count]];

        for(NSString *key in objdic.allKeys)

        {

            [dic setObject:[self getObjectInternal:[objdic objectForKey:key]] forKey:key];

        }

        return dic;

    }

    return [self entityConvertToDict:obj];

}

// UIColor转#ffffff格式的字符串
+ (NSString *)hexStringFromColor:(UIColor *)color {
    if(color==nil){
        return @"";
    }
    const CGFloat *components = CGColorGetComponents(color.CGColor);

    CGFloat r = components[0];
    CGFloat g = components[1];
    CGFloat b = components[2];

    return [NSString stringWithFormat:@"#%02lX%02lX%02lX",
            lroundf(r * 255),
            lroundf(g * 255),
            lroundf(b * 255)];
}


+ (UIColor *) colorWithHexString: (NSString *) hexString {
    NSString *colorString = [[hexString stringByReplacingOccurrencesOfString: @"#" withString: @""] uppercaseString];
    CGFloat alpha, red, blue, green;
    switch ([colorString length]) {
        case 3: // #RGB
            alpha = 1.0f;
            red   = [self colorComponentFrom: colorString start: 0 length: 1];
            green = [self colorComponentFrom: colorString start: 1 length: 1];
            blue  = [self colorComponentFrom: colorString start: 2 length: 1];
            break;
        case 4: // #ARGB
            alpha = [self colorComponentFrom: colorString start: 0 length: 1];
            red   = [self colorComponentFrom: colorString start: 1 length: 1];
            green = [self colorComponentFrom: colorString start: 2 length: 1];
            blue  = [self colorComponentFrom: colorString start: 3 length: 1];
            break;
        case 6: // #RRGGBB
            alpha = 1.0f;
            red   = [self colorComponentFrom: colorString start: 0 length: 2];
            green = [self colorComponentFrom: colorString start: 2 length: 2];
            blue  = [self colorComponentFrom: colorString start: 4 length: 2];
            break;
        case 8: // #AARRGGBB
            alpha = [self colorComponentFrom: colorString start: 0 length: 2];
            red   = [self colorComponentFrom: colorString start: 2 length: 2];
            green = [self colorComponentFrom: colorString start: 4 length: 2];
            blue  = [self colorComponentFrom: colorString start: 6 length: 2];
            break;
        default:
            return nil;
    }
    return [UIColor colorWithRed: red green: green blue: blue alpha: alpha];
}

+ (CGFloat) colorComponentFrom: (NSString *) string start: (NSUInteger) start length: (NSUInteger) length {
    NSString *substring = [string substringWithRange: NSMakeRange(start, length)];
    NSString *fullHex = length == 2 ? substring : [NSString stringWithFormat: @"%@%@", substring, substring];
    unsigned hexComponent;
    [[NSScanner scannerWithString: fullHex] scanHexInt: &hexComponent];
    return hexComponent / 255.0;
}



+ (NSDictionary *)dictionaryWithJsonString:(NSString *)jsonString{
    if (jsonString == nil) {
        return nil;
    }
    NSDictionary *dic = nil;
    @try {
        NSData *jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
        NSError *err;
        dic = [NSJSONSerialization JSONObjectWithData:jsonData
                                        options:NSJSONReadingMutableContainers
                                          error:&err];
        
        if(err) {
            NSLog(@"json解析失败：%@",err);
            
            return nil;
        }
    } @catch (NSException *exception) {
        
    } @finally {
        
    }
    
    return dic;
}


+(NSString*)DataTOjsonString:(id)object
{
    NSString *jsonString = @"";

    @try {
        
        NSError *error;

        if ([NSJSONSerialization isValidJSONObject:object]) {
           
//            NSData *jsonData = [NSJSONSerialization dataWithJSONObject:object
//                                                               options:0 // Pass 0 if you don't care about the readability of the generated string
//                                                                 error:&error];
            NSData *jsonData = [NSJSONSerialization dataWithJSONObject:object
                                                               options:NSJSONWritingPrettyPrinted // Pass 0 if you don't care about the readability of the generated string
                                                                 error:&error];
            if (! jsonData) {
                NSLog(@"Got an error: %@", error);
            } else {
                jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
            }
        }
    } @catch (NSException *exception) {
        NSLog(@"Got an error: %@", exception);
    } @finally {
        
    }
    return jsonString;
}



+(void)initByJsonDict:(NSDictionary *)dict obj:(id) object{
    @try {
        for (NSString *key in [EntityConvertUtils properties:object]) {
            if (dict[key]) {
                if(dict[key] != nil){
                    [object setValue:dict[key] forKey:key];
                }
            }
        }
    }
    @catch (NSException *exception) {
        
    }
    @finally {
        
    }
}


+ (NSArray *)properties:(id) obj
{
    unsigned int outCount = 0;
    objc_property_t *properties = class_copyPropertyList([obj class], &outCount);
    
    NSMutableArray *arrayM = [NSMutableArray arrayWithCapacity:outCount];
    for (int i = 0; i < outCount; i++) {
        objc_property_t property = properties[i];
        const char *name = property_getName(property);
        [arrayM addObject:[NSString stringWithUTF8String:name]];
    }
    free(properties);
    
    return arrayM;
}

NSString *convertToString(id object){
    if ([object isKindOfClass:[NSNull class]]) {
        return @"";
    }else if(!object){
        return @"";
    }else if([object isKindOfClass:[NSNumber class]]) {
        return [object stringValue];
    }else{
        return [NSString stringWithFormat:@"%@",object];
    }
}

@end
