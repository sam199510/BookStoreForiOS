//
//  CollectionVC.m
//  书斋
//
//  Created by 飞 on 2017/6/11.
//  Copyright © 2017年 Sam. All rights reserved.
//

#import "CollectionVC.h"
#import "CollectionTableViewCell.h"
#import "ShowBookDetailVC.h"
#import "LoginVC.h"

#import "CollectionModel.h"

#import "UIImageView+WebCache.h"

#import "IPConfig.h"

//收藏视图
@interface CollectionVC ()<UIViewControllerPreviewingDelegate,UITableViewDelegate,UITableViewDataSource>

{
    BOOL _isEdit;
    
    NSURLConnection *_connect;
    NSURLConnection *_cancelToCollectBookConnect;
    NSMutableData *_data;
    NSMutableData *_cancelToCollectBookData;
    NSMutableArray *_arrayBooks;
    NSString *_ipAndHost;
    NSString *_request;
    NSString *_cancelToCollectBookRequest;
}

@property (strong, nonatomic) IBOutlet UITableView *tbCollection;

@property (strong, nonatomic) UIBarButtonItem *rightEditBtn;
@property (strong, nonatomic) UIBarButtonItem *rightDoneBtn;

@end

@implementation CollectionVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.title = @"我的收藏";
    [self.navigationController.navigationBar setTintColor:[UIColor whiteColor]];
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor whiteColor]}];
    self.navigationController.navigationBar.translucent = NO;
    
    _tbCollection.dataSource = self;
    _tbCollection.delegate = self;
    
    [self createBtn];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) viewWillAppear:(BOOL)animated{
    [super viewWillAppear:YES];
    
    [self connectionWithURLToGetCollectionBook];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
 */

-(void) createBtn{
    _isEdit = NO;
    
    _rightEditBtn = [[UIBarButtonItem alloc] initWithTitle:@"编辑" style:UIBarButtonItemStylePlain target:self action:@selector(pressEditTableView)];
    self.navigationItem.rightBarButtonItem = _rightEditBtn;
    _rightDoneBtn = [[UIBarButtonItem alloc] initWithTitle:@"完成" style:UIBarButtonItemStylePlain target:self action:@selector(pressDoneTableView)];
}


-(void)pressEditTableView{
    _isEdit = YES;
    [_tbCollection setEditing:YES animated:YES];
    self.navigationItem.rightBarButtonItem = _rightDoneBtn;
}


-(void)pressDoneTableView{
    _isEdit = NO;
    [_tbCollection setEditing:NO animated:YES];
    self.navigationItem.rightBarButtonItem = _rightEditBtn;
}


//表格方法
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}


-(NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (section == 0) {
        return _arrayBooks.count;
    } else {
        return 0;
    }
}


-(UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *cellIdentifier = @"collectionCellIdentifier";
    
    CollectionTableViewCell *cell = [_tbCollection dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (cell == nil) {
        [_tbCollection registerNib:[UINib nibWithNibName:@"CollectionTableViewCell" bundle:nil] forCellReuseIdentifier:cellIdentifier];
        cell = [_tbCollection dequeueReusableCellWithIdentifier:cellIdentifier];
    }
    
    //判断3D Touch是否可用，可用的话就去注册
    if (self.traitCollection.forceTouchCapability == UIForceTouchCapabilityAvailable) {
        [self registerForPreviewingWithDelegate:self sourceView:cell];
    }
    
    if (indexPath.section == 0) {
        CollectionModel *collectionModel = [_arrayBooks objectAtIndex:indexPath.row];
        
        cell.tVBookName.text = collectionModel.bookName;
        cell.lbBookPrice.text = [NSString stringWithFormat:@"¥ %.2f", collectionModel.bookPrice];
        [cell.iVCollectBookCover sd_setImageWithURL:[NSURL URLWithString:collectionModel.bookCover]];
    }
    
    return cell;
}


-(CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 0) {
        return 120;
    } else {
        return 0;
    }
}


-(NSString *) tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        return @"以下是收藏的书目";
    } else {
        return @"";
    }
}


-(NSString *) tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section {
    if (section == 0) {
        return @"没有收藏的书目了";
    } else {
        return @"";
    }
}


-(void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 0) {
        [_tbCollection deselectRowAtIndexPath:indexPath animated:YES];
        CollectionModel *collectModel = [_arrayBooks objectAtIndex:indexPath.row];
        
        ShowBookDetailVC *showBookDetailVC = [[ShowBookDetailVC alloc] init];
        showBookDetailVC.bookID = collectModel.bookID;
        
        [self.navigationController pushViewController:showBookDetailVC animated:YES];
        
    }
}


-(void) tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 0) {
        NSArray *arrayDeleteCollections = [NSArray arrayWithObject:indexPath];
        
        if (editingStyle == UITableViewCellEditingStyleDelete) {
            
            CollectionModel *collectionModel = [_arrayBooks objectAtIndex:indexPath.row];
            NSInteger bookID = collectionModel.bookID;
            
            [self connectionWithURLToCancelCollectBook:bookID];
            
            [_arrayBooks removeObjectAtIndex:indexPath.row];
            [_tbCollection deleteRowsAtIndexPaths:arrayDeleteCollections withRowAnimation:UITableViewRowAnimationFade];
        }
    }
    [_tbCollection reloadData];
}


- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath {
    return @"删除";
}


//以下两个方法为3DTouch的方法
-(nullable UIViewController *)previewingContext:(id<UIViewControllerPreviewing>)previewingContext viewControllerForLocation:(CGPoint)location{
    NSIndexPath *indexPaht = [_tbCollection indexPathForCell:(UITableViewCell *)[previewingContext sourceView]];
    CollectionModel *collectionModel = [_arrayBooks objectAtIndex:indexPaht.row];
    
    //设定预览界面
    ShowBookDetailVC *showBookDetailVC = [[ShowBookDetailVC alloc] init];
    showBookDetailVC.preferredContentSize = CGSizeMake(0, 0);
    showBookDetailVC.bookID = collectionModel.bookID;
    return showBookDetailVC;
}


-(void)previewingContext:(id<UIViewControllerPreviewing>)previewingContext commitViewController:(UIViewController *)viewControllerToCommit{
    viewControllerToCommit.hidesBottomBarWhenPushed = YES;
    [self showViewController:viewControllerToCommit sender:self];
}

//获取收藏的图书的方法
-(void) connectionWithURLToGetCollectionBook{
    NSLog(@"方法被调用");
    
    _ipAndHost = Init_IP;
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *strUserName = [userDefaults objectForKey:@"userName"];
    
    if (!strUserName) {
        LoginVC *loginVC = [[LoginVC alloc] init];
        [self presentViewController:loginVC animated:YES completion:nil];
    } else {
        NSString *strRequest = [NSString stringWithFormat:@"showCollectBooks.html?userName=%@",strUserName];
        _request = strRequest;
        
        _request = [_request stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
        
        NSString *strURL = [NSString stringWithFormat:@"%@/%@", _ipAndHost, _request];
        NSURL *url = [NSURL URLWithString:strURL];
        NSURLRequest *request = [NSURLRequest requestWithURL:url];
        _connect = [NSURLConnection connectionWithRequest:request delegate:self];
        _data = [[NSMutableData alloc] init];
    }
}


//取消收藏方法
-(void) connectionWithURLToCancelCollectBook:(NSInteger) bookID{
    NSLog(@"方法被调用");
    
    _ipAndHost = Init_IP;
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *strUserName = [userDefaults objectForKey:@"userName"];
    
    
    
    NSString *strRequest = [NSString stringWithFormat:@"cancelToCollectBook.html?bookID=%ld&userName=%@",bookID,strUserName];
    _cancelToCollectBookRequest = strRequest;
    
    _cancelToCollectBookRequest = [_cancelToCollectBookRequest stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    
    NSString *strURL = [NSString stringWithFormat:@"%@/%@", _ipAndHost, _cancelToCollectBookRequest];
    NSURL *url = [NSURL URLWithString:strURL];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    _cancelToCollectBookConnect = [NSURLConnection connectionWithRequest:request delegate:self];
    _cancelToCollectBookData = [[NSMutableData alloc] init];
}


-(void) connection:(NSURLConnection *)connection didFailWithError:(NSError *)error{
    if (connection == _connect) {
        NSLog(@"错误发生，为%@错误",error);
    } else if (connection == _cancelToCollectBookConnect) {
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
    } else if (connection == _cancelToCollectBookConnect) {
        [_cancelToCollectBookData appendData:data];
    }
}


-(void)connectionDidFinishLoading:(NSURLConnection *)connection{
    if (connection == _connect) {
        //NSString *str = [[NSString alloc] initWithData:_data encoding:NSUTF8StringEncoding];
        [self parseDataWithData];
    } else if (connection == _cancelToCollectBookConnect) {
        NSString *str = [[NSString alloc] initWithData:_cancelToCollectBookData encoding:NSUTF8StringEncoding];
        NSLog(@"%@",str);
    }
   
}

//解析数据的方法
-(void)parseDataWithData{
    NSArray *arrRoot = [NSJSONSerialization JSONObjectWithData:_data options:NSJSONReadingMutableContainers error:nil];
    _arrayBooks = [[NSMutableArray alloc] init];
    
    for (int i = 0; i < arrRoot.count; i++) {
        NSDictionary *dicBook = [arrRoot objectAtIndex:i];
        
        NSInteger bookID = [[dicBook objectForKey:@"bookID"] integerValue];
        NSInteger collectID = [[dicBook objectForKey:@"id"] integerValue];
        NSInteger collectorID = [[dicBook objectForKey:@"collectorID"] integerValue];
        NSString *bookName = [dicBook objectForKey:@"bookName"];
        NSString *bookCover = [dicBook objectForKey:@"bookCover"];
        float bookPrice = [[dicBook objectForKey:@"bookPrice"] floatValue];
        
        CollectionModel *collectionModel = [[CollectionModel alloc] init];
        collectionModel.collectID = collectID;
        collectionModel.bookID = bookID;
        collectionModel.collectorID = collectorID;
        collectionModel.bookName = bookName;
        collectionModel.bookCover = bookCover;
        collectionModel.bookPrice = bookPrice;
        
        [_arrayBooks addObject:collectionModel];
        
    }
    [_tbCollection reloadData];
}

@end
