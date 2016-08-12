//
//  EventsViewController.m
//  Mountain Peak
//
//  Created by HHWS on 17/11/14.
//
//

#import "EventsViewController.h"

@interface EventsViewController ()

@end

@implementation EventsViewController

- (id)init
{
    self = [super init];
    if (self) {
        self.tabBarItem.title = @"Events";
        
        self.title = @"Events";
        
        // Create a UIImage from a file
        // This will use Hypno@2x on retina display devices
        UIImage *tabBarImage = [UIImage imageNamed:@"theatre_mask.png"];
        
        // Put that image on the tab bar item
        self.tabBarItem.image = tabBarImage;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
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
