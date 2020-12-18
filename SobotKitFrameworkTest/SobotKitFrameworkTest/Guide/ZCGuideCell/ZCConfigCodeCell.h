//
//  ZCConfigCodeCell.h
//  SobotKitFrameworkTest
//
//  Created by zhangxy on 2020/7/28.
//  Copyright © 2020 zhichi. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol ZCConfigCodeDelegate <NSObject>

-(void)openURLString:(NSString *) url;

@end

@interface ZCConfigCodeCell : UITableViewCell

@property(nonatomic,weak) id<ZCConfigCodeDelegate> delegate;

/**
 *  名称
 */
@property (nonatomic,strong) UILabel        *labTitle;
@property (nonatomic,strong) UILabel        *labTitle2;
@property (nonatomic,strong) NSArray        *tempData;

-(void)dataToView:(NSArray *)codeData;

@end

NS_ASSUME_NONNULL_END
