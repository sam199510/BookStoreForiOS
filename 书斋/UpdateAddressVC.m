//
//  UpdateAddressVC.m
//  书斋
//
//  Created by 飞 on 2017/6/10.
//  Copyright © 2017年 Sam. All rights reserved.
//

#import "UpdateAddressVC.h"
#import "UserModel.h"

#import "IPConfig.h"

#define ScreenWidth CGRectGetWidth([UIScreen mainScreen].bounds)

@interface UpdateAddressVC ()<UITableViewDelegate,UITableViewDataSource,UITextFieldDelegate,UIPickerViewDataSource,UIPickerViewDelegate>

{
    NSURLConnection *_connection;
    NSURLConnection *_updateAddressConnection;
    NSMutableData *_data;
    NSMutableData *_updateAddressData;
    NSString *_ipAndHost;
    NSString *_request;
    NSString *_updateAddressRequest;
    
    NSDictionary *_areasArray;
    NSArray *_provinces;
    NSString *_selectedProvince;
    NSString *_province;
    NSString *_area;
    
    NSMutableArray *_arrUsers;
}

@property (strong, nonatomic) IBOutlet UITableView *tableUpdateAddress;

@property (strong, nonatomic) UITextView *currentAddressTextView;
@property (strong, nonatomic) UITextField *provinceAndAreaTextField;
@property (strong, nonatomic) UILabel *lbProvinceAndArea;
@property (strong, nonatomic) UITextView *detailAddressTextView;
@property (strong, nonatomic) UILabel *lbDetailAddress;
@property (strong, nonatomic) UIPickerView *provinceAndAreaPickerView;

@property (assign, nonatomic) CGFloat keyboardHeight;

@end

@implementation UpdateAddressVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.title = @"修改地址";
    UIBarButtonItem *saveBtn = [[UIBarButtonItem alloc] initWithTitle:@"保存" style:UIBarButtonItemStylePlain target:self action:@selector(pressUpdateAddress)];
    self.navigationItem.rightBarButtonItem = saveBtn;
    
    //键盘收回
    self.view.userInteractionEnabled = YES;
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(fingetTap:)];
    [self.view addGestureRecognizer:singleTap];
    
    _tableUpdateAddress.delegate = self;
    _tableUpdateAddress.dataSource = self;
    
    //增加监听，键盘出现时调用
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    //增加监听，键盘消失时调用
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:YES];
    
    [self connectionWithURLToGetCurrentAddress];
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
    CGRect rectInTableView = [_tableUpdateAddress rectForRowAtIndexPath:indexPath];
    CGRect rect = [_tableUpdateAddress convertRect:rectInTableView toView:[_tableUpdateAddress superview]];
    CGFloat offSetYOfPasswordCell = rect.origin.y;
    //密码框父视图的高度
    CGFloat offSetHeightOFPasswordCell = rect.size.height ;
    //键盘高度转储
    CGFloat heightOfKeyboard = _keyboardHeight;
    //约束计算
    //    CGFloat offset = mainScreenHeight - (offSetYOfPasswordCell + offSetHeightOFPasswordCell + heightOfKeyboard);
    CGFloat offset = (mainScreenHeight - heightOfKeyboard) - (offSetHeightOFPasswordCell + offSetYOfPasswordCell);
    
    NSLog(@"offset%f",offset);
    
    //判断约束
    if (offset <= 0) {
        //约束变化
        [UIView animateWithDuration:0.25 animations:^{
            CGRect tbShopOrderFrame = _tableUpdateAddress.frame;
            tbShopOrderFrame.origin.y = -heightOfKeyboard + (_tableUpdateAddress.frame.size.height  - (offSetYOfPasswordCell + offSetHeightOFPasswordCell)) ;
            _tableUpdateAddress.frame = tbShopOrderFrame;
        }];
    }
}

//键盘消失时调用
-(void)keyboardWillHide:(NSNotification *)aNotification{
    [UIView animateWithDuration:0.25 animations:^{
        CGRect tbShopOrderFrame = _tableUpdateAddress.frame;
        tbShopOrderFrame.origin.y = 0;
        _tableUpdateAddress.frame = tbShopOrderFrame;
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


-(NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return 1;
    } else {
        return 2;
    }
}


-(CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 0) {
        return 60;
    } else {
        if (indexPath.row == 0) {
            return 64;
        } else {
            return 150;
        }
    }
}


-(UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *cellIndentifier = @"cellIdentifier";
    
    UITableViewCell *cell = [_tableUpdateAddress dequeueReusableCellWithIdentifier:cellIndentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIndentifier];
    }
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    if (indexPath.section == 0) {
        UserModel *userModel = [_arrUsers objectAtIndex:indexPath.row];
        
        _currentAddressTextView = [[UITextView alloc] init];
        _currentAddressTextView.frame = CGRectMake(20, 0, ScreenWidth-40, 60);
        _currentAddressTextView.font = [UIFont systemFontOfSize:15];
        _currentAddressTextView.editable = NO;
        _currentAddressTextView.text = userModel.address;
        [cell addSubview:_currentAddressTextView];
        
        return cell;
    } else if (indexPath.section == 1) {
        if (indexPath.row == 0) {
            _provinceAndAreaTextField = [[UITextField alloc] init];
            _provinceAndAreaTextField.frame = CGRectMake(20, 0, ScreenWidth-40, 44);
            _provinceAndAreaTextField.borderStyle = UITextBorderStyleNone;
            _provinceAndAreaTextField.font = [UIFont systemFontOfSize:15];
            _provinceAndAreaTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
            [self initProvinceAndAreaPickerViewWithCell];
            [cell addSubview:_provinceAndAreaTextField];
            
            _lbProvinceAndArea = [[UILabel alloc] init];
            _lbProvinceAndArea.frame = CGRectMake(20, 44, ScreenWidth-40, 20);
            _lbProvinceAndArea.textColor = [UIColor redColor];
            _lbProvinceAndArea.font = [UIFont systemFontOfSize:13];
            [cell addSubview:_lbProvinceAndArea];
            
            return cell;
        } else if (indexPath.row == 1) {
            _detailAddressTextView = [[UITextView alloc] init];
            _detailAddressTextView.frame = CGRectMake(20, 0, ScreenWidth-40, 130);
            _detailAddressTextView.font = [UIFont systemFontOfSize:15];
            [cell addSubview:_detailAddressTextView];
            
            _lbDetailAddress = [[UILabel alloc] init];
            _lbDetailAddress.frame = CGRectMake(20, 130, ScreenWidth-40, 20);
            _lbDetailAddress.textColor = [UIColor redColor];
            _lbDetailAddress.font = [UIFont systemFontOfSize:13];
            [cell addSubview:_lbDetailAddress];
         
            return cell;
        }
    }
    
    return cell;
}


-(NSString *) tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    if (section == 0) {
        return @"当前地址";
    } else {
        return @"以下框中选择省市区";
    }
}


-(NSString *) tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section{
    if (section == 1) {
        return @"以上框中输入详细地址";
    } else {
        return @"";
    }
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


-(void) initProvinceAndAreaPickerViewWithCell{
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
    
    _provinceAndAreaTextField.delegate=self;
    _provinceAndAreaPickerView.delegate=self;
    _provinceAndAreaPickerView.dataSource=self;
    
    UIToolbar *proAreatoolBar=[[UIToolbar alloc] init];
    proAreatoolBar.frame=CGRectMake(0, 0, ScreenWidth, 38);
    
    UIBarButtonItem *proAreaCancelBtn=[[UIBarButtonItem alloc] initWithTitle:@"取消" style:UIBarButtonItemStylePlain target:self action:@selector(pressCancel:)];
    UIBarButtonItem *proAreaConfigBtn=[[UIBarButtonItem alloc] initWithTitle:@"完成" style:UIBarButtonItemStylePlain target:self action:@selector(pressProAreaConfig:)];
    UIBarButtonItem *proAreaSpaceBtn=[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    proAreatoolBar.items=@[proAreaCancelBtn,proAreaSpaceBtn,proAreaConfigBtn];
    
    
    _provinceAndAreaTextField.inputView=_provinceAndAreaPickerView;
    _provinceAndAreaTextField.inputAccessoryView=proAreatoolBar;
}


//定义省市区确定事件
-(void)pressProAreaConfig:(UITapGestureRecognizer *)gestureRecognizer{
    if (_province.length!=0&&_area.length!=0) {
        _provinceAndAreaTextField.text=[NSString stringWithFormat:@"%@%@",_province,_area];
    }
    [self fingetTap:gestureRecognizer];
}

//定义取消事件
-(void)pressCancel:(UITapGestureRecognizer *)gestureRecognizer{
    [self fingetTap:gestureRecognizer];
}


-(void) pressUpdateAddress{
    BOOL isProvinceAndArea;
    BOOL isDetailAddress;
    
    if (_provinceAndAreaTextField.text.length == 0) {
        _lbProvinceAndArea.text = @"省市区不能为空";
        isProvinceAndArea = NO;
    } else {
        _lbProvinceAndArea.text = @"";
        isProvinceAndArea = YES;
    }
    
    if (_detailAddressTextView.text.length == 0) {
        _lbDetailAddress.text = @"详细地址不能为空";
        isDetailAddress = NO;
    } else {
        _lbDetailAddress.text = @"";
        isDetailAddress = YES;
    }
    
    if (isProvinceAndArea == YES && isDetailAddress == YES) {
        [self connectionWithURLToUpdateUserAddress];
    } else {
        NSLog(@"修改失败");
    }
    
}


-(void) connectionWithURLToGetCurrentAddress{
    NSLog(@"方法被调用");
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *strUserName = [userDefaults objectForKey:@"userName"];
    
    _ipAndHost = Init_IP;
    _request = [NSString stringWithFormat:@"getUserCurrentAddress.html?userName=%@", strUserName];
    
    _request = [_request stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    
    NSString *strURL = [NSString stringWithFormat:@"%@/%@", _ipAndHost, _request];
    NSURL *url = [NSURL URLWithString:strURL];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    _connection = [NSURLConnection connectionWithRequest:request delegate:self];
    _data = [[NSMutableData alloc] init];
}


-(void) connectionWithURLToUpdateUserAddress{
    NSLog(@"方法被调用");
    
    _ipAndHost = Init_IP;
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *strUserName = [userDefaults objectForKey:@"userName"];
    
    NSString *address = [NSString stringWithFormat:@"%@%@",_provinceAndAreaTextField.text,_detailAddressTextView.text];
    
    _updateAddressRequest = [NSString stringWithFormat:@"updateUserAddress.html?userName=%@&address=%@",strUserName,address];
    
    _updateAddressRequest = [_updateAddressRequest stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    
    NSString *strURL2 = [NSString stringWithFormat:@"%@/%@", _ipAndHost, _updateAddressRequest];
    NSURL *url2 = [NSURL URLWithString:strURL2];
    NSURLRequest *request2 = [NSURLRequest requestWithURL:url2];
    _updateAddressConnection = [NSURLConnection connectionWithRequest:request2 delegate:self];
    _updateAddressData = [[NSMutableData alloc] init];
}


-(void) connection:(NSURLConnection *)connection didFailWithError:(NSError *)error{
    if (connection == _connection) {
        NSLog(@"错误发生，为%@错误",error);
    } else if (connection == _updateAddressConnection ) {
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
    } else if (connection == _updateAddressConnection ) {
        [_updateAddressData appendData:data];
    }
}


-(void)connectionDidFinishLoading:(NSURLConnection *)connection{
    if (connection == _connection) {
//        NSString *str = [[NSString alloc] initWithData:_data encoding:NSUTF8StringEncoding];
//        NSLog(@"%@",str);
        [self setCurrentAddressWithData:_data];
    } else if (connection == _updateAddressConnection ) {
        NSString *str = [[NSString alloc] initWithData:_updateAddressData encoding:NSUTF8StringEncoding];
        NSLog(@"%@",str);
        [self backToPersonalVCWithData];
    }
}


-(void)setCurrentAddressWithData:(NSMutableData *) userData{
    NSArray *arrRoot = [NSJSONSerialization JSONObjectWithData:userData options:NSJSONReadingMutableContainers error:nil];
//    NSLog(@"字典为：%@",arrRoot);
    _arrUsers = [[NSMutableArray alloc] init];
    
    for (int i = 0; i < arrRoot.count; i++) {
        NSDictionary *dicUser = [arrRoot objectAtIndex:i];
        NSString *address = [dicUser objectForKey:@"address"];
        
        UserModel *userModel = [[UserModel alloc] init];
        userModel.address = address;
        
        [_arrUsers addObject:userModel];
    }
    [_tableUpdateAddress reloadData];
}


-(void) backToPersonalVCWithData{
    [self.navigationController popViewControllerAnimated:YES];
}

@end
