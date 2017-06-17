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

@property (assign, nonatomic) NSInteger userId;//主键id
@property (retain, nonatomic) NSString *userName;//用户名
@property (retain, nonatomic) NSString *password;//密码
@property (assign, nonatomic) long mobile;//用户手机号
@property (retain, nonatomic) NSString *address;//用户地址

@end
