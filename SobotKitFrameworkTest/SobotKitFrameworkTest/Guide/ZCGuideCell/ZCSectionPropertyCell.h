//
//  ZCSectionPropertyCell.h
//  SobotKitFrameworkTest
//
//  Created by zhangxy on 2020/7/23.
//  Copyright © 2020 zhichi. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface ZCSectionPropertyCell : UITableViewCell

@property (strong, nonatomic) UILabel *titleLab;
@property (strong, nonatomic) UILabel *detailLab;
@property (strong, nonatomic) UIImageView *img;


-(void)initWithNSDictionary:(NSDictionary*)dict;

@end

NS_ASSUME_NONNULL_END
