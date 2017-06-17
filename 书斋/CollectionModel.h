//
//  CollectionModel.h
//  书斋
//
//  Created by 飞 on 2017/6/12.
//  Copyright © 2017年 Sam. All rights reserved.
//

#import <Foundation/Foundation.h>

//用户收藏类
@interface CollectionModel : NSObject

@property (assign, nonatomic) NSInteger collectID;//主键id
@property (assign, nonatomic) NSInteger collectorID;//收藏者id
@property (assign, nonatomic) NSInteger bookID;//收藏书目id
@property (retain, nonatomic) NSString *bookName;//收藏书名
@property (assign, nonatomic) float bookPrice;//收藏书的价格
@property (retain, nonatomic) NSString *bookCover;//收藏书的封面

@end
