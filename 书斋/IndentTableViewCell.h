//
//  IndentTableViewCell.h
//  书斋
//
//  Created by 飞 on 2017/6/15.
//  Copyright © 2017年 Sam. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface IndentTableViewCell : UITableViewCell

@property (strong, nonatomic) IBOutlet UILabel *lbIndentBookPublisher;
@property (strong, nonatomic) IBOutlet UIImageView *iVbookCover;
@property (strong, nonatomic) IBOutlet UILabel *lbBookName;
@property (strong, nonatomic) IBOutlet UILabel *lbBookPrice;
@property (strong, nonatomic) IBOutlet UILabel *lbBargainTime;
@property (strong, nonatomic) IBOutlet UILabel *lbBargainState;

@end
