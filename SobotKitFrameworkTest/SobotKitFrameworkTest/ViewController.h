//
//  ViewController.h
//  SobotKitFrameworkTest
//
//  Created by zhangxy on 15/11/21.
//  Copyright © 2015年 zhichi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseNavViewController.h"

@interface ViewController : UIViewController

@property (weak, nonatomic) IBOutlet UIScrollView *bgScrollView;


@property (weak, nonatomic) IBOutlet UITextField *appKeyTF;

@property (weak, nonatomic) IBOutlet UITextField *hostTF;

@property (weak, nonatomic) IBOutlet UISwitch *hostSwitch;

@property (weak, nonatomic) IBOutlet UITextField *userIdTF;

@property (weak, nonatomic) IBOutlet UIButton *addUserInfoBtn;

@property (weak, nonatomic) IBOutlet UITextField *groupIdTF;

@property (weak, nonatomic) IBOutlet UITextField *groupNameTF;

@property (weak, nonatomic) IBOutlet UISwitch *robotPreferredSwitch;

@property (weak, nonatomic) IBOutlet UISwitch *onlyServiceSwitch;

@property (weak, nonatomic) IBOutlet UISwitch *artificialPrioritySwitch;

@property (weak, nonatomic) IBOutlet UISwitch *onlyRobotSwitch;

@property (weak, nonatomic) IBOutlet UISwitch *isShowGoodsSwitch;

@property (weak, nonatomic) IBOutlet UITextField *goodTagTF;

@property (weak, nonatomic) IBOutlet UITextField *goodsSendTF;

@property (weak, nonatomic) IBOutlet UITextField *goodsTitleTF;

@property (weak, nonatomic) IBOutlet UITextField *goodsImgTF;

@property (weak, nonatomic) IBOutlet UITextField *goodsSummaryTF;

@property (weak, nonatomic) IBOutlet UITextField *aidTF;

@property (weak, nonatomic) IBOutlet UISwitch *isAidSwitch;

@property (weak, nonatomic) IBOutlet UITextField *robotIdTF;

@property (weak, nonatomic) IBOutlet UISwitch *titleDefaultSwitch;

@property (weak, nonatomic) IBOutlet UISwitch *titleEnterpriseSwitch;

@property (weak, nonatomic) IBOutlet UISwitch *titleCustomSwitch;

@property (weak, nonatomic) IBOutlet UITextField *titleCustomTF;

@property (weak, nonatomic) IBOutlet UISwitch *isOpenVideoSwitch;

@property (weak, nonatomic) IBOutlet UISwitch *isShowTansferSwitch;

@property (weak, nonatomic) IBOutlet UISwitch *isBackSwitch;

@property (weak, nonatomic) IBOutlet UISwitch *isCloseSessionWhenBackSwitch;


@property (weak, nonatomic) IBOutlet UISwitch *isShowNickSwitch;

@property (weak, nonatomic) IBOutlet UISwitch *isAddNickSwitch;


@property (weak, nonatomic) IBOutlet UITextField *historyScopeTF;

@property (weak, nonatomic) IBOutlet UISwitch *isAutoRemindSwitch;

@property (weak, nonatomic) IBOutlet UILabel *offLineMsgCount;
@property (weak, nonatomic) IBOutlet UIButton *openOffLineMsgBtn;

@property (weak, nonatomic) IBOutlet UIButton *closePushBtn;

@property (weak, nonatomic) IBOutlet UILabel *unReadMsgCount;

@property (weak, nonatomic) IBOutlet UITextField *robotUnknowCount;

@property (weak, nonatomic) IBOutlet UIButton *closeSessionButton;

@property (weak, nonatomic) IBOutlet UITextField *customRobotHelloWord;

@property (weak, nonatomic) IBOutlet UITextField *customAdminHelloWord;

@property (weak, nonatomic) IBOutlet UITextField *customAdminNonelineTitle;

@property (weak, nonatomic) IBOutlet UITextField *customUserTipWord;

@property (weak, nonatomic) IBOutlet UITextField *customAdminTipWord;

@property (weak, nonatomic) IBOutlet UITextField *customUserOutWord;

@property (weak, nonatomic) IBOutlet UISwitch *isOpenLeaveMsgSwitch;

@property (weak, nonatomic) IBOutlet UISwitch *isOpenTurnSwitch;

@property (weak, nonatomic) IBOutlet UITextField *turnKeyWord;

@end

