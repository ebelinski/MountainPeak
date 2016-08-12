//
//  AddCommentViewController.m
//  Mountain Peak
//
//  Created by HHWS on 9/11/14.
//
//

#import "AddCommentViewController.h"
#import "Parse/Parse.h"
#import "AppDelegate.h"
#import "DetailViewController.h"

@interface AddCommentViewController ()

@property (retain, nonatomic) IBOutlet UITextField *commentText;
@property (retain, nonatomic) IBOutlet UIButton *addCommentButton;

@end

@implementation AddCommentViewController

- (id)initWithPostID:(NSString *)postID
{
    self = [super init];
    if (self) {
        self.title = @"New Comment";
        self.postID = postID;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancelInsert:)];
    self.navigationItem.leftBarButtonItem = cancelButton;
    
    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    self.addCommentButton.tintColor = appDelegate.globalColor2;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [self.commentText becomeFirstResponder];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)insertNewComment:(id)sender {
    BOOL upload = YES;
    
    if ([self.commentText.text isEqualToString:@""]) {
        upload = NO;
        
        UIAlertController *messageAlertController = [UIAlertController alertControllerWithTitle:@"Missing Text" message:@"You cannot submit a comment without text." preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault handler:nil];
        
        [messageAlertController addAction:okAction];
        [self presentViewController:messageAlertController animated:YES completion:nil];
    }
    
    if (upload) {
        
        PFObject *object = [PFObject objectWithClassName:@"Comment"];
        
        NSLog(@"We're going to save the comment now.");
        
        
        NSUUID *oNSUUID = [[UIDevice currentDevice] identifierForVendor];
        [object setObject:[NSString stringWithString:[oNSUUID UUIDString]] forKey:@"userDeviceID"];
        PFUser *user = [PFUser currentUser];
        [object setObject:user forKey:@"user"];
        
        AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
        
        [object setObject:[NSString stringWithString:self.commentText.text] forKey:@"comment"];
        [object setObject:appDelegate.userLocation forKey:@"location"];
        [object setObject:self.postID forKey:@"postID"];
        [object saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            // Refresh the table when the object is done saving.
            [self.parentView refresh:nil];
            NSLog(@"We're saving now.");
        }];
        
        [self dismissViewControllerAnimated:YES completion:NULL];
    }
}

- (IBAction)cancelInsert:(id)sender {
    [self dismissViewControllerAnimated:YES completion:NULL];
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
    [_commentText release];
    [_addCommentButton release];
    [super dealloc];
}
@end
