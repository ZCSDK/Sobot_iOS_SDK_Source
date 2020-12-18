//
//  ZCTestSplitController.m
//  SobotKitFrameworkTest
//
//  Created by zhangxy on 2020/11/16.
//  Copyright © 2020 zhichi. All rights reserved.
//

#import "ZCTestSplitController.h"

#import "ZCGuideHomeController.h"
#import "ZCGuideData.h"
#import "ZCGuideActionController.h"
#import "ZCConfigDetailController.h"

#import "EntityConvertUtils.h"

@interface ZCTestSplitController ()<UISplitViewControllerDelegate>

@property(nonatomic,strong) UISplitViewController *splitView;
@property(nonatomic,strong) UINavigationController *masterViewController;
@property(nonatomic,strong) UINavigationController *detailViewController;

@end

@implementation ZCTestSplitController
-(void)backClick{
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    
    self.navigationController.navigationBarHidden = YES;
    
    
    _splitView = [[UISplitViewController alloc] init];
    _splitView.view.frame = self.view.bounds;
    _splitView.view.backgroundColor = UIColor.whiteColor;
    [self.view addSubview:_splitView.view];
    _splitView.delegate = self;
    
    UIButton *btnBack = [UIButton buttonWithType:UIButtonTypeSystem];
    [btnBack setFrame:CGRectMake(0, NavBarHeight, 64, 44)];
    [btnBack setTitle:@"返回" forState:0];
    [btnBack addTarget:self action:@selector(backClick) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btnBack];
    
    // 设置主视图
    NSArray *arr = [[ZCGuideData getZCGuideData] getSectionListArray:0];
    
    _masterViewController = [[UINavigationController alloc]initWithRootViewController:[[ZCGuideHomeController alloc] init]];
    NSDictionary *item = arr[3];
    ZCSectionIndex code = (ZCSectionIndex)[item[@"index"] integerValue];
    if(code == ZCSectionIndex331 ||
             code == ZCSectionIndex332 ||
             code == ZCSectionIndex341 ||
             code == ZCSectionIndex342 ||
             code == ZCSectionIndex343||
             code == ZCSectionIndex351||
             code == ZCSectionIndex353){
        ZCGuideActionController *vc = [[ZCGuideActionController alloc] init];
        vc.sectionData = item;
        _detailViewController = [[UINavigationController alloc] initWithRootViewController:vc];
//        [self.splitView addChildViewController:nav1];
//        [self.splitView showDetailViewController:nav1 sender:self];
    }else{
        ZCConfigDetailController *vc = [[ZCConfigDetailController alloc] init];
        vc.sectionData = item;
        self.detailViewController = [[UINavigationController alloc] initWithRootViewController:vc];
//        [self.splitView addChildViewController:nav1];
//        [self.splitView showDetailViewController:nav1 sender:self];
        
    }
    //设置分割控制器分割模式
//    self.splitViewController.preferredDisplayMode = UISplitViewControllerDisplayModePrimaryOverlay;
    self.splitView.viewControllers = @[self.masterViewController,self.detailViewController];
    self.splitView.minimumPrimaryColumnWidth = ScreenWidth*0.5;
    [self.splitView setPresentsWithGesture:YES];
    [self.splitView setPreferredDisplayMode:UISplitViewControllerDisplayModeAllVisible];

}

- (BOOL)splitViewController:(UISplitViewController *)sender
   shouldHideViewController:(UIViewController *)master inOrientation:(UIInterfaceOrientation)orientation
{

       return YES; // always hide it

}

//开始时取消二级控制器,只显示详细控制器
//- (BOOL)splitViewController:(UISplitViewController *)splitViewController collapseSecondaryViewController:(UIViewController *)secondaryViewController ontoPrimaryViewController:(UIViewController *)primaryViewController
//{
//    return YES;
//}
    

-(void)splitViewController:(UISplitViewController *)sender  willHideViewController:(UIViewController *)master   withBarButtonItem:(UIBarButtonItem *)barButtonItem  forPopoverController:(UIPopoverController *)popover
{

   //将要隐藏master时，在detail控制器的toolbar上设置并显示一个按钮

    barButtonItem.title = @"Master";
    //master将要隐藏时，给detail设置一个返回按钮
        UINavigationController *Nav = [self.splitViewController.viewControllers lastObject];
    NSLog(@"1111%@",Nav.topViewController);
//        DetailViewController *Detail = (DetailViewController *)[Nav topViewController];
//
//        Detail.navigationItem.leftBarButtonItem = barButtonItem;


}

//主控制器将要显示时触发的方法
-(void)splitViewController:(UISplitViewController *)sender willShowViewController:(UIViewController *)master   invalidatingBarButtonItem:(UIBarButtonItem *)barButtonItem
{

 // removeSplitViewBarButtonItem: must remove the bar button from its toolbar

    //master将要显示时,取消detail的返回按钮
    UINavigationController *Nav = [self.splitViewController.viewControllers lastObject];
    NSLog(@"2222%@",Nav);

}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
