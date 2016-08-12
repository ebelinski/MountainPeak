//
//  AddNewViewController.m
//  LocalMediaSharer
//
//  Created by HHWS on 28/10/14.
//
//

#import "Parse/Parse.h"
#import "AddNewViewController.h"
#import "MyTableController.h"
#import "AppDelegate.h"
#import "PhotosViewController.h"

@interface AddNewViewController () <UINavigationControllerDelegate, UIImagePickerControllerDelegate>

@property (retain, nonatomic) IBOutlet UIImageView *imageView;
@property (retain, nonatomic) IBOutlet UITextField *messageView;
@property (retain, nonatomic) IBOutlet UIButton *selectNewButton;
@property (retain, nonatomic) IBOutlet UIButton *selectExistingButton;

@end

@implementation AddNewViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.title = @"New Post";
    
    UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(insertNewObject:)];
    self.navigationItem.rightBarButtonItem = addButton;
    
    UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancelInsert:)];
    self.navigationItem.leftBarButtonItem = cancelButton;
    
    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    
    self.selectExistingButton.tintColor = appDelegate.globalColor2;
    
    self.selectNewButton.tintColor = appDelegate.globalColor2;
    
//    [self selectImage:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)selectNewImage:(id)sender {
    UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
    
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
        imagePicker.cameraCaptureMode = UIImagePickerControllerCameraCaptureModePhoto;
        
//        CGRect f = imagePicker.view.bounds;
//        f.size.height -= imagePicker.navigationBar.bounds.size.height;
//        CGFloat barHeight = (f.size.height - f.size.width) / 2;
//        UIGraphicsBeginImageContext(f.size);
//        [[UIColor colorWithWhite:0 alpha:.5] set];
//        UIRectFillUsingBlendMode(CGRectMake(0, 0, f.size.width, barHeight), kCGBlendModeNormal);
//        UIRectFillUsingBlendMode(CGRectMake(0, f.size.height - barHeight, f.size.width, barHeight), kCGBlendModeNormal);
//        UIImage *overlayImage = UIGraphicsGetImageFromCurrentImageContext();
//        UIGraphicsEndImageContext();
//        
//        UIImageView *overlayIV = [[UIImageView alloc] initWithFrame:f];
//        overlayIV.image = overlayImage;
//        [imagePicker.cameraOverlayView addSubview:overlayIV];
    } else {
        imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    }
    
    imagePicker.delegate = self;
    
    [self presentViewController:imagePicker animated:YES completion:NULL];
}

- (IBAction)selectExistingImage:(id)sender {
    UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
    
    imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    
    imagePicker.delegate = self;
    
    [self presentViewController:imagePicker animated:YES completion:NULL];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    // Get the image from controller
    UIImage *image = info[UIImagePickerControllerOriginalImage];
    CGSize uncroppedSize = CGSizeMake(1000, (int)(1000*(image.size.height/image.size.width)));
    UIGraphicsBeginImageContext(uncroppedSize);
    
    
    CGRect uncroppedRect = CGRectMake(0, 0, 0, 0);
    uncroppedRect.origin = CGPointMake(0.0,0.0);
    uncroppedRect.size.width  = uncroppedSize.width;
    uncroppedRect.size.height = uncroppedSize.height;
    
    [image drawInRect:uncroppedRect];
    
    UIImage *uncroppedImage = UIGraphicsGetImageFromCurrentImageContext();;
    
    UIGraphicsEndImageContext();
    
//    CGSize imageSize = uncroppedRect.size;
    CGFloat width = uncroppedSize.width;
    CGFloat height = uncroppedSize.height;
    NSLog(@"%f %f", width, height);
    if (width != height) {
        CGFloat newDimension = MIN(width, height);
        CGFloat widthOffset = (width - newDimension) / 2;
        CGFloat heightOffset = (height - newDimension) / 2;
        UIGraphicsBeginImageContextWithOptions(CGSizeMake(newDimension, newDimension), NO, 0.);
        [uncroppedImage drawAtPoint:CGPointMake(-widthOffset, -heightOffset)
                 blendMode:kCGBlendModeCopy
                     alpha:1.];
        self.originalImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
    }
    
//    self.imageView.image = self.originalImage;
    
    
    // Make the medium image to display in this view
    CGSize viewSize = CGSizeMake(640, 640);
    UIGraphicsBeginImageContext(viewSize);
    
    CGRect viewRect = CGRectMake(0, 0, 0, 0);
    viewRect.origin = CGPointMake(0.0,0.0);
    viewRect.size.width  = viewSize.width;
    viewRect.size.height = viewSize.height;
    
    [self.originalImage drawInRect:viewRect];

    self.imageView.image = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    
    
    // Now make the thumbnail to save
    
    
    
    CGSize thumbSize = CGSizeMake(320, 320);
    UIGraphicsBeginImageContext(thumbSize);
    
    CGRect thumbRect = CGRectMake(0, 0, 0, 0);
    thumbRect.origin = CGPointMake(0.0,0.0);
    thumbRect.size.width  = thumbSize.width;
    thumbRect.size.height = thumbSize.height;
    
    [self.originalImage drawInRect:thumbRect];

    self.thumbnailImage = UIGraphicsGetImageFromCurrentImageContext();
    
    [self dismissViewControllerAnimated:YES completion:NULL];
    NSLog(@"After dismiss.");
}

- (IBAction)insertNewObject:(id)sender {
    BOOL upload = YES;
    
    if (!self.originalImage) {
        upload = NO;
        
        UIAlertController *pictureAlertController = [UIAlertController alertControllerWithTitle:@"Missing Photo" message:@"You cannot submit a post without a photo." preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault handler:nil];
        
        [pictureAlertController addAction:okAction];
        [self presentViewController:pictureAlertController animated:YES completion:nil];
    } if ([self.messageView.text isEqualToString:@""]) {
        upload = NO;
        
        UIAlertController *messageAlertController = [UIAlertController alertControllerWithTitle:@"Missing Message" message:@"You cannot submit a post without a message." preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault handler:nil];
        
        [messageAlertController addAction:okAction];
        [self presentViewController:messageAlertController animated:YES completion:nil];
    }
    
    if (upload) {
        // Get the image
        NSData *imageData = UIImageJPEGRepresentation(self.originalImage, 0.5);
        PFFile *imageFile = [PFFile fileWithName:@"photo.jpg" data:imageData];
        
        // Get the thumbnail
        NSData *thumbData = UIImageJPEGRepresentation(self.thumbnailImage, 0.5);
        PFFile *thumbFile = [PFFile fileWithName:@"photo.jpg" data:thumbData];
        
//        PFObject *object = [PFObject objectWithClassName:@"Submission"];
        PFObject *object = [PFObject objectWithClassName:@"Submission"];
        
        NSLog(@"We're going to save now.");
        
        
        NSUUID *oNSUUID = [[UIDevice currentDevice] identifierForVendor];
        [object setObject:[NSString stringWithString:[oNSUUID UUIDString]] forKey:@"userDeviceID"];
        PFUser *user = [PFUser currentUser];
        [object setObject:user forKey:@"user"];
        
        AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
        
        [object setObject:imageFile forKey:@"file"];
        [object setObject:thumbFile forKey:@"thumbnail"];
        [object setObject:[NSString stringWithString:self.messageView.text] forKey:@"message"];
        [object setObject:appDelegate.userLocation forKey:@"location"];
        [object saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            // Refresh the table when the object is done saving.
            [self.parentView refresh:nil];
            NSLog(@"We're saving now.");
        }];
        
        [self dismissViewControllerAnimated:YES completion:NULL];
    }
    
}

- (IBAction)cancelInsert:(id)sender {
    [self dismissViewControllerAnimated:YES completion:NULL];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    for (UIView * txt in self.view.subviews){
        if ([txt isKindOfClass:[UITextField class]] && [txt isFirstResponder]) {
            [txt resignFirstResponder];
        }
    }
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (void)dealloc {
    [_imageView release];
    [_messageView release];
    [_selectExistingButton release];
    [super dealloc];
}
@end
