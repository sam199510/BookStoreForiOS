//
//  IndentDeliveryInfo.h
//  书斋
//
//  Created by 飞 on 2017/6/16.
//  Copyright © 2017年 Sam. All rights reserved.
//

#import <UIKit/UIKit.h>

//订单配送信息的Cell
@interface IndentDeliveryInfo : UITableViewCell

@property (strong, nonatomic) IBOutlet UILabel *lbIndentBuyer;
@property (strong, nonatomic) IBOutlet UILabel *lbBuyerMobile;
@property (strong, nonatomic) IBOutlet UITextView *tVBookName;

@end
