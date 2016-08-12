//
//  DetailViewController.m
//  LocalMediaSharer
//
//  Created by HHWS on 27/10/14.
//
//

#import "DetailViewController.h"
#import "Parse/Parse.h"
#import "PhotosViewController.h"
#import "AddCommentViewController.h"
#import "AppDelegate.h"
#import "PostInfoViewController.h"
#import "CommentViewController.h"

@interface DetailViewController ()

@property (retain, nonatomic) IBOutlet UIScrollView *scrollView;

@end

@implementation DetailViewController

@synthesize object;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if (self.parentView.localView == YES) {
        UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(insertNewComment:)];
        self.navigationItem.rightBarButtonItem = addButton;
    }
    
//    [self.message setText:[self aboutText]];
    [self refresh:nil];
//    [self setupScrollView];
}

- (void)setupScrollView
{
    int screenWidth = (int)[UIScreen mainScreen].bounds.size.width;
    
    NSData *imageData = [[self.object objectForKey:@"file"] getData];
    UIImage *fullSizeImage = [UIImage imageWithData:imageData];
    
    CGSize newSize = CGSizeMake(screenWidth*2, screenWidth*2);
    UIGraphicsBeginImageContext( newSize );
    [fullSizeImage drawInRect:CGRectMake(0,0,newSize.width,newSize.height)];
    UIImage * newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    int height = 0;
    int imageHeight = screenWidth;
    int infoHeight = 150;
    int commentHeight = 90;
    
    // Add image view & incr height
    
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, imageHeight, imageHeight)];
    imageView.image = newImage;
    [self.scrollView addSubview:imageView];
    height += imageHeight;
    
    // Add info view & incr height
    
    PostInfoViewController *postInfo = [[PostInfoViewController alloc] initWithNibName:@"PostInfoViewController" bundle:nil];
    postInfo.parentView = self;
    postInfo.postObject = self.object;
    postInfo.view.frame = CGRectMake(0, height, screenWidth, infoHeight);
    [self.scrollView addSubview:postInfo.view];
    height += infoHeight;
    
    // Add each comment view & incr height
    
    CommentViewController *cvc = nil;
    for (PFObject *commentObject in self.comments) {
        cvc = [[CommentViewController alloc] initWithNibName:@"CommentViewController" bundle:nil];
        postInfo.parentView = self;
        cvc.commentObject = commentObject;
        cvc.view.frame = CGRectMake(0, height, screenWidth, commentHeight);
        height += commentHeight;
        
        [self.scrollView addSubview:cvc.view];
    }
    
    self.scrollView.contentSize = CGSizeMake(screenWidth, height);
}

// Depreciated method
- (NSString *)aboutText
{
    // Formatting date
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"cccc, LLLL d, yyyy 'at' h:mm a"];
    //Optionally for time zone conversions
    [formatter setTimeZone:[NSTimeZone timeZoneWithName:@"..."]];
    
    //    [self.dateLabel setText:[formatter stringFromDate:self.object.createdAt]];
    
    NSString *text = [NSString stringWithFormat:@"%@ — %@", [self.object objectForKey:@"message"], [formatter stringFromDate:self.object.createdAt]];
    
    return text;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)insertNewComment:(id)sender {

    AddCommentViewController *newCommentViewController = [[AddCommentViewController alloc] initWithPostID:[self.object objectId]];
    newCommentViewController.parentView = self;
    
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:newCommentViewController];
    navController.restorationIdentifier = NSStringFromClass([navController class]);
    
    navController.modalPresentationStyle = UIModalPresentationFormSheet;
    
    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    [navController.navigationBar setBarStyle:appDelegate.globalBarStyle];
    [navController.navigationBar setBarTintColor:appDelegate.globalColor1];
    [navController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName : appDelegate.globalColor2}];
    [navController.navigationBar setTintColor:appDelegate.globalColor2];
    
    [self presentViewController:navController animated:YES completion:NULL];
}

- (IBAction)refresh:(id)sender
{
    PFQuery *query = [PFQuery queryWithClassName:@"Comment"];
    
    [query whereKey:@"postID" equalTo:[self.object objectId]];
    [query orderByAscending:@"createdAt"];
    
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
//            NSLog(@"Successfully retrieved %lu comments.", (unsigned long)objects.count);
            
            [self setUpComments:objects];
            
            self.comments = objects;
            
            [self setupScrollView];
            
        } else {
            NSLog(@"Error: %@ %@", error, [error userInfo]);
        }
    }];
}

- (void)setUpComments:(NSArray *)comments
{
    NSString *commentsText = @"";
    
    for (PFObject *comment in comments) {
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"LLLL d 'at' h:mm a"];
        //Optionally for time zone conversions
        [formatter setTimeZone:[NSTimeZone timeZoneWithName:@"..."]];
        
        commentsText = [NSString stringWithFormat:@"%@\n%@ (%@)", commentsText, [comment objectForKey:@"comment"], [formatter stringFromDate:self.object.createdAt]];
    }
    
    // Depreciated action
//    [self.message setText:[NSString stringWithFormat:@"%@\n%@", [self aboutText], commentsText]];
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
    [_scrollView release];
    [super dealloc];
}
@end
