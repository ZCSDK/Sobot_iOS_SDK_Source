//
//  ZCLibOrderCusFieldsModel.h
//  SobotKit
//
//  Created by lu on 2017/9/12.
//  Copyright © 2017年 zhichi. All rights reserved.
//

#import <Foundation/Foundation.h>




@interface ZCLibOrderCusFieldsModel : NSObject
//"companyId":"d2f208880c1b4bbb8a451dff2b23497a",
//"createId":"face61ea2f9a4be5862cec74e4fdc6e3",
//"createTime":1500541754,
//"fieldId":"c62a18944c3246578ea1dd2905535c5d",
//"fieldName":"多行文本测试1-1",
//"fieldRemark":"",
//"fieldStatus":1,
//"fieldType":2,
//"fieldVariable":"customField1",
//"fillFlag":1,
//"openFlag":1,
//"operateType":3,
//"sortNo":1,
//"updateId":"face61ea2f9a4be5862cec74e4fdc6e3",
//"updateTime":1505207627,
//"workShowFlag":1,
//"workSortNo":1


@property (nonatomic,copy) NSString *fieldName;

@property (nonatomic,copy) NSString *fieldId;

@property (nonatomic,copy) NSString *fieldType;

@property (nonatomic,copy) NSString *fillFlag;// 是否必填项 1 必填 0 可以不填

@property (nonatomic,copy) NSString * openFlag;

@property (nonatomic,copy) NSString * queryFlag; // 是否支持搜索
@property (nonatomic,copy) NSString * queryShowFlag;

@property (nonatomic,copy) NSString *fieldRemark;// 备注 占位文字使用

@property (nonatomic,copy) NSString * fieldValue;// 自定义字段值

@property (nonatomic,strong) NSMutableArray * detailArray;// 多选，单选 下拉列表 的数据

@property (nonatomic,strong) NSString * fieldSaveValue;// 存储当前自定义字段填写的值

//限制方式  1禁止输入空格   2 禁止输入小数点  3 小数点后只允许2位  4 禁止输入特殊字符  5只允许输入数字 6最多允许输入字符  7判断邮箱格式  8判断手机格式
@property (nonatomic,strong) NSArray * limitOptions;

@property (nonatomic,strong) NSString * limitChar;//允许输入字符数



-(id)initWithMyDict:(NSDictionary *)dict;
@end


@interface ZCLibOrderCusFieldsDetailModel :NSObject

@property (nonatomic,copy) NSString *dataId;
@property (nonatomic,copy) NSString *dataName; // 分类名称
@property (nonatomic,copy) NSString *fieldId; // 分类的ID
@property (nonatomic,copy) NSString *dataValue;
@property (nonatomic,assign) BOOL isChecked;// 是否选中

-(id)initWithMyDict:(NSDictionary *)dict;
@end
