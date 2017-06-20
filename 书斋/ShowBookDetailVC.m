//
//  ShowBookDetailVC.m
//  书斋
//
//  Created by 飞 on 2017/6/9.
//  Copyright © 2017年 Sam. All rights reserved.
//

#import "ShowBookDetailVC.h"
#import "BookModel.h"
#import "ShopBookVC.h"
#import "ShowBookCommentCell.h"
#import "ShowBookInfoCell.h"

#import "CommentModel.h"

#import "IPConfig.h"

#import "UIImageView+WebCache.h"

@interface ShowBookDetailVC ()<UITableViewDelegate,UITableViewDataSource>

{
    BOOL isCollect;
    
    NSURLConnection *_connect;
    NSURLConnection *_checkCollectConnect;
    NSURLConnection *_collectBookConnect;
    NSURLConnection *_cancelCollectBookConnect;
    NSURLConnection *_getCommentConnection;
    NSMutableData *_data;
    NSMutableData *_checkCollectData;
    NSMutableData *_collectBookData;
    NSMutableData *_cancelCollectBookData;
    NSMutableData *_getCommentData;
    NSString *_ipAndHost;
    NSString *_request;
    NSString *_checkCollectRequest;
    NSString *_collectBookRequest;
    NSString *_cancelCollectBookRequest;
    NSString *_getCommentRequest;
    
    NSMutableArray *_arrayBooks;
    NSMutableArray *_arrayComments;
}

@property (strong, nonatomic) IBOutlet UITableView *tbComment;

@property (strong, nonatomic) IBOutlet UIButton *btnCollect;
@property (strong, nonatomic) IBOutlet UIButton *btnBuy;

@end

@implementation ShowBookDetailVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.title = @"书目详情";
    [self.navigationController.navigationBar setTintColor:[UIColor whiteColor]];
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor whiteColor]}];
    self.navigationController.navigationBar.translucent = NO;
    
    _tbComment.dataSource = self;
    _tbComment.delegate = self;
    
    [_btnCollect addTarget:self action:@selector(collectOrCancelToCollect) forControlEvents:UIControlEventTouchUpInside];
    [_btnBuy addTarget:self action:@selector(shopBook) forControlEvents:UIControlEventTouchUpInside];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(void) viewWillAppear:(BOOL)animated{
    [super viewWillAppear:YES];
    
    [self connectionWithURL];
    [self connectionWithURLToCheckIsCollect];
    [self connectionWithURLToGetCommentByBookID];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

//以下方法为表格方法
-(NSInteger) numberOfSectionsInTableView:(UITableView *)tableView{
    return 2;
}


-(NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (section == 0) {
        return 1;
    } else {
        return _arrayComments.count;
    }
}


-(CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 0) {
        return 245;
    } else {
        return 120;
    }
}


-(CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 30;
}


-(CGFloat) tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 30;
}


-(UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *cellIdentifier = @"cellIdentifier";
    
    UITableViewCell *cell = [_tbComment dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    
    if (indexPath.section == 0) {
        static NSString *cellIdentifier1 = @"cellIdentifier1";
        
        ShowBookInfoCell *cell = [_tbComment dequeueReusableCellWithIdentifier:cellIdentifier1];
        if (cell == nil) {
            [_tbComment registerNib:[UINib nibWithNibName:@"ShowBookInfoCell" bundle:nil] forCellReuseIdentifier:cellIdentifier1];
            cell = [_tbComment dequeueReusableCellWithIdentifier:cellIdentifier1];
        }
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        BookModel *bookModel = [_arrayBooks objectAtIndex:indexPath.row];
        
        cell.lbBookName.text = bookModel.bookName;
        [cell.iVBookCover sd_setImageWithURL:[NSURL URLWithString:bookModel.cover]];
        cell.lbAuthor.text = [NSString stringWithFormat:@"作者：%@",bookModel.author] ;
        cell.lbPublisher.text = [NSString stringWithFormat:@"出版社：%@",bookModel.publisher] ;
        cell.lbISBN.text = [NSString stringWithFormat:@"ISBN：%li",bookModel.isbn];
        cell.lbBookPrice.text = [NSString stringWithFormat:@"¥ %.2f",bookModel.price];
        cell.lbRepertory.text = [NSString stringWithFormat:@"库存：%ld", bookModel.repertory];
        cell.tVBookIntroduce.text = bookModel.introduce;
        
        return cell;
    } else if (indexPath.section == 1) {
        static NSString *cellIdentifier2 = @"cellIdentifier2";
        
        ShowBookCommentCell *cell = [_tbComment dequeueReusableCellWithIdentifier:cellIdentifier2];
        if (cell == nil) {
            [_tbComment registerNib:[UINib nibWithNibName:@"ShowBookCommentCell" bundle:nil] forCellReuseIdentifier:cellIdentifier2];
            cell = [_tbComment dequeueReusableCellWithIdentifier:cellIdentifier2];
        }
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        CommentModel *commentModel = [_arrayComments objectAtIndex:indexPath.row];
        
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"yyyy-MM-dd"];
        NSString *bargainTimeStr = [dateFormatter stringFromDate:commentModel.commentTime];
        
        cell.lbCommentName.text = commentModel.buyerName;
        cell.lbCommentTime.text = bargainTimeStr;
        cell.tvCommentContent.text = commentModel.content;
        
        return cell;
    }
    
    return cell;
}


-(NSString *) tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    if (section == 0) {
        return @"";
    } else {
        return @"以下是关于这本书的评价";
    }
}


-(NSString *) tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section{
    if (section == 0) {
        return @"";
    } else {
        return @"没有更多的评价了";
    }
}


//解析图书
-(void) connectionWithURL{
    NSLog(@"方法被调用");
    
    _ipAndHost = Init_IP;
    NSString *strRequest = [NSString stringWithFormat:@"showBookDetailInfo.html?bookID=%ld",_bookID];
    _request = strRequest;
    
    _request = [_request stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    
    NSString *strURL = [NSString stringWithFormat:@"%@/%@", _ipAndHost, _request];
    NSURL *url = [NSURL URLWithString:strURL];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    _connect = [NSURLConnection connectionWithRequest:request delegate:self];
    _data = [[NSMutableData alloc] init];
}

//检查是否收藏
-(void) connectionWithURLToCheckIsCollect{
    NSLog(@"方法被调用");
    
    _ipAndHost = Init_IP;
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *strUserName = [userDefaults objectForKey:@"userName"];
    
    NSString *strRequest = [NSString stringWithFormat:@"checkIsCollect.html?bookID=%ld&userName=%@",_bookID,strUserName];
    _checkCollectRequest = strRequest;
    
    _checkCollectRequest = [_checkCollectRequest stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    
    NSString *strURL = [NSString stringWithFormat:@"%@/%@", _ipAndHost, _checkCollectRequest];
    NSURL *url = [NSURL URLWithString:strURL];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    _checkCollectConnect = [NSURLConnection connectionWithRequest:request delegate:self];
    _checkCollectData = [[NSMutableData alloc] init];
}

//收藏方法
-(void) connectionWithURLToCollectBook{
    NSLog(@"方法被调用");
    
    _ipAndHost = Init_IP;
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *strUserName = [userDefaults objectForKey:@"userName"];
    
    NSString *strRequest = [NSString stringWithFormat:@"collectBook.html?bookID=%ld&userName=%@",_bookID,strUserName];
    _collectBookRequest = strRequest;
    
    _collectBookRequest = [_collectBookRequest stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    
    NSString *strURL = [NSString stringWithFormat:@"%@/%@", _ipAndHost, _collectBookRequest];
    NSURL *url = [NSURL URLWithString:strURL];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    _collectBookConnect = [NSURLConnection connectionWithRequest:request delegate:self];
    _collectBookData = [[NSMutableData alloc] init];
}

//取消收藏方法
-(void) connectionWithURLToCancelCollectBook{
    NSLog(@"方法被调用");
    
    _ipAndHost = Init_IP;
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *strUserName = [userDefaults objectForKey:@"userName"];
    
    NSString *strRequest = [NSString stringWithFormat:@"cancelToCollectBook.html?bookID=%ld&userName=%@",_bookID,strUserName];
    _cancelCollectBookRequest = strRequest;
    
    _cancelCollectBookRequest = [_cancelCollectBookRequest stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    
    NSString *strURL = [NSString stringWithFormat:@"%@/%@", _ipAndHost, _cancelCollectBookRequest];
    NSURL *url = [NSURL URLWithString:strURL];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    _cancelCollectBookConnect = [NSURLConnection connectionWithRequest:request delegate:self];
    _cancelCollectBookData = [[NSMutableData alloc] init];
}

//获取图书评论的方法
-(void) connectionWithURLToGetCommentByBookID{
    NSLog(@"方法被调用");
    
    _ipAndHost = Init_IP;
    _getCommentRequest = [NSString stringWithFormat:@"getCommentByBookID.html?bookId=%ld", _bookID];
    
    _getCommentRequest = [_getCommentRequest stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    
    NSString *strURL = [NSString stringWithFormat:@"%@/%@", _ipAndHost, _getCommentRequest];
    NSURL *url = [NSURL URLWithString:strURL];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    _getCommentConnection = [NSURLConnection connectionWithRequest:request delegate:self];
    _getCommentData = [[NSMutableData alloc] init];
}


-(void) connection:(NSURLConnection *)connection didFailWithError:(NSError *)error{
    if (connection == _connect) {
        NSLog(@"错误发生，为%@错误",error);
    } else if (connection == _checkCollectConnect) {
        NSLog(@"错误发生，为%@错误",error);
    } else if (connection == _collectBookConnect) {
        NSLog(@"错误发生，为%@错误",error);
    } else if (connection == _cancelCollectBookConnect ) {
        NSLog(@"错误发生，为%@错误",error);
    } else if (connection == _getCommentConnection) {
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
    } else if (connection == _checkCollectConnect) {
        [_checkCollectData appendData:data];
    } else if (connection == _collectBookConnect) {
        [_collectBookData appendData:data];
    } else if (connection == _cancelCollectBookConnect) {
        [_cancelCollectBookData appendData:data];
    } else if (connection == _getCommentConnection) {
        [_getCommentData appendData:data];
    }
    
}


-(void)connectionDidFinishLoading:(NSURLConnection *)connection{
    //NSString *str = [[NSString alloc] initWithData:_data encoding:NSUTF8StringEncoding];
    if (connection == _connect) {
        [self parseDataWithData];
    } else if (connection == _checkCollectConnect) {
//        [_checkCollectData appendData:data];
        NSString *str = [[NSString alloc] initWithData:_checkCollectData encoding:NSUTF8StringEncoding];
        [self dealCollectBtnWithCheckStr:str];
    } else if (connection == _collectBookConnect) {
        NSString *str = [[NSString alloc] initWithData:_collectBookData encoding:NSUTF8StringEncoding];
        [self dealCollectBook:str];
    } else if (connection == _cancelCollectBookConnect) {
        NSString *str = [[NSString alloc] initWithData:_cancelCollectBookData encoding:NSUTF8StringEncoding];
        [self dealCancelCollectBook:str];
    } else if (connection == _getCommentConnection) {
        [self parseCommentDataWithData];
    }
}

//解析书目详情的连接
-(void)parseDataWithData{
    NSArray *arrRoot = [NSJSONSerialization JSONObjectWithData:_data options:NSJSONReadingMutableContainers error:nil];
    _arrayBooks = [[NSMutableArray alloc] init];
    
    for (int i = 0; i < arrRoot.count; i++) {
        NSDictionary *dicBook = [arrRoot objectAtIndex:i];
        
        NSInteger bookId = [[dicBook objectForKey:@"id"] integerValue];
        NSString *bookName = [dicBook objectForKey:@"bookName"];
        NSString *author = [dicBook objectForKey:@"author"];
        float price = [[dicBook objectForKey:@"price"] floatValue];
        NSString *introduce = [dicBook objectForKey:@"introduce"];
        NSString *publisher = [dicBook objectForKey:@"publisher"];
        long isbn = [[dicBook objectForKey:@"isbn"] longValue];
        NSInteger repertory = [[dicBook objectForKey:@"repertory"] integerValue];
        NSString *cover = [dicBook objectForKey:@"cover"];
        
        BookModel *bookModel = [[BookModel alloc] init];
        bookModel.bookId = bookId;
        bookModel.bookName = bookName;
        bookModel.author = author;
        bookModel.price = price;
        bookModel.introduce = introduce;
        bookModel.publisher = publisher;
        bookModel.isbn = isbn;
        bookModel.repertory = repertory;
        bookModel.cover = cover;
        
        [_arrayBooks addObject:bookModel];
    }
    [_tbComment reloadData];
}

//进入应用预先检查并处理收藏按钮
-(void) dealCollectBtnWithCheckStr:(NSString *)checkStr{
    //checkStr为网络相应的字符串。如果为“0”，则设置为收藏；如果为“1”，则设置为取消收藏。
    if ([checkStr isEqualToString:@"0"]) {
        [_btnCollect setTitle:@"收藏" forState:UIControlStateNormal];
        isCollect = YES;
    } else if ([checkStr isEqualToString:@"1"]) {
        [_btnCollect setTitle:@"取消收藏" forState:UIControlStateNormal];
        isCollect = NO;
    }
}


//调整按钮样式为取消收藏
-(void) dealCollectBook:(NSString *)str {
    NSLog(@"%@",str);
    [_btnCollect setTitle:@"取消收藏" forState:UIControlStateNormal];
}

//调整按钮样式为收藏
-(void) dealCancelCollectBook:(NSString *)str {
    NSLog(@"%@",str);
    [_btnCollect setTitle:@"收藏" forState:UIControlStateNormal];
}

//收藏按钮方法
-(void) collectOrCancelToCollect{
    //如果isCollec为YES，则连接服务器收藏图书，如果为NO，则连接服务器取消收藏图书
    if (isCollect == YES) {
        [self connectionWithURLToCollectBook];
        isCollect = NO;
    } else {
        [self connectionWithURLToCancelCollectBook];
        isCollect = YES;
    }
}

//购买方法
-(void)shopBook{
    ShopBookVC *shopBookVC = [[ShopBookVC alloc] init];
    shopBookVC.bookID = _bookID;
    [self.navigationController pushViewController:shopBookVC animated:YES];
}

//解析评论的方法
-(void)parseCommentDataWithData{
    NSArray *arrRoot = [NSJSONSerialization JSONObjectWithData:_getCommentData options:NSJSONReadingMutableContainers error:nil];
    _arrayComments = [[NSMutableArray alloc] init];
    
    for (int i = 0; i < arrRoot.count; i++) {
        NSDictionary *dicComment = [arrRoot objectAtIndex:i];
        
        NSInteger bookID = [[dicComment objectForKey:@"bookID"] integerValue];
        NSInteger buyerID = [[dicComment objectForKey:@"buyerID"] integerValue];
        NSString *buyerName = [dicComment objectForKey:@"buyerName"];
        
        //获取从SSH框架中获取的时间戳
        NSTimeInterval bargainTimeInterval = [[dicComment objectForKey:@"commentTime"] integerValue]/1000;
        //创建日期格式对象
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        //设置日期格式
        [formatter setDateFormat:@"yyyy-MM-dd"];
        //将时间戳转换成NSDate对象
        NSDate *commentTimeDate = [NSDate dateWithTimeIntervalSince1970:bargainTimeInterval];
        //将转换成的NSDate对象格式化到一个NSString格式的字符串中
        NSString *commentTimeString = [formatter stringFromDate:commentTimeDate];
        //将格式化的日期的NSString字符串转换到一个NSDate中，以便之后Model中使用
        NSDate *commentTime = [formatter dateFromString:commentTimeString];
        
        NSString *content = [dicComment objectForKey:@"content"];
        NSInteger commentId = [[dicComment objectForKey:@"id"] integerValue];
        
        CommentModel *commentModel = [[CommentModel alloc] init];
        commentModel.commentId = commentId;
        commentModel.bookId = bookID;
        commentModel.buyerId = buyerID;
        commentModel.buyerName = buyerName;
        commentModel.commentTime = commentTime;
        commentModel.content = content;
        
        [_arrayComments addObject:commentModel];
    }
    [_tbComment reloadData];
}

@end
