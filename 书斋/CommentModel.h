//
//  CommentModel.h
//  书斋
//
//  Created by 飞 on 2017/6/17.
//  Copyright © 2017年 Sam. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CommentModel : NSObject

@property (assign, nonatomic) NSInteger commentId;
@property (assign, nonatomic) NSInteger bookId;
@property (assign, nonatomic) NSInteger buyerId;
@property (retain, nonatomic) NSDate *commentTime;
@property (retain, nonatomic) NSString *content;
@property (retain, nonatomic) NSString *buyerName;

@end
