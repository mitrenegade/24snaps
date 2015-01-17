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

    float scale = .25;
    float offsetx = -self.view.frame.size.width / 2 - 50/scale;
    float offsety = -self.view.frame.size.height / 2 + 150/scale;

    // todo:
    // calculate offsets for each device

    overlayController = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"CameraOverlayViewController"];
    overlayController.delegate = self;
    //overlayController.view.alpha = .3;

    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        _picker.cameraViewTransform = CGAffineTransformScale(_picker.cameraViewTransform, scale, scale);
        _picker.cameraViewTransform = CGAffineTransformTranslate(_picker.cameraViewTransform, offsetx, offsety);

        [controller presentViewController:_picker animated:NO completion:nil];
        [_picker setCameraOverlayView:overlayController.view];
    }
    else {
        // testing on devices
        [controller presentViewController:overlayController animated:NO completion:nil];
    }
}

-(void)zoomIn {
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        [UIView animateWithDuration:1 animations:^{
            _picker.cameraViewTransform = CGAffineTransformMakeScale(1.14, 1.14);
        }];
    }
}

-(void)zoomOut:(BOOL)animated {
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        float scale = .25;
        float offsetx = -self.view.frame.size.width / 2 - 50/scale;
        float offsety = -self.view.frame.size.height / 2 + 150/scale;

        float duration = animated?1:0;

        if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
            [UIView animateWithDuration:duration animations:^{
                _picker.cameraViewTransform = CGAffineTransformMakeScale(scale, scale);
                _picker.cameraViewTransform = CGAffineTransformTranslate(_picker.cameraViewTransform, offsetx, offsety);
            }];
        }
    }
}

@end
