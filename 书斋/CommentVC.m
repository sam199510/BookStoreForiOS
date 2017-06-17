//
//  CommentVC.m
//  书斋
//
//  Created by 飞 on 2017/6/17.
//  Copyright © 2017年 Sam. All rights reserved.
//

#import "CommentVC.h"
#import "CommentSuccessfulVC.h"

#import "UIImageView+WebCache.h"

#import "IPConfig.h"

#define ScreenWidth CGRectGetWidth([UIScreen mainScreen].bounds)
#define ScreenHeight CGRectGetHeight([UIScreen mainScreen].bounds)

@interface CommentVC ()<UITextViewDelegate>

{
    NSURLConnection *_connect;
    NSMutableData *_data;
    NSString *_ipAndHost;
    NSString *_request;
}

@property (strong, nonatomic) IBOutlet UIImageView *iVBookCover;
@property (strong, nonatomic) IBOutlet UILabel *lbBookName;
@property (strong, nonatomic) IBOutlet UILabel *lbCommentContentPlaceholder;
@property (strong, nonatomic) IBOutlet UITextView *tVCommentContent;
@property (strong, nonatomic) IBOutlet UILabel *lbCheckComment;
@property (strong, nonatomic) IBOutlet UIButton *btnSubmitCommentContent;

@end

@implementation CommentVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.title = @"评价";
    
    //键盘收回
    self.view.userInteractionEnabled = YES;
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(fingetTap:)];
    [self.view addGestureRecognizer:singleTap];
    
    [_iVBookCover sd_setImageWithURL:[NSURL URLWithString:_bookCover]];
    _lbBookName.text = _bookName;
    
    _tVCommentContent.delegate = self;
    
    UIToolbar *proAreatoolBar=[[UIToolbar alloc] init];
    proAreatoolBar.frame=CGRectMake(0, 0, ScreenWidth, 38);
    UIBarButtonItem *proAreaCancelBtn=[[UIBarButtonItem alloc] initWithTitle:@"取消" style:UIBarButtonItemStylePlain target:self action:@selector(pressCancel:)];
    UIBarButtonItem *proAreaConfigBtn=[[UIBarButtonItem alloc] initWithTitle:@"完成" style:UIBarButtonItemStylePlain target:self action:@selector(pressCancel:)];
    UIBarButtonItem *proAreaSpaceBtn=[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    proAreatoolBar.items=@[proAreaCancelBtn,proAreaSpaceBtn,proAreaConfigBtn];
    
    _tVCommentContent.inputAccessoryView=proAreatoolBar;
    
    [_btnSubmitCommentContent addTarget:self action:@selector(pressToCommentBook) forControlEvents:UIControlEventTouchUpInside];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//键盘收回
-(void) fingetTap:(UITapGestureRecognizer *)gestureRecognizer{
    [self.view endEditing:YES];
}

//定义取消事件
-(void)pressCancel:(UITapGestureRecognizer *)gestureRecognizer{
    [self fingetTap:gestureRecognizer];
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/


- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text{
    if (![text isEqualToString:@""]){
        _lbCommentContentPlaceholder.hidden = YES;
    }
    
    if ([text isEqualToString:@""] && range.location == 0 && range.length == 1){
        _lbCommentContentPlaceholder.hidden = NO;
    }
    
    return YES;
}


-(void)pressToCommentBook{
    BOOL isComment;
    
    if (_tVCommentContent.text.length == 0) {
        _lbCheckComment.text = @"评价内容不能为空，亲，写点评价吧!";
        isComment = NO;
    } else {
        _lbCheckComment.text = @"";
        isComment = YES;
    }
    
    if (isComment == YES) {
        [self connectionWithURLToCommentBook];
    }
}


-(void) connectionWithURLToCommentBook{
    NSLog(@"方法被调用");
    
    _ipAndHost = Init_IP;
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *strUserName = [userDefaults objectForKey:@"userName"];
    
    _request = [NSString stringWithFormat:@"commentBook.html?userName=%@&bookId=%ld&content=%@&indentId=%ld",strUserName,_bookID,_tVCommentContent.text,_indentId];
    
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
}


-(void)connectionDidFinishLoading:(NSURLConnection *)connection{
    NSString *str = [[NSString alloc] initWithData:_data encoding:NSUTF8StringEncoding];
    [self parseDataWithData:str];
}


-(void)parseDataWithData:(NSString *) str{
    NSLog(@"%@",str);
    
    CommentSuccessfulVC *commentSuccessfulVC = [[CommentSuccessfulVC alloc] init];
    
    [self.navigationController pushViewController:commentSuccessfulVC animated:YES];
}

@end
