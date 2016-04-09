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
        textFiled.text = @"http://devstreaming.apple.com/videos/wwdc/2015/413eflf3lrh1tyo/413/0640/0640.m3u8";
        textFiled.text = @"http://pl.youku.com/playlist/m3u8?ts=1460191031&keyframe=0&pid=6b5f94f4ab33c702&vid=XMjMzODM2MzU2&type=flv&r=/3sLngL0Q6CXymAIiF9JUQQtnOFNJPUClO8A56KJJcT8UB+NRAMQ09zE6rNj4EKMxAvRByWf6hitgv75Fv0ffY93XIyfsDxfTMrXhf93HpxU/l3ZcBOSsxUf7QaPO6gDptAU4mTDRr+dVJThYEJUnp5SDxM2fe5A70JG4d4z6AkQBQVlgFj+eIQgEoBHz2Fh&ypremium=1&oip=1992409311&token=9685&sid=4460191031966202a202d&did=1460190991&ev=1&ctype=20&ep=WolyplIdeJ0IjpH0p6nyXMzuiRFepTej4GnJddjesh%2BJCNyYqhFVGVTF4J2XXzwZ";
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
