//
//  ZCConfigBaseCell.h
//  SobotKitFrameworkTest
//
//  Created by zhangxy on 2020/7/16.
//  Copyright © 2020 zhichi. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol ZCConfigBaseCellDelegate <NSObject>

-(void)itemChangedCellOnClick:(NSString *) value dict:(NSDictionary *) dict indexPath:(NSIndexPath *)indexPath;

-(void)didKeyboardWillShow:(NSIndexPath *)indexPath view1:(UITextView *)textview view2:(UITextField *) textField;

@end

@interface ZCConfigBaseCell : UITableViewCell

@property(nonatomic,weak) NSIndexPath  *indexPath;
@property(nonatomic,strong) NSDictionary *tempDict;
@property(nonatomic,weak) id<ZCConfigBaseCellDelegate> delegate;
/**
 *  名称
 */
@property (nonatomic,strong) UILabel        *labTitle;
@property (nonatomic,strong) UILabel        *labDesc;
@property (nonatomic,strong) UITextField     *fieldContent;
@property (nonatomic,strong) UITextView     *textContent;
@property (nonatomic,strong) UISwitch       *switchControl;
@property (nonatomic,strong) UIImageView        *imgArrow;

-(void)dataToView:(NSDictionary *)item;
@end

NS_ASSUME_NONNULL_END
