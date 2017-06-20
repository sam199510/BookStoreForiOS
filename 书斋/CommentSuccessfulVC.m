//
//  CommentSuccessfulVC.m
//  书斋
//
//  Created by 飞 on 2017/6/17.
//  Copyright © 2017年 Sam. All rights reserved.
//

#import "CommentSuccessfulVC.h"

//评论成功视图
@interface CommentSuccessfulVC ()

@end

@implementation CommentSuccessfulVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.title = @"购买完成";
    [self.navigationController.navigationBar setTintColor:[UIColor whiteColor]];
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor whiteColor]}];
    self.navigationController.navigationBar.translucent = NO;
    
    //为导航栏添加完成按钮
    UIBarButtonItem *leftBtnOfNavgation = [[UIBarButtonItem alloc] initWithTitle:@"完成" style:UIBarButtonItemStylePlain target:self action:@selector(backToTopView)];
    self.navigationItem.leftBarButtonItem = leftBtnOfNavgation;
    
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

//返回根视图
-(void) backToTopView{
    [self.navigationController popToRootViewControllerAnimated:YES];
}

@end
