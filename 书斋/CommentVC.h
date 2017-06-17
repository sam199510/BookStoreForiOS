//
//  CommentVC.h
//  书斋
//
//  Created by 飞 on 2017/6/17.
//  Copyright © 2017年 Sam. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CommentVC : UIViewController

@property (assign, nonatomic) NSInteger bookID;
@property (retain, nonatomic) NSString *bookCover;
@property (retain, nonatomic) NSString *bookName;
@property (assign, nonatomic) NSInteger indentId;

@end
