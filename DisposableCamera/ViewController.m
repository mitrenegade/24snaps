//
//  ViewController.m
//  DisposableCamera
//
//  Created by Bobby Ren on 12/29/14.
//  Copyright (c) 2014 Bobby Ren Tech. All rights reserved.
//

#import "ViewController.h"
#import "AppDelegate.h"
#import "CameraOverlayViewController.h"
#import "FilmRollViewController.h"
#import "BackgroundHelper.h"

static NSString* const PASTEBOARD_NAME = @"tech.bobbyren.Pasteboard";
static NSString* const PASTEBOARD_TYPE = @"tech.bobbyren.data";

@interface ViewController ()
@end

@implementation ViewController

-(NSUInteger)navigationControllerSupportedInterfaceOrientations:(UINavigationController *)navigationController {
    return UIInterfaceOrientationMaskLandscapeRight;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.

    [self loadImages];
}

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self showCameraFromController:self];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark Image storage
-(void)loadImages {
    images = [NSMutableArray arrayWithCapacity:MAX_ROLL_SIZE];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    for (int i=0; i<MAX_ROLL_SIZE; i++) {
        NSString *imageName = [documentsDirectory stringByAppendingString:[NSString stringWithFormat:@"/disposableCamera_%d", i]];
        NSString *imagePath = [imageName stringByAppendingString:@".png"];

        NSData *data = [NSData dataWithContentsOfFile:imagePath];
        if (data) {
            UIImage *image = [UIImage imageWithData:data];
            [images addObject:image];
        }
        else {
            break;
        }
    }
    NSLog(@"Current images on film roll: %lu", [images count]);

}
-(void)saveImage:(UIImage *)image atIndex:(int)index {
    //save it
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *imageName = [documentsDirectory stringByAppendingString:[NSString stringWithFormat:@"/disposableCamera_%d", index]];
    NSString *imagePath = [imageName stringByAppendingString:@".png"];

    NSData *data = UIImageJPEGRepresentation(image, .8);
    NSError* error = nil;
    BOOL success = [data writeToFile:imagePath options:0 error:&error];
    if (success) {
        // successfull save
        NSLog(@"Success save to: %@", imagePath);
    }
    else if (error) {
        NSLog(@"Error:%@", error.localizedDescription);
    }
}

#pragma mark Camera
-(void)showCameraFromController:(UIViewController *)controller {
    _picker = [[UIImagePickerController alloc] init];
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        _picker.sourceType = UIImagePickerControllerSourceTypeCamera;
        _picker.showsCameraControls = NO;
        [_picker setCameraFlashMode:UIImagePickerControllerCameraFlashModeOff];
    }
    else
        _picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;

    _picker.toolbarHidden = YES; // hide toolbar of app, if there is one.
    _picker.allowsEditing = NO;
    _picker.delegate = self;

    // iphone 6+
    if (_appDelegate.window.bounds.size.height == 736) {
        overlayController = [_storyboard instantiateViewControllerWithIdentifier:@"CameraOverlay_iPhone6+"];
    }

    // iphone 6
    else if (_appDelegate.window.bounds.size.height == 667) {
        overlayController = [_storyboard instantiateViewControllerWithIdentifier:@"CameraOverlay_iPhone6"];
    }

    // iphone 5/5s
    else if (_appDelegate.window.bounds.size.height == 568) {
        overlayController = [_storyboard instantiateViewControllerWithIdentifier:@"CameraOverlay_iPhone5"];
    }

    // iphone 4/4s
    else if (_appDelegate.window.bounds.size.height == 480) {
        overlayController = [_storyboard instantiateViewControllerWithIdentifier:@"CameraOverlay_iPhone4"];
    }
    overlayController.delegate = self;
#if TESTING
    overlayController.view.alpha = .3;
#endif
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        //_picker.cameraViewTransform = CGAffineTransformScale(CGAffineTransformIdentity, 1.5, 1.5); // make sure full camera fills screen
        [controller presentViewController:_picker animated:NO completion:nil];
        [_picker setCameraOverlayView:overlayController.view];
        [self zoomOut:YES];
    }
    else {
        // testing on devices
        [controller presentViewController:overlayController animated:NO completion:nil];
    }
}

#pragma mark Camera Transform
-(float)scale {
    return (float)[overlayController viewFinderWidth] / self.view.frame.size.width;
}

-(float)adjustY {
    // the camera starts at the top. this is the Y offset needed to center the camera at scale = 1

    // iphone 6+
    if (_appDelegate.window.bounds.size.height == 736) {
        return 80; // todo
    }

    // iphone 6
    else if (_appDelegate.window.bounds.size.height == 667) {
        return 75;
    }

    // iphone 5/5s
    else if (_appDelegate.window.bounds.size.height == 568) {
        return 60;
    }

    // iphone 4/4s
    else if (_appDelegate.window.bounds.size.height == 480) {
        return 50; // todo
    }

    return 0;
}

-(float)offsetx {
    float offsetx = [overlayController viewFinderOffsetX]/self.scale; //100.0/self.scale; //100/self.scale;
//    float offsetx = 100.0/self.scale; //100/self.scale;
    NSLog(@"offsetx: %f", offsetx);
    return offsetx;
}

-(float)offsety {
    float offsety =[overlayController viewFinderOffsetY]/self.scale + self.adjustY/self.scale; //70.0/self.scale; //70/self.scale;
//    float offsety = 70.0/self.scale; //70/self.scale;
    NSLog(@"offsety: %f", offsety);
    return offsety;
}

#pragma mark CameraOverlayDelegate
-(void)zoomIn {
    // run in inverse
    CGAffineTransform target = CGAffineTransformIdentity;
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        [UIView animateWithDuration:.5 animations:^{
            _picker.cameraViewTransform = target;
        }];
    }
}

-(void)zoomOut:(BOOL)animated {
    CGAffineTransform target = CGAffineTransformTranslate(CGAffineTransformMakeScale(self.scale, self.scale), self.offsetx, self.offsety);

    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        float duration = animated?.5:0;

        [UIView animateWithDuration:duration animations:^{
            _picker.cameraViewTransform = target;
        } completion:nil];
    }
}

-(void)enableFlash {
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        [_picker setCameraFlashMode:UIImagePickerControllerCameraFlashModeOn];
    }
}

-(NSInteger)initialRollCount {
    return [images count];
}

-(void)showFilmRoll {
    FilmRollViewController *controller = [_storyboard instantiateViewControllerWithIdentifier:@"FilmRollViewController"];
    controller.images = images;
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:controller];

    NSNumber *value = [NSNumber numberWithInt:UIInterfaceOrientationLandscapeRight];
    [[UIDevice currentDevice] setValue:value forKey:@"orientation"];

    [_picker presentViewController:nav animated:YES completion:nil];
}

-(void)capture {
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        [_picker takePicture];
    }
    else {
        // generate fake image (old style)
        UIImage *image = [UIImage imageNamed:@"bowling"];
        [self imagePickerController:_picker didFinishPickingMediaWithInfo:@{UIImagePickerControllerOriginalImage:image}];
    }
}

#pragma mark UIImagePickerDelegate
-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    NSLog(@"Captured image!");

    UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];

    UIImageOrientation o = image.imageOrientation;
    NSLog(@"orientation: %d", o);

    if (o == UIImageOrientationUp) {
        NSLog(@"up");
        // images captured with the camera in the correct orientation is this way.
    }
    else { //if (o == UIImageOrientationRight) {
        NSLog(@"Right");
        // phone in portrait mode
        image = [self rotateImage:image withCurrentOrientation:image.imageOrientation];
    }

    UIImage *negative = [self makeImageNegative:image];

    // todo: shrink, filter images

    [images addObject:negative];
    [self saveImage:negative atIndex:(int)(images.count-1)];

    [[NSNotificationCenter defaultCenter] postNotificationName:@"image:captured" object:nil];
}

-(UIImage *)rotateImage:(UIImage *)image withCurrentOrientation:(int)orient
{
    int kMaxResolution = 320; // Or whatever

    CGImageRef imgRef = image.CGImage;

    CGFloat width = CGImageGetWidth(imgRef);
    CGFloat height = CGImageGetHeight(imgRef);

    CGAffineTransform transform = CGAffineTransformIdentity;
    CGRect bounds = CGRectMake(0, 0, width, height);

    CGFloat scaleRatio = 1; //bounds.size.width / width;
    CGSize imageSize = CGSizeMake(CGImageGetWidth(imgRef), CGImageGetHeight(imgRef));
    CGFloat boundHeight;

    // do not rotate any images
    transform = CGAffineTransformIdentity;

    UIGraphicsBeginImageContext(bounds.size);

    CGContextRef context = UIGraphicsGetCurrentContext();

    if (orient == 3 || orient == 4) {   // landscape
//        CGContextScaleCTM(context, -scaleRatio, scaleRatio);
//        CGContextTranslateCTM(context, -height, 0);
    }
    else {
        CGContextScaleCTM(context, scaleRatio, -scaleRatio);
        CGContextTranslateCTM(context, 0, -height);
    }

    CGContextConcatCTM(context, transform);

    CGContextDrawImage(UIGraphicsGetCurrentContext(), CGRectMake(0, 0, width, height), imgRef);
    UIImage *imageCopy = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();

    return imageCopy;
}

- (UIImage *)makeImageNegative:(UIImage *)image{
    UIGraphicsBeginImageContext(image.size);
    CGContextSetBlendMode(UIGraphicsGetCurrentContext(), kCGBlendModeCopy);
    [image drawInRect:CGRectMake(0, 0, image.size.width, image.size.height)];
    CGContextSetBlendMode(UIGraphicsGetCurrentContext(), kCGBlendModeDifference);
    CGContextSetFillColorWithColor(UIGraphicsGetCurrentContext(),[UIColor       whiteColor].CGColor);
    CGContextFillRect(UIGraphicsGetCurrentContext(), CGRectMake(0, 0,   image.size.width, image.size.height));
    UIImage *returnImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return returnImage;
}
@end
