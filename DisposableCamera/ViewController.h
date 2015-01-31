//
//  ViewController.h
//  DisposableCamera
//
//  Created by Bobby Ren on 12/29/14.
//  Copyright (c) 2014 Bobby Ren Tech. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CameraOverlayViewController.h"
#import "FilmRollViewController.h"

@interface ViewController : UIViewController <UIImagePickerControllerDelegate, UINavigationControllerDelegate, CameraOverlayDelegate, FilmRollDelegate>
{
    UIImagePickerController *_picker;
    CameraOverlayViewController *overlayController;

    NSMutableArray *images;
}

@end

