//
//  OrderVC.m
//  书斋
//
//  Created by 飞 on 2017/6/8.
//  Copyright © 2017年 Sam. All rights reserved.
//

#import "OrderVC.h"
#import "IndentTableViewCell.h"
#import "ShowIndentVC.h"
#import "LoginVC.h"

#import "IndentModel.h"

#import "UIImageView+WebCache.h"

#import "IPConfig.h"

@interface OrderVC ()<UIViewControllerPreviewingDelegate,UITableViewDelegate,UITableViewDataSource>

{
    NSURLConnection *_connect;
    NSURLConnection *_deleteIndentConnect;
    NSMutableData *_data;
    NSMutableData *_deleteIndentData;
    NSMutableArray *_arrayIndents;
    NSString *_ipAndHost;
    NSString *_request;
    NSString *_deleteIndentRequest;
    
    BOOL _isEdit;
}

@property (strong, nonatomic) IBOutlet UITableView *tbIndent;

@property (strong, nonatomic) UIBarButtonItem *btnEdit;
@property (strong, nonatomic) UIBarButtonItem *btnDone;

@end

@implementation OrderVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.title = @"订单";
    [self.navigationController.navigationBar setTintColor:[UIColor whiteColor]];
    [self.navigationController.navigationBar setBarTintColor:[UIColor colorWithRed:253.0/255.0 green:109.0/255.0 blue:9.0/255.0 alpha:1]];
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor whiteColor]}];
    self.navigationController.navigationBar.translucent = NO;
    
    [self createNavigationBarButton];
    
    _tbIndent.delegate = self;
    _tbIndent.dataSource = self;
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) viewWillAppear:(BOOL)animated{
    [super viewWillAppear:YES];
    self.tabBarController.tabBar.hidden = NO;
    [self connectionWithURL];
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
    return 1;
}


-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _arrayIndents.count;
}


-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"cellIdentifier";
    
    IndentTableViewCell *cell = [_tbIndent dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (cell == nil) {
        [_tbIndent registerNib:[UINib nibWithNibName:@"IndentTableViewCell" bundle:nil] forCellReuseIdentifier:cellIdentifier];
        cell = [_tbIndent dequeueReusableCellWithIdentifier:cellIdentifier];
    }
    
    //判断3D Touch是否可用，可用的话就去注册
    if (self.traitCollection.forceTouchCapability == UIForceTouchCapabilityAvailable) {
        [self registerForPreviewingWithDelegate:self sourceView:cell];
    }
    
    if (indexPath.section == 0) {
        
        IndentModel *indentModel = [_arrayIndents objectAtIndex:indexPath.row];
        
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
        NSString *bargainTimeStr = [dateFormatter stringFromDate:indentModel.bargainTime];
        
        if (indentModel.commentState == 1) {
            cell.lbBargainState.text = @"交易成功";
        } else if (indentModel.commentState == 0) {
            cell.lbBargainState.text = @"待评价";
        }
        
        cell.lbIndentBookPublisher.text = indentModel.bookPublisher;
        [cell.iVbookCover sd_setImageWithURL:[NSURL URLWithString:indentModel.bookCover]];
        cell.lbBookName.text = indentModel.bookName;
        cell.lbBookPrice.text = [NSString stringWithFormat:@"¥ %.2f",indentModel.bookPrice];
        cell.lbBargainTime.text = [NSString stringWithFormat:@"成交时间：%@",bargainTimeStr];
    }
    
    return cell;
}


-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 160;
}


-(NSString *) tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    return @"以下是已完成的订单";
}


-(NSString *) tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section{
    return @"没有更多的订单了";
}


-(void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    [_tbIndent deselectRowAtIndexPath:indexPath animated:YES];
    
    if (indexPath.section == 0) {
        ShowIndentVC *showIndentVC = [[ShowIndentVC alloc] init];
        showIndentVC.hidesBottomBarWhenPushed = YES;
        
        IndentModel *indentModel = [_arrayIndents objectAtIndex:indexPath.row];
        showIndentVC.indentID = indentModel.indentId;
        
        [self.navigationController pushViewController:showIndentVC animated:YES];
    }
}


-(void) tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 0) {
        NSArray *arrayDeleteIndents = [NSArray arrayWithObject:indexPath];
        
        if (editingStyle == UITableViewCellEditingStyleDelete) {
            
            IndentModel *indentModel = [_arrayIndents objectAtIndex:indexPath.row];
            NSInteger indentId = indentModel.indentId;
            
            [self connectionWithURLToDeleteIndent:indentId];
            
            [_arrayIndents removeObjectAtIndex:indexPath.row];
            [_tbIndent deleteRowsAtIndexPaths:arrayDeleteIndents withRowAnimation:UITableViewRowAnimationFade];
        }
    }
    [_tbIndent reloadData];
}


- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath {
    return @"删除";
}


//以下两个方法为3DTouch的方法
-(nullable UIViewController *)previewingContext:(id<UIViewControllerPreviewing>)previewingContext viewControllerForLocation:(CGPoint)location{
    NSIndexPath *indexPaht = [_tbIndent indexPathForCell:(UITableViewCell *)[previewingContext sourceView]];
    IndentModel *indentModel = [_arrayIndents objectAtIndex:indexPaht.row];
    
    //设定预览界面
    ShowIndentVC *showIndentVC = [[ShowIndentVC alloc] init];
    showIndentVC.preferredContentSize = CGSizeMake(0, 0);
    showIndentVC.indentID = indentModel.indentId;
    return showIndentVC;
}


-(void)previewingContext:(id<UIViewControllerPreviewing>)previewingContext commitViewController:(UIViewController *)viewControllerToCommit{
    viewControllerToCommit.hidesBottomBarWhenPushed = YES;
    [self showViewController:viewControllerToCommit sender:self];
}


-(void) createNavigationBarButton{
    _isEdit = NO;
    
    _btnEdit = [[UIBarButtonItem alloc] initWithTitle:@"编辑" style:UIBarButtonItemStylePlain target:self action:@selector(pressEdit)];
    _btnDone = [[UIBarButtonItem alloc] initWithTitle:@"完成" style:UIBarButtonItemStylePlain target:self action:@selector(pressDone)];
    
    self.navigationItem.rightBarButtonItem = _btnEdit;
}


-(void)pressEdit{
    _isEdit = YES;
    self.navigationItem.rightBarButtonItem = _btnDone;
    [_tbIndent setEditing:YES animated:YES];
}


-(void)pressDone{
    _isEdit = NO;
    self.navigationItem.rightBarButtonItem = _btnEdit;
    [_tbIndent setEditing:NO animated:YES];
}


-(void) connectionWithURL{
    NSLog(@"方法被调用");
    
    _ipAndHost = Init_IP;
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *strUserName = [userDefaults objectForKey:@"userName"];
    
    if (!strUserName) {
        LoginVC *loginVC = [[LoginVC alloc] init];
        [self presentViewController:loginVC animated:YES completion:nil];
    } else {
        _request = [NSString stringWithFormat:@"showIndent.html?userName=%@",strUserName];
        _request = [_request stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
        NSString *strURL = [NSString stringWithFormat:@"%@/%@", _ipAndHost, _request];
        NSURL *url = [NSURL URLWithString:strURL];
        
        NSURLRequest *request = [NSURLRequest requestWithURL:url];
        _connect = [NSURLConnection connectionWithRequest:request delegate:self];
        _data = [[NSMutableData alloc] init];
    }
}


-(void) connectionWithURLToDeleteIndent:(NSInteger) indentID{
    NSLog(@"方法被调用");
    
    _ipAndHost = Init_IP;
    
    NSString *strRequest = [NSString stringWithFormat:@"deleteIndentByIndentId.html?indentId=%ld",indentID];
    _deleteIndentRequest = strRequest;
    
    _deleteIndentRequest = [_deleteIndentRequest stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    
    NSString *strURL = [NSString stringWithFormat:@"%@/%@", _ipAndHost, _deleteIndentRequest];
    NSURL *url = [NSURL URLWithString:strURL];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    _deleteIndentConnect = [NSURLConnection connectionWithRequest:request delegate:self];
    _deleteIndentData = [[NSMutableData alloc] init];
}


-(void) connection:(NSURLConnection *)connection didFailWithError:(NSError *)error{
    if (connection == _connect) {
        NSLog(@"错误发生，为%@错误",error);
    } else if (connection == _deleteIndentConnect) {
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
    if (connection == _connect) {
        [_data appendData:data];
        [self parseIndentWithData];
    } else if (connection == _deleteIndentConnect) {
        [_deleteIndentData appendData:data];
    }
}


-(void)connectionDidFinishLoading:(NSURLConnection *)connection{
    if (connection == _connect) {
        //NSString *str = [[NSString alloc] initWithData:_data encoding:NSUTF8StringEncoding];
    } else if (connection == _deleteIndentConnect) {
        NSString *str = [[NSString alloc] initWithData:_deleteIndentData encoding:NSUTF8StringEncoding];
        NSLog(@"%@",str);
    }
}


-(void)parseIndentWithData{
    NSArray *arrRoot = [NSJSONSerialization JSONObjectWithData:_data options:NSJSONReadingMutableContainers error:nil];
    _arrayIndents = [[NSMutableArray alloc] init];
    
    for (int i = 0; i<arrRoot.count; i++) {
        NSDictionary *dicIndent = [arrRoot objectAtIndex:i];
        
        NSInteger indentID = [[dicIndent objectForKey:@"id"] integerValue];
        NSInteger buyerID = [[dicIndent objectForKey:@"buyerID"] integerValue];
        NSInteger bookID = [[dicIndent objectForKey:@"bookID"] integerValue];
        
        //获取从SSH框架中获取的时间戳
        NSTimeInterval bargainTimeInterval = [[dicIndent objectForKey:@"bargainTime"] integerValue]/1000;
        //创建日期格式对象
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        //设置日期格式
        [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
        //将时间戳转换成NSDate对象
        NSDate *bargainTimeDate = [NSDate dateWithTimeIntervalSince1970:bargainTimeInterval];
        //将转换成的NSDate对象格式化到一个NSString格式的字符串中
        NSString *bargainTimeString = [formatter stringFromDate:bargainTimeDate];
        //将格式化的日期的NSString字符串转换到一个NSDate中，以便之后Model中使用
        NSDate *bargainTime = [formatter dateFromString:bargainTimeString];
        
        NSString *buyerAddress = [dicIndent objectForKey:@"buyerAddress"];
        NSString *bookName = [dicIndent objectForKey:@"bookName"];
        NSString *bookCover = [dicIndent objectForKey:@"bookCover"];
        float bookPrice = [[dicIndent objectForKey:@"bookPrice"] floatValue];
        NSString *bookPublisher = [dicIndent objectForKey:@"bookPublisher"];
        NSInteger commentState = [[dicIndent objectForKey:@"commentState"] integerValue];
        long buyerMobile = [[dicIndent objectForKey:@"buyerMobile"] longValue];
        NSString *buyerName = [dicIndent objectForKey:@"buyerName"];
        
        IndentModel *indentModel = [[IndentModel alloc] init];
        indentModel.indentId = indentID;
        indentModel.buyerID = buyerID;
        indentModel.bookID = bookID;
        indentModel.bargainTime = bargainTime;
        indentModel.buyerAddress = buyerAddress;
        indentModel.bookName = bookName;
        indentModel.bookCover = bookCover;
        indentModel.bookPrice = bookPrice;
        indentModel.bookPublisher = bookPublisher;
        indentModel.commentState = commentState;
        indentModel.buyerMobile = buyerMobile;
        indentModel.buyerName = buyerName;
        
        [_arrayIndents addObject:indentModel];
    }
    
    [_tbIndent reloadData];
    
}

@end
