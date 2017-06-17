//
//  MeVC.m
//  书斋
//
//  Created by 飞 on 2017/6/8.
//  Copyright © 2017年 Sam. All rights reserved.
//

#import "MeVC.h"
#import "HeadImageViewCell.h"
#import "AboutVC.h"
#import "LoginVC.h"
#import "PersonalInfoVC.h"
#import "CollectionVC.h"

#define ScreenWidth CGRectGetWidth([UIScreen mainScreen].bounds)
#define ScreenHeitht CGRectGetHeight([UIScreen mainScreen].bounds)

@interface MeVC ()<UITableViewDelegate,UITableViewDataSource,UIActionSheetDelegate>

{
    //cell图片名称数组
    NSArray *_arrSecondImage ;
    //celllabel名称数组
    NSArray *_arrSecondTitle ;
}

@property (strong, nonatomic) UIActionSheet *actionSheet;
@property (strong, nonatomic) IBOutlet UITableView *meTableView;

@end

@implementation MeVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.title = @"我";
    [self.navigationController.navigationBar setTintColor:[UIColor whiteColor]];
    [self.navigationController.navigationBar setBarTintColor:[UIColor colorWithRed:253.0/255.0 green:109.0/255.0 blue:9.0/255.0 alpha:1]];
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor whiteColor]}];
    self.navigationController.navigationBar.translucent = NO;
    
    //第二个Group的图片名数组和名称数组
    _arrSecondImage = @[@"personalInfo.png",@"collection.png"];
    _arrSecondTitle = @[@"个人信息",@"我的收藏"];
    
    _meTableView.delegate = self;
    _meTableView.dataSource = self;
    [_meTableView setSectionHeaderHeight:10];
    [_meTableView setSectionFooterHeight:10];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:YES];
    self.tabBarController.tabBar.hidden = NO;
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/


//以下方法为Tableview协议方法
-(NSInteger) numberOfSectionsInTableView:(UITableView *)tableView{
    return 4;
}


-(NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (section == 0) {
        return 1;
    } else if (section == 1) {
        return 2;
    } else if(section == 2) {
        return 1;
    } else {
        return 1;
    }
}


-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *cellIdentifier = @"cellIdentifier";
    
    UITableViewCell *cell = [_meTableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    
    if (indexPath.section == 0) {
        //加载自定义的Cell
        static NSString *cellIdentifier2 = @"cellHeadImage";
        
        HeadImageViewCell *cellHeadImage = [_meTableView dequeueReusableCellWithIdentifier:cellIdentifier2];
        
        if (cellHeadImage == nil) {
            [_meTableView registerNib:[UINib nibWithNibName:@"HeadImageViewCell" bundle:nil] forCellReuseIdentifier:cellIdentifier2];
            cellHeadImage = [_meTableView dequeueReusableCellWithIdentifier:cellIdentifier2];
        }
        
        [cellHeadImage.iVHeadImageView.layer setBorderColor:[[UIColor colorWithRed:253.0/255.0 green:109.0/255.0 blue:9.0/255.0 alpha:1] CGColor]];
        cellHeadImage.iVHeadImageView.clipsToBounds = YES;
        cellHeadImage.iVHeadImageView.image = [UIImage imageNamed:@"headImage.png"];
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        cellHeadImage.lbUserName.text = [userDefaults objectForKey:@"userName"];
        cellHeadImage.selectionStyle = UITableViewCellSelectionStyleNone;
        
        return cellHeadImage;
        
    } else if (indexPath.section > 0 && indexPath.section < 3) {
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        
        if (indexPath.section == 1) {
            
            cell.textLabel.text = [_arrSecondTitle objectAtIndex:indexPath.row];
            cell.imageView.image = [UIImage imageNamed:[_arrSecondImage objectAtIndex:indexPath.row]];
        } else if (indexPath.section == 2){
            cell.textLabel.text = @"关于";
            cell.imageView.image = [UIImage imageNamed:@"about.png"];
        }
        
        return cell;
    } else {
        UILabel *lbLogOut = [[UILabel alloc] init];
        lbLogOut.frame = CGRectMake(20, 0, ScreenWidth-20, 44);
        lbLogOut.text = @"退出登录";
        lbLogOut.font = [UIFont systemFontOfSize:17];
        lbLogOut.textColor = [UIColor colorWithRed:253.0/255.0 green:109.0/255.0 blue:9.0/255.0 alpha:1];
        lbLogOut.textAlignment = NSTextAlignmentCenter;
        [cell addSubview:lbLogOut];
        
        return cell;
    }
}


-(void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 0) {
//        UITableViewCell * cell = [tableView cellForRowAtIndexPath:indexPath];
//        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    } else {
        [_meTableView deselectRowAtIndexPath:indexPath animated:YES];
        
        if (indexPath.section == 1) {
            if (indexPath.row == 0) {
                PersonalInfoVC *personInfoVC = [[PersonalInfoVC alloc] init];
                personInfoVC.hidesBottomBarWhenPushed = YES;
                [self.navigationController pushViewController:personInfoVC animated:YES];
            } else if (indexPath.row == 1) {
                CollectionVC *collectionVC = [[CollectionVC alloc] init];
                collectionVC.hidesBottomBarWhenPushed = YES;
                [self.navigationController pushViewController:collectionVC animated:YES];
            }
            
        } else if (indexPath.section == 2) {
            AboutVC *aboutVC = [[AboutVC alloc] init];
            aboutVC.hidesBottomBarWhenPushed = YES;
            [self.navigationController pushViewController:aboutVC animated:YES];
        } else if (indexPath.section == 3) {
            [self callActionSheetFunc];
        }
        
    }
}


-(CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 0) {
        return 200;
    } else {
        return 44;
    }
}

//呼出ActionSheet
-(void)callActionSheetFunc{
    self.actionSheet = [[UIActionSheet alloc] initWithTitle:@"是否退出登录？" delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"退出登录", nil];
    self.actionSheet.tag=1000;
    [self.actionSheet showInView:self.view];
    
}


-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (actionSheet.tag == 1000) {
        switch (buttonIndex) {
            case 0:
                [self pressLogout];
                break;
            case 1:
                return;
            default:
                break;
        }
    }
}


//退出登录方法
-(void)pressLogout{
    NSLog(@"退出登录！");
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults removeObjectForKey:@"userName"];
    [userDefaults removeObjectForKey:@"password"];
    [userDefaults synchronize];
    
    LoginVC *loginVC = [[LoginVC alloc] init];
    [self presentViewController:loginVC animated:YES completion:nil];
    
}

@end
