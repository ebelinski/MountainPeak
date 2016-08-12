//
//  FeedbackViewController.m
//  Mountain Peak
//
//  Created by HHWS on 19/11/14.
//
//

#import <MessageUI/MessageUI.h>

#import "FeedbackViewController.h"
#import "AppDelegate.h"

@interface FeedbackViewController () <MFMailComposeViewControllerDelegate>
@property (retain, nonatomic) IBOutlet UIButton *feedbackButton;

@end

@implementation FeedbackViewController

- (id)init
{
    self = [super init];
    if (self) {
        self.title = @"Feedback";
        
        self.tabBarItem.title = @"Feedback";
        UIImage *tabBarImage = [UIImage imageNamed:@"text.png"];
        self.tabBarItem.image = tabBarImage;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    
    self.feedbackButton.tintColor = appDelegate.globalColor2;
    
    [self sendFeedback:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)sendFeedback:(id)sender {
    if ([MFMailComposeViewController canSendMail])
    {
        MFMailComposeViewController *mail = [[MFMailComposeViewController alloc] init];
        mail.mailComposeDelegate = self;
        [mail setSubject:@"Mountain Peak Feedback"];
        [mail setMessageBody:@"" isHTML:NO];
        [mail setToRecipients:@[@"mountainpeakapp@gmail.com"]];
        
        [self presentViewController:mail animated:YES completion:NULL];
    }
    else
    {
        NSLog(@"This device cannot send email");
    }
}

- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error
{
    if (result == MFMailComposeResultSent)
    {
        NSLog(@"\n\n Email Sent");
//        [AppDelegate showAlert:@"Email Sent"];
        
    }
    if([self respondsToSelector:@selector(dismissViewControllerAnimated:completion:)])
        [self dismissViewControllerAnimated:YES completion:nil];
    else
        [self dismissViewControllerAnimated:YES completion:nil];
    //    [self dismissViewControllerAnimated:YES completion:nil];
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
    [_feedbackButton release];
    [super dealloc];
}
@end
