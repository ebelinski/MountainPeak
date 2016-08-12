//
//  PostInfoViewController.m
//  Mountain Peak
//
//  Created by HHWS on 9/11/14.
//
//

#import "PostInfoViewController.h"
#import "AppDelegate.h"

@interface PostInfoViewController ()

@property (retain, nonatomic) IBOutlet UILabel *messageLabel;
@property (retain, nonatomic) IBOutlet UILabel *dateLabel;
@property (retain, nonatomic) IBOutlet UILabel *votesLabel;
@property (retain, nonatomic) IBOutlet UIButton *upvoteButton;
@property (retain, nonatomic) IBOutlet UIButton *downvoteButton;
@property (retain, nonatomic) IBOutlet UIButton *infoButton;

@end

@implementation PostInfoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"cccc, LLLL d, yyyy 'at' h:mm a"];
    //Optionally for time zone conversions
    [formatter setTimeZone:[NSTimeZone timeZoneWithName:@"..."]];
    
    //    commentsText = [NSString stringWithFormat:@"%@\n%@ (%@)", commentsText, [commentObject objectForKey:@"comment"], ];
    
    self.messageLabel.text = [self.postObject objectForKey:@"message"];
    self.dateLabel.text = [formatter stringFromDate:self.postObject.createdAt];
    
    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    self.votedColor = appDelegate.globalColor2;
    self.notVotedColor = [UIColor grayColor];
    
    if (!(self.parentView.parentView.localView == YES)) {
        self.upvoteButton.enabled = NO;
        self.downvoteButton.enabled = NO;
        
        self.upvoteButton.alpha = .2;
        self.downvoteButton.alpha = .2;
    }
    
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
    PFQuery *query = [PFQuery queryWithClassName:@"Submission_Vote"];
    
    [query whereKey:@"postID" equalTo:[self.postObject objectId]];
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
    PFObject *object = [PFObject objectWithClassName:@"Submission_Vote"];
    
    NSLog(@"We're going to vote now.");
    
    NSUUID *oNSUUID = [[UIDevice currentDevice] identifierForVendor];
    [object setObject:[NSString stringWithString:[oNSUUID UUIDString]] forKey:@"userDeviceID"];
    
    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    
    [object setObject:value forKey:@"voteValue"];
    [object setObject:appDelegate.userLocation forKey:@"location"];
    [object setObject:[self.postObject objectId] forKey:@"postID"];
    [object saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        
        NSLog(@"We're voting now.");
        
        [self refreshVoteCounter];
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
    PFQuery *query = [PFQuery queryWithClassName:@"Submission_Vote"];
    
    [query whereKey:@"postID" equalTo:[self.postObject objectId]];
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
    
    query = [PFQuery queryWithClassName:@"Submission_Vote"];
    
    [query whereKey:@"postID" equalTo:[self.postObject objectId]];
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

- (IBAction)infoButtonClicked:(id)sender {
    UIAlertController *infoAlertController = [UIAlertController alertControllerWithTitle:@"Report this post?" message:@"If you believe this post violates any of the rules, tap the report button." preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
        NSLog(@"User cancelled info.");
    }];
    [infoAlertController addAction:cancelAction];
    
    UIAlertAction *reportAction = [UIAlertAction actionWithTitle:@"Report" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
        UIAlertController *infoAlertController = [UIAlertController alertControllerWithTitle:@"Report this post?" message:@"If you believe this post violates any of the rules, tap the report button." preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
            NSLog(@"User cancelled report.");
        }];
        [infoAlertController addAction:cancelAction];
        
        UIAlertAction *reportAction = [UIAlertAction actionWithTitle:@"Report" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * action) {
            NSLog(@"User confirmed report.");
            [self insertNewReport];
        }];
        [infoAlertController addAction:reportAction];
        
        [self presentViewController:infoAlertController animated:YES completion:nil];
    }];
    [infoAlertController addAction:reportAction];
    
    UIAlertAction *saveAction = [UIAlertAction actionWithTitle:@"Save" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
        NSLog(@"User saved post.");
        [self savePostForSelf];
    }];
    [infoAlertController addAction:saveAction];
    
    UIAlertAction *shareAction = [UIAlertAction actionWithTitle:@"Share" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
        NSLog(@"User shared post.");
    }];
    [infoAlertController addAction:shareAction];
    
    [self presentViewController:infoAlertController animated:YES completion:nil];
}

- (void)insertNewReport {
    NSLog(@"We're going to save the comment now.");
    
    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    
    PFObject *object = [PFObject objectWithClassName:@"Report"];
    [object setObject:self.postObject forKey:@"reportedItem"];
    [object setObject:[self.postObject objectId] forKey:@"reportedItemID"];
    [object setObject:@"post" forKey:@"reportedType"];
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

- (void)savePostForSelf {
    NSLog(@"We're going to save the comment now.");
    
    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    
    PFObject *object = [PFObject objectWithClassName:@"Save"];
    [object setObject:self.postObject forKey:@"savedItem"];
    [object setObject:[self.postObject objectId] forKey:@"savedItemID"];
    [object setObject:@"post" forKey:@"savedType"];
    [object setObject:appDelegate.currentUser forKey:@"savingUser"];
    if (appDelegate.userLocation) [object setObject:appDelegate.userLocation forKey:@"savingLocation"];
    [object saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (!error) {
            NSLog(@"Report has been submitted.");
            
            UIAlertController *infoAlertController = [UIAlertController alertControllerWithTitle:@"Saved" message:@"You have saved this post." preferredStyle:UIAlertControllerStyleAlert];
            
            UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault handler:nil];
            [infoAlertController addAction:okAction];
            
            [self presentViewController:infoAlertController animated:YES completion:nil];
            
        } else {
            UIAlertController *infoAlertController = [UIAlertController alertControllerWithTitle:@"Error" message:@"There was a problem in saving. Please try again later." preferredStyle:UIAlertControllerStyleAlert];
            
            UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault handler:nil];
            [infoAlertController addAction:okAction];
            
            [self presentViewController:infoAlertController animated:YES completion:nil];
        }
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
    [_infoButton release];
    [super dealloc];
}
@end
