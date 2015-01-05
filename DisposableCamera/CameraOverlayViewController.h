//
//  CameraOverlayViewController.h
//  DisposableCamera
//
//  Created by Bobby Ren on 1/5/15.
//  Copyright (c) 2015 Bobby Ren Tech. All rights reserved.
//

#import <UIKit/UIKit.h>

#define MAX_ADVANCE_COUNT 4

@interface CameraOverlayViewController : UIViewController <UIGestureRecognizerDelegate>
{
    IBOutlet UIButton *buttonFlash;
    IBOutlet UIView *viewFilmAdvance;
    BOOL flash;
    int advancedCount;

    IBOutlet NSLayoutConstraint *constraintFlashOffsetTop;
    IBOutlet NSLayoutConstraint *constraintFlashOffsetRight;
    IBOutlet NSLayoutConstraint *constraintAdvanceOffsetTop;
    IBOutlet NSLayoutConstraint *constraintAdvanceOffsetRight;

    IBOutlet UIImageView *scrollImage2;
    IBOutlet UIImageView *scrollImage3;
}

-(IBAction)didClickButtonFlash:(id)sender;
-(IBAction)didClickCapture:(id)sender;

@end
