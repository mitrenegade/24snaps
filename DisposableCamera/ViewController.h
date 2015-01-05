//
//  ViewController.h
//  DisposableCamera
//
//  Created by Bobby Ren on 12/29/14.
//  Copyright (c) 2014 Bobby Ren Tech. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CameraOverlayViewController;
@interface ViewController : UIViewController <UIImagePickerControllerDelegate, UINavigationControllerDelegate>
{
    UIImagePickerController *_picker;
    CameraOverlayViewController *overlayController;
}
@end

