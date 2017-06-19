//
//  LoginVC.m
//  书斋
//
//  Created by 飞 on 2017/6/8.
//  Copyright © 2017年 Sam. All rights reserved.
//

#import "LoginVC.h"
#import "RegistVC.h"
#import "HomeVC.h"
#import "OrderVC.h"
#import "MeVC.h"

#import "AppDelegate.h"

#import "IPConfig.h"

@interface LoginVC ()

{
    //登录的方法的相关网络方面的请求和连接信息
    NSURLConnection *_connection;
    NSMutableData *_data;
    NSString *_ipAndHost;
    NSString *_request;
}

//和登录有关的相关表单的相关属性
@property (strong, nonatomic) IBOutlet UITextField *tfUserName;
@property (strong, nonatomic) IBOutlet UITextField *tfPassword;
@property (strong, nonatomic) IBOutlet UIButton *loginBtn;
@property (strong, nonatomic) IBOutlet UIButton *registBtn;

@end

@implementation LoginVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    //键盘收回
    self.view.userInteractionEnabled = YES;
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(fingetTap:)];
    [self.view addGestureRecognizer:singleTap];
    
    _tfUserName.clearButtonMode = UITextFieldViewModeWhileEditing;
    _tfUserName.layer.borderColor = [[UIColor colorWithRed:253.0/255.0 green:109.0/255.0 blue:9.0/255.0 alpha:1] CGColor];
    _tfUserName.layer.borderWidth = 1;
    
    _tfPassword.clearButtonMode = UITextFieldViewModeWhileEditing;
    _tfPassword.layer.borderWidth = 1;
    _tfPassword.layer.borderColor = [[UIColor colorWithRed:253.0/255.0 green:109.0/255.0 blue:9.0/255.0 alpha:1] CGColor];
    
    //登录按钮
    [_loginBtn addTarget:self action:@selector(pressToJudgeUserNameAndPassword) forControlEvents:UIControlEventTouchUpInside];
    
    //注册按钮
    [_registBtn addTarget:self action:@selector(pressToRegistVC) forControlEvents:UIControlEventTouchUpInside];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//键盘收回
-(void) fingetTap:(UITapGestureRecognizer *)gestureRecognizer{
    [self.view endEditing:YES];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

//推进注册的模态视图
-(void) pressToRegistVC {
    RegistVC *registVC = [[RegistVC alloc] init];
    [self presentViewController:registVC animated:YES completion:nil];
}


-(void) pressToJudgeUserNameAndPassword {
    if (_tfUserName.text.length == 0) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"警告" message:@"用户名不能为空" delegate:self cancelButtonTitle:@"好" otherButtonTitles: nil];
        [alertView show];
    } else {
        if (_tfPassword.text.length == 0) {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"警告" message:@"密码不能为空" delegate:self cancelButtonTitle:@"好" otherButtonTitles: nil];
            [alertView show];
        } else {
            [self connectionWithURLToLogin];
        }
    }
}


-(void) connectionWithURLToLogin{
    NSLog(@"方法被调用");
    
    _ipAndHost = Init_IP;
    _request = [NSString stringWithFormat:@"login.html?userName=%@&password=%@", _tfUserName.text, _tfPassword.text];
    
    _request = [_request stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    
    NSString *strURL = [NSString stringWithFormat:@"%@/%@", _ipAndHost, _request];
    NSURL *url = [NSURL URLWithString:strURL];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    _connection = [NSURLConnection connectionWithRequest:request delegate:self];
    _data = [[NSMutableData alloc] init];
}


-(void) connection:(NSURLConnection *)connection didFailWithError:(NSError *)error{
    NSLog(@"错误发生，为%@错误",error);
}


-(void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response{
    NSHTTPURLResponse *res = (NSHTTPURLResponse *)response;
    
    if (res.statusCode == 200) {
        NSLog(@"连接服务器正常");
    } else if (res.statusCode == 404){
        NSLog(@"页面未找到");
    } else if (res.statusCode == 500) {
        NSLog(@"服务器崩溃");
    }
}


-(void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data{
    [_data appendData:data];
}


-(void)connectionDidFinishLoading:(NSURLConnection *)connection{
    NSString *str = [[NSString alloc] initWithData:_data encoding:NSUTF8StringEncoding];
    //NSLog(@"%@",str);
    [self isLoginRight:str];
}

//检查是否登录正确，如果正确，将信息保存到NSUserDefaults中
-(void) isLoginRight:(NSString *)strLoginStatus{
    if ([strLoginStatus isEqualToString:@"1"]) {
        NSLog(@"登录成功！");
        
        [_tfUserName resignFirstResponder];
        [_tfPassword resignFirstResponder];
        
        [self saveToNSUserDefault];
    } else {
        //NSLog(@"登录失败！");
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"警告" message:@"用户名或密码错误！登录失败！" delegate:self cancelButtonTitle:@"好" otherButtonTitles: nil];
        [alertView show];
    }
}

//将用户信息保存到NSUserDefaults，并且跳转到初始视图中
-(void)saveToNSUserDefault{
    NSString *userName = _tfUserName.text;
    NSString *password = _tfPassword.text;
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:userName forKey:@"userName"];
    [userDefaults setObject:password forKey:@"password"];
    [userDefaults synchronize];
    
    //创建三个试图对象
    HomeVC *homeVC = [[HomeVC alloc] init];
    homeVC.title = @"首页";
    homeVC.tabBarItem.image = [UIImage imageNamed:@"homeTabItem.png"];
    UINavigationController *homeNav = [[UINavigationController alloc] initWithRootViewController:homeVC];
    
    OrderVC *orderVC = [[OrderVC alloc] init];
    orderVC.title = @"订单";
    orderVC.tabBarItem.image = [UIImage imageNamed:@"orderTabItem.png"];
    UINavigationController *orderNav = [[UINavigationController alloc] initWithRootViewController:orderVC];
    
    MeVC *meVC = [[MeVC alloc] init];
    meVC.title = @"我";
    meVC.tabBarItem.image = [UIImage imageNamed:@"meTabItem.png"];
    UINavigationController *meNav = [[UINavigationController alloc] initWithRootViewController:meVC];
    
    NSArray *tabArray = [NSArray arrayWithObjects:homeNav, orderNav, meNav, nil];
    UITabBarController *tabBar = [[UITabBarController alloc] init];
    tabBar.tabBar.tintColor = [UIColor colorWithRed:253.0/255.0 green:109.0/255.0 blue:9.0/255.0 alpha:1];
    tabBar.viewControllers = tabArray;
    
    AppDelegate *appDele = (AppDelegate *)[UIApplication sharedApplication].delegate;
    appDele.window.rootViewController = tabBar;
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
