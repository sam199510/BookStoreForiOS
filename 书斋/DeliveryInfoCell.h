//
//  DeliveryInfoCell.h
//  书斋
//
//  Created by 飞 on 2017/6/12.
//  Copyright © 2017年 Sam. All rights reserved.
//

#import <UIKit/UIKit.h>

//送货详细地址Cell
@interface DeliveryInfoCell : UITableViewCell

@property (strong, nonatomic) IBOutlet UILabel *lbDeliveredUser;
@property (strong, nonatomic) IBOutlet UILabel *lbDeliveryMobile;
@property (strong, nonatomic) IBOutlet UITextView *tVDeliveryAddress;

@end
