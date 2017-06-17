//
//  PersonalInfoVC.m
//  书斋
//
//  Created by 飞 on 2017/6/10.
//  Copyright © 2017年 Sam. All rights reserved.
//

#import "PersonalInfoVC.h"
#import "UpdateMobileVC.h"
#import "UpdateAddressVC.h"
#import "UpdatePasswordVC.h"

@interface PersonalInfoVC ()<UITableViewDelegate,UITableViewDataSource>

@property (strong, nonatomic) IBOutlet UITableView *personalInfoTable;

@end

@implementation PersonalInfoVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.title = @"个人信息";
    [self.navigationController.navigationBar setTintColor:[UIColor whiteColor]];
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor whiteColor]}];
    self.navigationController.navigationBar.translucent = NO;
    
    _personalInfoTable.delegate = self;
    _personalInfoTable.dataSource = self;
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


-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 3;
}


-(NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (section == 0) {
        return 1;
    } else if (section == 1){
        return 1;
    } else {
        return 1;
    }
}


-(UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *cellIdentifier = @"cellIdentifier";
    
    UITableViewCell *cell = [_personalInfoTable dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    
    if (indexPath.section == 0) {
        cell.imageView.image = [UIImage imageNamed:@"password.png"];
        cell.textLabel.text = @"修改密码";
    } if (indexPath.section == 1) {
        cell.imageView.image = [UIImage imageNamed:@"phone.png"];
        cell.textLabel.text = @"修改手机号码";
    } if (indexPath.section == 2) {
        cell.imageView.image = [UIImage imageNamed:@"deliver.png"];
        cell.textLabel.text = @"修改地址";
    }
    
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    return cell;
}


-(CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 44;
}


-(CGFloat) tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0;
}


-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    if (section == 0) {
        NSString *security = @"安全设置";
        return security;
    } else if (section == 1) {
        return @"联系方式设置";
    } else {
        return @"地址设置";
    }
}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [_personalInfoTable deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.section == 0) {
        UpdatePasswordVC *updatePasswordVC = [[UpdatePasswordVC alloc] init];
        [self.navigationController pushViewController:updatePasswordVC animated:YES];
    } else if (indexPath.section == 1) {
        UpdateMobileVC *updateMobileVC = [[UpdateMobileVC alloc] init];
        [self.navigationController pushViewController:updateMobileVC animated:YES];
    } else {
        UpdateAddressVC *updateAddressVC = [[UpdateAddressVC alloc] init];
        [self.navigationController pushViewController:updateAddressVC animated:YES];
    }
}

@end
