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

}

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self showCameraFromController:self];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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

    CGRect frame = _appDelegate.window.bounds;
    frame.origin.y = 0;
    _picker.view.frame = frame;
    _picker.view.center = self.view.center;
    _picker.view.backgroundColor = [UIColor clearColor];
    _picker.view.layer.borderColor = [[UIColor redColor] CGColor];
    _picker.view.layer.borderWidth = 5;
//    _picker.view.transform = CGAffineTransformMakeScale(.5, .5);
//    _picker.cameraViewTransform = CGAffineTransformTranslate(_picker.cameraViewTransform, 0, 0);
//    _picker.cameraViewTransform = CGAffineTransformScale(_picker.cameraViewTransform, .25, .25);
//    _picker.cameraViewTransform = CGAffineTransformRotate(_picker.cameraViewTransform, M_PI_2);

//    [controller.view addSubview:_picker.view];
    overlayController = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"CameraOverlayViewController"];

    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        [controller presentViewController:_picker animated:NO completion:nil];
        [_picker setCameraOverlayView:overlayController.view];
    }
    else {
        [controller presentViewController:overlayController animated:NO completion:nil];
    }
}

@end
