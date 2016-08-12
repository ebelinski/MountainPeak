//
//  Cell.m
//  LocalMediaSharer
//
//  Created by HHWS on 29/10/14.
//
//

#import "Cell.h"

@interface Cell ()

@end

@implementation Cell

- (void)awakeFromNib {
//    NSData *imageData = [[self.object objectForKey:@"file"] getData];
//    UIImage *image = [UIImage imageWithData:imageData];
//    
//    [self.imageView initWithImage:image];
}

- (void)dealloc {
    [_imageView release];
    [self.backgroundView release];
    [super dealloc];
}
@end
