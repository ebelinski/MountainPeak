//
//  CommentViewController.h
//  Mountain Peak
//
//  Created by HHWS on 9/11/14.
//
//

#import <UIKit/UIKit.h>
#import "Parse/Parse.h"
#import "DetailViewController.h"

@interface CommentViewController : UIViewController

- (void)refreshVoteCounter;
- (void)processVoteWithValue:(NSNumber *)value;
- (void)voteWithValue:(NSNumber *)value;
- (void)switchButtonColor:(UIButton *)button;
- (void)switchButtonOff:(UIButton *)button;
- (void)setButtonColors:(NSNumber *)value;

@property (strong, nonatomic) PFObject *commentObject;
@property (strong, nonatomic) UIColor *votedColor;
@property (strong, nonatomic) UIColor *notVotedColor;
@property (strong, nonatomic) DetailViewController *parentView;

@end
