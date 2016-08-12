//
//  ViewController.h
//  SavingImagesTutorial
//
//  Created by Sidwyn Koh on 29/1/12.
//  Copyright (c) 2012 Parse. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>
#import "MBProgressHUD.h"
#include <stdlib.h> // For math functions including arc4random (a number randomizer)

@interface PhotosViewController : UIViewController <UINavigationControllerDelegate, UIImagePickerControllerDelegate, MBProgressHUDDelegate>
{
    IBOutlet UIScrollView *photoScrollView;
    NSMutableArray *allImages;
    
    MBProgressHUD *HUD;
    MBProgressHUD *refreshHUD;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil type:(NSString *)type;
- (IBAction)refresh:(id)sender;
- (void)setUpImages:(NSArray *)images;
- (void)buttonTouched:(id)sender;
- (void)setUserLocation;

@property BOOL localView;
@property BOOL lastRefreshWasTrueLocation;
@property (strong, nonatomic) NSString *parseClassName;

@property (nonatomic) int thumbCols;
@property (nonatomic) int thumbWidth;
@property (nonatomic) int thumbHeight;


@end
