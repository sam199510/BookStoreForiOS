//
//  UpdatePasswordVC.m
//  书斋
//
//  Created by 飞 on 2017/6/10.
//  Copyright © 2017年 Sam. All rights reserved.
//

#import "UpdatePasswordVC.h"
#import "UserModel.h"

#import "IPConfig.h"

#define ScreenWidth CGRectGetWidth([UIScreen mainScreen].bounds)

@interface UpdatePasswordVC ()<UITableViewDelegate,UITableViewDataSource>

{
    NSURLConnection *_connection;
    NSURLConnection *_updatePasswordConnection;
    NSMutableData *_data;
    NSMutableData *_updatePasswordData;
    NSString *_ipAndHost;
    NSString *_request;
    NSString *_updatePasswordRequest;
    
    NSMutableArray *_arrUsers;
}

@property (strong, nonatomic) IBOutlet UITableView *tbUpdatePassword;

@property (strong, nonatomic) UITextField *tfOldPassword;
@property (strong, nonatomic) UILabel *lbOldPassword;
@property (strong, nonatomic) UITextField *tfNewPassword;
@property (strong, nonatomic) UILabel *lbNewPassword;
@property (strong, nonatomic) UITextField *tfNewRePassword;
@property (strong, nonatomic) UILabel *lbNewRePassword;

@property (assign, nonatomic) CGFloat keyboardHeight;

@end

@implementation UpdatePasswordVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.title = @"修改密码";
    UIBarButtonItem *updatePasswordBtn = [[UIBarButtonItem alloc] initWithTitle:@"修改" style:UIBarButtonItemStylePlain target:self action:@selector(updateUserPassword)];
    self.navigationItem.rightBarButtonItem = updatePasswordBtn;
    
    //键盘收回
    self.view.userInteractionEnabled = YES;
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(fingetTap:)];
    [self.view addGestureRecognizer:singleTap];
    
    //增加监听，键盘出现时调用
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    //增加监听，键盘消失时调用
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    
    _tbUpdatePassword.delegate = self;
    _tbUpdatePassword.dataSource = self;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//键盘收回
-(void) fingetTap:(UITapGestureRecognizer *)gestureRecognizer{
    [self.view endEditing:YES];
}


//键盘出现时调用
-(void)keyboardWillShow: (NSNotification *) aNotification {
    //获取键盘高度
    NSDictionary *userInfo = [aNotification userInfo];
    NSValue *aValue = [userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];
    CGRect keyboardRect = [aValue CGRectValue];
    _keyboardHeight = keyboardRect.size.height;
    
    //主屏幕高度
    CGFloat mainScreenHeight = [UIScreen mainScreen].bounds.size.height;
    //密码框父视图的y坐标
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:1 inSection:1];
    CGRect rectInTableView = [_tbUpdatePassword rectForRowAtIndexPath:indexPath];
    CGRect rect = [_tbUpdatePassword convertRect:rectInTableView toView:[_tbUpdatePassword superview]];
    CGFloat offSetYOfPasswordCell = rect.origin.y;
    //密码框父视图的高度
    CGFloat offSetHeightOFPasswordCell = rect.size.height + 75;
    //键盘高度转储
    CGFloat heightOfKeyboard = _keyboardHeight;
    //约束计算
    //    CGFloat offset = mainScreenHeight - (offSetYOfPasswordCell + offSetHeightOFPasswordCell + heightOfKeyboard);
    CGFloat offset = (mainScreenHeight - heightOfKeyboard) - (offSetHeightOFPasswordCell + offSetYOfPasswordCell);
    //判断约束
    if (offset < 0) {
        //约束变化
        [UIView animateWithDuration:0.25 animations:^{
            CGRect tbShopOrderFrame = _tbUpdatePassword.frame;
            tbShopOrderFrame.origin.y = -heightOfKeyboard + (_tbUpdatePassword.frame.size.height + 44 - (offSetYOfPasswordCell + offSetHeightOFPasswordCell)) ;
            _tbUpdatePassword.frame = tbShopOrderFrame;
        }];
    }
}

//键盘消失时调用
-(void)keyboardWillHide:(NSNotification *)aNotification{
    [UIView animateWithDuration:0.25 animations:^{
        CGRect tbShopOrderFrame = _tbUpdatePassword.frame;
        tbShopOrderFrame.origin.y = 0;
        _tbUpdatePassword.frame = tbShopOrderFrame;
    }];
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
        return 2;
    }
}


-(UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *cellIdentifier = @"cellIdentifier";
    UITableViewCell *cell = [_tbUpdatePassword dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    if (indexPath.section == 0) {
        _tfOldPassword = [[UITextField alloc] init];
        _tfOldPassword.frame = CGRectMake(20, 0, ScreenWidth-40, 44);
        _tfOldPassword.clearButtonMode = UITextFieldViewModeWhileEditing;
        _tfOldPassword.font = [UIFont systemFontOfSize:15];
        _tfOldPassword.secureTextEntry = YES;
        [cell addSubview:_tfOldPassword];
        
        _lbOldPassword = [[UILabel alloc] init];
        _lbOldPassword.frame = CGRectMake(20, 44, ScreenWidth-40, 20);
        _lbOldPassword.textColor = [UIColor redColor];
        _lbOldPassword.font = [UIFont systemFontOfSize:13];
        
        [cell addSubview:_lbOldPassword];
        
        return cell;
    } else if (indexPath.section == 1) {
        if (indexPath.row == 0) {
            _tfNewPassword = [[UITextField alloc] init];
            _tfNewPassword.frame = CGRectMake(20, 0, ScreenWidth-40, 44);
            _tfNewPassword.clearButtonMode = UITextFieldViewModeWhileEditing;
            _tfNewPassword.font = [UIFont systemFontOfSize:15];
            _tfNewPassword.secureTextEntry = YES;
            [cell addSubview:_tfNewPassword];
            
            _lbNewPassword = [[UILabel alloc] init];
            _lbNewPassword.frame = CGRectMake(20, 44, ScreenWidth-40, 20);
            _lbNewPassword.textColor = [UIColor redColor];
            _lbNewPassword.font = [UIFont systemFontOfSize:13];
            [cell addSubview:_lbNewPassword];
            
            return cell;
        } else if (indexPath.row == 1) {
            _tfNewRePassword = [[UITextField alloc] init];
            _tfNewRePassword.frame = CGRectMake(20, 0, ScreenWidth-40, 44);
            _tfNewRePassword.clearButtonMode = UITextFieldViewModeWhileEditing;
            _tfNewRePassword.font = [UIFont systemFontOfSize:15];
            _tfNewRePassword.secureTextEntry = YES;
            [cell addSubview:_tfNewRePassword];
            
            _lbNewRePassword = [[UILabel alloc] init];
            _lbNewRePassword.frame = CGRectMake(20, 44, ScreenWidth-40, 20);
            _lbNewRePassword.textColor = [UIColor redColor];
            _lbNewRePassword.font = [UIFont systemFontOfSize:13];
            [cell addSubview:_lbNewRePassword];
            
            return cell;
        }
    }
    
    return cell;
}


-(NSString *) tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    if (section == 0) {
        return @"原密码";
    } else {
        return @"以下框中输入密码";
    }
}


-(NSString *) tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section{
    if (section == 1) {
        return @"以上框中输入确认密码";
    } else {
        return @"";
    }
}


-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 0) {
        return 64;
    } else {
        return 64;
    }
}


-(void)updateUserPassword{
    NSLog(@"修改密码");
    BOOL isOldPassword;
    BOOL isNewPassword;
    BOOL isNewRePassword;
    
    if (_tfOldPassword.text.length == 0) {
        _lbOldPassword.text = @"原密码不能为空";
        isOldPassword = NO;
    } else {
        _lbOldPassword.text = @"";
        isOldPassword = YES;
    }
    
    if (_tfNewPassword.text.length == 0) {
        _lbNewPassword.text = @"新密码不能为空";
        isNewPassword = NO;
    } else {
        _lbNewPassword.text = @"";
        isNewPassword = YES;
    }
    
    if (_tfNewRePassword.text.length == 0) {
        _lbNewRePassword.text = @"新确认密码不能为空";
        isNewRePassword = NO;
    } else {
        if (_tfNewPassword.text != _tfNewRePassword.text) {
            _lbNewRePassword.text = @"新密码与确认密码不同";
            isNewRePassword = NO;
        } else {
            _lbNewRePassword.text = @"";
            isNewRePassword = YES;
        }
    }
    
    if (isOldPassword == YES && isNewPassword == YES && isNewRePassword == YES) {
        NSLog(@"修改密码成功");
        [self connectionWithURLToCheckUserPassword];
    } else {
        NSLog(@"密码修改失败");
    }
}


-(void) connectionWithURLToCheckUserPassword{
    NSLog(@"方法被调用");
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *strUserName = [userDefaults objectForKey:@"userName"];
    
    _ipAndHost = Init_IP;
    _request = [NSString stringWithFormat:@"checkUserPassword.html?userName=%@&password=%@", strUserName, _tfOldPassword.text];
    
    _request = [_request stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    
    NSString *strURL = [NSString stringWithFormat:@"%@/%@", _ipAndHost, _request];
    NSURL *url = [NSURL URLWithString:strURL];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    _connection = [NSURLConnection connectionWithRequest:request delegate:self];
    _data = [[NSMutableData alloc] init];
}


-(void) connectionWithURLToUpdateUserPassword{
    NSLog(@"方法被调用");
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *strUserName = [userDefaults objectForKey:@"userName"];
    
    _ipAndHost = Init_IP;
    
    NSString *username = strUserName;
    NSString *password = _tfNewPassword.text;
    
    _updatePasswordRequest = [NSString stringWithFormat:@"updateUserPassword.html?userName=%@&password=%@",username,password];
    
    _updatePasswordRequest = [_updatePasswordRequest stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    
    NSString *strURL2 = [NSString stringWithFormat:@"%@/%@", _ipAndHost, _updatePasswordRequest];
    NSURL *url2 = [NSURL URLWithString:strURL2];
    NSURLRequest *request2 = [NSURLRequest requestWithURL:url2];
    _updatePasswordConnection = [NSURLConnection connectionWithRequest:request2 delegate:self];
    _updatePasswordData = [[NSMutableData alloc] init];
}


-(void) connection:(NSURLConnection *)connection didFailWithError:(NSError *)error{
    if (connection == _connection) {
        NSLog(@"错误发生，为%@错误",error);
    } else if (connection == _updatePasswordConnection ) {
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
    } else if (connection == _updatePasswordConnection ) {
        [_updatePasswordData appendData:data];
    }
}


-(void)connectionDidFinishLoading:(NSURLConnection *)connection{
    if (connection == _connection) {
        NSString *str = [[NSString alloc] initWithData:_data encoding:NSUTF8StringEncoding];
        //NSLog(@"%@",str);
        [self isCheckUserNameRight:str];
    } else if (connection == _updatePasswordConnection ) {
        NSString *str = [[NSString alloc] initWithData:_updatePasswordData encoding:NSUTF8StringEncoding];
        NSLog(@"%@",str);
        
        [self backToPersonalInfoVC];
    }
}


-(void) isCheckUserNameRight:(NSString *)strLoginStatus{
    if ([strLoginStatus isEqualToString:@"1"]) {
        NSLog(@"修改密码成功！");
        
        [_tfOldPassword resignFirstResponder];
        [_tfNewPassword resignFirstResponder];
        [_tfNewRePassword resignFirstResponder];
        
        _lbOldPassword.text = @"";
        
        [self connectionWithURLToUpdateUserPassword];
        
    } else {
        //NSLog(@"登录失败！");
        
        [_tfOldPassword resignFirstResponder];
        [_tfNewRePassword resignFirstResponder];
        [_tfNewPassword resignFirstResponder];
        
        _lbOldPassword.text = @"经验证原密码不正确";
    }
}


-(void) backToPersonalInfoVC{
    [self.navigationController popViewControllerAnimated:YES];
}

@end
