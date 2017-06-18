//
//  ShowBookInfoCell.h
//  书斋
//
//  Created by 飞 on 2017/6/18.
//  Copyright © 2017年 Sam. All rights reserved.
//

#import <UIKit/UIKit.h>

//显示书本详情的Cell
@interface ShowBookInfoCell : UITableViewCell

@property (strong, nonatomic) IBOutlet UILabel *lbBookName;
@property (strong, nonatomic) IBOutlet UIImageView *iVBookCover;
@property (strong, nonatomic) IBOutlet UILabel *lbAuthor;
@property (strong, nonatomic) IBOutlet UILabel *lbPublisher;
@property (strong, nonatomic) IBOutlet UILabel *lbISBN;
@property (strong, nonatomic) IBOutlet UILabel *lbBookPrice;
@property (strong, nonatomic) IBOutlet UILabel *lbRepertory;
@property (strong, nonatomic) IBOutlet UITextView *tVBookIntroduce;

@end
