//
//  ViewController.m
//  HLS-Test
//
//  Created by 超杨 on 16/1/27.
//  Copyright © 2016年 杨超. All rights reserved.
//

#import "ViewController.h"
#import "YCHLSDemoViewController.h"

@interface ViewController ()<UIAlertViewDelegate>

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
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
        textFiled.text = @"http://yangchao0033.github.io/hlsSegement/0640.m3u8";
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
