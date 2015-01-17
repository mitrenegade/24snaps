//
//  ViewController.h
//  DisposableCamera
//
//  Created by Bobby Ren on 12/29/14.
//  Copyright (c) 2014 Bobby Ren Tech. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CameraOverlayViewController.h"

@interface ViewController : UIViewController <UIImagePickerControllerDelegate, UINavigationControllerDelegate, CameraOverlayDelegate>
{
    UIImagePickerController *_picker;
    CameraOverlayViewController *overlayController;

    NSMutableArray *images;
}
@end

