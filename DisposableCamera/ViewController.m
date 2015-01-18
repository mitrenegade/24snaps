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
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSData *imageData = [defaults objectForKey:@"images"];
    if (imageData) {
        images = [NSKeyedUnarchiver unarchiveObjectWithData:imageData];
    }
    else {
        images = [NSMutableArray array];
    }
    NSLog(@"Current images on film roll: %lu", [images count]);
}

-(void)saveImageDictionary {
    NSData *imageData = [NSKeyedArchiver archivedDataWithRootObject:images];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:imageData forKey:@"images"];
    [defaults synchronize];
}

#pragma mark Camera
-(void)showCameraFromController:(UIViewController *)controller {
    _picker = [[UIImagePickerController alloc] init];
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        _picker.sourceType = UIImagePickerControllerSourceTypeCamera;
        _picker.showsCameraControls = NO;
    }
    else
        _picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;

    _picker.toolbarHidden = YES; // hide toolbar of app, if there is one.
    _picker.allowsEditing = NO;
    _picker.delegate = self;

    // todo:
    // calculate offsets for each device

    overlayController = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"CameraOverlayViewController"];
    overlayController.delegate = self;
    //overlayController.view.alpha = .3;

    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        //_picker.cameraViewTransform = CGAffineTransformScale(CGAffineTransformIdentity, 1.5, 1.5); // make sure full camera fills screen
        [self zoomOut:NO];
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
    return .15;
}

-(float)offsetx {
    float offsetx = + 100/self.scale;
    return offsetx;
}

-(float)offsety {
    float offsety = 70/self.scale;
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

        if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {

            [UIView animateWithDuration:duration animations:^{
                _picker.cameraViewTransform = target;
            }];
        }
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
    [self saveImageDictionary];
}

-(NSInteger)initialRollCount {
    return [images count];
}
@end
