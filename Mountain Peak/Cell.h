//
//  Cell.h
//  LocalMediaSharer
//
//  Created by HHWS on 29/10/14.
//
//

#import <UIKit/UIKit.h>
#import "Parse/Parse.h"

@interface Cell : UICollectionViewCell

@property (retain, nonatomic) IBOutlet UIImageView *imageView;

@property (strong, nonatomic) PFObject *object;

@end
