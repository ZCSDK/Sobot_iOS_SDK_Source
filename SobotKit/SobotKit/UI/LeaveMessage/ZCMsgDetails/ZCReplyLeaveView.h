//
//  ZCReplyLeaveView.h
//  SobotKit
//
//  Created by xuhan on 2019/12/4.
//  Copyright © 2019 zhichi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZCUIPlaceHolderTextView.h"

NS_ASSUME_NONNULL_BEGIN

@protocol ZCReplyLeaveViewDelegate <NSObject>
@optional


- (void)replyLeaveViewPreviewImg:(UIButton *)button;

- (void)replyLeaveViewDeleteImg:(NSInteger )buttonIndex;


- (void)replyLeaveViewPickImg:(NSInteger )buttonIndex;

- (void)replySuccess;

- (void)closeWithReplyStr:(NSString *)replyStr;

@end

@interface ZCReplyLeaveView : UIView

-(ZCReplyLeaveView *)initActionSheetWithView:(UIView *)view;

@property (nonatomic, strong) NSMutableArray *imageArr;
@property (nonatomic, strong) NSMutableArray *imagePathArr;
@property (nonatomic, strong) NSString *ticketId;
@property (nonatomic, strong) NSString *replyStr; // 回复内容

@property (nonatomic, strong) ZCUIPlaceHolderTextView *textDesc;

- (void)showInView:(UIView *)view;

- (void)tappedCancel:(BOOL) isClose;

- (void)reloadScrollView;

@property(nonatomic,weak) id<ZCReplyLeaveViewDelegate> delegate;

@end

NS_ASSUME_NONNULL_END
