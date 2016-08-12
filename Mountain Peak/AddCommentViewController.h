//
//  AddCommentViewController.h
//  Mountain Peak
//
//  Created by HHWS on 9/11/14.
//
//

#import <UIKit/UIKit.h>
#import "DetailViewController.h"

@interface AddCommentViewController : UIViewController
{
    NSMutableArray *allComments;
}

- (id)initWithPostID:(NSString *)postID;

@property (strong, nonatomic) NSString *postID;
@property (strong, nonatomic) DetailViewController *parentView;

@end
