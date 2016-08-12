#import "PhotosViewController.h"
#import "DetailViewController.h"
#import "AddNewViewController.h"
#import "AppDelegate.h"
#import "IntroViewController.h"


@interface PhotosViewController() <CLLocationManagerDelegate>

@end

@implementation PhotosViewController

#define PADDING_TOP 0 // For placing the images nicely in the grid
#define PADDING 4

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil type:(NSString *)type
{
    int screenWidth = (int)[UIScreen mainScreen].bounds.size.width;
    
    if (screenWidth > 500) {
        self.thumbCols = 3;
    } else {
        self.thumbCols = 2;
    }
    
    self.thumbWidth = (screenWidth / self.thumbCols) - (PADDING + 2);
    self.thumbHeight = self.thumbWidth;
    
//    NSLog(@"Original width: %i", (int)[UIScreen mainScreen].bounds.size.width);
//    NSLog(@"Thumb size: %i", self.thumbWidth);
    
    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
    [flowLayout setItemSize:CGSizeMake(150, 150)];
    //    UIEdgeInsets *insets = UIEdgeInsetsMake(0, 0, 0, 0);
    flowLayout.sectionInset = UIEdgeInsetsMake(0, 0, 0, 0);
    [flowLayout setScrollDirection:UICollectionViewScrollDirectionVertical];
    
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        if ([type isEqualToString:@"all"]) {
            self.localView = NO;
            self.title = @"All Peaks";
            self.tabBarItem.title = @"All Peaks";
            UIImage *tabBarImage = [UIImage imageNamed:@"mountains.png"];
            self.tabBarItem.image = tabBarImage;
            self.parseClassName = @"Submission";
        } else if ([type isEqualToString:@"events"]) {
            self.localView = YES; // TEMPORARY HACK
            self.title = @"Nearby Events";
            self.tabBarItem.title = @"Events";
            UIImage *tabBarImage = [UIImage imageNamed:@"theatre_mask.png"];
            self.tabBarItem.image = tabBarImage;
            self.parseClassName = @"EventSubmission";
        } else {
            self.localView = YES;
            self.title = @"Your Peak";
            self.tabBarItem.title = @"Home";
            UIImage *tabBarImage = [UIImage imageNamed:@"cottage.png"];
            self.tabBarItem.image = tabBarImage;
            self.parseClassName = @"Submission";
        }
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - Main methods

- (IBAction)refresh:(id)sender
{
//    NSLog(@"Showing Refresh HUD");
    refreshHUD = [[MBProgressHUD alloc] initWithView:self.view];
    [self.view addSubview:refreshHUD];
	
    // Register for HUD callbacks so we can remove it from the window at the right time
    refreshHUD.delegate = self;
	
    // Show the HUD while the provided method executes in a new thread
    [refreshHUD show:YES];
    
    PFQuery *query = [PFQuery queryWithClassName:self.parseClassName];
    
    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    if (appDelegate.onSimulator == YES) {
        [query whereKey:@"location" nearGeoPoint:[PFGeoPoint geoPointWithLatitude:44.983014785 longitude:-93.24363534] withinMiles:2.0];
    } else if (appDelegate.userLocation && self.localView) {
//        NSLog(@"User location is: %f %f", appDelegate.userLocation.latitude, appDelegate.userLocation.longitude);
        [query whereKey:@"location" nearGeoPoint:appDelegate.userLocation withinMiles:2.0];
        self.lastRefreshWasTrueLocation = YES;
    } else if (self.localView) {
        [query whereKey:@"location" nearGeoPoint:[PFGeoPoint geoPointWithLatitude:20 longitude:20] withinMiles:2.0];
        self.lastRefreshWasTrueLocation = NO;
    }
    [query orderByAscending:@"createdAt"];
    
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSDateComponents *daysAgoDateComponents = [[NSDateComponents alloc] init];
    [daysAgoDateComponents setDay:-80];
    NSDate *daysAgoDate = [gregorian dateByAddingComponents:daysAgoDateComponents toDate:[NSDate date] options:0];
    NSDateComponents *cutoffDateComponents = [gregorian components:NSCalendarUnitMonth|NSCalendarUnitDay|NSCalendarUnitYear fromDate:daysAgoDate];
    NSDate *cutoffDate = [gregorian dateFromComponents:cutoffDateComponents];
    
    [query whereKey:@"createdAt" greaterThanOrEqualTo:cutoffDate];
    
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            // The find succeeded.
            if (refreshHUD) {
                [refreshHUD hide:YES];
                
                refreshHUD = [[MBProgressHUD alloc] initWithView:self.view];
                [self.view addSubview:refreshHUD];
                
                // The sample image is based on the work by http://www.pixelpressicons.com, http://creativecommons.org/licenses/by/2.5/ca/
                // Make the customViews 37 by 37 pixels for best results (those are the bounds of the build-in progress indicators)
                refreshHUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"37x-Checkmark.png"]];
                
                // Set custom view mode
                refreshHUD.mode = MBProgressHUDModeCustomView;
                
                refreshHUD.delegate = self;
            }
            NSLog(@"Successfully retrieved %lu photos.", (unsigned long)objects.count);
            
            // Retrieve existing objectIDs

            NSMutableArray *oldCompareObjectIDArray = [NSMutableArray array];
            for (UIView *view in [photoScrollView subviews]) {
                if ([view isKindOfClass:[UIButton class]]) {
                    UIButton *eachButton = (UIButton *)view;
                    [oldCompareObjectIDArray addObject:[eachButton titleForState:UIControlStateReserved]];
                }
            }
                        
            NSMutableArray *oldCompareObjectIDArray2 = [NSMutableArray arrayWithArray:oldCompareObjectIDArray];
            
            // If there are photos, we start extracting the data
            // Save a list of object IDs while extracting this data
            
            NSMutableArray *newObjectIDArray = [NSMutableArray array];            
            if (objects.count > 0) {
                for (PFObject *eachObject in objects) {
                    [newObjectIDArray addObject:[eachObject objectId]];
                }
            }
            
            // Compare the old and new object IDs
            NSMutableArray *newCompareObjectIDArray = [NSMutableArray arrayWithArray:newObjectIDArray];
            NSMutableArray *newCompareObjectIDArray2 = [NSMutableArray arrayWithArray:newObjectIDArray];
            if (oldCompareObjectIDArray.count > 0) {
                // New objects
                [newCompareObjectIDArray removeObjectsInArray:oldCompareObjectIDArray];
                // Remove old objects if you delete them using the web browser
                [oldCompareObjectIDArray removeObjectsInArray:newCompareObjectIDArray2];
                if (oldCompareObjectIDArray.count > 0) {
                    // Check the position in the objectIDArray and remove
                    NSMutableArray *listOfToRemove = [[NSMutableArray alloc] init];
                    for (NSString *objectID in oldCompareObjectIDArray){
                        int i = 0;
                        for (NSString *oldObjectID in oldCompareObjectIDArray2){
                            if ([objectID isEqualToString:oldObjectID]) {
                                // Make list of all that you want to remove and remove at the end
                                [listOfToRemove addObject:[NSNumber numberWithInt:i]];
                            }
                            i++;
                        }
                    }
                    
                    // Remove from the back
                    NSSortDescriptor *highestToLowest = [NSSortDescriptor sortDescriptorWithKey:@"self" ascending:NO];
                    [listOfToRemove sortUsingDescriptors:[NSArray arrayWithObject:highestToLowest]];
                    
                    for (NSNumber *index in listOfToRemove){                        
                        [allImages removeObjectAtIndex:[index intValue]];
                    }
                }
            }
            
            // Add new objects
            for (NSString *objectID in newCompareObjectIDArray){
                for (PFObject *eachObject in objects){
                    if ([[eachObject objectId] isEqualToString:objectID]) {
                        NSMutableArray *selectedPhotoArray = [[NSMutableArray alloc] init];
                        [selectedPhotoArray addObject:eachObject];
                                                
                        if (selectedPhotoArray.count > 0) {
                            [allImages addObjectsFromArray:selectedPhotoArray];                
                        }
                    }
                }
            }
            
            // Remove and add from objects before this
            [self setUpImages:allImages];
            
        } else {
            [refreshHUD hide:YES];
            
            // Log details of the failure
            NSLog(@"Error: %@ %@", error, [error userInfo]);
        }
    }];
}

- (void)setUpImages:(NSArray *)images
{
    // Contains a list of all the BUTTONS
    allImages = [images mutableCopy];
    
    // This method sets up the downloaded images and places them nicely in a grid
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(queue, ^{
        NSMutableArray *imageDataArray = [NSMutableArray array];
        
        // Iterate over all images and get the data from the PFFile
//        for (int i = 0; i < images.count; i++) {
        for (int i = (int)(images.count-1); i >= 0; i--) {
            PFObject *eachObject = [images objectAtIndex:i];
            
            PFFile *theImage = nil;
            if ([eachObject objectForKey:@"thumbnail"]) {
                theImage = [eachObject objectForKey:@"thumbnail"];
//                NSLog(@"Using thumbnail");
            } else {
                theImage = [eachObject objectForKey:@"file"];
//                NSLog(@"Using file");
            }
            
            NSData *imageData = [theImage getData];
//            NSLog(@"SIZE OF IMAGE: %lu ", (unsigned long)imageData.length);
            UIImage *image = [UIImage imageWithData:imageData];
            
            
//            CGSize newSize = CGSizeMake(THUMBNAIL_WIDTH*2, THUMBNAIL_HEIGHT*2);
            CGSize newSize = CGSizeMake(self.thumbWidth*2, self.thumbHeight*2);
            UIGraphicsBeginImageContext( newSize );
            [image drawInRect:CGRectMake(0,0,newSize.width,newSize.height)];
            UIImage * newImage = UIGraphicsGetImageFromCurrentImageContext();
            UIGraphicsEndImageContext();
            
            
            [imageDataArray addObject:newImage];
            
            theImage = nil;
            imageData = nil;
            image = nil;
        }
                   
        // Dispatch to main thread to update the UI
        dispatch_async(dispatch_get_main_queue(), ^{
            // Remove old grid
            for (UIView *view in [photoScrollView subviews]) {
                if ([view isKindOfClass:[UIButton class]]) {
                    [view removeFromSuperview];
                }
            }
            
            // Create the buttons necessary for each image in the grid
            for (int i = 0; i < [imageDataArray count]; i++) {
                PFObject *eachObject = [images objectAtIndex:i];
                UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
                UIImage *image = [imageDataArray objectAtIndex:i];
                [button setImage:image forState:UIControlStateNormal];
                button.showsTouchWhenHighlighted = YES;
                [button addTarget:self action:@selector(buttonTouched:) forControlEvents:UIControlEventTouchUpInside];
                button.tag = i;
                button.frame = CGRectMake(self.thumbWidth * (i % self.thumbCols) + PADDING * (i % self.thumbCols) + PADDING,
                                          self.thumbHeight * (i / self.thumbCols) + PADDING * (i / self.thumbCols) + PADDING + PADDING_TOP,
                                          self.thumbWidth,
                                          self.thumbHeight);
                button.imageView.contentMode = UIViewContentModeScaleAspectFill;
                button.imageView.layer.cornerRadius = 10.0;
                [button setTitle:[eachObject objectId] forState:UIControlStateReserved];
                [photoScrollView addSubview:button];
            }
            
            // Size the grid accordingly
            int rows = (int)images.count / self.thumbCols;
            if (((float)images.count / self.thumbCols) - rows != 0) {
                rows++;
            }
            int height = self.thumbHeight * rows + PADDING * rows + PADDING + PADDING_TOP;
            
            photoScrollView.contentSize = CGSizeMake(self.view.frame.size.width, height);
            photoScrollView.clipsToBounds = YES;
        });
    });
}

- (void)buttonTouched:(id)sender {
    PFObject * object = (PFObject *)[allImages objectAtIndex:((allImages.count-1) - [sender tag])];
    
    DetailViewController * dvc = [[DetailViewController alloc] init];
    dvc.object = object;
    dvc.parentView = self;
    
    [self.navigationController pushViewController:dvc animated:YES];
}


#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    allImages = [[NSMutableArray alloc] init];
    
    UIBarButtonItem *refreshButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(refresh:)];
    self.navigationItem.leftBarButtonItem = refreshButton;
    
    if (self.localView == YES) {
        UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(insertNewObject:)];
        self.navigationItem.rightBarButtonItem = addButton;
        
        [self setUserLocation];
    }
    
    [self performSelector:@selector(refresh:) withObject:nil afterDelay:0.5];
    
    if (self.localView) {
//        IntroViewController *intro = [[IntroViewController alloc] init];
//        [self presentViewController:intro animated:NO completion:NULL];
    }
}

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status {
    if (status == kCLAuthorizationStatusAuthorizedWhenInUse) {
//        [self setUserLocation];
    } else {
        
    }
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)setUserLocation {
//    NSLog(@"Going to try to set the user location now.");
    
    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    
    if (appDelegate.onSimulator == YES) {
        PFGeoPoint *geoPoint = [PFGeoPoint geoPointWithLatitude:44.983014785 longitude:-93.24363534];
        appDelegate.userLocation = geoPoint;
        NSLog(@"Set artificial location to %f %f", geoPoint.latitude, geoPoint.longitude);
        
        appDelegate.userLocationSet = YES;
    } else {
        [PFGeoPoint geoPointForCurrentLocationInBackground:^(PFGeoPoint *geoPoint, NSError *error) {
            if (!error) {
                
                appDelegate.userLocation = geoPoint;
                NSLog(@"Set location to %f %f", geoPoint.latitude, geoPoint.longitude);
                
                appDelegate.userLocationSet = YES;
                
                if (!self.lastRefreshWasTrueLocation) {
                    //                [self performSelector:@selector(refresh:) withObject:nil afterDelay:2.0];
                }
                
    //            [self refresh:nil];
            } else {
                NSLog(@"Error getting location");
                
                appDelegate.userLocationSet = NO;
                
                UIAlertController *pictureAlertController = [UIAlertController alertControllerWithTitle:@"Location Unknown" message:@"Mountain Peak does not know your location. You may need to enable in by going to Settings > Privacy > Location Services > Mountain Peak > and select While Using the App." preferredStyle:UIAlertControllerStyleAlert];
                
                UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault handler:nil];
                
                [pictureAlertController addAction:okAction];
                [self presentViewController:pictureAlertController animated:YES completion:nil];
            }
        }];
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark -
#pragma mark UIImagePickerControllerDelegate methods

#pragma mark -
#pragma mark MBProgressHUDDelegate methods

- (void)hudWasHidden:(MBProgressHUD *)hud {
    // Remove HUD from screen when the HUD hides
    [HUD removeFromSuperview];
	HUD = nil;
}

- (void)insertNewObject:(id)sender {
    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    
    if (appDelegate.userLocationSet || appDelegate.onSimulator) {
        AddNewViewController *newObjectViewController = [[AddNewViewController alloc] init];
        
        newObjectViewController.parentView = self;
        
        UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:newObjectViewController];
        navController.restorationIdentifier = NSStringFromClass([navController class]);
        
        navController.modalPresentationStyle = UIModalPresentationFormSheet;
        
        AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
        [navController.navigationBar setBarStyle:appDelegate.globalBarStyle];
        [navController.navigationBar setBarTintColor:appDelegate.globalColor1];
        [navController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName : appDelegate.globalColor2}];
        [navController.navigationBar setTintColor:appDelegate.globalColor2];
        
        [self presentViewController:navController animated:YES completion:NULL];

    } else {
        UIAlertController *pictureAlertController = [UIAlertController alertControllerWithTitle:@"Location Unknown" message:@"Mountain Peak does not know your location, which is required to post something. You may need to enable in by going to Settings > Privacy > Location Services > Mountain Peak > and select While Using the App." preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault handler:nil];
        
        [pictureAlertController addAction:okAction];
        [self presentViewController:pictureAlertController animated:YES completion:nil];
    }
}

@end
