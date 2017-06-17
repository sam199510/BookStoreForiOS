//
//  ShopBookVC.m
//  书斋
//
//  Created by 飞 on 2017/6/12.
//  Copyright © 2017年 Sam. All rights reserved.
//

#import "ShopBookVC.h"
//导入Cell和ViewContoller
#import "DeliveryInfoCell.h"
#import "DeliveryStyleCell.h"
#import "DetailOrderInfoCell.h"
#import "BuyBookSuccessfulVC.h"

//导入模型
#import "UserModel.h"
#import "BookModel.h"

//导入SDWebImage框架
#import "UIImageView+WebCache.h"

//导入IP配置文件
#import "IPConfig.h"

//宏定义主屏幕宽度
#define ScreenWidth CGRectGetWidth([UIScreen mainScreen].bounds)

@interface ShopBookVC ()<UITableViewDelegate,UITableViewDataSource>

{
    NSURLConnection *_connection;//初始用于得到配送信息的连接
    NSURLConnection *_getDeliveryInfoConnection;//用于得到订单详情的连接
    NSURLConnection *_checkPayPasswordConnection;//用于检查用户支付密码的连接
    NSURLConnection *_successToBuyBookConnection;//用于提交订单的连接
    NSMutableData *_data;//配送信息的数据
    NSMutableData *_getDeliveryInfoData;//订单详情的数据
    NSMutableData *_checkPayPasswordData;//检查用户支付密码的数据
    NSMutableData *_successToBuyBookData;//提交订单的数据
    NSString *_ipAndHost;//IP和端口
    NSString *_request;//配送信息的请求
    NSString *_getDeliveryInfoRequest;//订单详情的请求
    NSString *_checkPayPasswordRequest;//检查支付密码的请求
    NSString *_successToBuyBookRequest;//成功提交订单的请求
    
    NSMutableArray *_arrUsers;//定义用户的可变数组
    NSMutableArray *_arrBooks;//定义书目的可变数组
}

@property (strong, nonatomic) IBOutlet UITableView *tbShopOrder;//订单表格
@property (strong, nonatomic) IBOutlet UIButton *btnCommitOrder;//提交订单按钮

@property (strong, nonatomic) UITextField *tfPassword;//输入支付密码的文本框
@property (strong, nonatomic) UILabel *lbPassword;//用于检查支付密码的Label

@property (assign, nonatomic) CGFloat keyboardHeight;//用于获取键盘的高度

@end

@implementation ShopBookVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    //键盘收回
    self.view.userInteractionEnabled = YES;
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(fingetTap:)];
    [self.view addGestureRecognizer:singleTap];
    
    self.title = @"确认订单";
    
    //增加监听，键盘出现时调用
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    //增加监听，键盘消失时调用
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    
    //订单表格协议
    _tbShopOrder.delegate = self;
    _tbShopOrder.dataSource = self;
    
    //为提交订单按钮添加函数
    [_btnCommitOrder addTarget:self action:@selector(pressToCheckPassword) forControlEvents:UIControlEventTouchUpInside];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:YES];
    [self connectionWithURLToGetDeliveryInfo];
    [self connectionWithURLToGetDetailOrderInfo];
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
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:2];
    CGRect rectInTableView = [_tbShopOrder rectForRowAtIndexPath:indexPath];
    CGRect rect = [_tbShopOrder convertRect:rectInTableView toView:[_tbShopOrder superview]];
    CGFloat offSetYOfPasswordCell = rect.origin.y;
    //密码框父视图的高度
    CGFloat offSetHeightOFPasswordCell = rect.size.height;
    //键盘高度转储
    CGFloat heightOfKeyboard = _keyboardHeight;
    //约束计算
//    CGFloat offset = mainScreenHeight - (offSetYOfPasswordCell + offSetHeightOFPasswordCell + heightOfKeyboard);
    CGFloat offset = (mainScreenHeight - heightOfKeyboard) - (offSetHeightOFPasswordCell + offSetYOfPasswordCell);
    //判断约束
    if (offset <= 0) {
        //约束变化
        [UIView animateWithDuration:0.25 animations:^{
            CGRect tbShopOrderFrame = _tbShopOrder.frame;
            tbShopOrderFrame.origin.y = -heightOfKeyboard + (_tbShopOrder.frame.size.height + 44 - (offSetYOfPasswordCell + offSetHeightOFPasswordCell)) ;
            _tbShopOrder.frame = tbShopOrderFrame;
        }];
    }
}

//键盘消失时调用
-(void)keyboardWillHide:(NSNotification *)aNotification{
    [UIView animateWithDuration:0.25 animations:^{
        CGRect tbShopOrderFrame = _tbShopOrder.frame;
        tbShopOrderFrame.origin.y = 0;
        _tbShopOrder.frame = tbShopOrderFrame;
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


//设置表格节数
-(NSInteger) numberOfSectionsInTableView:(UITableView *)tableView{
    return 3;
}

//设置表格节点每节的Cell数量
-(NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return 1;
    } else if(section == 1) {
        return 2;
    } else {
        return 1;
    }
}

//解析Cell
-(UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *cellIdentifier = @"cellIdentifier";
    
    UITableViewCell *cell = [_tbShopOrder dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    if (indexPath.section == 0) {
        static NSString *cellIdentifier1 = @"cellIdentifier1";
        
        DeliveryInfoCell *cell = [_tbShopOrder dequeueReusableCellWithIdentifier:cellIdentifier1];
        
        if (cell == nil) {
            [_tbShopOrder registerNib:[UINib nibWithNibName:@"DeliveryInfoCell" bundle:nil] forCellReuseIdentifier:cellIdentifier1];
            cell = [_tbShopOrder dequeueReusableCellWithIdentifier:cellIdentifier1];
        }
        
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        UserModel *userModel = [_arrUsers objectAtIndex:indexPath.row];
        
        cell.lbDeliveredUser.text = [NSString stringWithFormat:@"收货人：%@",userModel.userName] ;
        cell.lbDeliveryMobile.text = [NSString stringWithFormat:@"%ld",userModel.mobile];
        cell.tVDeliveryAddress.text = [NSString stringWithFormat:@"收货地址：%@",userModel.address] ;
        
        return cell;
    } else if (indexPath.section == 1) {
        if (indexPath.row == 0) {
            static NSString *cellIdentifier2 = @"cellIdentifier2";
            
            DetailOrderInfoCell *cell = [_tbShopOrder dequeueReusableCellWithIdentifier:cellIdentifier2];
            
            if (cell == nil) {
                [_tbShopOrder registerNib:[UINib nibWithNibName:@"DetailOrderInfoCell" bundle:nil] forCellReuseIdentifier:cellIdentifier2];
                cell = [_tbShopOrder dequeueReusableCellWithIdentifier:cellIdentifier2];
            }
            
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            
            BookModel *bookModel = [_arrBooks objectAtIndex:indexPath.row];
            
            [cell.iVDetailOrderBookCover sd_setImageWithURL:[NSURL URLWithString:bookModel.cover]];
            cell.tVDetailOrderBookName.text = bookModel.bookName;
            cell.lbDetailOrderBookPrice.text = [NSString stringWithFormat:@"¥ %.2f",bookModel.price];
            
             return cell;
        } else if (indexPath.row == 1) {
            static NSString *cellIdentifier3 = @"cellIdentifier3";
            
            DeliveryStyleCell *cell = [_tbShopOrder dequeueReusableCellWithIdentifier:cellIdentifier3];
            
            if (cell == nil) {
                [_tbShopOrder registerNib:[UINib nibWithNibName:@"DeliveryStyleCell" bundle:nil] forCellReuseIdentifier:cellIdentifier3];
                cell = [_tbShopOrder dequeueReusableCellWithIdentifier:cellIdentifier3];
            }
            
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            
             return cell;
        }
    } else if (indexPath.section == 2) {
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        _tfPassword = [[UITextField alloc] init];
        _tfPassword.frame = CGRectMake(20, 0, ScreenWidth-40, 44);
        _tfPassword.clearButtonMode = UITextFieldViewModeWhileEditing;
        _tfPassword.font = [UIFont systemFontOfSize:15];
        _tfPassword.secureTextEntry = YES;
        [cell addSubview:_tfPassword];
        
        _lbPassword = [[UILabel alloc] init];
        _lbPassword.frame = CGRectMake(20, 44, ScreenWidth-40, 20);
        _lbPassword.textColor = [UIColor redColor];
        _lbPassword.font = [UIFont systemFontOfSize:13];
        [cell addSubview:_lbPassword];
        
         return cell;
    }
    
    return cell;
}

//设置表格的每节的头部标题
-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    if (section == 0) {
        return @"收货信息";
    } else if(section == 1) {
        return @"订单内容";
    } else {
        return @"输入账户密码以完成支付";
    }
}

//设置表格视图的每节的高度
-(CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 0) {
        return 120;
    } else if(indexPath.section == 1) {
        if (indexPath.row == 0) {
            return 120;
        } else {
            return 50;
        }
    } else {
        return 64;
    }
}

//设置每节的头部的高度
-(CGFloat) tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 0;
}

//预先检查用户密码是否为空的函数
-(void) pressToCheckPassword{
    if (_tfPassword.text.length == 0) {
        _lbPassword.text = @"支付密码不能为空";
    } else {
        _lbPassword.text = @"";
        [self connectionWithURLToCheckUserPayPassword];
    }
}

//得到配送信息
-(void) connectionWithURLToGetDeliveryInfo{
    NSLog(@"方法被调用");
    
    _ipAndHost = Init_IP;
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *strUserName = [userDefaults objectForKey:@"userName"];

    _request = [NSString stringWithFormat:@"getDeliveredInfo.html?userName=%@",strUserName];
    
    _request = [_request stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    
    NSString *strURL = [NSString stringWithFormat:@"%@/%@", _ipAndHost, _request];
    NSURL *url = [NSURL URLWithString:strURL];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    _connection = [NSURLConnection connectionWithRequest:request delegate:self];
    _data = [[NSMutableData alloc] init];
}

//得到订单详情
-(void) connectionWithURLToGetDetailOrderInfo{
    NSLog(@"方法被调用");
    
    _ipAndHost = Init_IP;
    
    _getDeliveryInfoRequest = [NSString stringWithFormat:@"getBookDetailInfo.html?bookID=%ld",_bookID];
    
    _getDeliveryInfoRequest = [_getDeliveryInfoRequest stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    
    NSString *strURL2 = [NSString stringWithFormat:@"%@/%@", _ipAndHost, _getDeliveryInfoRequest];
    NSURL *url2 = [NSURL URLWithString:strURL2];
    NSURLRequest *request2 = [NSURLRequest requestWithURL:url2];
    _getDeliveryInfoConnection = [NSURLConnection connectionWithRequest:request2 delegate:self];
    _getDeliveryInfoData = [[NSMutableData alloc] init];
}

//检查用户支付密码
-(void) connectionWithURLToCheckUserPayPassword{
    NSLog(@"方法被调用");
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *strUserName = [userDefaults objectForKey:@"userName"];
    
    _ipAndHost = Init_IP;
    _checkPayPasswordRequest = [NSString stringWithFormat:@"isPayPasswordRight.html?userName=%@&password=%@", strUserName, _tfPassword.text];
    
    _checkPayPasswordRequest = [_checkPayPasswordRequest stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    
    NSString *strURL = [NSString stringWithFormat:@"%@/%@", _ipAndHost, _checkPayPasswordRequest];
    NSURL *url = [NSURL URLWithString:strURL];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    _checkPayPasswordConnection = [NSURLConnection connectionWithRequest:request delegate:self];
    _checkPayPasswordData = [[NSMutableData alloc] init];
}

//提交订单
-(void) connectionWithURLToCommitOrder{
    NSLog(@"方法被调用");
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *strUserName = [userDefaults objectForKey:@"userName"];
    
    _ipAndHost = Init_IP;
    _successToBuyBookRequest = [NSString stringWithFormat:@"createOrder.html?userName=%@&bookID=%ld", strUserName, _bookID];
    
    _successToBuyBookRequest = [_successToBuyBookRequest stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    
    NSString *strURL = [NSString stringWithFormat:@"%@/%@", _ipAndHost, _successToBuyBookRequest];
    NSURL *url = [NSURL URLWithString:strURL];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    _successToBuyBookConnection = [NSURLConnection connectionWithRequest:request delegate:self];
    _successToBuyBookData = [[NSMutableData alloc] init];
}

//发生错误检测
-(void) connection:(NSURLConnection *)connection didFailWithError:(NSError *)error{
    if (connection == _connection) {
        NSLog(@"错误发生，为%@错误",error);
    } else if (connection == _getDeliveryInfoConnection ) {
        NSLog(@"错误发生，为%@错误",error);
    } else if (connection == _checkPayPasswordConnection) {
        NSLog(@"错误发生，为%@",error);
    } else if (connection == _successToBuyBookConnection) {
        NSLog(@"错误发生，为%@",error);
    }
}

//检查连接的状态
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

//接受到数据的方法
-(void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data{
    if (connection == _connection) {
        [_data appendData:data];
        [self parseUserDataWithData];
    } else if (connection == _getDeliveryInfoConnection ) {
        [_getDeliveryInfoData appendData:data];
        [self parseBookDataWithData];
    } else if (connection == _checkPayPasswordConnection) {
        [_checkPayPasswordData appendData:data];
    } else if (connection == _successToBuyBookConnection) {
        [_successToBuyBookData appendData:data];
    }
}

//网络数据加载完成
-(void)connectionDidFinishLoading:(NSURLConnection *)connection{
    if (connection == _connection) {
//        NSString *str = [[NSString alloc] initWithData:_data encoding:NSUTF8StringEncoding];
//        NSLog(@"%@",str);
    } else if (connection == _getDeliveryInfoConnection ) {
//        NSString *str = [[NSString alloc] initWithData:_getDeliveryInfoData encoding:NSUTF8StringEncoding];
//        NSLog(@"%@",str);
    } else if (connection == _checkPayPasswordConnection) {
        NSString *str = [[NSString alloc] initWithData:_checkPayPasswordData encoding:NSUTF8StringEncoding];
        [self dealWithCommitBtnWithConfigString:str];
    } else if (connection == _successToBuyBookConnection) {
        NSString *str = [[NSString alloc] initWithData:_successToBuyBookData encoding:NSUTF8StringEncoding];
        [self dealWithSuccessfunToCreateOrder:str];
    }
}

//解析配送用户数据
-(void)parseUserDataWithData{
    NSArray *arrRoot = [NSJSONSerialization JSONObjectWithData:_data options:NSJSONReadingMutableContainers error:nil];
    _arrUsers = [[NSMutableArray alloc] init];
    
    for (int i = 0; i < arrRoot.count; i++) {
        NSDictionary *dicUser = [arrRoot objectAtIndex:i];
        
        NSInteger userID = [[dicUser objectForKey:@"id"] integerValue];
        NSString *userName = [dicUser objectForKey:@"userName"];
        NSInteger mobile = [[dicUser objectForKey:@"mobile"] integerValue];
        NSString *address = [dicUser objectForKey:@"address"];
        
        UserModel *userModel = [[UserModel alloc] init];
        userModel.userId = userID;
        userModel.userName = userName;
        userModel.mobile = mobile;
        userModel.address = address;
        
        [_arrUsers addObject:userModel];
        
    }
    [_tbShopOrder reloadData];
}

//解析书本的数据
-(void)parseBookDataWithData{
    NSArray *arrRoot = [NSJSONSerialization JSONObjectWithData:_getDeliveryInfoData options:NSJSONReadingMutableContainers error:nil];
    _arrBooks = [[NSMutableArray alloc] init];
    
    for (int i = 0; i < arrRoot.count; i++) {
        NSDictionary *dicBook = [arrRoot objectAtIndex:i];
        
        NSInteger bookID = [[dicBook objectForKey:@"id"] integerValue];
        NSString *bookName = [dicBook objectForKey:@"bookName"];
        NSString *author = [dicBook objectForKey:@"author"];
        float price = [[dicBook objectForKey:@"price"] floatValue];
        NSString *introduce = [dicBook objectForKey:@"introduce"];
        NSString *publisher = [dicBook objectForKey:@"publisher"];
        NSInteger isbn = [[dicBook objectForKey:@"isbn"] integerValue];
        NSInteger repertory = [[dicBook objectForKey:@"repertory"] integerValue];
        NSString *cover = [dicBook objectForKey:@"cover"];
        
        BookModel *bookModel = [[BookModel alloc] init];
        bookModel.bookId = bookID;
        bookModel.bookName = bookName;
        bookModel.author = author;
        bookModel.price = price;
        bookModel.introduce = introduce;
        bookModel.publisher = publisher;
        bookModel.isbn = isbn;
        bookModel.repertory = repertory;
        bookModel.cover = cover;
        
        [_arrBooks addObject:bookModel];
    }
    [_tbShopOrder reloadData];
}

//数据加载完成时检查用户支付密码
-(void) dealWithCommitBtnWithConfigString:(NSString *) configString{
    if ([configString isEqualToString:@"0"]) {
        _lbPassword.text = @"支付密码不正确";
    } else {
        _lbPassword.text = @"";
        [self connectionWithURLToCommitOrder];
    }
}

//成功提交订单
-(void) dealWithSuccessfunToCreateOrder: (NSString *) str{
    NSLog(@"%@",str);
    
    BuyBookSuccessfulVC *buyBookSuccessfunVC = [[BuyBookSuccessfulVC alloc] init];
    [self.navigationController pushViewController:buyBookSuccessfunVC animated:YES];
}


@end
