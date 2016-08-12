
#import <UIKit/UIKit.h>
#import "Parse/Parse.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate> {

}

@property (nonatomic, retain) UIWindow *window;
@property (nonatomic, retain) UIColor *globalColor1;
@property (nonatomic, retain) UIColor *globalColor2;
@property (nonatomic) UIBarStyle globalBarStyle;
@property (strong, nonatomic) NSString *userDeviceID;
@property (strong, nonatomic) PFUser *currentUser;
@property (nonatomic, retain) PFGeoPoint *userLocation;
@property (nonatomic) BOOL userLocationSet;
@property (nonatomic) BOOL onSimulator;

@end
