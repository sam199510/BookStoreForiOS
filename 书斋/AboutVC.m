//
//  AboutVC.m
//  书斋
//
//  Created by 飞 on 2017/6/10.
//  Copyright © 2017年 Sam. All rights reserved.
//

#import "AboutVC.h"

@interface AboutVC ()

@property (strong, nonatomic) IBOutlet UIImageView *iVAboutImage;
@property (strong, nonatomic) IBOutlet UILabel *lbAppName;
@property (strong, nonatomic) IBOutlet UILabel *lbVersion;
@property (strong, nonatomic) IBOutlet UILabel *lbBuild;

@end

@implementation AboutVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.title = @"关于";
    [self.navigationController.navigationBar setTintColor:[UIColor whiteColor]];
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor whiteColor]}];
    self.navigationController.navigationBar.translucent = NO;
    
    _iVAboutImage.clipsToBounds = YES;
    _iVAboutImage.image = [UIImage imageNamed:@"aboutVersion.png"];
    
    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
    //当前应用名称  
    NSString *appName = [infoDictionary objectForKey:@"CFBundleName"];
    //当前应用版本号
    NSString *appVersion = [infoDictionary objectForKey:@"CFBundleShortVersionString"];
    //当前应用build号
    NSString *appBuild = [infoDictionary objectForKey:@"CFBundleVersion"];
    
    _lbAppName.text = appName;
    _lbVersion.text = [NSString stringWithFormat:@"v%@",appVersion];
    _lbBuild.text = [NSString stringWithFormat:@"bulid %@", appBuild];
    
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
