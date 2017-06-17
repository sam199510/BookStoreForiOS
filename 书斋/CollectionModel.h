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

@property (assign, nonatomic) NSInteger collectID;
@property (assign, nonatomic) NSInteger collectorID;
@property (assign, nonatomic) NSInteger bookID;
@property (retain, nonatomic) NSString *bookName;
@property (assign, nonatomic) float bookPrice;
@property (retain, nonatomic) NSString *bookCover;

@end
