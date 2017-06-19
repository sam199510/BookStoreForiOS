//
//  HomeVC.m
//  书斋
//
//  Created by 飞 on 2017/6/8.
//  Copyright © 2017年 Sam. All rights reserved.
//

#import "HomeVC.h"
#import "BookModel.h"
#import "BookTableViewCell.h"
#import "ShowBookDetailVC.h"

#import "UIImageView+WebCache.h"
#import "SDCycleScrollView.h"

#import "IPConfig.h"

#define ScreenWidth CGRectGetWidth([UIScreen mainScreen].bounds)
#define ScreenHeight CGRectGetHeight([UIScreen mainScreen].bounds)

@interface HomeVC ()<UIViewControllerPreviewingDelegate,UITableViewDelegate,UITableViewDataSource,UIScrollViewDelegate,NSURLConnectionDelegate,NSURLConnectionDataDelegate,SDCycleScrollViewDelegate>

{
    NSURLConnection *_connect;
    NSMutableData *_data;
    NSMutableArray *_arrayBooks;
    NSString *_ipAndHost;
    NSString *_request;
}

@property (strong, nonatomic) UITableView *tableView;

@property (retain, nonatomic) NSTimer *rotateTimer;
@property (retain, nonatomic) UIPageControl *myPageControl;

@end

@implementation HomeVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.title = @"首页";
    [self.navigationController.navigationBar setTintColor:[UIColor whiteColor]];
    [self.navigationController.navigationBar setBarTintColor:[UIColor colorWithRed:253.0/255.0 green:109.0/255.0 blue:9.0/255.0 alpha:1]];
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor whiteColor]}];
    self.navigationController.navigationBar.translucent = NO;
    
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, ScreenHeight - 70) style:UITableViewStylePlain];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.contentInset = UIEdgeInsetsMake(200, 0, 0, 0);
    [self.view addSubview:_tableView];
    
    //图片轮播
    NSArray *imageNames = @[@"1.png",@"2.png",@"3.png"];
    NSArray *imageTitles = @[@"读书谓已多，抚事知不足！",@"读书百遍，其义自现！",@"积财千万，无过读书！"];
    
    SDCycleScrollView *cycleScrollView = [SDCycleScrollView cycleScrollViewWithFrame:CGRectMake(0, -200, [UIScreen mainScreen].bounds.size.width, 200) shouldInfiniteLoop:YES imageNamesGroup:imageNames];
    cycleScrollView.delegate = self;
    cycleScrollView.pageControlAliment = SDCycleScrollViewPageContolAlimentRight;
    cycleScrollView.titlesGroup = imageTitles;
    cycleScrollView.currentPageDotColor = [UIColor whiteColor];
    cycleScrollView.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    cycleScrollView.autoScrollTimeInterval = 5.0;
    [_tableView addSubview:cycleScrollView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
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

//以下各个方法为表格的协议方法
-(NSInteger) numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

-(NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _arrayBooks.count;
}

-(UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    static NSString *cellIdentifier = @"cellIdentifier";
    
    BookTableViewCell *cell = [_tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (cell == nil) {
        [_tableView registerNib:[UINib nibWithNibName:@"BookTableViewCell" bundle:nil] forCellReuseIdentifier:cellIdentifier];
        cell = [_tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    }
    
    //判断3D Touch是否可用，可用的话就去注册
    if (self.traitCollection.forceTouchCapability == UIForceTouchCapabilityAvailable) {
        [self registerForPreviewingWithDelegate:self sourceView:cell];
    }
    
    BookModel *bookModel = [_arrayBooks objectAtIndex:indexPath.row];
    [cell.coverImage sd_setImageWithURL:[NSURL URLWithString:bookModel.cover]];
    cell.txtBookName.text = bookModel.bookName;
    cell.txtAuthor.text = bookModel.author;
    cell.txtRepertory.text = [NSString stringWithFormat:@"库存：%ld",bookModel.repertory];
    cell.txtPrice.text = [NSString stringWithFormat:@"¥ %.2f",bookModel.price];
    
    return cell;
    
}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    [_tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    BookModel *bookModel = [_arrayBooks objectAtIndex:indexPath.row];

    ShowBookDetailVC *showBookDetailVC = [[ShowBookDetailVC alloc] init];
    showBookDetailVC.bookID = bookModel.bookId;
    //推进第二级视图时隐藏tabbar
    showBookDetailVC.hidesBottomBarWhenPushed = YES;
    
    [self.navigationController pushViewController:showBookDetailVC animated:YES];
}

//tableView一个Cell的高度
-(CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 140;
}

//以下两个方法为3DTouch的方法
-(nullable UIViewController *)previewingContext:(id<UIViewControllerPreviewing>)previewingContext viewControllerForLocation:(CGPoint)location{
    NSIndexPath *indexPaht = [_tableView indexPathForCell:(UITableViewCell *)[previewingContext sourceView]];
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

//解析每本书的网络连接的方法
-(void) connectionWithURL{
    NSLog(@"方法被调用");
    
    _ipAndHost = Init_IP;
    _request = @"showAllBooks.html";
    
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
    [_tableView reloadData];
}

@end
