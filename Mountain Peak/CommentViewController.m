//
//  CommentViewController.m
//  Mountain Peak
//
//  Created by HHWS on 9/11/14.
//
//

#import "CommentViewController.h"
#import "AppDelegate.h"

@interface CommentViewController ()

@property (retain, nonatomic) IBOutlet UILabel *commentLabel;
@property (retain, nonatomic) IBOutlet UILabel *dateLabel;
@property (retain, nonatomic) IBOutlet UILabel *votesLabel;
@property (retain, nonatomic) IBOutlet UIButton *upvoteButton;
@property (retain, nonatomic) IBOutlet UIButton *downvoteButton;
@property (retain, nonatomic) IBOutlet UIButton *reportButton;

@end

@implementation CommentViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"LLLL d 'at' h:mm a"];
    //Optionally for time zone conversions
    [formatter setTimeZone:[NSTimeZone timeZoneWithName:@"..."]];
    
//    commentsText = [NSString stringWithFormat:@"%@\n%@ (%@)", commentsText, [commentObject objectForKey:@"comment"], ];
    
    self.commentLabel.text = [self.commentObject objectForKey:@"comment"];
    self.dateLabel.text = [formatter stringFromDate:self.commentObject.createdAt];
    
    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    self.votedColor = appDelegate.globalColor2;
    self.notVotedColor = [UIColor grayColor];
    
    self.upvoteButton.tintColor = self.notVotedColor;
    self.downvoteButton.tintColor = self.notVotedColor;
    
    [self refreshVoteCounter];
}

- (IBAction)upvote:(id)sender {
    [self processVoteWithValue:@1];
}

- (IBAction)downvote:(id)sender {
    [self processVoteWithValue:@-1];
}

- (void)processVoteWithValue:(NSNumber *)value
{
    PFQuery *query = [PFQuery queryWithClassName:@"Submission_Comment"];
    
    [query whereKey:@"postID" equalTo:[self.commentObject objectId]];
    [query orderByAscending:@"createdAt"];
    NSUUID *oNSUUID = [[UIDevice currentDevice] identifierForVendor];
    [query whereKey:@"userDeviceID" equalTo:[NSString stringWithString:[oNSUUID UUIDString]]];
    
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            NSLog(@"Successfully retrieved %lu personal votes in processVoteWithValue.", (unsigned long)objects.count);
            
            if ([objects count] == 1) {
                // Should only loop once
                for (PFObject *object in objects) {
                    if ([[object objectForKey:@"voteValue"] intValue] == 1) {
                        if ([value intValue] == -1) {
                            [object deleteInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                                [self voteWithValue:value];
                            }];
                        } else {
                            [object deleteInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                                [self refreshVoteCounter];
                            }];
                        }
                    } else {
                        if ([value intValue] == 1) {
                            [object deleteInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                                [self voteWithValue:value];
                            }];
                        } else {
                            [object deleteInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                                [self refreshVoteCounter];
                            }];
                        }
                    }
                }
            } else {
                [self voteWithValue:value];
            }
            
        } else {
            NSLog(@"Error: %@ %@", error, [error userInfo]);
        }
    }];
    
    [self setButtonColors:value];
}

- (void)voteWithValue:(NSNumber *)value
{
    
    PFObject *object = [PFObject objectWithClassName:@"Comment_Vote"];
    
    NSLog(@"We're going to vote now.");
    
    NSUUID *oNSUUID = [[UIDevice currentDevice] identifierForVendor];
    [object setObject:[NSString stringWithString:[oNSUUID UUIDString]] forKey:@"userDeviceID"];
    
    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    
    [object setObject:value forKey:@"voteValue"];
    [object setObject:appDelegate.userLocation forKey:@"location"];
    [object setObject:[self.commentObject objectId] forKey:@"postID"];
    [object saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        
        NSLog(@"We're voting now.");
    }];
    
    [self refreshVoteCounter];
    
}

- (void)setButtonColors:(NSNumber *)value
{
    if ([value intValue] == 1) {
        self.upvoteButton.tintColor = self.votedColor;
        [self switchButtonOff:self.downvoteButton];
    } else {
        self.downvoteButton.tintColor = self.votedColor;
        [self switchButtonOff:self.upvoteButton];
    }
}

- (void)switchButtonColor:(UIButton *)button
{
    if (button.tintColor == self.votedColor) {
        button.tintColor = self.notVotedColor;
    } else {
        button.tintColor = self.votedColor;
    }
}

- (void)switchButtonOff:(UIButton *)button
{
    button.tintColor = self.notVotedColor;
}

- (void)refreshVoteCounter {
    PFQuery *query = [PFQuery queryWithClassName:@"Submission_Comment"];
    
    [query whereKey:@"postID" equalTo:[self.commentObject objectId]];
    [query orderByAscending:@"createdAt"];
    
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
//            NSLog(@"Successfully retrieved %lu votes.", (unsigned long)objects.count);
            
            int votes = 0;
            
            for (PFObject *object in objects) {
                votes += [[object objectForKey:@"voteValue"] intValue];
            }
            
            self.votesLabel.text = [NSString stringWithFormat:@"%i", votes];
            
        } else {
            NSLog(@"Error: %@ %@", error, [error userInfo]);
        }
    }];
    
    query = [PFQuery queryWithClassName:@"Submission_Comment"];
    
    [query whereKey:@"postID" equalTo:[self.commentObject objectId]];
    [query orderByAscending:@"createdAt"];
    NSUUID *oNSUUID = [[UIDevice currentDevice] identifierForVendor];
    [query whereKey:@"userDeviceID" equalTo:[NSString stringWithString:[oNSUUID UUIDString]]];
    
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
//            NSLog(@"Successfully retrieved %lu personal votes in refreshVoteCounter.", (unsigned long)objects.count);
            
            if ([objects count] == 1) {
                // Should only loop once
                for (PFObject *object in objects) {
                    if ([[object objectForKey:@"voteValue"] intValue] == 1) {
                        [self setButtonColors:[NSNumber numberWithInt:1]];
                    } else {
                        [self setButtonColors:[NSNumber numberWithInt:-1]];
                    }
                }
            } else {
                [self switchButtonOff:self.upvoteButton];
                [self switchButtonOff:self.downvoteButton];
            }
        } else {
            NSLog(@"Error: %@ %@", error, [error userInfo]);
        }
    }];
}

- (IBAction)reportButtonClicked:(id)sender {
    UIAlertController *reportAlertController = [UIAlertController alertControllerWithTitle:@"Report this comment?" message:@"If you believe this comment violates any of the rules, tap the report button." preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
        NSLog(@"User cancelled report.");
    }];
    [reportAlertController addAction:cancelAction];
    
    UIAlertAction *reportAction = [UIAlertAction actionWithTitle:@"Report" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * action) {
        NSLog(@"User confirmed report.");
        [self insertNewReport];
    }];
    [reportAlertController addAction:reportAction];
    
    [self presentViewController:reportAlertController animated:YES completion:nil];
}

- (void)insertNewReport {
    NSLog(@"We're going to save the comment now.");
    
    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    
    PFObject *object = [PFObject objectWithClassName:@"Report"];
    [object setObject:self.commentObject forKey:@"reportedItem"];
    [object setObject:[self.commentObject objectId] forKey:@"reportedItemID"];
    [object setObject:@"comment" forKey:@"reportedType"];
    [object setObject:appDelegate.currentUser forKey:@"reportingUser"];
    if (appDelegate.userLocation) [object setObject:appDelegate.userLocation forKey:@"reportingLocation"];
    [object saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (!error) {
            NSLog(@"Report has been submitted.");
            
            UIAlertController *infoAlertController = [UIAlertController alertControllerWithTitle:@"Thank you!" message:@"Your report has been submitted and will be reviewed soon." preferredStyle:UIAlertControllerStyleAlert];
            
            UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault handler:nil];
            [infoAlertController addAction:okAction];
            
            [self presentViewController:infoAlertController animated:YES completion:nil];
            
        } else {
            UIAlertController *infoAlertController = [UIAlertController alertControllerWithTitle:@"Error" message:@"There was a problem in submitting your report. Please try again later." preferredStyle:UIAlertControllerStyleAlert];
            
            UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault handler:nil];
            [infoAlertController addAction:okAction];
            
            [self presentViewController:infoAlertController animated:YES completion:nil];
        }
    }];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (void)dealloc {
    [_commentLabel release];
    [_dateLabel release];
    [_votesLabel release];
    [_upvoteButton release];
    [_downvoteButton release];
    [_reportButton release];
    [super dealloc];
}
@end
