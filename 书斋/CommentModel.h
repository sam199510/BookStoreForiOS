//
//  CommentModel.h
//  书斋
//
//  Created by 飞 on 2017/6/17.
//  Copyright © 2017年 Sam. All rights reserved.
//

#import <Foundation/Foundation.h>

//评价类
@interface CommentModel : NSObject

@property (assign, nonatomic) NSInteger commentId;//数据库中的评价表的主键
@property (assign, nonatomic) NSInteger bookId;//外键1：评论的书的id
@property (assign, nonatomic) NSInteger buyerId;//外键2：评价者的id
@property (retain, nonatomic) NSDate *commentTime;//评价的时间，具体以日期为单位
@property (retain, nonatomic) NSString *content;//评价的内容
@property (retain, nonatomic) NSString *buyerName;//评价人的用户名

@end
