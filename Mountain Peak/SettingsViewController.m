//
//  SettingsViewController.m
//  LocalMediaSharer
//
//  Created by HHWS on 28/10/14.
//
//

#import "SettingsViewController.h"

@interface SettingsViewController ()

@end

@implementation SettingsViewController

- (id)init
{
    self = [super init];
    if (self) {
        self.tabBarItem.title = @"More";
        
        self.title = @"More";
        
        // Create a UIImage from a file
        // This will use Hypno@2x on retina display devices
        UIImage *tabBarImage = [UIImage imageNamed:@"about.png"];
        
        // Put that image on the tab bar item
        self.tabBarItem.image = tabBarImage;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
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

@end
