//
//  MeViewController.m
//  Mountain Peak
//
//  Created by HHWS on 26/11/14.
//
//

#import "MeViewController.h"
#import "AppDelegate.h"

@interface MeViewController ()

@property (retain, nonatomic) IBOutlet UIButton *myPostsButton;
@property (retain, nonatomic) IBOutlet UIButton *myCommentsButton;
@property (retain, nonatomic) IBOutlet UIButton *savedPostsButton;

@end

@implementation MeViewController

- (id)init {
    self = [super init];
    if (self) {
        self.title = @"My Stuff";
        self.tabBarItem.title = @"Me";
        UIImage *tabBarImage = [UIImage imageNamed:@"happy.png"];
        self.tabBarItem.image = tabBarImage;
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    
    self.myPostsButton.tintColor = appDelegate.globalColor2;
    self.myCommentsButton.tintColor = appDelegate.globalColor2;
    self.savedPostsButton.tintColor = appDelegate.globalColor2;
}

- (IBAction)showMyPosts:(id)sender {
    UIAlertController *infoAlertController = [UIAlertController alertControllerWithTitle:@"Not available" message:@"This feature has not been implemented. Check back later!" preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault handler:nil];
    [infoAlertController addAction:okAction];
    
    [self presentViewController:infoAlertController animated:YES completion:nil];
}

- (IBAction)showMyComments:(id)sender {
    UIAlertController *infoAlertController = [UIAlertController alertControllerWithTitle:@"Not available" message:@"This feature has not been implemented. Check back later!" preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault handler:nil];
    [infoAlertController addAction:okAction];
    
    [self presentViewController:infoAlertController animated:YES completion:nil];
}

- (IBAction)showSavedPosts:(id)sender {
    UIAlertController *infoAlertController = [UIAlertController alertControllerWithTitle:@"Not available" message:@"This feature has not been implemented. Check back later!" preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault handler:nil];
    [infoAlertController addAction:okAction];
    
    [self presentViewController:infoAlertController animated:YES completion:nil];
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
    [_myPostsButton release];
    [_myCommentsButton release];
    [_savedPostsButton release];
    [super dealloc];
}
@end
