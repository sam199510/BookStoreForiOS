//
//  IndentOrderInfoCell.h
//  书斋
//
//  Created by 飞 on 2017/6/16.
//  Copyright © 2017年 Sam. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface IndentOrderInfoCell : UITableViewCell

@property (strong, nonatomic) IBOutlet UILabel *lbBookPublisher;
@property (strong, nonatomic) IBOutlet UIImageView *iVBookCover;
@property (strong, nonatomic) IBOutlet UITextView *tVBookName;
@property (strong, nonatomic) IBOutlet UILabel *lbBookPrice;

@end
