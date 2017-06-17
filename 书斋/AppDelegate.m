//
//  AppDelegate.m
//  书斋
//
//  Created by 飞 on 2017/6/8.
//  Copyright © 2017年 Sam. All rights reserved.
//

#import "AppDelegate.h"
//导入登录视图控制器
#import "LoginVC.h"
//导入首页视图控制器
#import "HomeVC.h"
//导入订单视图控制器
#import "OrderVC.h"
//导入我视图控制器
#import "MeVC.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    
    //判断是否已经登录了
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    //如果登录了，那么就直接进入首页视图控制器
    if ([userDefaults objectForKey:@"userName"]) {
        //创建三个试图对象
        //首页视图控制器
        HomeVC *homeVC = [[HomeVC alloc] init];
        homeVC.title = @"首页";
        homeVC.tabBarItem.image = [UIImage imageNamed:@"homeTabItem.png"];
        UINavigationController *homeNav = [[UINavigationController alloc] initWithRootViewController:homeVC];
        
        //订单视图控制器
        OrderVC *orderVC = [[OrderVC alloc] init];
        orderVC.title = @"订单";
        orderVC.tabBarItem.image = [UIImage imageNamed:@"orderTabItem.png"];
        UINavigationController *orderNav = [[UINavigationController alloc] initWithRootViewController:orderVC];
        
        //我视图控制器
        MeVC *meVC = [[MeVC alloc] init];
        meVC.title = @"我";
        meVC.tabBarItem.image = [UIImage imageNamed:@"meTabItem.png"];
        UINavigationController *meNav = [[UINavigationController alloc] initWithRootViewController:meVC];
        
        //tabBar的视图控制器数组
        NSArray *tabArray = [NSArray arrayWithObjects:homeNav, orderNav, meNav, nil];
        UITabBarController *tabBar = [[UITabBarController alloc] init];
        tabBar.tabBar.tintColor = [UIColor colorWithRed:253.0/255.0 green:109.0/255.0 blue:9.0/255.0 alpha:1];
        tabBar.viewControllers = tabArray;
        
        //设置根视图控制器
        self.window.rootViewController = tabBar;
    } else {
        //如果没有登录，就跳转到登录界面
        LoginVC *loginVC = [[LoginVC alloc] init];
        self.window.rootViewController = loginVC;
    }
    
    [self.window makeKeyAndVisible];
    
    return YES;
}


- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}


@end
