//
//  DetailOrderInfoCell.h
//  书斋
//
//  Created by 飞 on 2017/6/12.
//  Copyright © 2017年 Sam. All rights reserved.
//

#import <UIKit/UIKit.h>

//订单详情Cell
@interface DetailOrderInfoCell : UITableViewCell

@property (strong, nonatomic) IBOutlet UIImageView *iVDetailOrderBookCover;
@property (strong, nonatomic) IBOutlet UITextView *tVDetailOrderBookName;
@property (strong, nonatomic) IBOutlet UILabel *lbDetailOrderBookPrice;

@end
