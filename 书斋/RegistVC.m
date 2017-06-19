//
//  RegistVC.m
//  书斋
//
//  Created by 飞 on 2017/6/8.
//  Copyright © 2017年 Sam. All rights reserved.
//

#import "RegistVC.h"

#import "IPConfig.h"

#define ScreenWidth CGRectGetWidth([UIScreen mainScreen].bounds)

@interface RegistVC ()<UITextViewDelegate,UIPickerViewDelegate,UIPickerViewDataSource,UITextFieldDelegate>

{
    //以下为和网络加载有关的相关参数
    NSURLConnection *_connection;
    NSURLConnection *_registConnection;
    NSMutableData *_data;
    NSMutableData *_registData;
    NSString *_ipAndHost;
    NSString *_request;
    NSString *_registRequest;
    
    //定义字典和相关数组
    NSDictionary *_areasArray;
    NSArray *_provinces;
    NSString *_selectedProvince;
    NSString *_province;
    NSString *_area;
}

@property (strong, nonatomic) IBOutlet UINavigationBar *navigationBar;

//以下为注册的表单的各个信息记录
@property (strong, nonatomic) IBOutlet UITextField *tfUserName;
@property (strong, nonatomic) IBOutlet UILabel *lbCheckUserName;
@property (strong, nonatomic) IBOutlet UITextField *tfPassword;
@property (strong, nonatomic) IBOutlet UILabel *lbCheckPassword;
@property (strong, nonatomic) IBOutlet UITextField *tfRePassword;
@property (strong, nonatomic) IBOutlet UILabel *lbCheckRePassword;
@property (strong, nonatomic) IBOutlet UITextField *tfMobile;
@property (strong, nonatomic) IBOutlet UILabel *lbCheckMobile;
@property (strong, nonatomic) IBOutlet UITextField *tfProvinceAndArea;
@property (strong, nonatomic) IBOutlet UILabel *lbCheckProvinceAndArea;
@property (strong, nonatomic) IBOutlet UITextView *tvDetailAddress;
@property (strong, nonatomic) IBOutlet UILabel *lbCheckDetailAddress;
@property (strong, nonatomic) IBOutlet UILabel *lbDetailAddressPlaceholder;

//定义省市区的的选择器
@property (strong, nonatomic) UIPickerView *provinceAndAreaPickerView;

//取消按钮
- (IBAction)btnCancel:(id)sender;
//注册按钮
- (IBAction)btnRegist:(id)sender;

@end

@implementation RegistVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [_navigationBar setBarTintColor:[UIColor colorWithRed:253.0/255.0 green:109.0/255.0 blue:9.0/255.0 alpha:1]];
    [_navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor whiteColor]}];
    _navigationBar.translucent = NO;
    
    //键盘收回
    self.view.userInteractionEnabled = YES;
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(fingetTap:)];
    [self.view addGestureRecognizer:singleTap];
    
    _tfUserName.layer.borderColor = [[UIColor colorWithRed:253.0/255.0 green:109.0/255.0 blue:9.0/255.0 alpha:1] CGColor];
    _tfUserName.clearButtonMode = UITextFieldViewModeWhileEditing;
    _tfPassword.layer.borderColor = [[UIColor colorWithRed:253.0/255.0 green:109.0/255.0 blue:9.0/255.0 alpha:1] CGColor];
    _tfPassword.clearButtonMode = UITextFieldViewModeWhileEditing;
    _tfRePassword.layer.borderColor = [[UIColor colorWithRed:253.0/255.0 green:109.0/255.0 blue:9.0/255.0 alpha:1] CGColor];
    _tfRePassword.clearButtonMode = UITextFieldViewModeWhileEditing;
    _tfMobile.layer.borderColor = [[UIColor colorWithRed:253.0/255.0 green:109.0/255.0 blue:9.0/255.0 alpha:1] CGColor];
    _tfMobile.clearButtonMode = UITextFieldViewModeWhileEditing;
    _tfProvinceAndArea.layer.borderColor = [[UIColor colorWithRed:253.0/255.0 green:109.0/255.0 blue:9.0/255.0 alpha:1] CGColor];
    _tfProvinceAndArea.clearButtonMode = UITextFieldViewModeWhileEditing;
    _tvDetailAddress.layer.borderColor = [[UIColor colorWithRed:253.0/255.0 green:109.0/255.0 blue:9.0/255.0 alpha:1] CGColor];
    _tvDetailAddress.layer.borderWidth = 1;
    _tvDetailAddress.layer.cornerRadius = 5;
    _tvDetailAddress.delegate = self;
    
    [self initProvinceAndAreaPickerView];
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

//TextView的类似于Placeholder的协议方法
- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text{
    if (![text isEqualToString:@""]){
        _lbDetailAddressPlaceholder.hidden = YES;
    }
    
    if ([text isEqualToString:@""] && range.location == 0 && range.length == 1){
        _lbDetailAddressPlaceholder.hidden = NO;
    }
    
    return YES;
}


//选择器方法
-(NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView{
    return 2;
}

-(NSInteger) pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component{
    if (component==0) {
        return _provinces.count;
    } else {
        return [_areasArray[_selectedProvince] count];
    }
}

-(NSString *) pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component{
    if (component==0) {
        return _provinces[row];
    } else {
        return [_areasArray[_selectedProvince] objectAtIndex:row];
    }
}

-(void) pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component{
    
    if (component==0) {
        _selectedProvince=_provinces[row];
        [_provinceAndAreaPickerView reloadComponent:1];
        [_provinceAndAreaPickerView selectRow:0 inComponent:1 animated:YES];
        _province=_selectedProvince;
    } else {
        _area=[_areasArray[_selectedProvince] objectAtIndex:row];
    }
}

//取消按钮方法
- (IBAction)btnCancel:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

//注册按钮方法
- (IBAction)btnRegist:(id)sender {
    [self checkEveryProperty];
}

//检查注册表单的相关内容的方法
-(void)checkEveryProperty{
    
    [_tfUserName resignFirstResponder];
    [_tfPassword resignFirstResponder];
    [_tfRePassword resignFirstResponder];
    [_tfMobile resignFirstResponder];
    [_tfProvinceAndArea resignFirstResponder];
    [_tvDetailAddress resignFirstResponder];
    
    BOOL isUserName;
    BOOL isPassword;
    BOOL isRePassword;
    BOOL isMobile;
    BOOL isProvinceAndArea;
    BOOL isDetailAddress;
    //检查用户名
    if (_tfUserName.text.length == 0) {
        _lbCheckUserName.text = @"用户名不能为空！";
        isUserName = NO;
    } else {
        _lbCheckUserName.text = @"";
        isUserName = YES;
    }
    //检查密码
    if (_tfPassword.text.length == 0) {
        _lbCheckPassword.text = @"密码不能为空！";
        isPassword = NO;
    } else {
        _lbCheckPassword.text = @"";
        isPassword = YES;
    }
    //检查确认密码
    if (_tfRePassword.text.length == 0) {
        _lbCheckRePassword.text = @"确认密码不能为空！";
        isRePassword = NO;
    } else {
        if (_tfPassword.text != _tfRePassword.text) {
            _lbCheckRePassword.text = @"密码与确认密码不同!";
            isRePassword = NO;
        } else {
            _lbCheckRePassword.text = @"";
            isRePassword = YES;
        }
    }
    //检查手机号
    if (_tfMobile.text.length == 0) {
        _lbCheckMobile.text = @"手机号不能为空！";
        isMobile = NO;
    } else {
        if (_tfMobile.text.length != 11) {
            _lbCheckMobile.text = @"手机号必须为11位！";
            isMobile = NO;
        } else {
            _lbCheckMobile.text = @"";
            isMobile = YES;
        }
    }
    //检查省市区
    if (_tfProvinceAndArea.text.length == 0) {
        isProvinceAndArea = NO;
        _lbCheckProvinceAndArea.text = @"省市区不能为空！";
    } else {
        _lbCheckProvinceAndArea.text = @"";
        isProvinceAndArea = YES;
    }
    //检查详细地址
    if (_tvDetailAddress.text.length == 0) {
        isDetailAddress = NO;
        _lbCheckDetailAddress.text = @"详细地址不能为空！";
    } else {
        _lbCheckDetailAddress.text = @"";
        isDetailAddress = YES;
    }
    
    //条件都通过，执行注册方法
    if (isUserName==YES && isPassword==YES && isRePassword==YES && isMobile==YES && isProvinceAndArea==YES && isDetailAddress==YES) {
        [self connectionWithURLToCheckUserName];
    } else {
//        UIAlertView *alertV = [[UIAlertView alloc] initWithTitle:@"警告" message:@"请仔细检查信息是否有填写错误" delegate:self cancelButtonTitle:@"好" otherButtonTitles: nil];
//        [alertV show];
    }
}

//初始化省市区选择器的方法
-(void) initProvinceAndAreaPickerView{
    _provinceAndAreaPickerView=[[UIPickerView alloc] init];
    _provinceAndAreaPickerView.tag=1004;
    _areasArray=@{
                  @"北京市":@[@"",@"东城",@"西城",@"崇文",@"宣武",@"朝阳",@"丰台",@"石景山",@"海淀",@"门头沟",@"房山",@"通州",@"顺义",@"昌平",@"大兴",@"平谷",@"怀柔",@"密云",@"延庆"],
                  @"天津市":@[@"",@"和平",@"东丽",@"河东",@"西青",@"河西",@"津南",@"南开",@"北辰",@"河北",@"武清",@"红挢",@"塘沽",@"汉沽",@"大港",@"宁河",@"静海",@"宝坻",@"蓟县"],
                  @"上海市":@[@"",@"黄浦",@"卢湾",@"徐汇",@"长宁",@"静安",@"普陀",@"闸北",@"虹口",@"杨浦",@"闵行",@"宝山",@"嘉定",@"浦东",@"金山",@"松江",@"青浦",@"南汇",@"奉贤",@"崇明"],
                  @"重庆市":@[@"",@"万州",@"涪陵",@"渝中",@"大渡口",@"江北",@"沙坪坝",@"九龙坡",@"南岸",@"北碚",@"万盛",@"双挢",@"渝北",@"巴南",@"黔江",@"长寿",@"綦江",@"潼南",@"铜梁",@"大足",@"荣昌",@"壁山",@"梁平",@"城口",@"酆都",@"垫江",@"武隆",@"忠县",@"开县",@"云阳",@"奉节",@"巫山",@"巫溪",@"石柱",@"秀山",@"酉阳",@"彭水",@"江津",@"合川",@"永川",@"南川"],
                  @"河北市":@[@"",@"石家庄",@"邯郸",@"邢台",@"保定",@"张家口",@"承德",@"廊坊",@"唐山",@"秦皇岛",@"沧州",@"衡水"],
                  @"山西省":@[@"",@"太原",@"大同",@"阳泉",@"长治",@"晋城",@"朔州",@"吕梁",@"忻州",@"晋中",@"临汾",@"运城"],
                  @"辽宁省":@[@"",@"沈阳",@"大连",@"鞍山",@"抚顺",@"本溪",@"丹东",@"锦州",@"营口",@"阜新",@"辽阳",@"盘锦",@"铁岭",@"朝阳",@"葫芦岛"],
                  @"吉林省":@[@"",@"长春",@"吉林",@"四平",@"辽源",@"通化",@"白山",@"松原",@"白城",@"延边"],
                  @"黑龙江省":@[@"",@"哈尔滨",@"齐齐哈尔",@"牡丹江",@"佳木斯",@"大庆",@"绥化",@"鹤岗",@"鸡西",@"黑河",@"双鸭山",@"伊春",@"七台河",@"大兴安岭"],
                  @"江苏省":@[@"",@"南京",@"镇江",@"苏州",@"南通",@"扬州",@"盐城",@"徐州",@"连云港",@"常州",@"无锡",@"宿迁",@"泰州",@"淮安"],
                  @"浙江省":@[@"",@"杭州",@"宁波",@"温州",@"嘉兴",@"湖州",@"绍兴",@"金华",@"衢州",@"舟山",@"台州",@"丽水"],
                  @"安徽省":@[@"",@"合肥",@"芜湖",@"蚌埠",@"马鞍山",@"淮北",@"铜陵",@"安庆",@"黄山",@"滁州",@"宿州",@"池州",@"淮南",@"巢湖",@"阜阳",@"六安",@"宣城",@"亳州"],
                  @"福建省":@[@"",@"福州",@"厦门",@"莆田",@"三明",@"泉州",@"漳州",@"南平",@"龙岩",@"宁德"],
                  @"江西省":@[@"",@"南昌",@"景德镇",@"九江",@"鹰潭",@"萍乡",@"新馀",@"赣州",@"吉安",@"宜春",@"抚州",@"上饶"],
                  @"山东省":@[@"",@"济南",@"青岛",@"淄博",@"枣庄",@"东营",@"烟台",@"潍坊",@"济宁",@"泰安",@"威海",@"日照",@"莱芜",@"临沂",@"德州",@"聊城",@"滨州",@"菏泽"],
                  @"河南省":@[@"",@"郑州",@"开封",@"洛阳",@"平顶山",@"安阳",@"鹤壁",@"新乡",@"焦作",@"濮阳",@"许昌",@"漯河",@"三门峡",@"南阳",@"商丘",@"信阳",@"周口",@"驻马店",@"济源"],
                  @"湖北省":@[@"",@"武汉",@"宜昌",@"荆州",@"襄樊",@"黄石",@"荆门",@"黄冈",@"十堰",@"恩施",@"潜江",@"天门",@"仙桃",@"随州",@"咸宁",@"孝感",@"鄂州"],
                  @"湖南省":@[@"",@"长沙",@"常德",@"株洲",@"湘潭",@"衡阳",@"岳阳",@"邵阳",@"益阳",@"娄底",@"怀化",@"郴州",@"永州",@"湘西",@"张家界"],
                  @"广东省":@[@"",@"广州",@"深圳",@"珠海",@"汕头",@"东莞",@"中山",@"佛山",@"韶关",@"江门",@"湛江",@"茂名",@"肇庆",@"惠州",@"梅州",@"汕尾",@"河源",@"阳江",@"清远",@"潮州",@"揭阳",@"云浮"],
                  @"海南省":@[@"",@"海口",@"三亚"],
                  @"四川省":@[@"",@"成都",@"绵阳",@"德阳",@"自贡",@"攀枝花",@"广元",@"内江",@"乐山",@"南充",@"宜宾",@"广安",@"达川",@"雅安",@"眉山",@"甘孜",@"凉山",@"泸州"],
                  @"贵州省":@[@"",@"贵阳",@"六盘水",@"遵义",@"安顺",@"铜仁",@"黔西南",@"毕节",@"黔东南",@"黔南"],
                  @"云南省":@[@"",@"昆明",@"大理",@"曲靖",@"玉溪",@"昭通",@"楚雄",@"红河",@"文山",@"思茅",@"西双版纳",@"保山",@"德宏",@"丽江",@"怒江",@"迪庆",@"临沧"],
                  @"陕西省":@[@"",@"西安",@"宝鸡",@"咸阳",@"铜川",@"渭南",@"延安",@"榆林",@"汉中",@"安康",@"商洛"],
                  @"甘肃省":@[@"",@"兰州",@"嘉峪关",@"金昌",@"白银",@"天水",@"酒泉",@"张掖",@"武威",@"定西",@"陇南",@"平凉",@"庆阳",@"临夏",@"甘南"],
                  @"青海省":@[@"",@"西宁",@"海东",@"海南",@"海北",@"黄南",@"玉树",@"果洛",@"海西"],
                  @"台湾省":@[@"",@"台北",@"高雄",@"台中",@"台南",@"屏东",@"南投",@"云林",@"新竹",@"彰化",@"苗栗",@"嘉义",@"花莲",@"桃园",@"宜兰",@"基隆",@"台东",@"金门",@"马祖",@"澎湖"],
                  @"内蒙古自治区":@[@"",@"呼和浩特",@"包头",@"乌海",@"赤峰",@"呼伦贝尔盟",@"阿拉善盟",@"哲里木盟",@"兴安盟",@"乌兰察布盟",@"锡林郭勒盟",@"巴彦淖尔盟",@"伊克昭盟"],
                  @"广西壮族自治区":@[@"",@"南宁",@"柳州",@"桂林",@"梧州",@"北海",@"防城港",@"钦州",@"贵港",@"玉林",@"南宁地区",@"柳州地区",@"贺州",@"百色",@"河池"],
                  @"西藏自治区":@[@"",@"拉萨",@"日喀则",@"山南",@"林芝",@"昌都",@"阿里",@"那曲"],
                  @"宁夏回族自治区":@[@"",@"银川",@"石嘴山",@"吴忠",@"固原"],
                  @"新疆维吾尔自治区":@[@"",@"乌鲁木齐",@"石河子",@"克拉玛依",@"伊犁",@"巴音郭勒",@"昌吉",@"克孜勒苏柯尔克孜",@"博尔塔拉",@"吐鲁番",@"哈密",@"喀什",@"和田",@"阿克苏"],
                  @"香港特别行政区":@[@"",@"香港"],
                  @"澳门特别行政区":@[@"",@"澳门"]
                  };
    _provinces=[_areasArray allKeys];
    _selectedProvince=_provinces[0];
    
    _tfProvinceAndArea.delegate=self;
    _provinceAndAreaPickerView.delegate=self;
    _provinceAndAreaPickerView.dataSource=self;
    
    UIToolbar *proAreatoolBar=[[UIToolbar alloc] init];
    proAreatoolBar.frame=CGRectMake(0, 0, ScreenWidth, 38);
    
    UIBarButtonItem *proAreaCancelBtn=[[UIBarButtonItem alloc] initWithTitle:@"取消" style:UIBarButtonItemStylePlain target:self action:@selector(pressCancel:)];
    UIBarButtonItem *proAreaConfigBtn=[[UIBarButtonItem alloc] initWithTitle:@"完成" style:UIBarButtonItemStylePlain target:self action:@selector(pressProAreaConfig:)];
    UIBarButtonItem *proAreaSpaceBtn=[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    proAreatoolBar.items=@[proAreaCancelBtn,proAreaSpaceBtn,proAreaConfigBtn];
    
    _tfProvinceAndArea.inputView=_provinceAndAreaPickerView;
    _tfProvinceAndArea.inputAccessoryView=proAreatoolBar;
}


//定义省市区确定事件
-(void)pressProAreaConfig:(UITapGestureRecognizer *)gestureRecognizer{
    if (_province.length!=0&&_area.length!=0) {
        _tfProvinceAndArea.text=[NSString stringWithFormat:@"%@%@",_province,_area];
    }
    [self fingetTap:gestureRecognizer];
}

//定义取消事件
-(void)pressCancel:(UITapGestureRecognizer *)gestureRecognizer{
    [self fingetTap:gestureRecognizer];
}

//检查用户是否存在的方法
-(void) connectionWithURLToCheckUserName{
    NSLog(@"方法被调用");
    
    _ipAndHost = Init_IP;
    _request = [NSString stringWithFormat:@"checkUserName.html?userName=%@", _tfUserName.text];
    
    _request = [_request stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    
    NSString *strURL = [NSString stringWithFormat:@"%@/%@", _ipAndHost, _request];
    NSURL *url = [NSURL URLWithString:strURL];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    _connection = [NSURLConnection connectionWithRequest:request delegate:self];
    _data = [[NSMutableData alloc] init];
}

//成功注册的方法
-(void) connectionWithURLToRegist{
    NSLog(@"方法被调用");
    
    _ipAndHost = Init_IP;
    
    NSString *username = _tfUserName.text;
    NSString *password = _tfPassword.text;
    long mobile = [[NSString stringWithFormat:@"%@",_tfMobile.text] longLongValue];
    NSString *address = [NSString stringWithFormat:@"%@%@",_tfProvinceAndArea.text,_tvDetailAddress.text];
    
    _registRequest = [NSString stringWithFormat:@"regist.html?userName=%@&password=%@&mobile=%ld&address=%@",username,password,mobile,address];
    
    _registRequest = [_registRequest stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    
    NSString *strURL2 = [NSString stringWithFormat:@"%@/%@", _ipAndHost, _registRequest];
    NSURL *url2 = [NSURL URLWithString:strURL2];
    NSURLRequest *request2 = [NSURLRequest requestWithURL:url2];
    _registConnection = [NSURLConnection connectionWithRequest:request2 delegate:self];
    _registData = [[NSMutableData alloc] init];
}


-(void) connection:(NSURLConnection *)connection didFailWithError:(NSError *)error{
    if (connection == _connection) {
        NSLog(@"错误发生，为%@错误",error);
    } else if (connection == _registConnection ) {
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
    } else if (connection == _registConnection ) {
        [_registData appendData:data];
    }
}


-(void)connectionDidFinishLoading:(NSURLConnection *)connection{
    if (connection == _connection) {
        NSString *str = [[NSString alloc] initWithData:_data encoding:NSUTF8StringEncoding];
        //NSLog(@"%@",str);
        [self isCheckUserNameRight:str];
    } else if (connection == _registConnection ) {
        NSString *str = [[NSString alloc] initWithData:_registData encoding:NSUTF8StringEncoding];
        NSLog(@"%@",str);
    }
}

//检查是否注册成功
-(void) isCheckUserNameRight:(NSString *)strLoginStatus{
    if ([strLoginStatus isEqualToString:@"0"]) {
        NSLog(@"注册成功！");
        
        [_tfUserName resignFirstResponder];
        [_tfPassword resignFirstResponder];
        [_tfRePassword resignFirstResponder];
        [_tfMobile resignFirstResponder];
        [_tfProvinceAndArea resignFirstResponder];
        [_tvDetailAddress resignFirstResponder];
        
        [self connectionWithURLToRegist];
        [self dismissViewControllerAnimated:YES completion:nil];
        
    } else {
        //NSLog(@"登录失败！");
        
        [_tfUserName resignFirstResponder];
        [_tfPassword resignFirstResponder];
        [_tfRePassword resignFirstResponder];
        [_tfMobile resignFirstResponder];
        [_tfProvinceAndArea resignFirstResponder];
        [_tvDetailAddress resignFirstResponder];
        
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"警告" message:@"该用户已存在！" delegate:self cancelButtonTitle:@"好" otherButtonTitles: nil];
        [alertView show];
    }
}





@end
