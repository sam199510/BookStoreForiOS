//
//  CollectionTableViewCell.h
//  书斋
//
//  Created by 飞 on 2017/6/12.
//  Copyright © 2017年 Sam. All rights reserved.
//

#import <UIKit/UIKit.h>

//收藏Cell
@interface CollectionTableViewCell : UITableViewCell

@property (strong, nonatomic) IBOutlet UIImageView *iVCollectBookCover;
@property (strong, nonatomic) IBOutlet UITextView *tVBookName;
@property (strong, nonatomic) IBOutlet UILabel *lbBookPrice;

@end
