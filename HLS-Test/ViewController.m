//
//  ViewController.m
//  HLS-Test
//
//  Created by 超杨 on 16/1/27.
//  Copyright © 2016年 杨超. All rights reserved.
//

#import "ViewController.h"
#import "YCHLSDemoViewController.h"
#define myKey @"mykey"

@interface ViewController ()<UIAlertViewDelegate>

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
//    [userDefault setInteger:123 forKey:myKey];
    [userDefault setBool:YES forKey:myKey];
    [userDefault synchronize];
    NSLog(@"%@", [userDefault objectForKey:myKey]);
    NSLog(@"%@", [[userDefault objectForKey:myKey] class]);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 0) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"" message:@"请输入HLS直播url" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
        alertView.tag = 900;
        alertView.alertViewStyle = UIAlertViewStylePlainTextInput;
        UITextField *textFiled = [alertView textFieldAtIndex:0];
        textFiled.text = @"http://pl.youku.com/playlist/m3u8?ts=1460190028&keyframe=0&pid=6b5f94f4ab33c702&vid=XNzgxMTQyMzIw&type=hd2&r=/3sLngL0Q6CXymAIiF9JUQQtnOFNJPUClO8A56KJJcT8UB+NRAMQ09zE6rNj4EKMxAvRByWf6hitgv75Fv0ffeukHu0/cHPmEJbqRoQB5wVU/l3ZcBOSsxUf7QaPO6gDptAU4mTDRr+dVJThYEJUnhDylfynOikSdSxEqBFdeDY7+0iOLRI4iPtRlKx5jngj&ypremium=1&oip=1992409311&token=5701&sid=74601900286162054962a&did=1460189987&ev=1&ctype=20&ep=0nFhXc%2B6QqgNpi46UejQ2JQw5hPsb0UdjjMSGiBdsIV9nwiIZRIiNvonOZh89iYe";
        textFiled.clearButtonMode = UITextFieldViewModeAlways;
        [alertView show];
        
    }
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (alertView.tag == 900) {
        if (buttonIndex == 1) {
            UIStoryboard *board = [UIStoryboard storyboardWithName:NSStringFromClass([YCHLSDemoViewController class]) bundle:nil];
            YCHLSDemoViewController *vc = [board instantiateViewControllerWithIdentifier:@"HLSPlay"];
            vc.URLString = [alertView textFieldAtIndex:0].text;
            [self.navigationController pushViewController:vc animated:YES];
        }
    }
}

@end
