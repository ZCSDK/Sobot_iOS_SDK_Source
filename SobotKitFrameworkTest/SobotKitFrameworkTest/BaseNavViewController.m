//
//  BaseNavViewController.m
//  SobotKitFrameworkTest
//
//  Created by zhangxy on 16/3/31.
//  Copyright © 2016年 zhichi. All rights reserved.
//

#import "BaseNavViewController.h"

@interface BaseNavViewController ()

@end

@implementation BaseNavViewController
//- (BOOL)shouldAutorotate
//{
//    return [self.viewControllers.lastObject shouldAutorotate];
//}
//
//- (UIInterfaceOrientationMask)supportedInterfaceOrientations
//{
//    return [self.viewControllers.lastObject supportedInterfaceOrientations];
//}
//
//- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation
//{
//    
//    return [self.viewControllers.lastObject preferredInterfaceOrientationForPresentation];
//}

-(BOOL)shouldAutorotate{
    return [self.topViewController shouldAutorotate];
}
//支持的方向
- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return [self.topViewController supportedInterfaceOrientations];;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
