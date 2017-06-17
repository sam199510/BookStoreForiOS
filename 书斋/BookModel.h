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

@property (assign, nonatomic) NSInteger bookId;
@property (retain, nonatomic) NSString *bookName;
@property (retain, nonatomic) NSString *author;
@property (assign, nonatomic) float price;
@property (retain, nonatomic) NSString *introduce;
@property (retain, nonatomic) NSString *publisher;
@property (assign, nonatomic) long isbn;
@property (assign, nonatomic) NSInteger repertory;
@property (retain, nonatomic) NSString *cover;

@end
