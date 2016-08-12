//
//  AddNewViewController.h
//  LocalMediaSharer
//
//  Created by HHWS on 28/10/14.
//
//

#import <UIKit/UIKit.h>

@interface AddNewViewController : UIViewController

@property (retain, nonatomic) UIImage *originalImage;
@property (retain, nonatomic) UIImage *thumbnailImage;
@property (strong, nonatomic) id parentView;
@property (strong, nonatomic) PFGeoPoint *userLocation;

@end
