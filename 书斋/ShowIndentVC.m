//
//  ShowIndentVC.m
//  书斋
//
//  Created by 飞 on 2017/6/16.
//  Copyright © 2017年 Sam. All rights reserved.
//

#import "ShowIndentVC.h"
#import "BargainTimeInfoCell.h"
#import "SuccessFulIndentCell.h"
#import "IndentDeliveryInfo.h"
#import "IndentOrderInfoCell.h"
#import "CommentVC.h"

#import "IndentModel.h"

#import "UIImageView+WebCache.h"

#import "IPConfig.h"

#define ScreenWidth CGRectGetWidth([UIScreen mainScreen].bounds)
#define ScreenHeight CGRectGetHeight([UIScreen mainScreen].bounds)

//显示订单的ViewController
@interface ShowIndentVC ()<UITableViewDelegate,UITableViewDataSource>

{
    NSURLConnection *_connect;
    NSMutableData *_data;
    NSMutableArray *_arrayIndent;
    NSString *_ipAndHost;
    NSString *_request;
    
    NSURLConnection *_getIndentConnect;
    NSMutableData *_getIndentData;
    NSString *_getIndentRequest;
    
    NSString *_bargainState;
}

@property (strong, nonatomic) IBOutlet UITableView *tbShowIndent;

@property (strong, nonatomic) UIButton *btnNotComment;
@property (strong, nonatomic) UILabel *lbCommented;

@end

@implementation ShowIndentVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.title = @"订单详情";
    
    _tbShowIndent.delegate = self;
    _tbShowIndent.dataSource = self;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:YES];
    
    [self connectionWithURLToCheckIsComment];
    [self connectionWithURLToGetIndentDetailInfo];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

//以下方法为表格视图的协议方法
-(NSInteger) numberOfSectionsInTableView:(UITableView *)tableView{
    return 3;
}


-(NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (section == 0) {
        return 2;
    } else if (section == 1) {
        return 1;
    } else {
        return 1;
    }
}


-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *cellIdentifier = @"cellIdentifier";
    
    UITableViewCell *cell = [_tbShowIndent dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    if (indexPath.section == 0) {
        if (indexPath.row == 0) {
            static NSString *cellIdentifier1 = @"cellIdentifier1";
            
            SuccessFulIndentCell *cell = [_tbShowIndent dequeueReusableCellWithIdentifier:cellIdentifier1];
            
            if (cell == nil) {
                [_tbShowIndent registerNib:[UINib nibWithNibName:@"SuccessFulIndentCell" bundle:nil] forCellReuseIdentifier:cellIdentifier1];
                cell = [_tbShowIndent dequeueReusableCellWithIdentifier:cellIdentifier1];
            }
            
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            
            if ([_bargainState isEqualToString:@"0"]) {
                cell.lbBargainState.text = @"待评价";
            } else {
                cell.lbBargainState.text = @"交易成功";
            }
            
            return cell;
        } else {
            static NSString *cellIdentifier2 = @"cellIdentifier2";
            
            IndentDeliveryInfo *cell = [_tbShowIndent dequeueReusableCellWithIdentifier:cellIdentifier2];
            
            if (cell == nil) {
                [_tbShowIndent registerNib:[UINib nibWithNibName:@"IndentDeliveryInfo" bundle:nil] forCellReuseIdentifier:cellIdentifier2];
                cell = [_tbShowIndent dequeueReusableCellWithIdentifier:cellIdentifier2];
            }
            
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            
            IndentModel *indentModel = [_arrayIndent objectAtIndex:indexPath.row-1];
            
            cell.lbIndentBuyer.text = [NSString stringWithFormat:@"收货人：%@",indentModel.buyerName];
            cell.lbBuyerMobile.text = [NSString stringWithFormat:@"%li",indentModel.buyerMobile];
            cell.tVBookName.text = [NSString stringWithFormat:@"收货地址：%@",indentModel.buyerAddress];
            
            return cell;
        }
    } else if (indexPath.section == 1) {
        static NSString *cellIdentifier3 = @"cellIdentifier3";
        
        IndentOrderInfoCell *cell = [_tbShowIndent dequeueReusableCellWithIdentifier:cellIdentifier3];
        
        if (cell == nil) {
            [_tbShowIndent registerNib:[UINib nibWithNibName:@"IndentOrderInfoCell" bundle:nil] forCellReuseIdentifier:cellIdentifier3];
            cell = [_tbShowIndent dequeueReusableCellWithIdentifier:cellIdentifier3];
        }
        
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        IndentModel *indentModel = [_arrayIndent objectAtIndex:indexPath.row];
        
        cell.lbBookPublisher.text = indentModel.bookPublisher;
        [cell.iVBookCover sd_setImageWithURL:[NSURL URLWithString:indentModel.bookCover]];
        cell.tVBookName.text = indentModel.bookName;
        cell.lbBookPrice.text = [NSString stringWithFormat:@"¥ %.2f",indentModel.bookPrice];
        
        return cell;
    } else {
        static NSString *cellIdentifier4 = @"cellIdentifier4";
        
        BargainTimeInfoCell *cell = [_tbShowIndent dequeueReusableCellWithIdentifier:cellIdentifier4];
        
        if (cell == nil) {
            [_tbShowIndent registerNib:[UINib nibWithNibName:@"BargainTimeInfoCell" bundle:nil] forCellReuseIdentifier:cellIdentifier4];
            cell = [_tbShowIndent dequeueReusableCellWithIdentifier:cellIdentifier4];
        }
        
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        IndentModel *indentModel = [_arrayIndent objectAtIndex:indexPath.row];
        
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
        NSString *bargainTimeStr = [dateFormatter stringFromDate:indentModel.bargainTime];
        
        cell.lbBargainTime.text = [NSString stringWithFormat:@"%@",bargainTimeStr];
        
        return cell;
    }
    
    return cell;
}


-(CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 0) {
        if (indexPath.row == 0) {
            return 40;
        } else {
            return 120;
        }
    } else if (indexPath.section == 1) {
        return 140;
    } else {
        return 60;
    }
}


-(CGFloat) tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 0;
}


-(CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 30;
}


-(NSString *) tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    if (section == 0) {
        return @"以下是交易状态";
    } else if (section == 1) {
        return @"以下是订单详细信息";
    } else {
        return @"以下是成交时间";
    }
}

//检查是否已经评论
-(void) connectionWithURLToCheckIsComment{
    NSLog(@"方法被调用");
    
    _ipAndHost = Init_IP;
    _request = [NSString stringWithFormat:@"checkIsComment.html?indentId=%ld",_indentID];
    
    _request = [_request stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    NSString *strURL = [NSString stringWithFormat:@"%@/%@", _ipAndHost, _request];
    NSURL *url = [NSURL URLWithString:strURL];
    
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    _connect = [NSURLConnection connectionWithRequest:request delegate:self];
    _data = [[NSMutableData alloc] init];
}

//获取订单详情的连接方法
-(void) connectionWithURLToGetIndentDetailInfo{
    NSLog(@"方法被调用");
    
    _ipAndHost = Init_IP;
    _getIndentRequest = [NSString stringWithFormat:@"getIndentDetailInfo.html?indentId=%ld",_indentID];
    
    _getIndentRequest = [_getIndentRequest stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    NSString *strURL = [NSString stringWithFormat:@"%@/%@", _ipAndHost, _getIndentRequest];
    NSURL *url = [NSURL URLWithString:strURL];
    
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    _getIndentConnect = [NSURLConnection connectionWithRequest:request delegate:self];
    _getIndentData = [[NSMutableData alloc] init];
}


-(void) connection:(NSURLConnection *)connection didFailWithError:(NSError *)error{
    if (connection == _connect) {
        NSLog(@"错误发生，为%@错误",error);
    } else if (connection == _getIndentConnect) {
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
    } else if (connection == _getIndentConnect) {
        [_getIndentData appendData:data];
        [self praseDateWithData:_getIndentData];
    }
}


-(void)connectionDidFinishLoading:(NSURLConnection *)connection{
    if (connection == _connect) {
        NSString *str = [[NSString alloc] initWithData:_data encoding:NSUTF8StringEncoding];
        [self dealWithIsComment:str];
    } else if (connection == _getIndentConnect) {
        
    }
}

//处理是否已评价的方法，如果已评价，则在下面显示已经评价的Label，如果未评价，则在下面显示评价的按钮
-(void)dealWithIsComment:(NSString *)strInfo{
    _bargainState = strInfo;
    if ([strInfo isEqualToString:@"0"]) {
        _btnNotComment = [UIButton buttonWithType:UIButtonTypeSystem];
        _btnNotComment.frame = CGRectMake(0, ScreenHeight - 114, ScreenWidth, 50);
        [_btnNotComment setTitle:@"评价" forState:UIControlStateNormal];
        [_btnNotComment setTintColor:[UIColor whiteColor]];
        _btnNotComment.titleLabel.font = [UIFont systemFontOfSize:17];
        [_btnNotComment setBackgroundColor:[UIColor colorWithRed:251.0/255.0 green:0.0/255.0 blue:42.0/255.0 alpha:1]];
        [_btnNotComment addTarget:self action:@selector(pressBtnNotComment) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:_btnNotComment];
    } else {
        _lbCommented = [[UILabel alloc] init];
        _lbCommented.frame = CGRectMake(0, ScreenHeight - 114, ScreenWidth, 50);
        _lbCommented.text = @"已评价";
        _lbCommented.textColor = [UIColor whiteColor];
        _lbCommented.textAlignment = NSTextAlignmentCenter;
        _lbCommented.backgroundColor = [UIColor colorWithRed:251.0/255.0 green:0.0/255.0 blue:42.0/255.0 alpha:1];
        [self.view addSubview:_lbCommented];
    }
    
}

//前往评价的方法
-(void) pressBtnNotComment{
    CommentVC *commentVC = [[CommentVC alloc] init];
    IndentModel *indentModel = [_arrayIndent objectAtIndex:0];
    commentVC.bookID = indentModel.bookID;
    commentVC.bookCover = indentModel.bookCover;
    commentVC.bookName = indentModel.bookName;
    commentVC.indentId = indentModel.indentId;
    [self.navigationController pushViewController:commentVC animated:YES];
}

//解析订单数据的方法
-(void) praseDateWithData:(NSMutableData *) data{
    NSArray *arrRoot = [NSJSONSerialization JSONObjectWithData:_getIndentData options:NSJSONReadingMutableContainers error:nil];
    _arrayIndent = [[NSMutableArray alloc] init];
    
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
        
        [_arrayIndent addObject:indentModel];
    }
    
    [_tbShowIndent reloadData];
}

@end
