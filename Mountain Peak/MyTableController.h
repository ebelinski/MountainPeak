#import <Parse/Parse.h>

@interface MyTableController : PFQueryTableViewController

- (id)initWithStyle:(UITableViewStyle)style type:(NSString *)type;

@property (strong, nonatomic) PFGeoPoint *userLocation;
@property BOOL localView;

@end
