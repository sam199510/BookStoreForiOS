//
//  ShowBookCommentCell.h
//  书斋
//
//  Created by 飞 on 2017/6/17.
//  Copyright © 2017年 Sam. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ShowBookCommentCell : UITableViewCell

@property (strong, nonatomic) IBOutlet UILabel *lbCommentName;
@property (strong, nonatomic) IBOutlet UILabel *lbCommentTime;
@property (strong, nonatomic) IBOutlet UITextView *tvCommentContent;

@end
