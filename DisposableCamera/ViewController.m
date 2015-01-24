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

@interface ViewController ()
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.

    [self loadImageDictionary];
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
-(void)loadImageDictionary {
#if 1
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSData *imageData = [defaults objectForKey:@"images"];
    if (imageData) {
        images = [NSKeyedUnarchiver unarchiveObjectWithData:imageData];
    }
    else {
        images = [NSMutableArray array];
    }
#else
    images = [NSKeyedUnarchiver unarchiveObjectWithFile:@"images"];
    if (!images)
        images = [NSMutableArray array];
#endif
    NSLog(@"Current images on film roll: %lu", [images count]);
}

-(void)saveImageDictionary {
#if 1
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSData *imageData = [NSKeyedArchiver archivedDataWithRootObject:images];
        dispatch_sync(dispatch_get_main_queue(), ^{
            NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
            [defaults setObject:imageData forKey:@"images"];
            [defaults synchronize];
        });
    });
#else
    // todo: make this work
    BOOL done = [NSKeyedArchiver archiveRootObject:images toFile:@"images"];
#endif
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
        overlayController = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"CameraOverlay_iPhone6+"];
    }

    // iphone 6
    else if (_appDelegate.window.bounds.size.height == 667) {
        overlayController = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"CameraOverlay_iPhone6"];
    }

    // iphone 5/5s
    else if (_appDelegate.window.bounds.size.height == 568) {
        overlayController = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"CameraOverlay_iPhone5"];
    }

    // iphone 4/4s
    else if (_appDelegate.window.bounds.size.height == 480) {
        overlayController = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"CameraOverlay_iPhone4"];
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
        return 50; // todo
    }

    // iphone 6
    else if (_appDelegate.window.bounds.size.height == 667) {
        return 50; // todo
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

-(void)zoomIn {
    // run in inverse
    CGAffineTransform target = CGAffineTransformIdentity;
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        [UIView animateWithDuration:1 animations:^{
            _picker.cameraViewTransform = target;
        }];
    }
}

-(void)zoomOut:(BOOL)animated {
    CGAffineTransform target = CGAffineTransformTranslate(CGAffineTransformMakeScale(self.scale, self.scale), self.offsetx, self.offsety);

    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        float duration = animated?1:0;

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

#pragma mark UIImagePickerDelegate
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

-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    NSLog(@"Captured image!");

    UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];

    // todo: shrink, filter images; create negative
    [images addObject:image];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self saveImageDictionary];
    });
}

-(NSInteger)initialRollCount {
    return [images count];
}

@end
