//
//  ZCServiceCategoryListModel.h
//  SobotKit
//
//  Created by lizhihui on 2019/4/2.
//  Copyright © 2019 zhichi. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN


/// 帮助中心分类模型
@interface ZCSCListModel : NSObject

//分类id
@property (nonatomic,copy) NSString * categoryId;
@property (nonatomic,copy) NSString * appId;
//分类名称
@property (nonatomic,copy) NSString * categoryName;
//分类描述
@property (nonatomic,copy) NSString * categoryDetail;
///分类图片
@property (nonatomic,copy) NSString * categoryUrl;
//排序
@property (nonatomic,assign) int sortNo;


@property (nonatomic,copy) NSString * companyId;
//词条id
@property (nonatomic,copy) NSString * docId;
//问题id
@property (nonatomic,copy) NSString * questionId;
//问题标题
@property (nonatomic,copy) NSString * questionTitle;
//答案 富文本
@property (nonatomic,copy) NSString * answerDesc;


-(id)initWithMyDict:(NSDictionary *)dict;

@end

NS_ASSUME_NONNULL_END
