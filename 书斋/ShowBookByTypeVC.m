//
//  ShowBookByTypeVC.m
//  书斋
//
//  Created by 飞 on 2017/6/20.
//  Copyright © 2017年 Sam. All rights reserved.
//

#import "ShowBookByTypeVC.h"
#import "BookTableViewCell.h"
#import "ShowBookDetailVC.h"

#import "BookModel.h"

#import "IPConfig.h"

#import "UIImageView+WebCache.h"

@interface ShowBookByTypeVC ()<UIViewControllerPreviewingDelegate,UITableViewDelegate,UITableViewDataSource>

{
    NSURLConnection *_connect;
    NSMutableData *_data;
    NSMutableArray *_arrayBooks;
    NSString *_ipAndHost;
    NSString *_request;
}

@property (strong, nonatomic) IBOutlet UITableView *tbShowBookByType;

@end

@implementation ShowBookByTypeVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    if (_bookType == 0) {
        self.title = @"文学";
    } else if (_bookType == 1) {
        self.title = @"流行";
    } else if (_bookType == 2) {
        self.title = @"文化";
    } else if (_bookType == 3) {
        self.title = @"生活";
    } else {
        self.title = @"科技";
    }
    
    _tbShowBookByType.delegate = self;
    _tbShowBookByType.dataSource = self;
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:YES];
    
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


-(NSInteger) numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}


-(NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _arrayBooks.count;
}


-(UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *cellIdentifier = @"cellIdentifier";
    
    BookTableViewCell *cell = [_tbShowBookByType dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (cell == nil) {
        [_tbShowBookByType registerNib:[UINib nibWithNibName:@"BookTableViewCell" bundle:nil] forCellReuseIdentifier:cellIdentifier];
        cell = [_tbShowBookByType dequeueReusableCellWithIdentifier:cellIdentifier];
    }
    
    //判断3D Touch是否可用，可用的话就去注册
    if (self.traitCollection.forceTouchCapability == UIForceTouchCapabilityAvailable) {
        [self registerForPreviewingWithDelegate:self sourceView:cell];
    }
    
    //Cell中进行解析
    BookModel *bookModel = [_arrayBooks objectAtIndex:indexPath.row];
    [cell.coverImage sd_setImageWithURL:[NSURL URLWithString:bookModel.cover]];
    cell.txtBookName.text = bookModel.bookName;
    cell.txtAuthor.text = bookModel.author;
    cell.txtRepertory.text = [NSString stringWithFormat:@"库存：%ld",bookModel.repertory];
    cell.txtPrice.text = [NSString stringWithFormat:@"¥ %.2f",bookModel.price];

    return cell;
}


-(void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [_tbShowBookByType deselectRowAtIndexPath:indexPath animated:YES];
    
    BookModel *bookModel = [_arrayBooks objectAtIndex:indexPath.row];
    
    ShowBookDetailVC *showBookDetailVC = [[ShowBookDetailVC alloc] init];
    showBookDetailVC.bookID = bookModel.bookId;
    //推进第二级视图时隐藏tabbar
    showBookDetailVC.hidesBottomBarWhenPushed = YES;
    
    [self.navigationController pushViewController:showBookDetailVC animated:YES];
}

//以下两个方法为3DTouch的方法
-(nullable UIViewController *)previewingContext:(id<UIViewControllerPreviewing>)previewingContext viewControllerForLocation:(CGPoint)location{
    NSIndexPath *indexPaht = [_tbShowBookByType indexPathForCell:(UITableViewCell *)[previewingContext sourceView]];
    BookModel *bookModel = [_arrayBooks objectAtIndex:indexPaht.row];
    
    //设定预览界面
    ShowBookDetailVC *showBookDetailVC = [[ShowBookDetailVC alloc] init];
    showBookDetailVC.preferredContentSize = CGSizeMake(0, 0);
    showBookDetailVC.bookID = bookModel.bookId;
    return showBookDetailVC;
}


-(void)previewingContext:(id<UIViewControllerPreviewing>)previewingContext commitViewController:(UIViewController *)viewControllerToCommit{
    viewControllerToCommit.hidesBottomBarWhenPushed = YES;
    [self showViewController:viewControllerToCommit sender:self];
}



-(NSString *) tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (_bookType == 0) {
        return @"以下是关于文学的书本";
    } else if (_bookType == 1) {
        return @"以下是关于流行的书本";
    } else if (_bookType == 2) {
        return @"以下是关于文化的书本";
    } else if (_bookType == 3) {
        return @"以下是关于生活的书本";
    } else {
        return @"以下是关于科技的书本";
    }
}


-(CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 140;
}


//解析每本书的网络连接的方法
-(void) connectionWithURL{
    NSLog(@"方法被调用");
    
    _ipAndHost = Init_IP;
    _request = [NSString stringWithFormat:@"findBookByBookType.html?type=%ld",_bookType];
    
    _request = [_request stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    NSString *strURL = [NSString stringWithFormat:@"%@/%@", _ipAndHost, _request];
    NSURL *url = [NSURL URLWithString:strURL];
    
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    _connect = [NSURLConnection connectionWithRequest:request delegate:self];
    _data = [[NSMutableData alloc] init];
}


-(void) connection:(NSURLConnection *)connection didFailWithError:(NSError *)error{
    NSLog(@"错误发生，为%@错误",error);
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
    [_data appendData:data];
    [self parseDataWithData];
}


-(void)connectionDidFinishLoading:(NSURLConnection *)connection{
    //NSString *str = [[NSString alloc] initWithData:_data encoding:NSUTF8StringEncoding];
}

//解析书本信息到书本数组中
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
    [_tbShowBookByType reloadData];
}

@end
