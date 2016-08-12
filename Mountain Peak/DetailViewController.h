//
//  DetailViewController.h
//  LocalMediaSharer
//
//  Created by HHWS on 27/10/14.
//
//

#import <UIKit/UIKit.h>
#import "Parse/Parse.h"
#import "PhotosViewController.h"

@interface DetailViewController : UIViewController

- (IBAction)refresh:(id)sender;
- (void)setUpComments:(NSArray *)images;
- (NSString *)aboutText;
- (void)setupScrollView;

@property (strong, nonatomic) PFObject *object;
@property (strong, nonatomic) PhotosViewController *parentView;
@property (strong, nonatomic) NSArray *comments;

@end
