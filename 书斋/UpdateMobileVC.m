//
//  UpdateMobileVC.m
//  书斋
//
//  Created by 飞 on 2017/6/10.
//  Copyright © 2017年 Sam. All rights reserved.
//

#import "UpdateMobileVC.h"
#import "UserModel.h"

#import "IPConfig.h"

#define ScreenWidth CGRectGetWidth([UIScreen mainScreen].bounds)

@interface UpdateMobileVC ()<UITableViewDelegate,UITableViewDataSource>

{
    NSURLConnection *_connection;
    NSURLConnection *_updateMobileConnection;
    NSMutableData *_data;
    NSMutableData *_updateMobileData;
    NSString *_ipAndHost;
    NSString *_request;
    NSString *_updateMobileRequest;
    
    NSMutableArray *_arrUsers;
}

@property (strong, nonatomic) IBOutlet UITableView *tbUpdateMobile;

@property (strong, nonatomic) UILabel *lbCurrentMobile;
@property (strong, nonatomic) UITextField *tfMobile;
@property (strong, nonatomic) UILabel *lbMobileInfo;

@end

@implementation UpdateMobileVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.title = @"修改手机号码";
    UIBarButtonItem *saveMobileBtn = [[UIBarButtonItem alloc] initWithTitle:@"保存" style:UIBarButtonItemStylePlain target:self action:@selector(updateUserMobile)];
    self.navigationItem.rightBarButtonItem = saveMobileBtn;
    
    //键盘收回
    self.view.userInteractionEnabled = YES;
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(fingetTap:)];
    [self.view addGestureRecognizer:singleTap];
    
    _tbUpdateMobile.delegate = self;
    _tbUpdateMobile.dataSource = self;
    
    [self connectionWithURLToGetCurrentMobile];
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


-(NSInteger) numberOfSectionsInTableView:(UITableView *)tableView{
    return 2;
}


-(NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (section == 0) {
        return 1;
    } else {
        return 1;
    }
}


-(UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *cellIdentifier = @"cellIdentifier";
    
    UITableViewCell *cell = [_tbUpdateMobile dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    if (indexPath.section == 0) {
        _lbCurrentMobile = [[UILabel alloc] init];
        _lbCurrentMobile.frame = CGRectMake(20, 0, ScreenWidth-40, 44);
        _lbCurrentMobile.font = [UIFont systemFontOfSize:15];
        [cell addSubview:_lbCurrentMobile];
    } else {
        _tfMobile = [[UITextField alloc] init];
        _tfMobile.frame = CGRectMake(20, 0, ScreenWidth-40, 44);
        _tfMobile.keyboardType = UIKeyboardTypePhonePad;
        _tfMobile.clearButtonMode = UITextFieldViewModeWhileEditing;
        _tfMobile.font = [UIFont systemFontOfSize:15];
        [cell addSubview:_tfMobile];
        
        _lbMobileInfo = [[UILabel alloc] init];
        _lbMobileInfo.frame = CGRectMake(20, 44, ScreenWidth-40, 20);
        _lbMobileInfo.textColor = [UIColor redColor];
        _lbMobileInfo.font = [UIFont systemFontOfSize:13];
        [cell addSubview:_lbMobileInfo];
    }
    
    return cell;
}


-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 0) {
        return 44;
    } else {
        return 64;
    }
}


-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    if (section == 0) {
        return @"当前手机号码";
    } else {
        return @"以下框中输入手机号码";
    }
}


//修改手机号码
-(void)updateUserMobile{
    BOOL isMobile;
    if (_tfMobile.text.length == 0) {
        isMobile = NO;
        _lbMobileInfo.text = @"手机号码不能为空";
    } else {
        if (_tfMobile.text.length != 11) {
            isMobile = NO;
            _lbMobileInfo.text = @"手机号码必须为11位";
        } else {
            isMobile = YES;
            _lbMobileInfo.text = @"";
            [self connectionWithURLToUpdateUserMobile];
        }
    }
}


-(void) connectionWithURLToGetCurrentMobile{
    NSLog(@"方法被调用");
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *strUserName = [userDefaults objectForKey:@"userName"];
    
    _ipAndHost = Init_IP;
    _request = [NSString stringWithFormat:@"getUserCurrentMobile.html?userName=%@", strUserName];
    
    _request = [_request stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    
    NSString *strURL = [NSString stringWithFormat:@"%@/%@", _ipAndHost, _request];
    NSURL *url = [NSURL URLWithString:strURL];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    _connection = [NSURLConnection connectionWithRequest:request delegate:self];
    _data = [[NSMutableData alloc] init];
}


-(void) connectionWithURLToUpdateUserMobile{
    NSLog(@"方法被调用");
    
    _ipAndHost = Init_IP;
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *strUserName = [userDefaults objectForKey:@"userName"];
    
    _updateMobileRequest = [NSString stringWithFormat:@"updateUserMobile.html?userName=%@&mobile=%@",strUserName,_tfMobile.text];
    
    _updateMobileRequest = [_updateMobileRequest stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    
    NSString *strURL2 = [NSString stringWithFormat:@"%@/%@", _ipAndHost, _updateMobileRequest];
    NSURL *url2 = [NSURL URLWithString:strURL2];
    NSURLRequest *request2 = [NSURLRequest requestWithURL:url2];
    _updateMobileConnection = [NSURLConnection connectionWithRequest:request2 delegate:self];
    _updateMobileData = [[NSMutableData alloc] init];
}


-(void) connection:(NSURLConnection *)connection didFailWithError:(NSError *)error{
    if (connection == _connection) {
        NSLog(@"错误发生，为%@错误",error);
    } else if (connection == _updateMobileConnection ) {
        NSLog(@"错误发生，为%@错误",error);
    }
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
    if (connection == _connection) {
        [_data appendData:data];
    } else if (connection == _updateMobileConnection ) {
        [_updateMobileData appendData:data];
    }
}


-(void)connectionDidFinishLoading:(NSURLConnection *)connection{
    if (connection == _connection) {
        //        NSString *str = [[NSString alloc] initWithData:_data encoding:NSUTF8StringEncoding];
        //        NSLog(@"%@",str);
        [self setCurrentAddressWithData:_data];
    } else if (connection == _updateMobileConnection ) {
//        NSString *str = [[NSString alloc] initWithData:_updateMobileData encoding:NSUTF8StringEncoding];
//        NSLog(@"%@",str);
        [self backToPersonalVCWithData];
    }
}


-(void)setCurrentAddressWithData:(NSMutableData *) userData{
    NSArray *arrRoot = [NSJSONSerialization JSONObjectWithData:userData options:NSJSONReadingMutableContainers error:nil];
//    NSLog(@"字典为：%@",arrRoot);
    _arrUsers = [[NSMutableArray alloc] init];
    
    for (int i = 0; i < arrRoot.count; i++) {
        NSDictionary *dicUser = [arrRoot objectAtIndex:i];
        long mobile = [[dicUser objectForKey:@"mobile"] longValue];
        
        _lbCurrentMobile.text = [NSString stringWithFormat:@"%li",mobile];
    }
    [_tbUpdateMobile reloadData];
}


-(void) backToPersonalVCWithData{
    [self.navigationController popViewControllerAnimated:YES];
}


@end
