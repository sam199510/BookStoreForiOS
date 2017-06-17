//
//  BookModel.h
//  书斋
//
//  Created by 飞 on 2017/6/8.
//  Copyright © 2017年 Sam. All rights reserved.
//

#import <Foundation/Foundation.h>

//书籍类
@interface BookModel : NSObject

@property (assign, nonatomic) NSInteger bookId;//主键id
@property (retain, nonatomic) NSString *bookName;//书名
@property (retain, nonatomic) NSString *author;//作者
@property (assign, nonatomic) float price;//价格
@property (retain, nonatomic) NSString *introduce;//简介
@property (retain, nonatomic) NSString *publisher;//出版社
@property (assign, nonatomic) long isbn;//ISBN
@property (assign, nonatomic) NSInteger repertory;//库存
@property (retain, nonatomic) NSString *cover;//封面

@end
