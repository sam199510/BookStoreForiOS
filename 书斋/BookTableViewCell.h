//
//  BookTableViewCell.h
//  书斋
//
//  Created by 飞 on 2017/6/8.
//  Copyright © 2017年 Sam. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BookTableViewCell : UITableViewCell

@property (strong, nonatomic) IBOutlet UIImageView *coverImage;
@property (strong, nonatomic) IBOutlet UILabel *txtBookName;
@property (strong, nonatomic) IBOutlet UILabel *txtAuthor;
@property (strong, nonatomic) IBOutlet UILabel *txtRepertory;
@property (strong, nonatomic) IBOutlet UILabel *txtPrice;


@end
