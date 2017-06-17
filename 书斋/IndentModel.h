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

@property (assign, nonatomic) NSInteger indentId;
@property (assign, nonatomic) NSInteger buyerID;
@property (assign, nonatomic) NSInteger bookID;
@property (retain, nonatomic) NSDate *bargainTime;
@property (retain, nonatomic) NSString *buyerAddress;
@property (retain, nonatomic) NSString *bookName;
@property (retain, nonatomic) NSString *bookCover;
@property (assign, nonatomic) float bookPrice;
@property (retain, nonatomic) NSString *bookPublisher;
@property (assign, nonatomic) NSInteger commentState;
@property (assign, nonatomic) long buyerMobile;
@property (retain, nonatomic) NSString *buyerName;

@end
