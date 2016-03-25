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

@interface ViewController ()

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
        UIStoryboard *board = [UIStoryboard storyboardWithName:NSStringFromClass([YCHLSDemoViewController class]) bundle:nil];
        YCHLSDemoViewController *vc = [board instantiateViewControllerWithIdentifier:@"HLSPlay"];
        [self.navigationController pushViewController:vc animated:YES];
    }
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}
@end
