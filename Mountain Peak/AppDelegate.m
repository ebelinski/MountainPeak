
#import "Parse/Parse.h"
#import "AppDelegate.h"
#import "MyTableController.h"
#import "SettingsViewController.h"
#import "PhotosViewController.h"
#import "EventsViewController.h"
#import "FeedbackViewController.h"
#import "IntroViewController.h"
#import "MeViewController.h"
#import "MyStuffViewController.h"
#import "Constants.h"

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Check if on simulator before compile
    #if TARGET_IPHONE_SIMULATOR
    self.onSimulator = YES;
    #endif
    
    // Configuration for Parse
    [Parse setApplicationId:ParseApplicationID
                  clientKey:ParseClientKey];
    [PFAnalytics trackAppOpenedWithLaunchOptions:launchOptions];
    NSUUID *oNSUUID = [[UIDevice currentDevice] identifierForVendor];
    self.userDeviceID = [NSString stringWithString:[oNSUUID UUIDString]];
    
    // Login to Parse
    self.currentUser = [PFUser currentUser];
    if (!self.currentUser) {
        PFUser *user = [PFUser user];
        
        user.username = self.userDeviceID;
        user.password = @"password";
        
        [user signUpInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            if (error) {
                // Assume the error is because the user already existed.
                [PFUser logInWithUsername:self.userDeviceID password:@"password"];
            } else {
                self.currentUser = [PFUser currentUser];
            }
        }];
    }
    
    // 
    
    // Color scheme configuration
    
//    self.globalColor1 = [UIColor colorWithRed:0 green:0.553 blue:0.012 alpha:1];
//    self.globalColor1 = [UIColor colorWithRed:0.541 green:0 blue:0.918 alpha:1]; // Lighter purple
    //    self.globalColor1 = [UIColor purpleColor];
//    self.globalColor1 = [UIColor colorWithRed:0.827 green:0.827 blue:0.827 alpha:1]; // Light gray
    self.globalColor1 = [UIColor colorWithRed:1 green:1 blue:1 alpha:1]; // White
    
//    self.globalColor2 = [UIColor whiteColor];
    self.globalColor2 = [UIColor colorWithRed:0.016 green:0.635 blue:0 alpha:1]; // Green
    
//    self.globalBarStyle = UIBarStyleBlack;
    self.globalBarStyle = UIBarStyleDefault;
    
    // Create all of the tab views
    
    PhotosViewController *gridLocal = [[PhotosViewController alloc] initWithNibName:@"PhotosViewController" bundle:nil type:@"local"];
    UINavigationController *gridLocalNav = [[UINavigationController alloc] initWithRootViewController:gridLocal];
    
    PhotosViewController *gridAll = [[PhotosViewController alloc] initWithNibName:@"PhotosViewController" bundle:nil type:@"all"];
    UINavigationController *gridAllNav = [[UINavigationController alloc] initWithRootViewController:gridAll];
    
    PhotosViewController *gridEvents = [[PhotosViewController alloc] initWithNibName:@"PhotosViewController" bundle:nil type:@"events"];
    UINavigationController *gridEventsNav = [[UINavigationController alloc] initWithRootViewController:gridEvents];
    
    FeedbackViewController *feedback = [[FeedbackViewController alloc] init];
    UINavigationController *feedbackNav = [[UINavigationController alloc] initWithRootViewController:feedback];
    
    MyStuffViewController *me = [[MyStuffViewController alloc] init];
    UINavigationController *meNav = [[UINavigationController alloc] initWithRootViewController:me];
    
    SettingsViewController *settings = [[SettingsViewController alloc] init];
    UINavigationController *settingsNav = [[UINavigationController alloc] initWithRootViewController:settings];
    
    // Set colors for all the views
    
    [gridLocalNav.navigationBar setBarStyle:self.globalBarStyle];
    [gridAllNav.navigationBar setBarStyle:self.globalBarStyle];
    [gridEventsNav.navigationBar setBarStyle:self.globalBarStyle];
    [meNav.navigationBar setBarStyle:self.globalBarStyle];
    [settingsNav.navigationBar setBarStyle:self.globalBarStyle];
    
//    [gridLocalNav.navigationBar setBarTintColor:self.globalColor1];
//    [gridAllNav.navigationBar setBarTintColor:self.globalColor1];
//    [settingsNav.navigationBar setBarTintColor:self.globalColor1];
    
    [gridLocalNav.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName : self.globalColor2}];
    [gridAllNav.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName : self.globalColor2}];
    [gridEventsNav.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName : self.globalColor2}];
    [meNav.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName : self.globalColor2}];
    [settingsNav.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName : self.globalColor2}];
    
    [gridLocalNav.navigationBar setTintColor:self.globalColor2];
    [gridAllNav.navigationBar setTintColor:self.globalColor2];
    [gridEventsNav.navigationBar setTintColor:self.globalColor2];
    [meNav.navigationBar setTintColor:self.globalColor2];
    [settingsNav.navigationBar setTintColor:self.globalColor2];
    
    UITabBarController *tabBarController = [[UITabBarController alloc] init];
//    [tabBarController.tabBar setBarTintColor:self.globalColor1];
    [tabBarController.tabBar setTintColor:self.globalColor2];
    
    tabBarController.viewControllers = @[gridLocalNav, gridAllNav, gridEventsNav, meNav, settingsNav];
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.rootViewController = tabBarController;
    
    [self.window makeKeyAndVisible];
    
    return YES;
}

@end
