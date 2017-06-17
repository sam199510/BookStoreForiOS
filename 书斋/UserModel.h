//
//  UserModel.h
//  书斋
//
//  Created by 飞 on 2017/6/11.
//  Copyright © 2017年 Sam. All rights reserved.
//

#import <Foundation/Foundation.h>

//用户类
@interface UserModel : NSObject

@property (assign, nonatomic) NSInteger userId;
@property (retain, nonatomic) NSString *userName;
@property (retain, nonatomic) NSString *password;
@property (assign, nonatomic) long mobile;
@property (retain, nonatomic) NSString *address;

@end
