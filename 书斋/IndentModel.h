//
//  IndentModel.h
//  书斋
//
//  Created by 飞 on 2017/6/15.
//  Copyright © 2017年 Sam. All rights reserved.
//

#import <Foundation/Foundation.h>

//用户订单类
@interface IndentModel : NSObject

@property (assign, nonatomic) NSInteger indentId;//订单主键
@property (assign, nonatomic) NSInteger buyerID;//购买者id
@property (assign, nonatomic) NSInteger bookID;//书的id
@property (retain, nonatomic) NSDate *bargainTime;//成交时间，具体以秒为单位
@property (retain, nonatomic) NSString *buyerAddress;//购买者收货地址
@property (retain, nonatomic) NSString *bookName;//书名
@property (retain, nonatomic) NSString *bookCover;//书的封面
@property (assign, nonatomic) float bookPrice;//书的价格
@property (retain, nonatomic) NSString *bookPublisher;//书的出版社
@property (assign, nonatomic) NSInteger commentState;//评价状态
@property (assign, nonatomic) long buyerMobile;//购买者手机号
@property (retain, nonatomic) NSString *buyerName;//购买者用户名

@end
